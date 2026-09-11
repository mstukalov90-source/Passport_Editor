(function (global) {
    'use strict';

    const PV = global.PassViewer || (global.PassViewer = {});

    const PANE_NAME = 'selectivePane';

    function escapeHtml(value) {
        return PV.escapeHtml
            ? PV.escapeHtml(String(value == null ? '' : value))
            : String(value == null ? '' : value);
    }

    function asGetter(value) {
        if (typeof value === 'function') {
            return value;
        }
        return function () {
            return value || null;
        };
    }

    function objectLabel(obj) {
        const label = String(
            (obj && (obj.descr || obj.address || obj.name)) || ''
        ).trim();
        if (label) {
            return label;
        }
        const id = obj && obj.id;
        return id != null ? 'Объект #' + id : 'Без названия';
    }

    function objectMeta(obj) {
        const parts = [];
        const pct = Number(obj && obj.pct);
        if (Number.isFinite(pct) && pct > 0) {
            parts.push(pct.toFixed(2) + '%');
        }
        const areaM2 = Number(obj && obj.intersection_area_m2);
        if (Number.isFinite(areaM2) && areaM2 > 0) {
            parts.push(Math.round(areaM2 * 10) / 10 + ' м²');
        }
        return parts.join(' · ');
    }

    // После вырезания пересечения объект может остаться «касательным»
    // (общая граница, площадь 0) — такие строки в списке не показываем.
    function hasRealIntersection(obj) {
        return (
            !!obj &&
            !!(
                (obj.intersection_geometry || obj.geometry) &&
                (Number(obj.pct) > 0 || Number(obj.intersection_area_m2) > 0)
            )
        );
    }

    /**
     * «Выборочно удалить пересечения» — режим карты вместо списка в модалке.
     *
     * Вход: кнопка в модалке «Пересечение с З/У и ОГХ». Модалка закрывается,
     * список пересекающих объектов уходит в секцию «Управление слоями»,
     * с карты скрываются все слои кроме редактируемого объекта и объектов
     * списка. Клик по объекту списка/карты: объект мигает красным, зона
     * пересечения — жёлтым. «Удалить» вырезает пересечение (cut-geometry),
     * «Выйти из режима» возвращает слои и панель. Данные — один запрос
     * intersecs-analiz/data (layers для З/У и ogx_layers для ОГХ).
     *
     * map / managedLayers / editedGroup можно передавать значением или
     * функцией-геттером (страничные сущности объявлены ниже точки вызова).
     */
    PV.initCheckDgiSelectiveRemoval = function initCheckDgiSelectiveRemoval(opts) {
        const options = opts || {};
        const button =
            options.button || document.getElementById('check-dgi-selective-remove-btn');
        const modeController = options.modeController || null;
        const dataUrl = String(options.dataUrl || '').trim();
        const cutUrl = String(options.cutUrl || '').trim();
        const getGeometry = options.getGeometry || null;
        const getContext = options.getContext || null;
        const applyGeometry = options.applyGeometry || null;
        const afterChange = options.afterChange || null;
        const onDataFresh = options.onDataFresh || null;
        const setStatus = options.setStatus || null;
        const getCsrfToken = options.getCsrfToken || function () { return ''; };
        const getMap = asGetter(options.map);
        const getManagedLayers = asGetter(options.managedLayers);
        const getEditedGroup = asGetter(options.editedGroup);
        const closeModal = options.closeModal || null;
        const afterExit = options.afterExit || null;

        if (!button || !dataUrl || !cutUrl || !getGeometry || !applyGeometry) {
            return { reset: function () {} };
        }

        let active = false; // режим включён
        let busy = false; // идёт запрос списка или удаление
        let lastData = null; // последний ответ intersecs-analiz/data
        let capturedCtx = null; // контекст (rootid/request_id) на момент входа
        let hiddenKeys = []; // какие слои были скрыты при входе в режим
        let panelNode = null;
        let panelGrid = null;
        let objectGroup = null; // полигоны объектов списка
        let overlapGroup = null; // жёлтая зона пересечения выбранного объекта
        let objectRenderer = null;
        let objectPaths = {}; // 'layerKey:index' -> SVG path
        let selected = null; // { layerKey, objectIndex }

        button.style.display = '';

        function currentLayers() {
            if (!lastData) {
                return [];
            }
            const mode =
                modeController && modeController.getMode
                    ? modeController.getMode()
                    : 'zu';
            const layers = mode === 'ogx' ? lastData.ogx_layers : lastData.layers;
            return Array.isArray(layers) ? layers : [];
        }

        function findObject(layerKey, objectIndex) {
            const layer = currentLayers().find((item) => item && item.key === layerKey);
            const obj = layer && (layer.objects || [])[objectIndex];
            return { layer: layer, obj: obj };
        }

        function objectKey(layerKey, objectIndex) {
            return layerKey + ':' + objectIndex;
        }

        async function fetchList() {
            const geometry = getGeometry();
            if (!geometry) {
                throw new Error('Нет геометрии для анализа пересечений.');
            }
            const ctx = capturedCtx || (getContext ? getContext() : null) || {};
            const response = await fetch(dataUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCsrfToken(),
                },
                credentials: 'same-origin',
                body: JSON.stringify({
                    geometry: geometry,
                    rootid: ctx.rootid || '',
                    request_id: ctx.request_id || '',
                }),
            });
            const data = await PV.parseJsonResponse(response);
            if (!response.ok || !data || !data.ok) {
                throw new Error(
                    (data && data.error) || 'Не удалось получить список пересечений.'
                );
            }
            lastData = data;
            if (onDataFresh) {
                onDataFresh(data);
            }
        }

        /* ---------- Панель «Управление слоями» ---------- */

        function rowHtml(layer, obj, index) {
            const label = objectLabel(obj);
            const meta = objectMeta(obj);
            return (
                '<div class="selective-panel__row" data-layer-key="' +
                escapeHtml(layer.key) +
                '" data-object-index="' +
                index +
                '" role="button" tabindex="0">' +
                '<span class="selective-panel__name" title="' +
                escapeHtml(label) +
                '">' +
                escapeHtml(label) +
                '</span>' +
                (meta
                    ? '<span class="selective-panel__meta">' + escapeHtml(meta) + '</span>'
                    : '') +
                '<button type="button" class="selective-panel__remove" data-layer-key="' +
                escapeHtml(layer.key) +
                '" data-object-index="' +
                index +
                '">Удалить</button>' +
                '</div>'
            );
        }

        function layerBlockHtml(layer) {
            const objects = (layer.objects || []).filter(hasRealIntersection);
            if (!objects.length) {
                return '';
            }
            const rows = (layer.objects || [])
                .map((obj, index) => (hasRealIntersection(obj) ? rowHtml(layer, obj, index) : ''))
                .join('');
            return (
                '<div class="selective-panel__layer">' +
                '<div class="selective-panel__layer-title">' +
                escapeHtml(layer.label || layer.key) +
                ' <span class="selective-panel__layer-count">(' +
                objects.length +
                ')</span></div>' +
                rows +
                '</div>'
            );
        }

        function listHtml() {
            const mode =
                modeController && modeController.getMode
                    ? modeController.getMode()
                    : 'zu';
            const blocks = currentLayers()
                .map(layerBlockHtml)
                .filter(Boolean)
                .join('');
            if (!blocks) {
                return '<div class="selective-panel__empty">Пересечений не найдено.</div>';
            }
            return (
                '<div class="selective-panel__list">' +
                blocks +
                '</div>' +
                '<p class="selective-panel__footer">Режим: ' +
                (mode === 'ogx' ? 'ОГХ' : 'З/У') +
                '. Кликните по объекту — он мигает красным, зона пересечения — жёлтым.</p>'
            );
        }

        function renderPanelList(notice) {
            if (!panelNode) {
                return;
            }
            const noticeEl = panelNode.querySelector('.selective-panel__notice');
            if (noticeEl) {
                noticeEl.hidden = !notice;
                noticeEl.textContent = notice || '';
            }
            const container = panelNode.querySelector('.selective-panel__content');
            if (container) {
                container.innerHTML = listHtml();
            }
            bindPanelHandlers();
            applySelectionToPanel();
        }

        function bindPanelHandlers() {
            if (!panelNode) {
                return;
            }
            panelNode.querySelectorAll('.selective-panel__row').forEach((row) => {
                row.addEventListener('click', () => {
                    const index = Number(row.dataset.objectIndex);
                    if (!Number.isFinite(index)) {
                        return;
                    }
                    selectObject(row.dataset.layerKey, index);
                });
                row.addEventListener('keydown', (event) => {
                    if (event.key !== 'Enter' && event.key !== ' ') {
                        return;
                    }
                    event.preventDefault();
                    row.click();
                });
            });
            panelNode.querySelectorAll('.selective-panel__remove').forEach((btn) => {
                btn.addEventListener('click', (event) => {
                    event.stopPropagation();
                    const index = Number(btn.dataset.objectIndex);
                    if (!Number.isFinite(index)) {
                        return;
                    }
                    void removeObject(btn.dataset.layerKey, index, btn);
                });
            });
        }

        function buildPanel() {
            const section = document.getElementById('layer-management-panel');
            if (!section) {
                return;
            }
            const bodyEl = section.querySelector('.add-object-layers__body');
            if (!bodyEl) {
                return;
            }
            panelGrid = bodyEl.querySelector('.layer-management-panel');
            if (panelGrid) {
                panelGrid.style.display = 'none';
            }
            panelNode = document.createElement('div');
            panelNode.className = 'selective-panel';
            panelNode.id = 'selective-removal-panel';
            panelNode.innerHTML =
                '<div class="selective-panel__header">' +
                '<span class="selective-panel__title">Выборочное удаление пересечений</span>' +
                '<button type="button" class="selective-panel__exit" title="Вернуть слои и выйти из режима">Выйти из режима</button>' +
                '</div>' +
                '<p class="selective-panel__notice" hidden></p>' +
                '<div class="selective-panel__content"></div>';
            const exitBtn = panelNode.querySelector('.selective-panel__exit');
            exitBtn.addEventListener('click', () => {
                exitMode();
            });
            bodyEl.insertBefore(panelNode, bodyEl.firstChild);
            renderPanelList();
        }

        /* ---------- Карта ---------- */

        function ensureRenderer(map) {
            if (!map.getPane(PANE_NAME)) {
                const pane = map.createPane(PANE_NAME);
                pane.style.zIndex = 655;
            }
            if (!objectRenderer) {
                objectRenderer = L.svg({ padding: 0.5, pane: PANE_NAME });
            }
        }

        function clearMapLayers() {
            const map = getMap();
            if (!map) {
                return;
            }
            if (objectGroup && map.hasLayer(objectGroup)) {
                map.removeLayer(objectGroup);
            }
            if (overlapGroup && map.hasLayer(overlapGroup)) {
                map.removeLayer(overlapGroup);
            }
            objectGroup = null;
            overlapGroup = null;
            objectPaths = {};
        }

        function buildMapLayers() {
            const map = getMap();
            if (!map) {
                return;
            }
            clearMapLayers();
            ensureRenderer(map);
            objectGroup = L.featureGroup().addTo(map);
            overlapGroup = L.featureGroup().addTo(map);
            currentLayers().forEach((layer) => {
                (layer.objects || []).forEach((obj, index) => {
                    if (!hasRealIntersection(obj) || !obj.geometry) {
                        return;
                    }
                    const key = objectKey(layer.key, index);
                    const geo = L.geoJSON(obj.geometry, {
                        renderer: objectRenderer,
                        pane: PANE_NAME,
                        interactive: true,
                        bubblingMouseEvents: false,
                        style: {
                            color: '#475569',
                            weight: 2,
                            fillColor: '#94a3b8',
                            fillOpacity: 0.18,
                            className: 'selective-object',
                        },
                    });
                    geo.eachLayer((pathLayer) => {
                        pathLayer.on('click', () => {
                            selectObject(layer.key, index);
                        });
                    });
                    objectGroup.addLayer(geo);
                    const first = geo.getLayers()[0];
                    const pathEl = first && first.getElement ? first.getElement() : null;
                    if (pathEl) {
                        objectPaths[key] = pathEl;
                    }
                });
            });
            const bounds = objectGroup.getBounds();
            if (bounds.isValid()) {
                map.fitBounds(bounds.pad(0.25), { maxZoom: 18 });
            }
        }

        function hideOtherLayers() {
            const map = getMap();
            const managedLayers = getManagedLayers();
            const editedGroup = getEditedGroup();
            if (!map || !managedLayers) {
                return;
            }
            hiddenKeys = [];
            Object.keys(managedLayers).forEach((key) => {
                const group = managedLayers[key];
                if (!group || group === editedGroup) {
                    return;
                }
                if (map.hasLayer(group)) {
                    map.removeLayer(group);
                    hiddenKeys.push(key);
                }
            });
        }

        function restoreHiddenLayers() {
            const map = getMap();
            const managedLayers = getManagedLayers();
            if (!map || !managedLayers) {
                return;
            }
            hiddenKeys.forEach((key) => {
                const group = managedLayers[key];
                if (group && !map.hasLayer(group)) {
                    group.addTo(map);
                }
            });
            hiddenKeys = [];
        }

        /* ---------- Выбор объекта ---------- */

        function applySelectionToPanel() {
            if (!panelNode) {
                return;
            }
            panelNode.querySelectorAll('.selective-panel__row').forEach((row) => {
                const isSelected =
                    !!selected &&
                    row.dataset.layerKey === selected.layerKey &&
                    Number(row.dataset.objectIndex) === selected.objectIndex;
                row.classList.toggle('is-selected', isSelected);
            });
        }

        function clearSelection() {
            if (selected) {
                const pathEl = objectPaths[objectKey(selected.layerKey, selected.objectIndex)];
                if (pathEl) {
                    pathEl.classList.remove('selective-object-blink');
                }
            }
            if (overlapGroup) {
                overlapGroup.clearLayers();
            }
            selected = null;
            applySelectionToPanel();
        }

        function selectObject(layerKey, objectIndex) {
            const found = findObject(layerKey, objectIndex);
            if (!found.obj || !hasRealIntersection(found.obj)) {
                return;
            }
            if (
                selected &&
                selected.layerKey === layerKey &&
                selected.objectIndex === objectIndex
            ) {
                clearSelection();
                return;
            }
            clearSelection();
            selected = { layerKey: layerKey, objectIndex: objectIndex };

            const pathEl = objectPaths[objectKey(layerKey, objectIndex)];
            if (pathEl) {
                pathEl.classList.add('selective-object-blink');
            }
            const overlapGeometry =
                found.obj.intersection_geometry || found.obj.geometry;
            if (overlapGroup && overlapGeometry) {
                const overlapLayer = L.geoJSON(overlapGeometry, {
                    renderer: objectRenderer,
                    pane: PANE_NAME,
                    interactive: false,
                    style: {
                        color: '#b45309',
                        weight: 2,
                        fillColor: '#facc15',
                        fillOpacity: 0.55,
                        className: 'selective-overlap-blink',
                    },
                });
                overlapGroup.addLayer(overlapLayer);
                if (typeof overlapLayer.bringToFront === 'function') {
                    overlapLayer.bringToFront();
                }
            }
            applySelectionToPanel();
            if (panelNode) {
                const row = panelNode.querySelector(
                    '.selective-panel__row[data-layer-key="' +
                        escapeHtml(layerKey) +
                        '"][data-object-index="' +
                        objectIndex +
                        '"]'
                );
                if (row && typeof row.scrollIntoView === 'function') {
                    row.scrollIntoView({ block: 'nearest' });
                }
            }
        }

        /* ---------- Удаление пересечения ---------- */

        async function removeObject(layerKey, objectIndex, btn) {
            if (busy) {
                return;
            }
            const found = findObject(layerKey, objectIndex);
            const obj = found.obj;
            if (!obj || !(obj.intersection_geometry || obj.geometry)) {
                return;
            }
            const geometry = getGeometry();
            if (!geometry) {
                renderPanelList('Нет геометрии редактируемого объекта.');
                return;
            }
            busy = true;
            if (btn) {
                btn.disabled = true;
                btn.textContent = 'Удаляем…';
            }
            const label = objectLabel(obj);
            try {
                const response = await fetch(cutUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCsrfToken(),
                    },
                    credentials: 'same-origin',
                    body: JSON.stringify({
                        geometry: geometry,
                        cutter_geometry: obj.intersection_geometry || obj.geometry,
                        cutter_type: 'polygon',
                    }),
                });
                const data = await PV.parseJsonResponse(response);
                if (!response.ok || !data || !data.ok) {
                    throw new Error(
                        (data && data.error) || 'Не удалось удалить пересечение.'
                    );
                }
                if (!applyGeometry(data.geometry)) {
                    throw new Error('Не удалось применить обновлённую геометрию.');
                }
                if (afterChange) {
                    await afterChange();
                }
                if (setStatus) {
                    setStatus('Пересечение с «' + label + '» удалено.');
                }
                await fetchList();
                clearSelection();
                buildMapLayers();
                renderPanelList();
            } catch (error) {
                renderPanelList(error.message || 'Не удалось удалить пересечение.');
                if (btn) {
                    btn.disabled = false;
                    btn.textContent = 'Удалить';
                }
            } finally {
                busy = false;
            }
        }

        /* ---------- Вход / выход из режима ---------- */

        async function enterMode() {
            if (active || busy) {
                return;
            }
            if (!getMap() || !getManagedLayers()) {
                if (setStatus) {
                    setStatus('Карта недоступна для режима выборочного удаления.');
                }
                return;
            }
            busy = true;
            button.disabled = true;
            try {
                capturedCtx = (getContext ? getContext() : null) || {};
                await fetchList();
                active = true;
                if (closeModal) {
                    closeModal();
                }
                hideOtherLayers();
                buildPanel();
                buildMapLayers();
                if (setStatus) {
                    setStatus(
                        'Режим выборочного удаления: на карте только пересекающие объекты.'
                    );
                }
            } catch (error) {
                if (setStatus) {
                    setStatus(error.message || 'Не удалось получить список пересечений.');
                }
            } finally {
                busy = false;
                button.disabled = false;
            }
        }

        function exitMode() {
            clearSelection();
            clearMapLayers();
            restoreHiddenLayers();
            if (panelNode && panelNode.parentNode) {
                panelNode.parentNode.removeChild(panelNode);
            }
            panelNode = null;
            if (panelGrid) {
                panelGrid.style.display = '';
            }
            panelGrid = null;
            active = false;
            lastData = null;
            capturedCtx = null;
            if (afterExit) {
                try {
                    afterExit();
                } catch (_err) {
                    /* страница должна сама обрабатывать свои ошибки обновления */
                }
            }
            if (setStatus) {
                setStatus('Режим выборочного удаления выключен.');
            }
        }

        button.addEventListener('click', () => {
            void enterMode();
        });

        return {
            reset: function reset() {
                if (active) {
                    exitMode();
                    return;
                }
                clearSelection();
                lastData = null;
                capturedCtx = null;
            },
            isActive: function isActive() {
                return active;
            },
        };
    };
})(typeof window !== 'undefined' ? window : global);

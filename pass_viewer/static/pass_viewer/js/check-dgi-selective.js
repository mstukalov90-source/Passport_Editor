(function (global) {
    'use strict';

    const PV = global.PassViewer || (global.PassViewer = {});

    function escapeHtml(value) {
        return PV.escapeHtml
            ? PV.escapeHtml(String(value == null ? '' : value))
            : String(value == null ? '' : value);
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

    function hasCutter(obj) {
        return !!(obj && (obj.intersection_geometry || obj.geometry));
    }

    // После вырезания пересечения объект может остаться «касательным»
    // (общая граница, площадь 0) — такие строки в списке не показываем.
    function hasRealIntersection(obj) {
        return (
            hasCutter(obj) &&
            (Number(obj.pct) > 0 || Number(obj.intersection_area_m2) > 0)
        );
    }

    /**
     * «Выборочно удалить пересечения» в модалке «Пересечение с З/У и ОГХ».
     *
     * Список пересекающих объектов берётся одним запросом intersecs-analiz/data
     * (ответ содержит layers для З/У и ogx_layers для ОГХ), удаление одного
     * объекта — вычитание его пересечения через cut-geometry. Список живёт
     * внутри карточки модалки и скроллится, не перекрывая карту.
     */
    PV.initCheckDgiSelectiveRemoval = function initCheckDgiSelectiveRemoval(opts) {
        const options = opts || {};
        const button =
            options.button || document.getElementById('check-dgi-selective-remove-btn');
        const body = options.body || document.getElementById('check-dgi-modal-body');
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

        if (!button || !body || !dataUrl || !cutUrl || !getGeometry || !applyGeometry) {
            return { reset: function () {} };
        }

        let active = false; // список открыт вместо таблицы
        let busy = false; // идёт запрос списка или удаление
        let lastData = null; // последний ответ intersecs-analiz/data

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

        async function fetchList() {
            const geometry = getGeometry();
            if (!geometry) {
                throw new Error('Нет геометрии для анализа пересечений.');
            }
            const ctx = getContext ? getContext() : null;
            const response = await fetch(dataUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCsrfToken(),
                },
                credentials: 'same-origin',
                body: JSON.stringify({
                    geometry: geometry,
                    rootid: (ctx && ctx.rootid) || '',
                    request_id: (ctx && ctx.request_id) || '',
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

        function objectRowHtml(layer, obj, index) {
            const label = objectLabel(obj);
            const meta = objectMeta(obj);
            return (
                '<div class="check-dgi-object">' +
                '<span class="check-dgi-object__name" title="' +
                escapeHtml(label) +
                '">' +
                escapeHtml(label) +
                '</span>' +
                (meta
                    ? '<span class="check-dgi-object__meta">' + escapeHtml(meta) + '</span>'
                    : '') +
                '<button type="button" class="check-dgi-object__remove" data-layer-key="' +
                escapeHtml(layer.key) +
                '" data-object-index="' +
                index +
                '">Удалить</button>' +
                '</div>'
            );
        }

        function layerBlockHtml(layer) {
            const rows = (layer.objects || [])
                .map((obj, index) =>
                    hasRealIntersection(obj) ? objectRowHtml(layer, obj, index) : ''
                )
                .join('');
            if (!rows) {
                return '';
            }
            return (
                '<div class="check-dgi-objects__layer">' +
                '<div class="check-dgi-objects__layer-title">' +
                escapeHtml(layer.label || layer.key) +
                '</div>' +
                rows +
                '</div>'
            );
        }

        function listHtml(notice) {
            const mode =
                modeController && modeController.getMode
                    ? modeController.getMode()
                    : 'zu';
            const header =
                '<div class="check-dgi-objects__header">' +
                '<span class="check-dgi-objects__title">Пересекающие объекты (' +
                (mode === 'ogx' ? 'ОГХ' : 'З/У') +
                ')</span>' +
                '<button type="button" class="check-dgi-objects__back">Назад к таблице</button>' +
                '</div>' +
                (notice
                    ? '<div class="check-dgi-objects__notice">' +
                      escapeHtml(notice) +
                      '</div>'
                    : '');
            const blocks = currentLayers()
                .map(layerBlockHtml)
                .filter(Boolean)
                .join('');
            if (!blocks) {
                return (
                    header +
                    '<div class="check-dgi-objects check-dgi-objects--empty">Пересечений не найдено.</div>'
                );
            }
            return header + '<div class="check-dgi-objects">' + blocks + '</div>';
        }

        function bindListHandlers() {
            const backBtn = body.querySelector('.check-dgi-objects__back');
            if (backBtn) {
                backBtn.addEventListener('click', closeList);
            }
            body.querySelectorAll('.check-dgi-object__remove').forEach((btn) => {
                btn.addEventListener('click', () => {
                    const index = Number(btn.dataset.objectIndex);
                    if (!Number.isFinite(index)) {
                        return;
                    }
                    void removeObject(btn.dataset.layerKey, index, btn);
                });
            });
        }

        function renderList(notice) {
            body.innerHTML = listHtml(notice);
            bindListHandlers();
        }

        async function openList() {
            if (active || busy) {
                return;
            }
            busy = true;
            active = true;
            body.innerHTML =
                '<div class="check-dgi-objects check-dgi-objects--empty">Загружаем пересекающие объекты…</div>';
            try {
                await fetchList();
                renderList();
            } catch (error) {
                renderList(error.message || 'Не удалось получить список пересечений.');
            } finally {
                busy = false;
            }
        }

        function closeList() {
            active = false;
            lastData = null;
            if (modeController && modeController.render) {
                modeController.render();
            } else {
                body.innerHTML = '';
            }
        }

        async function removeObject(layerKey, objectIndex, btn) {
            if (busy) {
                return;
            }
            const found = findObject(layerKey, objectIndex);
            const obj = found.obj;
            if (!obj || !hasCutter(obj)) {
                return;
            }
            const geometry = getGeometry();
            if (!geometry) {
                renderList('Нет геометрии редактируемого объекта.');
                return;
            }
            busy = true;
            btn.disabled = true;
            btn.textContent = 'Удаляем…';
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
                body.innerHTML =
                    '<div class="check-dgi-objects check-dgi-objects--empty">Обновляем список пересечений…</div>';
                await fetchList();
                renderList();
            } catch (error) {
                renderList(error.message || 'Не удалось удалить пересечение.');
            } finally {
                busy = false;
            }
        }

        button.addEventListener('click', () => {
            void openList();
        });

        if (modeController && modeController.onModeChange) {
            modeController.onModeChange(() => {
                if (active && !busy) {
                    renderList();
                }
            });
        }

        return {
            reset: function reset() {
                active = false;
                busy = false;
                lastData = null;
            },
        };
    };
})(typeof window !== 'undefined' ? window : global);

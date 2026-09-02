(function () {
    'use strict';

    const PV = window.PassViewer || {};
    const cfg = typeof PV.getPageConfig === 'function' ? PV.getPageConfig() : { urls: {} };
    const urls = cfg.urls || {};
    const dataUrl = urls.intersecsAnalizData || '';
    const detailsUrl = urls.personalObjectDetails || '';

    const statusEl = document.getElementById('intersecs-analiz-status');
    const metaEl = document.getElementById('intersecs-analiz-meta');
    const tableWrap = document.getElementById('intersecs-analiz-table-wrap');
    const mapEl = document.getElementById('intersecs-analiz-map');

    const LAYER_STYLES = {
        dgi_moscow_rent: { color: '#dc2626', fillColor: '#f87171' },
        dgi_moscow_no_rent: { color: '#ea580c', fillColor: '#fdba74' },
        dgi_private_rent: { color: '#7c3aed', fillColor: '#c4b5fd' },
        dgi_private_no_rent: { color: '#2563eb', fillColor: '#93c5fd' },
        dgi_renovation: { color: '#0d9488', fillColor: '#5eead4' },
        renew: { color: '#b45309', fillColor: '#fbbf24' },
        oozt: { color: '#16a34a', fillColor: '#86efac' },
        rzd: { color: '#be123c', fillColor: '#fb7185' },
    };

    const LAYER_TAPE = {
        dgi_moscow_rent: {
            patternId: 'analiz-dgi-moscow-rent-tape',
            stripe: '#dc2626',
            bg: '#ffffff',
            stroke: '#dc2626',
        },
        dgi_moscow_no_rent: {
            patternId: 'analiz-dgi-moscow-no-rent-tape',
            stripe: '#ea580c',
            bg: '#ffffff',
            stroke: '#ea580c',
        },
        dgi_private_rent: {
            patternId: 'analiz-dgi-private-rent-tape',
            stripe: '#7c3aed',
            bg: '#ffffff',
            stroke: '#7c3aed',
        },
        dgi_private_no_rent: {
            patternId: 'analiz-dgi-private-no-rent-tape',
            stripe: '#2563eb',
            bg: '#ffffff',
            stroke: '#2563eb',
        },
        dgi_renovation: {
            patternId: 'analiz-dgi-renovation-tape',
            stripe: '#0d9488',
            bg: '#ffffff',
            stroke: '#0d9488',
        },
        renew: {
            patternId: 'analiz-renew-tape',
            stripe: '#f59e0b',
            bg: '#ffffff',
            stroke: '#b45309',
        },
        oozt: {
            patternId: 'analiz-oozt-tape',
            stripe: '#16a34a',
            bg: '#ffffff',
            stroke: '#16a34a',
        },
        rzd: {
            patternId: 'analiz-rzd-tape',
            stripe: '#dc2626',
            bg: '#16a34a',
            stroke: '#dc2626',
        },
    };

    const TABLE_ROWS = [
        { key: 'dgi_moscow_rent', label: 'З/У г. Москва с арендой', percentField: 'percent_moscow_rent' },
        {
            key: 'dgi_private_rent',
            label: 'З/У Частная или федеральная собственность с арендой',
            percentField: 'percent_private_rent',
        },
        {
            key: 'dgi_private_no_rent',
            label: 'З/У Частная или федеральная собственность без аренды',
            percentField: 'percent_private_no_rent',
        },
        { key: 'dgi_renovation', label: 'З/У Реновация', percentField: 'percent_dgi_renovation' },
        { key: '__sum__', label: 'Суммарное пересечение', percentField: 'percent_sum', sum: true },
        {
            key: 'dgi_moscow_no_rent',
            label: 'З/У г. Москва без аренды',
            percentField: 'percent_moscow_no_rent',
            pctAlwaysOk: true,
        },
        { key: 'renew', label: 'Реновация', percentField: 'percent_renew', pctAlwaysOk: true },
        { key: 'oozt', label: 'ООЗТ', percentField: 'percent_oozt' },
        { key: 'rzd', label: 'Полосы отвода ЖД', percentField: 'percent_rzd' },
    ];

    let map = null;
    let signalTapeRenderer = null;
    let selectedLayer = null;
    let parcelsLayer = null;
    let overlapLayer = null;
    let objectLayersById = {};

    function csrfToken() {
        if (PV.getCookie) {
            const fromCookie = PV.getCookie('csrftoken');
            if (fromCookie) {
                return fromCookie;
            }
        }
        const input = document.querySelector('input[name="csrfmiddlewaretoken"]');
        return input ? input.value : '';
    }

    function escapeHtml(value) {
        if (PV.escapeHtml) {
            return PV.escapeHtml(value);
        }
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function setStatus(text, isError) {
        if (!statusEl) {
            return;
        }
        statusEl.textContent = text || '';
        statusEl.classList.toggle('note--danger', !!isError);
    }

    function formatPct(value) {
        const n = Math.round(Number(value || 0) * 100) / 100;
        if (!Number.isFinite(n) || Object.is(n, -0) || n === 0) {
            return '0';
        }
        return String(n);
    }

    function pctClass(value, alwaysOk) {
        if (alwaysOk) {
            return 'dgi-pct--ok';
        }
        const n = Number(value || 0);
        if (n === 0) {
            return 'dgi-pct--ok';
        }
        if (n <= 10) {
            return 'dgi-pct--warn';
        }
        return 'dgi-pct--danger';
    }

    function queryParams() {
        const params = new URLSearchParams(window.location.search);
        return {
            sid: (params.get('sid') || '').trim(),
            rootid: (params.get('rootid') || '').trim(),
            requestId: (params.get('request_id') || '').trim(),
            source: (params.get('source') || '').trim(),
            name: (params.get('name') || '').trim(),
        };
    }

    async function parseJson(response) {
        if (typeof PV.parseJsonResponse === 'function') {
            return PV.parseJsonResponse(response);
        }
        return response.json();
    }

    async function fetchGeometryByIds(rootid, requestId, sourceLabel) {
        if (!detailsUrl || (!rootid && !requestId)) {
            return null;
        }
        const body = { source_label: sourceLabel || 'ДТ' };
        if (rootid) {
            body.rootid = rootid;
        } else {
            body.request_id = requestId;
        }
        const response = await fetch(detailsUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': csrfToken(),
            },
            credentials: 'same-origin',
            body: JSON.stringify(body),
        });
        const data = await parseJson(response);
        if (!response.ok || !data || !data.ok) {
            throw new Error((data && data.error) || 'Не удалось загрузить геометрию объекта.');
        }
        return data.geometry || null;
    }

    async function fetchAnalizData(geometry) {
        if (!dataUrl) {
            throw new Error('URL анализа пересечений не настроен.');
        }
        const response = await fetch(dataUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': csrfToken(),
            },
            credentials: 'same-origin',
            body: JSON.stringify({ geometry }),
        });
        const data = await parseJson(response);
        if (!response.ok || !data || !data.ok) {
            throw new Error((data && data.error) || 'Не удалось выполнить пространственный анализ.');
        }
        return data;
    }

    function layersByKey(layers) {
        const mapByKey = {};
        (layers || []).forEach((layer) => {
            if (layer && layer.key) {
                mapByKey[layer.key] = layer;
            }
        });
        return mapByKey;
    }

    function objectLabel(obj) {
        return obj.descr || obj.name || obj.address || 'Объект';
    }

    function ensureMap() {
        if (!mapEl || typeof L === 'undefined') {
            return null;
        }
        if (map) {
            return map;
        }
        map = L.map(mapEl, { maxZoom: 30, zoomControl: true }).setView([55.75, 37.61], 11);
        signalTapeRenderer = L.svg({ padding: 0.5 });
        map.createPane('overlapPane');
        map.getPane('overlapPane').style.zIndex = 650;
        if (map.attributionControl) {
            map.attributionControl.setPrefix(
                '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺',
            );
        }
        if (PV.attachBasemapControl) {
            PV.attachBasemapControl(map, {
                position: 'topright',
                scopeRoot: mapEl.parentElement,
            });
        } else if (PV.createBasemapLayers) {
            const layers = PV.createBasemapLayers();
            (layers.mggtLayer || layers.topoLayer).addTo(map);
        }
        if (PV.attachMapUtilityControls) {
            PV.attachMapUtilityControls(map);
        }
        selectedLayer = L.featureGroup().addTo(map);
        parcelsLayer = L.featureGroup().addTo(map);
        overlapLayer = L.featureGroup({ pane: 'overlapPane' }).addTo(map);
        window.addEventListener('resize', () => {
            if (map) {
                map.invalidateSize();
            }
        });
        return map;
    }

    function clearMapLayers() {
        objectLayersById = {};
        if (selectedLayer) {
            selectedLayer.clearLayers();
        }
        if (parcelsLayer) {
            parcelsLayer.clearLayers();
        }
        if (overlapLayer) {
            overlapLayer.clearLayers();
        }
    }

    function ensureSignalPattern(patternId, stripeColorHex, backgroundColorHex) {
        if (!map || !patternId) {
            return null;
        }
        const svg =
            (signalTapeRenderer &&
                signalTapeRenderer._container &&
                signalTapeRenderer._container.ownerSVGElement) ||
            (map.getPanes().overlayPane && map.getPanes().overlayPane.querySelector('svg'));
        if (!svg) {
            return null;
        }
        let defs = svg.querySelector('defs');
        if (!defs) {
            defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
            svg.insertBefore(defs, svg.firstChild);
        }
        if (!svg.querySelector('#' + patternId)) {
            const pattern = document.createElementNS('http://www.w3.org/2000/svg', 'pattern');
            pattern.setAttribute('id', patternId);
            pattern.setAttribute('patternUnits', 'userSpaceOnUse');
            pattern.setAttribute('width', '24');
            pattern.setAttribute('height', '24');
            pattern.setAttribute('patternTransform', 'rotate(45)');

            const bgRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
            bgRect.setAttribute('x', '0');
            bgRect.setAttribute('y', '0');
            bgRect.setAttribute('width', '24');
            bgRect.setAttribute('height', '24');
            bgRect.setAttribute('fill', backgroundColorHex);

            const stripeRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
            stripeRect.setAttribute('x', '0');
            stripeRect.setAttribute('y', '0');
            stripeRect.setAttribute('width', '12');
            stripeRect.setAttribute('height', '24');
            stripeRect.setAttribute('fill', stripeColorHex);

            pattern.appendChild(bgRect);
            pattern.appendChild(stripeRect);
            defs.appendChild(pattern);
        }
        return patternId;
    }

    function applySignalTape(lyr, tape) {
        if (!lyr || !tape) {
            return;
        }
        const restore = function () {
            const patternId = ensureSignalPattern(tape.patternId, tape.stripe, tape.bg);
            const el = typeof lyr.getElement === 'function' ? lyr.getElement() : null;
            if (!patternId || !el || el.classList.contains('intersecs-object-off')) {
                return;
            }
            el.setAttribute('fill', 'url(#' + patternId + ')');
            el.setAttribute('fill-opacity', '0.25');
            el.setAttribute('stroke', tape.stroke);
            el.setAttribute('stroke-width', '2');
            el.setAttribute('stroke-dasharray', '10 8');
        };
        lyr._analizRestoreTape = restore;
        lyr.on('add', restore);
        window.requestAnimationFrame(restore);
    }

    function addGeo(group, geometry, style, popupHtml, objectKey, pane, tape) {
        if (!group || !geometry) {
            return;
        }
        const options = {
            style: style,
            onEachFeature: function (_feature, lyr) {
                if (popupHtml) {
                    lyr.bindPopup(popupHtml);
                }
                if (tape) {
                    applySignalTape(lyr, tape);
                }
            },
        };
        if (pane) {
            options.pane = pane;
        }
        if (tape && signalTapeRenderer) {
            options.renderer = signalTapeRenderer;
        }
        const layer = L.geoJSON(geometry, options);
        layer.addTo(group);
        if (objectKey) {
            objectLayersById[objectKey] = objectLayersById[objectKey] || [];
            objectLayersById[objectKey].push(layer);
        }
        return layer;
    }

    function renderMap(data) {
        const leafletMap = ensureMap();
        if (!leafletMap) {
            return;
        }
        clearMapLayers();
        const selectedGeom = data.selected_geometry || null;
        addGeo(selectedLayer, selectedGeom, {
            color: '#2563eb',
            weight: 3,
            fillColor: '#60a5fa',
            fillOpacity: 0.22,
        });
        (data.layers || []).forEach((layer) => {
            const style = LAYER_STYLES[layer.key] || { color: '#64748b', fillColor: '#94a3b8' };
            const tape = LAYER_TAPE[layer.key] || null;
            (layer.objects || []).forEach((obj) => {
                const key = layer.key + ':' + obj.id;
                const popup =
                    '<div style="min-width:200px;"><div><strong>' +
                    escapeHtml(layer.label) +
                    '</strong></div><div style="margin-top:6px;">' +
                    escapeHtml(objectLabel(obj)) +
                    '</div><div style="margin-top:6px;"><strong>Пересечение:</strong> ' +
                    escapeHtml(formatPct(obj.pct)) +
                    '%</div></div>';
                addGeo(
                    parcelsLayer,
                    obj.geometry,
                    tape
                        ? {
                              color: tape.stroke,
                              weight: 4,
                              opacity: 0.95,
                              fillOpacity: 0,
                              dashArray: '10 8',
                          }
                        : {
                              color: style.color,
                              weight: 2,
                              fillColor: style.fillColor,
                              fillOpacity: 0.22,
                              dashArray: '10 8',
                          },
                    popup,
                    key,
                    undefined,
                    tape,
                );
                addGeo(
                    overlapLayer,
                    obj.intersection_geometry,
                    {
                        color: '#dc2626',
                        weight: 2,
                        fillColor: '#ef4444',
                        fillOpacity: 0.85,
                        className: 'intersecs-overlap-blink',
                    },
                    popup,
                    key,
                    'overlapPane',
                );
            });
        });
        const bounds = L.featureGroup(
            [selectedLayer, parcelsLayer, overlapLayer].filter(Boolean),
        ).getBounds();
        window.requestAnimationFrame(() => {
            leafletMap.invalidateSize();
            if (bounds.isValid()) {
                leafletMap.fitBounds(bounds, { padding: [24, 24], maxZoom: 17 });
            }
        });
        window.setTimeout(() => leafletMap.invalidateSize(), 80);
    }

    function setObjectLayersVisible(layerKey, objectId, visible) {
        const key = layerKey + ':' + objectId;
        (objectLayersById[key] || []).forEach((geojson) => {
            if (!geojson || typeof geojson.eachLayer !== 'function') {
                return;
            }
            geojson.eachLayer((lyr) => {
                const el = typeof lyr.getElement === 'function' ? lyr.getElement() : null;
                if (!visible) {
                    if (el) {
                        el.classList.add('intersecs-object-off');
                    }
                    if (typeof lyr.setStyle === 'function') {
                        lyr.setStyle({ opacity: 0, fillOpacity: 0 });
                    }
                    return;
                }
                if (el) {
                    el.classList.remove('intersecs-object-off');
                }
                if (typeof lyr._analizRestoreTape === 'function') {
                    lyr._analizRestoreTape();
                    return;
                }
                if (typeof lyr.setStyle === 'function') {
                    const isOverlap = !!(lyr.options && lyr.options.className === 'intersecs-overlap-blink');
                    lyr.setStyle({
                        opacity: 1,
                        fillOpacity: isOverlap ? 0.85 : 0.22,
                    });
                }
            });
        });
    }

    function syncLayerToggle(layerKey) {
        if (!tableWrap || !layerKey) {
            return;
        }
        const objectToggles = tableWrap.querySelectorAll(
            '.intersecs-analiz-object-toggle[data-layer-key="' + layerKey + '"]',
        );
        const checkedCount = Array.from(objectToggles).filter((cb) => cb.checked).length;
        const allOn = objectToggles.length > 0 && checkedCount === objectToggles.length;
        const noneOn = checkedCount === 0;
        tableWrap
            .querySelectorAll(
                '.intersecs-analiz-layer-toggle[data-layer-key="' +
                    layerKey +
                    '"], .intersecs-analiz-layer-all-toggle[data-layer-key="' +
                    layerKey +
                    '"]',
            )
            .forEach((cb) => {
                cb.checked = allOn;
                cb.indeterminate = !allOn && !noneOn;
            });
    }

    function applyObjectToggle(checkbox) {
        const layerKey = checkbox.getAttribute('data-layer-key');
        const objectId = checkbox.getAttribute('data-object-id');
        const visible = checkbox.checked;
        const rowEl = checkbox.closest('tr');
        if (rowEl) {
            rowEl.classList.toggle('is-off', !visible);
        }
        setObjectLayersVisible(layerKey, objectId, visible);
        syncLayerToggle(layerKey);
    }

    function setLayerObjectsVisible(layerKey, visible) {
        if (!tableWrap || !layerKey) {
            return;
        }
        tableWrap
            .querySelectorAll('.intersecs-analiz-object-toggle[data-layer-key="' + layerKey + '"]')
            .forEach((cb) => {
                cb.checked = visible;
                const rowEl = cb.closest('tr');
                if (rowEl) {
                    rowEl.classList.toggle('is-off', !visible);
                }
                setObjectLayersVisible(layerKey, cb.getAttribute('data-object-id'), visible);
            });
        syncLayerToggle(layerKey);
    }

    function focusObject(layerKey, objectId) {
        const key = layerKey + ':' + objectId;
        const layers = objectLayersById[key] || [];
        const group = L.featureGroup();
        layers.forEach((lyr) => group.addLayer(lyr));
        const bounds = group.getBounds();
        if (map && bounds.isValid()) {
            map.fitBounds(bounds, { padding: [28, 28], maxZoom: 18 });
        }
        layers.forEach((lyr) => {
            if (lyr.openPopup) {
                try {
                    lyr.openPopup();
                } catch (error) {
                    /* ignore */
                }
            }
        });
    }

    function renderTable(data) {
        if (!tableWrap) {
            return;
        }
        const byKey = layersByKey(data.layers);
        let html =
            '<table class="dgi-check-table intersecs-analiz-table">' +
            '<thead><tr><th>Слой</th><th>Пересечение</th></tr></thead><tbody>';
        TABLE_ROWS.forEach((row) => {
            const layer = byKey[row.key] || { objects: [], percent: data[row.percentField] };
            const percent = row.sum
                ? data.percent_sum
                : layer.percent != null
                    ? layer.percent
                    : data[row.percentField];
            const objects = row.sum ? [] : layer.objects || [];
            const expandable = objects.length > 0;
            const rowClass = [
                row.sum ? 'dgi-check-table__sum' : '',
                expandable ? 'intersecs-analiz-row--expandable is-open' : '',
            ]
                .filter(Boolean)
                .join(' ');
            html +=
                '<tr class="' +
                escapeHtml(rowClass) +
                '"' +
                (expandable ? ' data-layer-key="' + escapeHtml(row.key) + '"' : '') +
                '>' +
                '<td>' +
                (expandable
                    ? '<label class="intersecs-analiz-layer-label">' +
                      '<input type="checkbox" class="intersecs-analiz-layer-toggle" checked data-layer-key="' +
                      escapeHtml(row.key) +
                      '">' +
                      '<span>' +
                      escapeHtml(row.label) +
                      ' <span class="intersecs-analiz-count">(' +
                      objects.length +
                      ')</span></span></label>'
                    : escapeHtml(row.label)) +
                '</td>' +
                '<td class="dgi-pct ' +
                pctClass(percent, row.pctAlwaysOk) +
                '">' +
                escapeHtml(formatPct(percent)) +
                '%</td></tr>';
            if (expandable) {
                html +=
                    '<tr class="intersecs-analiz-detail-row" data-detail-for="' +
                    escapeHtml(row.key) +
                    '"><td colspan="2">' +
                    '<table class="intersecs-analiz-objects"><thead><tr>' +
                    '<th class="intersecs-analiz-check-col">' +
                    '<input type="checkbox" class="intersecs-analiz-layer-all-toggle" checked data-layer-key="' +
                    escapeHtml(row.key) +
                    '" title="Все объекты слоя" aria-label="Все объекты слоя">' +
                    '</th>' +
                    '<th>Кадастр / объект</th><th>Адрес</th><th>%</th><th>м²</th>' +
                    '</tr></thead><tbody>';
                objects.forEach((obj) => {
                    html +=
                        '<tr class="intersecs-analiz-object-row" data-layer-key="' +
                        escapeHtml(row.key) +
                        '" data-object-id="' +
                        escapeHtml(String(obj.id)) +
                        '">' +
                        '<td class="intersecs-analiz-check-col">' +
                        '<input type="checkbox" class="intersecs-analiz-object-toggle" checked data-layer-key="' +
                        escapeHtml(row.key) +
                        '" data-object-id="' +
                        escapeHtml(String(obj.id)) +
                        '" title="Показать на карте" aria-label="Показать на карте">' +
                        '</td>' +
                        '<td>' +
                        escapeHtml(objectLabel(obj)) +
                        '</td>' +
                        '<td>' +
                        escapeHtml(obj.address || '—') +
                        '</td>' +
                        '<td>' +
                        escapeHtml(formatPct(obj.pct)) +
                        '%</td>' +
                        '<td>' +
                        escapeHtml(String(obj.intersection_area_m2 != null ? obj.intersection_area_m2 : '—')) +
                        '</td></tr>';
                });
                html += '</tbody></table></td></tr>';
            }
        });
        html += '</tbody></table>';
        tableWrap.innerHTML = html;
        tableWrap.querySelectorAll('tr.intersecs-analiz-row--expandable').forEach((rowEl) => {
            rowEl.addEventListener('click', (event) => {
                if (event.target && event.target.closest('input, label')) {
                    return;
                }
                const key = rowEl.getAttribute('data-layer-key');
                const detail = tableWrap.querySelector('tr[data-detail-for="' + key + '"]');
                if (!detail) {
                    return;
                }
                const willHide = !detail.hidden;
                detail.hidden = willHide;
                rowEl.classList.toggle('is-open', !willHide);
            });
        });
        tableWrap.querySelectorAll('.intersecs-analiz-object-toggle').forEach((checkbox) => {
            checkbox.addEventListener('click', (event) => event.stopPropagation());
            checkbox.addEventListener('change', () => applyObjectToggle(checkbox));
        });
        tableWrap.querySelectorAll('.intersecs-analiz-layer-toggle, .intersecs-analiz-layer-all-toggle').forEach(
            (checkbox) => {
                checkbox.addEventListener('click', (event) => event.stopPropagation());
                checkbox.addEventListener('change', () => {
                    setLayerObjectsVisible(checkbox.getAttribute('data-layer-key'), checkbox.checked);
                });
            },
        );
        tableWrap.querySelectorAll('tr.intersecs-analiz-object-row').forEach((rowEl) => {
            rowEl.addEventListener('click', (event) => {
                if (event.target && event.target.closest('input')) {
                    return;
                }
                event.stopPropagation();
                focusObject(rowEl.getAttribute('data-layer-key'), rowEl.getAttribute('data-object-id'));
            });
        });
    }

    async function boot() {
        const q = queryParams();
        const stored = PV.readIntersecsAnalizPayload ? PV.readIntersecsAnalizPayload(q.sid) : null;
        const metaParts = [];
        const name = ((stored && stored.name) || q.name || '').trim();
        const rootid = (stored && stored.rootid) || q.rootid;
        const requestId = (stored && stored.request_id) || q.requestId;
        const sourceLabel = (stored && stored.source_label) || q.source;
        if (name) {
            metaParts.push('Название: ' + name);
        }
        if (rootid) {
            metaParts.push('№ паспорта: ' + rootid);
        }
        if (requestId) {
            metaParts.push('№ заявки: ' + requestId);
        }
        if (sourceLabel) {
            metaParts.push(sourceLabel);
        }
        if (metaEl) {
            metaEl.textContent = metaParts.join(' · ');
        }

        let geometry = stored && stored.geometry ? stored.geometry : null;
        try {
            if (!geometry) {
                setStatus('Загружаем геометрию объекта…');
                geometry = await fetchGeometryByIds(rootid, requestId, sourceLabel);
            }
            if (!geometry) {
                setStatus('Геометрия объекта недоступна. Откройте анализ из модалки пересечений.', true);
                return;
            }
            setStatus('Считаем пересечения по слоям…');
            const data = await fetchAnalizData(geometry);
            renderTable(data);
            renderMap(data);
            setStatus('');
        } catch (error) {
            setStatus(error.message || 'Не удалось загрузить анализ пересечений.', true);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();

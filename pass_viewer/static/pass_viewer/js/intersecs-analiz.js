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
        map = L.map(mapEl, { maxZoom: 30, preferCanvas: true }).setView([55.75, 37.61], 11);
        if (PV.attachBasemapControl) {
            PV.attachBasemapControl(map, { position: 'topright' });
        } else if (PV.createBasemapLayers) {
            const layers = PV.createBasemapLayers();
            (layers.mggtLayer || layers.topoLayer).addTo(map);
        }
        selectedLayer = L.featureGroup().addTo(map);
        parcelsLayer = L.featureGroup().addTo(map);
        overlapLayer = L.featureGroup().addTo(map);
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

    function addGeo(group, geometry, style, popupHtml, objectKey) {
        if (!group || !geometry) {
            return;
        }
        const layer = L.geoJSON(geometry, {
            style: style,
            onEachFeature: function (_feature, lyr) {
                if (popupHtml) {
                    lyr.bindPopup(popupHtml);
                }
            },
        });
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
                    {
                        color: style.color,
                        weight: 2,
                        fillColor: style.fillColor,
                        fillOpacity: 0.28,
                    },
                    popup,
                    key,
                );
                addGeo(
                    overlapLayer,
                    obj.intersection_geometry,
                    {
                        color: '#f43f5e',
                        weight: 2,
                        fillColor: '#fb7185',
                        fillOpacity: 0.55,
                    },
                    popup,
                    key,
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
                expandable ? 'intersecs-analiz-row--expandable' : '',
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
                escapeHtml(row.label) +
                (expandable ? ' <span class="intersecs-analiz-count">(' + objects.length + ')</span>' : '') +
                '</td>' +
                '<td class="dgi-pct ' +
                pctClass(percent, row.pctAlwaysOk) +
                '">' +
                escapeHtml(formatPct(percent)) +
                '%</td></tr>';
            if (expandable) {
                html +=
                    '<tr class="intersecs-analiz-detail-row" hidden data-detail-for="' +
                    escapeHtml(row.key) +
                    '"><td colspan="2">' +
                    '<table class="intersecs-analiz-objects"><thead><tr>' +
                    '<th>Кадастр / объект</th><th>Адрес</th><th>%</th><th>м²</th>' +
                    '</tr></thead><tbody>';
                objects.forEach((obj) => {
                    html +=
                        '<tr class="intersecs-analiz-object-row" data-layer-key="' +
                        escapeHtml(row.key) +
                        '" data-object-id="' +
                        escapeHtml(String(obj.id)) +
                        '">' +
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
            rowEl.addEventListener('click', () => {
                const key = rowEl.getAttribute('data-layer-key');
                const detail = tableWrap.querySelector('tr[data-detail-for="' + key + '"]');
                if (!detail) {
                    return;
                }
                const willShow = detail.hidden;
                tableWrap.querySelectorAll('tr.intersecs-analiz-detail-row').forEach((other) => {
                    other.hidden = true;
                });
                tableWrap.querySelectorAll('tr.intersecs-analiz-row--expandable').forEach((other) => {
                    other.classList.remove('is-open');
                });
                if (willShow) {
                    detail.hidden = false;
                    rowEl.classList.add('is-open');
                }
            });
        });
        tableWrap.querySelectorAll('tr.intersecs-analiz-object-row').forEach((rowEl) => {
            rowEl.addEventListener('click', (event) => {
                event.stopPropagation();
                focusObject(rowEl.getAttribute('data-layer-key'), rowEl.getAttribute('data-object-id'));
            });
        });
    }

    async function boot() {
        const q = queryParams();
        const stored = PV.readIntersecsAnalizPayload ? PV.readIntersecsAnalizPayload(q.sid) : null;
        const metaParts = [];
        const name = stored && stored.name;
        const rootid = (stored && stored.rootid) || q.rootid;
        const requestId = (stored && stored.request_id) || q.requestId;
        const sourceLabel = (stored && stored.source_label) || q.source;
        if (name) {
            metaParts.push(name);
        }
        if (rootid) {
            metaParts.push('rootid: ' + rootid);
        }
        if (requestId) {
            metaParts.push('заявка: ' + requestId);
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

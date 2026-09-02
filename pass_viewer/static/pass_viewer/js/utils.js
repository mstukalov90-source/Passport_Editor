(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    PassViewer.getPageConfig = function getPageConfig() {
        const el = document.getElementById('page-config');
        if (!el || !el.textContent) {
            return { urls: {}, features: {} };
        }
        try {
            return JSON.parse(el.textContent);
        } catch (e) {
            console.error('PassViewer: invalid page-config JSON', e);
            return { urls: {}, features: {} };
        }
    };

    PassViewer.parseJsonResponse = async function parseJsonResponse(response) {
        const text = await response.text();
        if (!text || !text.trim()) {
            throw new Error('Пустой ответ сервера (возможен таймаут прокси).');
        }
        try {
            return JSON.parse(text);
        } catch (error) {
            const trimmed = text.trimStart();
            if (trimmed.startsWith('<')) {
                throw new Error(
                    'Сервер вернул HTML вместо JSON (возможен таймаут или ошибка прокси).',
                );
            }
            throw new Error(
                'Некорректный ответ сервера. Попробуйте «Обновить смежные объекты и площадь».',
            );
        }
    };

    PassViewer.getCookie = function getCookie(name) {
        const cookieValue = document.cookie
            .split('; ')
            .find((row) => row.startsWith(name + '='));
        return cookieValue ? decodeURIComponent(cookieValue.split('=')[1]) : null;
    };

    PassViewer.parseGeometryData = function parseGeometryData(id) {
        const el = document.getElementById(id);
        if (!el) {
            return null;
        }
        const raw = JSON.parse(el.textContent);
        return raw ? JSON.parse(raw) : null;
    };

    PassViewer._hasDrawableGeometry = function _hasDrawableGeometry(geometry) {
        return Boolean(geometry && geometry.type);
    };

    // Must match geometry types returned by _simplify_geojson_for_editing (bare Polygon, etc.).
    PassViewer._GEOJSON_GEOMETRY_TYPES = new Set([
        'Point',
        'LineString',
        'Polygon',
        'MultiPoint',
        'MultiLineString',
        'MultiPolygon',
        'GeometryCollection',
    ]);

    PassViewer.normalizeGeoJson = function normalizeGeoJson(geojsonObject) {
        if (!geojsonObject) {
            return null;
        }
        if (typeof geojsonObject === 'string') {
            try {
                geojsonObject = JSON.parse(geojsonObject);
            } catch (e) {
                return null;
            }
        }
        if (geojsonObject.type === 'Feature') {
            if (!PassViewer._hasDrawableGeometry(geojsonObject.geometry)) {
                return null;
            }
            return geojsonObject;
        }
        if (geojsonObject.type === 'FeatureCollection' && Array.isArray(geojsonObject.features)) {
            const features = geojsonObject.features.filter((feature) =>
                PassViewer._hasDrawableGeometry(feature?.geometry),
            );
            if (!features.length) {
                return null;
            }
            if (features.length === geojsonObject.features.length) {
                return geojsonObject;
            }
            return { ...geojsonObject, features };
        }
        if (PassViewer._GEOJSON_GEOMETRY_TYPES.has(geojsonObject.type)) {
            return {
                type: 'FeatureCollection',
                features: [{ type: 'Feature', properties: {}, geometry: geojsonObject }],
            };
        }
        return null;
    };

    PassViewer.toEditableFeatureCollection = function toEditableFeatureCollection(geojsonObject) {
        const normalized = PassViewer.normalizeGeoJson(geojsonObject);
        if (!normalized) {
            return null;
        }
        const features = [];
        const sourceFeatures =
            normalized.type === 'Feature'
                ? [normalized]
                : Array.isArray(normalized.features)
                  ? normalized.features
                  : [];
        sourceFeatures.forEach((feature) => {
            const geometry = feature?.geometry;
            if (!geometry) {
                return;
            }
            if (geometry.type === 'Polygon') {
                features.push({
                    type: 'Feature',
                    properties: { ...(feature.properties || {}) },
                    geometry: geometry,
                });
                return;
            }
            if (geometry.type === 'MultiPolygon' && Array.isArray(geometry.coordinates)) {
                geometry.coordinates.forEach((polyCoords) => {
                    features.push({
                        type: 'Feature',
                        properties: { ...(feature.properties || {}) },
                        geometry: { type: 'Polygon', coordinates: polyCoords },
                    });
                });
            }
        });
        return { type: 'FeatureCollection', features: features };
    };

    PassViewer.mergeAdjacentDtPassportsGeoJson = function mergeAdjacentDtPassportsGeoJson(
        intersectsGeo,
        touchesGeo,
        nearbyGeo,
    ) {
        const mergedFeatures = [];
        const seenRootids = new Set();
        const appendFrom = (geojsonObject) => {
            let g = PassViewer.normalizeGeoJson(geojsonObject);
            if (!g) {
                return;
            }
            if (g.type === 'Feature') {
                g = { type: 'FeatureCollection', features: [g] };
            }
            if (g.type !== 'FeatureCollection' || !Array.isArray(g.features)) {
                return;
            }
            for (const f of g.features) {
                const reqRaw = f?.properties?.request_id;
                const reqStr = reqRaw == null ? '' : String(reqRaw).trim();
                if (reqStr) {
                    continue;
                }
                const rid = String(f?.properties?.rootid ?? '').trim();
                if (rid) {
                    if (seenRootids.has(rid)) {
                        continue;
                    }
                    seenRootids.add(rid);
                }
                mergedFeatures.push(f);
            }
        };
        appendFrom(intersectsGeo);
        appendFrom(touchesGeo);
        appendFrom(nearbyGeo);
        if (!mergedFeatures.length) {
            return null;
        }
        return { type: 'FeatureCollection', features: mergedFeatures };
    };

    PassViewer.mergeFeatureCollections = function mergeFeatureCollections(left, right) {
        const normalizedLeft = PassViewer.normalizeGeoJson(left);
        const normalizedRight = PassViewer.normalizeGeoJson(right);
        if (!normalizedLeft) {
            return normalizedRight;
        }
        if (!normalizedRight) {
            return normalizedLeft;
        }
        const leftFeatures =
            normalizedLeft.type === 'FeatureCollection'
                ? normalizedLeft.features
                : [normalizedLeft];
        const rightFeatures =
            normalizedRight.type === 'FeatureCollection'
                ? normalizedRight.features
                : [normalizedRight];
        return {
            type: 'FeatureCollection',
            features: leftFeatures.concat(rightFeatures),
        };
    };

    PassViewer.mergeMapLayerPayload = function mergeMapLayerPayload(accumulated, partial) {
        const result = { ...(accumulated || {}) };
        const source = partial || {};
        for (const [key, value] of Object.entries(source)) {
            if (!value) {
                continue;
            }
            if (key === 'request_objects' && result.request_objects) {
                result.request_objects = PassViewer.mergeFeatureCollections(
                    result.request_objects,
                    value,
                );
            } else {
                result[key] = value;
            }
        }
        return result;
    };

    PassViewer.formatAdjacentRelationsSearchStatus = function formatAdjacentRelationsSearchStatus(nearbyMeters) {
        const parsed = Number(nearbyMeters);
        const radius = Number.isFinite(parsed) && parsed > 0 ? parsed : 25;
        const radiusText = Number.isInteger(radius) ? String(radius) : String(Math.round(radius));
        return (
            'Ищем смежные паспорта ДТ (пересечение, общая граница, до ' + radiusText + ' м)...'
        );
    };

    PassViewer.filterPassportOnlyGeoJson = function filterPassportOnlyGeoJson(geojsonObject) {
        let g = PassViewer.normalizeGeoJson(geojsonObject);
        if (!g) {
            return null;
        }
        if (g.type === 'Feature') {
            g = { type: 'FeatureCollection', features: [g] };
        }
        if (g.type !== 'FeatureCollection' || !Array.isArray(g.features)) {
            return g;
        }
        const features = g.features.filter((feature) => {
            const reqRaw = feature?.properties?.request_id;
            const reqStr = reqRaw == null ? '' : String(reqRaw).trim();
            return !reqStr;
        });
        if (!features.length) {
            return null;
        }
        return { type: 'FeatureCollection', features };
    };

    PassViewer.escapeHtml = function escapeHtml(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    };

    function _dgiPctNumber(value) {
        const n = Number(value);
        return Number.isFinite(n) ? n : 0;
    }

    function _dgiFormatPct(value) {
        const n = Math.round(_dgiPctNumber(value) * 100) / 100;
        if (Object.is(n, -0) || n === 0) {
            return '0';
        }
        return String(n);
    }

    function _dgiPctClass(value) {
        const n = _dgiPctNumber(value);
        if (n === 0) {
            return 'dgi-pct--ok';
        }
        if (n <= 10) {
            return 'dgi-pct--warn';
        }
        return 'dgi-pct--danger';
    }

    function _dgiCheckRow(label, value, options) {
        const opts = options || {};
        const pct = _dgiFormatPct(value);
        const rowClass = opts.rowClass ? ` class="${opts.rowClass}"` : '';
        const colorValue = opts.colorValue != null ? opts.colorValue : value;
        const pctClass = opts.pctClass || _dgiPctClass(colorValue);
        return (
            `<tr${rowClass}>` +
            `<td>${PassViewer.escapeHtml(label)}</td>` +
            `<td class="dgi-pct ${pctClass}">${PassViewer.escapeHtml(pct)}%</td>` +
            '</tr>'
        );
    }

    PassViewer.INTERSECS_ANALIZ_STORAGE_PREFIX = 'pv-intersecs-analiz:';

    PassViewer.setCheckDgiAnalizEnabled = function setCheckDgiAnalizEnabled(btn, enabled) {
        if (!btn) {
            return;
        }
        btn.style.display = enabled ? '' : 'none';
        btn.disabled = !enabled;
    };

    PassViewer.openIntersecsAnalizPage = function openIntersecsAnalizPage(opts) {
        const options = opts || {};
        const pageUrl = String(options.pageUrl || '').trim();
        if (!pageUrl) {
            return;
        }
        const sid = (global.crypto && typeof global.crypto.randomUUID === 'function')
            ? global.crypto.randomUUID()
            : String(Date.now()) + '-' + Math.random().toString(16).slice(2);
        const payload = {
            geometry: options.geometry || null,
            percents: options.percents || null,
            rootid: String(options.rootid || '').trim(),
            request_id: String(options.request_id || '').trim(),
            source_label: String(options.source_label || '').trim(),
            name: String(options.name || '').trim(),
        };
        const key = PassViewer.INTERSECS_ANALIZ_STORAGE_PREFIX + sid;
        const meta = {
            rootid: payload.rootid,
            request_id: payload.request_id,
            source_label: payload.source_label,
            name: payload.name,
        };
        try {
            sessionStorage.setItem(key + ':meta', JSON.stringify(meta));
        } catch (error) {
            /* private mode */
        }
        try {
            localStorage.setItem(key, JSON.stringify(payload));
        } catch (error) {
            try {
                localStorage.setItem(key, JSON.stringify(Object.assign({ geometry: null, percents: null }, meta)));
            } catch (error2) {
                /* quota / private mode — страница попробует загрузить геометрию по query */
            }
        }
        const params = new URLSearchParams();
        params.set('sid', sid);
        if (payload.rootid) {
            params.set('rootid', payload.rootid);
        }
        if (payload.request_id) {
            params.set('request_id', payload.request_id);
        }
        if (payload.source_label) {
            params.set('source', payload.source_label);
        }
        if (payload.name) {
            params.set('name', payload.name);
        }
        const sep = pageUrl.indexOf('?') >= 0 ? '&' : '?';
        window.open(pageUrl + sep + params.toString(), '_blank', 'noopener,noreferrer');
    };

    PassViewer.SHOW_INTERSECS_ANALIZ_MSG = 'pv-show-intersecs-analiz';
    PassViewer.SHOW_BESKHOZ_MSG = 'pv-show-beskhoz';
    PassViewer.INTERSECS_ANALIZ_STATUS_MSG = 'pv-intersecs-analiz-status';

    PassViewer.requestIframeMapFn = function requestIframeMapFn(iframe, fnName, messageType) {
        const win = iframe && iframe.contentWindow;
        if (!win) {
            return false;
        }
        const tryCall = function tryCall() {
            try {
                if (win.PassViewer && typeof win.PassViewer[fnName] === 'function') {
                    void win.PassViewer[fnName]();
                    return true;
                }
            } catch (error) {
                /* iframe not same-origin or not ready */
            }
            return false;
        };
        if (tryCall()) {
            return true;
        }
        let attempts = 0;
        const timer = global.setInterval(function () {
            attempts += 1;
            if (tryCall() || attempts >= 25) {
                global.clearInterval(timer);
                if (attempts >= 25) {
                    try {
                        win.postMessage({ type: messageType }, '*');
                    } catch (error) {
                        /* ignore */
                    }
                }
            }
        }, 120);
        return true;
    };

    PassViewer.requestShowIntersecsAnalizOnMap = function requestShowIntersecsAnalizOnMap(iframe) {
        return PassViewer.requestIframeMapFn(
            iframe,
            'showIntersecsAnalizOnMap',
            PassViewer.SHOW_INTERSECS_ANALIZ_MSG,
        );
    };

    PassViewer.requestShowBeskhozOnMap = function requestShowBeskhozOnMap(iframe) {
        return PassViewer.requestIframeMapFn(
            iframe,
            'showBeskhozOnMap',
            PassViewer.SHOW_BESKHOZ_MSG,
        );
    };

    PassViewer.readIntersecsAnalizPayload = function readIntersecsAnalizPayload(sid) {
        const token = String(sid || '').trim();
        if (!token) {
            return null;
        }
        const key = PassViewer.INTERSECS_ANALIZ_STORAGE_PREFIX + token;
        let stored = null;
        try {
            const raw = localStorage.getItem(key);
            if (raw) {
                localStorage.removeItem(key);
                stored = JSON.parse(raw);
            }
        } catch (error) {
            stored = null;
        }
        try {
            const metaRaw = sessionStorage.getItem(key + ':meta');
            if (metaRaw) {
                sessionStorage.removeItem(key + ':meta');
                const meta = JSON.parse(metaRaw) || {};
                stored = stored && typeof stored === 'object' ? stored : {};
                if (!String(stored.name || '').trim() && meta.name) {
                    stored.name = meta.name;
                }
                if (!String(stored.rootid || '').trim() && meta.rootid) {
                    stored.rootid = meta.rootid;
                }
                if (!String(stored.request_id || '').trim() && meta.request_id) {
                    stored.request_id = meta.request_id;
                }
                if (!String(stored.source_label || '').trim() && meta.source_label) {
                    stored.source_label = meta.source_label;
                }
            }
        } catch (error) {
            /* ignore */
        }
        return stored;
    };

    PassViewer.buildCheckDgiModalHtml = function buildCheckDgiModalHtml(data) {
        const src = data || {};
        const moscowRent = _dgiPctNumber(src.percent_moscow_rent);
        const moscowNoRent = _dgiPctNumber(src.percent_moscow_no_rent);
        const privateRent = _dgiPctNumber(src.percent_private_rent);
        const privateNoRent = _dgiPctNumber(src.percent_private_no_rent);
        const dgiRenovation = _dgiPctNumber(src.percent_dgi_renovation);
        // «З/У г. Москва без аренды» не входит в сумму и не влияет на её цвет.
        const dgiSum = moscowRent + privateRent + privateNoRent + dgiRenovation;

        const rows =
            _dgiCheckRow('З/У г. Москва с арендой', moscowRent) +
            _dgiCheckRow('З/У Частная или федеральная собственность с арендой', privateRent) +
            _dgiCheckRow('З/У Частная или федеральная собственность без аренды', privateNoRent) +
            _dgiCheckRow('З/У Реновация', dgiRenovation) +
            _dgiCheckRow('Суммарное пересечение', dgiSum, {
                rowClass: 'dgi-check-table__sum',
            }) +
            _dgiCheckRow('З/У г. Москва без аренды', moscowNoRent, {
                pctClass: 'dgi-pct--ok',
            }) +
            _dgiCheckRow('Реновация', src.percent_renew, {
                pctClass: 'dgi-pct--ok',
            }) +
            _dgiCheckRow('ООЗТ', src.percent_oozt) +
            _dgiCheckRow('Полосы отвода ЖД', src.percent_rzd);

        return (
            '<table class="dgi-check-table">' +
            '<thead><tr><th>Слой</th><th>Пересечение</th></tr></thead>' +
            `<tbody>${rows}</tbody>` +
            '</table>'
        );
    };
})(typeof window !== 'undefined' ? window : global);

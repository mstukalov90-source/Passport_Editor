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
        // Жёлтый — от 1% пересечения, меньше 1% — зелёный (как на странице анализа).
        if (n < 1) {
            return 'dgi-pct--ok';
        }
        if (n <= 10) {
            return 'dgi-pct--warn';
        }
        return 'dgi-pct--danger';
    }

    function _dgiSectionRow(label) {
        return (
            '<tr class="dgi-check-table__section"><td colspan="2">' +
            PassViewer.escapeHtml(label) +
            '</td></tr>'
        );
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
        // «г. Москва без аренды» не входит в сумму и не влияет на её цвет.
        const dgiSum = moscowRent + privateRent + privateNoRent + dgiRenovation;

        // Порядок и группировка — как на странице «Пространственный анализ пересечений».
        const rows =
            _dgiSectionRow('Земельные участки ДГИ') +
            _dgiCheckRow('г. Москва с арендой', moscowRent) +
            _dgiCheckRow('Частная или федеральная собственность с арендой', privateRent) +
            _dgiCheckRow('Частная или федеральная собственность без аренды', privateNoRent) +
            _dgiCheckRow('Территория под реновацию', dgiRenovation) +
            _dgiCheckRow('Суммарное пересечение', dgiSum, {
                rowClass: 'dgi-check-table__sum',
            }) +
            _dgiSectionRow('Иные объекты') +
            _dgiCheckRow('Объекты под реновацию', src.percent_renew, {
                pctClass: 'dgi-pct--ok',
            }) +
            _dgiCheckRow('ООЗТ', src.percent_oozt) +
            _dgiCheckRow('Полосы отвода ЖД', src.percent_rzd) +
            _dgiSectionRow('Справочная информация') +
            // Справочная строка: не входит в сумму, бейдж всегда серый.
            _dgiCheckRow('г. Москва без аренды', moscowNoRent, {
                pctClass: 'dgi-pct--muted',
            });

        return (
            '<table class="dgi-check-table">' +
            '<thead><tr><th>Слой</th><th>Пересечение</th></tr></thead>' +
            `<tbody>${rows}</tbody>` +
            '</table>'
        );
    };

    PassViewer.buildCheckOgxModalHtml = function buildCheckOgxModalHtml(data) {
        const src = data || {};
        const rows =
            _dgiCheckRow('ДТ', src.percent_dt) +
            _dgiCheckRow('ОДХ', src.percent_odh) +
            _dgiCheckRow('ОО', src.percent_oo) +
            _dgiCheckRow('ТОП', src.percent_top);

        return (
            '<table class="dgi-check-table">' +
            '<thead><tr><th>Тип ОГХ</th><th>Пересечение</th></tr></thead>' +
            `<tbody>${rows}</tbody>` +
            '</table>'
        );
    };

    // Общий переключатель З/У | ОГХ для модалки check-dgi-modal на всех страницах.
    // Страница отдаёт контекст последней проверки (geometry + ids), контроллер
    // сам грузит проценты ОГХ при первом переключении и кеширует их до reset().
    PassViewer.createCheckDgiModeController = function createCheckDgiModeController(opts) {
        const options = opts || {};
        const modal = options.modal || document.getElementById('check-dgi-modal');
        const body = options.body || document.getElementById('check-dgi-modal-body');
        const toggle = options.toggle || document.getElementById('check-dgi-mode-toggle');
        const url = String(options.url || '').trim();
        const getContext = options.getContext || null;
        const getCsrfToken = options.getCsrfToken || function () { return ''; };
        if (!modal || !body || !toggle) {
            return { reset: function () {} };
        }
        let mode = 'zu';
        let ogxData = null;

        function setModeButtons(value) {
            toggle.querySelectorAll('.check-dgi-mode-toggle__btn').forEach((btn) => {
                const isActive = btn.dataset.dgiMode === value;
                btn.classList.toggle('is-active', isActive);
                btn.setAttribute('aria-pressed', isActive ? 'true' : 'false');
            });
        }

        function renderZuTable() {
            const ctx = getContext ? getContext() : null;
            const percents = ctx && ctx.percents;
            if (percents && percents.intersects && PassViewer.buildCheckDgiModalHtml) {
                body.innerHTML = PassViewer.buildCheckDgiModalHtml(percents);
            } else {
                body.textContent = 'Пересечений с объектами ДГИ и инфоресурсами не обнаружено.';
            }
        }

        function renderOgxTable() {
            if (ogxData && ogxData.intersects && PassViewer.buildCheckOgxModalHtml) {
                body.innerHTML = PassViewer.buildCheckOgxModalHtml(ogxData);
            } else {
                body.textContent = 'Пересечения с объектами ОГХ не обнаружены.';
            }
        }

        async function loadOgx() {
            const ctx = getContext ? getContext() : null;
            if (!ctx || !ctx.geometry) {
                if (mode === 'ogx') {
                    body.textContent = 'Нет данных для расчёта пересечений с ОГХ.';
                }
                return;
            }
            if (!url) {
                if (mode === 'ogx') {
                    body.textContent = 'URL проверки пересечений с ОГХ не настроен.';
                }
                return;
            }
            body.textContent = 'Проверяем пересечения с ОГХ…';
            try {
                const response = await fetch(url, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCsrfToken(),
                    },
                    credentials: 'same-origin',
                    body: JSON.stringify({
                        geometry: ctx.geometry,
                        rootid: ctx.rootid || '',
                        request_id: ctx.request_id || '',
                        source_label: ctx.source_label || '',
                    }),
                });
                const data = await PassViewer.parseJsonResponse(response);
                if (!response.ok || !data || !data.ok) {
                    throw new Error((data && data.error) || 'Ошибка проверки пересечений с ОГХ.');
                }
                ogxData = data;
                if (mode === 'ogx') {
                    renderOgxTable();
                }
            } catch (error) {
                if (mode === 'ogx') {
                    body.textContent = error.message || 'Не удалось проверить пересечения с ОГХ.';
                }
            }
        }

        function applyMode(value) {
            if (value !== 'zu' && value !== 'ogx') {
                return;
            }
            if (value === mode) {
                return;
            }
            mode = value;
            setModeButtons(mode);
            if (mode === 'zu') {
                renderZuTable();
                return;
            }
            if (ogxData) {
                renderOgxTable();
                return;
            }
            void loadOgx();
        }

        toggle.addEventListener('click', (event) => {
            const btn = event.target.closest('.check-dgi-mode-toggle__btn');
            if (!btn) {
                return;
            }
            applyMode(btn.dataset.dgiMode);
        });

        return {
            reset: function reset() {
                mode = 'zu';
                ogxData = null;
                setModeButtons('zu');
            },
        };
    };
})(typeof window !== 'undefined' ? window : global);

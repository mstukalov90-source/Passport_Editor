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
})(typeof window !== 'undefined' ? window : global);

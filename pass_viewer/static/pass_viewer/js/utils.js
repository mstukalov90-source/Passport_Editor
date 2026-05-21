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
        if (geojsonObject.type === 'FeatureCollection' || geojsonObject.type === 'Feature') {
            return geojsonObject;
        }
        return {
            type: 'FeatureCollection',
            features: [{ type: 'Feature', properties: {}, geometry: geojsonObject }],
        };
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

    PassViewer.escapeHtml = function escapeHtml(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    };
})(typeof window !== 'undefined' ? window : global);

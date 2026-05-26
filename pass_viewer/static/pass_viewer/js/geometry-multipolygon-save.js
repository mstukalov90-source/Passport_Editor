(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    const MULTIPOLYGON_SAVE_MIN_AREA_M2 = 1;
    const MULTIPOLYGON_SAVE_ERROR =
        'Для сохранения в ДТ/ОДХ нужен полигон с ненулевой площадью. ' +
        'Проверьте контур: минимум 3 различные вершины, без схлопнутых линий.';

    function countDistinctRingVertices(ring) {
        if (!Array.isArray(ring) || ring.length < 2) {
            return 0;
        }
        const key = (coord) =>
            `${Number(coord[0]).toFixed(8)},${Number(coord[1]).toFixed(8)}`;
        const seen = new Set();
        for (const coord of ring) {
            if (Array.isArray(coord) && coord.length >= 2) {
                seen.add(key(coord));
            }
        }
        return seen.size;
    }

    function requiresMultipolygonSave(sourceLabel) {
        const label = String(sourceLabel || '').trim().toUpperCase();
        return label === 'ДТ' || label === 'ОДХ';
    }

    function isMultipolygonSaveError(message) {
        const text = String(message || '').trim();
        if (!text) {
            return false;
        }
        return text === MULTIPOLYGON_SAVE_ERROR || text.indexOf('Для сохранения в ДТ/ОДХ') === 0;
    }

    function validateMultipolygonTargetGeometry(geometry, sourceLabel) {
        if (!requiresMultipolygonSave(sourceLabel)) {
            return null;
        }
        if (!geometry || typeof geometry !== 'object') {
            return MULTIPOLYGON_SAVE_ERROR;
        }
        if (geometry.type === 'GeometryCollection') {
            const geoms = geometry.geometries || [];
            if (
                !geoms.length ||
                geoms.some((g) => !g || (g.type !== 'Polygon' && g.type !== 'MultiPolygon'))
            ) {
                return MULTIPOLYGON_SAVE_ERROR;
            }
        } else if (geometry.type !== 'Polygon' && geometry.type !== 'MultiPolygon') {
            return MULTIPOLYGON_SAVE_ERROR;
        }

        const ringsToCheck = [];
        if (geometry.type === 'Polygon') {
            ringsToCheck.push(geometry.coordinates[0]);
        } else if (geometry.type === 'MultiPolygon') {
            for (const poly of geometry.coordinates || []) {
                if (poly && poly[0]) {
                    ringsToCheck.push(poly[0]);
                }
            }
        } else if (geometry.type === 'GeometryCollection') {
            for (const g of geometry.geometries || []) {
                if (g.type === 'Polygon') {
                    ringsToCheck.push(g.coordinates[0]);
                } else if (g.type === 'MultiPolygon') {
                    for (const poly of g.coordinates || []) {
                        if (poly && poly[0]) {
                            ringsToCheck.push(poly[0]);
                        }
                    }
                }
            }
        }
        if (!ringsToCheck.length || ringsToCheck.some((ring) => countDistinctRingVertices(ring) < 3)) {
            return MULTIPOLYGON_SAVE_ERROR;
        }
        const areaFn = PassViewer.calculateGeometryAreaSqMeters;
        const area = typeof areaFn === 'function' ? areaFn(geometry) : null;
        if (area === null || area < MULTIPOLYGON_SAVE_MIN_AREA_M2) {
            return MULTIPOLYGON_SAVE_ERROR;
        }
        return null;
    }

    async function repairMultipolygonGeometry(url, geometry, csrfToken) {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': csrfToken || '',
            },
            credentials: 'same-origin',
            body: JSON.stringify({ geometry }),
        });
        const data = await response.json();
        if (!response.ok || !data.ok) {
            const err = new Error(data.error || 'Не удалось исправить полигон.');
            err.issues = data.issues || [];
            err.fixable = data.fixable !== false;
            throw err;
        }
        return data;
    }

    PassViewer.multipolygonSave = {
        MULTIPOLYGON_SAVE_ERROR,
        MULTIPOLYGON_SAVE_MIN_AREA_M2,
        requiresMultipolygonSave,
        isMultipolygonSaveError,
        validateMultipolygonTargetGeometry,
        repairMultipolygonGeometry,
    };
})(typeof window !== 'undefined' ? window : global);

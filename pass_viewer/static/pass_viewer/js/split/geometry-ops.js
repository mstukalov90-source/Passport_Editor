(function (global) {
    'use strict';

    const PV = global.PassViewer;
    const Split = (global.PassViewerSplit = global.PassViewerSplit || {});

    const pointInPolygonCoords2D = PV.pointInPolygonCoords2D.bind(PV);
    const centroidPolygonLonLat = PV.centroidPolygonLonLat.bind(PV);
    const segmentsIntersect2d = PV.segmentsIntersect2d.bind(PV);
    const stripGeometryTo2D = PV.stripGeometryTo2D.bind(PV);

    function lineStringIntersectsRing2d(lineCoords, ring, eps) {
        if (!lineCoords || lineCoords.length < 2 || !ring || ring.length < 2) return false;
        const n = ring.length;
        for (let j = 0; j <= n - 2; j += 1) {
            const c = ring[j];
            const d = ring[j + 1];
            for (let i = 0; i < lineCoords.length - 1; i += 1) {
                if (segmentsIntersect2d(lineCoords[i], lineCoords[i + 1], c, d, eps)) return true;
            }
        }
        return false;
    }

    function polygonIntersectsLineString2d(polygonGeom, lineGeom) {
        if (!polygonGeom || polygonGeom.type !== 'Polygon' || !polygonGeom.coordinates?.[0]) {
            return false;
        }
        if (!lineGeom || lineGeom.type !== 'LineString' || !lineGeom.coordinates || lineGeom.coordinates.length < 2) {
            return false;
        }
        const polyCoords = polygonGeom.coordinates;
        const lineCoords = lineGeom.coordinates;
        const outer = polyCoords[0];
        const eps = 1e-10;
        if (lineStringIntersectsRing2d(lineCoords, outer, eps)) return true;
        for (let i = 0; i < lineCoords.length; i += 1) {
            if (pointInPolygonCoords2D(lineCoords[i], polyCoords)) return true;
        }
        for (let i = 0; i < lineCoords.length - 1; i += 1) {
            const a = lineCoords[i];
            const b = lineCoords[i + 1];
            const mid = [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
            if (pointInPolygonCoords2D(mid, polyCoords)) return true;
        }
        return false;
    }

    Split.lineGeometryTouchesPolygon2d = function lineGeometryTouchesPolygon2d(polygonGeom, lineGeom) {
        if (!polygonGeom || polygonGeom.type !== 'Polygon' || !lineGeom) return false;
        if (lineGeom.type === 'LineString') {
            return polygonIntersectsLineString2d(polygonGeom, lineGeom);
        }
        if (lineGeom.type === 'MultiLineString' && Array.isArray(lineGeom.coordinates)) {
            for (let k = 0; k < lineGeom.coordinates.length; k += 1) {
                const coords = lineGeom.coordinates[k];
                if (coords?.length >= 2) {
                    if (polygonIntersectsLineString2d(polygonGeom, { type: 'LineString', coordinates: coords })) {
                        return true;
                    }
                }
            }
        }
        return false;
    };

    function outerRingVertices2d(polygonGeom) {
        const ring = polygonGeom?.coordinates?.[0];
        if (!ring || ring.length < 2) return [];
        const closed =
            ring.length > 1 &&
            ring[0][0] === ring[ring.length - 1][0] &&
            ring[0][1] === ring[ring.length - 1][1];
        const lim = closed ? ring.length - 1 : ring.length;
        const out = [];
        for (let i = 0; i < lim; i += 1) out.push(ring[i]);
        return out;
    }

    function countPointsInsidePolygonCoords2d(points, polygonCoordinates) {
        let n = 0;
        for (let k = 0; k < points.length; k += 1) {
            if (pointInPolygonCoords2D(points[k], polygonCoordinates)) n += 1;
        }
        return n;
    }

    Split.findBestParentPolygonIndex = function findBestParentPolygonIndex(childGeom, parts) {
        if (!childGeom || childGeom.type !== 'Polygon' || !parts.length) return -1;
        const verts = outerRingVertices2d(childGeom);
        if (!verts.length) return -1;
        const c = centroidPolygonLonLat(childGeom);
        let minx = verts[0][0];
        let maxx = verts[0][0];
        let miny = verts[0][1];
        let maxy = verts[0][1];
        verts.forEach((v) => {
            minx = Math.min(minx, v[0]);
            maxx = Math.max(maxx, v[0]);
            miny = Math.min(miny, v[1]);
            maxy = Math.max(maxy, v[1]);
        });
        const bboxCenter = [(minx + maxx) / 2, (miny + maxy) / 2];
        let bestIdx = -1;
        let bestScore = -1;
        for (let i = 0; i < parts.length; i += 1) {
            const coords = parts[i].geometry.coordinates;
            let score = 0;
            if (c && pointInPolygonCoords2D(c, coords)) score += 1000;
            score += countPointsInsidePolygonCoords2d(verts, coords);
            if (pointInPolygonCoords2D(bboxCenter, coords)) score += 200;
            if (score > bestScore || (score === bestScore && (bestIdx < 0 || i < bestIdx))) {
                bestScore = score;
                bestIdx = i;
            }
        }
        return bestScore > 0 ? bestIdx : -1;
    };

    Split.polygonsFromGeometry2D = function polygonsFromGeometry2D(g) {
        if (!g) return [];
        if (g.type === 'Polygon') return [g];
        if (g.type === 'MultiPolygon') {
            return (g.coordinates || []).map((rings) => ({ type: 'Polygon', coordinates: rings }));
        }
        return [];
    };

    Split.mergePolygonGeometries = function mergePolygonGeometries(polygons) {
        if (!polygons.length) return null;
        if (polygons.length === 1) return polygons[0];
        return { type: 'MultiPolygon', coordinates: polygons.map((p) => p.coordinates) };
    };

    Split.buildMergedGeometryFromLayers = function buildMergedGeometryFromLayers(layers) {
        const all = [];
        for (let i = 0; i < layers.length; i += 1) {
            const layer = layers[i];
            if (typeof layer.toGeoJSON !== 'function') continue;
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            all.push(...Split.polygonsFromGeometry2D(g));
        }
        return Split.mergePolygonGeometries(all);
    };

    Split.getEditableLayers = function getEditableLayers(editableGroup) {
        return editableGroup.getLayers().filter((l) => typeof l.toGeoJSON === 'function');
    };

    Split.buildCurrentGeometry = function buildCurrentGeometry(editableGroup) {
        const layers = Split.getEditableLayers(editableGroup);
        return Split.buildMergedGeometryFromLayers(layers);
    };

    Split.classifyPartsForSelection = function classifyPartsForSelection(layers, selectionGeom, partCentroidInsideSelection) {
        let inside = 0;
        let outside = 0;
        let preservedInsideLocked = 0;
        let preservedLineCut = 0;
        let reentryInsideLocked = 0;

        layers.forEach((layer) => {
            const props = Split.getProps(layer);
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            const centroidInside = partCentroidInsideSelection(g, selectionGeom);

            if (Split.isInsideLocked(props)) {
                if (centroidInside) {
                    inside += 1;
                    reentryInsideLocked += 1;
                } else {
                    preservedInsideLocked += 1;
                }
                return;
            }
            if (Split.isLineCutPreserve(props) && !centroidInside) {
                preservedLineCut += 1;
                return;
            }
            if (centroidInside) inside += 1;
            else outside += 1;
        });

        return {
            inside,
            outside,
            preservedInsideLocked,
            preservedLineCut,
            reentryInsideLocked,
        };
    };
})(typeof window !== 'undefined' ? window : global);

(function (global) {
    'use strict';
    const PassViewer = (global.PassViewer = global.PassViewer || {});

    PassViewer.stripGeometryTo2D = function stripGeometryTo2D(geometry) {
            if (!geometry || typeof geometry !== 'object') return null;
            if (geometry.type === 'GeometryCollection') {
                return {
                    type: 'GeometryCollection',
                    geometries: (geometry.geometries || []).map(PassViewer.stripGeometryTo2D).filter(Boolean),
                };
            }
            const stripCoords = (coords) => {
                if (!Array.isArray(coords)) return coords;
                if (coords.length && typeof coords[0] === 'number') {
                    return [coords[0], coords[1]];
                }
                return coords.map(stripCoords);
            };
            return { ...geometry, coordinates: stripCoords(geometry.coordinates) };
        }

    PassViewer.pointInRing2D = function pointInRing2D(point, ring) {
            if (!ring || ring.length < 3) return false;
            const x = point[0];
            const y = point[1];
            let inside = false;
            const n = ring.length;
            const last = n - 1;
            const closed = ring[0][0] === ring[last][0] && ring[0][1] === ring[last][1];
            const max = closed ? n - 1 : n;
            for (let i = 0, j = max - 1; i < max; j = i++) {
                const xi = ring[i][0];
                const yi = ring[i][1];
                const xj = ring[j][0];
                const yj = ring[j][1];
                const intersect = (yi > y) !== (yj > y) && x < ((xj - xi) * (y - yi)) / (yj - yi + 1e-18) + xi;
                if (intersect) inside = !inside;
            }
            return inside;
        }

    PassViewer.pointInPolygonCoords2D = function pointInPolygonCoords2D(point, polygonCoordinates) {
            if (!polygonCoordinates || !polygonCoordinates.length) return false;
            if (!PassViewer.pointInRing2D(point, polygonCoordinates[0])) return false;
            for (let h = 1; h < polygonCoordinates.length; h += 1) {
                if (PassViewer.pointInRing2D(point, polygonCoordinates[h])) return false;
            }
            return true;
        }

    PassViewer.centroidPolygonLonLat = function centroidPolygonLonLat(geometry) {
            if (!geometry || geometry.type !== 'Polygon' || !geometry.coordinates || !geometry.coordinates[0]) return null;
            const ring = geometry.coordinates[0];
            let sx = 0;
            let sy = 0;
            let n = 0;
            const closed =
                ring.length > 1 &&
                ring[0][0] === ring[ring.length - 1][0] &&
                ring[0][1] === ring[ring.length - 1][1];
            const limit = closed ? ring.length - 1 : ring.length;
            for (let i = 0; i < limit; i += 1) {
                sx += ring[i][0];
                sy += ring[i][1];
                n += 1;
            }
            return n ? [sx / n, sy / n] : null;
        }

    PassViewer.partCentroidInsideSelection = function partCentroidInsideSelection(partGeometry, selectionPolygonGeometry) {
            const pt = PassViewer.centroidPolygonLonLat(partGeometry);
            if (!pt) return false;
            if (selectionPolygonGeometry.type !== 'Polygon' || !selectionPolygonGeometry.coordinates) return false;
            return PassViewer.pointInPolygonCoords2D(pt, selectionPolygonGeometry.coordinates);
        }

    PassViewer.cross2d = function cross2d(o, a, b) {
            return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
        }

    PassViewer.pointOnSegment2d = function pointOnSegment2d(p, a, b, eps) {
            const minx = Math.min(a[0], b[0]) - eps;
            const maxx = Math.max(a[0], b[0]) + eps;
            const miny = Math.min(a[1], b[1]) - eps;
            const maxy = Math.max(a[1], b[1]) + eps;
            return p[0] >= minx && p[0] <= maxx && p[1] >= miny && p[1] <= maxy && Math.abs(PassViewer.cross2d(a, b, p)) < eps;
        }

    PassViewer.segmentsIntersect2d = function segmentsIntersect2d(a, b, c, d, eps) {
            const o1 = PassViewer.cross2d(a, b, c);
            const o2 = PassViewer.cross2d(a, b, d);
            const o3 = PassViewer.cross2d(c, d, a);
            const o4 = PassViewer.cross2d(c, d, b);
            if (o1 * o2 < -eps * eps && o3 * o4 < -eps * eps) return true;
            if (Math.abs(o1) < eps && PassViewer.pointOnSegment2d(c, a, b, eps)) return true;
            if (Math.abs(o2) < eps && PassViewer.pointOnSegment2d(d, a, b, eps)) return true;
            if (Math.abs(o3) < eps && PassViewer.pointOnSegment2d(a, c, d, eps)) return true;
            if (Math.abs(o4) < eps && PassViewer.pointOnSegment2d(b, c, d, eps)) return true;
            return false;
        }

})(typeof window !== 'undefined' ? window : global);

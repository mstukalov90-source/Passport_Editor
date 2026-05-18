function getCookie(name) {
        const cookieValue = document.cookie.split('; ').find((row) => row.startsWith(name + '='));
        return cookieValue ? decodeURIComponent(cookieValue.split('=')[1]) : null;
    }

    function parseGeometryData(id) {
        const raw = JSON.parse(document.getElementById(id).textContent);
        return raw ? JSON.parse(raw) : null;
    }

    function normalizeGeoJson(geojsonObject) {
        if (!geojsonObject) return null;
        if (typeof geojsonObject === 'string') {
            try { geojsonObject = JSON.parse(geojsonObject); } catch (e) { return null; }
        }
        if (geojsonObject.type === 'FeatureCollection' || geojsonObject.type === 'Feature') return geojsonObject;
        return { type: 'FeatureCollection', features: [{ type: 'Feature', properties: {}, geometry: geojsonObject }] };
    }

    function toEditableFeatureCollection(geojsonObject) {
        const normalized = normalizeGeoJson(geojsonObject);
        if (!normalized) return null;
        const features = [];
        normalized.features.forEach((feature) => {
            const geometry = feature.geometry;
            if (!geometry) return;
            if (geometry.type === 'Polygon') {
                features.push({
                    type: 'Feature',
                    properties: { ...(feature.properties || {}) },
                    geometry: geometry
                });
            } else if (geometry.type === 'MultiPolygon') {
                (geometry.coordinates || []).forEach((polyCoords) => {
                    features.push({
                        type: 'Feature',
                        properties: { ...(feature.properties || {}) },
                        geometry: { type: 'Polygon', coordinates: polyCoords }
                    });
                });
            }
        });
        return { type: 'FeatureCollection', features: features };
    }

    function escapeHtml(value) {
        return String(value ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    const editButton = document.getElementById('edit-geometry-btn');
    const cutButton = document.getElementById('cut-polygon-btn');
    const selectByPolygonButton = document.getElementById('select-by-polygon-btn');
    const cancelButton = document.getElementById('cancel-edit-btn');
    const saveButton = document.getElementById('save-geometry-btn');
    const statusEl = document.getElementById('edit-status');
    const exportLinksEl = document.getElementById('export-links');
    if (L && L.drawLocal) {
        L.drawLocal.draw.toolbar.actions.title = 'Отменить рисование';
        L.drawLocal.draw.toolbar.actions.text = 'Отмена';
        L.drawLocal.draw.toolbar.finish.title = 'Завершить рисование';
        L.drawLocal.draw.toolbar.finish.text = 'Завершить';
        L.drawLocal.draw.toolbar.undo.title = 'Удалить последнюю точку';
        L.drawLocal.draw.toolbar.undo.text = 'Назад';
        L.drawLocal.draw.toolbar.buttons.polyline = 'Нарисовать линию';
        L.drawLocal.draw.toolbar.buttons.polygon = 'Нарисовать полигон';
        L.drawLocal.draw.handlers.polyline.tooltip.start = 'Кликните, чтобы начать линию.';
        L.drawLocal.draw.handlers.polyline.tooltip.cont = 'Кликайте, чтобы продолжить линию.';
        L.drawLocal.draw.handlers.polyline.tooltip.end = 'Кликните последнюю точку, чтобы завершить линию.';
        L.drawLocal.draw.handlers.polygon.tooltip.start = 'Кликните, чтобы начать полигон.';
        L.drawLocal.draw.handlers.polygon.tooltip.cont = 'Кликайте, чтобы продолжить полигон.';
        L.drawLocal.draw.handlers.polygon.tooltip.end = 'Кликните первую точку, чтобы замкнуть полигон.';
        L.drawLocal.edit.toolbar.actions.save.title = 'Сохранить изменения';
        L.drawLocal.edit.toolbar.actions.save.text = 'Сохранить';
        L.drawLocal.edit.toolbar.actions.cancel.title = 'Отменить редактирование, сбросить изменения';
        L.drawLocal.edit.toolbar.actions.cancel.text = 'Отмена';
        L.drawLocal.edit.toolbar.buttons.edit = 'Редактировать объекты';
        L.drawLocal.edit.toolbar.buttons.editDisabled = 'Нет объектов для редактирования';
        L.drawLocal.edit.toolbar.actions.clearAll.title = 'Удалить все объекты';
        L.drawLocal.edit.toolbar.actions.clearAll.text = 'Удалить все';
        L.drawLocal.edit.toolbar.buttons.remove = 'Удалить объекты';
        L.drawLocal.edit.toolbar.buttons.removeDisabled = 'Нет объектов для удаления';
        L.drawLocal.edit.handlers.edit.tooltip.text = 'Перетаскивайте маркеры или объекты для изменения.';
        L.drawLocal.edit.handlers.edit.tooltip.subtext = 'Нажмите "Отмена", чтобы отменить изменения.';
        L.drawLocal.edit.handlers.remove.tooltip.text = 'Кликните по объекту, чтобы удалить его.';
    }

    function stripGeometryTo2D(geometry) {
        if (!geometry || typeof geometry !== 'object') return null;
        if (geometry.type === 'GeometryCollection') {
            return {
                type: 'GeometryCollection',
                geometries: (geometry.geometries || []).map(stripGeometryTo2D).filter(Boolean),
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

    /** Ray casting: point [lng,lat] vs closed ring (first point may repeat last). */
    function pointInRing2D(point, ring) {
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

    function pointInPolygonCoords2D(point, polygonCoordinates) {
        if (!polygonCoordinates || !polygonCoordinates.length) return false;
        if (!pointInRing2D(point, polygonCoordinates[0])) return false;
        for (let h = 1; h < polygonCoordinates.length; h += 1) {
            if (pointInRing2D(point, polygonCoordinates[h])) return false;
        }
        return true;
    }

    function centroidPolygonLonLat(geometry) {
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

    function partCentroidInsideSelection(partGeometry, selectionPolygonGeometry) {
        const pt = centroidPolygonLonLat(partGeometry);
        if (!pt) return false;
        if (selectionPolygonGeometry.type !== 'Polygon' || !selectionPolygonGeometry.coordinates) return false;
        return pointInPolygonCoords2D(pt, selectionPolygonGeometry.coordinates);
    }

    function cross2d(o, a, b) {
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
    }

    function pointOnSegment2d(p, a, b, eps) {
        const minx = Math.min(a[0], b[0]) - eps;
        const maxx = Math.max(a[0], b[0]) + eps;
        const miny = Math.min(a[1], b[1]) - eps;
        const maxy = Math.max(a[1], b[1]) + eps;
        return p[0] >= minx && p[0] <= maxx && p[1] >= miny && p[1] <= maxy && Math.abs(cross2d(a, b, p)) < eps;
    }

    function segmentsIntersect2d(a, b, c, d, eps) {
        const o1 = cross2d(a, b, c);
        const o2 = cross2d(a, b, d);
        const o3 = cross2d(c, d, a);
        const o4 = cross2d(c, d, b);
        if (o1 * o2 < -eps * eps && o3 * o4 < -eps * eps) return true;
        if (Math.abs(o1) < eps && pointOnSegment2d(c, a, b, eps)) return true;
        if (Math.abs(o2) < eps && pointOnSegment2d(d, a, b, eps)) return true;
        if (Math.abs(o3) < eps && pointOnSegment2d(a, c, d, eps)) return true;
        if (Math.abs(o4) < eps && pointOnSegment2d(b, c, d, eps)) return true;
        return false;
    }

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

    /** Полигон части пересекает линию разреза (общая граница, точка линии внутри и т.п.). */
    function polygonIntersectsLineString2d(polygonGeom, lineGeom) {
        if (!polygonGeom || polygonGeom.type !== 'Polygon' || !polygonGeom.coordinates || !polygonGeom.coordinates[0]) {
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

    /** Линия (LineString или MultiLineString) имеет общие точки/пересечение с полигоном. */
    function lineGeometryTouchesPolygon2d(polygonGeom, lineGeom) {
        if (!polygonGeom || polygonGeom.type !== 'Polygon' || !lineGeom) return false;
        if (lineGeom.type === 'LineString') {
            return polygonIntersectsLineString2d(polygonGeom, lineGeom);
        }
        if (lineGeom.type === 'MultiLineString' && Array.isArray(lineGeom.coordinates)) {
            for (let k = 0; k < lineGeom.coordinates.length; k += 1) {
                const coords = lineGeom.coordinates[k];
                if (coords && coords.length >= 2) {
                    if (polygonIntersectsLineString2d(polygonGeom, { type: 'LineString', coordinates: coords })) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

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

    /**
     * Какой исходный полигон (до разреза) породил эту часть: центроид, вершины и центр bbox внутри родителя.
     * Не используем «линия ∩ новый полигон» — линия лежит на границе всех кусков после разреза.
     */
    function findBestParentPolygonIndex(childGeom, parts) {
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
    }

    const selectedName = "{{ selected_name|default:''|escapejs }}";
    const selectedRequestId = "{{ selected_request_id|default:''|escapejs }}";
    const selectedSourceLabel = "{{ selected_source_label|default:'ДТ'|escapejs }}";
    /** Часть хотя бы раз была внутри полигона выборки — № заявки и название не меняются при следующих выборках. */
    const POLYGON_SELECTION_INSIDE_LOCK = '_polygonSelectionInsideLocked';
    /** Пересечена линией разреза; после ввода заявки в модалке снимается и ставится LINE_CUT_OUTSIDE_SELECTION_PRESERVE. */
    const POLYGON_LINE_CUT_TOUCHED = '_polygonLineCutTouched';
    /** Заявка введена после разрезания линией; при выборке полигоном не менять, если центроид снаружи выделения. */
    const LINE_CUT_OUTSIDE_SELECTION_PRESERVE = '_lineCutOutsideSelectionPreserve';
    /** Последний введённый № заявки для частей «снаружи» (подставляется в следующих модалках выборки). */
    let lastPolygonSelectionOutsideRequestId = '';

    const map = L.map('map', { maxZoom: 30 }).setView([55.75, 37.61], 10);
    map.attributionControl.setPrefix(
        '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺'
    );
    const topoLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxNativeZoom: 19,
        maxZoom: 30,
        attribution: '&copy; OpenStreetMap contributors'
    });
    const satelliteLayer = L.tileLayer(
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        {
            maxNativeZoom: 19,
            maxZoom: 30,
            attribution: 'Tiles &copy; Esri'
        }
    );
    topoLayer.addTo(map);
    const basemapControl = L.control({position: 'topright'});
    basemapControl.onAdd = function () {
        const container = L.DomUtil.create('div', 'map-basemap-control');
        container.innerHTML =
            '<button type="button" class="map-basemap-btn is-active" data-map="topo">OSM</button>' +
            '<button type="button" class="map-basemap-btn" data-map="sat">Спутник</button>' +
            '<button type="button" class="map-basemap-btn" data-map="none">Без подложки</button>';
        L.DomEvent.disableClickPropagation(container);
        return container;
    };
    basemapControl.addTo(map);

    function setBasemap(mode) {
        const removeBasemapLayers = () => {
            if (map.hasLayer(topoLayer)) {
                map.removeLayer(topoLayer);
            }
            if (map.hasLayer(satelliteLayer)) {
                map.removeLayer(satelliteLayer);
            }
        };
        if (mode === 'none') {
            removeBasemapLayers();
        } else if (mode === 'topo') {
            removeBasemapLayers();
            map.addLayer(topoLayer);
        } else if (mode === 'sat') {
            removeBasemapLayers();
            map.addLayer(satelliteLayer);
        }
        document.querySelectorAll('.map-basemap-btn').forEach((btn) => {
            btn.classList.toggle('is-active', btn.dataset.map === mode);
        });
    }
    map.getContainer().querySelectorAll('.map-basemap-btn').forEach((btn) => {
        btn.addEventListener('click', () => setBasemap(btn.dataset.map));
    });

    /** Флажок на карте при рисовании (оформление как на add_object). Полигон — у первой точки; линия разреза — у последней. */
    let splitDrawFinishFlagMarker = null;

    function clearSplitDrawFinishFlag() {
        if (splitDrawFinishFlagMarker && map.hasLayer(splitDrawFinishFlagMarker)) {
            map.removeLayer(splitDrawFinishFlagMarker);
        }
        splitDrawFinishFlagMarker = null;
    }

    function getFirstVertexFromPolygonDrawer(drawer) {
        const latlngs = drawer?._poly?.getLatLngs?.();
        if (!Array.isArray(latlngs) || !latlngs.length) {
            return null;
        }
        const first = Array.isArray(latlngs[0]) ? latlngs[0][0] : latlngs[0];
        return first && Number.isFinite(first.lat) && Number.isFinite(first.lng) ? first : null;
    }

    function getLastVertexFromPolylineDrawer(drawer) {
        const latlngs = drawer?._poly?.getLatLngs?.();
        if (!Array.isArray(latlngs) || !latlngs.length) {
            return null;
        }
        const last = latlngs[latlngs.length - 1];
        return last && Number.isFinite(last.lat) && Number.isFinite(last.lng) ? last : null;
    }

    function updateSplitDrawFinishFlag() {
        if (!isEditing) {
            clearSplitDrawFinishFlag();
            return;
        }
        let anchor = null;
        if (selectionPolygonMode && selectionDrawer) {
            anchor = getFirstVertexFromPolygonDrawer(selectionDrawer);
        } else if (cutObjectMode && cutDrawer) {
            anchor = getLastVertexFromPolylineDrawer(cutDrawer);
        } else {
            clearSplitDrawFinishFlag();
            return;
        }
        if (!anchor) {
            clearSplitDrawFinishFlag();
            return;
        }
        if (!splitDrawFinishFlagMarker) {
            splitDrawFinishFlagMarker = L.marker(anchor, {
                interactive: false,
                keyboard: false,
                zIndexOffset: 2000,
                icon: L.divIcon({
                    className: '',
                    html: '<span class="start-vertex-flag" aria-hidden="true"></span>',
                    iconSize: [16, 16],
                    iconAnchor: [3, 14],
                }),
            }).addTo(map);
        } else {
            splitDrawFinishFlagMarker.setLatLng(anchor);
        }
    }

    const selectedGroup = L.featureGroup().addTo(map);
    const editableGroup = L.featureGroup().addTo(map);
    let selectedLayer = null;
    let cutDrawer = null;
    let selectionDrawer = null;
    let isEditing = false;
    let cutObjectMode = false;
    let selectionPolygonMode = false;
    let selectedEditableGeo = null;
    /** Число полигонов при входе в редактирование (из паспорта). */
    let initialEditablePolygonCount = 0;
    /** Для нескольких полигонов: после успешной выборки полигоном разрешаем разрезание линией. */
    let polygonSelectionCompletedForMulti = false;

    function setEditMode(enabled) {
        isEditing = enabled;
        if (map && map.getContainer) {
            map.getContainer().classList.toggle('edit-mode', enabled);
        }
        cancelButton.style.display = enabled ? 'inline-block' : 'none';
        saveButton.style.display = enabled ? 'inline-block' : 'none';
        editButton.textContent = enabled ? 'Режим редактирования включён' : 'Начать редактирование';
        if (!enabled) {
            cutObjectMode = false;
            cutButton.classList.remove('map-toolbar-btn--danger');
            cutButton.classList.add('map-toolbar-btn--accent');
            cancelSelectionPolygonMode();
            clearSplitDrawFinishFlag();
            selectByPolygonButton.classList.remove('map-toolbar-btn--danger');
            selectByPolygonButton.classList.add('map-toolbar-btn--teal');
            lastPolygonSelectionOutsideRequestId = '';
            exportLinksEl.innerHTML = '';
            initialEditablePolygonCount = 0;
            polygonSelectionCompletedForMulti = false;
        }
        refreshSplitToolbarButtons();
    }

    function polygonsFromGeometry2D(g) {
        if (!g) return [];
        if (g.type === 'Polygon') return [g];
        if (g.type === 'MultiPolygon') {
            return (g.coordinates || []).map((rings) => ({ type: 'Polygon', coordinates: rings }));
        }
        return [];
    }

    function mergePolygonGeometries(polygons) {
        if (!polygons.length) return null;
        if (polygons.length === 1) return polygons[0];
        return { type: 'MultiPolygon', coordinates: polygons.map((p) => p.coordinates) };
    }

    function buildMergedGeometryFromEditableLayers(layers) {
        const all = [];
        for (let i = 0; i < layers.length; i += 1) {
            const layer = layers[i];
            if (typeof layer.toGeoJSON !== 'function') continue;
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            all.push(...polygonsFromGeometry2D(g));
        }
        return mergePolygonGeometries(all);
    }

    function buildCurrentGeometry() {
        if (!isEditing) return null;
        const layers = editableGroup.getLayers().filter((l) => typeof l.toGeoJSON === 'function');
        return buildMergedGeometryFromEditableLayers(layers);
    }

    function refreshSplitToolbarButtons() {
        cutButton.removeAttribute('title');
        selectByPolygonButton.removeAttribute('title');
        if (!isEditing) {
            cutButton.disabled = true;
            selectByPolygonButton.disabled = true;
            return;
        }
        const hasGeom = !!buildCurrentGeometry();
        if (initialEditablePolygonCount <= 1) {
            selectByPolygonButton.disabled = true;
            selectByPolygonButton.title =
                'Выборка полигоном нужна только при нескольких полигонах у объекта.';
            cutButton.disabled = !hasGeom;
        } else {
            selectByPolygonButton.disabled = !hasGeom;
            const cutAllowed = hasGeom && polygonSelectionCompletedForMulti;
            cutButton.disabled = !cutAllowed;
            if (!cutAllowed && hasGeom) {
                cutButton.title =
                    'Сначала выполните выборку полигоном: назначьте заявки по полигону выделения, затем будет доступно разрезание линией.';
            }
        }
    }

    function bindPartPopup(layer) {
        const props = layer.feature?.properties || {};
        const lockedNote = props[POLYGON_SELECTION_INSIDE_LOCK]
            ? '<div style="margin-top:8px;font-size:12px;color:#0f766e;">Заявка зафиксирована после выборки «внутри» и не меняется при следующих полигонах.</div>'
            : '';
        const lineCutNote = props[LINE_CUT_OUTSIDE_SELECTION_PRESERVE]
            ? '<div style="margin-top:8px;font-size:12px;color:#92400e;">Заявка после разрезания линией не перезаписывается выборкой полигоном, если центроид снаружи выделения.</div>'
            : '';
        const html = '<div style="min-width:220px;">' +
            '<div><strong>Часть объекта</strong></div>' +
            '<div style="margin-top:6px;"><strong>№ Заявки:</strong> ' + escapeHtml(props.request_id || '-') + '</div>' +
            '<div style="margin-top:6px;"><strong>Название:</strong> ' + escapeHtml(props.name || '-') + '</div>' +
            lockedNote +
            lineCutNote +
            '</div>';
        layer.bindPopup(html);
    }

    async function requestAttributesForLayer(layer, idx, total) {
        return new Promise((resolve) => {
            const popupId = 'split-attrs-' + Date.now() + '-' + idx;
            const center = layer.getBounds().getCenter();
            const touchedLine = !!layer.feature?.properties?.[POLYGON_LINE_CUT_TOUCHED];
            const touchedHint = touchedLine
                ? '<p style="margin:0 0 8px;font-size:12px;color:#92400e;">Пересечена линией разреза — укажите заявку для этой части.</p>'
                : '';
            const popupHtml =
                '<div id="' + popupId + '" style="min-width:230px;">' +
                '<div style="font-weight:700;margin-bottom:8px;">Часть ' + idx + ' из ' + total + '</div>' +
                touchedHint +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ Заявки:</label>' +
                '<input data-field="request" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name" type="text" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<div data-error style="color:#b42318;font-size:12px;min-height:16px;"></div>' +
                '<button type="button" data-save class="map-toolbar-btn map-toolbar-btn--primary" style="width:100%;margin-top:6px;">Сохранить</button>' +
                '</div>';
            const popup = L.popup({ closeButton: false, closeOnClick: false, autoClose: false })
                .setLatLng(center)
                .setContent(popupHtml)
                .openOn(map);
            setTimeout(() => {
                const root = document.getElementById(popupId);
                if (!root) {
                    resolve(false);
                    return;
                }
                const requestInput = root.querySelector('[data-field="request"]');
                const nameInput = root.querySelector('[data-field="name"]');
                const saveBtn = root.querySelector('[data-save]');
                const errEl = root.querySelector('[data-error]');
                requestInput.value = (layer.feature?.properties?.request_id || selectedRequestId || '').trim();
                nameInput.value = (layer.feature?.properties?.name || selectedName || '').trim();
                requestInput.focus();
                saveBtn.addEventListener('click', () => {
                    const requestId = (requestInput.value || '').trim();
                    const name = (nameInput.value || '').trim();
                    if (!requestId || !/^\d+$/.test(requestId)) {
                        errEl.textContent = 'Введите request_id (только цифры).';
                        return;
                    }
                    if (!name) {
                        errEl.textContent = 'Введите название.';
                        return;
                    }
                    layer.feature = layer.feature || {
                        type: 'Feature',
                        properties: {},
                        geometry: stripGeometryTo2D(layer.toGeoJSON().geometry)
                    };
                    layer.feature.properties = layer.feature.properties || {};
                    layer.feature.properties.request_id = requestId;
                    layer.feature.properties.name = name;
                    if (layer.feature.properties[POLYGON_LINE_CUT_TOUCHED]) {
                        layer.feature.properties[LINE_CUT_OUTSIDE_SELECTION_PRESERVE] = true;
                        delete layer.feature.properties[POLYGON_LINE_CUT_TOUCHED];
                    }
                    bindPartPopup(layer);
                    map.closePopup(popup);
                    resolve(true);
                });
            }, 0);
        });
    }

    async function ensureAttributesForAllParts() {
        const layers = editableGroup.getLayers().filter((l) => typeof l.toGeoJSON === 'function');
        if (!layers.length) return false;
        for (let i = 0; i < layers.length; i += 1) {
            const layer = layers[i];
            const requestId = String(layer.feature?.properties?.request_id || '').trim();
            const name = String(layer.feature?.properties?.name || '').trim();
            if (requestId && name) continue;
            const cutTouched = !!layer.feature?.properties?.[POLYGON_LINE_CUT_TOUCHED];
            statusEl.textContent = cutTouched
                ? 'Заполните атрибуты для частей, пересечённых линией разреза (остальные уже заполнены из паспорта объекта).'
                : 'Заполните атрибуты для каждой образованной части.';
            const ok = await requestAttributesForLayer(layer, i + 1, layers.length);
            if (!ok) return false;
        }
        return true;
    }

    function applyGeometryToEditableGroup(geometry) {
        const editableGeo = toEditableFeatureCollection(geometry);
        if (!editableGeo || !editableGeo.features.length) return false;
        editableGroup.clearLayers();
        const layer = L.geoJSON(editableGeo, { style: { color: '#ef4444', weight: 3, fillOpacity: 0.25 } });
        layer.eachLayer((partLayer) => {
            partLayer.feature = partLayer.feature || {
                type: 'Feature',
                properties: {},
                geometry: stripGeometryTo2D(partLayer.toGeoJSON().geometry)
            };
            editableGroup.addLayer(partLayer);
        });
        return true;
    }

    function tagEditablePartsAfterLineCut(cutterLineGeometry, preCutParts, preTouchedParentIndices) {
        const parts = preCutParts && preCutParts.length ? preCutParts : null;
        const parentTouched = preTouchedParentIndices || new Set();
        const prPass = (selectedRequestId || '').trim();
        const nmPass = (selectedName || '').trim();
        editableGroup.eachLayer((layer) => {
            if (typeof layer.toGeoJSON !== 'function') return;
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            layer.feature = layer.feature || { type: 'Feature', properties: {}, geometry: g };
            layer.feature.properties = layer.feature.properties || {};
            const p = layer.feature.properties;
            delete p[POLYGON_LINE_CUT_TOUCHED];
            delete p[LINE_CUT_OUTSIDE_SELECTION_PRESERVE];

            if (!parts) {
                if (prPass) p.request_id = prPass;
                if (nmPass) p.name = nmPass;
                p[POLYGON_LINE_CUT_TOUCHED] = false;
                bindPartPopup(layer);
                return;
            }

            let parentIdx = findBestParentPolygonIndex(g, parts);
            if (
                parentIdx < 0 &&
                parentTouched.size === 1 &&
                lineGeometryTouchesPolygon2d(g, cutterLineGeometry)
            ) {
                parentIdx = parentTouched.values().next().value;
            }

            let touched = false;
            if (parentIdx >= 0) {
                touched = parentTouched.has(parentIdx);
                if (!touched) {
                    const src = parts[parentIdx].properties || {};
                    p.request_id = (String(src.request_id || '').trim() || prPass);
                    p.name = (String(src.name || '').trim() || nmPass);
                    if (src[POLYGON_SELECTION_INSIDE_LOCK]) {
                        p[POLYGON_SELECTION_INSIDE_LOCK] = true;
                    }
                    if (src[LINE_CUT_OUTSIDE_SELECTION_PRESERVE]) {
                        p[LINE_CUT_OUTSIDE_SELECTION_PRESERVE] = true;
                    }
                } else {
                    delete p.request_id;
                    delete p.name;
                }
            } else {
                if (prPass) p.request_id = prPass;
                if (nmPass) p.name = nmPass;
            }
            p[POLYGON_LINE_CUT_TOUCHED] = touched;
            bindPartPopup(layer);
        });
    }

    function cancelCutMode() {
        if (cutDrawer) {
            cutDrawer.disable();
            cutDrawer = null;
        }
        cutObjectMode = false;
        cutButton.textContent = 'Разрезать полигон';
        cutButton.classList.remove('map-toolbar-btn--danger');
        cutButton.classList.add('map-toolbar-btn--accent');
        clearSplitDrawFinishFlag();
    }

    function cancelSelectionPolygonMode() {
        if (selectionDrawer) {
            selectionDrawer.disable();
            selectionDrawer = null;
        }
        selectionPolygonMode = false;
        selectByPolygonButton.textContent = 'Выборка полигоном';
        selectByPolygonButton.classList.remove('map-toolbar-btn--danger');
        selectByPolygonButton.classList.add('map-toolbar-btn--teal');
        clearSplitDrawFinishFlag();
    }

    function startCutMode() {
        cancelSelectionPolygonMode();
        cancelCutMode();
        cutObjectMode = true;
        cutButton.textContent = 'Отменить разрезание';
        cutButton.classList.remove('map-toolbar-btn--accent');
        cutButton.classList.add('map-toolbar-btn--danger');
        cutDrawer = new L.Draw.Polyline(map, { shapeOptions: { color: '#ef4444', weight: 3, opacity: 0.9 } });
        statusEl.textContent = 'Нарисуйте линию для разрезания.';
        cutDrawer.enable();
    }

    function startSelectionPolygonMode() {
        cancelCutMode();
        cancelSelectionPolygonMode();
        selectionPolygonMode = true;
        selectByPolygonButton.textContent = 'Отменить выборку';
        selectByPolygonButton.classList.remove('map-toolbar-btn--teal');
        selectByPolygonButton.classList.add('map-toolbar-btn--danger');
        selectionDrawer = new L.Draw.Polygon(map, {
            shapeOptions: { color: '#0d9488', weight: 3, fillColor: '#5eead4', fillOpacity: 0.2 },
        });
        statusEl.textContent =
            'Нарисуйте полигон: незафиксированные части внутри получат заявку и будут закреплены; при следующих выборках их № заявки не изменится, даже если центроид окажется снаружи.';
        selectionDrawer.enable();
    }

    async function showDualGroupAssignmentPopup(insideCount, outsideCount) {
        return new Promise((resolve) => {
            const popupId = 'split-dual-' + Date.now();
            const center = map.getCenter();
            const popupHtml =
                '<div id="' + popupId + '" style="min-width:280px;">' +
                '<div style="font-weight:700;margin-bottom:8px;">Назначение заявок</div>' +
                '<p style="margin:0 0 10px;font-size:13px;color:#475569;">Внутри выделения: <strong>' + insideCount + '</strong> ч., снаружи: <strong>' + outsideCount + '</strong> ч.</p>' +
                '<div style="font-weight:600;margin:8px 0 4px;color:#0f766e;">Внутри полигона</div>' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ заявки:</label>' +
                '<input data-field="req-in" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:6px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name-in" type="text" style="width:100%;box-sizing:border-box;margin-bottom:10px;" />' +
                '<div style="font-weight:600;margin:8px 0 4px;color:#92400e;">Снаружи полигона</div>' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ заявки:</label>' +
                '<input data-field="req-out" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:6px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name-out" type="text" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<div data-error style="color:#b42318;font-size:12px;min-height:16px;"></div>' +
                '<button type="button" data-save class="map-toolbar-btn map-toolbar-btn--primary" style="width:100%;margin-top:6px;">Применить</button>' +
                '</div>';
            const popup = L.popup({ closeButton: true, closeOnClick: false, autoClose: false })
                .setLatLng(center)
                .setContent(popupHtml)
                .openOn(map);
            let settled = false;
            const finish = (value) => {
                if (settled) return;
                settled = true;
                resolve(value);
            };
            popup.on('remove', () => {
                finish(null);
            });
            setTimeout(() => {
                const root = document.getElementById(popupId);
                if (!root) {
                    finish(null);
                    return;
                }
                const rIn = root.querySelector('[data-field="req-in"]');
                const nIn = root.querySelector('[data-field="name-in"]');
                const rOut = root.querySelector('[data-field="req-out"]');
                const nOut = root.querySelector('[data-field="name-out"]');
                const errEl = root.querySelector('[data-error]');
                const saveBtn = root.querySelector('[data-save]');
                const defaultOutsideRequestId = (lastPolygonSelectionOutsideRequestId || selectedRequestId || '').trim();
                rIn.value = (selectedRequestId || '').trim();
                nIn.value = (selectedName || '').trim();
                rOut.value = defaultOutsideRequestId;
                nOut.value = (selectedName || '').trim() ? (selectedName || '').trim() + ' (вне выделения)' : '';
                rIn.focus();
                saveBtn.addEventListener('click', () => {
                    const ri = (rIn.value || '').trim();
                    const ni = (nIn.value || '').trim();
                    const ro = (rOut.value || '').trim();
                    const no = (nOut.value || '').trim();
                    if (!ri || !/^\d+$/.test(ri)) {
                        errEl.textContent = 'Внутри: укажите № заявки (только цифры).';
                        return;
                    }
                    if (!ni) {
                        errEl.textContent = 'Внутри: введите название.';
                        return;
                    }
                    if (!ro || !/^\d+$/.test(ro)) {
                        errEl.textContent = 'Снаружи: укажите № заявки (только цифры).';
                        return;
                    }
                    if (!no) {
                        errEl.textContent = 'Снаружи: введите название.';
                        return;
                    }
                    if (ri === ro) {
                        errEl.textContent = 'Номера заявок внутри и снаружи должны различаться.';
                        return;
                    }
                    finish({ inside: { request_id: ri, name: ni }, outside: { request_id: ro, name: no } });
                    map.closePopup(popup);
                });
            }, 0);
        });
    }

    function isPolygonSelectionInsideLocked(props) {
        return !!(props && props[POLYGON_SELECTION_INSIDE_LOCK]);
    }

    function isLineCutOutsideSelectionPreserved(props) {
        return !!(props && props[LINE_CUT_OUTSIDE_SELECTION_PRESERVE]);
    }

    async function showOutsideOnlyAssignmentPopup(outsideCount, skippedPreservedCount) {
        return new Promise((resolve) => {
            const popupId = 'split-out-only-' + Date.now();
            const center = map.getCenter();
            const popupHtml =
                '<div id="' + popupId + '" style="min-width:280px;">' +
                '<div style="font-weight:700;margin-bottom:8px;">Назначение заявки (снаружи)</div>' +
                '<p style="margin:0 0 10px;font-size:13px;color:#475569;">Новых незафиксированных частей внутри выделения нет. ' +
                'Снаружи для назначения: <strong>' + outsideCount + '</strong> ч.; без изменений ' +
                '(выборка «внутри» или заявка после линии вне выделения): <strong>' + skippedPreservedCount + '</strong> ч.</p>' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ заявки:</label>' +
                '<input data-field="req-out" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:6px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name-out" type="text" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<div data-error style="color:#b42318;font-size:12px;min-height:16px;"></div>' +
                '<button type="button" data-save class="map-toolbar-btn map-toolbar-btn--primary" style="width:100%;margin-top:6px;">Применить</button>' +
                '</div>';
            const popup = L.popup({ closeButton: true, closeOnClick: false, autoClose: false })
                .setLatLng(center)
                .setContent(popupHtml)
                .openOn(map);
            let settled = false;
            const finish = (value) => {
                if (settled) return;
                settled = true;
                resolve(value);
            };
            popup.on('remove', () => {
                finish(null);
            });
            setTimeout(() => {
                const root = document.getElementById(popupId);
                if (!root) {
                    finish(null);
                    return;
                }
                const rOut = root.querySelector('[data-field="req-out"]');
                const nOut = root.querySelector('[data-field="name-out"]');
                const errEl = root.querySelector('[data-error]');
                const saveBtn = root.querySelector('[data-save]');
                rOut.value = (lastPolygonSelectionOutsideRequestId || selectedRequestId || '').trim();
                nOut.value = (selectedName || '').trim();
                rOut.focus();
                saveBtn.addEventListener('click', () => {
                    const ro = (rOut.value || '').trim();
                    const no = (nOut.value || '').trim();
                    if (!ro || !/^\d+$/.test(ro)) {
                        errEl.textContent = 'Укажите № заявки (только цифры).';
                        return;
                    }
                    if (!no) {
                        errEl.textContent = 'Введите название.';
                        return;
                    }
                    finish({ request_id: ro, name: no });
                    map.closePopup(popup);
                });
            }, 0);
        });
    }

    async function applySelectionPolygonFromDrawLayer(drawnLayer) {
        const selectionGeom = stripGeometryTo2D(drawnLayer?.toGeoJSON?.()?.geometry);
        if (!selectionGeom || selectionGeom.type !== 'Polygon') {
            statusEl.textContent = 'Ожидался полигон выделения.';
            return;
        }
        if (map.hasLayer(drawnLayer)) {
            map.removeLayer(drawnLayer);
        }
        const layers = editableGroup.getLayers().filter((l) => typeof l.toGeoJSON === 'function');
        if (!layers.length) {
            statusEl.textContent = 'Нет частей для классификации.';
            return;
        }
        let inside = 0;
        let outside = 0;
        let insideSelectionLockedCount = 0;
        let lineCutOutsideFrozenCount = 0;
        layers.forEach((layer) => {
            const props = layer.feature?.properties || {};
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            const centroidInside = partCentroidInsideSelection(g, selectionGeom);
            if (isPolygonSelectionInsideLocked(props)) {
                insideSelectionLockedCount += 1;
                return;
            }
            if (isLineCutOutsideSelectionPreserved(props) && !centroidInside) {
                lineCutOutsideFrozenCount += 1;
                return;
            }
            if (centroidInside) inside += 1;
            else outside += 1;
        });
        const dualPossible = inside > 0 && outside > 0;
        const outsideOnlyPossible =
            inside === 0 &&
            outside > 0 &&
            (insideSelectionLockedCount > 0 || lineCutOutsideFrozenCount > 0);
        if (!dualPossible && !outsideOnlyPossible) {
            if (layers.length && inside === 0 && outside === 0) {
                statusEl.textContent =
                    'Нет частей для назначения по этому полигону: все незафиксированные отнесены к сохранённым ' +
                    '(внутри выборки или заявка после разрезания линией вне выделения).';
                return;
            }
            if (insideSelectionLockedCount === layers.length) {
                statusEl.textContent = 'Все части уже зафиксированы после выборки «внутри»; переназначение этим полигоном не требуется.';
                return;
            }
            statusEl.textContent =
                'Среди незафиксированных частей все оказались только ' +
                (!inside ? 'снаружи' : 'внутри') +
                ' выделения. Нарисуйте другой полигон или используйте разрезание линией.';
            return;
        }
        let insidePack = null;
        let outsidePack = null;
        if (dualPossible) {
            const assignment = await showDualGroupAssignmentPopup(inside, outside);
            if (!assignment) {
                statusEl.textContent = 'Назначение заявок отменено.';
                return;
            }
            insidePack = assignment.inside;
            outsidePack = assignment.outside;
        } else {
            const outOnly = await showOutsideOnlyAssignmentPopup(
                outside,
                insideSelectionLockedCount + lineCutOutsideFrozenCount
            );
            if (!outOnly) {
                statusEl.textContent = 'Назначение заявок отменено.';
                return;
            }
            outsidePack = outOnly;
        }
        layers.forEach((layer) => {
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            layer.feature = layer.feature || {
                type: 'Feature',
                properties: {},
                geometry: g,
            };
            layer.feature.properties = layer.feature.properties || {};
            const p = layer.feature.properties;
            const centroidInside = partCentroidInsideSelection(g, selectionGeom);
            if (isPolygonSelectionInsideLocked(p)) {
                bindPartPopup(layer);
                return;
            }
            if (isLineCutOutsideSelectionPreserved(p) && !centroidInside) {
                bindPartPopup(layer);
                return;
            }
            if (centroidInside) {
                p.request_id = insidePack.request_id;
                p.name = insidePack.name;
                p[POLYGON_SELECTION_INSIDE_LOCK] = true;
                delete p[LINE_CUT_OUTSIDE_SELECTION_PRESERVE];
            } else {
                p.request_id = outsidePack.request_id;
                p.name = outsidePack.name;
            }
            bindPartPopup(layer);
        });
        const outReq = String(outsidePack.request_id || '').trim();
        if (outReq) {
            lastPolygonSelectionOutsideRequestId = outReq;
        }
        if (dualPossible) {
            let tail = '';
            if (insideSelectionLockedCount) tail += ' ' + insideSelectionLockedCount + ' ч. с заявкой «внутри» без изменений.';
            if (lineCutOutsideFrozenCount) tail += ' ' + lineCutOutsideFrozenCount + ' ч. с заявкой после линии (снаружи выделения) без изменений.';
            statusEl.textContent =
                'Готово: ' + inside + ' ч. внутри выделения → заявка ' + insidePack.request_id +
                ', ' + outside + ' снаружи → заявка ' + outsidePack.request_id + '.' + tail;
        } else {
            statusEl.textContent =
                'Готово: ' + outside + ' незафиксированных ч. снаружи → заявка ' + outsidePack.request_id +
                '; ' + insideSelectionLockedCount + ' ч. с заявкой после выборки «внутри»' +
                (lineCutOutsideFrozenCount ? '; ' + lineCutOutsideFrozenCount + ' ч. с заявкой после линии (вне выделения) без изменений' : '') +
                '.';
        }
        if (initialEditablePolygonCount > 1) {
            polygonSelectionCompletedForMulti = true;
            refreshSplitToolbarButtons();
        }
    }

    async function applyCutGeometry(cutterLayer, cutterType) {
        if (initialEditablePolygonCount > 1 && !polygonSelectionCompletedForMulti) {
            statusEl.textContent =
                'Сначала выполните выборку полигоном: разрезание линией после неё станет доступно.';
            if (cutterLayer && map.hasLayer(cutterLayer)) {
                map.removeLayer(cutterLayer);
            }
            return;
        }
        const geometry = stripGeometryTo2D(buildCurrentGeometry());
        const cutterGeometry = stripGeometryTo2D(cutterLayer?.toGeoJSON?.()?.geometry);
        if (!geometry || !cutterGeometry) {
            statusEl.textContent = 'Не удалось выполнить разрезание: нет геометрии.';
            return;
        }
        statusEl.textContent = 'Выполняем разрезание полигона...';
        try {
            const preFc = editableGroup.toGeoJSON();
            const preCutParts = (preFc.features || [])
                .map((f) => ({
                    geometry: stripGeometryTo2D(f.geometry),
                    properties: { ...(f.properties || {}) },
                }))
                .filter((x) => x.geometry && x.geometry.type === 'Polygon');

            const preTouchedParentIndices = new Set();
            preCutParts.forEach((part, idx) => {
                if (lineGeometryTouchesPolygon2d(part.geometry, cutterGeometry)) {
                    preTouchedParentIndices.add(idx);
                }
            });

            const response = await fetch("{% url 'cut_edited_geometry' %}", {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-CSRFToken': getCookie('csrftoken') || '' },
                body: JSON.stringify({ geometry: geometry, cutter_geometry: cutterGeometry, cutter_type: cutterType })
            });
            const data = await response.json();
            if (!response.ok || !data.ok) throw new Error(data.error || 'Не удалось разрезать полигон.');
            if (!data.geometry) throw new Error('После разрезания геометрия не содержит площади.');
            if (!applyGeometryToEditableGroup(data.geometry)) throw new Error('Не удалось применить результат разрезания.');
            if (map.hasLayer(cutterLayer)) {
                map.removeLayer(cutterLayer);
            }
            tagEditablePartsAfterLineCut(cutterGeometry, preCutParts, preTouchedParentIndices);
            const attrsOk = await ensureAttributesForAllParts();
            if (!attrsOk) throw new Error('Не удалось заполнить атрибуты частей.');
            statusEl.textContent =
                'Разрезание выполнено. У частей вдоль линии заявки введены вручную и сохраняются при выборке полигоном «снаружи»; у остальных — из паспорта объекта.';
        } catch (error) {
            statusEl.textContent = error.message || 'Не удалось разрезать полигон.';
        }
    }

    async function exportAllParts() {
        if (!isEditing) {
            statusEl.textContent = 'Сначала включите режим редактирования.';
            return;
        }
        const layers = editableGroup.getLayers().filter((l) => typeof l.toGeoJSON === 'function');
        if (!layers.length) {
            statusEl.textContent = 'Нет геометрии для выгрузки.';
            return;
        }
        const attrsOk = await ensureAttributesForAllParts();
        if (!attrsOk) return;
        const layersAfterAttrs = editableGroup.getLayers().filter((l) => typeof l.toGeoJSON === 'function');
        if (!layersAfterAttrs.length) {
            statusEl.textContent = 'Нет геометрии для выгрузки.';
            return;
        }
        const byRequestId = new Map();
        for (let i = 0; i < layersAfterAttrs.length; i += 1) {
            const layer = layersAfterAttrs[i];
            const rid = String(layer.feature?.properties?.request_id || '').trim();
            if (!byRequestId.has(rid)) byRequestId.set(rid, []);
            byRequestId.get(rid).push(layer);
        }
        for (const [rid, groupLayers] of byRequestId) {
            const names = new Set(
                groupLayers.map((l) => String(l.feature?.properties?.name || '').trim()).filter(Boolean)
            );
            if (names.size > 1) {
                statusEl.textContent =
                    'У частей с номером заявки ' +
                    escapeHtml(rid) +
                    ' указаны разные названия. Укажите одно название на заявку или разные номера заявок.';
                return;
            }
        }
        const requestIdsSorted = Array.from(byRequestId.keys()).sort((a, b) => {
            const na = parseInt(a, 10);
            const nb = parseInt(b, 10);
            const aNum = !Number.isNaN(na) && String(na) === a;
            const bNum = !Number.isNaN(nb) && String(nb) === b;
            if (aNum && bNum) return na - nb;
            return a.localeCompare(b, undefined, { numeric: true });
        });
        saveButton.disabled = true;
        statusEl.textContent = 'Сохраняем части в базе и формируем файлы...';
        const links = [];
        try {
            for (let g = 0; g < requestIdsSorted.length; g += 1) {
                const rid = requestIdsSorted[g];
                const groupLayers = byRequestId.get(rid);
                const geometry = buildMergedGeometryFromEditableLayers(groupLayers);
                if (!geometry) {
                    throw new Error('Нет полигонов для заявки ' + rid + '.');
                }
                const props = groupLayers[0].feature?.properties || {};
                const saveResponse = await fetch("{% url 'save_new_object' %}", {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'X-CSRFToken': getCookie('csrftoken') || '' },
                    body: JSON.stringify({
                        geometry: geometry,
                        name: props.name,
                        request_id: props.request_id,
                        source_label: selectedSourceLabel
                    })
                });
                const saveResult = await saveResponse.json();
                if (!saveResponse.ok || !saveResult.ok) {
                    throw new Error(
                        saveResult.error ||
                            ('Ошибка сохранения в базе (заявка ' + rid + ', ' + groupLayers.length + ' ч.).')
                    );
                }
                const response = await fetch("{% url 'export_new_object_geometry' %}", {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'X-CSRFToken': getCookie('csrftoken') || '' },
                    body: JSON.stringify({
                        geometry: geometry,
                        properties: {
                            request_id: props.request_id,
                            name: props.name,
                            OwnerLegalPersonId: saveResult.owner_id
                        }
                    })
                });
                const result = await response.json();
                if (!response.ok || !result.ok) {
                    throw new Error(result.error || ('Ошибка выгрузки (заявка ' + rid + ').'));
                }
                links.push({
                    partCount: groupLayers.length,
                    name: props.name,
                    requestId: props.request_id,
                    geojson: result.geojson_url,
                    shp: result.shapefile_url
                });
            }
            exportLinksEl.innerHTML = links.map((item) =>
                '<div style="margin:6px 0;">' +
                '<strong>Заявка ' +
                escapeHtml(String(item.requestId)) +
                '</strong>' +
                (item.partCount > 1 ? ' (' + item.partCount + ' полигонов)' : '') +
                ', название: ' +
                escapeHtml(item.name) +
                ' — ' +
                '<a class="button-link" href="' + item.geojson + '" download>GeoJSON</a> ' +
                '<a class="button-link" href="' + item.shp + '">SHP (ZIP)</a>' +
                '</div>'
            ).join('');
            statusEl.textContent =
                'Сохранено и выгружено записей по заявкам: ' +
                links.length +
                ' (полигонов на карте было ' +
                layersAfterAttrs.length +
                ').';
        } catch (error) {
            statusEl.textContent = error.message || 'Не удалось сохранить и выгрузить части.';
        } finally {
            saveButton.disabled = false;
        }
    }

    const selectedGeometry = stripGeometryTo2D(parseGeometryData('selected-geometry-data'));
    const selectedGeometryForEditing = stripGeometryTo2D(parseGeometryData('selected-geometry-for-editing-data')) || selectedGeometry;
    const selectedGeo = normalizeGeoJson(selectedGeometryForEditing);
    selectedEditableGeo = toEditableFeatureCollection(selectedGeo);
    if (selectedGeo) {
        selectedLayer = L.geoJSON(selectedGeo, { style: { color: '#ef4444', weight: 3, fillOpacity: 0.25 } }).addTo(selectedGroup);
        map.fitBounds(selectedLayer.getBounds(), { padding: [30, 30], maxZoom: 30 });
    } else {
        statusEl.textContent = 'Выбранный объект не удалось отрисовать на карте.';
    }

    editButton.addEventListener('click', () => {
        if (!selectedEditableGeo || !selectedEditableGeo.features.length) {
            statusEl.textContent = 'Для этого типа геометрии редактирование не поддержано.';
            return;
        }
        if (isEditing) return;
        editableGroup.clearLayers();
        const editableLayer = L.geoJSON(selectedEditableGeo, { style: { color: '#ef4444', weight: 3, fillOpacity: 0.25 } });
        editableLayer.eachLayer((layer) => {
            layer.feature = layer.feature || {
                type: 'Feature',
                properties: {},
                geometry: stripGeometryTo2D(layer.toGeoJSON().geometry)
            };
            layer.feature.properties = layer.feature.properties || {};
            editableGroup.addLayer(layer);
        });
        if (selectedLayer && map.hasLayer(selectedLayer)) map.removeLayer(selectedLayer);
        initialEditablePolygonCount = (selectedEditableGeo.features || []).filter(
            (f) => f.geometry && f.geometry.type === 'Polygon'
        ).length;
        polygonSelectionCompletedForMulti = false;
        setEditMode(true);
        statusEl.textContent =
            initialEditablePolygonCount > 1
                ? 'Режим редактирования включён. Сначала выполните выборку полигоном — затем станет доступно разрезание линией.'
                : 'Режим редактирования включён.';
    });

    cutButton.addEventListener('click', () => {
        if (!isEditing) {
            statusEl.textContent = 'Сначала включите режим редактирования.';
            return;
        }
        if (initialEditablePolygonCount > 1 && !polygonSelectionCompletedForMulti) {
            statusEl.textContent =
                'Сначала выполните выборку полигоном: назначьте заявки по полигону выделения, затем станет доступно разрезание линией.';
            return;
        }
        if (!buildCurrentGeometry()) {
            statusEl.textContent = 'Нет редактируемой геометрии для разрезания.';
            return;
        }
        if (cutObjectMode) {
            cancelCutMode();
            statusEl.textContent = 'Разрезание отменено.';
            return;
        }
        startCutMode();
    });

    selectByPolygonButton.addEventListener('click', () => {
        if (!isEditing) {
            statusEl.textContent = 'Сначала включите режим редактирования.';
            return;
        }
        if (initialEditablePolygonCount <= 1) {
            statusEl.textContent = 'Выборка полигоном доступна только если у объекта несколько полигонов.';
            return;
        }
        if (!buildCurrentGeometry()) {
            statusEl.textContent = 'Нет редактируемой геометрии для выборки.';
            return;
        }
        if (selectionPolygonMode) {
            cancelSelectionPolygonMode();
            statusEl.textContent = 'Выборка полигоном отменена.';
            return;
        }
        startSelectionPolygonMode();
    });

    map.on(L.Draw.Event.CREATED, (event) => {
        if (selectionPolygonMode) {
            cancelSelectionPolygonMode();
            void applySelectionPolygonFromDrawLayer(event.layer);
            return;
        }
        if (!cutObjectMode) return;
        const cutterType = 'line';
        cancelCutMode();
        void applyCutGeometry(event.layer, cutterType);
    });

    map.on(L.Draw.Event.DRAWVERTEX, () => {
        updateSplitDrawFinishFlag();
    });
    map.on('draw:drawstart', () => {
        clearSplitDrawFinishFlag();
    });
    map.on('draw:drawstop', () => {
        clearSplitDrawFinishFlag();
    });

    cancelButton.addEventListener('click', () => {
        cancelCutMode();
        cancelSelectionPolygonMode();
        editableGroup.clearLayers();
        if (selectedLayer && !map.hasLayer(selectedLayer)) map.addLayer(selectedLayer);
        setEditMode(false);
        statusEl.textContent = 'Изменения отменены.';
    });

    saveButton.addEventListener('click', () => { void exportAllParts(); });

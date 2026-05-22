(function (global) {
    'use strict';

    const PV = global.PassViewer;
    const Split = global.PassViewerSplit;

    const parseGeometryData = PV.parseGeometryData.bind(PV);
    const normalizeGeoJson = PV.normalizeGeoJson.bind(PV);
    const toEditableFeatureCollection = PV.toEditableFeatureCollection.bind(PV);
    const stripGeometryTo2D = PV.stripGeometryTo2D.bind(PV);

    Split.createMapController = function createMapController(cfg, dom) {
        const state = Split.createSplitState(cfg);

        const map = L.map(dom.mapEl, { maxZoom: 30 }).setView([55.75, 37.61], 10);
        map.attributionControl.setPrefix(
            '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺'
        );

        PV.attachBasemapControl(map);
        map.invalidateSize();

        const selectedGroup = L.featureGroup().addTo(map);
        const editableGroup = L.featureGroup().addTo(map);
        let selectedLayer = null;
        let cutDrawer = null;
        let selectionDrawer = null;
        let splitDrawFinishFlagMarker = null;

        const ctx = {
            state,
            map,
            editableGroup,
            selectedGroup,
            statusEl: dom.statusEl,
            exportLinksEl: dom.exportLinksEl,
            editButton: dom.editButton,
            cutButton: dom.cutButton,
            selectByPolygonButton: dom.selectByPolygonButton,
            cancelButton: dom.cancelButton,
            saveButton: dom.saveButton,
            refreshToolbar: null,
        };

        function clearSplitDrawFinishFlag() {
            if (splitDrawFinishFlagMarker && map.hasLayer(splitDrawFinishFlagMarker)) {
                map.removeLayer(splitDrawFinishFlagMarker);
            }
            splitDrawFinishFlagMarker = null;
        }

        function getFirstVertexFromPolygonDrawer(drawer) {
            const latlngs = drawer?._poly?.getLatLngs?.();
            if (!Array.isArray(latlngs) || !latlngs.length) return null;
            const first = Array.isArray(latlngs[0]) ? latlngs[0][0] : latlngs[0];
            return first && Number.isFinite(first.lat) && Number.isFinite(first.lng) ? first : null;
        }

        function getLastVertexFromPolylineDrawer(drawer) {
            const latlngs = drawer?._poly?.getLatLngs?.();
            if (!Array.isArray(latlngs) || !latlngs.length) return null;
            const last = latlngs[latlngs.length - 1];
            return last && Number.isFinite(last.lat) && Number.isFinite(last.lng) ? last : null;
        }

        function updateSplitDrawFinishFlag() {
            if (!state.isEditing) {
                clearSplitDrawFinishFlag();
                return;
            }
            let anchor = null;
            if (state.selectionPolygonMode && selectionDrawer) {
                anchor = getFirstVertexFromPolygonDrawer(selectionDrawer);
            } else if (state.cutObjectMode && cutDrawer) {
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

        function cancelCutMode() {
            if (cutDrawer) {
                cutDrawer.disable();
                cutDrawer = null;
            }
            state.cutObjectMode = false;
            dom.cutButton.textContent = 'Разрезать полигон';
            dom.cutButton.classList.remove('map-toolbar-btn--danger');
            dom.cutButton.classList.add('map-toolbar-btn--accent');
            clearSplitDrawFinishFlag();
        }

        function cancelSelectionPolygonMode() {
            if (selectionDrawer) {
                selectionDrawer.disable();
                selectionDrawer = null;
            }
            state.selectionPolygonMode = false;
            dom.selectByPolygonButton.textContent = 'Выборка полигоном';
            dom.selectByPolygonButton.classList.remove('map-toolbar-btn--danger');
            dom.selectByPolygonButton.classList.add('map-toolbar-btn--teal');
            clearSplitDrawFinishFlag();
        }

        function refreshToolbar() {
            dom.cutButton.removeAttribute('title');
            dom.selectByPolygonButton.removeAttribute('title');
            if (!state.isEditing) {
                dom.cutButton.disabled = true;
                dom.selectByPolygonButton.disabled = true;
                return;
            }
            const hasGeom = !!Split.buildCurrentGeometry(editableGroup);
            if (state.objectMode() === 'single') {
                dom.selectByPolygonButton.disabled = true;
                dom.selectByPolygonButton.title =
                    'Выборка полигоном нужна только при нескольких полигонах у объекта.';
                dom.cutButton.disabled = !hasGeom;
            } else {
                dom.selectByPolygonButton.disabled = !hasGeom;
                const cutAllowed = hasGeom && state.polygonSelectionDone;
                dom.cutButton.disabled = !cutAllowed;
                if (!cutAllowed && hasGeom) {
                    dom.cutButton.title =
                        'Сначала выполните выборку полигоном: назначьте заявки, затем будет доступно разрезание линией.';
                }
            }
        }
        ctx.refreshToolbar = refreshToolbar;

        function setEditMode(enabled) {
            state.isEditing = enabled;
            map.getContainer().classList.toggle('edit-mode', enabled);
            dom.cancelButton.style.display = enabled ? 'inline-block' : 'none';
            dom.saveButton.style.display = enabled ? 'inline-block' : 'none';
            dom.editButton.textContent = enabled ? 'Режим редактирования включён' : 'Начать редактирование';
            if (!enabled) {
                cancelCutMode();
                cancelSelectionPolygonMode();
                clearSplitDrawFinishFlag();
                state.lastOutsideRequestId = '';
                dom.exportLinksEl.innerHTML = '';
                state.setModeFromPolygonCount(0);
                state.resetPartIdCounter();
            }
            refreshToolbar();
        }

        function startCutMode() {
            cancelSelectionPolygonMode();
            cancelCutMode();
            state.cutObjectMode = true;
            dom.cutButton.textContent = 'Отменить разрезание';
            dom.cutButton.classList.remove('map-toolbar-btn--accent');
            dom.cutButton.classList.add('map-toolbar-btn--danger');
            cutDrawer = new L.Draw.Polyline(map, {
                shapeOptions: { color: '#ef4444', weight: 3, opacity: 0.9 },
            });
            dom.statusEl.textContent = 'Нарисуйте линию для разрезания.';
            cutDrawer.enable();
        }

        function startSelectionPolygonMode() {
            cancelCutMode();
            cancelSelectionPolygonMode();
            state.selectionPolygonMode = true;
            dom.selectByPolygonButton.textContent = 'Отменить выборку';
            dom.selectByPolygonButton.classList.remove('map-toolbar-btn--teal');
            dom.selectByPolygonButton.classList.add('map-toolbar-btn--danger');
            selectionDrawer = new L.Draw.Polygon(map, {
                shapeOptions: { color: '#0d9488', weight: 3, fillColor: '#5eead4', fillOpacity: 0.2 },
            });
            dom.statusEl.textContent =
                'Нарисуйте полигон выборки. Части внутри получат заявку и будут закреплены; при повторном попадании внутрь нового полигона заявку можно переназначить.';
            selectionDrawer.enable();
        }

        const selectedGeometry = stripGeometryTo2D(parseGeometryData('selected-geometry-data'));
        const selectedGeometryForEditing =
            stripGeometryTo2D(parseGeometryData('selected-geometry-for-editing-data')) || selectedGeometry;
        const selectedGeo = normalizeGeoJson(selectedGeometryForEditing);
        state.selectedEditableGeo = toEditableFeatureCollection(selectedGeo);

        if (selectedGeo) {
            selectedLayer = L.geoJSON(selectedGeo, {
                style: { color: '#ef4444', weight: 3, fillOpacity: 0.25 },
            }).addTo(selectedGroup);
            try {
                const bounds = selectedLayer.getBounds();
                if (bounds?.isValid?.()) {
                    map.fitBounds(bounds, { padding: [30, 30], maxZoom: 30 });
                }
            } catch (e) {
                console.warn('split-object: fitBounds skipped', e);
            }
            map.invalidateSize();
        } else {
            dom.statusEl.textContent = 'Выбранный объект не удалось отрисовать на карте.';
        }

        dom.editButton.addEventListener('click', () => {
            if (!state.selectedEditableGeo?.features?.length) {
                dom.statusEl.textContent = 'Для этого типа геометрии редактирование не поддержано.';
                return;
            }
            if (state.isEditing) return;

            state.resetPartIdCounter();
            editableGroup.clearLayers();
            const editableLayer = L.geoJSON(state.selectedEditableGeo, {
                style: { color: '#ef4444', weight: 3, fillOpacity: 0.25 },
            });
            let idx = 0;
            editableLayer.eachLayer((layer) => {
                const partId = state.nextPartId();
                const pr = (state.selectedRequestId || '').trim();
                const nm = (state.selectedName || '').trim();
                Split.initPartFromPassport(layer, partId, pr, nm, stripGeometryTo2D);
                Split.bindReadOnlyPartPopup(layer);
                editableGroup.addLayer(layer);
                idx += 1;
            });

            if (selectedLayer && map.hasLayer(selectedLayer)) {
                map.removeLayer(selectedLayer);
            }

            const polyCount = (state.selectedEditableGeo.features || []).filter(
                (f) => f.geometry?.type === 'Polygon'
            ).length;
            state.setModeFromPolygonCount(polyCount);
            setEditMode(true);

            dom.statusEl.textContent =
                state.objectMode() === 'multi'
                    ? 'Режим редактирования включён. Сначала выполните выборку полигоном — затем станет доступно разрезание линией.'
                    : 'Режим редактирования включён. Доступно только разрезание линией.';
        });

        dom.cutButton.addEventListener('click', () => {
            if (!state.isEditing) {
                dom.statusEl.textContent = 'Сначала включите режим редактирования.';
                return;
            }
            if (state.objectMode() === 'multi' && !state.polygonSelectionDone) {
                dom.statusEl.textContent =
                    'Сначала выполните выборку полигоном: назначьте заявки, затем станет доступно разрезание линией.';
                return;
            }
            if (!Split.buildCurrentGeometry(editableGroup)) {
                dom.statusEl.textContent = 'Нет редактируемой геометрии для разрезания.';
                return;
            }
            if (state.cutObjectMode) {
                cancelCutMode();
                dom.statusEl.textContent = 'Разрезание отменено.';
                return;
            }
            startCutMode();
        });

        dom.selectByPolygonButton.addEventListener('click', () => {
            if (!state.isEditing) {
                dom.statusEl.textContent = 'Сначала включите режим редактирования.';
                return;
            }
            if (state.objectMode() === 'single') {
                dom.statusEl.textContent = 'Выборка полигоном доступна только при нескольких полигонах.';
                return;
            }
            if (!Split.buildCurrentGeometry(editableGroup)) {
                dom.statusEl.textContent = 'Нет редактируемой геометрии для выборки.';
                return;
            }
            if (state.selectionPolygonMode) {
                cancelSelectionPolygonMode();
                dom.statusEl.textContent = 'Выборка полигоном отменена.';
                return;
            }
            startSelectionPolygonMode();
        });

        map.on(L.Draw.Event.CREATED, (event) => {
            if (state.selectionPolygonMode) {
                cancelSelectionPolygonMode();
                void Split.applySelectionFromDrawLayer(ctx, event.layer);
                return;
            }
            if (!state.cutObjectMode) return;
            cancelCutMode();
            void Split.applyCutFromDrawLayer(ctx, event.layer, 'line');
        });

        map.on(L.Draw.Event.DRAWVERTEX, () => updateSplitDrawFinishFlag());
        map.on('draw:drawstart', () => clearSplitDrawFinishFlag());
        map.on('draw:drawstop', () => clearSplitDrawFinishFlag());

        dom.cancelButton.addEventListener('click', () => {
            cancelCutMode();
            cancelSelectionPolygonMode();
            editableGroup.clearLayers();
            if (selectedLayer && !map.hasLayer(selectedLayer)) {
                map.addLayer(selectedLayer);
            }
            setEditMode(false);
            dom.statusEl.textContent = 'Изменения отменены.';
        });

        dom.saveButton.addEventListener('click', () => {
            void Split.exportAllParts(ctx);
        });

        return ctx;
    };
})(typeof window !== 'undefined' ? window : global);

(function () {
    'use strict';
    const PV = window.PassViewer;
    PV.localizeLeafletDraw();
    const cfg = PV.getPageConfig();
    const getCookie = PV.getCookie.bind(PV);
    const parseGeometryData = PV.parseGeometryData.bind(PV);
    const normalizeGeoJson = PV.normalizeGeoJson.bind(PV);
    const toEditableFeatureCollection = PV.toEditableFeatureCollection.bind(PV);
    const mergeAdjacentDtPassportsGeoJson = PV.mergeAdjacentDtPassportsGeoJson.bind(PV);
    const escapeHtml = PV.escapeHtml.bind(PV);
    const pickPopupProperty = PV.pickPopupProperty.bind(PV);
    const formatPopupDateToDay = PV.formatPopupDateToDay.bind(PV);
    const buildPopupMetaFieldsHtml = PV.buildPopupMetaFieldsHtml.bind(PV);
    const calculateGeometryAreaSqMeters = PV.calculateGeometryAreaSqMeters.bind(PV);
    const buildObjectPopup = PV.buildObjectPopup.bind(PV);
    const buildPdfIntersectionPopupHtml = PV.buildPdfIntersectionPopupHtml.bind(PV);

const map = L.map('map', {maxZoom: 30}).setView([55.75, 37.61], 12);
        map.attributionControl.setPrefix(
            '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺'
        );

        let popupHighlightLayer = null;
        const POPUP_HIGHLIGHT_WEIGHT_DELTA = 3;

        function clearPopupHighlight() {
            if (popupHighlightLayer && popupHighlightLayer._passViewerPopupPrevStyle) {
                const prev = popupHighlightLayer._passViewerPopupPrevStyle;
                popupHighlightLayer.setStyle(prev);
                if (typeof popupHighlightLayer._passViewerRestoreDgiDom === 'function') {
                    popupHighlightLayer._passViewerDgiPopupSolidStroke = false;
                    popupHighlightLayer._passViewerRestoreDgiDom();
                }
                delete popupHighlightLayer._passViewerPopupPrevStyle;
            }
            popupHighlightLayer = null;
        }

        function applyPopupHighlight(layer) {
            clearPopupHighlight();
            if (!layer || typeof layer.setStyle !== 'function') {
                return;
            }
            const opt = layer.options || {};
            layer._passViewerPopupPrevStyle = {
                weight: opt.weight,
                opacity: opt.opacity,
                fillOpacity: opt.fillOpacity,
                color: opt.color,
                fillColor: opt.fillColor,
                dashArray: opt.dashArray,
            };
            const baseW = typeof opt.weight === 'number' ? opt.weight : 2;
            const highlight = {
                weight: baseW + POPUP_HIGHLIGHT_WEIGHT_DELTA,
                opacity: typeof opt.opacity === 'number' ? Math.min(1, opt.opacity + 0.08) : 1,
            };
            if (typeof opt.fillOpacity === 'number' && opt.fillOpacity > 0.001) {
                highlight.fillOpacity = Math.min(0.55, opt.fillOpacity + 0.12);
            }
            layer.setStyle(highlight);
            if (typeof layer._passViewerRestoreDgiDom === 'function') {
                layer._passViewerDgiPopupSolidStroke = true;
                layer._passViewerRestoreDgiDom();
            }
            popupHighlightLayer = layer;
            if (typeof layer.bringToFront === 'function') {
                layer.bringToFront();
            }
        }

        map.on('popupopen', (e) => {
            const layer = e.popup && e.popup._source;
            applyPopupHighlight(layer);
        });
        map.on('popupclose', () => {
            clearPopupHighlight();
        });

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
        const editButton = document.getElementById('edit-geometry-btn');
        const addPolygonButton = document.getElementById('add-polygon-btn');
        const cutPolygonButton = document.getElementById('cut-polygon-btn');
        const drawModeFreehandToggle = document.getElementById('draw-mode-freehand');
        const snapToggle = document.getElementById('snap-toggle');
        const drawModeSwitch = drawModeFreehandToggle.closest('.snap-switch');
        const snapModeSwitch = snapToggle.closest('.snap-switch');
        const checkRelationsButton = document.getElementById('check-relations-btn');
        const checkDgiIntersectionsButton = document.getElementById('check-dgi-intersections-btn');
        const autoRemoveIntersectionsButton = document.getElementById('auto-remove-intersections-btn');
        const addCommentPointButton = document.getElementById('add-comment-point-btn');
        const clearMapButton = document.getElementById('clear-map-btn');
        const commentPointModal = document.getElementById('comment-point-modal');
        const commentPointText = document.getElementById('comment-point-text');
        const commentPointModalError = document.getElementById('comment-point-modal-error');
        const commentPointModalCancel = document.getElementById('comment-point-modal-cancel');
        const commentPointModalSubmit = document.getElementById('comment-point-modal-submit');
        const listCommentPointsUrl = cfg.urls.listCommentPoints;
        const saveCommentPointUrl = cfg.urls.saveCommentPoint;
        const deleteCommentPointUrl = cfg.urls.deleteCommentPoint;
        const cancelEditButton = document.getElementById('cancel-edit-btn');
        const saveButton = document.getElementById('save-geometry-btn');
        const statusEl = document.getElementById('edit-status');
        const editableAreaInfoEl = document.getElementById('editable-area-info');
        const snapDebugEl = {set textContent(_) {}};
        const snapDebugFixedEl = {set textContent(_) {}};
        const exportLinksEl = document.getElementById('export-links');
        const selectedSourceLabel = cfg.selectedSourceLabel || "ДТ";
        const selectedRootid = cfg.selectedRootid || "";
        const effectiveEntryRequestId = cfg.effectiveRequestId || "";
        const saveModal = document.getElementById('save-modal');
        const saveModalCancel = document.getElementById('save-modal-cancel');
        const saveModalSubmit = document.getElementById('save-modal-submit');
        const newObjectNameInput = document.getElementById('new-object-name');
        const newObjectRequestIdInput = document.getElementById('new-object-request-id');
        const saveModalErrorEl = document.getElementById('save-modal-error');
        const saveModalDgiWarning = document.getElementById('save-modal-dgi-warning');
        const dgiExportConfirmModal = document.getElementById('dgi-export-confirm-modal');
        const dgiExportConfirmAgree = document.getElementById('dgi-export-confirm-agree');
        const dgiExportConfirmBack = document.getElementById('dgi-export-confirm-back');
        let pendingDgiApprove = null;
        const saveTargetDtRadio = document.getElementById('save-target-dt');
        const saveTargetOdhRadio = document.getElementById('save-target-odh');
        const saveTargetOznRadio = document.getElementById('save-target-ozn');
        const autoRemoveModal = document.getElementById('auto-remove-modal');
        const autoRemoveModalCancel = document.getElementById('auto-remove-modal-cancel');
        const autoRemoveModalSubmit = document.getElementById('auto-remove-modal-submit');
        const autoRemoveModalErrorEl = document.getElementById('auto-remove-modal-error');
        const autoRemoveDtCheckbox = document.getElementById('auto-remove-dt');
        const autoRemoveOdhCheckbox = document.getElementById('auto-remove-odh');
        const autoRemoveOznCheckbox = document.getElementById('auto-remove-ozn');
        const autoRemoveDgiMoscowCheckbox = document.getElementById('auto-remove-dgi-moscow');
        const autoRemoveDgiPrivateCheckbox = document.getElementById('auto-remove-dgi-private');
        const autoRemoveOoztCheckbox = document.getElementById('auto-remove-oozt');
        const autoRemoveRzdCheckbox = document.getElementById('auto-remove-rzd');
        const checkDgiModal = document.getElementById('check-dgi-modal');
        const checkDgiModalBody = document.getElementById('check-dgi-modal-body');
        const checkDgiModalClose = document.getElementById('check-dgi-modal-close');
        const dbLoadingModal = document.getElementById('db-loading-modal');
        const deletePolygonModal = document.getElementById('delete-polygon-modal');
        const deletePolygonModalCancel = document.getElementById('delete-polygon-modal-cancel');
        const deletePolygonModalSubmit = document.getElementById('delete-polygon-modal-submit');
        const cutModeModal = document.getElementById('cut-mode-modal');
        const cutModePolygonButton = document.getElementById('cut-mode-polygon-btn');
        const cutModeLineButton = document.getElementById('cut-mode-line-btn');
        const cutModeModalCancel = document.getElementById('cut-mode-modal-cancel');
        let isEditing = false;
        const mapEl = document.getElementById('map');
        const editableGroup = new L.FeatureGroup().addTo(map);
        const relationAdjacentDtPassportsGroup = new L.FeatureGroup().addTo(map);
        const relationRequestObjectsGroup = new L.FeatureGroup().addTo(map);
        const dgiMoscowSignalGroup = L.featureGroup().addTo(map);
        const dgiPrivateSignalGroup = L.featureGroup().addTo(map);
        const odhSignalGroup = L.featureGroup().addTo(map);
        const oznSignalGroup = L.featureGroup().addTo(map);
        const renewGroup = L.featureGroup().addTo(map);
        const ooztSignalGroup = L.featureGroup().addTo(map);
        const rzdSignalGroup = L.featureGroup().addTo(map);
        const recapsGroup = L.featureGroup().addTo(map);
        const commentPointsGroup = L.featureGroup().addTo(map);
        let drawControl = null;
        let editToolbar = null;
        let polygonDrawer = null;
        let freehandMode = false;
        let freehandDrawing = false;
        let freehandLatLngs = [];
        let freehandPreviewLine = null;
        let drawModeToggleLocked = false;
        let dbLoadingCounter = 0;
        let addObjectMode = false;
        let cutObjectMode = false;
        let snappingEnabled = false;
        let snapDistanceMeters = 5;
        let snapGuideLines = [];
        let snapBindingTimer = null;
        let drawSnapRadiusCircle = null;
        let drawSnapTargetLine = null;
        const layerPanelEl = document.getElementById('layer-management-panel');
        const layerPanelCheckboxes = layerPanelEl
            ? Array.from(layerPanelEl.querySelectorAll('input[data-layer-key]'))
            : [];
        const layerPanelGroupCheckboxes = layerPanelEl
            ? Array.from(layerPanelEl.querySelectorAll('input[data-layer-group]'))
            : [];
        let startVertexFlagMarker = null;
        let pendingDeleteLayer = null;
        let cutDrawer = null;
        let commentPointMode = false;
        let pendingCommentLatLng = null;
        let commentPickCaptureLayer = null;
        autoRemoveIntersectionsButton.disabled = true;

        function showDbLoadingModal() {
            if (!dbLoadingModal) {
                return;
            }
            dbLoadingCounter += 1;
            dbLoadingModal.style.display = 'flex';
        }

        function hideDbLoadingModal() {
            if (!dbLoadingModal) {
                return;
            }
            dbLoadingCounter = Math.max(0, dbLoadingCounter - 1);
            if (dbLoadingCounter === 0) {
                dbLoadingModal.style.display = 'none';
            }
        }

        function buildCommentPointPopupHtml(props) {
            const p = props || {};
            const id = p.id;
            const text = (p.comment || '').trim() || '—';
            const created = p.created_at || '';
            const esc = (s) => String(s || '').replace(/</g, '&lt;');
            return (
                '<div class="comment-point-popup" style="max-width:260px;">' +
                '<strong>Комментарий</strong><br/>' +
                esc(text) +
                (created
                    ? '<br/><span style="color:#64748b;font-size:12px;">' + esc(created) + '</span>'
                    : '') +
                '<div style="margin-top:10px;padding-top:8px;border-top:1px solid #e5e7eb;">' +
                '<button type="button" class="map-toolbar-btn map-toolbar-btn--danger comment-point-delete-btn" style="font-size:12px;padding:6px 10px;" data-comment-point-id="' +
                esc(id) +
                '">🗑 Удалить</button>' +
                '</div></div>'
            );
        }

        function bindCommentPointLayer(layer, feature) {
            const props = feature.properties || {};
            const fid = props.id;
            layer.bindPopup(buildCommentPointPopupHtml(props));
            layer.off('popupopen');
            layer.on('popupopen', () => {
                const popupEl = layer.getPopup()?.getElement?.();
                const btn = popupEl?.querySelector('.comment-point-delete-btn');
                if (btn && fid != null) {
                    btn.onclick = (event) => {
                        event.preventDefault();
                        event.stopPropagation();
                        void deleteCommentPointById(Number(fid), layer);
                    };
                }
            });
        }

        async function deleteCommentPointById(pointId, layer) {
            if (!pointId || !Number.isFinite(pointId)) {
                return;
            }
            if (!window.confirm('Удалить эту точку комментария?')) {
                return;
            }
            try {
                const res = await fetch(deleteCommentPointUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    credentials: 'same-origin',
                    body: JSON.stringify({ id: pointId }),
                });
                const data = await res.json();
                if (!res.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось удалить точку.');
                }
                if (layer) {
                    layer.remove();
                }
                map.closePopup();
                refreshObjectLayersControl();
                statusEl.textContent = 'Точка комментария удалена.';
            } catch (err) {
                window.alert(err.message || 'Ошибка удаления.');
            }
        }

        function ensureCommentPickCapture() {
            if (commentPickCaptureLayer) {
                return;
            }
            if (!map.getPane('commentPickPane')) {
                const pane = map.createPane('commentPickPane');
                pane.style.zIndex = '10000';
                pane.style.pointerEvents = 'auto';
            }
            const bounds = L.latLngBounds(L.latLng(-90, -180), L.latLng(90, 180));
            commentPickCaptureLayer = L.rectangle(bounds, {
                pane: 'commentPickPane',
                interactive: true,
                stroke: false,
                fillOpacity: 0,
                fillColor: '#000',
            });
            commentPickCaptureLayer.on('click', (e) => {
                L.DomEvent.stopPropagation(e);
                if (!commentPointMode) {
                    return;
                }
                if (addObjectMode || cutObjectMode || freehandDrawing) {
                    return;
                }
                if (polygonDrawer) {
                    return;
                }
                pendingCommentLatLng = e.latlng;
                setCommentPointMode(false);
                openCommentPointModal();
            });
        }

        async function loadCommentPointsForMap() {
            const rid = (effectiveEntryRequestId || '').trim();
            commentPointsGroup.clearLayers();
            if (addCommentPointButton) {
                if (!rid) {
                    addCommentPointButton.disabled = true;
                    addCommentPointButton.title =
                        'Нет номера заявки — укажите его при входе на страницу добавления объекта.';
                } else {
                    addCommentPointButton.disabled = false;
                    addCommentPointButton.title = '';
                }
            }
            if (!rid) {
                return;
            }
            try {
                const u = new URL(listCommentPointsUrl, window.location.origin);
                u.searchParams.set('request_id', rid);
                const res = await fetch(u.toString(), { credentials: 'same-origin' });
                const data = await res.json();
                if (!res.ok || !data.ok || !data.geojson) {
                    return;
                }
                L.geoJSON(data.geojson, {
                    pointToLayer: (feature, latlng) =>
                        L.circleMarker(latlng, {
                            radius: 8,
                            color: '#6d28d9',
                            weight: 2,
                            fillColor: '#a78bfa',
                            fillOpacity: 0.9,
                            opacity: 0.95,
                        }),
                    onEachFeature: (feature, layer) => {
                        bindCommentPointLayer(layer, feature);
                    },
                }).addTo(commentPointsGroup);
            } catch (e) {
                /* ignore */
            }
        }

        function setCommentPointMode(enabled) {
            commentPointMode = enabled;
            if (addCommentPointButton) {
                addCommentPointButton.classList.toggle('is-active', enabled);
            }
            if (mapEl) {
                mapEl.classList.toggle('map--pick-comment-point', enabled);
            }
            if (enabled) {
                pendingCommentLatLng = null;
                ensureCommentPickCapture();
                if (commentPickCaptureLayer && !map.hasLayer(commentPickCaptureLayer)) {
                    commentPickCaptureLayer.addTo(map);
                }
            } else if (commentPickCaptureLayer && map.hasLayer(commentPickCaptureLayer)) {
                map.removeLayer(commentPickCaptureLayer);
            }
        }

        function cancelCommentPointMode() {
            pendingCommentLatLng = null;
            setCommentPointMode(false);
        }

        function openCommentPointModal() {
            if (commentPointModal && commentPointText) {
                commentPointText.value = '';
                if (commentPointModalError) {
                    commentPointModalError.textContent = '';
                }
                commentPointModal.style.display = 'flex';
                setTimeout(() => commentPointText.focus(), 0);
            }
        }

        function closeCommentPointModal() {
            if (commentPointModal) {
                commentPointModal.style.display = 'none';
            }
            pendingCommentLatLng = null;
        }

        function clearStartVertexFlag() {
            if (startVertexFlagMarker && map.hasLayer(startVertexFlagMarker)) {
                map.removeLayer(startVertexFlagMarker);
            }
            startVertexFlagMarker = null;
        }
        function getFirstVertexFromDrawer() {
            const latlngs = polygonDrawer?._poly?.getLatLngs?.();
            if (!Array.isArray(latlngs) || !latlngs.length) {
                return null;
            }
            const first = Array.isArray(latlngs[0]) ? latlngs[0][0] : latlngs[0];
            return first && Number.isFinite(first.lat) && Number.isFinite(first.lng) ? first : null;
        }
        function updateStartVertexFlag() {
            if (!isEditing || !addObjectMode || freehandMode || !polygonDrawer) {
                clearStartVertexFlag();
                return;
            }
            const firstVertex = getFirstVertexFromDrawer();
            if (!firstVertex) {
                clearStartVertexFlag();
                return;
            }
            if (!startVertexFlagMarker) {
                startVertexFlagMarker = L.marker(firstVertex, {
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
                startVertexFlagMarker.setLatLng(firstVertex);
            }
        }
        const countGroupFeatures = (group) => {
            let count = 0;
            group.eachLayer((layer) => {
                if (typeof layer.toGeoJSON !== 'function') {
                    return;
                }
                const geo = layer.toGeoJSON();
                if (geo?.type === 'FeatureCollection' && Array.isArray(geo.features)) {
                    count += geo.features.length;
                } else if (geo?.type === 'Feature') {
                    count += 1;
                } else if (geo?.type) {
                    count += 1;
                }
            });
            return count;
        };
        const filterOutSelectedRootid = (geojson, selectedRootidValue) => {
            const selectedRootidText = String(selectedRootidValue || '').trim();
            if (!selectedRootidText || !geojson || geojson.type !== 'FeatureCollection' || !Array.isArray(geojson.features)) {
                return geojson;
            }
            return {
                ...geojson,
                features: geojson.features.filter((feature) => {
                    const rid = String(feature?.properties?.rootid ?? '').trim();
                    return rid !== selectedRootidText;
                }),
            };
        };
        const managedLayers = {
            selected: editableGroup,
            dt: relationAdjacentDtPassportsGroup,
            oo: oznSignalGroup,
            odh: odhSignalGroup,
            dgi_moscow: dgiMoscowSignalGroup,
            dgi_private: dgiPrivateSignalGroup,
            renew: renewGroup,
            oozt: ooztSignalGroup,
            rzd: rzdSignalGroup,
            requests: relationRequestObjectsGroup,
            recaps: recapsGroup,
            comments: commentPointsGroup,
        };
        const layerGroups = {
            municipal: ['selected', 'dt', 'oo', 'odh'],
            requests: ['requests', 'recaps', 'comments'],
            external: ['dgi_moscow', 'dgi_private', 'renew', 'oozt', 'rzd'],
        };

        function setLayerVisible(layerKey, isVisible) {
            const group = managedLayers[layerKey];
            if (!group) {
                return;
            }
            if (isVisible) {
                if (!map.hasLayer(group)) {
                    group.addTo(map);
                }
            } else if (map.hasLayer(group)) {
                map.removeLayer(group);
            }
        }

        function syncLayerPanelCheckboxes() {
            layerPanelCheckboxes.forEach((checkbox) => {
                const group = managedLayers[checkbox.dataset.layerKey];
                if (group) {
                    checkbox.checked = map.hasLayer(group);
                }
            });
            layerPanelGroupCheckboxes.forEach((groupCheckbox) => {
                const groupKeys = layerGroups[groupCheckbox.dataset.layerGroup] || [];
                const visibleCount = groupKeys.filter((key) => {
                    const layer = managedLayers[key];
                    return layer && map.hasLayer(layer);
                }).length;
                groupCheckbox.indeterminate = visibleCount > 0 && visibleCount < groupKeys.length;
                groupCheckbox.checked = visibleCount > 0 && visibleCount === groupKeys.length;
            });
        }

        function refreshLayerPanelCounts() {
            const counts = {
                selected: countGroupFeatures(editableGroup),
                dt: countGroupFeatures(relationAdjacentDtPassportsGroup),
                oo: countGroupFeatures(oznSignalGroup),
                odh: countGroupFeatures(odhSignalGroup),
                dgi_moscow: countGroupFeatures(dgiMoscowSignalGroup),
                dgi_private: countGroupFeatures(dgiPrivateSignalGroup),
                renew: countGroupFeatures(renewGroup),
                oozt: countGroupFeatures(ooztSignalGroup),
                rzd: countGroupFeatures(rzdSignalGroup),
                requests: countGroupFeatures(relationRequestObjectsGroup),
                recaps: countGroupFeatures(recapsGroup),
                comments: countGroupFeatures(commentPointsGroup),
            };
            Object.entries(counts).forEach(([key, count]) => {
                const countEl = layerPanelEl?.querySelector(`[data-layer-count-for="${key}"]`);
                if (countEl) {
                    countEl.textContent = `(${count})`;
                }
            });
            syncLayerPanelCheckboxes();
        }

        layerPanelCheckboxes.forEach((checkbox) => {
            checkbox.addEventListener('change', () => {
                setLayerVisible(checkbox.dataset.layerKey, checkbox.checked);
                refreshLayerPanelCounts();
            });
        });
        layerPanelGroupCheckboxes.forEach((groupCheckbox) => {
            groupCheckbox.addEventListener('change', () => {
                const groupKeys = layerGroups[groupCheckbox.dataset.layerGroup] || [];
                groupKeys.forEach((layerKey) => {
                    setLayerVisible(layerKey, groupCheckbox.checked);
                });
                refreshLayerPanelCounts();
            });
        });

        function refreshObjectLayersControl() {
            refreshLayerPanelCounts();
        }

        function addSignalTapeLayer(targetGroup, geojsonObject, sourceLabel) {
            targetGroup.clearLayers();
            const geo = normalizeGeoJson(geojsonObject);
            if (!geo) {
                return;
            }
            const ensureSignalPattern = (patternId, stripeColorHex, backgroundColorHex) => {
                const svg = map.getPanes().overlayPane.querySelector('svg');
                if (!svg) {
                    return null;
                }
                let defs = svg.querySelector('defs');
                if (!defs) {
                    defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
                    svg.insertBefore(defs, svg.firstChild);
                }
                if (!svg.querySelector('#' + patternId)) {
                    const pattern = document.createElementNS('http://www.w3.org/2000/svg', 'pattern');
                    pattern.setAttribute('id', patternId);
                    pattern.setAttribute('patternUnits', 'userSpaceOnUse');
                    pattern.setAttribute('width', '24');
                    pattern.setAttribute('height', '24');
                    pattern.setAttribute('patternTransform', 'rotate(45)');

                    const bgRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
                    bgRect.setAttribute('x', '0');
                    bgRect.setAttribute('y', '0');
                    bgRect.setAttribute('width', '24');
                    bgRect.setAttribute('height', '24');
                    bgRect.setAttribute('fill', backgroundColorHex);

                    const stripeRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
                    stripeRect.setAttribute('x', '0');
                    stripeRect.setAttribute('y', '0');
                    stripeRect.setAttribute('width', '12');
                    stripeRect.setAttribute('height', '24');
                    stripeRect.setAttribute('fill', stripeColorHex);

                    pattern.appendChild(bgRect);
                    pattern.appendChild(stripeRect);
                    defs.appendChild(pattern);
                }
                return patternId;
            };
            const isDgi = sourceLabel === 'ДГИ';
            const isOozt = sourceLabel === 'ООЗТ';
            const isRzd = sourceLabel === 'РЖД';
            const isRenew = sourceLabel === 'Реновация';
            const isOdh = sourceLabel === 'ОДХ';
            const isOzn = sourceLabel === 'ОЗН';
            const isSignalTape = isDgi || isOozt || isRzd || isRenew;
            if (!isSignalTape && !isOdh && !isOzn) {
                L.geoJSON(geo, {
                    interactive: false,
                    style: {color: '#ffffff', weight: 7, opacity: 0.95, fillOpacity: 0}
                }).addTo(targetGroup);
            }
            L.geoJSON(geo, {
                style: {
                    color: isOdh ? '#00bfff' : (isOzn || isOozt) ? '#16a34a' : isRenew ? '#b45309' : '#dc2626',
                    weight: 4,
                    opacity: 0.95,
                    dashArray: (isOdh || isOzn) ? null : '10 8',
                    fillOpacity: isOzn ? 0.25 : 0,
                },
                onEachFeature: (feature, layer) => {
                    if (isOozt) {
                        const ooztType = feature?.properties?.type ?? '-';
                        const ooztNomer1 = feature?.properties?.nomer1 ?? '-';
                        const ooztComment = feature?.properties?.comment ?? '-';
                        const typeText = String(ooztType ?? '').trim();
                        const nomer1Text = String(ooztNomer1 ?? '').trim();
                        const commentText = String(ooztComment ?? '').trim();
                        layer.bindPopup(
                            '<div style="min-width: 220px;">' +
                            '<div><strong>ООЗТ</strong></div>' +
                            (!typeText || ['null', 'none', '-'].includes(typeText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Тип:</strong> ' + escapeHtml(ooztType) + '</div>')) +
                            (!nomer1Text || ['null', 'none', '-'].includes(nomer1Text.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Номер:</strong> ' + escapeHtml(ooztNomer1) + '</div>')) +
                            (!commentText || ['null', 'none', '-'].includes(commentText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Комментарий:</strong> ' + escapeHtml(ooztComment) + '</div>')) +
                            '</div>'
                        );
                    } else if (isRzd) {
                        const rzdName = feature?.properties?.name ?? '-';
                        const rzdComment = feature?.properties?.comment_ ?? '-';
                        const nameText = String(rzdName ?? '').trim();
                        const commentText = String(rzdComment ?? '').trim();
                        layer.bindPopup(
                            '<div style="min-width: 220px;">' +
                            '<div><strong>РЖД</strong></div>' +
                            (!nameText || ['null', 'none', '-'].includes(nameText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Название:</strong> ' + escapeHtml(rzdName) + '</div>')) +
                            (!commentText || ['null', 'none', '-'].includes(commentText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Комментарий:</strong> ' + escapeHtml(rzdComment) + '</div>')) +
                            '</div>'
                        );
                    } else if (isRenew) {
                        const renewName = feature?.properties?.name ?? '-';
                        const nameText = String(renewName ?? '').trim();
                        layer.bindPopup(
                            '<div style="min-width: 220px;">' +
                            '<div><strong>Реновация</strong></div>' +
                            (!nameText || ['null', 'none', '-'].includes(nameText.toLowerCase())
                                ? ''
                                : ('<div style="margin-top: 6px;"><strong>Название:</strong> ' + escapeHtml(renewName) + '</div>')) +
                            '</div>'
                        );
                    } else if (isDgi) {
                        const descr = feature?.properties?.descr ?? '-';
                        const address = feature?.properties?.address ?? '-';
                        const vri = feature?.properties?.vri ?? '-';
                        const sobstvRrDisplay = formatDgiShortSobstvRr(feature?.properties?.short_sobstv_rr);
                        const descrText = String(descr ?? '').trim();
                        const addressText = String(address ?? '').trim();
                        const vriText = String(vri ?? '').trim();
                        const sobstvRrText = String(sobstvRrDisplay ?? '').trim();
                        layer.bindPopup(
                            '<div style="min-width: 220px;">' +
                            '<div><strong>ДГИ</strong></div>' +
                            (!descrText || ['null', 'none', '-'].includes(descrText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Кадастровый номер:</strong> ' + escapeHtml(descr) + '</div>')) +
                            (!addressText || ['null', 'none', '-'].includes(addressText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Адрес:</strong> ' + escapeHtml(address) + '</div>')) +
                            (!vriText || ['null', 'none', '-'].includes(vriText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Назначение:</strong> ' + escapeHtml(vri) + '</div>')) +
                            (!sobstvRrText ? '' : ('<div style="margin-top: 6px;"><strong>Собственник:</strong> ' + escapeHtml(sobstvRrDisplay) + '</div>')) +
                            '</div>'
                        );
                    } else if (isOdh || isOzn) {
                        const rootid = feature?.properties?.rootid ?? '-';
                        const name = feature?.properties?.name ?? '-';
                        const customerLegalPersonId = feature?.properties?.customer_legal_person_id ?? '-';
                        const departmentLegalPersonId = feature?.properties?.department_legal_person_id ?? '-';
                        const ownerLegalPersonId = feature?.properties?.owner_legal_person_id ?? '-';
                        const customerLegalPersonName = feature?.properties?.customer_legal_person_name ?? '-';
                        const departmentLegalPersonName = feature?.properties?.department_legal_person_name ?? '-';
                        const ownerLegalPersonName = feature?.properties?.owner_legal_person_name ?? '-';
                        const customerText = String(customerLegalPersonId ?? '').trim();
                        const departmentText = String(departmentLegalPersonId ?? '').trim();
                        const ownerText = String(ownerLegalPersonId ?? '').trim();
                        const customerNameText = String(customerLegalPersonName ?? '').trim();
                        const departmentNameText = String(departmentLegalPersonName ?? '').trim();
                        const ownerNameText = String(ownerLegalPersonName ?? '').trim();
                        const rootidText = String(rootid ?? '').trim();
                        const nameText = String(name ?? '').trim();
                        const hasCustomer = !!customerText && !['null', 'none', '-'].includes(customerText.toLowerCase());
                        const hasDepartmentId = !!departmentText && !['null', 'none', '-'].includes(departmentText.toLowerCase());
                        const hasOwner = !!ownerText && !['null', 'none', '-'].includes(ownerText.toLowerCase());
                        const hasCustomerName = !!customerNameText && !['null', 'none', '-'].includes(customerNameText.toLowerCase());
                        const hasDepartmentName = !!departmentNameText && !['null', 'none', '-'].includes(departmentNameText.toLowerCase());
                        const hasDepartment = hasDepartmentId || hasDepartmentName;
                        const hasOwnerName = !!ownerNameText && !['null', 'none', '-'].includes(ownerNameText.toLowerCase());
                        const customerDisplay = hasCustomerName
                            ? String(customerLegalPersonName || '-')
                            : String(customerLegalPersonId || '-');
                        const departmentDisplay = hasDepartmentName
                            ? String(departmentLegalPersonName || '-')
                            : String(departmentLegalPersonId || '-');
                        const ownerDisplay = hasOwnerName
                            ? String(ownerLegalPersonName || '-')
                            : String(ownerLegalPersonId || '-');
                        layer.bindPopup(
                            '<div style="min-width: 220px;">' +
                            '<div><strong>' + (isOzn ? 'ОО' : 'ОДХ') + '</strong></div>' +
                            (!rootidText || ['null', 'none', '-'].includes(rootidText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Паспорт №:</strong> ' + escapeHtml(rootid) + '</div>')) +
                            (!nameText || ['null', 'none', '-'].includes(nameText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Название:</strong> ' + escapeHtml(name) + '</div>')) +
                            (isOzn
                                ? (hasOwner ? ('<div style="margin-top: 6px;"><strong>Балансодержатель:</strong> ' + escapeHtml(ownerDisplay) + '</div>') : '')
                                : (hasCustomer ? ('<div style="margin-top: 6px;"><strong>Балансодержатель:</strong> ' + escapeHtml(customerDisplay) + '</div>') : '')) +
                            (hasDepartment ? ('<div style="margin-top: 6px;"><strong>Отраслевой ОИВ:</strong> ' + escapeHtml(departmentDisplay) + '</div>') : '') +
                            buildPopupMetaFieldsHtml(feature.properties || {}) +
                            '</div>'
                        );
                    } else {
                        layer.bindPopup('<strong>' + sourceLabel + '</strong>');
                    }
                    if (isSignalTape) {
                        const tapeConfig = isOozt
                            ? {patternId: 'oozt-signal-tape-pattern', stripe: '#16a34a', bg: '#ffffff', stroke: '#16a34a'}
                            : isRzd
                                ? {patternId: 'rzd-signal-tape-pattern', stripe: '#dc2626', bg: '#16a34a', stroke: '#dc2626'}
                                : isRenew
                                    ? {patternId: 'renew-signal-tape-pattern', stripe: '#f59e0b', bg: '#ffffff', stroke: '#b45309'}
                                    : {patternId: 'dgi-signal-tape-pattern', stripe: '#dc2626', bg: '#ffffff', stroke: '#dc2626'};
                        layer._passViewerRestoreDgiDom = function () {
                            const patternId = ensureSignalPattern(
                                tapeConfig.patternId,
                                tapeConfig.stripe,
                                tapeConfig.bg
                            );
                            const el = layer.getElement && layer.getElement();
                            if (!patternId || !el) {
                                return;
                            }
                            const o = layer.options || {};
                            const solidPopup = !!layer._passViewerDgiPopupSolidStroke;
                            const dash =
                                solidPopup
                                    ? null
                                    : o.dashArray != null && o.dashArray !== ''
                                        ? String(o.dashArray)
                                        : '10 8';
                            el.setAttribute('fill', 'url(#' + patternId + ')');
                            el.setAttribute('fill-opacity', '0.25');
                            el.setAttribute('stroke', tapeConfig.stroke);
                            el.setAttribute('stroke-width', '2');
                            if (dash) {
                                el.setAttribute('stroke-dasharray', dash);
                            } else {
                                el.removeAttribute('stroke-dasharray');
                            }
                        };
                        layer.on('add', layer._passViewerRestoreDgiDom);
                    }
                }
            }).addTo(targetGroup);
        }
        function renderReferenceSignalLayers(dgiMoscowGeo, dgiPrivateGeo, odhGeo, oznGeo) {
            addSignalTapeLayer(dgiMoscowSignalGroup, dgiMoscowGeo, 'ДГИ');
            addSignalTapeLayer(dgiPrivateSignalGroup, dgiPrivateGeo, 'ДГИ');
            addSignalTapeLayer(odhSignalGroup, odhGeo, 'ОДХ');
            addSignalTapeLayer(oznSignalGroup, oznGeo, 'ОЗН');
        }
        function renderRenewLayer(renewGeo) {
            addSignalTapeLayer(renewGroup, renewGeo, 'Реновация');
        }

        function renderRecapsLayer(recapsGeo) {
            recapsGroup.clearLayers();
            const geo = normalizeGeoJson(recapsGeo);
            if (!geo) {
                return;
            }
            L.geoJSON(geo, {
                style: {color: '#7c3aed', weight: 2, fillColor: '#7c3aed', fillOpacity: 0.25},
                onEachFeature: (feature, layer) => {
                    const recapId = feature?.properties?.recap_id ?? '-';
                    const requestId = feature?.properties?.request_id ?? '-';
                    const name = feature?.properties?.name ?? '-';
                    const ownerLegalPersonId = feature?.properties?.owner_legal_person_id ?? '-';
                    const ownerLegalPersonName = feature?.properties?.owner_legal_person_name ?? '-';
                    const nameText = String(name ?? '').trim();
                    const ownerText = String(ownerLegalPersonId ?? '').trim();
                    const ownerNameText = String(ownerLegalPersonName ?? '').trim();
                    const ownerDisplay = ownerNameText && !['null', 'none', '-'].includes(ownerNameText.toLowerCase())
                        ? String(ownerLegalPersonName || '-')
                        : String(ownerLegalPersonId || '-');
                    layer.bindPopup(
                        '<div style="min-width: 220px;">' +
                        '<div><strong>№ Досъёма:</strong> ' + escapeHtml(recapId) + '</div>' +
                        '<div style="margin-top: 6px;"><strong>№ Заявки:</strong> ' + escapeHtml(requestId) + '</div>' +
                        (!nameText || ['null', 'none', '-'].includes(nameText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Название:</strong> ' + escapeHtml(name) + '</div>')) +
                        (!ownerText || ['null', 'none', '-'].includes(ownerText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Балансодержатель:</strong> ' + escapeHtml(ownerDisplay) + '</div>')) +
                        '</div>'
                    );
                }
            }).addTo(recapsGroup);
        }
        // Do not render DGI/ODH on initial page load.
        // They are requested and shown only after the user creates the first object.

        
        function formatDgiShortSobstvRr(value) {
            const raw = String(value ?? '').trim();
            if (!raw || ['null', 'none', '-'].includes(raw.toLowerCase())) {
                return '';
            }
            if (raw.toUpperCase() === 'ЧС') {
                return 'Частная собственность';
            }
            return raw;
        }

        
        
        
        
        
        
        function buildEditableDeletePopupHtml(baseHtml) {
            return (
                baseHtml +
                '<div style="margin-top:10px; padding-top:8px; border-top:1px solid #e5e7eb;">' +
                '<button type="button" class="popup-delete-polygon-btn map-toolbar-btn map-toolbar-btn--danger" style="font-size:12px; padding:6px 10px;">🗑 Удалить полигон</button>' +
                '</div>'
            );
        }

        function bindEditablePolygonPopup(layer, baseHtml) {
            layer.bindPopup(buildEditableDeletePopupHtml(baseHtml));
            layer.off('popupopen');
            layer.on('popupopen', () => {
                const popupEl = layer.getPopup()?.getElement?.();
                const btn = popupEl?.querySelector('.popup-delete-polygon-btn');
                if (!btn) {
                    return;
                }
                btn.onclick = (event) => {
                    event.preventDefault();
                    event.stopPropagation();
                    pendingDeleteLayer = layer;
                    deletePolygonModal.style.display = 'flex';
                };
            });
        }

        function buildCurrentGeometry() {
            const featureCollection = editableGroup.toGeoJSON();
            const geometries = (featureCollection.features || [])
                .map((feature) => feature.geometry)
                .filter((geometry) => geometry && (geometry.type === 'Polygon' || geometry.type === 'MultiPolygon'));

            if (!geometries.length) {
                return null;
            }
            if (geometries.length === 1) {
                return geometries[0];
            }
            return {
                type: 'GeometryCollection',
                geometries: geometries
            };
        }

        function clearRelationLayers() {
            relationAdjacentDtPassportsGroup.clearLayers();
            relationRequestObjectsGroup.clearLayers();
            refreshObjectLayersControl();
        }

        function clearMapDisplayedUserDrawings() {
            if (!window.confirm('Убрать с карты все нарисованные полигоны? Объекты из базы на карте останутся.')) {
                return;
            }
            cancelCommentPointMode();
            cancelAddObjectMode();
            cancelCutMode();
            if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
            }
            stopFreehandMode();
            clearDrawSnapPreview();
            clearStartVertexFlag();
            closeCutModeModal();
            closeAutoRemoveModal();
            closeDeletePolygonModal();
            closeCommentPointModal();

            editableGroup.clearLayers();

            clearPopupHighlight();
            map.closePopup();

            if (editToolbar) {
                editToolbar.disable();
                editToolbar = new L.EditToolbar.Edit(map, { featureGroup: editableGroup });
                if (isEditing && editableGroup.getLayers().length) {
                    editToolbar.enable();
                }
            }

            rebuildSnapGuideLines();
            refreshObjectLayersControl();
            updateRelationsButtonState();
            if (exportLinksEl) {
                exportLinksEl.innerHTML = '';
            }
            statusEl.textContent = 'С карты убраны только нарисованные полигоны; данные из базы не изменялись.';
        }

        function updateRelationsButtonState() {
            const hasEditableGeometry = !!buildCurrentGeometry();
            checkRelationsButton.disabled = !hasEditableGeometry;
            const geometry = buildCurrentGeometry();
            const area = calculateGeometryAreaSqMeters(geometry);
            editableAreaInfoEl.textContent = Number.isFinite(area) && area > 0
                ? ('Площадь редактируемого объекта: ' + area.toFixed(2) + ' м² (' + (area / 10000).toFixed(2) + ' га)')
                : 'Площадь редактируемого объекта: -';
            updateEditToolbarVisibility(hasEditableGeometry);
            refreshObjectLayersControl();
        }

        function updateEditToolbarVisibility(hasEditableGeometry = !!buildCurrentGeometry()) {
            const showEditModeControls = !!isEditing;
            const showGeometryControls = showEditModeControls && !!hasEditableGeometry;
            [addPolygonButton, cutPolygonButton, drawModeSwitch, snapModeSwitch].forEach((control) => {
                control?.classList.toggle('map-toolbar-hidden', !showEditModeControls);
            });
            [checkRelationsButton, checkDgiIntersectionsButton, autoRemoveIntersectionsButton, addCommentPointButton].forEach((control) => {
                control?.classList.toggle('map-toolbar-hidden', !showGeometryControls);
            });
        }

        function collectSnapGuideLines(geojsonObject, output) {
            const normalized = normalizeGeoJson(geojsonObject);
            if (!normalized || !normalized.features) {
                if (normalized && normalized.type === 'Feature') {
                    return collectSnapGuideLines({type: 'FeatureCollection', features: [normalized]}, output);
                }
                return;
            }
            const addRing = (ring) => {
                if (!ring || ring.length < 2) {
                    return;
                }
                output.push(ring.map((c) => L.latLng(c[1], c[0])));
            };
            const collectGeometry = (geometry) => {
                if (!geometry) {
                    return;
                }
                if (geometry.type === 'Polygon') {
                    geometry.coordinates.forEach(addRing);
                } else if (geometry.type === 'MultiPolygon') {
                    geometry.coordinates.forEach((poly) => poly.forEach(addRing));
                } else if (geometry.type === 'LineString') {
                    addRing(geometry.coordinates);
                } else if (geometry.type === 'MultiLineString') {
                    geometry.coordinates.forEach(addRing);
                } else if (geometry.type === 'GeometryCollection') {
                    (geometry.geometries || []).forEach(collectGeometry);
                }
            };
            normalized.features.forEach((feature) => {
                collectGeometry(feature.geometry);
            });
        }

        function rebuildSnapGuideLines() {
            snapGuideLines = [];
            [relationAdjacentDtPassportsGroup, relationRequestObjectsGroup, dgiMoscowSignalGroup,
                dgiPrivateSignalGroup, odhSignalGroup, oznSignalGroup, renewGroup, ooztSignalGroup, rzdSignalGroup, recapsGroup].forEach((group) => {
                group.eachLayer((layer) => {
                    if (typeof layer.toGeoJSON === 'function') {
                        collectSnapGuideLines(layer.toGeoJSON(), snapGuideLines);
                    }
                });
            });
        }

        function findNearestSnapTarget(latlng) {
            if (!snappingEnabled || !snapGuideLines.length) {
                return null;
            }
            const nearestAny = findNearestCandidate(latlng);
            if (!nearestAny || nearestAny.distance > snapDistanceMeters) {
                return null;
            }
            return nearestAny;
        }

        function nearestPointOnSegment(pointLatLng, aLatLng, bLatLng) {
            const p = L.CRS.EPSG3857.project(pointLatLng);
            const a = L.CRS.EPSG3857.project(aLatLng);
            const b = L.CRS.EPSG3857.project(bLatLng);
            const vx = b.x - a.x;
            const vy = b.y - a.y;
            const len2 = vx * vx + vy * vy;
            if (!len2) {
                return aLatLng;
            }
            let t = ((p.x - a.x) * vx + (p.y - a.y) * vy) / len2;
            t = Math.max(0, Math.min(1, t));
            const proj = L.point(a.x + t * vx, a.y + t * vy);
            return L.CRS.EPSG3857.unproject(proj);
        }

        function findNearestCandidate(latlng) {
            if (!snapGuideLines.length) {
                return null;
            }
            let bestPoint = null;
            let bestDistance = Infinity;
            snapGuideLines.forEach((lineLatLngs) => {
                if (!lineLatLngs || !lineLatLngs.length) {
                    return;
                }
                // Candidate 1: snap to vertices.
                for (let i = 0; i < lineLatLngs.length; i += 1) {
                    const candidate = lineLatLngs[i];
                    const distance = map.distance(latlng, candidate);
                    if (distance < bestDistance) {
                        bestDistance = distance;
                        bestPoint = candidate;
                    }
                }
                // Candidate 2: snap to edges.
                if (lineLatLngs.length >= 2) {
                    for (let i = 0; i < lineLatLngs.length - 1; i += 1) {
                        const candidate = nearestPointOnSegment(latlng, lineLatLngs[i], lineLatLngs[i + 1]);
                        const distance = map.distance(latlng, candidate);
                        if (distance < bestDistance) {
                            bestDistance = distance;
                            bestPoint = candidate;
                        }
                    }
                }
            });
            if (!bestPoint) {
                return null;
            }
            return {point: bestPoint, distance: bestDistance};
        }

        function clearDrawSnapPreview() {
            if (drawSnapRadiusCircle) {
                map.removeLayer(drawSnapRadiusCircle);
                drawSnapRadiusCircle = null;
            }
            if (drawSnapTargetLine) {
                map.removeLayer(drawSnapTargetLine);
                drawSnapTargetLine = null;
            }
        }

        function setSnapCircleVisualState(circle, canSnap) {
            if (!circle) {
                return;
            }
            const stroke = canSnap ? '#16a34a' : '#2563eb';
            const fill = canSnap ? '#4ade80' : '#60a5fa';
            circle.setStyle({
                color: stroke,
                fillColor: fill,
                fillOpacity: 0.1,
            });
        }

        function updateDrawSnapPreview(latlng) {
            if (!snappingEnabled || !addObjectMode || freehandMode || !polygonDrawer) {
                clearDrawSnapPreview();
                return;
            }
            if (!drawSnapRadiusCircle) {
                drawSnapRadiusCircle = L.circle(latlng, {
                    radius: snapDistanceMeters,
                    color: '#2563eb',
                    weight: 1,
                    fillColor: '#60a5fa',
                    fillOpacity: 0.08,
                    interactive: false,
                }).addTo(map);
            } else {
                drawSnapRadiusCircle.setLatLng(latlng);
                drawSnapRadiusCircle.setRadius(snapDistanceMeters);
            }
            const nearestAny = findNearestCandidate(latlng);
            if (!nearestAny || nearestAny.distance > snapDistanceMeters) {
                setSnapCircleVisualState(drawSnapRadiusCircle, false);
                if (drawSnapTargetLine) {
                    map.removeLayer(drawSnapTargetLine);
                    drawSnapTargetLine = null;
                }
                return;
            }
            setSnapCircleVisualState(drawSnapRadiusCircle, true);
            const lineLatLngs = [latlng, nearestAny.point];
            if (drawSnapTargetLine) {
                drawSnapTargetLine.setLatLngs(lineLatLngs);
            } else {
                drawSnapTargetLine = L.polyline(lineLatLngs, {
                    color: '#0ea5e9',
                    weight: 2,
                    opacity: 0.9,
                    dashArray: '6 4',
                    interactive: false,
                }).addTo(map);
            }
        }

        function snapLastDrawVertexIfNeeded(event) {
            if (!snappingEnabled || !event || !event.layers || typeof event.layers.eachLayer !== 'function') {
                return;
            }
            let lastMarker = null;
            const markers = [];
            event.layers.eachLayer((layer) => {
                if (layer && typeof layer.getLatLng === 'function') {
                    markers.push(layer);
                }
            });
            if (!markers.length) {
                return;
            }
            lastMarker = markers[markers.length - 1];
            const current = lastMarker.getLatLng();
            const target = findNearestSnapTarget(current);
            if (!target) {
                return;
            }
            lastMarker.setLatLng(target.point);
            if (polygonDrawer && polygonDrawer._poly && typeof polygonDrawer._poly.setLatLngs === 'function') {
                polygonDrawer._poly.setLatLngs(markers.map((marker) => marker.getLatLng()));
            }
            snapDebugEl.textContent = 'Привязка: вершина привязана на ' + target.distance.toFixed(2) + ' м.';
        }

        function applySnappedVertex(marker, snappedPoint) {
            marker.setLatLng(snappedPoint);
            if (marker._origLatLng) {
                marker._origLatLng.lat = snappedPoint.lat;
                marker._origLatLng.lng = snappedPoint.lng;
            }
            if (marker._latlng) {
                marker._latlng.lat = snappedPoint.lat;
                marker._latlng.lng = snappedPoint.lng;
            }
            editableGroup.eachLayer((layer) => {
                if (layer?.editing && typeof layer.editing.updateMarkers === 'function') {
                    try {
                        layer.editing.updateMarkers();
                    } catch (e) {
                        // keep layer refresh best-effort
                    }
                }
                if (typeof layer.redraw === 'function') {
                    layer.redraw();
                }
            });
        }

        function attachPromptSnapHandlers(retryCount = 0) {
            let attachedMarkers = 0;
            let markerGroupsFound = 0;

            function collectMarkerGroups(layer) {
                const groups = [];
                const directGroup = layer?.editing?._markerGroup;
                if (directGroup) {
                    groups.push(directGroup);
                }
                const verticesHandlers = layer?.editing?._verticesHandlers;
                if (Array.isArray(verticesHandlers)) {
                    verticesHandlers.forEach((handler) => {
                        if (handler?._markerGroup) {
                            groups.push(handler._markerGroup);
                        }
                    });
                }
                return groups;
            }

            editableGroup.eachLayer((layer) => {
                if (layer?.editing && typeof layer.editing.enable === 'function') {
                    try {
                        layer.editing.enable();
                    } catch (e) {
                        // keep trying next retries
                    }
                }
                const markerGroups = collectMarkerGroups(layer);
                if (!markerGroups.length) {
                    return;
                }
                markerGroups.forEach((markerGroup) => {
                    markerGroupsFound += 1;
                    markerGroup.eachLayer((marker) => {
                        attachedMarkers += 1;
                        if (marker._promptSnapHandler) {
                            marker.off('dragstart', marker._promptSnapHandler.dragstart);
                            marker.off('drag', marker._promptSnapHandler.drag);
                            marker.off('dragend', marker._promptSnapHandler.dragend);
                            marker.off('mouseup', marker._promptSnapHandler.mouseup);
                            marker.off('touchend', marker._promptSnapHandler.touchend);
                        }
                        const dragStartHandler = (event) => {
                            if (marker._snapRadiusCircle) {
                                map.removeLayer(marker._snapRadiusCircle);
                                marker._snapRadiusCircle = null;
                            }
                            if (marker._snapTargetLine) {
                                map.removeLayer(marker._snapTargetLine);
                                marker._snapTargetLine = null;
                            }
                            if (!snappingEnabled) {
                                return;
                            }
                            marker._snapRadiusCircle = L.circle(event.target.getLatLng(), {
                                radius: snapDistanceMeters,
                                color: '#2563eb',
                                weight: 1,
                                fillColor: '#60a5fa',
                                fillOpacity: 0.08,
                                interactive: false,
                            }).addTo(map);
                        };
                        const dragHandler = (event) => {
                            const center = event.target.getLatLng();
                            if (marker._snapRadiusCircle) {
                                marker._snapRadiusCircle.setLatLng(center);
                                marker._snapRadiusCircle.setRadius(snapDistanceMeters);
                            }
                            if (!snappingEnabled) {
                                marker._lastNearestCandidate = null;
                                if (marker._snapTargetLine) {
                                    map.removeLayer(marker._snapTargetLine);
                                    marker._snapTargetLine = null;
                                }
                                setSnapCircleVisualState(marker._snapRadiusCircle, false);
                                snapDebugEl.textContent = 'Привязка: snapping disabled.';
                                return;
                            }
                            const nearestAny = findNearestCandidate(center);
                            marker._lastNearestCandidate = nearestAny || null;
                            if (!nearestAny) {
                                if (marker._snapTargetLine) {
                                    map.removeLayer(marker._snapTargetLine);
                                    marker._snapTargetLine = null;
                                }
                                setSnapCircleVisualState(marker._snapRadiusCircle, false);
                                snapDebugEl.textContent = 'Привязка: направляющих нет.';
                                return;
                            }
                            const canSnap = nearestAny.distance <= snapDistanceMeters;
                            setSnapCircleVisualState(marker._snapRadiusCircle, canSnap);
                            if (canSnap) {
                                const lineLatLngs = [center, nearestAny.point];
                                if (marker._snapTargetLine) {
                                    marker._snapTargetLine.setLatLngs(lineLatLngs);
                                } else {
                                    marker._snapTargetLine = L.polyline(lineLatLngs, {
                                        color: '#0ea5e9',
                                        weight: 2,
                                        opacity: 0.9,
                                        dashArray: '6 4',
                                        interactive: false,
                                    }).addTo(map);
                                }
                            } else if (marker._snapTargetLine) {
                                map.removeLayer(marker._snapTargetLine);
                                marker._snapTargetLine = null;
                            }
                            snapDebugEl.textContent =
                                'Привязка: ближайшая=' + nearestAny.distance.toFixed(2) +
                                ' м, порог=' + snapDistanceMeters.toFixed(2) + ' м, enabled=' + (snappingEnabled ? 'on' : 'off');
                        };
                        const finalizeSnapAfterDrag = async (event, source = 'dragend') => {
                            const now = Date.now();
                            if (marker._lastSnapFinalizeAt && (now - marker._lastSnapFinalizeAt) < 80) {
                                return;
                            }
                            marker._lastSnapFinalizeAt = now;
                            if (!snappingEnabled) {
                                marker._lastNearestCandidate = null;
                                if (marker._snapTargetLine) {
                                    map.removeLayer(marker._snapTargetLine);
                                    marker._snapTargetLine = null;
                                }
                                snapDebugEl.textContent = 'Привязка: finalize skipped, snapping disabled.';
                                snapDebugFixedEl.textContent = 'Привязка (dragend): snapping disabled.';
                                return;
                            }
                            if (marker._snapRadiusCircle) {
                                map.removeLayer(marker._snapRadiusCircle);
                                marker._snapRadiusCircle = null;
                            }
                            if (marker._snapTargetLine) {
                                map.removeLayer(marker._snapTargetLine);
                                marker._snapTargetLine = null;
                            }
                            const currentLatLng = event.target.getLatLng();
                            const recomputed = findNearestSnapTarget(currentLatLng);
                            const fromDrag = marker._lastNearestCandidate;
                            // Always snap to the nearest candidate at release moment.
                            const target = recomputed;
                            const recomputedAny = findNearestCandidate(currentLatLng);
                            const dragEndDebug =
                                'Привязка: источник=' + source + ', enabled=' + (snappingEnabled ? 'on' : 'off') +
                                ', recomputed=' + (recomputed ? recomputed.distance.toFixed(2) : 'null') +
                                ', recomputedAny=' + (recomputedAny ? recomputedAny.distance.toFixed(2) : 'null') +
                                ', fromDrag=' + (fromDrag ? fromDrag.distance.toFixed(2) : 'null') +
                                ', target=' + (target ? target.distance.toFixed(2) : 'null');
                            snapDebugEl.textContent = dragEndDebug;
                            snapDebugFixedEl.textContent = dragEndDebug;
                            marker._lastNearestCandidate = null;
                            if (!target) {
                                if (isEditing && snappingEnabled) {
                                    statusEl.textContent = 'Кандидат для замыкания не найден (дальше ' + snapDistanceMeters.toFixed(2) + ' м).';
                                }
                                const nearestAny = findNearestCandidate(currentLatLng);
                                snapDebugEl.textContent = nearestAny
                                    ? ('Привязка: без замыкания, ближайшая=' + nearestAny.distance.toFixed(2) + ' м.')
                                    : 'Привязка: без замыкания, направляющих нет.';
                                return;
                            }
                            applySnappedVertex(event.target, target.point);
                            statusEl.textContent = 'Замыкание выполнено: ' + target.distance.toFixed(2) + ' м.';
                            snapDebugEl.textContent = 'Привязка: замыкание выполнено на ' + target.distance.toFixed(2) + ' м.';
                        };
                        const dragEndHandler = async (event) => finalizeSnapAfterDrag(event, 'dragend');
                        const mouseUpHandler = async (event) => {
                            if (!marker._lastNearestCandidate) {
                                return;
                            }
                            await finalizeSnapAfterDrag(event, 'mouseup');
                        };
                        const touchEndHandler = async (event) => {
                            if (!marker._lastNearestCandidate) {
                                return;
                            }
                            await finalizeSnapAfterDrag(event, 'touchend');
                        };
                        marker.on('dragstart', dragStartHandler);
                        marker.on('drag', dragHandler);
                        marker.on('dragend', dragEndHandler);
                        marker.on('mouseup', mouseUpHandler);
                        marker.on('touchend', touchEndHandler);
                        marker._promptSnapHandler = {
                            dragstart: dragStartHandler,
                            drag: dragHandler,
                            dragend: dragEndHandler,
                            mouseup: mouseUpHandler,
                            touchend: touchEndHandler,
                        };
                    });
                });
            });
            snapDebugEl.textContent =
                'Привязка: markerGroups=' + markerGroupsFound +
                ', handlers attached=' + attachedMarkers +
                ', retry=' + retryCount + '.';
            if (!attachedMarkers && retryCount < 40) {
                setTimeout(() => attachPromptSnapHandlers(retryCount + 1), 100);
            }
        }

        function detachPromptSnapHandlers() {
            editableGroup.eachLayer((layer) => {
                const markerGroup = layer?.editing?._markerGroup;
                if (!markerGroup) {
                    return;
                }
                markerGroup.eachLayer((marker) => {
                    if (marker._promptSnapHandler) {
                        marker.off('dragstart', marker._promptSnapHandler.dragstart);
                        marker.off('drag', marker._promptSnapHandler.drag);
                        marker.off('dragend', marker._promptSnapHandler.dragend);
                        marker.off('mouseup', marker._promptSnapHandler.mouseup);
                        marker.off('touchend', marker._promptSnapHandler.touchend);
                        marker._promptSnapHandler = null;
                    }
                    if (marker._snapRadiusCircle) {
                        map.removeLayer(marker._snapRadiusCircle);
                        marker._snapRadiusCircle = null;
                    }
                    if (marker._snapTargetLine) {
                        map.removeLayer(marker._snapTargetLine);
                        marker._snapTargetLine = null;
                    }
                });
            });
        }

        function startSnapBindingLoop() {
            if (snapBindingTimer) {
                clearInterval(snapBindingTimer);
            }
            snapDebugFixedEl.textContent = 'Привязка (dragend): waiting dragend...';
            attachPromptSnapHandlers(0);
            snapBindingTimer = setInterval(() => {
                if (isEditing) {
                    attachPromptSnapHandlers(0);
                }
            }, 400);
        }

        function stopSnapBindingLoop() {
            if (snapBindingTimer) {
                clearInterval(snapBindingTimer);
                snapBindingTimer = null;
            }
            detachPromptSnapHandlers();
        }

        map.on('draw:editstart', () => attachPromptSnapHandlers(0));
        map.on('draw:editvertex', () => attachPromptSnapHandlers(0));

        function renderRelationLayers(layers) {
            clearRelationLayers();
            const parsed = {
                intersects: normalizeGeoJson(layers.intersects),
                touches: normalizeGeoJson(layers.touches),
                nearby: normalizeGeoJson(layers.nearby),
                request_objects: normalizeGeoJson(layers.request_objects),
                dgi_moscow: normalizeGeoJson(layers.dgi_moscow),
                dgi_private: normalizeGeoJson(layers.dgi_private),
                odh: normalizeGeoJson(layers.odh),
                ozn: normalizeGeoJson(layers.ozn),
                renew: normalizeGeoJson(layers.renew),
                recaps: normalizeGeoJson(layers.recaps),
                oozt: normalizeGeoJson(layers.oozt),
                rzd: normalizeGeoJson(layers.rzd),
            };
            parsed.odh = filterOutSelectedRootid(parsed.odh, selectedRootid);
            parsed.ozn = filterOutSelectedRootid(parsed.ozn, selectedRootid);

            const mergedAdjacentDt = mergeAdjacentDtPassportsGeoJson(parsed.intersects, parsed.touches, parsed.nearby);
            if (mergedAdjacentDt) {
                L.geoJSON(mergedAdjacentDt, {
                    style: {color: '#0284c7', weight: 2, fillColor: '#38bdf8', fillOpacity: 0.35},
                    onEachFeature: (feature, layer) => {
                        layer.bindPopup(buildObjectPopup(feature.properties || {}));
                    }
                }).addTo(relationAdjacentDtPassportsGroup);
            }
            if (parsed.request_objects) {
                L.geoJSON(parsed.request_objects, {
                    style: {color: '#c026d3', weight: 2, fillColor: '#f0abfc', fillOpacity: 0.28},
                    onEachFeature: (feature, layer) => {
                        layer.bindPopup(buildObjectPopup(feature.properties || {}));
                    },
                }).addTo(relationRequestObjectsGroup);
            }
            renderReferenceSignalLayers(parsed.dgi_moscow, parsed.dgi_private, parsed.odh, parsed.ozn);
            renderRecapsLayer(parsed.recaps);
            renderRenewLayer(parsed.renew);
            addSignalTapeLayer(ooztSignalGroup, parsed.oozt, 'ООЗТ');
            addSignalTapeLayer(rzdSignalGroup, parsed.rzd, 'РЖД');
            refreshObjectLayersControl();
            rebuildSnapGuideLines();
            if (isEditing) {
                attachPromptSnapHandlers(0);
            }
        }

        async function checkRelations() {
            const geometry = buildCurrentGeometry();
            if (!geometry) {
                updateRelationsButtonState();
                statusEl.textContent = 'Сначала добавьте хотя бы один полигон.';
                return;
            }

            checkRelationsButton.disabled = true;
            statusEl.textContent = 'Ищем смежные паспорта ДТ (пересечение, общая граница, до 10 м)...';
            showDbLoadingModal();
            try {
                const response = await fetch(cfg.urls.checkRelations, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || ''
                    },
                    body: JSON.stringify(
                        (() => {
                            const payload = {geometry, source_label: selectedSourceLabel};
                            const entryRid = String(effectiveEntryRequestId || '').trim();
                            if (entryRid) {
                                payload.request_id = entryRid;
                            }
                            return payload;
                        })()
                    )
                });
                const data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.error || 'Ошибка запроса.');
                }
                renderRelationLayers(data.layers || {});
                statusEl.textContent = 'Границы объектов и площадь обновлены.';
            } catch (error) {
                statusEl.textContent = error.message || 'Не удалось проверить связанные объекты.';
            } finally {
                hideDbLoadingModal();
                updateRelationsButtonState();
            }
        }

        checkRelationsButton.addEventListener('click', () => {
            checkRelations();
        });

        function closeCheckDgiModal() {
            if (checkDgiModal) {
                checkDgiModal.style.display = 'none';
            }
        }

        function showCheckDgiModal(data) {
            if (!checkDgiModal || !checkDgiModalBody) {
                return;
            }
            if (data.intersects) {
                checkDgiModalBody.innerHTML =
                    '<div>ДГИ (г. Москва и Нет данных): ' + data.percent_moscow + '% от площади</div>' +
                    '<div>ДГИ (Частная собственность): ' + data.percent_private + '% от площади</div>';
            } else {
                checkDgiModalBody.textContent = 'Пересечений с объектами ДГИ не обнаружено.';
            }
            checkDgiModal.style.display = 'flex';
        }

        async function checkDgiIntersections() {
            const geometry = buildCurrentGeometry();
            if (!geometry) {
                statusEl.textContent = 'Сначала добавьте хотя бы один полигон.';
                return;
            }
            checkDgiIntersectionsButton.disabled = true;
            statusEl.textContent = 'Проверяем пересечение с объектами ДГИ...';
            try {
                const response = await fetch(cfg.urls.checkDgi, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || ''
                    },
                    body: JSON.stringify({geometry})
                });
                const data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.error || 'Ошибка проверки пересечений с ДГИ.');
                }
                showCheckDgiModal(data);
                statusEl.textContent = 'Проверка пересечений с ДГИ завершена.';
            } catch (error) {
                statusEl.textContent = error.message || 'Не удалось проверить пересечения с ДГИ.';
            } finally {
                checkDgiIntersectionsButton.disabled = false;
            }
        }

        if (checkDgiModalClose) {
            checkDgiModalClose.addEventListener('click', closeCheckDgiModal);
        }

        checkDgiIntersectionsButton.addEventListener('click', () => {
            checkDgiIntersections();
        });

        function openAutoRemoveModal() {
            autoRemoveModalErrorEl.textContent = '';
            autoRemoveModal.style.display = 'flex';
        }

        function closeAutoRemoveModal() {
            autoRemoveModal.style.display = 'none';
            autoRemoveModalErrorEl.textContent = '';
        }

        function getAutoRemoveSources() {
            const sources = [];
            if (autoRemoveDtCheckbox.checked) {
                sources.push('dt');
            }
            if (autoRemoveOdhCheckbox.checked) {
                sources.push('odh');
            }
            if (autoRemoveOznCheckbox.checked) {
                sources.push('ozn');
            }
            if (autoRemoveDgiMoscowCheckbox.checked) {
                sources.push('dgi_moscow');
            }
            if (autoRemoveDgiPrivateCheckbox.checked) {
                sources.push('dgi_private');
            }
            if (autoRemoveOoztCheckbox.checked) {
                sources.push('oozt');
            }
            if (autoRemoveRzdCheckbox.checked) {
                sources.push('rzd');
            }
            return sources;
        }

        function applyGeometryToEditableGroup(geometry) {
            const editableGeo = toEditableFeatureCollection(geometry);
            if (!editableGeo || !editableGeo.features.length) {
                return false;
            }
            editableGroup.clearLayers();
            const editableLayer = L.geoJSON(editableGeo, {
                style: {color: '#ff0000', weight: 3, fillOpacity: 0.25}
            });
            editableLayer.eachLayer((layer) => {
                bindEditablePolygonPopup(
                    layer,
                    buildObjectPopup(
                        {},
                        'Новый объект',
                        'Новый объект'
                    )
                );
                editableGroup.addLayer(layer);
            });
            if (editToolbar) {
                editToolbar.disable();
                editToolbar = new L.EditToolbar.Edit(map, {featureGroup: editableGroup});
                editToolbar.enable();
            }
            rebuildSnapGuideLines();
            startSnapBindingLoop();
            updateRelationsButtonState();
            return true;
        }

        async function autoRemoveIntersections() {
            const geometry = buildCurrentGeometry();
            if (!geometry) {
                statusEl.textContent = 'Сначала добавьте хотя бы один полигон.';
                return;
            }
            const selectedSources = getAutoRemoveSources();
            if (!selectedSources.length) {
                autoRemoveModalErrorEl.textContent = 'Выберите хотя бы один источник.';
                return;
            }
            autoRemoveIntersectionsButton.disabled = true;
            autoRemoveModalSubmit.disabled = true;
            autoRemoveModalErrorEl.textContent = '';
            statusEl.textContent = 'Удаляем пересечения с выбранными слоями...';
            try {
                const response = await fetch(cfg.urls.autoRemove, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || ''
                    },
                    body: JSON.stringify({
                        geometry,
                        selected_sources: selectedSources,
                        source_label: selectedSourceLabel
                    })
                });
                const data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось удалить пересечения.');
                }
                if (!data.geometry) {
                    throw new Error('После удаления пересечений не осталось площади объекта.');
                }
                if (!applyGeometryToEditableGroup(data.geometry)) {
                    throw new Error('Не удалось применить обновлённую геометрию.');
                }
                closeAutoRemoveModal();
                statusEl.textContent = 'Пересечения автоматически удалены.';
                await checkRelations();
            } catch (error) {
                autoRemoveModalErrorEl.textContent = error.message || 'Не удалось удалить пересечения.';
                statusEl.textContent = error.message || 'Не удалось удалить пересечения.';
            } finally {
                autoRemoveIntersectionsButton.disabled = !isEditing;
                autoRemoveModalSubmit.disabled = false;
            }
        }

        autoRemoveIntersectionsButton.addEventListener('click', () => {
            openAutoRemoveModal();
        });
        autoRemoveModalCancel.addEventListener('click', () => {
            closeAutoRemoveModal();
        });
        autoRemoveModalSubmit.addEventListener('click', () => {
            autoRemoveIntersections();
        });

        function closeDeletePolygonModal() {
            deletePolygonModal.style.display = 'none';
            pendingDeleteLayer = null;
        }

        function deletePendingPolygon() {
            if (!pendingDeleteLayer) {
                closeDeletePolygonModal();
                return;
            }
            if (editableGroup.hasLayer(pendingDeleteLayer)) {
                editableGroup.removeLayer(pendingDeleteLayer);
            }
            if (editToolbar) {
                editToolbar.disable();
                editToolbar = new L.EditToolbar.Edit(map, {featureGroup: editableGroup});
                if (isEditing && editableGroup.getLayers().length) {
                    editToolbar.enable();
                }
            }
            closeDeletePolygonModal();
            clearDrawSnapPreview();
            rebuildSnapGuideLines();
            refreshObjectLayersControl();
            updateRelationsButtonState();
            statusEl.textContent = 'Полигон удалён.';
            if (editableGroup.getLayers().length) {
                checkRelations();
            }
        }

        deletePolygonModalCancel.addEventListener('click', () => {
            closeDeletePolygonModal();
        });
        deletePolygonModalSubmit.addEventListener('click', () => {
            deletePendingPolygon();
        });

        function setEditMode(enabled) {
            isEditing = enabled;
            mapEl.classList.toggle('edit-mode', enabled);
            editableAreaInfoEl.style.display = enabled ? 'block' : 'none';
            if (!enabled) {
                editableAreaInfoEl.textContent = 'Площадь редактируемого объекта: -';
            }
            cancelEditButton.style.display = enabled ? 'inline-block' : 'none';
            saveButton.style.display = enabled ? 'inline-block' : 'none';
            autoRemoveIntersectionsButton.disabled = !enabled;
            editButton.textContent = enabled ? 'Режим редактирования включён' : 'Начать редактирование';
            addPolygonButton.disabled = !enabled;
            cutPolygonButton.disabled = !enabled;
            if (!enabled) {
                drawModeToggleLocked = false;
                addObjectMode = false;
                cutObjectMode = false;
                addPolygonButton.textContent = 'Добавить полигон';
                addPolygonButton.classList.remove('map-toolbar-btn--danger');
                addPolygonButton.classList.add('map-toolbar-btn--accent');
                cutPolygonButton.textContent = 'Обрезать полигон';
                cutPolygonButton.classList.remove('map-toolbar-btn--danger');
                cutPolygonButton.classList.add('map-toolbar-btn--accent');
            }
            drawModeFreehandToggle.disabled = !enabled || drawModeToggleLocked;
            drawModeFreehandToggle.closest('.snap-switch')?.classList.toggle('snap-switch--locked', drawModeToggleLocked);
            statusEl.textContent = enabled
                ? 'Режим редактирования включён. Можно добавлять и изменять полигоны.'
                : 'Режим редактирования выключен.';
            updateEditToolbarVisibility();
        }

        function setAddObjectButtonMode(enabled) {
            addObjectMode = enabled;
            addPolygonButton.textContent = enabled ? 'Отменить добавление' : 'Добавить полигон';
            addPolygonButton.classList.toggle('map-toolbar-btn--danger', enabled);
            addPolygonButton.classList.toggle('map-toolbar-btn--accent', !enabled);
            if (!enabled) {
                clearDrawSnapPreview();
            }
        }

        function setCutObjectButtonMode(enabled) {
            cutObjectMode = enabled;
            cutPolygonButton.textContent = enabled ? 'Отменить обрезку' : 'Обрезать полигон';
            cutPolygonButton.classList.toggle('map-toolbar-btn--danger', enabled);
            cutPolygonButton.classList.toggle('map-toolbar-btn--accent', !enabled);
            if (!enabled) {
                clearDrawSnapPreview();
            }
        }

        function cancelCutMode() {
            if (cutDrawer) {
                cutDrawer.disable();
                cutDrawer = null;
            }
            setCutObjectButtonMode(false);
            clearDrawSnapPreview();
        }

        function openCutModeModal() {
            cutModeModal.style.display = 'flex';
        }

        function closeCutModeModal() {
            cutModeModal.style.display = 'none';
        }

        function startCutMode(mode) {
            const normalizedMode = mode === 'line' ? 'line' : 'polygon';
            setCutObjectButtonMode(true);
            if (editToolbar) {
                editToolbar.disable();
            }
            if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
            }
            if (normalizedMode === 'line') {
                cutDrawer = new L.Draw.Polyline(map, {
                    shapeOptions: {color: '#ef4444', weight: 3, opacity: 0.9}
                });
                statusEl.textContent = 'Нарисуйте линию для обрезки.';
            } else {
                cutDrawer = new L.Draw.Polygon(map, {
                    allowIntersection: false,
                    showArea: false,
                    shapeOptions: {color: '#ef4444', weight: 3, fillOpacity: 0.15}
                });
                statusEl.textContent = 'Нарисуйте полигон для вырезания.';
            }
            cutDrawer.enable();
        }

        function cancelAddObjectMode() {
            if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
            }
            clearStartVertexFlag();
            stopFreehandMode();
            setAddObjectButtonMode(false);
            clearDrawSnapPreview();
            if (isEditing) {
                statusEl.textContent = 'Добавление полигона отменено.';
            }
        }

        async function applyCutGeometry(cutterLayer, cutterType) {
            const geometry = buildCurrentGeometry();
            const cutterGeometry = cutterLayer?.toGeoJSON?.()?.geometry;
            if (!geometry || !cutterGeometry) {
                statusEl.textContent = 'Не удалось выполнить обрезку: нет геометрии.';
                return;
            }
            statusEl.textContent = 'Обрезаем редактируемый полигон...';
            try {
                const response = await fetch(cfg.urls.cutGeometry, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || ''
                    },
                    body: JSON.stringify({
                        geometry,
                        cutter_geometry: cutterGeometry,
                        cutter_type: cutterType
                    })
                });
                const data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось обрезать полигон.');
                }
                if (!data.geometry) {
                    throw new Error('После обрезки геометрия не содержит площади.');
                }
                if (!applyGeometryToEditableGroup(data.geometry)) {
                    throw new Error('Не удалось применить результат обрезки.');
                }
                statusEl.textContent = 'Обрезка выполнена.';
                await checkRelations();
            } catch (error) {
                statusEl.textContent = error.message || 'Не удалось обрезать полигон.';
            }
        }

        function stopFreehandMode() {
            freehandMode = false;
            freehandDrawing = false;
            freehandLatLngs = [];
            if (freehandPreviewLine) {
                map.removeLayer(freehandPreviewLine);
                freehandPreviewLine = null;
            }
            map.dragging.enable();
            map.getContainer().style.cursor = '';
            if (isEditing) {
                drawModeToggleLocked = false;
                drawModeFreehandToggle.disabled = false;
                drawModeFreehandToggle.closest('.snap-switch')?.classList.remove('snap-switch--locked');
            }
        }

        function finishCreatedPolygon(layer) {
            editableGroup.addLayer(layer);
            bindEditablePolygonPopup(
                layer,
                buildObjectPopup(
                    {},
                    'Новый объект',
                    'Новый объект'
                )
            );
            if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
            }
            clearStartVertexFlag();
            if (freehandMode || drawModeFreehandToggle.checked) {
                drawModeFreehandToggle.checked = false;
                stopFreehandMode();
            }
            setAddObjectButtonMode(false);
            drawModeToggleLocked = false;
            drawModeFreehandToggle.disabled = !isEditing;
            drawModeFreehandToggle.closest('.snap-switch')?.classList.remove('snap-switch--locked');
            if (isEditing) {
                editToolbar = new L.EditToolbar.Edit(map, {featureGroup: editableGroup});
                editToolbar.enable();
            }
            startSnapBindingLoop();
            statusEl.textContent = 'Полигон добавлен. Можно продолжать редактирование.';
            updateRelationsButtonState();
            checkRelations();
        }

        editButton.addEventListener('click', () => {
            if (isEditing) {
                return;
            }
            if (drawControl) {
                map.removeControl(drawControl);
            }
            drawControl = new L.Control.Draw({
                edit: {
                    featureGroup: editableGroup,
                    remove: false
                },
                draw: false
            });
            map.addControl(drawControl);
            if (editToolbar) {
                editToolbar.disable();
            }
            editToolbar = new L.EditToolbar.Edit(map, {featureGroup: editableGroup});
            editToolbar.enable();
            setEditMode(true);
            rebuildSnapGuideLines();
            startSnapBindingLoop();
            exportLinksEl.innerHTML = '';
        });

        cancelEditButton.addEventListener('click', () => {
            cancelCommentPointMode();
            cancelAddObjectMode();
            cancelCutMode();
            if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
            }
            stopFreehandMode();
            if (editToolbar) {
                editToolbar.disable();
            }
            stopSnapBindingLoop();
            clearStartVertexFlag();
            setEditMode(false);
        });

        addPolygonButton.addEventListener('click', () => {
            if (!isEditing) {
                statusEl.textContent = 'Сначала включите режим редактирования.';
                return;
            }
            if (cutObjectMode) {
                cancelCutMode();
            }
            if (addObjectMode) {
                cancelAddObjectMode();
                return;
            }
            drawModeToggleLocked = true;
            drawModeFreehandToggle.disabled = true;
            drawModeFreehandToggle.closest('.snap-switch')?.classList.add('snap-switch--locked');
            setAddObjectButtonMode(true);
            if (editToolbar) {
                editToolbar.disable();
            }
            if (drawModeFreehandToggle.checked) {
                if (polygonDrawer) {
                    polygonDrawer.disable();
                    polygonDrawer = null;
                }
                clearStartVertexFlag();
                freehandMode = true;
                map.getContainer().style.cursor = 'crosshair';
                statusEl.textContent = 'Режим кисти: зажмите левую кнопку мыши и обведите контур.';
                return;
            }
            stopFreehandMode();
            if (polygonDrawer) {
                polygonDrawer.disable();
            }
            polygonDrawer = new L.Draw.Polygon(map, {
                allowIntersection: false,
                showArea: true,
                shapeOptions: {
                    color: '#ff0000',
                    weight: 3,
                    fillOpacity: 0.25,
                },
            });
            polygonDrawer.enable();
            clearStartVertexFlag();
            statusEl.textContent = 'Добавьте новый полигон на карту.';
        });

        cutPolygonButton.addEventListener('click', () => {
            if (!isEditing) {
                statusEl.textContent = 'Сначала включите режим редактирования.';
                return;
            }
            if (!buildCurrentGeometry()) {
                statusEl.textContent = 'Нет редактируемой геометрии для обрезки.';
                return;
            }
            if (addObjectMode) {
                cancelAddObjectMode();
            }
            if (cutObjectMode) {
                cancelCutMode();
                statusEl.textContent = 'Обрезка отменена.';
                return;
            }
            openCutModeModal();
        });
        cutModeModalCancel.addEventListener('click', () => {
            closeCutModeModal();
        });
        cutModePolygonButton.addEventListener('click', () => {
            closeCutModeModal();
            startCutMode('polygon');
        });
        cutModeLineButton.addEventListener('click', () => {
            closeCutModeModal();
            startCutMode('line');
        });
        drawModeFreehandToggle.addEventListener('change', () => {
            if (!drawModeFreehandToggle.checked) {
                stopFreehandMode();
                clearStartVertexFlag();
            } else if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
                clearStartVertexFlag();
            }
        });

        map.on(L.Draw.Event.CREATED, (event) => {
            if (cutObjectMode) {
                const cutterType = event.layerType === 'polyline' ? 'line' : 'polygon';
                cancelCutMode();
                applyCutGeometry(event.layer, cutterType);
                return;
            }
            if (event.layerType !== 'polygon') {
                return;
            }
            finishCreatedPolygon(event.layer);
        });
        map.on(L.Draw.Event.DRAWVERTEX, (event) => {
            snapLastDrawVertexIfNeeded(event);
            updateStartVertexFlag();
        });
        map.on('draw:drawstart', () => {
            clearStartVertexFlag();
        });
        map.on('draw:drawstop', () => {
            clearStartVertexFlag();
        });

        map.on('mousedown', (event) => {
            if (!freehandMode || !isEditing) {
                return;
            }
            freehandDrawing = true;
            freehandLatLngs = [event.latlng];
            if (freehandPreviewLine) {
                map.removeLayer(freehandPreviewLine);
            }
            freehandPreviewLine = L.polyline(freehandLatLngs, {
                color: '#ef4444',
                weight: 3,
                opacity: 0.85,
                interactive: false,
            }).addTo(map);
            map.dragging.disable();
        });
        map.on('mousemove', (event) => {
            if (isEditing && addObjectMode && !freehandMode && polygonDrawer) {
                updateDrawSnapPreview(event.latlng);
            } else {
                clearDrawSnapPreview();
            }
            if (!freehandMode || !freehandDrawing) {
                return;
            }
            freehandLatLngs.push(event.latlng);
            if (freehandPreviewLine) {
                freehandPreviewLine.setLatLngs(freehandLatLngs);
            }
        });
        map.on('mouseup', () => {
            if (!freehandMode || !freehandDrawing) {
                return;
            }
            freehandDrawing = false;
            map.dragging.enable();
            if (freehandPreviewLine) {
                map.removeLayer(freehandPreviewLine);
                freehandPreviewLine = null;
            }
            if (freehandLatLngs.length < 3) {
                freehandLatLngs = [];
                statusEl.textContent = 'Для кисти нужно провести контур минимум из 3 точек.';
                return;
            }
            const polygon = L.polygon(freehandLatLngs, {
                color: '#ff0000',
                weight: 3,
                fillOpacity: 0.25,
            });
            freehandLatLngs = [];
            finishCreatedPolygon(polygon);
        });

        map.on(L.Draw.Event.EDITED, () => {
            statusEl.textContent = 'Геометрия обновлена. Пересчитываем связанные объекты...';
            updateRelationsButtonState();
            checkRelations();
        });

        function buildExportGeometry(editedGeojson) {
            if (!editedGeojson.features.length) {
                return null;
            }
            if (editedGeojson.features.length === 1) {
                return editedGeojson.features[0].geometry;
            }
            const allPolygons = editedGeojson.features.every((f) => f.geometry && f.geometry.type === 'Polygon');
            if (allPolygons) {
                return {
                    type: 'MultiPolygon',
                    coordinates: editedGeojson.features.map((f) => f.geometry.coordinates)
                };
            }
            return {
                type: 'GeometryCollection',
                geometries: editedGeojson.features.map((f) => f.geometry).filter(Boolean)
            };
        }

        function getSaveTargetSourceLabel() {
            if (saveTargetOznRadio && saveTargetOznRadio.checked) {
                return 'ОЗН';
            }
            if (saveTargetOdhRadio && saveTargetOdhRadio.checked) {
                return 'ОДХ';
            }
            return 'ДТ';
        }

        function openSaveModal(opts) {
            opts = opts || {};
            newObjectNameInput.value = '';
            newObjectRequestIdInput.value = (effectiveEntryRequestId || '').trim();
            saveModalErrorEl.textContent = '';
            if (saveModalDgiWarning) {
                const warningText = PV.buildDgiExportWarningText(opts.warningPercent);
                if (warningText) {
                    saveModalDgiWarning.textContent = warningText;
                    saveModalDgiWarning.style.display = 'block';
                } else {
                    saveModalDgiWarning.textContent = '';
                    saveModalDgiWarning.style.display = 'none';
                }
            }
            if (selectedSourceLabel === 'ОЗН') {
                if (saveTargetOznRadio) {
                    saveTargetOznRadio.checked = true;
                }
            } else if (selectedSourceLabel === 'ОДХ') {
                if (saveTargetOdhRadio) {
                    saveTargetOdhRadio.checked = true;
                }
            } else if (saveTargetDtRadio) {
                saveTargetDtRadio.checked = true;
            }
            saveModal.style.display = 'flex';
            setTimeout(() => {
                if (newObjectNameInput.value) {
                    newObjectRequestIdInput.focus();
                } else {
                    newObjectNameInput.focus();
                }
            }, 0);
        }

        function closeSaveModal() {
            saveModal.style.display = 'none';
        }

        async function saveObjectToDb(geometryToSave, name, requestId, sourceLabelForSave) {
            const savePayload = {
                geometry: geometryToSave,
                name: name,
                request_id: requestId,
                source_label: sourceLabelForSave || selectedSourceLabel,
            };
            if (pendingDgiApprove) {
                savePayload.dgi_aprove = pendingDgiApprove;
            }
            const response = await fetch(cfg.urls.saveNewObject, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCookie('csrftoken') || ''
                },
                body: JSON.stringify(savePayload)
            });
            const result = await response.json();
            if (!response.ok || !result.ok) {
                throw new Error(result.error || 'Не удалось сохранить объект.');
            }
            return result;
        }

        async function exportObjectFiles(geometryToExport, properties) {
            const response = await fetch(cfg.urls.exportGeometry, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCookie('csrftoken') || ''
                },
                body: JSON.stringify({
                    geometry: geometryToExport,
                    properties: properties || {}
                })
            });
            const result = await response.json();
            if (!response.ok || !result.ok) {
                throw new Error(result.error || 'Не удалось сформировать файлы.');
            }
            return result;
        }

        let lastPdfExportContext = null;
        let pdfExportInProgress = false;

        function stripPopupButtons(html) {
            return String(html || '').replace(/<button[\s\S]*?<\/button>/gi, '');
        }

        function mergePdfIntersectFeatureCollections(passportFc, dgiFc, odhFc) {
            const out = [];
            const passportKey = (props) => {
                const r = String(props?.rootid ?? '').trim();
                const q = String(props?.request_id ?? '').trim();
                return 'p:' + r + ':' + q;
            };
            const seenPassportLike = new Set();
            const pushFc = (fc) => {
                const n = normalizeGeoJson(fc);
                if (!n || !Array.isArray(n.features)) {
                    return;
                }
                n.features.forEach((f) => {
                    const props = f?.properties || {};
                    const src = String(props.source ?? '').trim();
                    if (src !== 'ДГИ' && src !== 'ОДХ') {
                        out.push(f);
                        const k = passportKey(props);
                        if (k && k !== 'p::' && k !== 'p:null:null') {
                            seenPassportLike.add(k);
                        }
                        return;
                    }
                    if (src === 'ОДХ' || src === 'ОЗН') {
                        const k = passportKey(props);
                        if (k && seenPassportLike.has(k)) {
                            return;
                        }
                    }
                    out.push(f);
                });
            };
            pushFc(passportFc);
            pushFc(dgiFc);
            pushFc(odhFc);
            return {type: 'FeatureCollection', features: out};
        }

        async function fetchIntersectsLayerForPdfExport(geometry) {
            const ctxSl =
                lastPdfExportContext && lastPdfExportContext.source_label
                    ? lastPdfExportContext.source_label
                    : selectedSourceLabel;
            const pdfBody = {geometry, source_label: ctxSl};
            const entryRid = String(effectiveEntryRequestId || '').trim();
            if (entryRid) {
                pdfBody.request_id = entryRid;
            }
            const response = await fetch(cfg.urls.checkRelations, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCookie('csrftoken') || '',
                },
                body: JSON.stringify(pdfBody),
            });
            const data = await response.json();
            if (!response.ok || !data.ok) {
                throw new Error(data.error || 'Не удалось получить пересечения для PDF.');
            }
            return mergePdfIntersectFeatureCollections(
                data.layers?.intersects,
                data.layers?.dgi_intersects,
                data.layers?.odh_intersects
            );
        }

        function waitForVisibleTilesLoaded(mapElement, timeoutMs) {
            const started = Date.now();
            return new Promise((resolve) => {
                const tick = () => {
                    const tiles = mapElement.querySelectorAll('img.leaflet-tile');
                    let pending = 0;
                    tiles.forEach((img) => {
                        if (!img.complete || img.naturalWidth === 0) {
                            pending += 1;
                        }
                    });
                    if (pending === 0 || Date.now() - started > timeoutMs) {
                        requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
                        return;
                    }
                    setTimeout(tick, 90);
                };
                setTimeout(tick, 100);
            });
        }

        function leafletRedrawAllVectorLayers(leafletMap) {
            const visit = (layer) => {
                if (!layer) {
                    return;
                }
                if (typeof layer.eachLayer === 'function') {
                    layer.eachLayer(visit);
                    return;
                }
                if (typeof layer.redraw === 'function') {
                    try {
                        layer.redraw();
                    } catch (e) {
                        /* ignore */
                    }
                }
            };
            leafletMap.eachLayer(visit);
        }

        async function captureLeafletMapPngCanvas() {
            const mapDiv = map.getContainer();
            clearDrawSnapPreview();
            let vertexFlagWasOnMap = false;
            if (startVertexFlagMarker && map.hasLayer(startVertexFlagMarker)) {
                vertexFlagWasOnMap = true;
                map.removeLayer(startVertexFlagMarker);
            }
            mapDiv.classList.add('pass-viewer-pdf-capture');
            const controls = mapDiv.querySelector('.leaflet-control-container');
            const prevCtrl = controls ? controls.style.display : '';
            if (controls) {
                controls.style.display = 'none';
            }
            const dragWas = map.dragging && map.dragging.enabled();
            if (dragWas) {
                map.dragging.disable();
            }
            const wheelWas = map.scrollWheelZoom && map.scrollWheelZoom.enabled();
            if (wheelWas) {
                map.scrollWheelZoom.disable();
            }
            let canvas;
            try {
                map.invalidateSize(false);
                mapDiv.scrollTop = 0;
                mapDiv.scrollLeft = 0;
                await waitForVisibleTilesLoaded(mapDiv, 3200);
                await new Promise((r) => setTimeout(r, 80));
                leafletRedrawAllVectorLayers(map);
                await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(() => setTimeout(r, 40))));
                const w = mapDiv.clientWidth;
                const h = mapDiv.clientHeight;
                canvas = await html2canvas(mapDiv, {
                    useCORS: true,
                    allowTaint: false,
                    scale: 1,
                    logging: false,
                    backgroundColor: '#f1f5f9',
                    foreignObjectRendering: false,
                    x: 0,
                    y: 0,
                    width: w,
                    height: h,
                    windowWidth: w,
                    windowHeight: h,
                });
            } finally {
                mapDiv.classList.remove('pass-viewer-pdf-capture');
                if (controls) {
                    controls.style.display = prevCtrl;
                }
                if (dragWas) {
                    map.dragging.enable();
                }
                if (wheelWas) {
                    map.scrollWheelZoom.enable();
                }
                if (vertexFlagWasOnMap && startVertexFlagMarker) {
                    startVertexFlagMarker.addTo(map);
                }
            }
            return canvas;
        }

        function addMapCanvasAsFullFirstPdfPage(pdf, canvas) {
            /* Ожидается первая страница A4 в альбомной ориентации (как широкий экран с картой). */
            const pageW = pdf.internal.pageSize.getWidth();
            const pageH = pdf.internal.pageSize.getHeight();
            const marginMm = 5;
            const innerW = pageW - 2 * marginMm;
            const innerH = pageH - 2 * marginMm;
            const imgRatio = canvas.width / canvas.height;
            const boxRatio = innerW / innerH;
            let drawW;
            let drawH;
            let offX;
            let offY;
            if (imgRatio > boxRatio) {
                drawH = innerH;
                drawW = drawH * imgRatio;
                offX = marginMm + (innerW - drawW) / 2;
                offY = marginMm;
            } else {
                drawW = innerW;
                drawH = drawW / imgRatio;
                offX = marginMm;
                offY = marginMm + (innerH - drawH) / 2;
            }
            pdf.addImage(canvas.toDataURL('image/png', 0.93), 'PNG', offX, offY, drawW, drawH);
        }

        function addCanvasToPdfPaginated(pdf, canvas, marginMm) {
            const pageW = pdf.internal.pageSize.getWidth();
            const pageH = pdf.internal.pageSize.getHeight();
            const imgWmm = pageW - 2 * marginMm;
            const pxPerMm = canvas.width / imgWmm;
            const pageContentHmm = pageH - 2 * marginMm;
            let offsetY = 0;
            let first = true;
            const eps = 0.5;
            while (offsetY < canvas.height - eps) {
                if (!first) {
                    pdf.addPage('a4', 'p');
                }
                first = false;
                const sliceHeightPx = Math.min(canvas.height - offsetY, Math.ceil(pageContentHmm * pxPerMm));
                if (sliceHeightPx <= eps) {
                    break;
                }
                const slice = document.createElement('canvas');
                slice.width = canvas.width;
                slice.height = sliceHeightPx;
                slice.getContext('2d').drawImage(canvas, 0, offsetY, canvas.width, sliceHeightPx, 0, 0, canvas.width, sliceHeightPx);
                const sliceHmm = sliceHeightPx / pxPerMm;
                pdf.addImage(slice.toDataURL('image/png'), 'PNG', marginMm, marginMm, imgWmm, sliceHmm);
                offsetY += sliceHeightPx;
            }
        }

        async function runPdfExportDownload() {
            if (pdfExportInProgress) {
                return;
            }
            if (typeof html2canvas === 'undefined' || !window.jspdf?.jsPDF) {
                window.alert('Библиотеки PDF не загрузились. Обновите страницу.');
                return;
            }
            const ctx = lastPdfExportContext;
            if (!ctx || !ctx.geometry) {
                window.alert('Нет геометрии для PDF. Сначала выполните выгрузку файлов.');
                return;
            }
            pdfExportInProgress = true;
            const prevStatus = statusEl.textContent;
            let wrap = null;
            try {
                statusEl.textContent = 'Готовим PDF: запрос пересечений...';
                const intersectsGeo = await fetchIntersectsLayerForPdfExport(ctx.geometry);
                statusEl.textContent = 'Готовим PDF: снимок карты...';
                const mapCanvas = await captureLeafletMapPngCanvas();
                const pdf = new window.jspdf.jsPDF({unit: 'mm', format: 'a4', orientation: 'landscape'});
                addMapCanvasAsFullFirstPdfPage(pdf, mapCanvas);

                const features =
                    intersectsGeo && intersectsGeo.type === 'FeatureCollection' && Array.isArray(intersectsGeo.features)
                        ? intersectsGeo.features
                        : [];
                wrap = document.createElement('div');
                Object.assign(wrap.style, {
                    position: 'fixed',
                    left: '-12000px',
                    top: '0',
                    width: '794px',
                    background: '#ffffff',
                    color: '#0f172a',
                    fontFamily: 'system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
                    padding: '24px',
                    boxSizing: 'border-box',
                });
                const title = document.createElement('h1');
                title.textContent = 'Пересечения (паспорта, ДГИ, ОДХ)';
                title.style.cssText = 'margin:0 0 12px;font-size:18px;font-weight:700;';
                wrap.appendChild(title);
                const sub = document.createElement('div');
                sub.style.cssText = 'margin-bottom:14px;font-size:12px;color:#475569;line-height:1.4;';
                sub.textContent =
                    'Содержимое всплывающих окон для паспортов ДТ/ОДХ и пересекающихся объектов ДГИ и ОДХ (по данным PostGIS).';
                wrap.appendChild(sub);
                if (!features.length) {
                    const p = document.createElement('p');
                    p.style.margin = '0';
                    p.style.fontSize = '13px';
                    p.textContent = 'Пересечений с паспортами и объектами ДГИ/ОДХ не найдено.';
                    wrap.appendChild(p);
                } else {
                    features.forEach((feature, idx) => {
                        const props = feature?.properties || {};
                        const rawHtml = buildPdfIntersectionPopupHtml(props);
                        const box = document.createElement('div');
                        box.style.cssText =
                            'border:1px solid #cbd5e1;border-radius:8px;padding:12px;margin-bottom:12px;background:#f8fafc;font-size:13px;line-height:1.45;';
                        const head = document.createElement('div');
                        head.style.cssText = 'font-weight:600;margin-bottom:8px;color:#0369a1;';
                        head.textContent = 'Пересечение ' + (idx + 1);
                        box.appendChild(head);
                        const inner = document.createElement('div');
                        inner.innerHTML = stripPopupButtons(rawHtml);
                        box.appendChild(inner);
                        wrap.appendChild(box);
                    });
                }
                document.body.appendChild(wrap);
                statusEl.textContent = 'Готовим PDF: список пересечений...';
                await new Promise((r) => requestAnimationFrame(() => r()));
                await new Promise((r) => setTimeout(r, 80));
                const listCanvas = await html2canvas(wrap, {
                    scale: 1.75,
                    useCORS: true,
                    allowTaint: true,
                    logging: false,
                    backgroundColor: '#ffffff',
                });
                pdf.addPage('a4', 'p');
                addCanvasToPdfPaginated(pdf, listCanvas, 10);
                const fname =
                    'export_map_' +
                    String(ctx.requestId || 'object').replace(/\W+/g, '_') +
                    '_' +
                    new Date().toISOString().slice(0, 10) +
                    '.pdf';
                pdf.save(fname);
                statusEl.textContent = 'PDF сохранён: ' + fname;
            } catch (err) {
                window.alert(err.message || 'Не удалось сформировать PDF.');
                statusEl.textContent = prevStatus;
            } finally {
                if (wrap && wrap.parentNode) {
                    wrap.parentNode.removeChild(wrap);
                }
                pdfExportInProgress = false;
            }
        }

        function bindPdfExportLink() {
            const a = exportLinksEl.querySelector('[data-export-pdf-link="1"]');
            if (!a) {
                return;
            }
            a.addEventListener('click', (event) => {
                event.preventDefault();
                void runPdfExportDownload();
            });
        }

        async function runSaveAndExportFlow() {
            if (!isEditing) {
                statusEl.textContent = 'Сначала включите режим редактирования.';
                return;
            }
            const editedGeojson = editableGroup.toGeoJSON();
            if (!editedGeojson.features.length) {
                statusEl.textContent = 'Нет геометрии для сохранения.';
                return;
            }
            const geometryToSave = buildExportGeometry(editedGeojson);
            if (!geometryToSave) {
                statusEl.textContent = 'Не удалось собрать геометрию для сохранения.';
                return;
            }

            const name = (newObjectNameInput.value || '').trim();
            const requestId = (newObjectRequestIdInput.value || '').trim();
            if (!requestId) {
                saveModalErrorEl.textContent = 'Укажите номер заявки.';
                return;
            }
            if (!/^\d+$/.test(requestId)) {
                saveModalErrorEl.textContent = 'Номер заявки должен содержать только цифры.';
                return;
            }
            saveModalErrorEl.textContent = '';

            saveModalSubmit.disabled = true;
            saveButton.disabled = true;
            const saveTargetLabel = getSaveTargetSourceLabel();
            statusEl.textContent = 'Сохраняем объект в базе...';
            try {
                const saveResult = await saveObjectToDb(geometryToSave, name, requestId, saveTargetLabel);
                statusEl.textContent = 'Объект сохранён в базе. Формируем файлы...';
                const exportResult = await exportObjectFiles(geometryToSave, {
                    name: name,
                    OwnerLegalPersonId: saveResult.owner_id,
                    request_id: requestId
                });
                closeSaveModal();
                pendingDgiApprove = null;
                const savedTableLabel = saveTargetLabel === 'ОЗН'
                    ? 'ОО'
                    : (saveTargetLabel === 'ОДХ' ? 'ОДХ' : 'ДТ');
                statusEl.textContent =
                    'Объект сохранён в ' +
                    savedTableLabel +
                    '. Идентификатор владельца: ' +
                    saveResult.owner_id +
                    '. Файлы сформированы.';
                lastPdfExportContext = {
                    geometry: geometryToSave,
                    requestId: requestId,
                    source_label: saveTargetLabel,
                };
                exportLinksEl.innerHTML =
                    '<a class="button-link" href="' + exportResult.geojson_url + '" download>Скачать GeoJSON</a> ' +
                    '<a class="button-link" href="' + exportResult.shapefile_url + '">Скачать SHP (ZIP)</a> ' +
                    '<a class="button-link" href="#" data-export-pdf-link="1">Скачать PDF (карта и пересечения)</a>';
                bindPdfExportLink();
            } catch (error) {
                saveModalErrorEl.textContent = error.message || 'Ошибка сохранения объекта.';
            } finally {
                saveModalSubmit.disabled = false;
                saveButton.disabled = false;
            }
        }

        saveModalCancel.addEventListener('click', () => {
            closeSaveModal();
        });
        saveModalSubmit.addEventListener('click', () => {
            runSaveAndExportFlow();
        });
        saveModal.addEventListener('click', (event) => {
            if (event.target === saveModal) {
                closeSaveModal();
            }
        });

        PV.initDgiExportGateFlow({
            exportButton: saveButton,
            checkDgiUrl: cfg.urls.checkDgi,
            getCookie: getCookie,
            getGeometry: () => {
                if (!isEditing) {
                    statusEl.textContent = 'Сначала включите режим редактирования.';
                    return null;
                }
                const editedGeojson = editableGroup.toGeoJSON();
                if (!editedGeojson.features.length) {
                    statusEl.textContent = 'Нет геометрии для выгрузки.';
                    return null;
                }
                return buildExportGeometry(editedGeojson);
            },
            openSaveModal: openSaveModal,
            dgiConfirmModal: dgiExportConfirmModal,
            dgiConfirmAgree: dgiExportConfirmAgree,
            dgiConfirmBack: dgiExportConfirmBack,
            setPendingApprove: (value) => {
                pendingDgiApprove = value;
            },
        });

        async function submitCommentPointModal() {
            const latlng = pendingCommentLatLng;
            const text = (commentPointText && commentPointText.value ? commentPointText.value : '').trim();
            if (!latlng) {
                if (commentPointModalError) {
                    commentPointModalError.textContent = 'Сначала выберите точку на карте.';
                }
                return;
            }
            if (!text) {
                if (commentPointModalError) {
                    commentPointModalError.textContent = 'Введите комментарий.';
                }
                return;
            }
            const rid = (effectiveEntryRequestId || '').trim();
            if (!rid) {
                if (commentPointModalError) {
                    commentPointModalError.textContent = 'Нет номера заявки.';
                }
                return;
            }
            if (commentPointModalError) {
                commentPointModalError.textContent = '';
            }
            if (commentPointModalSubmit) {
                commentPointModalSubmit.disabled = true;
            }
            try {
                const res = await fetch(saveCommentPointUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    credentials: 'same-origin',
                    body: JSON.stringify({
                        request_id: rid,
                        comment: text,
                        lng: latlng.lng,
                        lat: latlng.lat,
                    }),
                });
                const data = await res.json();
                if (!res.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось сохранить точку.');
                }
                if (data.feature) {
                    const gj = data.feature;
                    L.geoJSON(
                        { type: 'FeatureCollection', features: [gj] },
                        {
                            pointToLayer: (feature, latlngMarker) =>
                                L.circleMarker(latlngMarker, {
                                    radius: 8,
                                    color: '#6d28d9',
                                    weight: 2,
                                    fillColor: '#a78bfa',
                                    fillOpacity: 0.9,
                                    opacity: 0.95,
                                }),
                            onEachFeature: (feature, layer) => {
                                bindCommentPointLayer(layer, feature);
                            },
                        }
                    ).addTo(commentPointsGroup);
                }
                refreshObjectLayersControl();
                closeCommentPointModal();
                cancelCommentPointMode();
                statusEl.textContent = 'Точка комментария сохранена.';
            } catch (err) {
                if (commentPointModalError) {
                    commentPointModalError.textContent = err.message || 'Ошибка сохранения.';
                }
            } finally {
                if (commentPointModalSubmit) {
                    commentPointModalSubmit.disabled = false;
                }
            }
        }

        if (addCommentPointButton) {
            addCommentPointButton.addEventListener('click', () => {
                const rid = (effectiveEntryRequestId || '').trim();
                if (!rid) {
                    statusEl.textContent = 'Нет номера заявки для привязки комментария.';
                    return;
                }
                if (commentPointMode) {
                    cancelCommentPointMode();
                    statusEl.textContent = 'Режим добавления точки выключен.';
                    return;
                }
                if (addObjectMode) {
                    cancelAddObjectMode();
                }
                if (cutObjectMode) {
                    cancelCutMode();
                }
                if (freehandMode || freehandDrawing) {
                    stopFreehandMode();
                }
                setCommentPointMode(true);
                statusEl.textContent = 'Кликните по карте, чтобы поставить точку комментария.';
            });
        }
        if (commentPointModalCancel) {
            commentPointModalCancel.addEventListener('click', () => {
                closeCommentPointModal();
                cancelCommentPointMode();
            });
        }
        if (commentPointModalSubmit) {
            commentPointModalSubmit.addEventListener('click', () => {
                submitCommentPointModal();
            });
        }
        if (commentPointModal) {
            commentPointModal.addEventListener('click', (event) => {
                if (event.target === commentPointModal) {
                    closeCommentPointModal();
                    cancelCommentPointMode();
                }
            });
        }

        if (clearMapButton) {
            clearMapButton.addEventListener('click', () => {
                clearMapDisplayedUserDrawings();
            });
        }

        loadCommentPointsForMap();

        addPolygonButton.disabled = true;
        updateRelationsButtonState();

})();

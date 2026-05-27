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
    const filterPassportOnlyGeoJson = PV.filterPassportOnlyGeoJson.bind(PV);
    const escapeHtml = PV.escapeHtml.bind(PV);
    const pickPopupProperty = PV.pickPopupProperty.bind(PV);
    const formatPopupDateToDay = PV.formatPopupDateToDay.bind(PV);
    const buildPopupMetaFieldsHtml = PV.buildPopupMetaFieldsHtml.bind(PV);
    const calculateGeometryAreaSqMeters = PV.calculateGeometryAreaSqMeters.bind(PV);
    const buildObjectPopup = PV.buildObjectPopup.bind(PV);
    const buildPdfIntersectionPopupHtml = PV.buildPdfIntersectionPopupHtml.bind(PV);

const map = L.map('map', {maxZoom: 30}).setView([55.75, 37.61], 12);

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

        PV.attachBasemapControl(map);

        map.attributionControl.setPrefix(
            '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺'
        );

        
        const selectedGeometryRaw = JSON.parse(document.getElementById('selected-geometry-data').textContent);
        const selectedGeometry = typeof selectedGeometryRaw === 'string' ? JSON.parse(selectedGeometryRaw) : selectedGeometryRaw;
        const requestId = cfg.requestId || "";
        const objectName = cfg.objectName || "";
        const selectedSourceLabel = cfg.selectedSourceLabel || "ДТ";
        const selectedRootid = cfg.selectedRootid || "";
        const selectedRowCtid = cfg.selectedRowCtid || "";

        const statusEl = document.getElementById('edit-status');
        const editableAreaInfoEl = document.getElementById('editable-area-info');
        const exportLinksEl = document.getElementById('export-links');
        const addDossierButton = document.getElementById('add-dossier-btn');
        const checkRelationsButton = document.getElementById('check-relations-btn');
        const checkDgiIntersectionsButton = document.getElementById('check-dgi-intersections-btn');
        const autoRemoveIntersectionsButton = document.getElementById('auto-remove-intersections-btn');
        const addCommentPointButton = document.getElementById('add-comment-point-btn');
        const commentPointModal = document.getElementById('comment-point-modal');
        const commentPointText = document.getElementById('comment-point-text');
        const commentPointModalError = document.getElementById('comment-point-modal-error');
        const commentPointModalCancel = document.getElementById('comment-point-modal-cancel');
        const commentPointModalSubmit = document.getElementById('comment-point-modal-submit');
        const listCommentPointsUrl = cfg.urls.listCommentPoints;
        const saveCommentPointUrl = cfg.urls.saveCommentPoint;
        const deleteCommentPointUrl = cfg.urls.deleteCommentPoint;
        const cancelDrawButton = document.getElementById('cancel-draw-btn');
        const saveDossierButton = document.getElementById('save-dossier-btn');
        const drawModeFreehandToggle = document.getElementById('draw-mode-freehand');
        const snapToggle = document.getElementById('snap-toggle');
        const snapDebugEl = {set textContent(_) {}};
        const saveModal = document.getElementById('save-modal');
        const saveModalCancel = document.getElementById('save-modal-cancel');
        const saveModalSubmit = document.getElementById('save-modal-submit');
        const newRecapIdInput = document.getElementById('new-recap-id');
        const initialRecapIdFromEntry = cfg.initialRecapId || "";
        const saveModalErrorEl = document.getElementById('save-modal-error');
        const autoRemoveModal = document.getElementById('auto-remove-modal');
        const autoRemoveModalCancel = document.getElementById('auto-remove-modal-cancel');
        const autoRemoveModalSubmit = document.getElementById('auto-remove-modal-submit');
        const autoRemoveModalErrorEl = document.getElementById('auto-remove-modal-error');
        const autoRemoveDtCheckbox = document.getElementById('auto-remove-dt');
        const autoRemoveOdhCheckbox = document.getElementById('auto-remove-odh');
        const autoRemoveOznCheckbox = document.getElementById('auto-remove-ozn');
        const autoRemoveDgiCheckbox = document.getElementById('auto-remove-dgi');
        const autoRemoveRenewCheckbox = document.getElementById('auto-remove-renew');
        const autoRemoveTopCheckbox = document.getElementById('auto-remove-top');
        const autoRemoveOoztCheckbox = document.getElementById('auto-remove-oozt');
        const autoRemoveRzdCheckbox = document.getElementById('auto-remove-rzd');
        const autoRemoveRequestsCheckbox = document.getElementById('auto-remove-requests');
        const autoRemoveNoLayersEl = document.getElementById('auto-remove-no-layers');
        const dbLoadingModal = document.getElementById('db-loading-modal');
        const deletePolygonModal = document.getElementById('delete-polygon-modal');
        const deletePolygonModalCancel = document.getElementById('delete-polygon-modal-cancel');
        const deletePolygonModalSubmit = document.getElementById('delete-polygon-modal-submit');
        const mapEl = document.getElementById('map');

        const selectedGroup = new L.FeatureGroup().addTo(map);
        const selectedLayer = L.geoJSON(selectedGeometry, {
            style: {color: '#ef4444', weight: 3, fillOpacity: 0.2}
        }).addTo(selectedGroup);
        const dossierGroup = new L.FeatureGroup().addTo(map);
        const adjacentDtPassportsGroup = new L.FeatureGroup().addTo(map);
        const requestObjectsGroup = L.featureGroup().addTo(map);
        const dgiSignalGroup = L.featureGroup().addTo(map);
        const odhSignalGroup = L.featureGroup().addTo(map);
        const oznSignalGroup = L.featureGroup().addTo(map);
        const renewGroup = L.featureGroup().addTo(map);
        const topSignalGroup = L.featureGroup().addTo(map);
        const ooztSignalGroup = L.featureGroup().addTo(map);
        const rzdSignalGroup = L.featureGroup().addTo(map);
        const recapsGroup = L.featureGroup().addTo(map);
        const commentPointsGroup = L.featureGroup().addTo(map);
        const layerPanelEl = document.getElementById('layer-management-panel');
        const layerPanelCheckboxes = layerPanelEl
            ? Array.from(layerPanelEl.querySelectorAll('input[data-layer-key]'))
            : [];
        const layerPanelGroupCheckboxes = layerPanelEl
            ? Array.from(layerPanelEl.querySelectorAll('input[data-layer-group]'))
            : [];
        const bounds = selectedLayer.getBounds();
        if (bounds.isValid()) {
            map.fitBounds(bounds.pad(0.4));
        }

        let polygonDrawer = null;
        let freehandMode = false;
        let freehandDrawing = false;
        let freehandLatLngs = [];
        let freehandPreviewLine = null;
        let snappingEnabled = false;
        let snapDistanceMeters = 5;
        let snapGuideLines = [];
        let drawSnapRadiusCircle = null;
        let drawSnapTargetLine = null;
        let startVertexFlagMarker = null;
        let pendingDeleteLayer = null;
        let areaInfoVisible = false;
        let commentPointMode = false;
        let pendingCommentLatLng = null;
        let commentPickCaptureLayer = null;
        let dbLoadingCounter = 0;

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
                if (freehandDrawing || polygonDrawer) {
                    return;
                }
                pendingCommentLatLng = e.latlng;
                setCommentPointMode(false);
                openCommentPointModal();
            });
        }

        async function loadCommentPointsForMap() {
            const rid = (requestId || '').trim();
            commentPointsGroup.clearLayers();
            if (addCommentPointButton) {
                if (!rid) {
                    addCommentPointButton.disabled = true;
                    addCommentPointButton.title = 'Нет номера заявки в контексте страницы.';
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

        
        
        function filterByRequestedName(geojsonObject) {
            const geo = normalizeGeoJson(geojsonObject);
            if (!geo || geo.type !== 'FeatureCollection' || !Array.isArray(geo.features)) {
                return geo;
            }
            const requestedName = (objectName || '').trim().toLowerCase();
            if (!requestedName) {
                return geo;
            }
            return {
                ...geo,
                features: geo.features.filter((feature) => {
                    const featureName = String(feature?.properties?.name || '').trim().toLowerCase();
                    return featureName !== requestedName;
                }),
            };
        }

        
        function buildEditableDeletePopupHtml(baseHtml) {
            return (
                baseHtml +
                '<div style="margin-top:10px; padding-top:8px; border-top:1px solid #e5e7eb;">' +
                '<button type="button" class="popup-delete-polygon-btn map-toolbar-btn map-toolbar-btn--danger" style="font-size:12px; padding:6px 10px;">🗑 Удалить полигон</button>' +
                '</div>'
            );
        }

        function bindDossierPolygonPopup(layer) {
            const displayName = String(objectName || 'Новый полигон');
            const baseHtml =
                '<div style="min-width: 220px;">' +
                '<div><strong>Название:</strong> ' + displayName + '</div>' +
                '</div>';
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
            if (freehandMode || !polygonDrawer) {
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
            selected: dossierGroup,
            dt: adjacentDtPassportsGroup,
            oo: oznSignalGroup,
            odh: odhSignalGroup,
            top: topSignalGroup,
            dgi: dgiSignalGroup,
            renew: renewGroup,
            oozt: ooztSignalGroup,
            rzd: rzdSignalGroup,
            requests: requestObjectsGroup,
            recaps: recapsGroup,
            comments: commentPointsGroup,
        };
        const layerGroups = {
            municipal: ['selected', 'dt', 'oo', 'odh', 'top'],
            requests: ['requests', 'recaps', 'comments'],
            external: ['dgi', 'renew', 'oozt', 'rzd'],
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
                selected: countGroupFeatures(dossierGroup),
                dt: countGroupFeatures(adjacentDtPassportsGroup),
                oo: countGroupFeatures(oznSignalGroup),
                odh: countGroupFeatures(odhSignalGroup),
                top: countGroupFeatures(topSignalGroup),
                dgi: countGroupFeatures(dgiSignalGroup),
                renew: countGroupFeatures(renewGroup),
                oozt: countGroupFeatures(ooztSignalGroup),
                rzd: countGroupFeatures(rzdSignalGroup),
                requests: countGroupFeatures(requestObjectsGroup),
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
                        const sobstvRr = feature?.properties?.sobstv_rr ?? '-';
                        const descrText = String(descr ?? '').trim();
                        const addressText = String(address ?? '').trim();
                        const vriText = String(vri ?? '').trim();
                        const sobstvRrText = String(sobstvRr ?? '').trim();
                        layer.bindPopup(
                            '<div style="min-width: 220px;">' +
                            '<div><strong>ДГИ</strong></div>' +
                            (!descrText || ['null', 'none', '-'].includes(descrText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Кадастровый номер:</strong> ' + escapeHtml(descr) + '</div>')) +
                            (!addressText || ['null', 'none', '-'].includes(addressText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Адрес:</strong> ' + escapeHtml(address) + '</div>')) +
                            (!vriText || ['null', 'none', '-'].includes(vriText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Назначение:</strong> ' + escapeHtml(vri) + '</div>')) +
                            (!sobstvRrText || ['null', 'none', '-'].includes(sobstvRrText.toLowerCase()) ? '' : ('<div style="margin-top: 6px;"><strong>Собственник:</strong> ' + escapeHtml(sobstvRr) + '</div>')) +
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
        
        function renderReferenceSignalLayers(dgiGeo, odhGeo, oznGeo) {
            addSignalTapeLayer(dgiSignalGroup, dgiGeo, 'ДГИ');
            addSignalTapeLayer(odhSignalGroup, filterPassportOnlyGeoJson(odhGeo), 'ОДХ');
            addSignalTapeLayer(oznSignalGroup, filterPassportOnlyGeoJson(oznGeo), 'ОЗН');
        }
        function renderRenewLayer(renewGeo) {
            addSignalTapeLayer(renewGroup, renewGeo, 'Реновация');
        }

        function renderTopLayer(topGeo) {
            topSignalGroup.clearLayers();
            const geo = normalizeGeoJson(filterPassportOnlyGeoJson(topGeo));
            if (!geo) {
                return;
            }
            L.geoJSON(geo, {
                style: {color: '#ea580c', weight: 2, fillColor: '#fb923c', fillOpacity: 0.25},
                onEachFeature: (feature, layer) => {
                    layer.bindPopup(buildObjectPopup(feature.properties || {}));
                }
            }).addTo(topSignalGroup);
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

        function collectSnapGuideLines(geojsonObject, output) {
            const normalized = normalizeGeoJson(geojsonObject);
            if (!normalized) {
                return;
            }
            let features = [];
            if (normalized.type === 'FeatureCollection') {
                features = normalized.features || [];
            } else if (normalized.type === 'Feature') {
                features = [normalized];
            } else if (normalized.type) {
                // Raw geometry object (Polygon/MultiPolygon/etc.)
                features = [{type: 'Feature', geometry: normalized, properties: {}}];
            }
            const addRing = (ring) => {
                if (!ring || ring.length < 2) {
                    return;
                }
                output.push(ring.map((c) => L.latLng(c[1], c[0])));
            };
            const collectGeometry = (geometry) => {
                if (!geometry) return;
                if (geometry.type === 'Polygon') geometry.coordinates.forEach(addRing);
                else if (geometry.type === 'MultiPolygon') geometry.coordinates.forEach((poly) => poly.forEach(addRing));
                else if (geometry.type === 'LineString') addRing(geometry.coordinates);
                else if (geometry.type === 'MultiLineString') geometry.coordinates.forEach(addRing);
                else if (geometry.type === 'GeometryCollection') (geometry.geometries || []).forEach(collectGeometry);
            };
            features.forEach((f) => collectGeometry(f.geometry));
        }

        function rebuildSnapGuideLines() {
            snapGuideLines = [];
            collectSnapGuideLines(selectedGeometry, snapGuideLines);
            [dossierGroup, adjacentDtPassportsGroup, requestObjectsGroup, dgiSignalGroup, odhSignalGroup, oznSignalGroup, topSignalGroup, renewGroup, ooztSignalGroup, rzdSignalGroup, recapsGroup].forEach((group) => {
                group.eachLayer((layer) => {
                    if (typeof layer.toGeoJSON === 'function') collectSnapGuideLines(layer.toGeoJSON(), snapGuideLines);
                });
            });
        }

        function nearestPointOnSegment(pointLatLng, aLatLng, bLatLng) {
            const p = L.CRS.EPSG3857.project(pointLatLng);
            const a = L.CRS.EPSG3857.project(aLatLng);
            const b = L.CRS.EPSG3857.project(bLatLng);
            const vx = b.x - a.x;
            const vy = b.y - a.y;
            const len2 = vx * vx + vy * vy;
            if (!len2) return aLatLng;
            let t = ((p.x - a.x) * vx + (p.y - a.y) * vy) / len2;
            t = Math.max(0, Math.min(1, t));
            return L.CRS.EPSG3857.unproject(L.point(a.x + t * vx, a.y + t * vy));
        }

        function findNearestCandidate(latlng) {
            if (!snapGuideLines.length) return null;
            let bestPoint = null;
            let bestDistance = Infinity;
            snapGuideLines.forEach((lineLatLngs) => {
                if (!lineLatLngs || !lineLatLngs.length) return;
                for (let i = 0; i < lineLatLngs.length; i += 1) {
                    const d = map.distance(latlng, lineLatLngs[i]);
                    if (d < bestDistance) { bestDistance = d; bestPoint = lineLatLngs[i]; }
                }
                if (lineLatLngs.length >= 2) {
                    for (let i = 0; i < lineLatLngs.length - 1; i += 1) {
                        const c = nearestPointOnSegment(latlng, lineLatLngs[i], lineLatLngs[i + 1]);
                        const d = map.distance(latlng, c);
                        if (d < bestDistance) { bestDistance = d; bestPoint = c; }
                    }
                }
            });
            return bestPoint ? {point: bestPoint, distance: bestDistance} : null;
        }

        function findNearestSnapTarget(latlng) {
            if (!snappingEnabled || !snapGuideLines.length) return null;
            const nearest = findNearestCandidate(latlng);
            if (!nearest || nearest.distance > snapDistanceMeters) return null;
            return nearest;
        }

        function clearDrawSnapPreview() {
            if (drawSnapRadiusCircle) { map.removeLayer(drawSnapRadiusCircle); drawSnapRadiusCircle = null; }
            if (drawSnapTargetLine) { map.removeLayer(drawSnapTargetLine); drawSnapTargetLine = null; }
        }

        function updateDrawSnapPreview(latlng) {
            if (!snappingEnabled || !polygonDrawer || freehandMode) { clearDrawSnapPreview(); return; }
            if (!drawSnapRadiusCircle) {
                drawSnapRadiusCircle = L.circle(latlng, {
                    radius: snapDistanceMeters, color: '#2563eb', weight: 1, fillColor: '#60a5fa', fillOpacity: 0.08, interactive: false
                }).addTo(map);
            } else {
                drawSnapRadiusCircle.setLatLng(latlng);
                drawSnapRadiusCircle.setRadius(snapDistanceMeters);
            }
            const nearest = findNearestCandidate(latlng);
            if (!nearest || nearest.distance > snapDistanceMeters) {
                if (drawSnapTargetLine) { map.removeLayer(drawSnapTargetLine); drawSnapTargetLine = null; }
                return;
            }
            const line = [latlng, nearest.point];
            if (drawSnapTargetLine) drawSnapTargetLine.setLatLngs(line);
            else {
                drawSnapTargetLine = L.polyline(line, {color: '#0ea5e9', weight: 2, opacity: 0.9, dashArray: '6 4', interactive: false}).addTo(map);
            }
        }

        function snapLastDrawVertexIfNeeded(event) {
            if (!snappingEnabled || !event || !event.layers || typeof event.layers.eachLayer !== 'function') return;
            const markers = [];
            event.layers.eachLayer((layer) => { if (layer && typeof layer.getLatLng === 'function') markers.push(layer); });
            if (!markers.length) return;
            const lastMarker = markers[markers.length - 1];
            const target = findNearestSnapTarget(lastMarker.getLatLng());
            if (!target) return;
            lastMarker.setLatLng(target.point);
            if (polygonDrawer && polygonDrawer._poly && typeof polygonDrawer._poly.setLatLngs === 'function') {
                polygonDrawer._poly.setLatLngs(markers.map((m) => m.getLatLng()));
            }
            snapDebugEl.textContent = 'Snap debug: вершина привязана на ' + target.distance.toFixed(2) + ' м.';
        }

        function ensureSelectedRequestObject(geojsonObject) {
            const selectedRequestId = String(requestId || '').trim();
            if (!selectedRequestId || !selectedGeometry) {
                return normalizeGeoJson(geojsonObject);
            }
            const normalized = normalizeGeoJson(geojsonObject);
            const selectedFeature = {
                type: 'Feature',
                properties: {
                    rootid: '-',
                    name: objectName || '-',
                    request_id: selectedRequestId,
                },
                geometry: selectedGeometry,
            };
            if (!normalized || normalized.type !== 'FeatureCollection' || !Array.isArray(normalized.features)) {
                return {type: 'FeatureCollection', features: [selectedFeature]};
            }
            const hasSelected = normalized.features.some((feature) => {
                const featureRequestId = String(feature?.properties?.request_id || '').trim();
                return featureRequestId === selectedRequestId;
            });
            if (hasSelected) {
                return normalized;
            }
            return {
                ...normalized,
                features: [...normalized.features, selectedFeature],
            };
        }

        function excludeSelectedRootidFromCollection(geojson) {
            const selectedRootidText = (selectedRootid || '').trim();
            if (!geojson || geojson.type !== 'FeatureCollection' || !Array.isArray(geojson.features)) {
                return geojson;
            }
            if (!selectedRootidText) {
                return geojson;
            }
            return {
                ...geojson,
                features: geojson.features.filter((feature) => {
                    const rootid = String(feature?.properties?.rootid ?? '').trim();
                    return rootid !== selectedRootidText;
                }),
            };
        }

        function renderExternalReferenceLayers(layers) {
            const parsed = {
                dgi: normalizeGeoJson(layers.dgi),
                odh: normalizeGeoJson(layers.odh),
                ozn: normalizeGeoJson(layers.ozn),
                renew: normalizeGeoJson(layers.renew),
                recaps: normalizeGeoJson(layers.recaps),
                oozt: normalizeGeoJson(layers.oozt),
                rzd: normalizeGeoJson(layers.rzd),
                top: normalizeGeoJson(layers.top),
            };
            parsed.odh = excludeSelectedRootidFromCollection(parsed.odh);
            parsed.ozn = excludeSelectedRootidFromCollection(parsed.ozn);
            renderReferenceSignalLayers(parsed.dgi, parsed.odh, parsed.ozn);
            renderRecapsLayer(parsed.recaps);
            renderRenewLayer(parsed.renew);
            addSignalTapeLayer(ooztSignalGroup, parsed.oozt, 'ООЗТ');
            addSignalTapeLayer(rzdSignalGroup, parsed.rzd, 'РЖД');
            renderTopLayer(parsed.top);
        }

        function renderAdjacentAndRequestLayers(intersects, touches, nearby, requestObjects) {
            adjacentDtPassportsGroup.clearLayers();
            requestObjectsGroup.clearLayers();
            let parsedIntersects = filterByRequestedName(intersects);
            let parsedTouches = filterByRequestedName(touches);
            let parsedNearby = filterByRequestedName(nearby);
            let parsedRequestObjects = ensureSelectedRequestObject(requestObjects);
            parsedIntersects = excludeSelectedRootidFromCollection(parsedIntersects);
            parsedTouches = excludeSelectedRootidFromCollection(parsedTouches);
            parsedNearby = excludeSelectedRootidFromCollection(parsedNearby);
            parsedRequestObjects = excludeSelectedRootidFromCollection(parsedRequestObjects);
            const mergedAdjacentDt = mergeAdjacentDtPassportsGeoJson(parsedIntersects, parsedTouches, parsedNearby);
            if (mergedAdjacentDt) {
                L.geoJSON(mergedAdjacentDt, {
                    style: {color: '#0284c7', weight: 2, fillColor: '#38bdf8', fillOpacity: 0.35},
                    onEachFeature: (feature, layer) => layer.bindPopup(buildObjectPopup(feature.properties || {})),
                }).addTo(adjacentDtPassportsGroup);
            }
            if (parsedRequestObjects) {
                L.geoJSON(parsedRequestObjects, {
                    style: {color: '#c026d3', weight: 2, fillColor: '#f0abfc', fillOpacity: 0.28},
                    onEachFeature: (feature, layer) => layer.bindPopup(buildObjectPopup(feature.properties || {})),
                }).addTo(requestObjectsGroup);
            }
        }

        function renderRelationLayers(layers) {
            renderExternalReferenceLayers(layers);
            renderAdjacentAndRequestLayers(
                layers.intersects,
                layers.touches,
                layers.nearby,
                layers.request_objects,
            );
            rebuildSnapGuideLines();
            refreshObjectLayersControl();
            updateEditableAreaInfo();
        }

        renderExternalReferenceLayers({
            dgi: parseGeometryData('dgi-geometry-data'),
            odh: parseGeometryData('odh-geometry-data'),
            ozn: parseGeometryData('ozn-geometry-data'),
            renew: parseGeometryData('renew-geometry-data'),
            recaps: parseGeometryData('recaps-geometry-data'),
            oozt: parseGeometryData('oozt-geometry-data'),
            rzd: parseGeometryData('rzd-geometry-data'),
            top: parseGeometryData('top-geometry-data'),
        });
        renderAdjacentAndRequestLayers(
            parseGeometryData('intersects-geometry-data'),
            parseGeometryData('touches-geometry-data'),
            parseGeometryData('nearby-geometry-data'),
            parseGeometryData('request-objects-geometry-data'),
        );
        rebuildSnapGuideLines();
        refreshObjectLayersControl();
        updateEditableAreaInfo();

        function hasDossierPolygon() {
            const dossierGeo = dossierGroup.toGeoJSON();
            return Array.isArray(dossierGeo?.features) && dossierGeo.features.length > 0;
        }

        function buildCurrentGeometry() {
            const geo = dossierGroup.toGeoJSON();
            if (geo.features && geo.features.length) {
                return geo.features[0].geometry;
            }
            return selectedGeometry;
        }
        function updateEditableAreaInfo() {
            if (!areaInfoVisible) {
                editableAreaInfoEl.style.display = 'none';
                editableAreaInfoEl.textContent = 'Площадь редактируемого объекта: -';
                return;
            }
            editableAreaInfoEl.style.display = 'block';
            const area = calculateGeometryAreaSqMeters(buildCurrentGeometry());
            editableAreaInfoEl.textContent = Number.isFinite(area) && area > 0
                ? ('Площадь редактируемого объекта: ' + area.toFixed(2) + ' м² (' + (area / 10000).toFixed(2) + ' га)')
                : 'Площадь редактируемого объекта: -';
        }

        function openDrawMode() {
            areaInfoVisible = true;
            if (polygonDrawer) {
                polygonDrawer.disable();
            }
            clearStartVertexFlag();
            stopFreehandMode();
            if (drawModeFreehandToggle.checked) {
                polygonDrawer = null;
                freehandMode = true;
                map.getContainer().style.cursor = 'crosshair';
                cancelDrawButton.style.display = 'inline-block';
                saveDossierButton.style.display = 'inline-block';
                exportLinksEl.innerHTML = '';
                statusEl.textContent = 'Режим кисти: зажмите левую кнопку мыши и обведите контур.';
                rebuildSnapGuideLines();
                return;
            }
            polygonDrawer = new L.Draw.Polygon(map, {
                allowIntersection: false,
                showArea: true,
                shapeOptions: {
                    color: '#2563eb',
                    weight: 3,
                    fillOpacity: 0.2,
                },
            });
            polygonDrawer.enable();
            clearStartVertexFlag();
            cancelDrawButton.style.display = 'inline-block';
            saveDossierButton.style.display = 'inline-block';
            exportLinksEl.innerHTML = '';
            statusEl.textContent = 'Нарисуйте новый полигон досъёма.';
            rebuildSnapGuideLines();
        }

        addDossierButton.addEventListener('click', openDrawMode);

        cancelDrawButton.addEventListener('click', () => {
            cancelCommentPointMode();
            if (polygonDrawer) {
                polygonDrawer.disable();
                polygonDrawer = null;
            }
            clearStartVertexFlag();
            stopFreehandMode();
            clearDrawSnapPreview();
            dossierGroup.clearLayers();
            statusEl.textContent = 'Добавление досъёма отменено.';
            areaInfoVisible = false;
            updateEditableAreaInfo();
        });

        map.on(L.Draw.Event.CREATED, (event) => {
            if (event.layerType !== 'polygon') {
                return;
            }
            dossierGroup.clearLayers();
            bindDossierPolygonPopup(event.layer);
            dossierGroup.addLayer(event.layer);
            clearStartVertexFlag();
            if (freehandMode || drawModeFreehandToggle.checked) {
                drawModeFreehandToggle.checked = false;
                stopFreehandMode();
            }
            clearDrawSnapPreview();
            statusEl.textContent = 'Полигон досъёма добавлен. Можно сохранить.';
            rebuildSnapGuideLines();
            refreshObjectLayersControl();
            updateEditableAreaInfo();
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
        }

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

        snapToggle.addEventListener('change', () => {
            snappingEnabled = snapToggle.checked;
            if (snappingEnabled) {
                const raw = window.prompt('Введите радиус прилипания в метрах:', String(snapDistanceMeters));
                if (raw === null) {
                    snappingEnabled = false;
                    snapToggle.checked = false;
                    statusEl.textContent = 'Прилипание не включено: радиус не задан.';
                    return;
                }
                const parsed = Number(raw.replace(',', '.').trim());
                if (!Number.isFinite(parsed) || parsed <= 0) {
                    snappingEnabled = false;
                    snapToggle.checked = false;
                    statusEl.textContent = 'Прилипание не включено: неверный радиус.';
                    return;
                }
                snapDistanceMeters = parsed;
                rebuildSnapGuideLines();
                statusEl.textContent = 'Прилипание включено. Радиус: ' + snapDistanceMeters.toFixed(2) + ' м.';
            } else {
                clearDrawSnapPreview();
                statusEl.textContent = 'Прилипание выключено.';
            }
        });

        map.on('mousedown', (event) => {
            if (!freehandMode) return;
            freehandDrawing = true;
            freehandLatLngs = [event.latlng];
            if (freehandPreviewLine) map.removeLayer(freehandPreviewLine);
            freehandPreviewLine = L.polyline(freehandLatLngs, {color: '#2563eb', weight: 3, opacity: 0.85, interactive: false}).addTo(map);
            map.dragging.disable();
        });
        map.on('mousemove', (event) => {
            if (polygonDrawer && !freehandMode) updateDrawSnapPreview(event.latlng);
            else clearDrawSnapPreview();
            if (!freehandMode || !freehandDrawing) return;
            freehandLatLngs.push(event.latlng);
            if (freehandPreviewLine) freehandPreviewLine.setLatLngs(freehandLatLngs);
        });
        map.on('mouseup', () => {
            if (!freehandMode || !freehandDrawing) return;
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
            const polygon = L.polygon(freehandLatLngs, {color: '#2563eb', weight: 3, fillOpacity: 0.2});
            freehandLatLngs = [];
            dossierGroup.clearLayers();
            bindDossierPolygonPopup(polygon);
            dossierGroup.addLayer(polygon);
            drawModeFreehandToggle.checked = false;
            stopFreehandMode();
            clearDrawSnapPreview();
            statusEl.textContent = 'Полигон досъёма добавлен. Можно сохранить.';
            rebuildSnapGuideLines();
            updateEditableAreaInfo();
        });

        async function checkRelations() {
            const geometry = buildCurrentGeometry();
            if (!geometry) {
                statusEl.textContent = 'Нет геометрии для проверки связей.';
                return;
            }
            const hasNewPolygon = hasDossierPolygon();
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
                    body: JSON.stringify({
                        geometry,
                        source_label: selectedSourceLabel,
                        selected_geometry: hasNewPolygon ? selectedGeometry : null,
                        request_id: String(requestId || '').trim() || undefined,
                    })
                });
                const data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.error || 'Ошибка обновления связей.');
                }
                if (hasNewPolygon && data.intersects_selected) {
                    window.alert('Новый полигон пересекает редактируемый объект');
                    statusEl.textContent = 'Обнаружено пересечение: новый полигон пересекает редактируемый объект.';
                }
                renderRelationLayers(data.layers || {});
                statusEl.textContent = 'Границы объектов и площадь обновлены.';
            } catch (error) {
                statusEl.textContent = error.message || 'Не удалось обновить связи.';
            } finally {
                hideDbLoadingModal();
                checkRelationsButton.disabled = false;
            }
        }

        async function checkDgiIntersections() {
            const geometry = buildCurrentGeometry();
            if (!geometry) {
                statusEl.textContent = 'Нет геометрии для проверки пересечений.';
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
                if (data.intersects) {
                    window.alert('Обнаружено пересечение с объектами ДГИ ' + data.percent + '% от площади');
                } else {
                    window.alert('Пересечений с объектами ДГИ не обнаружено.');
                }
                statusEl.textContent = 'Проверка пересечений с ДГИ завершена.';
            } catch (error) {
                statusEl.textContent = error.message || 'Не удалось проверить пересечения с ДГИ.';
            } finally {
                checkDgiIntersectionsButton.disabled = false;
            }
        }

        const autoRemoveSourceToGroup = {
            dt: adjacentDtPassportsGroup,
            odh: odhSignalGroup,
            ozn: oznSignalGroup,
            top: topSignalGroup,
            requests: requestObjectsGroup,
            dgi: dgiSignalGroup,
            renew: renewGroup,
            oozt: ooztSignalGroup,
            rzd: rzdSignalGroup,
        };
        const autoRemoveOptionLabels = autoRemoveModal
            ? Array.from(autoRemoveModal.querySelectorAll('[data-auto-remove-source]'))
            : [];
        const autoRemoveNoLayersMessage =
            'Нет отображённых слоёв. Включите нужные слои в панели управления картой.';

        function isAutoRemoveSourceDisplayed(source) {
            const group = autoRemoveSourceToGroup[source];
            if (!group) {
                return false;
            }
            return map.hasLayer(group) && countGroupFeatures(group) > 0;
        }

        function resetAutoRemoveCheckboxes() {
            [
                autoRemoveDtCheckbox,
                autoRemoveOdhCheckbox,
                autoRemoveOznCheckbox,
                autoRemoveTopCheckbox,
                autoRemoveRequestsCheckbox,
                autoRemoveDgiCheckbox,
                autoRemoveRenewCheckbox,
                autoRemoveOoztCheckbox,
                autoRemoveRzdCheckbox,
            ].forEach((el) => {
                if (el) {
                    el.checked = false;
                }
            });
        }

        function refreshAutoRemoveModalOptions() {
            let visibleCount = 0;
            autoRemoveOptionLabels.forEach((label) => {
                const source = label.dataset.autoRemoveSource;
                const checkbox = label.querySelector('input[type="checkbox"]');
                const displayed = isAutoRemoveSourceDisplayed(source);
                label.classList.toggle('auto-remove-option--hidden', !displayed);
                if (!displayed && checkbox) {
                    checkbox.checked = false;
                }
                if (displayed) {
                    visibleCount += 1;
                }
            });
            if (autoRemoveNoLayersEl) {
                autoRemoveNoLayersEl.style.display = visibleCount === 0 ? 'block' : 'none';
            }
            if (autoRemoveModalSubmit) {
                autoRemoveModalSubmit.disabled = visibleCount === 0;
            }
            return visibleCount;
        }

        function openAutoRemoveModal() {
            autoRemoveModalErrorEl.textContent = '';
            resetAutoRemoveCheckboxes();
            refreshAutoRemoveModalOptions();
            autoRemoveModal.style.display = 'flex';
        }

        function closeAutoRemoveModal() {
            autoRemoveModal.style.display = 'none';
            autoRemoveModalErrorEl.textContent = '';
            if (autoRemoveModalSubmit) {
                autoRemoveModalSubmit.disabled = false;
            }
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
            if (autoRemoveTopCheckbox && autoRemoveTopCheckbox.checked) {
                sources.push('top');
            }
            if (autoRemoveRequestsCheckbox?.checked) {
                sources.push('requests');
            }
            if (autoRemoveDgiCheckbox.checked) {
                sources.push('dgi');
            }
            if (autoRemoveRenewCheckbox.checked) {
                sources.push('renew');
            }
            if (autoRemoveOoztCheckbox.checked) {
                sources.push('oozt');
            }
            if (autoRemoveRzdCheckbox.checked) {
                sources.push('rzd');
            }
            return sources;
        }

        function applyGeometryToDossierGroup(geometry) {
            const normalized = normalizeGeoJson(geometry);
            if (!normalized || !normalized.features || !normalized.features.length) {
                return false;
            }
            dossierGroup.clearLayers();
            L.geoJSON(normalized, {
                style: {color: '#2563eb', weight: 3, fillOpacity: 0.2}
            }).eachLayer((layer) => {
                bindDossierPolygonPopup(layer);
                dossierGroup.addLayer(layer);
            });
            rebuildSnapGuideLines();
            refreshObjectLayersControl();
            return true;
        }

        async function autoRemoveIntersections() {
            const geometry = buildCurrentGeometry();
            if (!geometry) {
                statusEl.textContent = 'Нет геометрии для автоматического удаления пересечений.';
                return;
            }
            const hasNewPolygon = hasDossierPolygon();
            const visibleLayerCount = refreshAutoRemoveModalOptions();
            if (!visibleLayerCount) {
                autoRemoveModalErrorEl.textContent = autoRemoveNoLayersMessage;
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
                        source_label: selectedSourceLabel,
                        selected_row_ctid: hasNewPolygon ? (selectedRowCtid || null) : null,
                        selected_rootid: hasNewPolygon ? (selectedRootid || null) : null,
                        selected_geometry: hasNewPolygon ? selectedGeometry : null,
                    })
                });
                const data = await response.json();
                if (!response.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось удалить пересечения.');
                }
                if (!data.geometry) {
                    throw new Error('После удаления пересечений не осталось площади объекта.');
                }
                if (!applyGeometryToDossierGroup(data.geometry)) {
                    throw new Error('Не удалось применить обновлённую геометрию.');
                }
                closeAutoRemoveModal();
                statusEl.textContent = 'Пересечения автоматически удалены.';
                updateEditableAreaInfo();
                await checkRelations();
            } catch (error) {
                autoRemoveModalErrorEl.textContent = error.message || 'Не удалось удалить пересечения.';
                statusEl.textContent = error.message || 'Не удалось удалить пересечения.';
            } finally {
                autoRemoveIntersectionsButton.disabled = false;
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
            if (dossierGroup.hasLayer(pendingDeleteLayer)) {
                dossierGroup.removeLayer(pendingDeleteLayer);
            }
            closeDeletePolygonModal();
            clearDrawSnapPreview();
            rebuildSnapGuideLines();
            refreshObjectLayersControl();
            statusEl.textContent = 'Полигон удалён.';
            updateEditableAreaInfo();
            checkRelations();
        }

        deletePolygonModalCancel.addEventListener('click', () => {
            closeDeletePolygonModal();
        });
        deletePolygonModalSubmit.addEventListener('click', () => {
            deletePendingPolygon();
        });

        function openSaveModal() {
            if (newRecapIdInput) {
                newRecapIdInput.value = (initialRecapIdFromEntry || '').trim();
            }
            if (saveModalErrorEl) {
                saveModalErrorEl.textContent = '';
            }
            saveModal.style.display = 'flex';
            setTimeout(() => newRecapIdInput && newRecapIdInput.focus(), 0);
        }

        function closeSaveModal() {
            saveModal.style.display = 'none';
        }

        async function saveDossier() {
            const geo = dossierGroup.toGeoJSON();
            if (!geo.features.length) {
                statusEl.textContent = 'Сначала нарисуйте полигон досъёма.';
                return;
            }
            const geometry = geo.features[0].geometry;
            const recapId = (newRecapIdInput.value || '').trim();
            if (!recapId) {
                saveModalErrorEl.textContent = 'Укажите номер досъёма (recap_id).';
                return;
            }
            if (!/^\d+$/.test(recapId)) {
                saveModalErrorEl.textContent = 'Номер досъёма (recap_id) должен содержать только цифры.';
                return;
            }
            saveModalErrorEl.textContent = '';
            saveModalSubmit.disabled = true;
            saveDossierButton.disabled = true;
            statusEl.textContent = 'Сохраняем досъём...';
            try {
                const saveResponse = await fetch(cfg.urls.saveRecap, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    body: JSON.stringify({
                        geometry: geometry,
                        name: objectName,
                        request_id: requestId,
                        recap_id: recapId,
                    }),
                });
                const saveResult = await saveResponse.json();
                if (!saveResponse.ok || !saveResult.ok) {
                    throw new Error(saveResult.error || 'Не удалось сохранить досъём.');
                }

                const exportResponse = await fetch(cfg.urls.exportGeometry, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    body: JSON.stringify({
                        geometry: geometry,
                        properties: {
                            name: objectName,
                            OwnerLegalPersonId: saveResult.owner_id,
                            request_id: requestId,
                            recap_id: recapId,
                        },
                    }),
                });
                const exportResult = await exportResponse.json();
                if (!exportResponse.ok || !exportResult.ok) {
                    throw new Error(exportResult.error || 'Не удалось сформировать файлы.');
                }

                closeSaveModal();
                exportLinksEl.innerHTML =
                    '<a class="button-link" href="' + exportResult.geojson_url + '" download>Скачать GeoJSON</a> ' +
                    '<a class="button-link" href="' + exportResult.shapefile_url + '">Скачать SHP (ZIP)</a>';
                statusEl.textContent = 'Досъём сохранён в recaps, файлы выгружены.';
            } catch (error) {
                saveModalErrorEl.textContent = error.message || 'Ошибка сохранения досъёма.';
            } finally {
                saveModalSubmit.disabled = false;
                saveDossierButton.disabled = false;
            }
        }

        saveDossierButton.addEventListener('click', openSaveModal);
        saveModalCancel.addEventListener('click', closeSaveModal);
        saveModalSubmit.addEventListener('click', saveDossier);
        saveModal.addEventListener('click', (event) => {
            if (event.target === saveModal) {
                closeSaveModal();
            }
        });
        checkRelationsButton.addEventListener('click', checkRelations);
        checkDgiIntersectionsButton.addEventListener('click', checkDgiIntersections);

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
            const rid = (requestId || '').trim();
            if (!rid) {
                if (commentPointModalError) {
                    commentPointModalError.textContent = 'Нет номера заявки (request_id).';
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
                const rid = (requestId || '').trim();
                if (!rid) {
                    statusEl.textContent = 'Нет номера заявки для привязки комментария.';
                    return;
                }
                if (commentPointMode) {
                    cancelCommentPointMode();
                    statusEl.textContent = 'Режим добавления точки выключен.';
                    return;
                }
                if (polygonDrawer) {
                    polygonDrawer.disable();
                    polygonDrawer = null;
                    clearStartVertexFlag();
                }
                stopFreehandMode();
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

        refreshObjectLayersControl();
        loadCommentPointsForMap();

})();

(function () {
    'use strict';

    let activeDrawer = null;
    let drawMode = false;
    let brushMode = null;
    let brushDrawing = false;
    let brushLatLngs = [];
    let brushPreview = null;
    let brushLastPoint = null;
    let geometryCompleteCallback = null;
    let brushEventsBound = false;

    const EVENT_COLOR = '#7c3aed';
    const BRUSH_MIN_PIXEL_DISTANCE = 3;
    const BRUSH_POINTER_PANES = ['.leaflet-overlay-pane', '.leaflet-marker-pane'];

    function getMap() {
        return window.ApprovalMap && window.ApprovalMap.getMap();
    }

    function stopActiveDrawer() {
        if (activeDrawer) {
            activeDrawer.disable();
            activeDrawer = null;
        }
    }

    function setBrushPointerEvents(enabled) {
        const map = getMap();
        if (!map) {
            return;
        }
        const container = map.getContainer();
        BRUSH_POINTER_PANES.forEach(function (selector) {
            const pane = container.querySelector(selector);
            if (pane) {
                pane.style.pointerEvents = enabled ? '' : 'none';
            }
        });
    }

    function removeBrushPreviewLayer() {
        const map = getMap();
        if (brushPreview && map) {
            map.removeLayer(brushPreview);
        }
        brushPreview = null;
    }

    function clearBrushPreview() {
        removeBrushPreviewLayer();
        brushLatLngs = [];
        brushLastPoint = null;
        brushDrawing = false;
        setBrushPointerEvents(true);
    }

    function stopDrawMode() {
        const map = getMap();
        drawMode = false;
        brushMode = null;
        stopActiveDrawer();
        clearBrushPreview();
        if (map) {
            map.dragging.enable();
            map.getContainer().style.cursor = '';
        }
        const toolbar = document.getElementById('approval-draw-toolbar');
        if (toolbar) {
            toolbar.hidden = true;
        }
        document.querySelectorAll('.approval-draw-toolbar__btn[data-draw-tool]').forEach(function (btn) {
            btn.classList.remove('is-active');
        });
    }

    function layerToGeoJSON(layer) {
        if (!layer || typeof layer.toGeoJSON !== 'function') {
            return null;
        }
        const geo = layer.toGeoJSON();
        return geo && geo.geometry ? geo.geometry : null;
    }

    function finishGeometry(geometry) {
        if (!geometry) {
            return;
        }
        stopDrawMode();
        if (typeof geometryCompleteCallback === 'function') {
            geometryCompleteCallback(geometry);
        }
    }

    function startDrawer(tool) {
        const map = getMap();
        if (!map || typeof L === 'undefined' || !L.Draw) {
            return;
        }
        stopActiveDrawer();
        clearBrushPreview();
        brushMode = null;

        document.querySelectorAll('.approval-draw-toolbar__btn[data-draw-tool]').forEach(function (btn) {
            btn.classList.toggle('is-active', btn.dataset.drawTool === tool);
        });

        if (tool === 'marker') {
            activeDrawer = new L.Draw.Marker(map, {
                icon: L.divIcon({
                    className: 'approval-event-marker-icon',
                    html: '<span></span>',
                    iconSize: [14, 14],
                    iconAnchor: [7, 7],
                }),
            });
        } else if (tool === 'polyline') {
            activeDrawer = new L.Draw.Polyline(map, {
                shapeOptions: { color: EVENT_COLOR, weight: 3 },
            });
        } else if (tool === 'polygon') {
            activeDrawer = new L.Draw.Polygon(map, {
                allowIntersection: false,
                shapeOptions: {
                    color: EVENT_COLOR,
                    weight: 3,
                    fillColor: EVENT_COLOR,
                    fillOpacity: 0.35,
                },
            });
        } else if (tool === 'brush-fill') {
            brushMode = 'fill';
            map.getContainer().style.cursor = 'crosshair';
            return;
        } else if (tool === 'brush-line') {
            brushMode = 'line';
            map.getContainer().style.cursor = 'crosshair';
            return;
        }

        if (activeDrawer) {
            activeDrawer.enable();
        }
    }

    function eventToContainerPoint(map, domEvent) {
        const rect = map.getContainer().getBoundingClientRect();
        return L.point(domEvent.clientX - rect.left, domEvent.clientY - rect.top);
    }

    function eventToLatLng(map, domEvent) {
        return map.containerPointToLatLng(eventToContainerPoint(map, domEvent));
    }

    function shouldAppendBrushPoint(map, latlng) {
        if (!brushLastPoint) {
            return true;
        }
        const prev = map.latLngToContainerPoint(brushLastPoint);
        const next = map.latLngToContainerPoint(latlng);
        const dx = next.x - prev.x;
        const dy = next.y - prev.y;
        return Math.sqrt(dx * dx + dy * dy) >= BRUSH_MIN_PIXEL_DISTANCE;
    }

    function finishBrushStroke() {
        if (!drawMode || !brushMode || !brushDrawing) {
            return;
        }
        brushDrawing = false;
        setBrushPointerEvents(true);
        const mapRef = getMap();
        if (mapRef) {
            mapRef.dragging.enable();
        }
        if (brushLatLngs.length < 2) {
            clearBrushPreview();
            return;
        }

        let geometry = null;
        if (brushMode === 'fill' && brushLatLngs.length >= 3) {
            geometry = L.polygon(brushLatLngs, {
                color: EVENT_COLOR,
                fillColor: EVENT_COLOR,
                fillOpacity: 0.35,
            }).toGeoJSON().geometry;
        } else {
            geometry = L.polyline(brushLatLngs, { color: EVENT_COLOR }).toGeoJSON().geometry;
        }
        clearBrushPreview();
        finishGeometry(geometry);
    }

    function bindMapDrawEvents() {
        const map = getMap();
        if (!map || brushEventsBound) {
            return;
        }
        brushEventsBound = true;
        const container = map.getContainer();

        map.on(L.Draw.Event.CREATED, function (event) {
            if (!drawMode) {
                return;
            }
            const geometry = layerToGeoJSON(event.layer);
            if (event.layer && map.hasLayer(event.layer)) {
                map.removeLayer(event.layer);
            }
            finishGeometry(geometry);
        });

        container.addEventListener('mousedown', function (domEvent) {
            if (!drawMode || !brushMode || domEvent.button !== 0) {
                return;
            }
            domEvent.preventDefault();
            removeBrushPreviewLayer();
            brushDrawing = true;
            setBrushPointerEvents(false);
            const latlng = eventToLatLng(map, domEvent);
            brushLatLngs = [latlng];
            brushLastPoint = latlng;
            brushPreview = L.polyline(brushLatLngs, {
                color: EVENT_COLOR,
                weight: 3,
                opacity: 0.9,
                interactive: false,
            }).addTo(map);
            map.dragging.disable();
        });

        container.addEventListener('mousemove', function (domEvent) {
            if (!drawMode || !brushMode || !brushDrawing) {
                return;
            }
            const latlng = eventToLatLng(map, domEvent);
            if (!shouldAppendBrushPoint(map, latlng)) {
                return;
            }
            brushLatLngs.push(latlng);
            brushLastPoint = latlng;
            if (brushPreview) {
                brushPreview.setLatLngs(brushLatLngs);
            }
        });

        container.addEventListener('mouseup', function () {
            finishBrushStroke();
        });

        container.addEventListener('mouseleave', function () {
            finishBrushStroke();
        });
    }

    function startDrawMode(onComplete) {
        const map = getMap();
        if (!map) {
            return;
        }
        if (
            window.ApprovalMap &&
            typeof window.ApprovalMap.stopMeasureMode === 'function'
        ) {
            window.ApprovalMap.stopMeasureMode();
        }
        geometryCompleteCallback = onComplete;
        drawMode = true;
        const toolbar = document.getElementById('approval-draw-toolbar');
        if (toolbar) {
            toolbar.hidden = false;
        }
        document.querySelectorAll('.approval-draw-toolbar__btn[data-draw-tool]').forEach(function (btn) {
            btn.classList.remove('is-active');
        });
        stopActiveDrawer();
        clearBrushPreview();
        brushMode = null;
    }

    function initToolbar() {
        const toolbar = document.getElementById('approval-draw-toolbar');
        const cancelBtn = document.getElementById('approval-draw-cancel');
        if (!toolbar) {
            return;
        }

        toolbar.hidden = true;

        toolbar.querySelectorAll('[data-draw-tool]').forEach(function (button) {
            button.addEventListener('click', function () {
                if (!drawMode) {
                    return;
                }
                startDrawer(button.dataset.drawTool);
            });
        });

        if (cancelBtn) {
            cancelBtn.addEventListener('click', function () {
                stopDrawMode();
                geometryCompleteCallback = null;
            });
        }
    }

    window.addEventListener('load', function () {
        bindMapDrawEvents();
        initToolbar();
    });

    window.ApprovalEventDraw = {
        startDrawMode: startDrawMode,
        stopDrawMode: stopDrawMode,
        startCreateMode: startDrawMode,
        stopCreateMode: stopDrawMode,
        isDrawMode: function () {
            return drawMode;
        },
    };
})();

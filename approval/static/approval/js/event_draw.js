(function () {
    'use strict';

    let activeDrawer = null;
    let drawMode = false;
    let brushMode = null;
    let brushDrawing = false;
    let brushLatLngs = [];
    let brushPreview = null;
    let geometryCompleteCallback = null;

    const EVENT_COLOR = '#7c3aed';

    function getMap() {
        return window.ApprovalMap && window.ApprovalMap.getMap();
    }

    function stopActiveDrawer() {
        if (activeDrawer) {
            activeDrawer.disable();
            activeDrawer = null;
        }
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
        brushDrawing = false;
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

    function bindMapDrawEvents() {
        const map = getMap();
        if (!map) {
            return;
        }

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

        map.on('mousedown', function (event) {
            if (!drawMode || !brushMode) {
                return;
            }
            removeBrushPreviewLayer();
            brushDrawing = true;
            brushLatLngs = [event.latlng];
            brushPreview = L.polyline(brushLatLngs, {
                color: EVENT_COLOR,
                weight: 3,
                opacity: 0.9,
            }).addTo(map);
            map.dragging.disable();
        });

        map.on('mousemove', function (event) {
            if (!drawMode || !brushMode || !brushDrawing) {
                return;
            }
            brushLatLngs.push(event.latlng);
            if (brushPreview) {
                brushPreview.setLatLngs(brushLatLngs);
            }
        });

        map.on('mouseup', function () {
            if (!drawMode || !brushMode || !brushDrawing) {
                return;
            }
            brushDrawing = false;
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
        });
    }

    function startDrawMode(onComplete) {
        const map = getMap();
        if (!map) {
            return;
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
    };
})();

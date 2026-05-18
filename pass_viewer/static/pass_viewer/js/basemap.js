(function (global) {
    'use strict';
    const PassViewer = (global.PassViewer = global.PassViewer || {});

    PassViewer.bindPopupHighlight = function bindPopupHighlight(map) {
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

        return { clearPopupHighlight, applyPopupHighlight };
    };

    PassViewer.attachBasemapControl = function attachBasemapControl(map) {
        const topoLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxNativeZoom: 19,
            maxZoom: 30,
            attribution: '&copy; OpenStreetMap contributors',
        });
        const satelliteLayer = L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            {
                maxNativeZoom: 19,
                maxZoom: 30,
                attribution: 'Tiles &copy; Esri',
            },
        );
        topoLayer.addTo(map);

        const basemapControl = L.control({ position: 'topright' });
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

        return { setBasemap, topoLayer, satelliteLayer };
    };
})(typeof window !== 'undefined' ? window : global);

(function (global) {
    'use strict';
    const PassViewer = (global.PassViewer = global.PassViewer || {});

    const MGGT_TILE_URL =
        'http://ngtst.mggt:8080/api/component/render/tile?resource=248465&nd=204&z={z}&x={x}&y={y}';
    const ERROR_TILE_URL =
        'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
    /** Максимальный z, на котором сервер МГГТ отдаёт реальные тайлы; выше — Leaflet масштабирует уже загруженные. */
    const MGGT_MAX_NATIVE_ZOOM = 17;
    const MAP_MAX_ZOOM = 30;

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

    function bindTileLayerErrorHandling(layer, label) {
        let notified = false;
        layer.on('tileerror', () => {
            if (notified) {
                return;
            }
            notified = true;
            console.warn(`[PassViewer] Подложка «${label}»: тайлы недоступны`);
        });
    }

    PassViewer.createBasemapLayers = function createBasemapLayers() {
        const commonTileOpts = { maxNativeZoom: 19, maxZoom: MAP_MAX_ZOOM };
        const mggtLayer = L.tileLayer(MGGT_TILE_URL, {
            minZoom: 0,
            maxNativeZoom: MGGT_MAX_NATIVE_ZOOM,
            maxZoom: MAP_MAX_ZOOM,
            attribution: '© МГГТ',
            errorTileUrl: ERROR_TILE_URL,
            detectRetina: false,
            updateWhenZooming: false,
            updateWhenIdle: true,
        });
        const topoLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            ...commonTileOpts,
            crossOrigin: 'anonymous',
            attribution: '&copy; OpenStreetMap contributors',
            errorTileUrl: ERROR_TILE_URL,
        });
        const satelliteLayer = L.tileLayer(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            {
                ...commonTileOpts,
                crossOrigin: 'anonymous',
                attribution: 'Tiles &copy; Esri',
                errorTileUrl: ERROR_TILE_URL,
            },
        );
        bindTileLayerErrorHandling(mggtLayer, 'МГГТ');
        bindTileLayerErrorHandling(topoLayer, 'OSM');
        bindTileLayerErrorHandling(satelliteLayer, 'Спутник');
        return { mggtLayer, topoLayer, satelliteLayer };
    };

    PassViewer.attachBasemapControl = function attachBasemapControl(map, options) {
        const scopeRoot = options && options.scopeRoot;
        const { mggtLayer, topoLayer, satelliteLayer } = PassViewer.createBasemapLayers();
        const basemapLayers = [mggtLayer, topoLayer, satelliteLayer];

        mggtLayer.addTo(map);

        const basemapControl = L.control({ position: 'topright' });
        basemapControl.onAdd = function () {
            const container = L.DomUtil.create('div', 'map-basemap-control');
            container.innerHTML =
                '<button type="button" class="map-basemap-btn is-active" data-map="mggt">МГГТ</button>' +
                '<button type="button" class="map-basemap-btn" data-map="topo">OSM</button>' +
                '<button type="button" class="map-basemap-btn" data-map="sat">Спутник</button>' +
                '<button type="button" class="map-basemap-btn" data-map="none">Без подложки</button>';
            L.DomEvent.disableClickPropagation(container);
            return container;
        };
        basemapControl.addTo(map);

        function buttonScope() {
            return scopeRoot || map.getContainer();
        }

        function setBasemap(mode) {
            basemapLayers.forEach((layer) => {
                if (map.hasLayer(layer)) {
                    map.removeLayer(layer);
                }
            });
            if (mode === 'mggt') {
                map.addLayer(mggtLayer);
            } else if (mode === 'topo') {
                map.addLayer(topoLayer);
            } else if (mode === 'sat') {
                map.addLayer(satelliteLayer);
            }
            buttonScope().querySelectorAll('.map-basemap-btn').forEach((btn) => {
                btn.classList.toggle('is-active', btn.dataset.map === mode);
            });
        }

        map.getContainer().querySelectorAll('.map-basemap-btn').forEach((btn) => {
            btn.addEventListener('click', () => setBasemap(btn.dataset.map));
        });

        return { setBasemap, mggtLayer, topoLayer, satelliteLayer };
    };
})(typeof window !== 'undefined' ? window : global);

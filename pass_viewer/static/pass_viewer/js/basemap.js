(function (global) {
    'use strict';
    const PassViewer = (global.PassViewer = global.PassViewer || {});

    const MGGT_TILE_URL =
        'http://ngtst.mggt:8080/api/component/render/tile?resource=248465&nd=204&z={z}&x={x}&y={y}';
    const SCALE_2000_TILE_URL =
        'http://ngtst.mggt:8080/api/component/render/tile?resource=232992&nd=204&z={z}&x={x}&y={y}';
    const ERROR_TILE_URL =
        'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
    /** Максимальный z, на котором сервер МГГТ отдаёт реальные тайлы; выше — Leaflet масштабирует уже загруженные. */
    const MGGT_MAX_NATIVE_ZOOM = 17;
    const MAP_MAX_ZOOM = 30;
    const MGGT_PROBE_CACHE_KEY = 'passviewer:mggt_available';
    const MGGT_PROBE_TIMEOUT_MS = 3000;
    /** Тайл в центре Москвы для проверки доступности сервера МГГТ. */
    const MGGT_PROBE_TILE = { z: 10, x: 618, y: 319 };

    let mggtProbePromise = null;

    function getCachedMggtAvailability() {
        try {
            const value = sessionStorage.getItem(MGGT_PROBE_CACHE_KEY);
            if (value === '1') {
                return true;
            }
            if (value === '0') {
                return false;
            }
        } catch (e) {
            // sessionStorage may be unavailable
        }
        return null;
    }

    function setCachedMggtAvailability(available) {
        try {
            sessionStorage.setItem(MGGT_PROBE_CACHE_KEY, available ? '1' : '0');
        } catch (e) {
            // sessionStorage may be unavailable
        }
    }

    function probeMggtAvailability(timeoutMs) {
        const url = MGGT_TILE_URL.replace('{z}', String(MGGT_PROBE_TILE.z))
            .replace('{x}', String(MGGT_PROBE_TILE.x))
            .replace('{y}', String(MGGT_PROBE_TILE.y));

        return new Promise((resolve) => {
            const img = new Image();
            let settled = false;
            const finish = (ok) => {
                if (settled) {
                    return;
                }
                settled = true;
                clearTimeout(timer);
                img.onload = null;
                img.onerror = null;
                resolve(ok);
            };
            const timer = setTimeout(() => finish(false), timeoutMs);
            img.onload = () => finish(img.naturalWidth > 1 && img.naturalHeight > 1);
            img.onerror = () => finish(false);
            img.src = url;
        });
    }

    function resolveMggtAvailability() {
        const cached = getCachedMggtAvailability();
        if (cached !== null) {
            return Promise.resolve(cached);
        }
        if (!mggtProbePromise) {
            mggtProbePromise = probeMggtAvailability(MGGT_PROBE_TIMEOUT_MS).then((available) => {
                setCachedMggtAvailability(available);
                return available;
            });
        }
        return mggtProbePromise;
    }

    function buildBasemapButtonsHtml(mggtAvailable, activeMode) {
        const btn = (mode, label) => {
            const activeClass = mode === activeMode ? ' is-active' : '';
            return (
                `<button type="button" class="map-basemap-btn${activeClass}" data-map="${mode}">` +
                `${label}</button>`
            );
        };
        const parts = [];
        if (mggtAvailable) {
            parts.push(btn('mggt', 'МГГТ'), btn('scale2000', '1:2000'));
        }
        parts.push(btn('topo', 'OSM'), btn('sat', 'Спутник'), btn('none', 'Без подложки'));
        return parts.join('');
    }

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
        const mggtTileOpts = {
            minZoom: 0,
            maxNativeZoom: MGGT_MAX_NATIVE_ZOOM,
            maxZoom: MAP_MAX_ZOOM,
            attribution: '© МГГТ',
            errorTileUrl: ERROR_TILE_URL,
            detectRetina: false,
            updateWhenZooming: false,
            updateWhenIdle: true,
        };
        const mggtLayer = L.tileLayer(MGGT_TILE_URL, mggtTileOpts);
        const scale2000Layer = L.tileLayer(SCALE_2000_TILE_URL, {
            ...mggtTileOpts,
            attribution: '© МГГТ 1:2000',
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
        bindTileLayerErrorHandling(scale2000Layer, '1:2000');
        bindTileLayerErrorHandling(topoLayer, 'OSM');
        bindTileLayerErrorHandling(satelliteLayer, 'Спутник');
        return { mggtLayer, scale2000Layer, topoLayer, satelliteLayer };
    };

    PassViewer.attachBasemapControl = function attachBasemapControl(map, options) {
        const scopeRoot = options && options.scopeRoot;
        const { mggtLayer, scale2000Layer, topoLayer, satelliteLayer } =
            PassViewer.createBasemapLayers();
        const basemapLayers = [mggtLayer, scale2000Layer, topoLayer, satelliteLayer];

        const cachedAvailability = getCachedMggtAvailability();
        let mggtAvailable = cachedAvailability === true;
        let currentMode = mggtAvailable ? 'mggt' : 'topo';
        let controlContainer = null;

        function buttonScope() {
            return scopeRoot || map.getContainer();
        }

        function findControlContainer() {
            if (controlContainer && controlContainer.isConnected) {
                return controlContainer;
            }
            const scope = buttonScope();
            controlContainer =
                scope.querySelector('.map-basemap-control') ||
                map.getContainer().querySelector('.map-basemap-control');
            return controlContainer;
        }

        function setBasemap(mode) {
            if ((mode === 'mggt' || mode === 'scale2000') && !mggtAvailable) {
                mode = 'topo';
            }
            currentMode = mode;
            basemapLayers.forEach((layer) => {
                if (map.hasLayer(layer)) {
                    map.removeLayer(layer);
                }
            });
            if (mode === 'mggt') {
                map.addLayer(mggtLayer);
            } else if (mode === 'scale2000') {
                map.addLayer(scale2000Layer);
            } else if (mode === 'topo') {
                map.addLayer(topoLayer);
            } else if (mode === 'sat') {
                map.addLayer(satelliteLayer);
            }
            const container = findControlContainer();
            if (container) {
                container.querySelectorAll('.map-basemap-btn').forEach((btn) => {
                    btn.classList.toggle('is-active', btn.dataset.map === mode);
                });
            }
        }

        function bindButtonListeners(container) {
            container.querySelectorAll('.map-basemap-btn').forEach((btn) => {
                btn.addEventListener('click', () => setBasemap(btn.dataset.map));
            });
        }

        function renderButtons(activeMode) {
            const container = findControlContainer();
            if (!container) {
                return;
            }
            container.innerHTML = buildBasemapButtonsHtml(mggtAvailable, activeMode);
            bindButtonListeners(container);
        }

        const basemapControl = L.control({ position: 'topright' });
        basemapControl.onAdd = function () {
            const container = L.DomUtil.create('div', 'map-basemap-control');
            container.innerHTML = buildBasemapButtonsHtml(mggtAvailable, currentMode);
            L.DomEvent.disableClickPropagation(container);
            controlContainer = container;
            bindButtonListeners(container);
            return container;
        };
        basemapControl.addTo(map);

        setBasemap(currentMode);

        if (cachedAvailability === null) {
            resolveMggtAvailability().then((available) => {
                if (available === mggtAvailable) {
                    return;
                }
                mggtAvailable = available;
                if (available) {
                    setBasemap('mggt');
                    renderButtons('mggt');
                } else {
                    renderButtons(currentMode);
                }
            });
        }

        return { setBasemap, mggtLayer, scale2000Layer, topoLayer, satelliteLayer };
    };
})(typeof window !== 'undefined' ? window : global);

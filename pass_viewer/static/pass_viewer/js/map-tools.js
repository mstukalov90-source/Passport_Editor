(function (global) {
    'use strict';
    const PassViewer = (global.PassViewer = global.PassViewer || {});
    const EARTH_RADIUS_M = 6378137.0;

    function formatMeasureMeters(meters) {
        if (!Number.isFinite(meters) || meters < 0) {
            return '0 м';
        }
        if (meters < 10) {
            return String(Math.round(meters * 10) / 10) + ' м';
        }
        return Math.round(meters) + ' м';
    }

    function formatMeasureArea(sqMeters) {
        if (!Number.isFinite(sqMeters) || sqMeters < 0) {
            return '0 м²';
        }
        const ha = sqMeters / 10000;
        let metersText;
        if (sqMeters < 100) {
            metersText = String(Math.round(sqMeters * 10) / 10) + ' м²';
        } else {
            metersText = Math.round(sqMeters) + ' м²';
        }
        if (ha < 0.01) {
            return metersText;
        }
        return metersText + ' · ' + ha.toFixed(2) + ' га';
    }

    /** Same spherical formula as Leaflet.Draw GeometryUtil.geodesicArea. */
    function geodesicAreaSqMeters(latLngs) {
        if (L.GeometryUtil && typeof L.GeometryUtil.geodesicArea === 'function') {
            return Math.abs(L.GeometryUtil.geodesicArea(latLngs));
        }
        if (!Array.isArray(latLngs) || latLngs.length < 3) {
            return 0;
        }
        const d2r = Math.PI / 180;
        let area = 0;
        for (let i = 0; i < latLngs.length; i += 1) {
            const p1 = latLngs[i];
            const p2 = latLngs[(i + 1) % latLngs.length];
            area +=
                (p2.lng - p1.lng) *
                d2r *
                (2 + Math.sin(p1.lat * d2r) + Math.sin(p2.lat * d2r));
        }
        return Math.abs((area * EARTH_RADIUS_M * EARTH_RADIUS_M) / 2);
    }

    function polygonCentroid(latLngs) {
        let lat = 0;
        let lng = 0;
        latLngs.forEach(function (p) {
            lat += p.lat;
            lng += p.lng;
        });
        return L.latLng(lat / latLngs.length, lng / latLngs.length);
    }

    function getState(map) {
        return map && map._passViewerMapTools ? map._passViewerMapTools : null;
    }

    function isToolModeActive(state) {
        return !!(state && state.measureKind);
    }

    function uiTargetSelector(extraUiSelectors) {
        const extra = extraUiSelectors ? String(extraUiSelectors).trim() : '';
        return extra
            ? '.leaflet-control, .approval-map-tools, ' + extra
            : '.leaflet-control, .approval-map-tools';
    }

    function isMeasureUiTarget(target, extraUiSelectors) {
        if (!target || typeof target.closest !== 'function') {
            return false;
        }
        return Boolean(target.closest(uiTargetSelector(extraUiSelectors)));
    }

    function syncToolButtonState(state) {
        if (state.measureBtnEl) {
            const lineOn = state.measureKind === 'line';
            state.measureBtnEl.classList.toggle('is-active', lineOn);
            state.measureBtnEl.setAttribute('aria-pressed', lineOn ? 'true' : 'false');
            state.measureBtnEl.title = lineOn ? 'Выключить линейку (Esc)' : 'Линейка (метры)';
        }
        if (state.planimeterBtnEl) {
            const areaOn = state.measureKind === 'area';
            state.planimeterBtnEl.classList.toggle('is-active', areaOn);
            state.planimeterBtnEl.setAttribute('aria-pressed', areaOn ? 'true' : 'false');
            state.planimeterBtnEl.title = areaOn
                ? 'Выключить планиметр (Esc)'
                : 'Планиметр (площадь, м²)';
        }
    }

    function clearMeasureGraphics(state) {
        const map = state.map;
        if (state.measureGroup && map) {
            map.removeLayer(state.measureGroup);
        }
        state.measureGroup = null;
        state.measurePoints = [];
    }

    function rebuildLineGraphics(state) {
        state.measurePoints.forEach(function (latlng) {
            L.circleMarker(latlng, {
                radius: 4,
                color: '#9a3412',
                weight: 2,
                fillColor: '#fff',
                fillOpacity: 1,
                interactive: false,
            }).addTo(state.measureGroup);
        });

        if (state.measurePoints.length < 2) {
            return;
        }

        L.polyline(state.measurePoints, {
            color: '#ea580c',
            weight: 3,
            dashArray: '6 4',
            interactive: false,
        }).addTo(state.measureGroup);

        let total = 0;
        for (let i = 1; i < state.measurePoints.length; i += 1) {
            const prev = state.measurePoints[i - 1];
            const next = state.measurePoints[i];
            const segment = prev.distanceTo(next);
            total += segment;
            const mid = L.latLng((prev.lat + next.lat) / 2, (prev.lng + next.lng) / 2);
            L.marker(mid, {
                interactive: false,
                keyboard: false,
                icon: L.divIcon({
                    className: 'approval-measure-label',
                    html: '<span>' + formatMeasureMeters(segment) + '</span>',
                    iconSize: null,
                }),
            }).addTo(state.measureGroup);
        }

        L.marker(state.measurePoints[state.measurePoints.length - 1], {
            interactive: false,
            keyboard: false,
            icon: L.divIcon({
                className: 'approval-measure-label approval-measure-label--total',
                html: '<span>Σ ' + formatMeasureMeters(total) + '</span>',
                iconSize: null,
            }),
        }).addTo(state.measureGroup);
    }

    function rebuildAreaGraphics(state) {
        const points = state.measurePoints;
        points.forEach(function (latlng) {
            L.circleMarker(latlng, {
                radius: 4,
                color: '#1d4ed8',
                weight: 2,
                fillColor: '#fff',
                fillOpacity: 1,
                interactive: false,
            }).addTo(state.measureGroup);
        });

        if (points.length < 2) {
            return;
        }

        if (points.length < 3) {
            L.polyline(points, {
                color: '#2563eb',
                weight: 3,
                dashArray: '6 4',
                interactive: false,
            }).addTo(state.measureGroup);
            return;
        }

        L.polygon(points, {
            color: '#2563eb',
            weight: 2,
            fillColor: '#3b82f6',
            fillOpacity: 0.18,
            interactive: false,
        }).addTo(state.measureGroup);

        const area = geodesicAreaSqMeters(points);
        L.marker(polygonCentroid(points), {
            interactive: false,
            keyboard: false,
            icon: L.divIcon({
                className: 'approval-measure-label approval-measure-label--area',
                html: '<span>' + formatMeasureArea(area) + '</span>',
                iconSize: null,
            }),
        }).addTo(state.measureGroup);
    }

    function rebuildMeasureGraphics(state) {
        const map = state.map;
        if (!map) {
            return;
        }
        if (!state.measureGroup) {
            state.measureGroup = L.featureGroup().addTo(map);
        } else {
            state.measureGroup.clearLayers();
        }
        if (!state.measurePoints.length) {
            return;
        }
        if (state.measureKind === 'area') {
            rebuildAreaGraphics(state);
        } else {
            rebuildLineGraphics(state);
        }
    }

    function onMeasureCaptureClick(state, domEvent) {
        const map = state.map;
        if (!isToolModeActive(state) || !map) {
            return;
        }
        if (domEvent.button != null && domEvent.button !== 0) {
            return;
        }
        if (isMeasureUiTarget(domEvent.target, state.options.extraUiSelectors)) {
            return;
        }
        const latlng = map.mouseEventToLatLng(domEvent);
        if (!latlng) {
            return;
        }
        L.DomEvent.stop(domEvent);
        map.closePopup();
        state.measurePoints.push(latlng);
        rebuildMeasureGraphics(state);
    }

    function onMeasureKeyDown(state, event) {
        if (!isToolModeActive(state)) {
            return;
        }
        if (event.key === 'Escape') {
            stopMeasureMode(state);
        }
    }

    function shouldPreserveCursor(state) {
        const fn = state.options && state.options.shouldPreserveCursor;
        return typeof fn === 'function' && fn();
    }

    function detachCapture(state) {
        const map = state.map;
        if (map) {
            map.getContainer().removeEventListener('click', state.onMeasureCaptureClick, true);
            map.doubleClickZoom.enable();
            if (!shouldPreserveCursor(state)) {
                map.getContainer().style.cursor = '';
            }
        }
        document.removeEventListener('keydown', state.onMeasureKeyDown);
    }

    function stopMeasureMode(state) {
        const hadMode = isToolModeActive(state) || (state.measurePoints && state.measurePoints.length);
        if (!hadMode) {
            syncToolButtonState(state);
            return;
        }
        state.measureKind = null;
        detachCapture(state);
        clearMeasureGraphics(state);
        syncToolButtonState(state);
    }

    function startMeasureMode(state, kind) {
        const map = state.map;
        if (!map || (kind !== 'line' && kind !== 'area')) {
            return;
        }
        if (typeof state.options.onStartMeasure === 'function') {
            state.options.onStartMeasure();
        }
        if (state.measureKind === kind) {
            return;
        }
        if (isToolModeActive(state)) {
            detachCapture(state);
            clearMeasureGraphics(state);
        }
        state.measureKind = kind;
        state.measureGroup = L.featureGroup().addTo(map);
        map.closePopup();
        map.doubleClickZoom.disable();
        map.getContainer().style.cursor = 'crosshair';
        map.getContainer().addEventListener('click', state.onMeasureCaptureClick, true);
        document.addEventListener('keydown', state.onMeasureKeyDown);
        syncToolButtonState(state);
    }

    function toggleMeasureKind(state, kind) {
        if (state.measureKind === kind) {
            stopMeasureMode(state);
        } else {
            startMeasureMode(state, kind);
        }
    }

    function openCurrentViewInYandexMaps(map) {
        if (!map) {
            return;
        }
        const center = map.getCenter();
        const zoom = Math.max(1, Math.min(21, Math.round(map.getZoom())));
        const url =
            'https://yandex.ru/maps/?ll=' +
            center.lng.toFixed(6) +
            ',' +
            center.lat.toFixed(6) +
            '&z=' +
            zoom;
        window.open(url, '_blank', 'noopener,noreferrer');
    }

    PassViewer.stopMeasureMode = function stopMeasureModeForMap(map) {
        const state = getState(map);
        if (!state) {
            return;
        }
        stopMeasureMode(state);
    };

    PassViewer.isMeasureMode = function isMeasureModeForMap(map) {
        const state = getState(map);
        return isToolModeActive(state);
    };

    PassViewer.attachMapUtilityControls = function attachMapUtilityControls(map, options) {
        if (!map || typeof L === 'undefined') {
            return null;
        }
        if (map._passViewerMapTools && map._passViewerMapTools.control) {
            return map._passViewerMapTools;
        }

        const state = {
            map: map,
            options: options || {},
            measureKind: null,
            measurePoints: [],
            measureGroup: null,
            measureBtnEl: null,
            planimeterBtnEl: null,
            control: null,
        };
        state.onMeasureCaptureClick = function (domEvent) {
            onMeasureCaptureClick(state, domEvent);
        };
        state.onMeasureKeyDown = function (event) {
            onMeasureKeyDown(state, event);
        };
        map._passViewerMapTools = state;

        const control = L.control({ position: 'bottomright' });
        control.onAdd = function () {
            const container = L.DomUtil.create('div', 'approval-map-tools leaflet-bar');
            L.DomEvent.disableClickPropagation(container);
            L.DomEvent.disableScrollPropagation(container);

            const measureBtn = L.DomUtil.create(
                'button',
                'approval-map-tools__btn approval-map-tools__btn--measure',
                container
            );
            measureBtn.type = 'button';
            measureBtn.title = 'Линейка (метры)';
            measureBtn.setAttribute('aria-label', 'Линейка в метрах');
            measureBtn.setAttribute('aria-pressed', 'false');
            measureBtn.innerHTML =
                '<span class="approval-map-tools__icon" aria-hidden="true">' +
                '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                '<path d="M3 12h18"/><path d="M6 9v6"/><path d="M10 10v4"/><path d="M14 9v6"/><path d="M18 10v4"/>' +
                '</svg></span><span class="approval-map-tools__caption">Линейка</span>';
            state.measureBtnEl = measureBtn;
            L.DomEvent.on(measureBtn, 'click', function (event) {
                L.DomEvent.stop(event);
                toggleMeasureKind(state, 'line');
            });

            const planimeterBtn = L.DomUtil.create(
                'button',
                'approval-map-tools__btn approval-map-tools__btn--planimeter',
                container
            );
            planimeterBtn.type = 'button';
            planimeterBtn.title = 'Планиметр (площадь, м²)';
            planimeterBtn.setAttribute('aria-label', 'Планиметр: площадь в квадратных метрах');
            planimeterBtn.setAttribute('aria-pressed', 'false');
            planimeterBtn.innerHTML =
                '<span class="approval-map-tools__icon" aria-hidden="true">' +
                '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                '<path d="M5 19V8l7-4 7 4v11"/><path d="M5 19h14"/><path d="M9 19v-6h6v6"/>' +
                '</svg></span><span class="approval-map-tools__caption">Планиметр</span>';
            state.planimeterBtnEl = planimeterBtn;
            L.DomEvent.on(planimeterBtn, 'click', function (event) {
                L.DomEvent.stop(event);
                toggleMeasureKind(state, 'area');
            });

            const yandexBtn = L.DomUtil.create(
                'button',
                'approval-map-tools__btn approval-map-tools__btn--yandex',
                container
            );
            yandexBtn.type = 'button';
            yandexBtn.title = 'Открыть это место в Яндекс.Картах';
            yandexBtn.setAttribute('aria-label', 'Открыть в Яндекс.Картах');
            yandexBtn.innerHTML =
                '<span class="approval-map-tools__icon" aria-hidden="true">' +
                '<svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">' +
                '<rect width="24" height="24" rx="5" fill="#FC3F1D"/>' +
                '<text x="12" y="17" text-anchor="middle" fill="#fff" font-size="14" font-weight="700" font-family="YS Text, Arial, sans-serif">Я</text>' +
                '</svg></span><span class="approval-map-tools__caption">Я.Карты</span>';
            L.DomEvent.on(yandexBtn, 'click', function (event) {
                L.DomEvent.stop(event);
                openCurrentViewInYandexMaps(map);
            });

            return container;
        };
        control.addTo(map);
        state.control = control;
        syncToolButtonState(state);
        return state;
    };
})(typeof window !== 'undefined' ? window : global);

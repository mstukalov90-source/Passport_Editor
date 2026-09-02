(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    /**
     * Shared editor entry helpers. Full editor flows live in add-object.js and main.js;
     * both depend on utils.js, popups.js, and basemap.js loaded before page scripts.
     */
    PassViewer.MapEditorCore = {
        version: 1,
        defaultCenter: [55.75, 37.61],
        createMap(elementId, zoom) {
            const z = typeof zoom === 'number' ? zoom : 10;
            const map = L.map(elementId, { maxZoom: 30 }).setView(
                PassViewer.MapEditorCore.defaultCenter,
                z,
            );
            map.attributionControl.setPrefix(
                '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺',
            );
            PassViewer.bindPopupHighlight(map);
            PassViewer.attachBasemapControl(map);
            if (PassViewer.attachMapUtilityControls) {
                PassViewer.attachMapUtilityControls(map);
            }
            return map;
        },
    };
})(typeof window !== 'undefined' ? window : global);

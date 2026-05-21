(function () {
    'use strict';

    const PV = window.PassViewer;
    PV.localizeLeafletDraw();

    const cfg = PV.getPageConfig();
    const Split = window.PassViewerSplit;

    const mapEl = document.getElementById('map');
    const statusEl = document.getElementById('edit-status');

    if (!mapEl) {
        console.error('split-object: #map not found');
        if (statusEl) {
            statusEl.textContent = 'Ошибка: контейнер карты не найден.';
        }
        return;
    }

    Split.createMapController(cfg, {
        mapEl,
        statusEl,
        exportLinksEl: document.getElementById('export-links'),
        editButton: document.getElementById('edit-geometry-btn'),
        cutButton: document.getElementById('cut-polygon-btn'),
        selectByPolygonButton: document.getElementById('select-by-polygon-btn'),
        cancelButton: document.getElementById('cancel-edit-btn'),
        saveButton: document.getElementById('save-geometry-btn'),
    });
})();

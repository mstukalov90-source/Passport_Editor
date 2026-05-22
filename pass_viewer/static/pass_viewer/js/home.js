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

const HOME_OGH_BOUNDARIES_EDIT_KEY = 'home_ogh_boundaries_edit';
        const HOME_OGH_SPLIT_PASSPORT_KEY = 'home_ogh_split_passport';

        function setHomeOghBoundariesEditMode(enabled) {
            const on = Boolean(enabled);
            if (on) {
                try {
                    sessionStorage.removeItem(HOME_OGH_SPLIT_PASSPORT_KEY);
                } catch (e) {
                    // sessionStorage may be unavailable
                }
                document.body.classList.remove('home--ogh-split-passport');
            }
            try {
                if (on) {
                    sessionStorage.setItem(HOME_OGH_BOUNDARIES_EDIT_KEY, '1');
                } else {
                    sessionStorage.removeItem(HOME_OGH_BOUNDARIES_EDIT_KEY);
                }
            } catch (e) {
                // sessionStorage may be unavailable
            }
            document.body.classList.toggle('home--ogh-boundaries-edit', on);
        }

        function setHomeOghSplitPassportMode(enabled) {
            const on = Boolean(enabled);
            if (on) {
                try {
                    sessionStorage.removeItem(HOME_OGH_BOUNDARIES_EDIT_KEY);
                } catch (e) {
                    // sessionStorage may be unavailable
                }
                document.body.classList.remove('home--ogh-boundaries-edit');
            }
            try {
                if (on) {
                    sessionStorage.setItem(HOME_OGH_SPLIT_PASSPORT_KEY, '1');
                } else {
                    sessionStorage.removeItem(HOME_OGH_SPLIT_PASSPORT_KEY);
                }
            } catch (e) {
                // sessionStorage may be unavailable
            }
            document.body.classList.toggle('home--ogh-split-passport', on);
        }

        function clearHomeOghSpecialModes() {
            setHomeOghBoundariesEditMode(false);
            setHomeOghSplitPassportMode(false);
        }

        function syncHomeOghSpecialModesFromStorage() {
            try {
                let boundaries = sessionStorage.getItem(HOME_OGH_BOUNDARIES_EDIT_KEY) === '1';
                let split = sessionStorage.getItem(HOME_OGH_SPLIT_PASSPORT_KEY) === '1';
                if (boundaries && split) {
                    sessionStorage.removeItem(HOME_OGH_SPLIT_PASSPORT_KEY);
                    split = false;
                }
                document.body.classList.toggle('home--ogh-boundaries-edit', boundaries);
                document.body.classList.toggle('home--ogh-split-passport', split);
            } catch (e) {
                document.body.classList.remove('home--ogh-boundaries-edit');
                document.body.classList.remove('home--ogh-split-passport');
            }
        }

        syncHomeOghSpecialModesFromStorage();

        const homeBootstrapEl = document.getElementById('home-bootstrap-data');
        const needEntryRequestIdOnLoad =
            homeBootstrapEl && homeBootstrapEl.dataset.needEntryRequestId === '1';
        const odsSourceLabelNorm = (homeBootstrapEl?.dataset.odsSourceLabel || 'ОДС').trim().toUpperCase();
        const ownedMapEl = document.getElementById('owned-passports-map');
        const ownedGeoDataEl = document.getElementById('owned-passports-geojson-data');
        const hoodWorkAreaGeoEl = document.getElementById('hood-work-area-geojson-data');
        const listTabButtons = Array.from(document.querySelectorAll('.owned-list-tab-btn'));
        const listPanels = Array.from(document.querySelectorAll('.owned-list-panel'));
        const sourceFilterButtons = Array.from(document.querySelectorAll('.owned-source-filter-btn'));
        let applyOwnedMapSourceFilters = null;

        function normalizeOwnedSourceLabel(value) {
            const source = String(value || 'ДТ').trim().toUpperCase();
            if (source === 'ОДХ') {
                return 'ОДХ';
            }
            if (source === 'ОЗН' || source === 'ОО') {
                return 'ОЗН';
            }
            if (odsSourceLabelNorm && source === odsSourceLabelNorm) {
                return odsSourceLabelNorm;
            }
            return 'ДТ';
        }

        function buildOwnedMapKey(rootidValue, sourceLabelValue, requestIdValue, nameValue, mapRowKeyValue) {
            const custom = String(mapRowKeyValue || '').trim().toLowerCase();
            if (custom) {
                return `${custom}|${normalizeOwnedSourceLabel(sourceLabelValue)}`;
            }
            const rid = String(rootidValue || '').trim().toLowerCase();
            const req = String(requestIdValue || '').trim().toLowerCase();
            const nm = String(nameValue || '').trim().toLowerCase();
            const entityId = rid || (req ? `req:${req}` : `name:${nm}`);
            return `${entityId}|${normalizeOwnedSourceLabel(sourceLabelValue)}`;
        }

        function getSelectedSourceSet() {
            const selected = new Set();
            sourceFilterButtons.forEach((btn) => {
                if (!btn.classList.contains('is-off')) {
                    selected.add(normalizeOwnedSourceLabel(btn.dataset.sourceFilter || 'ДТ'));
                }
            });
            return selected;
        }

        function getActiveOwnedListTab() {
            const activeBtn = listTabButtons.find((btn) => btn.classList.contains('is-active'));
            return activeBtn ? activeBtn.dataset.ownedListTab : 'passports';
        }

        function setOwnedListTab(tabName) {
            listTabButtons.forEach((btn) => {
                const isActive = btn.dataset.ownedListTab === tabName;
                btn.classList.toggle('is-active', isActive);
            });
            listPanels.forEach((panel) => {
                panel.classList.toggle('is-active', panel.dataset.listPanel === tabName);
            });
        }

        function parseOwnedGeoData() {
            if (!ownedGeoDataEl) {
                return { type: 'FeatureCollection', features: [] };
            }
            try {
                const parsed = JSON.parse(ownedGeoDataEl.textContent || '{}');
                if (parsed && parsed.type === 'FeatureCollection' && Array.isArray(parsed.features)) {
                    return parsed;
                }
            } catch (e) {
                // keep map resilient to malformed payload
            }
            return { type: 'FeatureCollection', features: [] };
        }

        function styleOwnedFeature(feature) {
            const props = feature?.properties || {};
            const sourceLabel = String(props.source_label || 'ДТ').toUpperCase();
            const rootid = String(props.rootid || '').trim();
            const requestId = String(props.request_id || '').trim();
            if (props.from_ods_registry) {
                return { color: '#7c3aed', weight: 2.5, fillOpacity: 0.26, fillColor: '#ddd6fe' };
            }
            if (!rootid && requestId) {
                return { color: '#c026d3', weight: 2.5, fillOpacity: 0.28, fillColor: '#f0abfc' };
            }
            if (odsSourceLabelNorm && sourceLabel === odsSourceLabelNorm) {
                return { color: '#9333ea', weight: 2.5, fillOpacity: 0.22, fillColor: '#e9d5ff' };
            }
            if (sourceLabel === 'ОДХ') {
                return { color: '#00bfff', weight: 2.5, fillOpacity: 0.04, fillColor: '#93c5fd' };
            }
            if (sourceLabel === 'ОЗН' || sourceLabel === 'ОО') {
                return { color: '#16a34a', weight: 2.5, fillOpacity: 0.22, fillColor: '#86efac' };
            }
            return { color: '#0284c7', weight: 2.5, fillOpacity: 0.3, fillColor: '#38bdf8' };
        }

        function initOwnedMap() {
            if (!ownedMapEl || typeof L === 'undefined') {
                return;
            }
                                                            const mapListRows = Array.from(document.querySelectorAll('.owned-passport-row, .owned-request-row'));
            const rowByKey = new Map();
            mapListRows.forEach((row) => {
                const key = buildOwnedMapKey(
                    row.dataset.mapRootid || '',
                    row.dataset.sourceLabel || 'ДТ',
                    row.dataset.requestId || '',
                    row.dataset.name || '',
                    row.dataset.mapRowKey || ''
                );
                row.dataset.mapKey = key;
                if (!rowByKey.has(key)) {
                    rowByKey.set(key, row);
                }
            });

            const map = L.map(ownedMapEl, { zoomControl: true, preferCanvas: true });
            PV.attachBasemapControl(map, { scopeRoot: ownedMapEl.parentElement });

            function parseHoodWorkAreaGeoData() {
                if (!hoodWorkAreaGeoEl) {
                    return { type: 'FeatureCollection', features: [] };
                }
                try {
                    const parsed = JSON.parse(hoodWorkAreaGeoEl.textContent || '{}');
                    if (parsed && parsed.type === 'FeatureCollection' && Array.isArray(parsed.features)) {
                        return parsed;
                    }
                    if (Array.isArray(parsed)) {
                        return { type: 'FeatureCollection', features: parsed };
                    }
                } catch (e) {
                    // ignore
                }
                return { type: 'FeatureCollection', features: [] };
            }

            const hoodWorkAreaData = parseHoodWorkAreaGeoData();
            let hoodWorkAreaLayer = null;
            if (hoodWorkAreaData.features && hoodWorkAreaData.features.length > 0) {
                hoodWorkAreaLayer = L.geoJSON(hoodWorkAreaData, {
                    interactive: false,
                    style: {
                        color: '#5c4033',
                        weight: 2,
                        opacity: 0.95,
                        fillOpacity: 0,
                        fill: false,
                    },
                });
                hoodWorkAreaLayer.addTo(map);
                hoodWorkAreaLayer.bringToBack();
            }

            const data = parseOwnedGeoData();
            const featureLayerByKey = new Map();
            const featureStyleByKey = new Map();
            const featureMetaByKey = new Map();
            let activeKey = '';
            let activeRow = null;
            let hoverKey = '';
            let hoverRow = null;

            function clearActiveRow() {
                if (activeRow) {
                    activeRow.classList.remove('is-map-focused');
                    activeRow = null;
                }
            }

            function clearActiveFeature() {
                if (!activeKey) {
                    return;
                }
                const prevLayer = featureLayerByKey.get(activeKey);
                const prevStyle = featureStyleByKey.get(activeKey);
                if (prevLayer && prevStyle && typeof prevLayer.setStyle === 'function') {
                    prevLayer.setStyle(prevStyle);
                }
                activeKey = '';
            }

            function clearHoverFeature() {
                if (!hoverKey || hoverKey === activeKey) {
                    hoverKey = '';
                    return;
                }
                const prevLayer = featureLayerByKey.get(hoverKey);
                const prevStyle = featureStyleByKey.get(hoverKey);
                if (prevLayer && prevStyle && typeof prevLayer.setStyle === 'function') {
                    prevLayer.setStyle(prevStyle);
                }
                hoverKey = '';
            }

            function clearHoverRow() {
                if (hoverRow) {
                    hoverRow.classList.remove('is-map-hovered');
                    hoverRow = null;
                }
            }

            function hoverByKey(key) {
                if (!key || key === activeKey) {
                    return;
                }
                clearHoverFeature();
                clearHoverRow();
                const layerToHover = featureLayerByKey.get(key);
                if (layerToHover && typeof layerToHover.setStyle === 'function') {
                    const baseStyle = featureStyleByKey.get(key) || {};
                    layerToHover.setStyle({
                        ...baseStyle,
                        color: '#ef4444',
                        fillColor: '#fecaca',
                        weight: Math.max(4, Number(baseStyle.weight) + 1 || 4),
                        fillOpacity: 0.45,
                    });
                    if (typeof layerToHover.bringToFront === 'function') {
                        layerToHover.bringToFront();
                    }
                    hoverKey = key;
                }
                const row = rowByKey.get(key);
                if (row) {
                    row.classList.add('is-map-hovered');
                    hoverRow = row;
                }
            }

            function focusByKey(key, source) {
                if (!key) {
                    return;
                }
                clearActiveFeature();
                clearActiveRow();

                const layerToFocus = featureLayerByKey.get(key);
                if (layerToFocus && typeof layerToFocus.setStyle === 'function') {
                    const baseStyle = featureStyleByKey.get(key) || {};
                    layerToFocus.setStyle({
                        ...baseStyle,
                        weight: Math.max(4, Number(baseStyle.weight) + 1 || 4),
                        fillOpacity: Math.max(0.34, Number(baseStyle.fillOpacity) + 0.12 || 0.34),
                    });
                    if (typeof layerToFocus.bringToFront === 'function') {
                        layerToFocus.bringToFront();
                    }
                    if (source === 'list') {
                        const bounds = layerToFocus.getBounds && layerToFocus.getBounds();
                        if (bounds && bounds.isValid && bounds.isValid()) {
                            map.fitBounds(bounds.pad(0.06));
                        }
                    }
                    if (typeof layerToFocus.openPopup === 'function') {
                        layerToFocus.openPopup();
                    }
                    activeKey = key;
                }

                const row = rowByKey.get(key);
                if (row) {
                    if (source === 'map') {
                        const rowTab = row.classList.contains('owned-request-row') ? 'requests' : 'passports';
                        setOwnedListTab(rowTab);
                        applyOwnedFilters();
                    }
                    row.classList.add('is-map-focused');
                    activeRow = row;
                    if (source === 'map') {
                        row.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                }
            }

            const layer = L.geoJSON(data, {
                style: styleOwnedFeature,
                onEachFeature: (feature, featureLayer) => {
                    const props = feature?.properties || {};
                    const key = buildOwnedMapKey(
                        props.rootid || '',
                        props.source_label || 'ДТ',
                        props.request_id || '',
                        props.name || '',
                        props.map_row_key || ''
                    );
                    featureLayerByKey.set(key, featureLayer);
                    featureStyleByKey.set(key, styleOwnedFeature(feature));
                    featureMetaByKey.set(key, {
                        sourceLabel: normalizeOwnedSourceLabel(props.source_label || 'ДТ'),
                    });
                    featureLayer.on('click', () => focusByKey(key, 'map'));
                    const idLabel = props.rootid ? '№ Паспорта' : '№ Заявки';
                    const idValue = props.rootid || props.request_id || '-';
                    let sourceDisplay = escapeHtml(props.source_label || 'ДТ');
                    if (props.from_ods_registry) {
                        const brid = String(props.brid || props.request_id || '').trim();
                        const odsLabel = escapeHtml(props.source_label || 'ОДС');
                        sourceDisplay = odsLabel + ', Заявка № ' + (brid ? escapeHtml(brid) : '—');
                    }
                    let popupHtml =
                        '<div>' +
                            '<div><strong>' + idLabel + ':</strong> ' + escapeHtml(idValue) + '</div>' +
                            '<div><strong>Название:</strong> ' + escapeHtml(props.name || '-') + '</div>' +
                            '<div><strong>Источник:</strong> ' + sourceDisplay + '</div>';
                    if (props.from_ods_registry && props.matched_source_label) {
                        popupHtml +=
                            '<div><strong>Источник GIS:</strong> ' +
                            escapeHtml(props.matched_source_label) +
                            '</div>';
                    }
                    popupHtml += buildPopupMetaFieldsHtml(props) + '</div>';
                    featureLayer.bindPopup(popupHtml);
                },
            }).addTo(map);

            const ownedBounds = layer.getBounds();
            const hoodBounds = hoodWorkAreaLayer && hoodWorkAreaLayer.getBounds ? hoodWorkAreaLayer.getBounds() : null;
            if (ownedBounds.isValid()) {
                map.fitBounds(ownedBounds.pad(0.04));
            } else if (hoodBounds && hoodBounds.isValid && hoodBounds.isValid()) {
                map.fitBounds(hoodBounds.pad(0.05));
            } else {
                map.setView([55.751244, 37.618423], 10);
            }
            // Keep requests above regular passports by default.
            layer.eachLayer((featureLayer) => {
                const props = featureLayer?.feature?.properties || {};
                const rootid = String(props.rootid || '').trim();
                const requestId = String(props.request_id || '').trim();
                if (!rootid && requestId && typeof featureLayer.bringToFront === 'function') {
                    featureLayer.bringToFront();
                }
            });
            if (hoodWorkAreaLayer && typeof hoodWorkAreaLayer.bringToBack === 'function') {
                hoodWorkAreaLayer.bringToBack();
            }
            map.attributionControl.setPrefix(
                '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> 🇷🇺'
            );

            mapListRows.forEach((row) => {
                const openBtn = row.querySelector('.owned-list-open-btn');
                if (openBtn && !openBtn.classList.contains('owned-ods-action-btn')) {
                    openBtn.addEventListener('click', () => {
                        focusByKey(row.dataset.mapKey || '', 'list');
                    });
                }
                row.addEventListener('click', (event) => {
                    if (event.target.closest('.owned-ods-action-btn')) {
                        return;
                    }
                    if (
                        event.target.closest(
                            'form.owned-open-form button[type="submit"], .owned-split-form, .owned-split-btn, .add-recap-entry-btn, .owned-confirm-open-btn, input, a, label'
                        )
                    ) {
                        return;
                    }
                    const mapKey = row.dataset.mapKey || '';
                    if (!mapKey) {
                        return;
                    }
                    if (row.classList.contains('owned-passport-row') || row.classList.contains('owned-request-row')) {
                        focusByKey(mapKey, 'list');
                    }
                });
                row.addEventListener('mouseenter', () => {
                    hoverByKey(row.dataset.mapKey || '');
                });
                row.addEventListener('mouseleave', () => {
                    clearHoverFeature();
                    clearHoverRow();
                });
            });

            function applyMapFilters() {
                const selectedSources = getSelectedSourceSet();
                featureLayerByKey.forEach((featureLayer, key) => {
                    const baseStyle = featureStyleByKey.get(key) || {};
                    const meta = featureMetaByKey.get(key) || {};
                    const isVisible = selectedSources.has(meta.sourceLabel || 'ДТ');
                    let visibleStyle = baseStyle;
                    if (key === activeKey) {
                        visibleStyle = {
                            ...baseStyle,
                            weight: Math.max(4, Number(baseStyle.weight) + 1 || 4),
                            fillOpacity: Math.max(0.34, Number(baseStyle.fillOpacity) + 0.12 || 0.34),
                        };
                    } else if (key === hoverKey) {
                        visibleStyle = {
                            ...baseStyle,
                            color: '#ef4444',
                            fillColor: '#fecaca',
                            weight: Math.max(4, Number(baseStyle.weight) + 1 || 4),
                            fillOpacity: 0.45,
                        };
                    }
                    if (typeof featureLayer.setStyle === 'function') {
                        featureLayer.setStyle(
                            isVisible
                                ? {
                                      ...visibleStyle,
                                      opacity: 1,
                                      interactive: true,
                                  }
                                : {
                                      ...baseStyle,
                                      opacity: 0,
                                      fillOpacity: 0,
                                      interactive: false,
                                  }
                        );
                    }
                    if (!isVisible && typeof featureLayer.closePopup === 'function') {
                        featureLayer.closePopup();
                    }
                });
                clearHoverFeature();
                clearHoverRow();
            }

            applyOwnedMapSourceFilters = applyMapFilters;
            applyOwnedMapSourceFilters();

            const ownedMapWrap = ownedMapEl.closest('.owned-map-wrap');
            if (ownedMapWrap && typeof ResizeObserver !== 'undefined') {
                const mapResizeObserver = new ResizeObserver(() => {
                    map.invalidateSize(false);
                });
                mapResizeObserver.observe(ownedMapWrap);
            }
        }
        initOwnedMap();

        const manualModal = document.getElementById('manual-modal');
        const manualOpenBtn = document.getElementById('manual-open-btn');
        const manualCloseBtn = document.getElementById('manual-close-btn');
        const manualCancelBtn = document.getElementById('manual-cancel-btn');
        const filterRootidEl = document.getElementById('owned-filter-rootid');
        const filterNameEl = document.getElementById('owned-filter-name');
        const filterClearEl = document.getElementById('owned-filter-clear');
        const ownedItems = Array.from(document.querySelectorAll('.owned-item'));
        const passportForms = Array.from(document.querySelectorAll('.owned-passport-row form.owned-open-form'));
        const shouldOpenManualModal = manualModal?.dataset?.openOnLoad === '1';

        function closeManualModal() {
            manualModal.style.display = 'none';
        }

        manualOpenBtn.addEventListener('click', () => {
            manualModal.style.display = 'flex';
        });
        manualCloseBtn.addEventListener('click', closeManualModal);
        manualCancelBtn.addEventListener('click', closeManualModal);

        manualModal.addEventListener('click', (event) => {
            if (event.target === manualModal) {
                closeManualModal();
            }
        });
        if (shouldOpenManualModal) {
            manualModal.style.display = 'flex';
        }

        function applyOwnedFilters() {
            const rootidNeedle = (filterRootidEl?.value || '').trim().toLowerCase();
            const nameNeedle = (filterNameEl?.value || '').trim().toLowerCase();
            const activeTab = getActiveOwnedListTab();
            const selectedSources = getSelectedSourceSet();
            ownedItems.forEach((item) => {
                const rootidValue = item.dataset.rootid || '';
                const nameValue = item.dataset.name || '';
                const sourceLabel = normalizeOwnedSourceLabel(item.dataset.sourceLabel || 'ДТ');
                const tabName = item.classList.contains('owned-request-row') ? 'requests' : 'passports';
                const rootidMatch = !rootidNeedle || rootidValue.includes(rootidNeedle);
                const nameMatch = !nameNeedle || nameValue.includes(nameNeedle);
                const sourceMatch = selectedSources.has(sourceLabel);
                const tabMatch = tabName === activeTab;
                item.style.display = rootidMatch && nameMatch && sourceMatch && tabMatch ? '' : 'none';
            });
            if (typeof applyOwnedMapSourceFilters === 'function') {
                applyOwnedMapSourceFilters();
            }
        }

        function setPassportConfirmState(form, enabled) {
            if (!form) {
                return;
            }
            const row = form.closest('.owned-passport-row');
            if (!row) {
                return;
            }
            const badge = row.querySelector('.owned-source-badge');
            const confirmBtn = row.querySelector('.owned-confirm-open-btn');
            const splitBtn = row.querySelector('.owned-split-btn');
            if (!confirmBtn) {
                return;
            }
            if (badge) {
                badge.style.display = enabled ? 'none' : '';
            }
            confirmBtn.style.display = enabled ? 'inline-flex' : 'none';
            if (splitBtn) {
                splitBtn.style.display = enabled ? 'inline-flex' : 'none';
            }
            form.dataset.confirmReady = enabled ? '1' : '0';
        }

        function clearPassportConfirmState(exceptForm) {
            passportForms.forEach((form) => {
                if (exceptForm && form === exceptForm) {
                    return;
                }
                setPassportConfirmState(form, false);
            });
        }

        if (filterRootidEl && filterNameEl) {
            filterRootidEl.addEventListener('input', applyOwnedFilters);
            filterNameEl.addEventListener('input', applyOwnedFilters);
        }
        if (filterClearEl) {
            filterClearEl.addEventListener('click', () => {
                if (filterRootidEl) {
                    filterRootidEl.value = '';
                }
                if (filterNameEl) {
                    filterNameEl.value = '';
                }
                applyOwnedFilters();
            });
        }
        listTabButtons.forEach((btn) => {
            btn.addEventListener('click', () => {
                setOwnedListTab(btn.dataset.ownedListTab || 'passports');
                applyOwnedFilters();
            });
        });
        sourceFilterButtons.forEach((btn) => {
            btn.addEventListener('click', () => {
                btn.classList.toggle('is-off');
                applyOwnedFilters();
            });
        });
        passportForms.forEach((form) => {
            const row = form.closest('.owned-passport-row');
            const confirmBtn = row ? row.querySelector('.owned-confirm-open-btn') : null;
            if (confirmBtn) {
                confirmBtn.addEventListener('click', (event) => {
                    event.preventDefault();
                    clearPassportConfirmState(form);
                    setPassportConfirmState(form, true);
                    form.requestSubmit();
                });
            }
        });
        setOwnedListTab('passports');
        applyOwnedFilters();

        const entryRequestModal = document.getElementById('entry-request-id-modal');
        const entryRequestInput = document.getElementById('entry-request-id-input');
        const entryRequestError = document.getElementById('entry-request-id-error');
        const entryRequestText = document.getElementById('entry-request-id-modal-text');
        const entryRequestTitle = document.getElementById('entry-request-id-modal-title');
        const entryGeometryDetailFieldset = document.getElementById('entry-geometry-detail-fieldset');
        const entryGeometryDetailSimplified = document.getElementById('entry-geometry-detail-simplified');
        const entryGeometryDetailFull = document.getElementById('entry-geometry-detail-full');
        const confirmPendingForm = document.getElementById('form-confirm-pending');
        const confirmPendingHidden = document.getElementById('confirm-pending-request-id');
        const prepareAddObjectForm = document.getElementById('form-prepare-add-object');
        const prepareAddObjectHidden = document.getElementById('prepare-add-object-request-id');
        const cancelPendingUrl = cfg.urls.cancelPending;
        const addRecapBaseUrl = cfg.urls.addRecap;
        let entryRequestMode = null;
        let pendingOwnedForm = null;
        let pendingOdsOpenOwned = null;

        const entryRecapModal = document.getElementById('entry-recap-id-modal');
        const entryRecapInput = document.getElementById('entry-recap-id-input');
        const entryRecapError = document.getElementById('entry-recap-id-error');
        const entryRecapSubmitBtn = document.getElementById('entry-recap-id-submit-btn');
        const entryRecapCloseBtn = document.getElementById('entry-recap-id-close-btn');
        const entryRecapCancelBtn = document.getElementById('entry-recap-id-cancel-btn');
        let pendingRecapEntryBtn = null;

        function openEntryRecapModal(fromBtn) {
            pendingRecapEntryBtn = fromBtn || null;
            if (entryRecapInput) {
                entryRecapInput.value = '';
            }
            if (entryRecapError) {
                entryRecapError.textContent = '';
            }
            if (entryRecapModal) {
                entryRecapModal.style.display = 'flex';
            }
            setTimeout(() => entryRecapInput && entryRecapInput.focus(), 0);
        }

        function closeEntryRecapModal() {
            if (entryRecapModal) {
                entryRecapModal.style.display = 'none';
            }
            pendingRecapEntryBtn = null;
        }

        function submitEntryRecapModal() {
            const raw = (entryRecapInput && entryRecapInput.value ? entryRecapInput.value : '').trim();
            if (!raw) {
                if (entryRecapError) {
                    entryRecapError.textContent = 'Введите номер досъёма.';
                }
                return;
            }
            if (!/^\d+$/.test(raw)) {
                if (entryRecapError) {
                    entryRecapError.textContent = 'Номер досъёма должен содержать только цифры.';
                }
                return;
            }
            if (entryRecapError) {
                entryRecapError.textContent = '';
            }
            const btn = pendingRecapEntryBtn;
            if (!btn || !btn.dataset) {
                closeEntryRecapModal();
                return;
            }
            const params = new URLSearchParams();
            params.set('request_id', btn.dataset.requestId || '');
            params.set('name', btn.dataset.name || '');
            params.set('object_key', btn.dataset.objectKey || '');
            params.set('source_label', btn.dataset.sourceLabel || 'ДТ');
            params.set('recap_id', raw);
            window.location.href = addRecapBaseUrl + '?' + params.toString();
        }

        document.querySelectorAll('.add-recap-entry-btn').forEach((btn) => {
            btn.addEventListener('click', () => {
                openEntryRecapModal(btn);
            });
        });
        if (entryRecapSubmitBtn) {
            entryRecapSubmitBtn.addEventListener('click', submitEntryRecapModal);
        }
        if (entryRecapCloseBtn) {
            entryRecapCloseBtn.addEventListener('click', closeEntryRecapModal);
        }
        if (entryRecapCancelBtn) {
            entryRecapCancelBtn.addEventListener('click', closeEntryRecapModal);
        }
        if (entryRecapModal) {
            entryRecapModal.addEventListener('click', (event) => {
                if (event.target === entryRecapModal) {
                    closeEntryRecapModal();
                }
            });
        }
        if (entryRecapInput) {
            entryRecapInput.addEventListener('keydown', (event) => {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    submitEntryRecapModal();
                }
            });
        }

        function getEntryGeometryDetailMode() {
            return entryGeometryDetailFull && entryGeometryDetailFull.checked ? 'full' : 'simplified';
        }

        function openEntryRequestModal(mode, opts) {
            const options = opts || {};
            entryRequestMode = mode;
            pendingOwnedForm = options.form || null;
            pendingOdsOpenOwned = null;
            if (entryRequestError) {
                entryRequestError.textContent = '';
            }
            if (entryRequestInput) {
                if (options.prefillRequestId != null && String(options.prefillRequestId).trim() !== '') {
                    entryRequestInput.value = String(options.prefillRequestId).trim();
                } else {
                    entryRequestInput.value = '';
                }
            }
            if (entryRequestTitle) {
                if (mode === 'add-object') {
                    entryRequestTitle.textContent = 'Заявка на первичную паспортизацию';
                } else if (mode === 'ods-main') {
                    entryRequestTitle.textContent = 'Открытие карты по заявке ОДС';
                } else {
                    entryRequestTitle.textContent = 'Заявка на актуализацию.';
                }
            }
            if (entryRequestText) {
                if (mode === 'pending') {
                    entryRequestText.textContent =
                        'Объект найден, но в записи нет номера заявки. Введите номер заявки, чтобы открыть редактирование.';
                } else if (mode === 'add-object') {
                    entryRequestText.textContent =
                        'Укажите номер заявки перед переходом к созданию объекта.';
                } else if (mode === 'ods-main') {
                    entryRequestText.textContent =
                        'Проверьте номер заявки и нажмите «Продолжить», чтобы открыть карту.';
                } else if (mode === 'owned') {
                    entryRequestText.textContent =
                        'У объекта не указан номер заявки в базе. Введите номер заявки, чтобы продолжить.';
                }
            }
            if (mode === 'ods-main') {
                pendingOdsOpenOwned = options.odsOpenOwned || null;
            }
            if (entryGeometryDetailFieldset) {
                const showGeometryModeChoice = mode === 'owned' || mode === 'ods-main' || mode === 'pending';
                entryGeometryDetailFieldset.style.display = showGeometryModeChoice ? 'block' : 'none';
                if (entryGeometryDetailSimplified && showGeometryModeChoice) {
                    entryGeometryDetailSimplified.checked = true;
                }
                if (entryGeometryDetailFull && !showGeometryModeChoice) {
                    entryGeometryDetailFull.checked = false;
                }
            }
            if (entryRequestModal) {
                entryRequestModal.style.display = 'flex';
            }
            setTimeout(() => entryRequestInput && entryRequestInput.focus(), 0);
        }

        function closeEntryRequestModal() {
            if (entryRequestModal) {
                entryRequestModal.style.display = 'none';
            }
            entryRequestMode = null;
            pendingOwnedForm = null;
            pendingOdsOpenOwned = null;
        }

        function handleEntryRequestCancel() {
            if (entryRequestMode === 'pending') {
                window.location.href = cancelPendingUrl;
            } else {
                closeEntryRequestModal();
            }
        }

        function submitEntryRequestModal() {
            const raw = (entryRequestInput && entryRequestInput.value ? entryRequestInput.value : '').trim();
            if (!raw) {
                if (entryRequestError) {
                    entryRequestError.textContent = 'Введите номер заявки.';
                }
                return;
            }
            if (!/^\d+$/.test(raw)) {
                if (entryRequestError) {
                    entryRequestError.textContent = 'Номер заявки должен содержать только цифры.';
                }
                return;
            }
            if (entryRequestError) {
                entryRequestError.textContent = '';
            }
            if (entryRequestMode === 'pending' && confirmPendingHidden && confirmPendingForm) {
                confirmPendingHidden.value = raw;
                const confirmPendingGeom = document.getElementById('confirm-pending-geometry-detail-mode');
                if (confirmPendingGeom) {
                    confirmPendingGeom.value = getEntryGeometryDetailMode();
                }
                confirmPendingForm.submit();
            } else if (entryRequestMode === 'ods-main' && pendingOdsOpenOwned) {
                const formOds = document.getElementById('form-ods-open-owned');
                const rootEl = document.getElementById('ods-open-owned-rootid');
                const nameEl = document.getElementById('ods-open-owned-name');
                const ridEl = document.getElementById('ods-open-owned-request-id');
                const srcEl = document.getElementById('ods-open-owned-source-label');
                const geomEl = document.getElementById('ods-open-owned-geom-mode');
                const redEl = document.getElementById('ods-open-owned-redirect-to');
                if (formOds && rootEl && nameEl && ridEl && srcEl && geomEl && redEl) {
                    rootEl.value = pendingOdsOpenOwned.rootid || '';
                    nameEl.value = pendingOdsOpenOwned.name || '';
                    ridEl.value = raw;
                    srcEl.value = pendingOdsOpenOwned.source_label || 'ДТ';
                    geomEl.value = getEntryGeometryDetailMode();
                    redEl.value = '';
                    formOds.submit();
                }
                pendingOdsOpenOwned = null;
            } else if (entryRequestMode === 'add-object' && prepareAddObjectHidden && prepareAddObjectForm) {
                prepareAddObjectHidden.value = raw;
                prepareAddObjectForm.submit();
            } else if (entryRequestMode === 'owned' && pendingOwnedForm) {
                const ridInput = pendingOwnedForm.querySelector('input[name="request_id"]');
                if (ridInput) {
                    ridInput.value = raw;
                }
                const geometryDetailInput = pendingOwnedForm.querySelector('input[name="geometry_detail_mode"]');
                if (geometryDetailInput) {
                    geometryDetailInput.value = getEntryGeometryDetailMode();
                }
                pendingOwnedForm.submit();
            }
            closeEntryRequestModal();
        }

        document.querySelectorAll('form.owned-open-form').forEach((form) => {
            form.addEventListener('submit', (e) => {
                const isPassportForm = !!form.closest('.owned-passport-row');
                if (isPassportForm && form.dataset.confirmReady !== '1') {
                    e.preventDefault();
                    clearPassportConfirmState(form);
                    setPassportConfirmState(form, true);
                    return;
                }
                if (isPassportForm) {
                    setPassportConfirmState(form, false);
                }
                if (form.dataset.needsRequestId === '1') {
                    e.preventDefault();
                    clearPassportConfirmState();
                    openEntryRequestModal('owned', { form: form });
                }
            });
        });

        const addObjectEntryBtn = document.getElementById('add-object-entry-btn');
        if (addObjectEntryBtn) {
            addObjectEntryBtn.addEventListener('click', () => {
                openEntryRequestModal('add-object');
            });
        }

        const entryRequestSubmitBtn = document.getElementById('entry-request-id-submit-btn');
        const entryRequestCloseBtn = document.getElementById('entry-request-id-close-btn');
        const entryRequestCancelBtn = document.getElementById('entry-request-id-cancel-btn');
        if (entryRequestSubmitBtn) {
            entryRequestSubmitBtn.addEventListener('click', submitEntryRequestModal);
        }
        if (entryRequestCloseBtn) {
            entryRequestCloseBtn.addEventListener('click', handleEntryRequestCancel);
        }
        if (entryRequestCancelBtn) {
            entryRequestCancelBtn.addEventListener('click', handleEntryRequestCancel);
        }
        if (entryRequestModal) {
            entryRequestModal.addEventListener('click', (event) => {
                if (event.target === entryRequestModal) {
                    handleEntryRequestCancel();
                }
            });
        }
        if (entryRequestInput) {
            entryRequestInput.addEventListener('keydown', (event) => {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    submitEntryRequestModal();
                }
            });
        }

        const mergePassportsBtn = document.getElementById('merge-passports-btn');
        const mergePassportsToolbar = document.getElementById('merge-passports-toolbar');
        const mergePassportsCancelBtn = document.getElementById('merge-passports-cancel-btn');
        const mergePassportsNextBtn = document.getElementById('merge-passports-next-btn');
        const mergeRequestModal = document.getElementById('merge-passports-request-modal');
        const mergeRequestInput = document.getElementById('merge-passports-request-input');
        const mergeRequestError = document.getElementById('merge-passports-request-error');
        const mergeRequestSubmitBtn = document.getElementById('merge-passports-request-submit-btn');
        const mergeRequestCancelBtn = document.getElementById('merge-passports-request-cancel-btn');
        const mergeRequestCloseBtn = document.getElementById('merge-passports-request-close-btn');
        const formMergePassports = document.getElementById('form-merge-passports');
        const mergeItemsContainer = document.getElementById('merge-passports-items-container');
        const mergeRequestIdHidden = document.getElementById('merge-passports-request-id-hidden');
        const mergeTargetSourceHidden = document.getElementById('merge-passports-target-source-hidden');
        const mergeTargetDtRadio = document.getElementById('merge-target-dt');
        const mergeTargetOdhRadio = document.getElementById('merge-target-odh');
        const mergeTargetOznRadio = document.getElementById('merge-target-ozn');
        const mergeTargetSourceFieldset = document.getElementById('merge-target-source-fieldset');
        const mergePassportsRequestIntro = document.getElementById('merge-passports-request-intro');
        const mergeGeometryDetailSimplified = document.getElementById('merge-geometry-detail-simplified');
        const mergeGeometryDetailFull = document.getElementById('merge-geometry-detail-full');
        const mergePassportsGeometryDetailHidden = document.getElementById('merge-passports-geometry-detail-mode');

        function getMergeGeometryDetailMode() {
            return mergeGeometryDetailFull && mergeGeometryDetailFull.checked ? 'full' : 'simplified';
        }

        let mergePassportsMode = false;
        let mergeImplicitTargetSource = '';

        function normalizeMergeSourceLabel(rawSourceLabel) {
            const sourceLabel = String(rawSourceLabel || 'ДТ').trim().toUpperCase();
            if (sourceLabel === 'ОДХ') {
                return 'ОДХ';
            }
            if (sourceLabel === 'ОЗН' || sourceLabel === 'ОО') {
                return 'ОЗН';
            }
            return 'ДТ';
        }

        function setMergePassportsMode(active) {
            mergePassportsMode = Boolean(active);
            document.body.classList.toggle('home--merge-passports', mergePassportsMode);
            if (mergePassportsToolbar) {
                mergePassportsToolbar.style.display = mergePassportsMode ? 'flex' : 'none';
            }
            document.querySelectorAll('.owned-passport-row .owned-open-form button[type="submit"]').forEach((btn) => {
                btn.disabled = mergePassportsMode;
            });
            if (!mergePassportsMode) {
                document.querySelectorAll('.merge-passport-cb').forEach((cb) => {
                    cb.checked = false;
                });
            }
        }

        function resetMergeTargetOptionRows() {
            if (!mergeTargetSourceFieldset) {
                return;
            }
            mergeTargetSourceFieldset.querySelectorAll('.merge-target-option').forEach((row) => {
                row.style.display = '';
            });
            mergeTargetSourceFieldset.style.display = 'none';
        }

        function closeMergeRequestModal() {
            if (mergeRequestModal) {
                mergeRequestModal.style.display = 'none';
            }
            if (mergeRequestInput) {
                mergeRequestInput.value = '';
            }
            if (mergeRequestError) {
                mergeRequestError.textContent = '';
            }
            if (mergeTargetDtRadio) {
                mergeTargetDtRadio.checked = false;
            }
            if (mergeTargetOdhRadio) {
                mergeTargetOdhRadio.checked = false;
            }
            if (mergeTargetOznRadio) {
                mergeTargetOznRadio.checked = false;
            }
            mergeImplicitTargetSource = '';
            resetMergeTargetOptionRows();
            if (mergeGeometryDetailSimplified) {
                mergeGeometryDetailSimplified.checked = true;
            }
            if (mergeGeometryDetailFull) {
                mergeGeometryDetailFull.checked = false;
            }
        }

        function openMergeRequestModalWithSources(sourcesSet) {
            if (mergeRequestInput) {
                mergeRequestInput.value = '';
            }
            if (mergeRequestError) {
                mergeRequestError.textContent = '';
            }
            if (mergeTargetDtRadio) {
                mergeTargetDtRadio.checked = false;
            }
            if (mergeTargetOdhRadio) {
                mergeTargetOdhRadio.checked = false;
            }
            if (mergeTargetOznRadio) {
                mergeTargetOznRadio.checked = false;
            }
            mergeImplicitTargetSource = '';
            if (mergeGeometryDetailSimplified) {
                mergeGeometryDetailSimplified.checked = true;
            }
            if (mergeGeometryDetailFull) {
                mergeGeometryDetailFull.checked = false;
            }

            if (mergeTargetSourceFieldset) {
                mergeTargetSourceFieldset.querySelectorAll('.merge-target-option').forEach((row) => {
                    row.style.display = '';
                });
            }

            if (sourcesSet.size <= 1) {
                const onlySource = sourcesSet.size === 1 ? sourcesSet.values().next().value : 'ДТ';
                mergeImplicitTargetSource = onlySource;
                resetMergeTargetOptionRows();
                if (mergePassportsRequestIntro) {
                    mergePassportsRequestIntro.textContent =
                        'Укажите номер заявки для объединённого паспорта. Все выбранные паспорта из одной таблицы — результат сохранится в той же системе.';
                }
            } else {
                mergeImplicitTargetSource = '';
                if (mergeTargetSourceFieldset) {
                    mergeTargetSourceFieldset.style.display = 'block';
                    mergeTargetSourceFieldset.querySelectorAll('.merge-target-option').forEach((row) => {
                        const rowSource = normalizeMergeSourceLabel(row.dataset.mergeSource || '');
                        const show = sourcesSet.has(rowSource);
                        row.style.display = show ? 'flex' : 'none';
                        const radio = row.querySelector('input[type="radio"]');
                        if (radio && !show) {
                            radio.checked = false;
                        }
                    });
                }
                if (mergePassportsRequestIntro) {
                    mergePassportsRequestIntro.textContent =
                        'Выбраны паспорта из разных таблиц. Укажите номер заявки и выберите, в какой из таблиц выбранных типов сохранить объединённый паспорт.';
                }
            }
            if (mergeRequestModal) {
                mergeRequestModal.style.display = 'flex';
            }
            setTimeout(() => mergeRequestInput && mergeRequestInput.focus(), 0);
        }

        function submitMergePassportsContinue() {
            const checked = Array.from(document.querySelectorAll('.merge-passport-cb:checked'));
            if (checked.length < 2) {
                window.alert('Отметьте не менее двух паспортов.');
                return;
            }
            const sources = new Set(
                checked.map((cb) => {
                    return normalizeMergeSourceLabel(cb.dataset.sourceLabel);
                })
            );
            openMergeRequestModalWithSources(sources);
        }

        function submitMergeRequestModal() {
            const raw = (mergeRequestInput && mergeRequestInput.value ? mergeRequestInput.value : '').trim();
            if (!raw) {
                if (mergeRequestError) {
                    mergeRequestError.textContent = 'Введите номер заявки.';
                }
                return;
            }
            if (!/^\d+$/.test(raw)) {
                if (mergeRequestError) {
                    mergeRequestError.textContent = 'Номер заявки должен содержать только цифры.';
                }
                return;
            }
            const checked = Array.from(document.querySelectorAll('.merge-passport-cb:checked'));
            const allowedTargetSources = new Set(
                checked.map((cb) => normalizeMergeSourceLabel(cb.dataset.sourceLabel))
            );

            let targetSourceValue = (mergeImplicitTargetSource || '').trim();
            if (targetSourceValue) {
                targetSourceValue = normalizeMergeSourceLabel(targetSourceValue);
                if (!allowedTargetSources.has(targetSourceValue)) {
                    if (mergeRequestError) {
                        mergeRequestError.textContent = 'Несогласованность выбора источников. Закройте окно и выберите паспорты заново.';
                    }
                    return;
                }
            } else {
                const targetRadio = document.querySelector(
                    '#merge-target-source-fieldset input[name="merge_target_source_ui"]:checked'
                );
                if (!targetRadio) {
                    if (mergeRequestError) {
                        mergeRequestError.textContent = 'Выберите таблицу для сохранения объединённого паспорта.';
                    }
                    return;
                }
                targetSourceValue = normalizeMergeSourceLabel(targetRadio.value);
                if (!allowedTargetSources.has(targetSourceValue)) {
                    if (mergeRequestError) {
                        mergeRequestError.textContent = 'Можно сохранить только в одну из таблиц, из которых выбраны паспорта.';
                    }
                    return;
                }
            }
            if (!mergeItemsContainer || !formMergePassports || !mergeRequestIdHidden || !mergeTargetSourceHidden) {
                return;
            }
            mergeItemsContainer.innerHTML = '';
            checked.forEach((cb) => {
                const sl = normalizeMergeSourceLabel(cb.dataset.sourceLabel);
                const rid = document.createElement('input');
                rid.type = 'hidden';
                rid.name = 'merge_item_rootid';
                rid.value = cb.value || '';
                mergeItemsContainer.appendChild(rid);
                const srcInp = document.createElement('input');
                srcInp.type = 'hidden';
                srcInp.name = 'merge_item_source';
                srcInp.value = sl;
                mergeItemsContainer.appendChild(srcInp);
            });
            mergeRequestIdHidden.value = raw;
            mergeTargetSourceHidden.value = targetSourceValue;
            if (mergePassportsGeometryDetailHidden) {
                mergePassportsGeometryDetailHidden.value = getMergeGeometryDetailMode();
            }
            formMergePassports.submit();
        }

        if (mergePassportsBtn && mergePassportsToolbar) {
            mergePassportsBtn.addEventListener('click', () => {
                setMergePassportsMode(!mergePassportsMode);
                mergePassportsBtn.classList.toggle('is-active', mergePassportsMode);
            });
        }
        if (mergePassportsCancelBtn) {
            mergePassportsCancelBtn.addEventListener('click', () => {
                setMergePassportsMode(false);
                if (mergePassportsBtn) {
                    mergePassportsBtn.classList.remove('is-active');
                }
                closeMergeRequestModal();
            });
        }
        if (mergePassportsNextBtn) {
            mergePassportsNextBtn.addEventListener('click', submitMergePassportsContinue);
        }
        if (mergeRequestSubmitBtn) {
            mergeRequestSubmitBtn.addEventListener('click', submitMergeRequestModal);
        }
        if (mergeRequestCancelBtn) {
            mergeRequestCancelBtn.addEventListener('click', closeMergeRequestModal);
        }
        if (mergeRequestCloseBtn) {
            mergeRequestCloseBtn.addEventListener('click', closeMergeRequestModal);
        }
        if (mergeRequestModal) {
            mergeRequestModal.addEventListener('click', (event) => {
                if (event.target === mergeRequestModal) {
                    closeMergeRequestModal();
                }
            });
        }
        if (mergeRequestInput) {
            mergeRequestInput.addEventListener('keydown', (event) => {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    submitMergeRequestModal();
                }
            });
        }

        const odsGisMissingModal = document.getElementById('ods-gis-missing-modal');
        const odsGisMissingOkBtn = document.getElementById('ods-gis-missing-ok-btn');

        function openOdsGisMissingModal() {
            if (odsGisMissingModal) {
                odsGisMissingModal.style.display = 'flex';
            }
        }

        function closeOdsGisMissingModal() {
            if (odsGisMissingModal) {
                odsGisMissingModal.style.display = 'none';
            }
        }

        function fillAndSubmitOdsOpenOwnedForm(ctx, requestIdVal, redirectToValue) {
            const formOds = document.getElementById('form-ods-open-owned');
            if (!formOds) {
                return;
            }
            const rootEl = document.getElementById('ods-open-owned-rootid');
            const nameEl = document.getElementById('ods-open-owned-name');
            const ridEl = document.getElementById('ods-open-owned-request-id');
            const srcEl = document.getElementById('ods-open-owned-source-label');
            const geomEl = document.getElementById('ods-open-owned-geom-mode');
            const redEl = document.getElementById('ods-open-owned-redirect-to');
            if (!rootEl || !nameEl || !ridEl || !srcEl || !geomEl || !redEl) {
                return;
            }
            rootEl.value = (ctx && ctx.rootid) || '';
            nameEl.value = (ctx && ctx.name) || '';
            ridEl.value = (requestIdVal || '').trim();
            srcEl.value = (ctx && ctx.source_label) || 'ДТ';
            geomEl.value = 'simplified';
            redEl.value = (redirectToValue || '').trim();
            formOds.submit();
        }

        if (odsGisMissingOkBtn) {
            odsGisMissingOkBtn.addEventListener('click', closeOdsGisMissingModal);
        }
        if (odsGisMissingModal) {
            odsGisMissingModal.addEventListener('click', (ev) => {
                if (ev.target === odsGisMissingModal) {
                    closeOdsGisMissingModal();
                }
            });
        }

        document.querySelectorAll('.owned-ods-action-btn').forEach((btn) => {
            btn.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                const scenario = parseInt(btn.dataset.odsScenario || '0', 10);
                const gisReady = btn.dataset.odsGisReady === '1';
                const brid = (btn.dataset.odsBrid || '').trim();
                const shortRoot = (btn.dataset.shortRoot || '').trim();
                const ctx = {
                    rootid: (btn.dataset.matchedRootid || '').trim(),
                    name: (btn.dataset.matchedName || '').trim(),
                    source_label: (btn.dataset.matchedSource || '').trim() || 'ДТ',
                };
                if (scenario === 1) {
                    openEntryRequestModal('add-object', { prefillRequestId: brid || '' });
                    return;
                }
                if (scenario === 2) {
                    if (!gisReady || !shortRoot) {
                        openOdsGisMissingModal();
                        return;
                    }
                    openEntryRequestModal('ods-main', {
                        prefillRequestId: brid || '',
                        odsOpenOwned: ctx,
                    });
                    return;
                }
                if (scenario === 3 || scenario === 4) {
                    if (!gisReady || !shortRoot) {
                        openOdsGisMissingModal();
                        return;
                    }
                }
                if (scenario === 3) {
                    fillAndSubmitOdsOpenOwnedForm(ctx, brid, 'split_object');
                    return;
                }
                if (scenario === 4) {
                    setMergePassportsMode(true);
                    if (mergePassportsBtn) {
                        mergePassportsBtn.classList.add('is-active');
                    }
                    setOwnedListTab('passports');
                    applyOwnedFilters();
                    const targetNorm = shortRoot.trim().toLowerCase();
                    document.querySelectorAll('.merge-passport-cb').forEach((cb) => {
                        const v = (cb.value || '').trim().toLowerCase();
                        cb.checked = Boolean(targetNorm) && v === targetNorm;
                    });
                    let targetRow = null;
                    document.querySelectorAll('.owned-passport-row').forEach((row) => {
                        const cb = row.querySelector('.merge-passport-cb');
                        if (!cb) {
                            return;
                        }
                        const v = (cb.value || '').trim().toLowerCase();
                        if (Boolean(targetNorm) && v === targetNorm) {
                            targetRow = row;
                        }
                    });
                    if (targetRow && typeof targetRow.scrollIntoView === 'function') {
                        targetRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                    return;
                }
                window.alert('Сценарий не определён.');
            });
        });

        const homeWorkflowModal = document.getElementById('home-workflow-modal');
        const homeWorkflowOdsRequestsBtn = document.getElementById('home-workflow-ods-requests-btn');
        const homeWorkflowPrimaryBtn = document.getElementById('home-workflow-primary-btn');
        const homeWorkflowBoundariesBtn = document.getElementById('home-workflow-boundaries-btn');
        const homeWorkflowSplitPassportBtn = document.getElementById('home-workflow-split-passport-btn');
        const homeWorkflowMergeBtn = document.getElementById('home-workflow-merge-btn');
        const homeWorkflowCloseBtn = document.getElementById('home-workflow-close-btn');

        function closeHomeWorkflowModal() {
            if (homeWorkflowModal) {
                homeWorkflowModal.style.display = 'none';
            }
        }

        if (homeWorkflowOdsRequestsBtn) {
            homeWorkflowOdsRequestsBtn.addEventListener('click', () => {
                clearHomeOghSpecialModes();
                closeHomeWorkflowModal();
                setOwnedListTab('requests');
                applyOwnedFilters();
                const requestsPanel = document.querySelector('.owned-list-panel[data-list-panel="requests"]');
                if (requestsPanel && typeof requestsPanel.scrollIntoView === 'function') {
                    requestsPanel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                }
            });
        }
        if (homeWorkflowPrimaryBtn) {
            homeWorkflowPrimaryBtn.addEventListener('click', () => {
                clearHomeOghSpecialModes();
                closeHomeWorkflowModal();
                openEntryRequestModal('add-object');
            });
        }
        if (homeWorkflowBoundariesBtn) {
            homeWorkflowBoundariesBtn.addEventListener('click', () => {
                setHomeOghBoundariesEditMode(true);
                closeHomeWorkflowModal();
            });
        }
        if (homeWorkflowSplitPassportBtn) {
            homeWorkflowSplitPassportBtn.addEventListener('click', () => {
                setHomeOghSplitPassportMode(true);
                closeHomeWorkflowModal();
            });
        }
        if (homeWorkflowMergeBtn) {
            homeWorkflowMergeBtn.addEventListener('click', () => {
                clearHomeOghSpecialModes();
                closeHomeWorkflowModal();
                if (mergePassportsBtn) {
                    mergePassportsBtn.click();
                }
            });
        }
        if (homeWorkflowCloseBtn) {
            homeWorkflowCloseBtn.addEventListener('click', closeHomeWorkflowModal);
        }
        if (homeWorkflowModal) {
            homeWorkflowModal.addEventListener('click', (event) => {
                if (event.target === homeWorkflowModal) {
                    closeHomeWorkflowModal();
                }
            });
        }

        const userGuideModal = document.getElementById('user-guide-modal');
        const userGuideOpenBtn = document.getElementById('user-guide-open-btn');
        const userGuideCloseBtn = document.getElementById('user-guide-close-btn');
        let userGuidePreviousOverflow = '';

        function openUserGuideModal() {
            if (!userGuideModal) {
                return;
            }
            userGuidePreviousOverflow = document.body.style.overflow;
            document.body.style.overflow = 'hidden';
            userGuideModal.hidden = false;
            userGuideModal.classList.add('is-open');
            if (userGuideCloseBtn) {
                userGuideCloseBtn.focus();
            }
        }

        function closeUserGuideModal() {
            if (!userGuideModal) {
                return;
            }
            userGuideModal.classList.remove('is-open');
            userGuideModal.hidden = true;
            document.body.style.overflow = userGuidePreviousOverflow;
        }

        if (userGuideOpenBtn) {
            userGuideOpenBtn.addEventListener('click', openUserGuideModal);
        }
        if (userGuideCloseBtn) {
            userGuideCloseBtn.addEventListener('click', closeUserGuideModal);
        }
        if (userGuideModal) {
            userGuideModal.addEventListener('click', (event) => {
                if (event.target === userGuideModal) {
                    closeUserGuideModal();
                }
            });
        }
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && userGuideModal && userGuideModal.classList.contains('is-open')) {
                closeUserGuideModal();
            }
        });

        if (needEntryRequestIdOnLoad) {
            openEntryRequestModal('pending');
        } else if (homeWorkflowModal) {
            homeWorkflowModal.style.display = 'flex';
            setTimeout(() => {
                const firstWorkflowBtn = homeWorkflowOdsRequestsBtn || homeWorkflowPrimaryBtn;
                if (firstWorkflowBtn && homeWorkflowModal && homeWorkflowModal.style.display === 'flex') {
                    firstWorkflowBtn.focus();
                }
            }, 0);
        }

})();

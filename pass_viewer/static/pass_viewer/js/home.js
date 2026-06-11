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
        const homeOwnerIdNorm = (homeBootstrapEl?.dataset.ownerId || '').trim();

        function getHomeOdsSyncStorageKey() {
            return homeOwnerIdNorm ? `home_ods_sync_status:${homeOwnerIdNorm}` : 'home_ods_sync_status';
        }

        function readOdsSyncSnapshot() {
            try {
                const raw = localStorage.getItem(getHomeOdsSyncStorageKey());
                if (!raw) {
                    return {};
                }
                const parsed = JSON.parse(raw);
                return parsed && typeof parsed === 'object' ? parsed : {};
            } catch (e) {
                return {};
            }
        }

        function writeOdsSyncSnapshot(map) {
            try {
                localStorage.setItem(getHomeOdsSyncStorageKey(), JSON.stringify(map));
            } catch (e) {
                // localStorage may be unavailable
            }
        }

        function collectCurrentOdsSyncStatuses() {
            const out = {};
            document.querySelectorAll('.owned-request-row[data-ods-sync-status]').forEach((row) => {
                if (row.querySelector('.owned-ods-action-btn')) {
                    return;
                }
                const status = (row.dataset.odsSyncStatus || '').trim();
                if (status !== 'ok' && status !== 'pending' && status !== 'bad') {
                    return;
                }
                const brid = (row.dataset.requestId || '').trim();
                if (brid) {
                    out[brid] = status;
                }
            });
            return out;
        }

        function buildOdsSyncChangeMessages(prev, current) {
            const messages = [];
            Object.keys(current).forEach((brid) => {
                if (prev[brid] !== 'pending') {
                    return;
                }
                const next = current[brid];
                if (next === 'ok') {
                    messages.push({ brid, kind: 'ok' });
                } else if (next === 'bad') {
                    messages.push({ brid, kind: 'bad' });
                }
            });
            messages.sort((a, b) => a.brid.localeCompare(b.brid, 'ru', { numeric: true }));
            return messages;
        }

        function renderHomeWorkflowOdsSyncChanges(messages) {
            const block = document.getElementById('home-workflow-ods-sync-block');
            const list = document.getElementById('home-workflow-ods-sync-list');
            if (!block || !list) {
                return;
            }
            list.replaceChildren();
            if (!messages.length) {
                block.hidden = true;
                return;
            }
            messages.forEach((msg) => {
                const li = document.createElement('li');
                li.className = msg.kind === 'ok'
                    ? 'home-workflow-ods-sync-item home-workflow-ods-sync-item--ok'
                    : 'home-workflow-ods-sync-item home-workflow-ods-sync-item--bad';
                li.textContent = msg.kind === 'ok'
                    ? `Заявка № ${msg.brid} подтверждена АСУ ОДС`
                    : `Заявка № ${msg.brid} не подтверждена АСУ ОДС`;
                list.appendChild(li);
            });
            block.hidden = false;
        }

        function applyHomeWorkflowOdsSyncNotifications() {
            const prev = readOdsSyncSnapshot();
            const current = collectCurrentOdsSyncStatuses();
            const messages = buildOdsSyncChangeMessages(prev, current);
            renderHomeWorkflowOdsSyncChanges(messages);
            writeOdsSyncSnapshot(current);
        }
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
            if (source === 'ТОП' || source === 'TOP') {
                return 'ТОП';
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
            if (sourceLabel === 'ТОП' || sourceLabel === 'TOP') {
                return { color: '#ea580c', weight: 2.5, fillOpacity: 0.25, fillColor: '#fb923c' };
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
                            'form.owned-open-form button[type="submit"], .owned-split-form, .owned-split-btn, .add-recap-entry-btn, .owned-recaps-open-btn, .owned-recap-download-btn, .owned-recap-delete-btn, .owned-confirm-open-btn, input, a, label'
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
        const requestStatusFilterEl = document.getElementById('owned-request-status-filter');
        let statusFilterCheckboxes = [];
        let statusDropdownTrigger = null;
        let statusDropdownPanel = null;
        let statusDropdownLabel = null;

        function getSelectedRequestStatusSet() {
            const checked = statusFilterCheckboxes.filter((cb) => cb.checked);
            if (!checked.length || checked.length === statusFilterCheckboxes.length) {
                return null;
            }
            return new Set(checked.map((cb) => (cb.value || '').trim()));
        }

        function updateStatusDropdownLabel() {
            if (!statusDropdownLabel) {
                return;
            }
            const checked = statusFilterCheckboxes.filter((cb) => cb.checked);
            if (!checked.length || checked.length === statusFilterCheckboxes.length) {
                statusDropdownLabel.textContent = 'Все статусы';
                return;
            }
            if (checked.length === 1) {
                statusDropdownLabel.textContent = checked[0].value;
                return;
            }
            statusDropdownLabel.textContent = `Выбрано: ${checked.length}`;
        }

        function setStatusDropdownOpen(isOpen) {
            if (!statusDropdownTrigger || !statusDropdownPanel) {
                return;
            }
            statusDropdownTrigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            statusDropdownPanel.hidden = !isOpen;
            statusDropdownTrigger.classList.toggle('is-open', isOpen);
        }

        function resetRequestStatusFilter() {
            statusFilterCheckboxes.forEach((cb) => {
                cb.checked = false;
            });
            updateStatusDropdownLabel();
            setStatusDropdownOpen(false);
        }

        function syncRequestStatusFilterVisibility() {
            if (!requestStatusFilterEl) {
                return;
            }
            const show =
                getActiveOwnedListTab() === 'requests' && statusFilterCheckboxes.length > 0;
            requestStatusFilterEl.hidden = !show;
            if (!show) {
                setStatusDropdownOpen(false);
            }
        }

        function initRequestStatusFilter() {
            if (!requestStatusFilterEl) {
                return;
            }
            const statuses = new Set();
            document.querySelectorAll('.owned-request-row').forEach((row) => {
                const status = (row.dataset.requestStatus || '').trim();
                if (status) {
                    statuses.add(status);
                }
            });
            const sorted = Array.from(statuses).sort((a, b) => a.localeCompare(b, 'ru'));
            requestStatusFilterEl.replaceChildren();

            const dropdown = document.createElement('div');
            dropdown.className = 'owned-status-dropdown';

            statusDropdownTrigger = document.createElement('button');
            statusDropdownTrigger.type = 'button';
            statusDropdownTrigger.className = 'owned-status-dropdown-trigger';
            statusDropdownTrigger.setAttribute('aria-haspopup', 'listbox');
            statusDropdownTrigger.setAttribute('aria-expanded', 'false');
            statusDropdownLabel = document.createElement('span');
            statusDropdownLabel.className = 'owned-status-dropdown-label';
            statusDropdownLabel.textContent = 'Все статусы';
            const chevron = document.createElement('span');
            chevron.className = 'owned-status-dropdown-chevron';
            chevron.setAttribute('aria-hidden', 'true');
            chevron.textContent = '▾';
            statusDropdownTrigger.append(statusDropdownLabel, chevron);

            statusDropdownPanel = document.createElement('div');
            statusDropdownPanel.className = 'owned-status-dropdown-panel';
            statusDropdownPanel.hidden = true;

            const list = document.createElement('ul');
            list.className = 'owned-status-dropdown-list';
            list.setAttribute('role', 'listbox');
            list.setAttribute('aria-multiselectable', 'true');

            statusFilterCheckboxes = sorted.map((status) => {
                const item = document.createElement('li');
                item.className = 'owned-status-dropdown-item';
                item.setAttribute('role', 'option');
                const label = document.createElement('label');
                label.className = 'owned-status-dropdown-option';
                const checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.value = status;
                checkbox.addEventListener('change', () => {
                    updateStatusDropdownLabel();
                    applyOwnedFilters();
                });
                const text = document.createElement('span');
                text.className = 'owned-status-dropdown-option-text';
                text.textContent = status;
                label.append(checkbox, text);
                item.appendChild(label);
                list.appendChild(item);
                return checkbox;
            });

            statusDropdownPanel.appendChild(list);
            dropdown.append(statusDropdownTrigger, statusDropdownPanel);
            requestStatusFilterEl.appendChild(dropdown);

            statusDropdownTrigger.addEventListener('click', (event) => {
                event.stopPropagation();
                const isOpen = statusDropdownTrigger.getAttribute('aria-expanded') === 'true';
                setStatusDropdownOpen(!isOpen);
            });

            statusDropdownPanel.addEventListener('click', (event) => {
                event.stopPropagation();
            });

            document.addEventListener('click', () => {
                setStatusDropdownOpen(false);
            });

            updateStatusDropdownLabel();
            syncRequestStatusFilterVisibility();
        }

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
            const selectedStatuses = getSelectedRequestStatusSet();
            ownedItems.forEach((item) => {
                const rootidValue = item.dataset.rootid || '';
                const nameValue = item.dataset.name || '';
                const sourceLabel = normalizeOwnedSourceLabel(item.dataset.sourceLabel || 'ДТ');
                const tabName = item.classList.contains('owned-request-row') ? 'requests' : 'passports';
                const rootidMatch = !rootidNeedle || rootidValue.includes(rootidNeedle);
                const nameMatch = !nameNeedle || nameValue.includes(nameNeedle);
                const sourceMatch = selectedSources.has(sourceLabel);
                const tabMatch = tabName === activeTab;
                const rowStatus = (item.dataset.requestStatus || '').trim();
                const statusMatch =
                    activeTab !== 'requests' ||
                    !rowStatus ||
                    selectedStatuses === null ||
                    selectedStatuses.has(rowStatus);
                item.style.display =
                    rootidMatch && nameMatch && sourceMatch && tabMatch && statusMatch ? '' : 'none';
            });
            syncRequestStatusFilterVisibility();
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
                resetRequestStatusFilter();
                applyOwnedFilters();
            });
        }
        initRequestStatusFilter();
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
        const listOwnedRecapsUrl = cfg.urls.listOwnedRecaps;
        const exportRecapUrl = cfg.urls.exportRecap;
        const deleteRecapUrl = cfg.urls.deleteRecap;
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

        const ownedRecapsModal = document.getElementById('owned-recaps-modal');
        const ownedRecapsListEl = document.getElementById('owned-recaps-list');
        const ownedRecapsStatusEl = document.getElementById('owned-recaps-status');
        const ownedRecapsModalTitle = document.getElementById('owned-recaps-modal-title');
        const ownedRecapsModalSubtitle = document.getElementById('owned-recaps-modal-subtitle');
        const ownedRecapsCloseBtn = document.getElementById('owned-recaps-close-btn');
        const ownedRecapsDoneBtn = document.getElementById('owned-recaps-done-btn');
        let activeOwnedRecapsBtn = null;

        function ownedRecapsEscapeHtml(value) {
            return String(value ?? '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function closeOwnedRecapsModal() {
            if (ownedRecapsModal) {
                ownedRecapsModal.style.display = 'none';
            }
            activeOwnedRecapsBtn = null;
            if (ownedRecapsListEl) {
                ownedRecapsListEl.innerHTML = '';
            }
            if (ownedRecapsStatusEl) {
                ownedRecapsStatusEl.textContent = '';
            }
        }

        function updateOwnedRecapsBadge(btn, count) {
            if (!btn) {
                return;
            }
            btn.dataset.recapCount = String(count);
            if (count > 0) {
                btn.textContent = 'Заявок на досъём: ' + count;
                return;
            }
            const span = document.createElement('span');
            span.style.cssText =
                'align-self: center; background: #eef2ff; color: #3730a3; border: 1px solid #c7d2fe; border-radius: 8px; padding: 8px 10px; font-size: 13px; white-space: nowrap;';
            span.title = 'Количество заявок на досъём в recaps с этим request_id';
            span.textContent = 'Заявок на досъём: 0';
            btn.replaceWith(span);
        }

        function renderOwnedRecapsList(recaps) {
            if (!ownedRecapsListEl) {
                return;
            }
            ownedRecapsListEl.innerHTML = '';
            recaps.forEach((recap) => {
                const row = document.createElement('div');
                row.className = 'owned-recap-row';
                row.dataset.recapId = recap.recap_id || '';
                row.style.cssText =
                    'display: flex; flex-wrap: wrap; align-items: center; gap: 8px; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 8px; background: #f8fafc;';

                const info = document.createElement('div');
                info.style.flex = '1';
                info.style.minWidth = '140px';
                info.innerHTML =
                    '<div><strong>№ досъёма:</strong> ' + ownedRecapsEscapeHtml(recap.recap_id) + '</div>' +
                    (recap.name
                        ? '<div style="font-size: 13px; color: #64748b;"><strong>Название:</strong> ' +
                          ownedRecapsEscapeHtml(recap.name) +
                          '</div>'
                        : '');

                const downloadBtn = document.createElement('button');
                downloadBtn.type = 'button';
                downloadBtn.className = 'owned-recap-download-btn';
                downloadBtn.textContent = 'Скачать';
                downloadBtn.style.cssText =
                    'background: #dbeafe; color: #1d4ed8; border: 1px solid #bfdbfe; border-radius: 8px; padding: 6px 10px; cursor: pointer; font: inherit;';
                downloadBtn.addEventListener('click', () => {
                    void downloadOwnedRecap(recap, downloadBtn, row);
                });

                const deleteBtn = document.createElement('button');
                deleteBtn.type = 'button';
                deleteBtn.className = 'owned-recap-delete-btn';
                deleteBtn.textContent = 'Удалить';
                deleteBtn.style.cssText =
                    'background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; border-radius: 8px; padding: 6px 10px; cursor: pointer; font: inherit;';
                deleteBtn.addEventListener('click', () => {
                    void deleteOwnedRecap(recap, row);
                });

                const linksEl = document.createElement('div');
                linksEl.className = 'owned-recap-download-links';
                linksEl.style.cssText = 'width: 100%; display: none; gap: 8px; flex-wrap: wrap;';

                row.appendChild(info);
                row.appendChild(downloadBtn);
                row.appendChild(deleteBtn);
                row.appendChild(linksEl);
                ownedRecapsListEl.appendChild(row);
            });
        }

        async function downloadOwnedRecap(recap, btn, row) {
            const linksEl = row.querySelector('.owned-recap-download-links');
            btn.disabled = true;
            try {
                const res = await fetch(exportRecapUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    body: JSON.stringify({ recap_id: recap.recap_id }),
                });
                const data = await res.json();
                if (!res.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось сформировать файлы.');
                }
                if (linksEl) {
                    linksEl.style.display = 'flex';
                    linksEl.innerHTML =
                        '<a class="button-link" href="' +
                        ownedRecapsEscapeHtml(data.geojson_url) +
                        '" download>Скачать GeoJSON</a> ' +
                        '<a class="button-link" href="' +
                        ownedRecapsEscapeHtml(data.shapefile_url) +
                        '">Скачать SHP (ZIP)</a>';
                }
            } catch (error) {
                window.alert(error.message || 'Ошибка скачивания.');
            } finally {
                btn.disabled = false;
            }
        }

        async function deleteOwnedRecap(recap, row) {
            if (!window.confirm('Удалить досъём № ' + (recap.recap_id || '') + '?')) {
                return;
            }
            try {
                const res = await fetch(deleteRecapUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    body: JSON.stringify({ recap_id: recap.recap_id }),
                });
                const data = await res.json();
                if (!res.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось удалить досъём.');
                }
                row.remove();
                const remaining = ownedRecapsListEl
                    ? ownedRecapsListEl.querySelectorAll('.owned-recap-row').length
                    : 0;
                if (ownedRecapsStatusEl && remaining === 0) {
                    ownedRecapsStatusEl.textContent = 'Нет сохранённых досъёмов.';
                }
                if (activeOwnedRecapsBtn) {
                    updateOwnedRecapsBadge(activeOwnedRecapsBtn, remaining);
                }
            } catch (error) {
                window.alert(error.message || 'Ошибка удаления.');
            }
        }

        async function openOwnedRecapsModal(btn) {
            activeOwnedRecapsBtn = btn;
            const requestId = btn.dataset.requestId || '';
            const requestName = btn.dataset.name || '';
            if (ownedRecapsModalTitle) {
                ownedRecapsModalTitle.textContent = 'Досъёмы по заявке № ' + requestId;
            }
            if (ownedRecapsModalSubtitle) {
                ownedRecapsModalSubtitle.textContent = requestName ? 'Объект: ' + requestName : '';
            }
            if (ownedRecapsModal) {
                ownedRecapsModal.style.display = 'flex';
            }
            if (ownedRecapsListEl) {
                ownedRecapsListEl.innerHTML = '';
            }
            if (ownedRecapsStatusEl) {
                ownedRecapsStatusEl.textContent = 'Загрузка...';
            }
            try {
                const url = listOwnedRecapsUrl + '?request_id=' + encodeURIComponent(requestId);
                const res = await fetch(url);
                const data = await res.json();
                if (!res.ok || !data.ok) {
                    throw new Error(data.error || 'Не удалось загрузить список досъёмов.');
                }
                const recaps = data.recaps || [];
                renderOwnedRecapsList(recaps);
                if (ownedRecapsStatusEl) {
                    ownedRecapsStatusEl.textContent = recaps.length ? '' : 'Нет сохранённых досъёмов.';
                }
                updateOwnedRecapsBadge(btn, recaps.length);
            } catch (error) {
                if (ownedRecapsStatusEl) {
                    ownedRecapsStatusEl.textContent = error.message || 'Ошибка загрузки.';
                }
            }
        }

        document.querySelectorAll('.owned-recaps-open-btn').forEach((btn) => {
            btn.addEventListener('click', () => {
                void openOwnedRecapsModal(btn);
            });
        });
        if (ownedRecapsCloseBtn) {
            ownedRecapsCloseBtn.addEventListener('click', closeOwnedRecapsModal);
        }
        if (ownedRecapsDoneBtn) {
            ownedRecapsDoneBtn.addEventListener('click', closeOwnedRecapsModal);
        }
        if (ownedRecapsModal) {
            ownedRecapsModal.addEventListener('click', (event) => {
                if (event.target === ownedRecapsModal) {
                    closeOwnedRecapsModal();
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
        const mergeTargetTopRadio = document.getElementById('merge-target-top');
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
            if (sourceLabel === 'ТОП' || sourceLabel === 'TOP') {
                return 'ТОП';
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
            document.querySelectorAll('.owned-request-row .owned-open-form button[type="submit"]').forEach((btn) => {
                btn.disabled = mergePassportsMode;
            });
            document.querySelectorAll('.owned-request-row .owned-ods-action-btn').forEach((btn) => {
                btn.disabled = mergePassportsMode;
            });
            if (!mergePassportsMode) {
                document.querySelectorAll('.merge-passport-cb').forEach((cb) => {
                    cb.checked = false;
                });
            }
        }

        function getMergeCheckboxPayload(cb) {
            const mergeKind = (cb.dataset.mergeKind || 'passport').trim();
            const sourceLabel = normalizeMergeSourceLabel(cb.dataset.sourceLabel);
            if (mergeKind === 'request') {
                return {
                    rootid: '',
                    objectKey: (cb.dataset.objectKey || '').trim(),
                    sourceLabel,
                };
            }
            return {
                rootid: (cb.value || '').trim(),
                objectKey: '',
                sourceLabel,
            };
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
            if (mergeTargetTopRadio) {
                mergeTargetTopRadio.checked = false;
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
            if (mergeTargetTopRadio) {
                mergeTargetTopRadio.checked = false;
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
                        'Укажите номер заявки для объединённого объекта. Все выбранные паспорта и/или заявки из одной таблицы — результат сохранится в той же системе.';
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
                        'Выбраны объекты из разных таблиц. Укажите номер заявки и выберите, в какой из таблиц выбранных типов сохранить объединённый объект.';
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
                window.alert('Отметьте не менее двух объектов (паспорта и/или заявки).');
                return;
            }
            const sources = new Set(checked.map((cb) => getMergeCheckboxPayload(cb).sourceLabel));
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
            const allowedTargetSources = new Set(checked.map((cb) => getMergeCheckboxPayload(cb).sourceLabel));

            let targetSourceValue = (mergeImplicitTargetSource || '').trim();
            if (targetSourceValue) {
                targetSourceValue = normalizeMergeSourceLabel(targetSourceValue);
                if (!allowedTargetSources.has(targetSourceValue)) {
                    if (mergeRequestError) {
                        mergeRequestError.textContent = 'Несогласованность выбора источников. Закройте окно и выберите объекты заново.';
                    }
                    return;
                }
            } else {
                const targetRadio = document.querySelector(
                    '#merge-target-source-fieldset input[name="merge_target_source_ui"]:checked'
                );
                if (!targetRadio) {
                    if (mergeRequestError) {
                        mergeRequestError.textContent = 'Выберите таблицу для сохранения объединённого объекта.';
                    }
                    return;
                }
                targetSourceValue = normalizeMergeSourceLabel(targetRadio.value);
                if (!allowedTargetSources.has(targetSourceValue)) {
                    if (mergeRequestError) {
                        mergeRequestError.textContent = 'Можно сохранить только в одну из таблиц, из которых выбраны объекты.';
                    }
                    return;
                }
            }
            if (!mergeItemsContainer || !formMergePassports || !mergeRequestIdHidden || !mergeTargetSourceHidden) {
                return;
            }
            mergeItemsContainer.innerHTML = '';
            checked.forEach((cb) => {
                const payload = getMergeCheckboxPayload(cb);
                const rid = document.createElement('input');
                rid.type = 'hidden';
                rid.name = 'merge_item_rootid';
                rid.value = payload.rootid;
                mergeItemsContainer.appendChild(rid);
                const okInp = document.createElement('input');
                okInp.type = 'hidden';
                okInp.name = 'merge_item_object_key';
                okInp.value = payload.objectKey;
                mergeItemsContainer.appendChild(okInp);
                const srcInp = document.createElement('input');
                srcInp.type = 'hidden';
                srcInp.name = 'merge_item_source';
                srcInp.value = payload.sourceLabel;
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
                    const targetNorm = shortRoot.trim().toLowerCase();
                    let targetRow = null;
                    let foundOnRequests = false;
                    document.querySelectorAll('.owned-request-row .merge-passport-cb').forEach((cb) => {
                        const v = (cb.value || '').trim().toLowerCase();
                        if (Boolean(targetNorm) && v === targetNorm) {
                            cb.checked = true;
                            foundOnRequests = true;
                            targetRow = cb.closest('.owned-request-row');
                        }
                    });
                    if (!foundOnRequests) {
                        setOwnedListTab('passports');
                        applyOwnedFilters();
                        document.querySelectorAll('.owned-passport-row .merge-passport-cb').forEach((cb) => {
                            const v = (cb.value || '').trim().toLowerCase();
                            cb.checked = Boolean(targetNorm) && v === targetNorm;
                            if (Boolean(targetNorm) && v === targetNorm) {
                                targetRow = cb.closest('.owned-passport-row');
                            }
                        });
                    } else {
                        setOwnedListTab('requests');
                        applyOwnedFilters();
                    }
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
            applyHomeWorkflowOdsSyncNotifications();
            homeWorkflowModal.style.display = 'flex';
            setTimeout(() => {
                const firstWorkflowBtn = homeWorkflowOdsRequestsBtn || homeWorkflowPrimaryBtn;
                if (firstWorkflowBtn && homeWorkflowModal && homeWorkflowModal.style.display === 'flex') {
                    firstWorkflowBtn.focus();
                }
            }, 0);
        }

})();

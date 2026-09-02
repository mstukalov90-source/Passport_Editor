(function () {
    'use strict';

    const PV = window.PassViewer || {};
    const pageConfig = (PV.getPageConfig && PV.getPageConfig()) || { urls: {} };
    const urls = pageConfig.urls || {};

    const filterToggle = document.getElementById('personal-filter-toggle');
    const filterPanel = document.getElementById('personal-filter-panel');
    const globalSearch = document.getElementById('personal-global-search');
    const table = document.querySelector('.personal-table');
    const clearButton = document.getElementById('personal-filter-clear');
    const kindFilterButtons = Array.from(document.querySelectorAll('.personal-kind-filter-btn[data-kind-filter]'));
    const KF = PV.kindFilters || {};

    function activeKindFilters() {
        if (typeof KF.activeFromButtons === 'function') {
            return KF.activeFromButtons(kindFilterButtons);
        }
        return new Set(
            kindFilterButtons
                .filter((btn) => btn.getAttribute('aria-pressed') === 'true')
                .map((btn) => btn.dataset.kindFilter)
        );
    }

    function rowMatchesKindFilter(row, active) {
        if (typeof KF.rowMatchesKindFilter === 'function') {
            return KF.rowMatchesKindFilter(row, active);
        }
        const rowKind = row.dataset.rowKind || '';
        if (!rowKind) {
            return true;
        }
        if (!active.size) {
            return true;
        }
        const passportizationKind = row.dataset.passportizationKind || '';
        if (active.has('all')) {
            return true;
        }
        if (active.has('actualization') && passportizationKind === 'Актуализация') {
            return true;
        }
        if (active.has('primary') && passportizationKind === 'Первичная') {
            return true;
        }
        if (active.has('drawn') && rowKind === 'request') {
            return true;
        }
        if (active.has('approval') && rowKind === 'approval') {
            return true;
        }
        return false;
    }

    function applyPersonalTableFilters() {
        if (!table) {
            return;
        }
        const rows = table.querySelectorAll('tbody tr');
        const inputs = filterPanel ? filterPanel.querySelectorAll('input[data-filter-col]') : [];
        const active = activeKindFilters();
        rows.forEach((row) => {
            if (!rowMatchesKindFilter(row, active)) {
                row.hidden = true;
                return;
            }
            const cells = row.querySelectorAll('td');
            const columnMismatch = Array.from(inputs).some((input) => {
                const value = input.value.trim().toLocaleLowerCase('ru');
                if (!value) return false;
                const cell = cells[Number(input.dataset.filterCol)];
                return !cell || !cell.textContent.toLocaleLowerCase('ru').includes(value);
            });
            if (columnMismatch) {
                row.hidden = true;
                return;
            }
            const query = globalSearch ? globalSearch.value.trim().toLocaleLowerCase('ru') : '';
            if (!query) {
                row.hidden = false;
                return;
            }
            let matchesGlobal = false;
            for (let index = 1; index <= 8; index += 1) {
                const cell = cells[index];
                if (cell && cell.textContent.toLocaleLowerCase('ru').includes(query)) {
                    matchesGlobal = true;
                    break;
                }
            }
            row.hidden = !matchesGlobal;
        });
        renumberVisiblePersonalRows();
        updateKindFilterCounts();
    }

    function updateKindFilterCounts() {
        const rows = table
            ? Array.from(table.querySelectorAll('tbody tr')).filter((row) => row.dataset.rowKind)
            : [];
        kindFilterButtons.forEach((btn) => {
            const countEl = btn.querySelector('.personal-kind-filter-count');
            const key = btn.dataset.kindFilter;
            if (!countEl || !key) {
                return;
            }
            const n = rows.filter((row) => rowMatchesKindFilter(row, new Set([key]))).length;
            countEl.textContent = String(n);
        });
    }

    function renumberVisiblePersonalRows() {
        if (!table) {
            return;
        }
        let index = 0;
        table.querySelectorAll('tbody tr').forEach((row) => {
            const cell = row.querySelector('td.personal-row-num');
            if (!cell) {
                return;
            }
            if (row.hidden || !row.dataset.rowKind) {
                cell.textContent = '';
                return;
            }
            index += 1;
            cell.textContent = String(index);
        });
    }

    if (table) {
        const inputs = filterPanel ? filterPanel.querySelectorAll('input[data-filter-col]') : [];
        if (typeof KF.bindKindFilters === 'function' && kindFilterButtons.length) {
            KF.bindKindFilters(kindFilterButtons, applyPersonalTableFilters);
        } else {
            applyPersonalTableFilters();
        }
        if (filterToggle && filterPanel) {
            filterToggle.addEventListener('click', () => {
                const open = filterPanel.hidden;
                filterPanel.hidden = !open;
                filterToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
            });
        }
        inputs.forEach((input) => input.addEventListener('input', applyPersonalTableFilters));
        globalSearch?.addEventListener('input', applyPersonalTableFilters);
        clearButton?.addEventListener('click', () => {
            inputs.forEach((input) => { input.value = ''; });
            if (globalSearch) {
                globalSearch.value = '';
            }
            applyPersonalTableFilters();
        });
    }

    const modal = document.getElementById('personal-detail-modal');
    const closeButton = document.getElementById('personal-detail-close');
    const asuOdsLink = document.getElementById('personal-asu-ods-link');
    const openForm = document.getElementById('personal-open-form');
    const viewObjectModal = document.getElementById('owned-view-object-modal');
    const viewObjectFrame = document.getElementById('owned-view-object-frame');
    const viewObjectStatus = document.getElementById('owned-view-object-status');
    const viewObjectCloseBtn = document.getElementById('owned-view-object-close-btn');
    const viewObjectAnalizBtn = document.getElementById('owned-view-object-analiz-btn');
    const viewObjectBeskhozBtn = document.getElementById('owned-view-object-beskhoz-btn');
    const viewObjectLoading = document.getElementById('owned-view-object-loading');
    const field = (id) => document.getElementById(id);

    let detailMap = null;
    let detailLayer = null;
    let detailsRequestSeq = 0;
    let currentViewObjectProps = null;

    function csrfToken() {
        if (PV.getCookie) {
            const fromCookie = PV.getCookie('csrftoken');
            if (fromCookie) return fromCookie;
        }
        const input = document.querySelector('#personal-open-form input[name="csrfmiddlewaretoken"]');
        return input ? input.value : '';
    }

    function parseJson(response) {
        if (PV.parseJsonResponse) {
            return PV.parseJsonResponse(response);
        }
        return response.json();
    }

    function fillText(id, value) {
        const node = field(id);
        if (node) node.textContent = value || '—';
    }

    function setAsuOdsLinkEnabled(enabled, rootid, sourceLabel) {
        if (!asuOdsLink) return;
        if (enabled && rootid) {
            asuOdsLink.disabled = false;
            asuOdsLink.classList.remove('is-disabled');
            asuOdsLink.dataset.rootid = rootid;
            asuOdsLink.dataset.source = sourceLabel || 'ДТ';
        } else {
            asuOdsLink.disabled = true;
            asuOdsLink.classList.add('is-disabled');
            asuOdsLink.removeAttribute('data-rootid');
            asuOdsLink.removeAttribute('data-source');
        }
    }

    function clearDetailMap() {
        if (detailMap && detailLayer) {
            detailMap.removeLayer(detailLayer);
            detailLayer = null;
        }
    }

    function ensureDetailMap() {
        const el = document.getElementById('personal-detail-map');
        if (!el || typeof L === 'undefined') {
            return null;
        }
        if (!detailMap) {
            detailMap = L.map(el, {
                zoomControl: false,
                attributionControl: false,
                maxZoom: 30,
            });
            if (PV.attachBasemapControl) {
                PV.attachBasemapControl(detailMap, { scopeRoot: el.parentElement });
            } else if (PV.createBasemapLayers) {
                const { mggtLayer } = PV.createBasemapLayers();
                mggtLayer.addTo(detailMap);
            }
            if (PV.attachMapUtilityControls) {
                PV.attachMapUtilityControls(detailMap);
            }
            detailMap.setView([55.75, 37.62], 10);
        }
        return detailMap;
    }

    function renderDetailGeometry(geometry) {
        const map = ensureDetailMap();
        if (!map) return;
        clearDetailMap();
        if (!geometry) {
            map.invalidateSize();
            return;
        }
        detailLayer = L.geoJSON(geometry, {
            style: { color: '#2563eb', weight: 2, fillColor: '#60a5fa', fillOpacity: 0.25 },
        }).addTo(map);
        const bounds = detailLayer.getBounds();
        if (bounds.isValid()) {
            map.fitBounds(bounds, { padding: [12, 12], maxZoom: 17 });
        }
        window.requestAnimationFrame(() => map.invalidateSize());
        window.setTimeout(() => map.invalidateSize(), 80);
    }

    function closeModal() {
        detailsRequestSeq += 1;
        if (modal) modal.style.display = 'none';
        if (objectToggle) objectToggle.hidden = true;
        clearDetailMap();
        setAsuOdsLinkEnabled(false);
    }

    function setOwnedViewObjectLoading(isLoading, message) {
        if (viewObjectLoading) {
            if (isLoading) {
                viewObjectLoading.hidden = false;
                const label = viewObjectLoading.querySelector('span');
                if (label && message) {
                    label.textContent = message;
                }
            } else {
                viewObjectLoading.hidden = true;
            }
        }
        if (viewObjectStatus) {
            viewObjectStatus.textContent = isLoading ? (message || 'Загрузка карты…') : '';
        }
    }

    function syncViewObjectAnalizBtn() {
        const p = currentViewObjectProps || {};
        const show = Boolean(
            String(p.rootid || '').trim() ||
            String(p.request_id || '').trim() ||
            String(p.name || '').trim()
        );
        if (viewObjectAnalizBtn) {
            viewObjectAnalizBtn.hidden = !show;
        }
        if (viewObjectBeskhozBtn) {
            viewObjectBeskhozBtn.hidden = !show;
        }
    }

    function closeOwnedViewObjectModal() {
        currentViewObjectProps = null;
        syncViewObjectAnalizBtn();
        if (viewObjectModal) {
            viewObjectModal.classList.remove('is-open');
            viewObjectModal.style.display = 'none';
        }
        if (viewObjectFrame) {
            viewObjectFrame.src = 'about:blank';
        }
        setOwnedViewObjectLoading(false);
    }

    function openOwnedViewObjectModal(url) {
        if (!viewObjectModal || !viewObjectFrame) {
            return;
        }
        setOwnedViewObjectLoading(true, 'Загрузка карты и слоёв…');
        viewObjectModal.style.display = 'flex';
        viewObjectModal.classList.add('is-open');
        viewObjectFrame.onload = () => {
            setOwnedViewObjectLoading(false);
            try {
                const childWin = viewObjectFrame.contentWindow;
                if (childWin) {
                    childWin.dispatchEvent(new Event('resize'));
                }
            } catch (e) {
                // same-origin main page
            }
        };
        viewObjectFrame.src = url;
    }

    async function openOwnedObjectForView(props) {
        const openOwnedUrl = urls.openOwned;
        if (!openOwnedUrl) {
            window.alert('URL открытия объекта не настроен.');
            return;
        }
        const rootid = String((props && props.rootid) || '').trim();
        const requestId = String((props && props.request_id) || '').trim();
        const name = String((props && props.name) || '').trim();
        const sourceLabel = String(
            (props && (props.source_label || props.source)) || 'ДТ'
        ).trim() || 'ДТ';
        if (!rootid && !requestId && !name) {
            window.alert('Не удалось определить объект для просмотра.');
            return;
        }
        currentViewObjectProps = {
            rootid,
            request_id: requestId,
            name,
            source_label: sourceLabel,
        };
        syncViewObjectAnalizBtn();
        const body = new URLSearchParams();
        body.set('rootid', rootid);
        body.set('request_id', requestId);
        body.set('name', name);
        body.set('source_label', sourceLabel);
        body.set('geometry_detail_mode', rootid ? 'simplified' : 'full');
        body.set('view_only', '1');
        body.set('format', 'json');
        if (viewObjectModal) {
            viewObjectModal.style.display = 'flex';
            viewObjectModal.classList.add('is-open');
        }
        setOwnedViewObjectLoading(true, 'Подготовка просмотра…');
        try {
            const response = await fetch(openOwnedUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    Accept: 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRFToken': csrfToken(),
                },
                body: body.toString(),
                credentials: 'same-origin',
            });
            const data = await parseJson(response);
            if (!response.ok || !data || !data.ok || !data.url) {
                const err = (data && data.error) || 'Не удалось открыть объект для просмотра.';
                setOwnedViewObjectLoading(false);
                if (viewObjectStatus) {
                    viewObjectStatus.textContent = err;
                } else {
                    window.alert(err);
                }
                return;
            }
            openOwnedViewObjectModal(data.url);
        } catch (error) {
            setOwnedViewObjectLoading(false);
            const err = 'Ошибка сети при открытии просмотра.';
            if (viewObjectStatus) {
                viewObjectStatus.textContent = err;
            }
            console.error('personal-account: open owned object failed', error);
        }
    }

    async function resolveAndOpenAsuOds(rootid, sourceLabel) {
        const endpoint = urls.resolveAsuOdsUrl;
        if (!endpoint || !rootid) {
            return;
        }
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': csrfToken(),
                },
                body: JSON.stringify({
                    rootid,
                    source_label: sourceLabel || 'ДТ',
                }),
            });
            const data = await parseJson(response);
            const href = data && data.ok ? String(data.asu_ods_url || '').trim() : '';
            if (href) {
                window.open(href, '_blank', 'noopener');
            }
        } catch (error) {
            console.error('personal-account: resolve ASU ODS URL failed', error);
        }
    }

    const objectToggle = document.getElementById('personal-detail-object-toggle');
    const passportModeBtn = document.getElementById('personal-detail-mode-passport');
    const requestModeBtn = document.getElementById('personal-detail-mode-request');
    let detailContext = {
        passportRootid: '',
        displayRootid: '',
        drawnRequestId: '',
        displayRequestId: '',
        name: '',
        source: 'ДТ',
        drawnSource: '',
        status: '—',
        hasDrawnRequest: false,
        mode: 'passport',
    };

    function setDetailModeButtons(mode) {
        const isPassport = mode === 'passport';
        passportModeBtn?.classList.toggle('is-active', isPassport);
        requestModeBtn?.classList.toggle('is-active', !isPassport);
        passportModeBtn?.setAttribute('aria-pressed', isPassport ? 'true' : 'false');
        requestModeBtn?.setAttribute('aria-pressed', isPassport ? 'false' : 'true');
    }

    function applyDetailMode(mode) {
        detailContext.mode = mode;
        setDetailModeButtons(mode);
        const isPassport = mode === 'passport';
        const rootid = isPassport ? (detailContext.passportRootid || detailContext.displayRootid) : '';
        const requestId = isPassport ? '' : (detailContext.drawnRequestId || detailContext.displayRequestId);
        const sourceLabel = isPassport
            ? detailContext.source
            : (detailContext.drawnSource || detailContext.source);
        const seq = detailsRequestSeq + 1;
        detailsRequestSeq = seq;
        if (field('personal-open-rootid')) field('personal-open-rootid').value = rootid;
        if (field('personal-open-request-id')) field('personal-open-request-id').value = requestId;
        if (field('personal-open-source')) field('personal-open-source').value = sourceLabel;
        fillText('detail-passport-id', rootid || requestId);
        renderDetailGeometry(null);
        loadObjectDetails(rootid, sourceLabel, seq, requestId);
    }

    async function loadObjectDetails(rootid, sourceLabel, seq, requestId) {
        const endpoint = urls.personalObjectDetails;
        const rid = String(rootid || '').trim();
        const reqId = String(requestId || '').trim();
        if (!endpoint || (!rid && !reqId)) {
            return;
        }
        const body = { source_label: sourceLabel || 'ДТ' };
        if (rid) {
            body.rootid = rid;
        } else {
            body.request_id = reqId;
        }
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': csrfToken(),
                },
                body: JSON.stringify(body),
            });
            const data = await parseJson(response);
            if (seq !== detailsRequestSeq) {
                return;
            }
            if (!data || !data.ok) {
                fillText('detail-approval-date', '—');
                fillText('detail-owner', '—');
                fillText('detail-oiv', '—');
                fillText('detail-area', '—');
                renderDetailGeometry(null);
                return;
            }
            fillText('detail-approval-date', data.approval_date);
            fillText('detail-owner', data.owner_name);
            fillText('detail-oiv', data.oiv_name);
            fillText('detail-area', data.area_label);
            renderDetailGeometry(data.geometry);
        } catch (error) {
            if (seq !== detailsRequestSeq) {
                return;
            }
            console.error('personal-account: object details failed', error);
            fillText('detail-approval-date', '—');
            fillText('detail-owner', '—');
            fillText('detail-oiv', '—');
            fillText('detail-area', '—');
            renderDetailGeometry(null);
        }
    }

    document.querySelectorAll('.personal-asu-ods-open').forEach((button) => {
        button.addEventListener('click', () => {
            resolveAndOpenAsuOds(button.dataset.rootid, button.dataset.source);
        });
    });

    asuOdsLink?.addEventListener('click', () => {
        if (asuOdsLink.disabled) return;
        resolveAndOpenAsuOds(asuOdsLink.dataset.rootid, asuOdsLink.dataset.source);
    });

    document.querySelectorAll('.personal-detail-open').forEach((button) => {
        button.addEventListener('click', () => {
            const sourceLabel = button.dataset.source || 'ДТ';
            const displayRootid = button.dataset.id || '';
            const passportRootid = (button.dataset.passportRootid || '').trim();
            const displayRequestId = button.dataset.requestId || '';
            const drawnRequestId = (button.dataset.drawnRequestId || '').trim();
            const drawnSource = (button.dataset.drawnSource || '').trim();
            const hasDrawnRequest = button.dataset.hasDrawnRequest === '1' && Boolean(passportRootid) && Boolean(drawnRequestId);
            detailContext = {
                passportRootid,
                displayRootid,
                drawnRequestId,
                displayRequestId,
                name: button.dataset.name || '',
                source: sourceLabel,
                drawnSource,
                status: button.dataset.status || '—',
                hasDrawnRequest,
                mode: passportRootid || displayRootid ? 'passport' : 'request',
            };
            fillText('detail-passport-name', button.dataset.name);
            fillText('detail-approval-date', '—');
            fillText('detail-owner', '—');
            fillText('detail-oiv', '—');
            fillText('detail-area', '—');
            fillText('detail-status', button.dataset.status);
            if (field('personal-open-name')) field('personal-open-name').value = button.dataset.name || '';
            setAsuOdsLinkEnabled(sourceLabel !== 'ТОП' && sourceLabel !== 'TOP', passportRootid || displayRootid, sourceLabel);
            if (objectToggle) objectToggle.hidden = !hasDrawnRequest;
            if (modal) modal.style.display = 'flex';
            if (hasDrawnRequest) {
                applyDetailMode('passport');
                return;
            }
            const seq = detailsRequestSeq + 1;
            detailsRequestSeq = seq;
            fillText('detail-passport-id', displayRootid || displayRequestId);
            if (field('personal-open-rootid')) field('personal-open-rootid').value = displayRootid;
            if (field('personal-open-request-id')) field('personal-open-request-id').value = displayRequestId;
            if (field('personal-open-source')) field('personal-open-source').value = sourceLabel;
            renderDetailGeometry(null);
            loadObjectDetails(displayRootid, sourceLabel, seq, displayRootid ? '' : displayRequestId);
        });
    });

    passportModeBtn?.addEventListener('click', () => applyDetailMode('passport'));
    requestModeBtn?.addEventListener('click', () => applyDetailMode('request'));

    const checkDgiModal = document.getElementById('check-dgi-modal');
    const checkDgiModalBody = document.getElementById('check-dgi-modal-body');
    const checkDgiModalClose = document.getElementById('check-dgi-modal-close');
    const checkDgiAnalizBtn = document.getElementById('check-dgi-analiz-btn');
    const checkDgiViewObjectBtn = document.getElementById('check-dgi-view-object-btn');
    const dgiChooseModal = document.getElementById('personal-dgi-choose-modal');
    const dgiChoosePassportBtn = document.getElementById('personal-dgi-choose-passport');
    const dgiChooseRequestBtn = document.getElementById('personal-dgi-choose-request');
    const dgiChooseCancelBtn = document.getElementById('personal-dgi-choose-cancel');
    const checkDgiUrl = urls.checkDgi || '';
    const intersecsAnalizUrl = urls.intersecsAnaliz || '';
    let checkDgiViewObjectProps = null;
    let lastCheckDgiContext = null;
    let pendingDgiCheck = null;

    function normalizeCheckGeometry(geometry) {
        if (!geometry || typeof geometry !== 'object') {
            return null;
        }
        if (geometry.type === 'Feature') {
            return geometry.geometry || null;
        }
        if (geometry.type === 'FeatureCollection') {
            const features = Array.isArray(geometry.features) ? geometry.features : [];
            const geoms = features.map((item) => (item && item.geometry) || null).filter(Boolean);
            if (!geoms.length) {
                return null;
            }
            if (geoms.length === 1) {
                return geoms[0];
            }
            return { type: 'GeometryCollection', geometries: geoms };
        }
        if (geometry.type) {
            return geometry;
        }
        return null;
    }

    function setCheckDgiAnalizContext(ctx) {
        const hasPayload = !!(
            ctx &&
            (ctx.geometry || String(ctx.rootid || '').trim() || String(ctx.request_id || '').trim())
        );
        lastCheckDgiContext = hasPayload ? ctx : null;
        if (PV.setCheckDgiAnalizEnabled) {
            PV.setCheckDgiAnalizEnabled(checkDgiAnalizBtn, hasPayload);
        } else if (checkDgiAnalizBtn) {
            checkDgiAnalizBtn.style.display = hasPayload ? '' : 'none';
            checkDgiAnalizBtn.disabled = !hasPayload;
        }
    }

    function setCheckDgiViewObjectProps(props) {
        const rootid = String((props && props.rootid) || '').trim();
        const requestId = String((props && props.request_id) || '').trim();
        const name = String((props && props.name) || '').trim();
        const sourceLabel = String((props && props.source_label) || '').trim();
        if (!rootid && !requestId && !name) {
            checkDgiViewObjectProps = null;
            if (checkDgiViewObjectBtn) {
                checkDgiViewObjectBtn.style.display = 'none';
            }
            return;
        }
        checkDgiViewObjectProps = {
            rootid,
            request_id: requestId,
            name,
            source_label: sourceLabel || 'ДТ',
        };
        if (checkDgiViewObjectBtn) {
            checkDgiViewObjectBtn.style.display = '';
        }
    }

    function closeCheckDgiModal() {
        if (checkDgiModal) {
            checkDgiModal.style.display = 'none';
        }
        setCheckDgiAnalizContext(null);
        setCheckDgiViewObjectProps(null);
    }

    function closeDgiChooseModal() {
        if (dgiChooseModal) {
            dgiChooseModal.style.display = 'none';
        }
        pendingDgiCheck = null;
    }

    function openCheckDgiModalShell(bodyText) {
        if (!checkDgiModal || !checkDgiModalBody) {
            return;
        }
        if (bodyText != null) {
            checkDgiModalBody.textContent = bodyText;
            setCheckDgiAnalizContext(null);
            setCheckDgiViewObjectProps(null);
        }
        checkDgiModal.style.display = 'flex';
    }

    function showCheckDgiModal(data, viewProps, geometry) {
        if (!checkDgiModal || !checkDgiModalBody) {
            return;
        }
        if (data && data.intersects && PV.buildCheckDgiModalHtml) {
            checkDgiModalBody.innerHTML = PV.buildCheckDgiModalHtml(data);
        } else {
            checkDgiModalBody.textContent = 'Пересечений с объектами ДГИ и инфоресурсами не обнаружено.';
        }
        const props = viewProps || {};
        setCheckDgiAnalizContext({
            geometry: geometry || null,
            percents: data,
            rootid: props.rootid || '',
            request_id: props.request_id || '',
            source_label: props.source_label || '',
            name: props.name || '',
        });
        setCheckDgiViewObjectProps(viewProps);
        openCheckDgiModalShell();
    }

    async function fetchPersonalGeometry(rootid, requestId, sourceLabel) {
        const endpoint = urls.personalObjectDetails;
        const rid = String(rootid || '').trim();
        const reqId = String(requestId || '').trim();
        if (!endpoint || (!rid && !reqId)) {
            return null;
        }
        const body = { source_label: sourceLabel || 'ДТ' };
        if (rid) {
            body.rootid = rid;
        } else {
            body.request_id = reqId;
        }
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': csrfToken(),
            },
            body: JSON.stringify(body),
        });
        const data = await parseJson(response);
        if (!response.ok || !data || !data.ok) {
            throw new Error((data && data.error) || 'Не удалось загрузить геометрию объекта.');
        }
        return data.geometry || null;
    }

    async function runPersonalDgiCheck({ rootid, requestId, sourceLabel, name, triggerBtn }) {
        if (!checkDgiUrl) {
            openCheckDgiModalShell('URL проверки пересечений с ДГИ не настроен.');
            return;
        }
        if (triggerBtn) {
            triggerBtn.disabled = true;
        }
        openCheckDgiModalShell('Проверяем пересечения…');
        const viewProps = {
            rootid: rootid || '',
            request_id: requestId || '',
            name: name || '',
            source_label: sourceLabel || 'ДТ',
        };
        try {
            const geometry = normalizeCheckGeometry(
                await fetchPersonalGeometry(rootid, requestId, sourceLabel)
            );
            if (!geometry) {
                openCheckDgiModalShell('Геометрия объекта недоступна для проверки.');
                return;
            }
            const response = await fetch(checkDgiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': csrfToken(),
                },
                credentials: 'same-origin',
                body: JSON.stringify({
                    geometry,
                    rootid: rootid || '',
                    source_label: sourceLabel || 'ДТ',
                }),
            });
            const data = await parseJson(response);
            if (!response.ok || !data || !data.ok) {
                throw new Error((data && data.error) || 'Ошибка проверки пересечений с ДГИ.');
            }
            showCheckDgiModal(data, viewProps, geometry);
        } catch (error) {
            openCheckDgiModalShell(error.message || 'Не удалось проверить пересечения с ДГИ.');
        } finally {
            if (triggerBtn) {
                triggerBtn.disabled = false;
            }
        }
    }

    function dgiTargetsFromButton(button) {
        const passportRootid = (button.dataset.passportRootid || '').trim();
        const displayRootid = (button.dataset.id || '').trim();
        const drawnRequestId = (button.dataset.drawnRequestId || '').trim();
        const displayRequestId = (button.dataset.requestId || '').trim();
        const sourceLabel = button.dataset.source || 'ДТ';
        const drawnSource = (button.dataset.drawnSource || '').trim() || sourceLabel;
        const name = button.dataset.name || '';
        const hasDrawnRequest = button.dataset.hasDrawnRequest === '1' && Boolean(passportRootid) && Boolean(drawnRequestId);
        const rootid = passportRootid || displayRootid;
        const requestId = hasDrawnRequest ? drawnRequestId : (rootid ? '' : displayRequestId);
        return { hasDrawnRequest, rootid, requestId, drawnRequestId, sourceLabel, drawnSource, name, triggerBtn: button };
    }

    document.querySelectorAll('.personal-dgi-check').forEach((button) => {
        button.addEventListener('click', () => {
            const targets = dgiTargetsFromButton(button);
            if (targets.hasDrawnRequest) {
                pendingDgiCheck = targets;
                if (dgiChooseModal) {
                    dgiChooseModal.style.display = 'flex';
                }
                return;
            }
            void runPersonalDgiCheck(targets);
        });
    });

    dgiChoosePassportBtn?.addEventListener('click', () => {
        const targets = pendingDgiCheck;
        closeDgiChooseModal();
        if (!targets) {
            return;
        }
        void runPersonalDgiCheck({
            rootid: targets.rootid,
            requestId: '',
            sourceLabel: targets.sourceLabel,
            name: targets.name,
            triggerBtn: targets.triggerBtn,
        });
    });
    dgiChooseRequestBtn?.addEventListener('click', () => {
        const targets = pendingDgiCheck;
        closeDgiChooseModal();
        if (!targets) {
            return;
        }
        void runPersonalDgiCheck({
            rootid: '',
            requestId: targets.drawnRequestId,
            sourceLabel: targets.drawnSource,
            name: targets.name,
            triggerBtn: targets.triggerBtn,
        });
    });
    dgiChooseCancelBtn?.addEventListener('click', closeDgiChooseModal);
    dgiChooseModal?.addEventListener('click', (event) => {
        if (event.target === dgiChooseModal) {
            closeDgiChooseModal();
        }
    });
    checkDgiModalClose?.addEventListener('click', closeCheckDgiModal);
    checkDgiAnalizBtn?.addEventListener('click', (event) => {
        event.preventDefault();
        if (!lastCheckDgiContext || !PV.openIntersecsAnalizPage) {
            return;
        }
        PV.openIntersecsAnalizPage({
            pageUrl: intersecsAnalizUrl,
            ...lastCheckDgiContext,
        });
    });
    checkDgiModal?.addEventListener('click', (event) => {
        if (event.target === checkDgiModal) {
            closeCheckDgiModal();
        }
    });
    checkDgiViewObjectBtn?.addEventListener('click', (event) => {
        event.preventDefault();
        const props = checkDgiViewObjectProps;
        if (!props) {
            return;
        }
        closeCheckDgiModal();
        openOwnedObjectForView(props);
    });

    closeButton?.addEventListener('click', closeModal);
    modal?.addEventListener('click', (event) => {
        if (event.target === modal || event.target.classList.contains('personal-modal__overlay')) closeModal();
    });
    openForm?.addEventListener('submit', (event) => {
        event.preventDefault();
        openOwnedObjectForView({
            rootid: field('personal-open-rootid')?.value || '',
            name: field('personal-open-name')?.value || '',
            request_id: field('personal-open-request-id')?.value || '',
            source_label: field('personal-open-source')?.value || 'ДТ',
        });
    });
    const drawForm = document.getElementById('personal-draw-form');
    const drawChoiceModal = document.getElementById('personal-draw-choice-modal');
    const drawRequestModal = document.getElementById('personal-draw-request-modal');
    const drawRequestInput = document.getElementById('personal-draw-request-input');
    const drawRequestError = document.getElementById('personal-draw-request-error');
    let pendingDrawPayload = null;

    function setModalOpen(modal, open) {
        if (!modal) {
            return;
        }
        modal.style.display = open ? 'flex' : 'none';
    }

    function closeDrawChoiceModal() {
        setModalOpen(drawChoiceModal, false);
    }

    function closeDrawRequestModal() {
        setModalOpen(drawRequestModal, false);
        if (drawRequestError) {
            drawRequestError.textContent = '';
        }
        if (drawRequestInput) {
            drawRequestInput.value = '';
        }
    }

    function submitDrawForm(payload) {
        if (!drawForm) {
            window.alert('Форма открытия объекта не найдена.');
            return;
        }
        const rootid = String((payload && payload.rootid) || '').trim();
        const name = String((payload && payload.name) || '').trim();
        const requestId = String((payload && payload.requestId) || '').trim();
        const sourceLabel = String((payload && payload.sourceLabel) || 'ДТ').trim() || 'ДТ';
        const geometryMode = String((payload && payload.geometryMode) || 'full').trim() || 'full';
        const redirectTo = String((payload && payload.redirectTo) || '').trim();
        document.getElementById('personal-draw-rootid').value = rootid;
        document.getElementById('personal-draw-name').value = name;
        document.getElementById('personal-draw-request-id').value = requestId;
        document.getElementById('personal-draw-source').value = sourceLabel;
        document.getElementById('personal-draw-geom-mode').value = geometryMode;
        document.getElementById('personal-draw-redirect-to').value = redirectTo;
        drawForm.submit();
    }

    function payloadFromDrawButton(btn) {
        const requestId = String(btn.dataset.requestId || '').trim();
        const drawnRequestId = String(btn.dataset.drawnRequestId || '').trim();
        return {
            rootid: String(btn.dataset.rootid || '').trim(),
            name: String(btn.dataset.name || '').trim(),
            requestId: requestId || drawnRequestId,
            sourceLabel: String(btn.dataset.source || 'ДТ').trim() || 'ДТ',
            hasRequest: btn.dataset.hasRequest === '1' || Boolean(requestId || drawnRequestId),
        };
    }

    document.querySelectorAll('.personal-draw-open').forEach((btn) => {
        btn.addEventListener('click', (event) => {
            event.preventDefault();
            const payload = payloadFromDrawButton(btn);
            if (payload.hasRequest) {
                submitDrawForm({
                    ...payload,
                    geometryMode: 'full',
                    redirectTo: '',
                });
                return;
            }
            pendingDrawPayload = payload;
            setModalOpen(drawChoiceModal, true);
        });
    });

    document.getElementById('personal-draw-choice-cancel')?.addEventListener('click', () => {
        pendingDrawPayload = null;
        closeDrawChoiceModal();
    });
    drawChoiceModal?.addEventListener('click', (event) => {
        if (event.target === drawChoiceModal) {
            pendingDrawPayload = null;
            closeDrawChoiceModal();
        }
    });
    document.getElementById('personal-draw-choice-aktualize')?.addEventListener('click', () => {
        closeDrawChoiceModal();
        if (drawRequestError) {
            drawRequestError.textContent = '';
        }
        if (drawRequestInput) {
            drawRequestInput.value = '';
        }
        setModalOpen(drawRequestModal, true);
        setTimeout(() => drawRequestInput && drawRequestInput.focus(), 0);
    });
    document.getElementById('personal-draw-choice-split')?.addEventListener('click', () => {
        const payload = pendingDrawPayload;
        pendingDrawPayload = null;
        closeDrawChoiceModal();
        if (!payload) {
            return;
        }
        submitDrawForm({
            ...payload,
            geometryMode: 'simplified',
            redirectTo: 'split_object',
        });
    });

    function submitDrawRequestModal() {
        const raw = (drawRequestInput && drawRequestInput.value ? drawRequestInput.value : '').trim();
        if (!raw) {
            if (drawRequestError) {
                drawRequestError.textContent = 'Введите номер заявки.';
            }
            return;
        }
        if (!/^\d+$/.test(raw)) {
            if (drawRequestError) {
                drawRequestError.textContent = 'Номер заявки должен содержать только цифры.';
            }
            return;
        }
        const payload = pendingDrawPayload;
        pendingDrawPayload = null;
        closeDrawRequestModal();
        if (!payload) {
            return;
        }
        submitDrawForm({
            ...payload,
            requestId: raw,
            geometryMode: 'simplified',
            redirectTo: '',
        });
    }

    document.getElementById('personal-draw-request-cancel')?.addEventListener('click', () => {
        closeDrawRequestModal();
        setModalOpen(drawChoiceModal, true);
    });
    document.getElementById('personal-draw-request-submit')?.addEventListener('click', submitDrawRequestModal);
    drawRequestInput?.addEventListener('keydown', (event) => {
        if (event.key === 'Enter') {
            event.preventDefault();
            submitDrawRequestModal();
        }
    });
    drawRequestModal?.addEventListener('click', (event) => {
        if (event.target === drawRequestModal) {
            closeDrawRequestModal();
            setModalOpen(drawChoiceModal, true);
        }
    });

    viewObjectCloseBtn?.addEventListener('click', (event) => {
        event.preventDefault();
        closeOwnedViewObjectModal();
    });
    viewObjectAnalizBtn?.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        const p = currentViewObjectProps || {};
        const ctx = {
            rootid: String(p.rootid || '').trim(),
            request_id: String(p.request_id || '').trim(),
            name: String(p.name || '').trim(),
            source_label: String(p.source_label || p.source || 'ДТ').trim() || 'ДТ',
        };
        if (!ctx.rootid && !ctx.request_id && !ctx.name) {
            return;
        }
        if (viewObjectStatus) {
            viewObjectStatus.textContent = 'Показываем пересечения на карте…';
        }
        if (!PV.requestShowIntersecsAnalizOnMap || !PV.requestShowIntersecsAnalizOnMap(viewObjectFrame)) {
            if (viewObjectStatus) {
                viewObjectStatus.textContent = 'Карта ещё загружается.';
            }
        }
    });
    viewObjectBeskhozBtn?.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        const p = currentViewObjectProps || {};
        const ctx = {
            rootid: String(p.rootid || '').trim(),
            request_id: String(p.request_id || '').trim(),
            name: String(p.name || '').trim(),
        };
        if (!ctx.rootid && !ctx.request_id && !ctx.name) {
            return;
        }
        if (viewObjectStatus) {
            viewObjectStatus.textContent = 'Ищем бесхозы на карте…';
            viewObjectStatus.classList.remove('note--danger');
        }
        if (!PV.requestShowBeskhozOnMap || !PV.requestShowBeskhozOnMap(viewObjectFrame)) {
            if (viewObjectStatus) {
                viewObjectStatus.textContent = 'Карта ещё загружается.';
            }
        }
    });
    window.addEventListener('message', (event) => {
        if (!viewObjectFrame || event.source !== viewObjectFrame.contentWindow) {
            return;
        }
        if (!event.data || event.data.type !== (PV.INTERSECS_ANALIZ_STATUS_MSG || 'pv-intersecs-analiz-status')) {
            return;
        }
        if (viewObjectStatus) {
            viewObjectStatus.textContent = event.data.text || '';
            viewObjectStatus.classList.toggle('note--danger', !!event.data.isError);
        }
    });
    viewObjectModal?.addEventListener('click', (event) => {
        if (event.target === viewObjectModal) {
            closeOwnedViewObjectModal();
        }
    });
    document.addEventListener('keydown', (event) => {
        if (event.key !== 'Escape') return;
        if (viewObjectModal && viewObjectModal.classList.contains('is-open')) {
            closeOwnedViewObjectModal();
            return;
        }
        if (checkDgiModal && checkDgiModal.style.display === 'flex') {
            closeCheckDgiModal();
            return;
        }
        if (dgiChooseModal && dgiChooseModal.style.display === 'flex') {
            closeDgiChooseModal();
            return;
        }
        if (drawRequestModal && drawRequestModal.style.display === 'flex') {
            closeDrawRequestModal();
            setModalOpen(drawChoiceModal, true);
            return;
        }
        if (drawChoiceModal && drawChoiceModal.style.display === 'flex') {
            pendingDrawPayload = null;
            closeDrawChoiceModal();
            return;
        }
        closeModal();
    });
})();

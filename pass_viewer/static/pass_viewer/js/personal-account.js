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
    // Глобальный поиск работает только по ID Паспорта, ID Заявки и Наименованию.
    const GLOBAL_SEARCH_COLS = [1, 2, 3];
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
        const oghType = (row.dataset.sourceLabel || '').trim();
        const approvedOgh = oghType === 'ОЗН' || oghType === 'ОО' || oghType === 'ОДХ' || oghType === 'ТОП' || oghType === 'ДТ' || oghType === 'DT' || oghType === 'TOP';
        if (active.has('approved') && rowKind === 'passport' && approvedOgh) {
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

    function filterControls() {
        return filterPanel ? Array.from(filterPanel.querySelectorAll('[data-filter-col]')) : [];
    }

    function cellText(cell) {
        return (cell && cell.textContent ? cell.textContent : '').replace(/\s+/g, ' ').trim();
    }

    function sortFilterValues(values, col) {
        return values.sort((a, b) => {
            if (col === 6) {
                const na = Number.parseInt(a, 10);
                const nb = Number.parseInt(b, 10);
                const aNum = String(na) === a;
                const bNum = String(nb) === b;
                if (aNum && bNum) {
                    return nb - na;
                }
                if (aNum) {
                    return -1;
                }
                if (bNum) {
                    return 1;
                }
            }
            return a.localeCompare(b, 'ru');
        });
    }

    function populateFilterSelects() {
        if (!table || !filterPanel) {
            return;
        }
        const rows = table.querySelectorAll('tbody tr[data-row-kind]');
        filterPanel.querySelectorAll('select[data-filter-col]').forEach((select) => {
            const col = Number(select.dataset.filterCol);
            if (col === 10) {
                return;
            }
            const values = new Set();
            rows.forEach((row) => {
                const text = cellText(row.querySelectorAll('td')[col]);
                if (text) {
                    values.add(text);
                }
            });
            sortFilterValues(Array.from(values), col).forEach((value) => {
                const option = document.createElement('option');
                option.value = value;
                option.textContent = value;
                select.appendChild(option);
            });
        });
    }

    function normalizeDateCell(cell) {
        const match = cellText(cell).match(/(\d{2})\.(\d{2})\.(\d{4})/);
        return match ? `${match[3]}-${match[2]}-${match[1]}` : '';
    }

    function dateRangeGroups() {
        return filterPanel ? Array.from(filterPanel.querySelectorAll('.personal-filter-daterange')) : [];
    }

    function parseDateRangeInput(value) {
        const matches = String(value || '').match(/\d{2}\.\d{2}\.\d{4}/g);
        if (!matches || !matches.length) {
            return null;
        }
        const toIso = (ru) => ru.split('.').reverse().join('-');
        let from = toIso(matches[0]);
        let to = matches.length > 1 ? toIso(matches[1]) : '';
        if (to && to < from) {
            [from, to] = [to, from];
        }
        return { from, to };
    }

    function toggleDateRangeClear(group) {
        const input = group.querySelector('input');
        const clearBtn = group.querySelector('.personal-filter-daterange__clear');
        if (clearBtn) {
            clearBtn.hidden = !(input && input.value.trim());
        }
    }

    function clearDateRange(group) {
        const input = group.querySelector('input');
        if (input) {
            input.value = '';
        }
        toggleDateRangeClear(group);
    }

    function dateRangeMismatch(group, cells) {
        const input = group.querySelector('input');
        const range = input ? parseDateRangeInput(input.value) : null;
        if (!range) {
            return false;
        }
        const cellValue = normalizeDateCell(cells[Number(group.dataset.dateFilterCol)]);
        if (!cellValue) {
            return true;
        }
        if (cellValue < range.from) {
            return true;
        }
        return Boolean(range.to) && cellValue > range.to;
    }

    function columnMismatch(control, cells) {
        const value = control.value.trim();
        if (!value) {
            return false;
        }
        const cell = cells[Number(control.dataset.filterCol)];
        const text = cellText(cell).toLocaleLowerCase('ru');
        const needle = value.toLocaleLowerCase('ru');
        if (control.tagName === 'SELECT') {
            return text !== needle;
        }
        return !text.includes(needle);
    }

    function escapeRegExp(value) {
        return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }

    function ensureSearchHtml(cell) {
        if (cell.dataset.searchHtml == null) {
            cell.dataset.searchHtml = cell.innerHTML;
        }
    }

    function restoreSearchHtml(cell) {
        if (cell.dataset.searchHtml != null) {
            cell.innerHTML = cell.dataset.searchHtml;
        }
    }

    function highlightTextNodes(root, query) {
        const re = new RegExp(escapeRegExp(query), 'gi');
        const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
            acceptNode(node) {
                if (!node.nodeValue) {
                    return NodeFilter.FILTER_REJECT;
                }
                const parent = node.parentElement;
                if (parent && (parent.closest('mark.personal-search-hit') || parent.closest('.personal-table-btn'))) {
                    return NodeFilter.FILTER_REJECT;
                }
                return NodeFilter.FILTER_ACCEPT;
            },
        });
        const nodes = [];
        while (walker.nextNode()) {
            nodes.push(walker.currentNode);
        }
        nodes.forEach((node) => {
            const text = node.nodeValue;
            re.lastIndex = 0;
            if (!re.test(text)) {
                return;
            }
            re.lastIndex = 0;
            const frag = document.createDocumentFragment();
            let last = 0;
            let match = re.exec(text);
            while (match) {
                if (match.index > last) {
                    frag.appendChild(document.createTextNode(text.slice(last, match.index)));
                }
                const mark = document.createElement('mark');
                mark.className = 'personal-search-hit';
                mark.textContent = match[0];
                frag.appendChild(mark);
                last = match.index + match[0].length;
                if (!match[0].length) {
                    break;
                }
                match = re.exec(text);
            }
            if (last < text.length) {
                frag.appendChild(document.createTextNode(text.slice(last)));
            }
            node.parentNode.replaceChild(frag, node);
        });
    }

    function updateRowSearchHighlights(row, query) {
        const cells = row.querySelectorAll('td');
        for (const index of GLOBAL_SEARCH_COLS) {
            const cell = cells[index];
            if (!cell || cell.querySelector('.personal-table-btn')) {
                continue;
            }
            ensureSearchHtml(cell);
            restoreSearchHtml(cell);
            if (query) {
                highlightTextNodes(cell, query);
            }
        }
    }

    function statusDisplayMode(active) {
        const keys = active instanceof Set ? active : new Set(active || []);
        if (!keys.size || keys.has('all')) {
            return 'combined';
        }
        const hasApproved = keys.has('approved');
        const hasRequest = keys.has('actualization') || keys.has('primary') || keys.has('drawn');
        const hasApproval = keys.has('approval');
        if (hasApproved && !hasRequest && !hasApproval) {
            return 'ogh';
        }
        if (hasRequest && !hasApproved && !hasApproval) {
            return 'ods';
        }
        return 'combined';
    }

    function statusTextForCell(cell, mode) {
        const combined = String((cell && cell.dataset.statusCombined) || '').trim();
        const ogh = String((cell && cell.dataset.statusOgh) || '').trim();
        const ods = String((cell && cell.dataset.statusOds) || '').trim();
        if (mode === 'ogh') {
            return ogh || '—';
        }
        if (mode === 'ods') {
            return ods || '—';
        }
        return combined || ogh || ods || '—';
    }

    function applyStatusModeToRows(mode) {
        if (!table) {
            return;
        }
        table.querySelectorAll('tbody tr[data-row-kind]').forEach((row) => {
            const cell = row.querySelector('td.personal-status-cell');
            if (!cell) {
                return;
            }
            cell.textContent = statusTextForCell(cell, mode);
            delete cell.dataset.searchHtml;
        });
    }

    function rebuildStatusFilterSelect() {
        if (!table || !filterPanel) {
            return;
        }
        const select = filterPanel.querySelector('select[data-filter-col="10"]');
        if (!select) {
            return;
        }
        const previous = select.value;
        const placeholderLabel = (select.options[0] && select.options[0].textContent) || 'Статус';
        select.innerHTML = '';
        const blank = document.createElement('option');
        blank.value = '';
        blank.textContent = placeholderLabel;
        select.appendChild(blank);
        const values = new Set();
        table.querySelectorAll('tbody tr[data-row-kind]').forEach((row) => {
            const text = cellText(row.querySelector('td.personal-status-cell'));
            if (text) {
                values.add(text);
            }
        });
        sortFilterValues(Array.from(values), 10).forEach((value) => {
            const option = document.createElement('option');
            option.value = value;
            option.textContent = value;
            select.appendChild(option);
        });
        const stillThere = Array.from(select.options).some((option) => option.value === previous);
        select.value = stillThere ? previous : '';
    }

    function applyPersonalTableFilters() {
        if (!table) {
            return;
        }
        const rows = table.querySelectorAll('tbody tr');
        const controls = filterControls();
        const dateGroups = dateRangeGroups();
        const active = activeKindFilters();
        applyStatusModeToRows(statusDisplayMode(active));
        rebuildStatusFilterSelect();
        const queryRaw = globalSearch ? globalSearch.value.trim() : '';
        const query = queryRaw.toLocaleLowerCase('ru');
        rows.forEach((row) => {
            if (!rowMatchesKindFilter(row, active)) {
                row.hidden = true;
                updateRowSearchHighlights(row, '');
                return;
            }
            const cells = row.querySelectorAll('td');
            if (controls.some((control) => columnMismatch(control, cells))
                || dateGroups.some((group) => dateRangeMismatch(group, cells))) {
                row.hidden = true;
                updateRowSearchHighlights(row, '');
                return;
            }
            if (!query) {
                row.hidden = false;
                updateRowSearchHighlights(row, '');
                return;
            }
            let matchesGlobal = false;
            for (const index of GLOBAL_SEARCH_COLS) {
                const cell = cells[index];
                if (cell && cell.textContent.toLocaleLowerCase('ru').includes(query)) {
                    matchesGlobal = true;
                    break;
                }
            }
            row.hidden = !matchesGlobal;
            updateRowSearchHighlights(row, matchesGlobal ? queryRaw : '');
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
        const controls = filterControls();
        populateFilterSelects();
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
        controls.forEach((control) => {
            const eventName = control.tagName === 'SELECT' ? 'change' : 'input';
            control.addEventListener(eventName, applyPersonalTableFilters);
        });
        const dateGroupEls = dateRangeGroups();
        dateGroupEls.forEach((group) => {
            group.querySelector('input')?.addEventListener('input', () => {
                toggleDateRangeClear(group);
                applyPersonalTableFilters();
            });
            group.querySelector('.personal-filter-daterange__clear')?.addEventListener('click', () => {
                clearDateRange(group);
                applyPersonalTableFilters();
            });
            toggleDateRangeClear(group);
        });
        globalSearch?.addEventListener('input', applyPersonalTableFilters);
        clearButton?.addEventListener('click', () => {
            controls.forEach((control) => { control.value = ''; });
            dateGroupEls.forEach(clearDateRange);
            if (globalSearch) {
                globalSearch.value = '';
            }
            applyPersonalTableFilters();
        });
    }

    const EXPORT_COLUMN_COUNT = 12;
    const exportButton = document.getElementById('personal-export-xlsx');

    function visiblePersonalExportRows() {
        if (!table) {
            return [];
        }
        return Array.from(table.querySelectorAll('tbody tr[data-row-kind]')).filter((row) => !row.hidden);
    }

    function collectPersonalExportPayload() {
        return visiblePersonalExportRows().map((row) => {
            const cells = row.querySelectorAll('td');
            const values = [];
            for (let index = 0; index < EXPORT_COLUMN_COUNT; index += 1) {
                values.push(cellText(cells[index]));
            }
            const asuBtn = row.querySelector('.personal-asu-ods-open');
            const payload = { cells: values };
            if (asuBtn) {
                payload.asu_ods_rootid = String(asuBtn.dataset.rootid || '').trim();
                payload.asu_ods_source = String(asuBtn.dataset.source || '').trim();
            }
            return payload;
        });
    }

    function filenameFromDisposition(header) {
        if (!header) {
            return '';
        }
        const utfMatch = header.match(/filename\*=UTF-8''([^;]+)/i);
        if (utfMatch) {
            try {
                return decodeURIComponent(utfMatch[1]);
            } catch (error) {
                return utfMatch[1];
            }
        }
        const plain = header.match(/filename="?([^";]+)"?/i);
        return plain ? plain[1] : '';
    }

    function downloadBlob(blob, filename) {
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename || 'personal-account.xlsx';
        document.body.appendChild(link);
        link.click();
        link.remove();
        URL.revokeObjectURL(url);
    }

    async function exportPersonalTableXlsx() {
        const endpoint = urls.personalExportXlsx;
        if (!endpoint || !exportButton) {
            return;
        }
        const exportLabel = exportButton.querySelector('.personal-export-xlsx-btn__label') || exportButton;
        const originalLabel = exportLabel.textContent;
        exportButton.disabled = true;
        exportLabel.textContent = 'Выгрузка…';
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': csrfToken(),
                },
                credentials: 'same-origin',
                body: JSON.stringify({ rows: collectPersonalExportPayload() }),
            });
            if (!response.ok) {
                const data = await parseJson(response).catch(() => null);
                throw new Error((data && data.error) || 'Не удалось выгрузить таблицу в Excel.');
            }
            const blob = await response.blob();
            const filename = filenameFromDisposition(response.headers.get('Content-Disposition'));
            downloadBlob(blob, filename);
        } catch (error) {
            window.alert(error.message || 'Не удалось выгрузить таблицу в Excel.');
        } finally {
            exportButton.disabled = false;
            exportLabel.textContent = originalLabel;
        }
    }

    exportButton?.addEventListener('click', () => {
        exportPersonalTableXlsx().catch((error) => {
            console.error('personal-account: excel export failed', error);
        });
    });

    const modal = document.getElementById('personal-detail-modal');
    const closeButton = document.getElementById('personal-detail-close');
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
            style: { color: '#ff00ff', weight: 2, fillColor: '#ff00ff', fillOpacity: 0.25 },
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
        fillText('detail-request-id', detailContext.displayRequestId || detailContext.drawnRequestId);
        fillText('detail-source', sourceLabel);
        fillText('detail-survey-date', '—');
        fillText('detail-create-type', '—');
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
            fillText('detail-area', '—');
            fillText('detail-survey-date', '—');
            fillText('detail-create-type', '—');
            renderDetailGeometry(null);
            return;
        }
        fillText('detail-approval-date', data.approval_date);
        fillText('detail-area', data.area_label);
        fillText('detail-survey-date', data.survey_date);
        fillText('detail-create-type', data.create_type);
            if (data.source_label) {
                fillText('detail-source', data.source_label);
            }
            if (data.request_id) {
                fillText('detail-request-id', data.request_id);
            }
            if (data.status) {
                fillText('detail-status', data.status);
            }
            renderDetailGeometry(data.geometry);
        } catch (error) {
            if (seq !== detailsRequestSeq) {
                return;
            }
            console.error('personal-account: object details failed', error);
            fillText('detail-approval-date', '—');
            fillText('detail-area', '—');
            fillText('detail-survey-date', '—');
            fillText('detail-create-type', '—');
            renderDetailGeometry(null);
        }
    }

    document.querySelectorAll('.personal-asu-ods-open').forEach((button) => {
        button.addEventListener('click', () => {
            resolveAndOpenAsuOds(button.dataset.rootid, button.dataset.source);
        });
    });

    function syncModalDrawButton(button) {
        const drawBtn = document.getElementById('personal-modal-draw-open');
        if (!drawBtn) {
            return;
        }
        const rowKind = button.closest('tr') && button.closest('tr').dataset.rowKind;
        if (rowKind === 'approval') {
            drawBtn.disabled = true;
            drawBtn.classList.add('is-disabled');
            return;
        }
        const requestId = String(button.dataset.requestId || '').trim();
        const drawnRequestId = String(button.dataset.drawnRequestId || '').trim();
        drawBtn.disabled = false;
        drawBtn.classList.remove('is-disabled');
        drawBtn.dataset.rootid = String(button.dataset.passportRootid || button.dataset.id || '').trim();
        drawBtn.dataset.name = String(button.dataset.name || '').trim();
        drawBtn.dataset.requestId = requestId;
        drawBtn.dataset.drawnRequestId = drawnRequestId;
        drawBtn.dataset.source = String(button.dataset.source || 'ДТ').trim() || 'ДТ';
        drawBtn.dataset.hasRequest = button.dataset.hasRequest === '1' || Boolean(requestId || drawnRequestId)
            ? '1'
            : '';
    }

    document.querySelectorAll('.personal-detail-open').forEach((button) => {
        button.addEventListener('click', () => {
            const sourceLabel = button.dataset.source || 'ДТ';
            const displayRootid = button.dataset.id || '';
            const passportRootid = (button.dataset.passportRootid || '').trim();
            const displayRequestId = button.dataset.requestId || '';
            const drawnRequestId = (button.dataset.drawnRequestId || '').trim();
            const drawnSource = (button.dataset.drawnSource || '').trim();
            const hasDrawnRequest = button.dataset.hasDrawnRequest === '1' && Boolean(passportRootid) && Boolean(drawnRequestId);
            syncModalDrawButton(button);
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
            fillText('detail-request-id', displayRequestId);
            fillText('detail-source', sourceLabel);
            fillText('detail-approval-date', button.dataset.approvalDate);
            fillText('detail-survey-date', button.dataset.surveyDate);
            fillText('detail-create-type', button.dataset.createType);
            fillText('detail-area', button.dataset.area);
            fillText('detail-status', button.dataset.status);
            if (field('personal-open-name')) field('personal-open-name').value = button.dataset.name || '';
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
    const checkOgxUrl = urls.checkOgx || '';
    const intersecsAnalizUrl = urls.intersecsAnaliz || '';
    let checkDgiViewObjectProps = null;
    let lastCheckDgiContext = null;
    let pendingDgiCheck = null;
    const checkDgiMode = PV.createCheckDgiModeController
        ? PV.createCheckDgiModeController({
              url: checkOgxUrl,
              getContext: () => lastCheckDgiContext,
              getCsrfToken: csrfToken,
          })
        : null;

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

    function resetCheckDgiMode() {
        if (checkDgiMode && checkDgiMode.reset) {
            checkDgiMode.reset();
        }
    }

    function closeCheckDgiModal() {
        if (checkDgiModal) {
            checkDgiModal.style.display = 'none';
        }
        resetCheckDgiMode();
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
            resetCheckDgiMode();
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
    document.getElementById('personal-intersecs-open')?.addEventListener('click', (event) => {
        event.preventDefault();
        if (!PV.openIntersecsAnalizPage) {
            return;
        }
        PV.openIntersecsAnalizPage({
            pageUrl: intersecsAnalizUrl,
            rootid: field('personal-open-rootid')?.value || '',
            request_id: field('personal-open-request-id')?.value || '',
            source_label: field('personal-open-source')?.value || 'ДТ',
            name: field('personal-open-name')?.value || '',
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

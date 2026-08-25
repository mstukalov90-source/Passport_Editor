(function () {
    'use strict';

    const PV = window.PassViewer || {};
    const pageConfig = (PV.getPageConfig && PV.getPageConfig()) || { urls: {} };
    const urls = pageConfig.urls || {};

    const filterToggle = document.getElementById('personal-filter-toggle');
    const filterPanel = document.getElementById('personal-filter-panel');
    const table = document.querySelector('.personal-table');
    const clearButton = document.getElementById('personal-filter-clear');

    if (filterToggle && filterPanel && table) {
        const rows = table.querySelectorAll('tbody tr');
        const inputs = filterPanel.querySelectorAll('input[data-filter-col]');
        const applyFilters = () => {
            rows.forEach((row) => {
                const cells = row.querySelectorAll('td');
                row.hidden = Array.from(inputs).some((input) => {
                    const value = input.value.trim().toLocaleLowerCase('ru');
                    if (!value) return false;
                    const cell = cells[Number(input.dataset.filterCol)];
                    return !cell || !cell.textContent.toLocaleLowerCase('ru').includes(value);
                });
            });
        };
        filterToggle.addEventListener('click', () => {
            const open = filterPanel.hidden;
            filterPanel.hidden = !open;
            filterToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
        inputs.forEach((input) => input.addEventListener('input', applyFilters));
        clearButton?.addEventListener('click', () => {
            inputs.forEach((input) => { input.value = ''; });
            applyFilters();
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
    const viewObjectLoading = document.getElementById('owned-view-object-loading');
    const field = (id) => document.getElementById(id);

    let detailMap = null;
    let detailLayer = null;
    let detailsRequestSeq = 0;

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
            if (PV.createBasemapLayers) {
                const { mggtLayer } = PV.createBasemapLayers();
                mggtLayer.addTo(detailMap);
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

    function closeOwnedViewObjectModal() {
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

    async function loadObjectDetails(rootid, sourceLabel, seq) {
        const endpoint = urls.personalObjectDetails;
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
            const rootid = button.dataset.id || '';
            const seq = detailsRequestSeq + 1;
            detailsRequestSeq = seq;
            fillText('detail-passport-id', rootid);
            fillText('detail-passport-name', button.dataset.name);
            fillText('detail-approval-date', '—');
            fillText('detail-owner', '—');
            fillText('detail-oiv', '—');
            fillText('detail-area', '—');
            fillText('detail-status', button.dataset.status);
            if (field('personal-open-rootid')) field('personal-open-rootid').value = rootid;
            if (field('personal-open-name')) field('personal-open-name').value = button.dataset.name || '';
            if (field('personal-open-request-id')) field('personal-open-request-id').value = button.dataset.requestId || '';
            if (field('personal-open-source')) field('personal-open-source').value = sourceLabel;
            setAsuOdsLinkEnabled(sourceLabel !== 'ТОП' && sourceLabel !== 'TOP', rootid, sourceLabel);
            if (modal) modal.style.display = 'flex';
            renderDetailGeometry(null);
            loadObjectDetails(rootid, sourceLabel, seq);
        });
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
    viewObjectCloseBtn?.addEventListener('click', (event) => {
        event.preventDefault();
        closeOwnedViewObjectModal();
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
        closeModal();
    });
})();

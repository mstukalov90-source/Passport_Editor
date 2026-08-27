(function () {
    'use strict';

    if (typeof window.openOwnedListsModal === 'function') {
        return;
    }

    const LISTS_MODAL_TITLES = {
        requests: 'Отрисовка границ заявок',
        approvals: 'Согласование границ ОГХ',
    };

    const modal = document.getElementById('owned-lists-modal');
    const modalTitle = document.getElementById('owned-lists-modal-title');
    const modalClose = document.getElementById('owned-lists-modal-close');
    const modalBody = document.getElementById('owned-lists-modal-body');
    const modalFooter = document.getElementById('owned-lists-modal-footer');
    const actionsHost = document.getElementById('owned-lists-actions-host');
    const PARTIAL_URL = (modal && modal.dataset.partialUrl) || '/owned/lists-partial/';

    let fragmentPromise = null;
    let fragmentReady = false;
    let hydrated = false;
    let mergePassportsMode = false;
    let mergeImplicitTargetSource = '';
    let entryRequestMode = null;
    let pendingOwnedForm = null;

    function normalizeSourceLabel(raw) {
        const sourceLabel = String(raw || 'ДТ').trim().toUpperCase();
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

    function getModalListButtons() {
        return Array.from(document.querySelectorAll('#owned-lists-modal .owned-list-tab-btn'));
    }

    function getModalListPanels() {
        return Array.from(document.querySelectorAll('#owned-lists-modal [data-list-panel]'));
    }

    function getActiveOwnedListTab() {
        const fromBody = document.body.getAttribute('data-owned-lists-tab');
        if (fromBody === 'requests' || fromBody === 'approvals' || fromBody === 'passports') {
            return fromBody;
        }
        const activeBtn = getModalListButtons().find((btn) => btn.classList.contains('is-active'));
        return activeBtn ? activeBtn.dataset.ownedListTab : 'requests';
    }

    function setOwnedListTab(tabName) {
        const tab =
            tabName === 'approvals' ? 'approvals' : tabName === 'passports' ? 'passports' : 'requests';
        getModalListButtons().forEach((btn) => {
            btn.classList.toggle('is-active', btn.dataset.ownedListTab === tab);
        });
        getModalListPanels().forEach((panel) => {
            const on = panel.getAttribute('data-list-panel') === tab;
            panel.classList.toggle('is-active', on);
            panel.hidden = !on;
        });
        document.body.setAttribute('data-owned-lists-tab', tab);
    }

    function applyOwnedFilters() {
        const rootidEl = document.getElementById('owned-filter-rootid');
        const nameEl = document.getElementById('owned-filter-name');
        const approvalSelectEl = document.getElementById('owned-approval-select');
        const approvalScopeSelectEl = document.getElementById('owned-approval-scope-select');
        const rootidNeedle = (rootidEl?.value || '').trim().toLowerCase();
        const nameNeedle = (nameEl?.value || '').trim().toLowerCase();
        const activeTab = getActiveOwnedListTab();
        const selectedApprovalStatus = (approvalSelectEl?.value || '').trim();
        const filterApprovalsByMine = Boolean(approvalScopeSelectEl);
        const approvalScope = (approvalScopeSelectEl?.value || 'mine').trim();
        const approvalSelectWrapEl = document.getElementById('owned-approval-select-wrap');
        const approvalScopeWrapEl = document.getElementById('owned-approval-scope-wrap');
        document.querySelectorAll('#owned-lists-modal .owned-item').forEach((item) => {
            const rootidValue = item.dataset.rootid || '';
            const nameValue = item.dataset.name || '';
            const rootidMatch = !rootidNeedle || rootidValue.includes(rootidNeedle);
            const nameMatch = !nameNeedle || nameValue.includes(nameNeedle);
            const rowApprovalStatus = (item.dataset.approvalStatus || '').trim();
            const approvalMatch =
                activeTab !== 'approvals' ||
                !selectedApprovalStatus ||
                rowApprovalStatus === selectedApprovalStatus;
            const isMine = (item.dataset.approvalMine || '') === '1';
            const approvalScopeMatch =
                activeTab !== 'approvals' ||
                !filterApprovalsByMine ||
                approvalScope === 'all' ||
                isMine;
            item.style.display =
                rootidMatch && nameMatch && approvalMatch && approvalScopeMatch ? '' : 'none';
        });
        if (approvalSelectWrapEl) {
            const approvalRows = document.querySelectorAll('.owned-approval-row');
            approvalSelectWrapEl.hidden = activeTab !== 'approvals' || !approvalRows.length;
            if (approvalScopeWrapEl) {
                approvalScopeWrapEl.hidden =
                    approvalSelectWrapEl.hidden || !approvalScopeWrapEl;
            }
        }
    }

    function isModalOpen() {
        return Boolean(modal && modal.classList.contains('is-open'));
    }

    function closeOwnedListsModal() {
        if (!modal || !isModalOpen()) {
            return;
        }
        modal.classList.remove('is-open');
        modal.hidden = true;
        document.body.classList.remove('owned-lists-modal-open');
        document.body.removeAttribute('data-owned-lists-tab');
        setMergePassportsMode(false);
        const mergeBtn = document.getElementById('merge-passports-btn');
        if (mergeBtn) {
            mergeBtn.classList.remove('is-active');
        }
        closeMergeRequestModal();
        closeEntryRequestModal();
    }

    function showModalShell(tab) {
        const kind = tab === 'approvals' ? 'approvals' : 'requests';
        if (modalTitle) {
            modalTitle.textContent = LISTS_MODAL_TITLES[kind] || LISTS_MODAL_TITLES.requests;
        }
        document.body.classList.add('owned-lists-modal-open');
        document.body.setAttribute('data-owned-lists-tab', kind);
        if (modal) {
            modal.hidden = false;
            modal.classList.add('is-open');
        }
        if (modalClose) {
            modalClose.focus();
        }
        if (fragmentReady) {
            setOwnedListTab(kind);
            applyOwnedFilters();
        }
    }

    function fetchFragment() {
        if (!fragmentPromise) {
            fragmentPromise = fetch(PARTIAL_URL, {
                credentials: 'same-origin',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
            })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error('Не удалось загрузить список заявок.');
                    }
                    return response.text();
                })
                .then((html) => {
                    injectFragment(html);
                    fragmentReady = true;
                    return true;
                })
                .catch((err) => {
                    fragmentPromise = null;
                    throw err;
                });
        }
        return fragmentPromise;
    }

    function injectFragment(html) {
        const wrap = document.createElement('div');
        wrap.innerHTML = html.trim();
        const fragment = wrap.querySelector('#owned-lists-fragment') || wrap;
        const stack = fragment.querySelector('.owned-home-lists-stack');
        if (!stack) {
            throw new Error('Не удалось загрузить список заявок.');
        }
        const footer = fragment.querySelector('.owned-home-footer');
        const tabs = fragment.querySelector('.owned-lists-fragment__tabs');
        const actions = fragment.querySelector('.owned-lists-fragment__actions');
        if (modalBody) {
            modalBody.replaceChildren();
            if (tabs) {
                modalBody.appendChild(tabs);
            }
            if (stack) {
                modalBody.appendChild(stack);
            }
        }
        if (modalFooter) {
            modalFooter.replaceChildren();
            if (footer) {
                modalFooter.appendChild(footer);
            }
        }
        if (actionsHost && actions) {
            actionsHost.replaceChildren();
            while (actions.firstChild) {
                actionsHost.appendChild(actions.firstChild);
            }
        }
        hydrateFragment();
    }

    function hydrateFragment() {
        if (hydrated) {
            return;
        }
        hydrated = true;

        const filterRootidEl = document.getElementById('owned-filter-rootid');
        const filterNameEl = document.getElementById('owned-filter-name');
        const filterClearEl = document.getElementById('owned-filter-clear');
        const approvalSelectEl = document.getElementById('owned-approval-select');
        const approvalScopeSelectEl = document.getElementById('owned-approval-scope-select');

        if (filterRootidEl) {
            filterRootidEl.addEventListener('input', applyOwnedFilters);
        }
        if (filterNameEl) {
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
                if (approvalSelectEl) {
                    approvalSelectEl.value = '';
                }
                applyOwnedFilters();
            });
        }
        if (approvalSelectEl) {
            approvalSelectEl.addEventListener('change', applyOwnedFilters);
        }
        if (approvalScopeSelectEl) {
            approvalScopeSelectEl.addEventListener('change', applyOwnedFilters);
        }
        getModalListButtons().forEach((btn) => {
            btn.addEventListener('click', () => {
                const tab = btn.dataset.ownedListTab || 'requests';
                if (modalTitle) {
                    modalTitle.textContent = LISTS_MODAL_TITLES[tab] || modalTitle.textContent;
                }
                setOwnedListTab(tab);
                applyOwnedFilters();
            });
        });

        document.querySelectorAll('#owned-lists-modal form.owned-open-form').forEach((form) => {
            form.addEventListener('submit', (event) => {
                if (form.dataset.needsRequestId === '1') {
                    event.preventDefault();
                    openEntryRequestModal('owned', { form: form });
                }
            });
        });
        document.querySelectorAll('#owned-lists-modal .owned-delete-btn').forEach((btn) => {
            const form = btn.closest('form');
            if (!form) {
                return;
            }
            form.addEventListener('submit', (event) => {
                const message = btn.getAttribute('data-confirm-message') || 'Удалить?';
                if (!window.confirm(message)) {
                    event.preventDefault();
                }
            });
        });

        bindEntryAndMerge();
    }

    function openEntryRequestModal(mode, opts) {
        const options = opts || {};
        entryRequestMode = mode;
        pendingOwnedForm = options.form || null;
        const entryRequestModal = document.getElementById('entry-request-id-modal');
        const entryRequestInput = document.getElementById('entry-request-id-input');
        const entryRequestError = document.getElementById('entry-request-id-error');
        const entryRequestText = document.getElementById('entry-request-id-modal-text');
        const entryRequestTitle = document.getElementById('entry-request-id-modal-title');
        if (entryRequestError) {
            entryRequestError.textContent = '';
        }
        if (entryRequestInput) {
            entryRequestInput.value = '';
        }
        if (entryRequestTitle) {
            entryRequestTitle.textContent =
                mode === 'add-object'
                    ? 'Заявка на первичную паспортизацию'
                    : 'Заявка на актуализацию.';
        }
        if (entryRequestText) {
            entryRequestText.textContent =
                mode === 'add-object'
                    ? 'Укажите номер заявки перед переходом к созданию объекта.'
                    : 'У объекта не указан номер заявки в базе. Введите номер заявки, чтобы продолжить.';
        }
        if (entryRequestModal) {
            entryRequestModal.style.display = 'flex';
        }
        setTimeout(() => entryRequestInput && entryRequestInput.focus(), 0);
    }

    function closeEntryRequestModal() {
        const entryRequestModal = document.getElementById('entry-request-id-modal');
        if (entryRequestModal) {
            entryRequestModal.style.display = 'none';
        }
        entryRequestMode = null;
        pendingOwnedForm = null;
    }

    function submitEntryRequestModal() {
        const entryRequestInput = document.getElementById('entry-request-id-input');
        const entryRequestError = document.getElementById('entry-request-id-error');
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
        const prepareAddObjectForm = document.getElementById('form-prepare-add-object');
        const prepareAddObjectHidden = document.getElementById('prepare-add-object-request-id');
        if (entryRequestMode === 'add-object' && prepareAddObjectHidden && prepareAddObjectForm) {
            prepareAddObjectHidden.value = raw;
            prepareAddObjectForm.submit();
        } else if (entryRequestMode === 'owned' && pendingOwnedForm) {
            const ridInput = pendingOwnedForm.querySelector('input[name="request_id"]');
            if (ridInput) {
                ridInput.value = raw;
            }
            pendingOwnedForm.submit();
        }
        closeEntryRequestModal();
    }

    function setMergePassportsMode(active) {
        mergePassportsMode = Boolean(active);
        document.body.classList.toggle('home--merge-passports', mergePassportsMode);
        const mergePassportsToolbar = document.getElementById('merge-passports-toolbar');
        if (mergePassportsToolbar) {
            mergePassportsToolbar.style.display = mergePassportsMode ? 'flex' : 'none';
        }
        document.querySelectorAll('#owned-lists-modal .owned-open-form button[type="submit"]').forEach((btn) => {
            btn.disabled = mergePassportsMode;
        });
        document.querySelectorAll('#owned-lists-modal .owned-ods-action-btn').forEach((btn) => {
            btn.disabled = mergePassportsMode;
        });
        if (!mergePassportsMode) {
            document.querySelectorAll('#owned-lists-modal .merge-passport-cb').forEach((cb) => {
                cb.checked = false;
            });
        }
    }

    function getMergeCheckboxPayload(cb) {
        const mergeKind = (cb.dataset.mergeKind || 'passport').trim();
        const sourceLabel = normalizeSourceLabel(cb.dataset.sourceLabel);
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
        const mergeTargetSourceFieldset = document.getElementById('merge-target-source-fieldset');
        if (!mergeTargetSourceFieldset) {
            return;
        }
        mergeTargetSourceFieldset.querySelectorAll('.merge-target-option').forEach((row) => {
            row.style.display = '';
        });
        mergeTargetSourceFieldset.style.display = 'none';
    }

    function closeMergeRequestModal() {
        const mergeRequestModal = document.getElementById('merge-passports-request-modal');
        const mergeRequestInput = document.getElementById('merge-passports-request-input');
        const mergeRequestError = document.getElementById('merge-passports-request-error');
        if (mergeRequestModal) {
            mergeRequestModal.style.display = 'none';
        }
        if (mergeRequestInput) {
            mergeRequestInput.value = '';
        }
        if (mergeRequestError) {
            mergeRequestError.textContent = '';
        }
        ['merge-target-dt', 'merge-target-odh', 'merge-target-ozn', 'merge-target-top'].forEach((id) => {
            const radio = document.getElementById(id);
            if (radio) {
                radio.checked = false;
            }
        });
        mergeImplicitTargetSource = '';
        resetMergeTargetOptionRows();
        const simplified = document.getElementById('merge-geometry-detail-simplified');
        const full = document.getElementById('merge-geometry-detail-full');
        if (simplified) {
            simplified.checked = true;
        }
        if (full) {
            full.checked = false;
        }
    }

    function openMergeRequestModalWithSources(sourcesSet) {
        const mergeRequestInput = document.getElementById('merge-passports-request-input');
        const mergeRequestError = document.getElementById('merge-passports-request-error');
        const mergeTargetSourceFieldset = document.getElementById('merge-target-source-fieldset');
        const mergePassportsRequestIntro = document.getElementById('merge-passports-request-intro');
        const mergeRequestModal = document.getElementById('merge-passports-request-modal');
        if (mergeRequestInput) {
            mergeRequestInput.value = '';
        }
        if (mergeRequestError) {
            mergeRequestError.textContent = '';
        }
        ['merge-target-dt', 'merge-target-odh', 'merge-target-ozn', 'merge-target-top'].forEach((id) => {
            const radio = document.getElementById(id);
            if (radio) {
                radio.checked = false;
            }
        });
        mergeImplicitTargetSource = '';
        const simplified = document.getElementById('merge-geometry-detail-simplified');
        const full = document.getElementById('merge-geometry-detail-full');
        if (simplified) {
            simplified.checked = true;
        }
        if (full) {
            full.checked = false;
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
                    const rowSource = normalizeSourceLabel(row.dataset.mergeSource || '');
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

    function getMergeGeometryDetailMode() {
        const full = document.getElementById('merge-geometry-detail-full');
        return full && full.checked ? 'full' : 'simplified';
    }

    function submitMergePassportsContinue() {
        const checked = Array.from(document.querySelectorAll('#owned-lists-modal .merge-passport-cb:checked'));
        if (checked.length < 2) {
            window.alert('Отметьте не менее двух объектов (паспорта и/или заявки).');
            return;
        }
        const sources = new Set(checked.map((cb) => getMergeCheckboxPayload(cb).sourceLabel));
        openMergeRequestModalWithSources(sources);
    }

    function submitMergeRequestModal() {
        const mergeRequestInput = document.getElementById('merge-passports-request-input');
        const mergeRequestError = document.getElementById('merge-passports-request-error');
        const mergeItemsContainer = document.getElementById('merge-passports-items-container');
        const formMergePassports = document.getElementById('form-merge-passports');
        const mergeRequestIdHidden = document.getElementById('merge-passports-request-id-hidden');
        const mergeTargetSourceHidden = document.getElementById('merge-passports-target-source-hidden');
        const mergePassportsGeometryDetailHidden = document.getElementById('merge-passports-geometry-detail-mode');
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
        const checked = Array.from(document.querySelectorAll('#owned-lists-modal .merge-passport-cb:checked'));
        const allowedTargetSources = new Set(checked.map((cb) => getMergeCheckboxPayload(cb).sourceLabel));
        let targetSourceValue = (mergeImplicitTargetSource || '').trim();
        if (targetSourceValue) {
            targetSourceValue = normalizeSourceLabel(targetSourceValue);
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
            targetSourceValue = normalizeSourceLabel(targetRadio.value);
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

    function bindEntryAndMerge() {
        const addObjectEntryBtn = document.getElementById('add-object-entry-btn');
        if (addObjectEntryBtn) {
            addObjectEntryBtn.addEventListener('click', () => {
                openEntryRequestModal('add-object');
            });
        }
        const entryRequestSubmitBtn = document.getElementById('entry-request-id-submit-btn');
        const entryRequestCloseBtn = document.getElementById('entry-request-id-close-btn');
        const entryRequestCancelBtn = document.getElementById('entry-request-id-cancel-btn');
        const entryRequestModal = document.getElementById('entry-request-id-modal');
        const entryRequestInput = document.getElementById('entry-request-id-input');
        if (entryRequestSubmitBtn) {
            entryRequestSubmitBtn.addEventListener('click', submitEntryRequestModal);
        }
        if (entryRequestCloseBtn) {
            entryRequestCloseBtn.addEventListener('click', closeEntryRequestModal);
        }
        if (entryRequestCancelBtn) {
            entryRequestCancelBtn.addEventListener('click', closeEntryRequestModal);
        }
        if (entryRequestModal) {
            entryRequestModal.addEventListener('click', (event) => {
                if (event.target === entryRequestModal) {
                    closeEntryRequestModal();
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
        const mergeRequestSubmitBtn = document.getElementById('merge-passports-request-submit-btn');
        const mergeRequestCancelBtn = document.getElementById('merge-passports-request-cancel-btn');
        const mergeRequestCloseBtn = document.getElementById('merge-passports-request-close-btn');
        const mergeRequestModal = document.getElementById('merge-passports-request-modal');
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
    }

    async function openOwnedListsModal(tabName) {
        const tab = tabName === 'approvals' ? 'approvals' : 'requests';
        if (modalBody && !fragmentReady) {
            modalBody.innerHTML = '<p class="owned-lists-modal__status note">Загрузка списка…</p>';
        }
        showModalShell(tab);
        try {
            await fetchFragment();
            setOwnedListTab(tab);
            applyOwnedFilters();
        } catch (err) {
            if (modalBody) {
                modalBody.innerHTML =
                    '<p class="owned-lists-modal__status note" style="color:#b42318;">Не удалось загрузить список заявок.</p>';
            }
        }
    }

    window.openOwnedListsModal = openOwnedListsModal;
    window.closeOwnedListsModal = closeOwnedListsModal;

    if (modalClose) {
        modalClose.addEventListener('click', closeOwnedListsModal);
    }
    if (modal) {
        modal.addEventListener('click', (event) => {
            if (event.target === modal) {
                closeOwnedListsModal();
            }
        });
    }
    document.addEventListener('keydown', (event) => {
        if (event.key !== 'Escape' || !isModalOpen()) {
            return;
        }
        const entryRequestModal = document.getElementById('entry-request-id-modal');
        const mergeRequestModal = document.getElementById('merge-passports-request-modal');
        if (entryRequestModal && entryRequestModal.style.display === 'flex') {
            closeEntryRequestModal();
            return;
        }
        if (mergeRequestModal && mergeRequestModal.style.display === 'flex') {
            closeMergeRequestModal();
            return;
        }
        closeOwnedListsModal();
    });
})();

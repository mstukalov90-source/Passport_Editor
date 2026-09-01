(function () {
    'use strict';

    const bootstrapEl = document.getElementById('approval-notifications-bootstrap');
    const homeUsernameNorm = (bootstrapEl?.dataset.username || '').trim();
    const homeOwnerIdNorm = (bootstrapEl?.dataset.ownerId || '').trim();
    const homeUrl = (bootstrapEl?.dataset.homeUrl || '/').trim() || '/';

    const approvalNotificationsBtn = document.getElementById('approval-notifications-btn');
    const approvalNotificationsModal = document.getElementById('approval-notifications-modal');
    const approvalNotificationsCloseBtn = document.getElementById('approval-notifications-close-btn');
    const approvalChatPreviewModal = document.getElementById('approval-chat-preview-modal');
    const approvalChatPreviewCloseBtn = document.getElementById('approval-chat-preview-close-btn');
    const approvalChatPreviewTitle = document.getElementById('approval-chat-preview-title');
    const approvalChatPreviewStatus = document.getElementById('approval-chat-preview-status');
    const approvalChatPreviewThread = document.getElementById('approval-chat-preview-thread');
    const approvalChatPreviewOpenLink = document.getElementById('approval-chat-preview-open-link');
    const approvalNotificationsTitleModeInput = document.getElementById('approval-notifications-title-mode');
    const actionsPage = document.getElementById('actions-page');
    const actionsApprovalsSection = document.getElementById('actions-approvals-section');
    const actionsFeed = document.getElementById('actions-events-feed');
    const actionsOdsSection = document.getElementById('actions-ods-sync-section');
    const actionsOdsList = document.getElementById('actions-ods-sync-list');
    const actionsEmpty = document.getElementById('actions-events-empty');
    const actionsTitleModeInput = document.getElementById('actions-title-mode');

    let notificationsTitleMode = 'numbers';
    let notificationsPreviousOverflow = '';

    function getHomeOdsSyncStorageKey() {
        return homeOwnerIdNorm ? `home_ods_sync_status:${homeOwnerIdNorm}` : 'home_ods_sync_status';
    }

    function getHomeOdsRequestIdsStorageKey() {
        return homeOwnerIdNorm ? `home_ods_request_ids:${homeOwnerIdNorm}` : 'home_ods_request_ids';
    }

    function getHomeNotificationsSeenStorageKey() {
        if (homeUsernameNorm) {
            return `home_notifications_seen:${homeUsernameNorm}`;
        }
        return homeOwnerIdNorm
            ? `home_notifications_seen:${homeOwnerIdNorm}`
            : 'home_notifications_seen';
    }

    function getNotificationsTitleModeStorageKey() {
        return homeOwnerIdNorm
            ? `home_notifications_title_mode:${homeOwnerIdNorm}`
            : 'home_notifications_title_mode';
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

    function readOdsRequestIdsSnapshot() {
        try {
            const raw = localStorage.getItem(getHomeOdsRequestIdsStorageKey());
            if (!raw) {
                return [];
            }
            const parsed = JSON.parse(raw);
            return Array.isArray(parsed) ? parsed.map((id) => String(id || '').trim()).filter(Boolean) : [];
        } catch (e) {
            return [];
        }
    }

    function writeOdsRequestIdsSnapshot(ids) {
        try {
            localStorage.setItem(getHomeOdsRequestIdsStorageKey(), JSON.stringify(ids));
        } catch (e) {
            // localStorage may be unavailable
        }
    }

    function emptyNotificationsSeenState() {
        return { seen: {}, baseline: false, ods_active: [], ods_history: [], ods_baseline: false };
    }

    function readNotificationsSeenState() {
        try {
            const raw = localStorage.getItem(getHomeNotificationsSeenStorageKey());
            if (!raw) {
                return emptyNotificationsSeenState();
            }
            const parsed = JSON.parse(raw);
            if (!parsed || typeof parsed !== 'object') {
                return emptyNotificationsSeenState();
            }
            const seen = parsed.seen && typeof parsed.seen === 'object' ? parsed.seen : {};
            const odsActive = Array.isArray(parsed.ods_active) ? parsed.ods_active : [];
            const odsHistory = Array.isArray(parsed.ods_history) ? parsed.ods_history : odsActive.slice();
            return {
                seen,
                baseline: parsed.baseline === true,
                ods_active: odsActive,
                ods_history: odsHistory,
                ods_baseline: parsed.ods_baseline === true,
            };
        } catch (e) {
            return emptyNotificationsSeenState();
        }
    }

    function writeNotificationsSeenState(state) {
        try {
            localStorage.setItem(
                getHomeNotificationsSeenStorageKey(),
                JSON.stringify({
                    seen: state.seen || {},
                    baseline: state.baseline === true,
                    ods_active: Array.isArray(state.ods_active) ? state.ods_active : [],
                    ods_history: Array.isArray(state.ods_history) ? state.ods_history : [],
                    ods_baseline: state.ods_baseline === true,
                })
            );
        } catch (e) {
            // localStorage may be unavailable
        }
    }

    function loadServerNotificationEvents() {
        const el = document.getElementById('home-notification-events');
        if (!el) {
            return [];
        }
        try {
            const parsed = JSON.parse(el.textContent || '[]');
            return Array.isArray(parsed) ? parsed : [];
        } catch (e) {
            return [];
        }
    }

    function hasOdsRequestRows() {
        return Boolean(document.querySelector('.owned-request-row'));
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

    function collectCurrentOdsRequestIds() {
        const ids = [];
        const seen = {};
        document.querySelectorAll('.owned-request-row').forEach((row) => {
            const brid = (row.dataset.requestId || '').trim();
            if (!brid || seen[brid]) {
                return;
            }
            seen[brid] = true;
            ids.push(brid);
        });
        ids.sort((a, b) => a.localeCompare(b, 'ru', { numeric: true }));
        return ids;
    }

    function buildOdsEventMessage(kind, brid) {
        const normalized = String(brid || '').trim();
        if (!normalized) {
            return null;
        }
        if (kind === 'ods_ok') {
            return {
                id: `ods_ok:${normalized}`,
                kind: 'ods_ok',
                brid: normalized,
                title: `Заявка № ${normalized} подтверждена АСУ ОДС`,
                subtitle: 'Подтверждена',
            };
        }
        if (kind === 'ods_bad') {
            return {
                id: `ods_bad:${normalized}`,
                kind: 'ods_bad',
                brid: normalized,
                title: `Заявка № ${normalized} не подтверждена АСУ ОДС`,
                subtitle: 'Не подтверждена',
            };
        }
        return {
            id: `ods_new:${normalized}`,
            kind: 'ods_new',
            brid: normalized,
            title: `Новая заявка № ${normalized}`,
            subtitle: 'Появилась в списке',
        };
    }

    function buildOdsSyncChangeMessages(prev, current) {
        const messages = [];
        Object.keys(current).forEach((brid) => {
            if (prev[brid] !== 'pending') {
                return;
            }
            const next = current[brid];
            if (next === 'ok' || next === 'bad') {
                const msg = buildOdsEventMessage(next === 'ok' ? 'ods_ok' : 'ods_bad', brid);
                if (msg) {
                    messages.push(msg);
                }
            }
        });
        messages.sort((a, b) => a.brid.localeCompare(b.brid, 'ru', { numeric: true }));
        return messages;
    }

    function buildOdsNewMessages(prevIds, currentIds) {
        const prevSet = {};
        (prevIds || []).forEach((id) => {
            const brid = String(id || '').trim();
            if (brid) {
                prevSet[brid] = true;
            }
        });
        const messages = [];
        (currentIds || []).forEach((id) => {
            const msg = buildOdsEventMessage('ods_new', id);
            if (!msg || prevSet[msg.brid]) {
                return;
            }
            messages.push(msg);
        });
        messages.sort((a, b) => a.brid.localeCompare(b.brid, 'ru', { numeric: true }));
        return messages;
    }

    function odsEventsFromCurrentState(requestIds, syncStatuses) {
        const messages = [];
        const statusBrids = {};
        Object.keys(syncStatuses || {}).forEach((brid) => {
            const status = syncStatuses[brid];
            if (status !== 'ok' && status !== 'bad') {
                return;
            }
            const msg = buildOdsEventMessage(status === 'ok' ? 'ods_ok' : 'ods_bad', brid);
            if (msg) {
                statusBrids[msg.brid] = true;
                messages.push(msg);
            }
        });
        (requestIds || []).forEach((id) => {
            const msg = buildOdsEventMessage('ods_new', id);
            if (!msg || statusBrids[msg.brid]) {
                return;
            }
            messages.push(msg);
        });
        messages.sort((a, b) => String(a.brid || '').localeCompare(String(b.brid || ''), 'ru', { numeric: true }));
        return messages;
    }

    function loadAllOdsEvents() {
        const state = readNotificationsSeenState();
        return mergeActiveOdsEvents(
            mergeActiveOdsEvents(state.ods_history, state.ods_active),
            odsEventsFromCurrentState(readOdsRequestIdsSnapshot(), readOdsSyncSnapshot())
        );
    }

    function odsFingerprintIds(requestIds, syncStatuses) {
        const ids = [];
        (requestIds || []).forEach((brid) => {
            const normalized = String(brid || '').trim();
            if (normalized) {
                ids.push(`ods_new:${normalized}`);
            }
        });
        Object.keys(syncStatuses || {}).forEach((brid) => {
            const status = syncStatuses[brid];
            if (status === 'ok') {
                ids.push(`ods_ok:${brid}`);
            } else if (status === 'bad') {
                ids.push(`ods_bad:${brid}`);
            } else if (status === 'pending') {
                ids.push(`ods_pending:${brid}`);
            }
        });
        return ids;
    }

    function notificationKindLabel(kind) {
        switch (kind) {
            case 'message':
                return 'Сообщение';
            case 'new_approve':
                return 'Согласование';
            case 'new_case':
                return 'Событие';
            case 'approved':
                return 'Согласовано';
            case 'ods_new':
                return 'Новая заявка';
            case 'ods_ok':
                return 'Подтверждена';
            case 'ods_bad':
                return 'Не подтверждена';
            default:
                return 'Уведомление';
        }
    }

    function markNotificationSeen(eventId) {
        const id = String(eventId || '').trim();
        if (!id) {
            return;
        }
        const state = readNotificationsSeenState();
        state.seen[id] = true;
        state.ods_active = (state.ods_active || []).filter((item) => item && item.id !== id);
        writeNotificationsSeenState(state);
    }

    function mergeActiveOdsEvents(existing, incoming) {
        const byId = {};
        (existing || []).forEach((item) => {
            if (item && item.id) {
                byId[item.id] = item;
            }
        });
        (incoming || []).forEach((item) => {
            if (item && item.id) {
                byId[item.id] = item;
            }
        });
        return Object.keys(byId)
            .map((id) => byId[id])
            .sort((a, b) => String(a.brid || '').localeCompare(String(b.brid || ''), 'ru', { numeric: true }));
    }

    function updateApprovalNotificationsBadge(totalCount) {
        const btn = document.getElementById('approval-notifications-btn');
        if (!btn) {
            return;
        }
        const total = Number(totalCount) || 0;
        let badge = btn.querySelector('.approval-notifications-badge');
        if (total > 0) {
            if (!badge) {
                badge = document.createElement('span');
                badge.className = 'approval-notifications-badge';
                btn.appendChild(badge);
            }
            badge.hidden = false;
            badge.textContent = String(total);
        } else if (badge) {
            badge.remove();
        }
    }

    function eventDisplayTitle(event) {
        if (!event) {
            return '';
        }
        if (notificationsTitleMode === 'names' && event.title_named) {
            return event.title_named;
        }
        return event.title || event.title_named || '';
    }

    function appendServerEventRow(listEl, event) {
        const li = document.createElement('li');
        const row = document.createElement('div');
        row.className = 'approval-notifications-case';
        row.dataset.eventId = event.id || '';
        row.dataset.eventKind = event.kind || '';
        row.dataset.approveId = event.approve_id || '';
        row.dataset.caseId = event.case_id || '';
        row.dataset.titleNumbers = event.title || '';
        row.dataset.titleNames = event.title_named || event.title || '';
        row.setAttribute('role', 'button');
        row.tabIndex = 0;

        const main = document.createElement('div');
        main.className = 'approval-notifications-case__main';
        const kind = document.createElement('span');
        kind.className = 'approval-notifications-item__kind';
        kind.textContent = notificationKindLabel(event.kind);
        const title = document.createElement('span');
        title.className = 'approval-notifications-item__title';
        title.textContent = eventDisplayTitle(event);
        const meta = document.createElement('span');
        meta.className = 'approval-notifications-case__meta';
        const metaParts = [];
        if (event.subtitle) {
            metaParts.push(event.subtitle);
        }
        if (event.created_at) {
            metaParts.push(event.created_at);
        }
        meta.textContent = metaParts.join(' · ');
        main.appendChild(kind);
        main.appendChild(title);
        main.appendChild(meta);
        row.appendChild(main);

        if (event.case_id && (event.kind === 'message' || event.kind === 'new_case' || event.kind === 'approved')) {
            const chatBtn = document.createElement('button');
            chatBtn.type = 'button';
            chatBtn.className = 'approval-notifications-chat-btn';
            chatBtn.dataset.eventId = event.id || '';
            chatBtn.dataset.approveId = event.approve_id || '';
            chatBtn.dataset.caseId = event.case_id || '';
            chatBtn.dataset.caseTitle = eventDisplayTitle(event);
            chatBtn.dataset.titleNumbers = event.title || '';
            chatBtn.dataset.titleNames = event.title_named || event.title || '';
            chatBtn.textContent = 'Чат';
            row.appendChild(chatBtn);
        }

        li.appendChild(row);
        listEl.appendChild(li);
    }

    function appendOdsEventRow(listEl, msg) {
        const li = document.createElement('li');
        const item = document.createElement('button');
        item.type = 'button';
        item.className = msg.kind === 'ods_ok'
            ? 'approval-notifications-item approval-ods-sync-item--ok'
            : (msg.kind === 'ods_bad'
                ? 'approval-notifications-item approval-ods-sync-item--bad'
                : 'approval-notifications-item approval-ods-sync-item--new');
        item.dataset.eventId = msg.id || '';
        item.dataset.odsBrid = msg.brid || '';
        item.setAttribute('role', 'option');
        const kind = document.createElement('span');
        kind.className = 'approval-notifications-item__kind';
        kind.textContent = notificationKindLabel(msg.kind);
        const title = document.createElement('span');
        title.className = 'approval-notifications-item__title';
        title.textContent = msg.title || '';
        const status = document.createElement('span');
        status.className = 'approval-notifications-item__status';
        status.textContent = msg.subtitle || '';
        item.appendChild(kind);
        item.appendChild(title);
        item.appendChild(status);
        li.appendChild(item);
        listEl.appendChild(li);
    }

    function renderOdsEventList(listEl, odsEvents) {
        if (!listEl) {
            return;
        }
        listEl.replaceChildren();
        (odsEvents || []).forEach((msg) => {
            appendOdsEventRow(listEl, msg);
        });
    }

    function renderApprovalNotificationFeed(serverEvents, odsEvents) {
        const approvalsSection = document.getElementById('approval-notifications-approvals-section');
        const approvalsList = document.getElementById('approval-notifications-feed');
        const odsSection = document.getElementById('approval-ods-sync-section');
        const odsList = document.getElementById('approval-ods-sync-list');
        const emptyEl = document.getElementById('approval-notifications-empty');

        if (approvalsList) {
            approvalsList.replaceChildren();
            (serverEvents || []).forEach((event) => {
                appendServerEventRow(approvalsList, event);
            });
        }

        if (odsList) {
            renderOdsEventList(odsList, odsEvents);
        }

        const hasApprovals = !!(serverEvents && serverEvents.length);
        const hasOds = !!(odsEvents && odsEvents.length);
        if (approvalsSection) {
            approvalsSection.hidden = !hasApprovals;
        }
        if (odsSection) {
            odsSection.hidden = !hasOds;
        }
        if (emptyEl) {
            emptyEl.hidden = hasApprovals || hasOds;
        }
        updateApprovalNotificationsBadge((serverEvents || []).length + (odsEvents || []).length);
    }

    function applyHomeWorkflowOdsSyncNotifications() {
        const serverEvents = loadServerNotificationEvents();
        const hasOdsRows = hasOdsRequestRows();
        let state = readNotificationsSeenState();

        if (hasOdsRows) {
            const prevSync = readOdsSyncSnapshot();
            const currentSync = collectCurrentOdsSyncStatuses();
            const prevRequestIds = readOdsRequestIdsSnapshot();
            const currentRequestIds = collectCurrentOdsRequestIds();
            if (!state.ods_baseline) {
                odsFingerprintIds(currentRequestIds, currentSync).forEach((id) => {
                    state.seen[id] = true;
                });
                state.ods_baseline = true;
                state.ods_active = [];
                state.ods_history = mergeActiveOdsEvents(
                    state.ods_history,
                    odsEventsFromCurrentState(currentRequestIds, currentSync)
                );
                writeOdsSyncSnapshot(currentSync);
                writeOdsRequestIdsSnapshot(currentRequestIds);
            } else {
                const detectedOds = [
                    ...buildOdsNewMessages(prevRequestIds, currentRequestIds),
                    ...buildOdsSyncChangeMessages(prevSync, currentSync),
                ];
                state.ods_history = mergeActiveOdsEvents(state.ods_history, detectedOds);
                state.ods_active = mergeActiveOdsEvents(state.ods_active, detectedOds)
                    .filter((item) => item && item.id && !state.seen[item.id]);
                writeOdsSyncSnapshot(currentSync);
                writeOdsRequestIdsSnapshot(currentRequestIds);
            }
        }

        if (!state.baseline) {
            const seen = { ...(state.seen || {}) };
            serverEvents.forEach((event) => {
                if (event && event.id) {
                    seen[event.id] = true;
                }
            });
            state = {
                seen,
                baseline: true,
                ods_active: state.ods_active || [],
                ods_history: state.ods_history || [],
                ods_baseline: state.ods_baseline === true,
            };
            writeNotificationsSeenState(state);
            renderApprovalNotificationFeed([], hasOdsRows ? [] : (state.ods_active || []));
            return;
        }

        writeNotificationsSeenState(state);
        const unreadServer = serverEvents.filter((event) => event && event.id && !state.seen[event.id]);
        const unreadOds = (state.ods_active || []).filter((item) => item && item.id && !state.seen[item.id]);
        renderApprovalNotificationFeed(unreadServer, unreadOds);
    }

    function refreshUnreadNotificationsFeed() {
        const state = readNotificationsSeenState();
        const unreadServer = loadServerNotificationEvents().filter(
            (event) => event && event.id && !state.seen[event.id]
        );
        const unreadOds = (state.ods_active || []).filter((item) => item && item.id && !state.seen[item.id]);
        renderApprovalNotificationFeed(unreadServer, unreadOds);
    }

    function readNotificationsTitleMode() {
        try {
            const raw = localStorage.getItem(getNotificationsTitleModeStorageKey());
            return raw === 'names' ? 'names' : 'numbers';
        } catch (e) {
            return 'numbers';
        }
    }

    function persistNotificationsTitleMode(mode) {
        try {
            localStorage.setItem(getNotificationsTitleModeStorageKey(), mode === 'names' ? 'names' : 'numbers');
        } catch (e) {
            // localStorage may be unavailable
        }
    }

    function notificationCaseTitle(el) {
        if (!el) {
            return '';
        }
        const numbers = el.dataset.titleNumbers || '';
        const names = el.dataset.titleNames || '';
        if (notificationsTitleMode === 'names' && names) {
            return names;
        }
        return numbers || names || el.dataset.caseTitle || '';
    }

    function applyNotificationsTitleModeTo(root) {
        if (!root) {
            return;
        }
        root.querySelectorAll('.approval-notifications-case').forEach((row) => {
            const titleEl = row.querySelector('.approval-notifications-item__title');
            if (titleEl) {
                titleEl.textContent = notificationCaseTitle(row);
            }
            const chatBtn = row.querySelector('.approval-notifications-chat-btn');
            if (chatBtn) {
                chatBtn.dataset.caseTitle = notificationCaseTitle(chatBtn) || notificationCaseTitle(row);
            }
        });
    }

    function applyNotificationsTitleMode() {
        applyNotificationsTitleModeTo(approvalNotificationsModal);
        applyNotificationsTitleModeTo(actionsPage);
    }

    function setTitleModeInputs(mode) {
        const isNames = mode === 'names';
        if (approvalNotificationsTitleModeInput) {
            approvalNotificationsTitleModeInput.checked = isNames;
        }
        if (actionsTitleModeInput) {
            actionsTitleModeInput.checked = isNames;
        }
    }

    function bindTitleModeInput(input) {
        if (!input) {
            return;
        }
        input.addEventListener('change', () => {
            notificationsTitleMode = input.checked ? 'names' : 'numbers';
            persistNotificationsTitleMode(notificationsTitleMode);
            setTitleModeInputs(notificationsTitleMode);
            applyNotificationsTitleMode();
        });
    }

    function initNotificationsTitleModeSwitch() {
        notificationsTitleMode = readNotificationsTitleMode();
        setTitleModeInputs(notificationsTitleMode);
        bindTitleModeInput(approvalNotificationsTitleModeInput);
        bindTitleModeInput(actionsTitleModeInput);
        applyNotificationsTitleMode();
    }

    function renderActionsFeed(serverEvents, odsEvents) {
        if (actionsFeed) {
            actionsFeed.replaceChildren();
            (serverEvents || []).forEach((event) => {
                appendServerEventRow(actionsFeed, event);
            });
        }
        renderOdsEventList(actionsOdsList, odsEvents);
        const hasApprovals = !!(serverEvents && serverEvents.length);
        const hasOds = !!(odsEvents && odsEvents.length);
        if (actionsApprovalsSection) {
            actionsApprovalsSection.hidden = !hasApprovals;
        }
        if (actionsOdsSection) {
            actionsOdsSection.hidden = !hasOds;
        }
        if (actionsEmpty) {
            actionsEmpty.hidden = hasApprovals || hasOds;
        }
    }

    function approvalCaseUrl(approveId, caseId) {
        const params = new URLSearchParams();
        if (approveId) {
            params.set('approve', String(approveId));
        }
        if (caseId) {
            params.set('case', String(caseId));
        }
        const query = params.toString();
        return query ? '/approval/?' + query : '/approval/';
    }

    function setApprovalNotificationsOpen(isOpen) {
        if (!approvalNotificationsBtn || !approvalNotificationsModal) {
            return;
        }
        approvalNotificationsBtn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        approvalNotificationsModal.hidden = !isOpen;
        approvalNotificationsBtn.classList.toggle('is-open', isOpen);
        if (isOpen) {
            notificationsPreviousOverflow = document.body.style.overflow;
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = notificationsPreviousOverflow || '';
        }
    }

    function setApprovalChatPreviewOpen(isOpen) {
        if (!approvalChatPreviewModal) {
            return;
        }
        approvalChatPreviewModal.hidden = !isOpen;
        if (isOpen) {
            document.body.style.overflow = 'hidden';
        } else if (approvalNotificationsModal && !approvalNotificationsModal.hidden) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = notificationsPreviousOverflow || '';
        }
    }

    function openApprovalFromNotifications(approveId, caseId) {
        const normalizedApproveId = String(approveId || '').trim();
        const normalizedCaseId = String(caseId || '').trim();
        if (!normalizedApproveId && !normalizedCaseId) {
            return;
        }
        setApprovalChatPreviewOpen(false);
        setApprovalNotificationsOpen(false);
        window.location.href = approvalCaseUrl(normalizedApproveId, normalizedCaseId);
    }

    function openOdsRequestFromNotifications(brid) {
        const normalizedBrid = String(brid || '').trim().toLowerCase();
        if (!normalizedBrid) {
            return;
        }
        setApprovalNotificationsOpen(false);
        const requestsTab = document.querySelector('[data-owned-list-tab="requests"]');
        if (requestsTab) {
            requestsTab.click();
        }
        let targetRow = null;
        document.querySelectorAll('.owned-request-row').forEach((row) => {
            const rowId = (row.dataset.requestId || '').trim().toLowerCase();
            if (rowId && rowId === normalizedBrid) {
                targetRow = row;
            }
        });
        if (!targetRow) {
            window.location.href = homeUrl;
            return;
        }
        if (typeof targetRow.scrollIntoView === 'function') {
            targetRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function renderChatPreviewMessages(messages) {
        if (!approvalChatPreviewThread) {
            return;
        }
        approvalChatPreviewThread.replaceChildren();
        if (!messages.length) {
            const empty = document.createElement('p');
            empty.className = 'note';
            empty.textContent = 'В чате пока нет сообщений.';
            approvalChatPreviewThread.appendChild(empty);
            return;
        }
        messages.forEach((message) => {
            if (message && message.is_service) {
                return;
            }
            if (message && message.kind && message.kind !== 'chat') {
                return;
            }
            const wrap = document.createElement('div');
            wrap.className = 'approval-chat-preview-message';
            const head = document.createElement('div');
            head.className = 'approval-chat-preview-message__author';
            head.textContent = message.author || '—';
            if (message.time) {
                const time = document.createElement('span');
                time.className = 'approval-chat-preview-message__time';
                time.textContent = message.time;
                head.appendChild(time);
            }
            const body = document.createElement('div');
            body.className = 'approval-chat-preview-message__body';
            body.textContent = message.text || message.body || '';
            wrap.appendChild(head);
            wrap.appendChild(body);
            approvalChatPreviewThread.appendChild(wrap);
        });
    }

    async function openApprovalChatPreview(approveId, caseId, caseTitle) {
        if (!approvalChatPreviewModal || !caseId) {
            return;
        }
        if (approvalChatPreviewTitle) {
            approvalChatPreviewTitle.textContent = caseTitle
                ? ('Превью чата: ' + caseTitle)
                : 'Превью чата';
        }
        if (approvalChatPreviewStatus) {
            approvalChatPreviewStatus.hidden = false;
            approvalChatPreviewStatus.textContent = 'Загрузка…';
        }
        if (approvalChatPreviewThread) {
            approvalChatPreviewThread.replaceChildren();
        }
        if (approvalChatPreviewOpenLink) {
            approvalChatPreviewOpenLink.href = approvalCaseUrl(approveId, caseId);
        }
        setApprovalChatPreviewOpen(true);
        try {
            const response = await fetch('/approval/api/cases/' + encodeURIComponent(caseId) + '/', {
                credentials: 'same-origin',
                headers: { Accept: 'application/json' },
            });
            const data = await response.json().catch(() => ({}));
            if (!response.ok || !data || data.ok === false) {
                throw new Error((data && data.error) || 'Не удалось загрузить чат.');
            }
            const caseItem = data.case || {};
            const messages = Array.isArray(caseItem.messages)
                ? caseItem.messages
                : (Array.isArray(caseItem.timeline) ? caseItem.timeline : []);
            if (approvalChatPreviewStatus) {
                approvalChatPreviewStatus.hidden = true;
                approvalChatPreviewStatus.textContent = '';
            }
            renderChatPreviewMessages(messages);
        } catch (error) {
            if (approvalChatPreviewStatus) {
                approvalChatPreviewStatus.hidden = false;
                approvalChatPreviewStatus.textContent =
                    (error && error.message) || 'Не удалось загрузить чат.';
            }
        }
    }

    function handleFeedClick(event) {
        const chatBtn = event.target.closest('.approval-notifications-chat-btn');
        if (chatBtn) {
            event.preventDefault();
            event.stopPropagation();
            if (chatBtn.dataset.eventId) {
                markNotificationSeen(chatBtn.dataset.eventId);
                refreshUnreadNotificationsFeed();
            }
            openApprovalChatPreview(
                chatBtn.dataset.approveId,
                chatBtn.dataset.caseId,
                notificationCaseTitle(chatBtn) || chatBtn.dataset.caseTitle
            );
            return;
        }
        const odsItem = event.target.closest('.approval-notifications-item[data-ods-brid]');
        if (odsItem) {
            if (odsItem.dataset.eventId) {
                markNotificationSeen(odsItem.dataset.eventId);
                refreshUnreadNotificationsFeed();
            }
            openOdsRequestFromNotifications(odsItem.dataset.odsBrid);
            return;
        }
        const caseRow = event.target.closest('.approval-notifications-case[data-event-id], .approval-notifications-case[data-case-id]');
        if (caseRow) {
            if (caseRow.dataset.eventId) {
                markNotificationSeen(caseRow.dataset.eventId);
                refreshUnreadNotificationsFeed();
            }
            openApprovalFromNotifications(caseRow.dataset.approveId, caseRow.dataset.caseId);
        }
    }

    function handleFeedKeydown(event) {
        if (event.key !== 'Enter' && event.key !== ' ') {
            return;
        }
        const caseRow = event.target.closest('.approval-notifications-case[data-event-id], .approval-notifications-case[data-case-id]');
        if (!caseRow || event.target.closest('.approval-notifications-chat-btn')) {
            return;
        }
        event.preventDefault();
        if (caseRow.dataset.eventId) {
            markNotificationSeen(caseRow.dataset.eventId);
            refreshUnreadNotificationsFeed();
        }
        openApprovalFromNotifications(caseRow.dataset.approveId, caseRow.dataset.caseId);
    }

    if (approvalNotificationsBtn && approvalNotificationsModal) {
        approvalNotificationsBtn.addEventListener('click', (event) => {
            event.stopPropagation();
            const isOpen = approvalNotificationsBtn.getAttribute('aria-expanded') === 'true';
            setApprovalNotificationsOpen(!isOpen);
        });
        if (approvalNotificationsCloseBtn) {
            approvalNotificationsCloseBtn.addEventListener('click', () => {
                setApprovalNotificationsOpen(false);
            });
        }
        approvalNotificationsModal.addEventListener('click', (event) => {
            if (event.target === approvalNotificationsModal) {
                setApprovalNotificationsOpen(false);
                return;
            }
            handleFeedClick(event);
        });
        approvalNotificationsModal.addEventListener('keydown', handleFeedKeydown);
    }

    if (approvalChatPreviewCloseBtn) {
        approvalChatPreviewCloseBtn.addEventListener('click', () => {
            setApprovalChatPreviewOpen(false);
        });
    }
    if (approvalChatPreviewModal) {
        approvalChatPreviewModal.addEventListener('click', (event) => {
            if (event.target === approvalChatPreviewModal) {
                setApprovalChatPreviewOpen(false);
            }
        });
    }
    document.addEventListener('keydown', (event) => {
        if (event.key !== 'Escape') {
            return;
        }
        if (approvalChatPreviewModal && !approvalChatPreviewModal.hidden) {
            setApprovalChatPreviewOpen(false);
            return;
        }
        if (approvalNotificationsModal && !approvalNotificationsModal.hidden) {
            setApprovalNotificationsOpen(false);
        }
    });

    initNotificationsTitleModeSwitch();
    applyHomeWorkflowOdsSyncNotifications();
    if (actionsPage) {
        renderActionsFeed(loadServerNotificationEvents(), loadAllOdsEvents());
        applyNotificationsTitleMode();
        actionsPage.addEventListener('click', handleFeedClick);
        actionsPage.addEventListener('keydown', handleFeedKeydown);
    }
})();

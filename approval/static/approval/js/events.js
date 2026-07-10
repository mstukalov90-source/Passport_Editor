(function () {
    'use strict';

    const state = {
        config: null,
        cases: [],
        activeCaseId: null,
        selectedApproveId: null,
        pendingMessageGeometry: null,
        activeMessageGeometryId: null,
    };

    function el(id) {
        return document.getElementById(id);
    }

    function mapApi() {
        return window.ApprovalMap || {};
    }

    function drawApi() {
        return window.ApprovalEventDraw || {};
    }

    async function fetchJson(url, options) {
        const headers = Object.assign({}, (options && options.headers) || {});
        const method = (options && options.method) || 'GET';
        if (method !== 'GET') {
            headers['X-CSRFToken'] = mapApi().getCookie('csrftoken');
        }
        const response = await fetch(url, Object.assign({}, options || {}, { headers: headers }));
        const data = await response.json().catch(function () {
            return { ok: false, error: 'Некорректный ответ сервера.' };
        });
        if (!response.ok || !data.ok) {
            throw new Error(data.error || 'Ошибка запроса.');
        }
        return data;
    }

    function splitCases(cases) {
        const secondary = [];
        let primary = null;
        (cases || []).forEach(function (caseItem) {
            if (caseItem.is_primary) {
                primary = caseItem;
            } else {
                secondary.push(caseItem);
            }
        });
        return { primary: primary, secondary: secondary };
    }

    function renderAttachments(message) {
        if (!message.attachments || !message.attachments.length) {
            return '';
        }
        return message.attachments
            .map(function (attachment) {
                const isImage = (attachment.content_type || '').indexOf('image/') === 0;
                if (isImage) {
                    return (
                        '<a class="approval-chat-attachment approval-chat-attachment--image" href="' +
                        attachment.url +
                        '" target="_blank" rel="noopener">' +
                        '<img src="' +
                        attachment.url +
                        '" alt="' +
                        escapeHtml(attachment.original_name) +
                        '">' +
                        '</a>'
                    );
                }
                return (
                    '<a class="approval-chat-attachment" href="' +
                    attachment.url +
                    '" target="_blank" rel="noopener">' +
                    escapeHtml(attachment.original_name) +
                    '</a>'
                );
            })
            .join('');
    }

    function escapeHtml(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function updateGeometryHint() {
        const hint = el('approval-chat-geometry-hint');
        if (!hint) {
            return;
        }
        if (state.pendingMessageGeometry) {
            hint.hidden = false;
            hint.innerHTML =
                'Геометрия добавлена к сообщению. ' +
                '<button type="button" class="approval-chat-composer__geometry-hint-btn" data-geometry-action="edit">Изменить</button> ' +
                '<button type="button" class="approval-chat-composer__geometry-hint-btn" data-geometry-action="remove">Убрать</button>';
            const editBtn = hint.querySelector('[data-geometry-action="edit"]');
            const removeBtn = hint.querySelector('[data-geometry-action="remove"]');
            if (editBtn) {
                editBtn.addEventListener('click', function (event) {
                    event.preventDefault();
                    startGeometryDrawMode();
                });
            }
            if (removeBtn) {
                removeBtn.addEventListener('click', function (event) {
                    event.preventDefault();
                    clearPendingMessageGeometry();
                });
            }
        } else {
            hint.hidden = true;
            hint.innerHTML = '';
        }
    }

    function setPendingMessageGeometry(geometry) {
        state.pendingMessageGeometry = geometry;
        if (mapApi().setPendingMessageGeometry) {
            mapApi().setPendingMessageGeometry(geometry);
        }
        updateGeometryHint();
    }

    function clearPendingMessageGeometry(options) {
        const opts = options || {};
        state.pendingMessageGeometry = null;
        if (mapApi().clearPendingMessageGeometry) {
            mapApi().clearPendingMessageGeometry();
        }
        updateGeometryHint();
        if (opts.stopDraw !== false) {
            drawApi().stopDrawMode();
        }
    }

    function startGeometryDrawMode() {
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || caseItem.approved) {
            return;
        }
        clearPendingMessageGeometry({ stopDraw: false });
        const startDraw = drawApi().startDrawMode || drawApi().startCreateMode;
        if (typeof startDraw !== 'function') {
            return;
        }
        startDraw(function (geometry) {
            setPendingMessageGeometry(geometry);
        });
    }

    function bindMessageGeometryClicks() {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        thread.querySelectorAll('.approval-chat-message--has-geometry').forEach(function (article) {
            article.addEventListener('click', function () {
                const messageId = article.dataset.messageId;
                if (!messageId) {
                    return;
                }
                state.activeMessageGeometryId = messageId;
                thread.querySelectorAll('.approval-chat-message--geometry-active').forEach(function (node) {
                    node.classList.remove('approval-chat-message--geometry-active');
                });
                article.classList.add('approval-chat-message--geometry-active');
                mapApi().highlightMessageGeometry(messageId);
                mapApi().fitMessageGeometry(messageId);
            });
        });
    }

    function renderChatMessages(messages) {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        if (!messages || !messages.length) {
            thread.innerHTML = '<p class="approval-events__empty">Сообщений пока нет.</p>';
            return;
        }
        thread.innerHTML = messages
            .map(function (message) {
                const ownClass = message.is_own ? ' approval-chat-message--own' : '';
                const geometryClass = message.geometry ? ' approval-chat-message--has-geometry' : '';
                const activeClass =
                    state.activeMessageGeometryId &&
                    String(message.id) === String(state.activeMessageGeometryId)
                        ? ' approval-chat-message--geometry-active'
                        : '';
                const geometryBadge = message.geometry
                    ? '<p class="approval-chat-message__geometry-badge">Геометрия</p>'
                    : '';
                return (
                    '<article class="approval-chat-message' +
                    ownClass +
                    geometryClass +
                    activeClass +
                    '" data-message-id="' +
                    escapeHtml(message.id) +
                    '">' +
                    '<header class="approval-chat-message__header">' +
                    '<span class="approval-chat-message__author">' +
                    escapeHtml(message.author) +
                    '</span>' +
                    '<time class="approval-chat-message__time">' +
                    escapeHtml(message.time) +
                    '</time>' +
                    '</header>' +
                    '<p class="approval-chat-message__text">' +
                    escapeHtml(message.text) +
                    '</p>' +
                    geometryBadge +
                    renderAttachments(message) +
                    '</article>'
                );
            })
            .join('');
        bindMessageGeometryClicks();
        thread.scrollTop = thread.scrollHeight;
    }

    function updateComposerState(caseItem) {
        const closed = !!(caseItem && caseItem.approved);
        const input = el('approval-chat-input');
        const sendBtn = el('approval-chat-send-btn');
        const approveBtn = el('approval-chat-approve-btn');
        const attachBtn = el('approval-chat-attach-btn');
        const geometryBtn = el('approval-chat-geometry-btn');
        const filesInput = el('approval-chat-files');
        const closedBanner = el('approval-closed-banner');
        const progress = el('approval-approval-progress');

        if (input) {
            input.disabled = closed;
        }
        if (sendBtn) {
            sendBtn.disabled = closed;
        }
        if (attachBtn) {
            attachBtn.disabled = closed;
        }
        if (geometryBtn) {
            geometryBtn.disabled = closed;
        }
        if (filesInput) {
            filesInput.disabled = closed;
        }
        if (approveBtn) {
            approveBtn.disabled = closed || !!(caseItem && caseItem.current_owner_approved);
            approveBtn.textContent = caseItem && caseItem.current_owner_approved ? 'Вы согласовали' : 'Согласовать';
        }
        if (closedBanner) {
            closedBanner.hidden = !closed;
        }
        if (progress && caseItem) {
            progress.hidden = false;
            progress.textContent =
                'Согласование: ' + caseItem.approvals_done + ' / ' + caseItem.approvals_total;
        }
    }

    function renderActiveCase(caseItem, options) {
        if (!caseItem) {
            el('approval-active-title').textContent = '';
            el('approval-active-status').textContent = '';
            renderChatMessages([]);
            updateComposerState(null);
            mapApi().highlightCase(null);
            mapApi().renderGeometries(null);
            clearPendingMessageGeometry();
            return;
        }

        const previousCaseId = state.activeCaseId;
        state.activeCaseId = caseItem.id;
        if (previousCaseId && previousCaseId !== caseItem.id) {
            clearPendingMessageGeometry();
        }
        state.activeMessageGeometryId = null;
        el('approval-active-title').textContent = caseItem.title;
        const statusEl = el('approval-active-status');
        statusEl.textContent = caseItem.status;
        statusEl.className =
            'approval-events__status approval-events__status--' + (caseItem.status_class || 'active');

        mapApi().highlightCase(caseItem.id);
        mapApi().renderGeometries(caseItem);
        const fitMap = !options || options.fitMap !== false;
        if (fitMap) {
            mapApi().fitCaseGeometry(caseItem.id);
        }
        updateComposerState(caseItem);
    }

    function buildEventCardHtml(caseItem, options) {
        const opts = options || {};
        const title = opts.titleOverride || caseItem.title;
        const extraClass = opts.extraClass || '';
        const active = caseItem.id === state.activeCaseId ? ' is-active' : '';
        return (
            '<div class="approval-event-card' +
            extraClass +
            active +
            '">' +
            '<div class="approval-event-card__head">' +
            '<span class="approval-event-card__title">' +
            escapeHtml(title) +
            '</span>' +
            '<span class="approval-event-card__status approval-event-card__status--' +
            escapeHtml(caseItem.status_class || 'active') +
            '">' +
            escapeHtml(caseItem.status) +
            '</span>' +
            '</div>' +
            '<p class="approval-event-card__preview">' +
            escapeHtml(caseItem.preview || '') +
            '</p>' +
            '<div class="approval-event-card__footer">' +
            '<span class="approval-event-card__count">' +
            caseItem.messages_count +
            ' сообщ.</span>' +
            '<button type="button" class="approval-event-card__open" data-case-id="' +
            caseItem.id +
            '">Открыть чат</button>' +
            '</div>' +
            '</div>'
        );
    }

    function bindEventCardClicks(root) {
        if (!root) {
            return;
        }
        root.querySelectorAll('.approval-event-card__open').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.stopPropagation();
                openCase(button.dataset.caseId, { fitMap: false });
            });
        });
        root.querySelectorAll('.approval-event-card').forEach(function (card) {
            card.addEventListener('click', function (event) {
                if (event.target.closest('.approval-event-card__open')) {
                    return;
                }
                const openBtn = card.querySelector('.approval-event-card__open');
                if (openBtn) {
                    openCase(openBtn.dataset.caseId, { fitMap: false });
                }
            });
        });
    }

    function renderPrimaryEventCard(primaryCase) {
        const slot = el('approval-primary-event-card');
        if (!slot) {
            return;
        }
        if (!primaryCase) {
            slot.hidden = true;
            slot.innerHTML = '';
            return;
        }
        slot.hidden = false;
        slot.innerHTML = buildEventCardHtml(primaryCase, {
            titleOverride: 'Основное событие',
            extraClass: ' approval-event-card--primary',
        });
        bindEventCardClicks(slot);
    }

    function renderSecondaryList(secondaryCases) {
        const list = el('approval-secondary-event-list');
        const empty = el('approval-secondary-empty');
        if (!list) {
            return;
        }
        if (!secondaryCases.length) {
            list.innerHTML = '';
            if (empty) {
                empty.hidden = false;
            }
            return;
        }
        if (empty) {
            empty.hidden = true;
        }
        list.innerHTML = secondaryCases
            .map(function (caseItem) {
                return '<li>' + buildEventCardHtml(caseItem) + '</li>';
            })
            .join('');

        bindEventCardClicks(list);
    }

    function renderEventNav(split) {
        renderPrimaryEventCard(split.primary);
        renderSecondaryList(split.secondary);
    }

    function findCase(caseId) {
        return state.cases.find(function (item) {
            return item.id === caseId;
        });
    }

    async function openCase(caseId, options) {
        const data = await fetchJson(mapApi().apiUrl(state.config.apiUrls.caseDetail, { caseId: caseId }));
        const caseItem = data.case;
        const index = state.cases.findIndex(function (item) {
            return item.id === caseId;
        });
        if (index >= 0) {
            const prev = state.cases[index];
            state.cases[index] = Object.assign({}, prev, caseItem, {
                geometry: caseItem.geometry != null ? caseItem.geometry : (prev && prev.geometry),
            });
        }
        renderActiveCase(caseItem, options);
        renderChatMessages(caseItem.messages || []);
        const split = splitCases(state.cases);
        renderEventNav(split);
    }

    async function loadBootstrap(approveId) {
        let url = state.config.apiUrls.bootstrap;
        if (approveId) {
            url += (url.indexOf('?') >= 0 ? '&' : '?') + 'approve_id=' + encodeURIComponent(approveId);
        }
        const data = await fetchJson(url);
        state.cases = data.cases || [];
        state.selectedApproveId = data.selected_approve_id;

        const split = splitCases(state.cases);
        renderEventNav(split);

        const defaultCaseId = state.activeCaseId || data.primary_case_id || (split.primary && split.primary.id);
        if (defaultCaseId) {
            await openCase(defaultCaseId);
        } else {
            renderActiveCase(null);
            renderChatMessages([]);
        }
    }

    async function sendMessage() {
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || caseItem.approved) {
            return;
        }
        const input = el('approval-chat-input');
        const filesInput = el('approval-chat-files');
        const body = (input && input.value || '').trim();
        const files = filesInput && filesInput.files ? Array.from(filesInput.files) : [];
        if (!body && !files.length && !state.pendingMessageGeometry) {
            return;
        }

        const formData = new FormData();
        formData.append('body', body);
        files.forEach(function (file) {
            formData.append('files', file);
        });
        if (state.pendingMessageGeometry) {
            formData.append('geometry', JSON.stringify(state.pendingMessageGeometry));
        }

        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.postMessage, { caseId: state.activeCaseId }),
            { method: 'POST', body: formData }
        );

        if (input) {
            input.value = '';
        }
        if (filesInput) {
            filesInput.value = '';
        }
        el('approval-chat-file-names').textContent = '';
        clearPendingMessageGeometry();

        const index = state.cases.findIndex(function (item) {
            return item.id === state.activeCaseId;
        });
        if (index >= 0) {
            state.cases[index] = Object.assign({}, state.cases[index], data.case);
        }
        await openCase(state.activeCaseId, { fitMap: false });
    }

    async function approveCase() {
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || caseItem.approved) {
            return;
        }
        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.approveCase, { caseId: state.activeCaseId }),
            { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' }
        );
        const index = state.cases.findIndex(function (item) {
            return item.id === state.activeCaseId;
        });
        if (index >= 0) {
            state.cases[index] = Object.assign({}, state.cases[index], data.case);
        }
        await openCase(state.activeCaseId, { fitMap: false });
    }

    function bindUi() {
        const sendBtn = el('approval-chat-send-btn');
        const approveBtn = el('approval-chat-approve-btn');
        const attachBtn = el('approval-chat-attach-btn');
        const geometryBtn = el('approval-chat-geometry-btn');
        const filesInput = el('approval-chat-files');

        if (sendBtn) {
            sendBtn.addEventListener('click', function () {
                sendMessage().catch(showError);
            });
        }
        const chatInput = el('approval-chat-input');
        if (chatInput) {
            chatInput.addEventListener('keydown', function (event) {
                if (event.key !== 'Enter' || event.shiftKey) {
                    return;
                }
                event.preventDefault();
                sendMessage().catch(showError);
            });
        }
        if (approveBtn) {
            approveBtn.addEventListener('click', function () {
                approveCase().catch(showError);
            });
        }
        if (attachBtn && filesInput) {
            attachBtn.addEventListener('click', function () {
                filesInput.click();
            });
            filesInput.addEventListener('change', function () {
                const names = Array.from(filesInput.files || [])
                    .map(function (file) {
                        return file.name;
                    })
                    .join(', ');
                el('approval-chat-file-names').textContent = names;
            });
        }
        if (geometryBtn) {
            geometryBtn.addEventListener('click', function () {
                startGeometryDrawMode();
            });
        }
    }

    function showError(error) {
        window.alert((error && error.message) || 'Произошла ошибка.');
    }

    window.addEventListener('load', function () {
        state.config = mapApi().getConfig();
        if (!state.config || !state.config.apiUrls) {
            return;
        }
        bindUi();
        state.selectedApproveId = state.config.selectedApproveId || null;
        loadBootstrap(state.config.selectedApproveId).catch(showError);
    });
})();

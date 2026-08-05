(function () {
    'use strict';

    const state = {
        config: null,
        cases: [],
        activeCaseId: null,
        selectedApproveId: null,
        pendingMessageGeometries: [],
        activeMessageGeometryId: null,
        approveConfirmMode: null,
        replyToMessageId: null,
        replyToAuthor: '',
        chatPollTimer: null,
        chatPollInFlight: false,
        chatPollFingerprint: '',
        messageStatsCollapsed: false,
        eventTitleMode: 'numbers',
    };

    const CHAT_POLL_INTERVAL_MS = 2500;
    const EVENT_TITLE_MODE_STORAGE_KEY = 'approval.eventTitleMode';

    const REACTION_LABELS = {
        in_progress: 'В работе',
        done: 'Выполнено',
        accepted: 'Принято',
        rejected: 'Отклонено',
    };

    const INSPECTOR_REACTION_KINDS = ['in_progress', 'done'];
    const OWNER_VERDICT_KINDS = ['accepted', 'rejected'];

    function el(id) {
        return document.getElementById(id);
    }

    function mapApi() {
        return window.ApprovalMap || {};
    }

    function drawApi() {
        return window.ApprovalEventDraw || {};
    }

    function readStoredEventTitleMode() {
        try {
            const raw = window.localStorage.getItem(EVENT_TITLE_MODE_STORAGE_KEY);
            return raw === 'names' ? 'names' : 'numbers';
        } catch (error) {
            return 'numbers';
        }
    }

    function persistEventTitleMode(mode) {
        try {
            window.localStorage.setItem(
                EVENT_TITLE_MODE_STORAGE_KEY,
                mode === 'names' ? 'names' : 'numbers'
            );
        } catch (error) {
            /* ignore quota / private mode */
        }
    }

    function eventCardTitle(caseItem) {
        if (
            state.eventTitleMode === 'names' &&
            caseItem &&
            caseItem.title_named
        ) {
            return caseItem.title_named;
        }
        return (caseItem && caseItem.title) || '';
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

    function attachmentDownloadUrl(url) {
        if (!url) {
            return '';
        }
        return url + (url.indexOf('?') >= 0 ? '&' : '?') + 'download=1';
    }

    function openImageLightbox(src, alt) {
        const dialog = el('approval-chat-image-lightbox');
        const img = el('approval-chat-lightbox-img');
        if (!dialog || !img || !src) {
            return;
        }
        img.src = src;
        img.alt = alt || '';
        if (typeof dialog.showModal === 'function') {
            dialog.showModal();
        }
    }

    function closeImageLightbox() {
        const dialog = el('approval-chat-image-lightbox');
        const img = el('approval-chat-lightbox-img');
        if (dialog && typeof dialog.close === 'function' && dialog.open) {
            dialog.close();
        }
        if (img) {
            img.removeAttribute('src');
            img.alt = '';
        }
    }

    function renderAttachments(message) {
        if (!message.attachments || !message.attachments.length) {
            return '';
        }
        return message.attachments
            .map(function (attachment) {
                const isImage = (attachment.content_type || '').indexOf('image/') === 0;
                const name = escapeHtml(attachment.original_name);
                if (isImage) {
                    return (
                        '<button type="button" class="approval-chat-attachment approval-chat-attachment--image" ' +
                        'data-image-src="' +
                        escapeHtml(attachment.url) +
                        '" data-image-alt="' +
                        name +
                        '" title="Открыть изображение">' +
                        '<img src="' +
                        escapeHtml(attachment.url) +
                        '" alt="' +
                        name +
                        '">' +
                        '</button>'
                    );
                }
                return (
                    '<a class="approval-chat-attachment approval-chat-attachment--file" href="' +
                    escapeHtml(attachmentDownloadUrl(attachment.url)) +
                    '" download="' +
                    name +
                    '" title="Скачать файл">' +
                    name +
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
        if (mapApi().clearPendingGeometryHighlight) {
            mapApi().clearPendingGeometryHighlight();
        }
        const items = state.pendingMessageGeometries || [];
        if (!items.length) {
            hint.hidden = true;
            hint.innerHTML = '';
            return;
        }
        hint.hidden = false;
        const listHtml = items
            .map(function (_geom, index) {
                return (
                    '<li class="approval-chat-composer__geometry-hint-item" data-geometry-index="' +
                    index +
                    '">' +
                    'Объект ' +
                    (index + 1) +
                    ' ' +
                    '<button type="button" class="approval-chat-composer__geometry-hint-btn" data-geometry-action="remove-one" data-geometry-index="' +
                    index +
                    '">Убрать</button>' +
                    '</li>'
                );
            })
            .join('');
        hint.innerHTML =
            '<span>Добавлено объектов: ' +
            items.length +
            '.</span> ' +
            '<button type="button" class="approval-chat-composer__geometry-hint-btn" data-geometry-action="add">Добавить ещё</button> ' +
            '<button type="button" class="approval-chat-composer__geometry-hint-btn" data-geometry-action="remove-all">Убрать все</button>' +
            '<ul class="approval-chat-composer__geometry-hint-list">' +
            listHtml +
            '</ul>';
        hint.querySelectorAll('[data-geometry-action]').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.preventDefault();
                const action = button.getAttribute('data-geometry-action');
                if (action === 'add') {
                    startGeometryDrawMode({ append: true });
                } else if (action === 'remove-all') {
                    clearPendingMessageGeometry();
                } else if (action === 'remove-one') {
                    const index = Number(button.getAttribute('data-geometry-index'));
                    if (!Number.isNaN(index)) {
                        removePendingMessageGeometryAt(index);
                    }
                }
            });
        });
        hint.querySelectorAll('.approval-chat-composer__geometry-hint-item').forEach(function (item) {
            item.addEventListener('mouseenter', function () {
                const index = Number(item.getAttribute('data-geometry-index'));
                if (Number.isNaN(index) || !mapApi().highlightPendingGeometry) {
                    return;
                }
                mapApi().highlightPendingGeometry(index);
            });
            item.addEventListener('mouseleave', function () {
                if (mapApi().clearPendingGeometryHighlight) {
                    mapApi().clearPendingGeometryHighlight();
                }
            });
        });
    }

    function syncPendingGeometriesOnMap() {
        if (mapApi().setPendingMessageGeometries) {
            mapApi().setPendingMessageGeometries(state.pendingMessageGeometries.slice());
            return;
        }
        if (mapApi().clearPendingMessageGeometry) {
            mapApi().clearPendingMessageGeometry();
        }
        if (state.pendingMessageGeometries.length && mapApi().setPendingMessageGeometry) {
            mapApi().setPendingMessageGeometry(state.pendingMessageGeometries[0]);
        }
    }

    function setPendingMessageGeometries(geometries) {
        state.pendingMessageGeometries = Array.isArray(geometries) ? geometries.slice() : [];
        syncPendingGeometriesOnMap();
        updateGeometryHint();
    }

    function addPendingMessageGeometry(geometry) {
        if (!geometry) {
            return;
        }
        state.pendingMessageGeometries.push(geometry);
        syncPendingGeometriesOnMap();
        updateGeometryHint();
    }

    function removePendingMessageGeometryAt(index) {
        if (index < 0 || index >= state.pendingMessageGeometries.length) {
            return;
        }
        state.pendingMessageGeometries.splice(index, 1);
        syncPendingGeometriesOnMap();
        updateGeometryHint();
    }

    function clearPendingMessageGeometry(options) {
        const opts = options || {};
        state.pendingMessageGeometries = [];
        if (mapApi().clearPendingMessageGeometry) {
            mapApi().clearPendingMessageGeometry();
        }
        updateGeometryHint();
        if (opts.stopDraw !== false) {
            drawApi().stopDrawMode();
        }
    }

    function startGeometryDrawMode(options) {
        const opts = options || {};
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || caseItem.approved) {
            return;
        }
        if (!opts.append) {
            clearPendingMessageGeometry({ stopDraw: false });
        } else if (drawApi().stopDrawMode) {
            drawApi().stopDrawMode();
        }
        const startDraw = drawApi().startDrawMode || drawApi().startCreateMode;
        if (typeof startDraw !== 'function') {
            return;
        }
        startDraw(function (geometry) {
            addPendingMessageGeometry(geometry);
        });
    }

    function bindMessageGeometryClicks() {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        thread.querySelectorAll('.approval-chat-message--has-geometry').forEach(function (article) {
            article.addEventListener('click', function (event) {
                if (
                    event.target.closest('.approval-chat-message__reaction-btn') ||
                    event.target.closest('.approval-chat-message__reply-btn') ||
                    event.target.closest('.approval-chat-message__delete-btn') ||
                    event.target.closest('.approval-chat-attachment')
                ) {
                    return;
                }
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

    function renderReactionBadges(message) {
        if (!message.reactions || !message.reactions.length) {
            return '';
        }
        return (
            '<div class="approval-chat-message__reactions">' +
            message.reactions
                .map(function (reaction) {
                    const ownClass = reaction.is_own ? ' approval-chat-message__reaction-badge--own' : '';
                    const label = REACTION_LABELS[reaction.kind] || reaction.kind;
                    return (
                        '<span class="approval-chat-message__reaction-badge' +
                        ownClass +
                        '" data-reaction-kind="' +
                        escapeHtml(reaction.kind) +
                        '" title="' +
                        escapeHtml(reaction.author) +
                        '">' +
                        escapeHtml(label) +
                        ': ' +
                        escapeHtml(reaction.author) +
                        '</span>'
                    );
                })
                .join('') +
            '</div>'
        );
    }

    function messageHasDoneReaction(message) {
        return !!(message.reactions || []).some(function (reaction) {
            return reaction.kind === 'done';
        });
    }

    function renderReactionActionButtons(kinds, message) {
        const myReaction = message.my_reaction || '';
        return (
            '<div class="approval-chat-message__reaction-actions">' +
            kinds
                .map(function (kind) {
                    const activeClass = myReaction === kind ? ' is-active' : '';
                    return (
                        '<button type="button" class="approval-chat-message__reaction-btn' +
                        activeClass +
                        '" data-reaction-kind="' +
                        kind +
                        '" data-message-id="' +
                        escapeHtml(message.id) +
                        '">' +
                        escapeHtml(REACTION_LABELS[kind]) +
                        '</button>'
                    );
                })
                .join('') +
            '</div>'
        );
    }

    function renderReactionActions(message, caseClosed) {
        if (caseClosed) {
            return '';
        }
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem) {
            return '';
        }
        if (caseItem.current_user_is_inspector && !message.is_own && messageHasReplyTarget(message)) {
            return renderReactionActionButtons(INSPECTOR_REACTION_KINDS, message);
        }
        if (caseItem.current_user_is_owner && messageHasDoneReaction(message)) {
            return renderReactionActionButtons(OWNER_VERDICT_KINDS, message);
        }
        return '';
    }

    function bindMessageReactionClicks() {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        thread.querySelectorAll('.approval-chat-message__reaction-btn').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.stopPropagation();
                const messageId = button.dataset.messageId;
                const kind = button.dataset.reactionKind;
                if (!messageId || !kind) {
                    return;
                }
                setMessageReaction(messageId, kind).catch(showError);
            });
        });
    }

    function bindAttachmentClicks() {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        thread.querySelectorAll('.approval-chat-attachment--image').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.preventDefault();
                event.stopPropagation();
                openImageLightbox(button.dataset.imageSrc, button.dataset.imageAlt || '');
            });
        });
    }

    function messageGeometries(message) {
        if (message.geometries && message.geometries.length) {
            return message.geometries;
        }
        if (message.geometry) {
            return [{ id: message.geometry_id || null, geometry: message.geometry }];
        }
        return [];
    }

    function messageHasReplyTarget(message) {
        const hasAttachments = !!(message.attachments && message.attachments.length);
        return hasAttachments || messageGeometries(message).length > 0;
    }

    function renderReplyButton(message, caseClosed) {
        if (caseClosed || !messageHasReplyTarget(message)) {
            return '';
        }
        return (
            '<button type="button" class="approval-chat-message__reply-btn" data-message-id="' +
            escapeHtml(message.id) +
            '" data-message-author="' +
            escapeHtml(message.author) +
            '">Ответить</button>'
        );
    }

    function renderDeleteButton(message, caseClosed) {
        if (caseClosed || !message.can_delete) {
            return '';
        }
        return (
            '<button type="button" class="approval-chat-message__delete-btn" data-message-id="' +
            escapeHtml(message.id) +
            '">Удалить</button>'
        );
    }

    function renderServiceStrip(message) {
        const kind = message.kind || '';
        let toneClass = ' approval-chat-service--approved';
        if (kind === 'service_revoked') {
            toneClass = ' approval-chat-service--revoked';
        } else if (kind === 'service_closed') {
            toneClass = ' approval-chat-service--closed';
        } else if (kind === 'service_closed_overdue') {
            toneClass = ' approval-chat-service--closed-overdue';
        }
        return (
            '<div class="approval-chat-service' +
            toneClass +
            '" data-message-id="' +
            escapeHtml(message.id) +
            '">' +
            '<span class="approval-chat-service__text">' +
            escapeHtml(message.text || '') +
            '</span>' +
            '<time class="approval-chat-service__time">' +
            escapeHtml(message.time || '') +
            '</time>' +
            '</div>'
        );
    }

    function isServiceMessage(message) {
        return !!(message && (message.is_service || String(message.kind || '').indexOf('service_') === 0));
    }

    function renderMessageArticle(message, caseClosed, options) {
        if (isServiceMessage(message)) {
            return renderServiceStrip(message);
        }
        const opts = options || {};
        const geometries = messageGeometries(message);
        const ownClass = message.is_own ? ' approval-chat-message--own' : '';
        const replyClass = opts.isReply ? ' approval-chat-message--reply' : '';
        const geometryClass = geometries.length ? ' approval-chat-message--has-geometry' : '';
        const activeClass =
            state.activeMessageGeometryId &&
            String(message.id) === String(state.activeMessageGeometryId)
                ? ' approval-chat-message--geometry-active'
                : '';
        let geometryBadge = '';
        if (geometries.length === 1) {
            geometryBadge = '<p class="approval-chat-message__geometry-badge">Геометрия</p>';
        } else if (geometries.length > 1) {
            geometryBadge =
                '<p class="approval-chat-message__geometry-badge">Геометрия (' +
                geometries.length +
                ')</p>';
        }
        const replyMeta =
            opts.showReplyTo && message.reply_to_author
                ? '<p class="approval-chat-message__reply-to">в ответ на ' +
                  escapeHtml(message.reply_to_author) +
                  '</p>'
                : '';
        return (
            '<article class="approval-chat-message' +
            ownClass +
            replyClass +
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
            replyMeta +
            '<p class="approval-chat-message__text">' +
            escapeHtml(message.text) +
            '</p>' +
            geometryBadge +
            renderAttachments(message) +
            renderReactionBadges(message) +
            '<div class="approval-chat-message__footer">' +
            renderReactionActions(message, caseClosed) +
            renderReplyButton(message, caseClosed) +
            renderDeleteButton(message, caseClosed) +
            '</div>' +
            '</article>'
        );
    }

    function buildMessageThreadGroups(messages) {
        const byId = {};
        const children = {};
        (messages || []).forEach(function (message) {
            byId[message.id] = message;
            children[message.id] = [];
        });
        const roots = [];
        (messages || []).forEach(function (message) {
            const parentId = message.parent_id;
            if (parentId != null && byId[parentId]) {
                children[parentId].push(message);
            } else {
                roots.push(message);
            }
        });

        function collectDescendants(rootId) {
            const result = [];
            const queue = (children[rootId] || []).slice();
            while (queue.length) {
                const current = queue.shift();
                result.push(current);
                const nested = children[current.id] || [];
                for (let i = 0; i < nested.length; i += 1) {
                    queue.push(nested[i]);
                }
            }
            result.sort(function (a, b) {
                return Number(a.id) - Number(b.id);
            });
            return result;
        }

        return {
            byId: byId,
            groups: roots.map(function (root) {
                return { root: root, replies: collectDescendants(root.id) };
            }),
        };
    }

    function updateReplyBanner() {
        const banner = el('approval-chat-reply-banner');
        if (!banner) {
            return;
        }
        if (!state.replyToMessageId) {
            banner.hidden = true;
            banner.innerHTML = '';
            return;
        }
        banner.hidden = false;
        banner.innerHTML =
            '<span class="approval-chat-composer__reply-text">Ответ на сообщение от ' +
            escapeHtml(state.replyToAuthor || 'участника') +
            '</span> ' +
            '<button type="button" class="approval-chat-composer__reply-cancel" id="approval-chat-reply-cancel">Отмена</button>';
        const cancelBtn = el('approval-chat-reply-cancel');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', function (event) {
                event.preventDefault();
                clearReplyTarget();
            });
        }
    }

    function setReplyTarget(messageId, author) {
        state.replyToMessageId = messageId;
        state.replyToAuthor = author || '';
        updateReplyBanner();
        const input = el('approval-chat-input');
        if (input) {
            input.focus();
        }
    }

    function clearReplyTarget() {
        state.replyToMessageId = null;
        state.replyToAuthor = '';
        updateReplyBanner();
    }

    function bindMessageReplyClicks() {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        thread.querySelectorAll('.approval-chat-message__reply-btn').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.preventDefault();
                event.stopPropagation();
                setReplyTarget(button.dataset.messageId, button.dataset.messageAuthor);
            });
        });
    }

    function bindMessageDeleteClicks() {
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        thread.querySelectorAll('.approval-chat-message__delete-btn').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.preventDefault();
                event.stopPropagation();
                const messageId = button.dataset.messageId;
                if (!messageId) {
                    return;
                }
                deleteMessage(messageId).catch(showError);
            });
        });
    }

    function renderChatMessages(messages, options) {
        const opts = options || {};
        const thread = el('approval-chat-thread');
        if (!thread) {
            return;
        }
        if (!messages || !messages.length) {
            thread.innerHTML = '<p class="approval-events__empty">Сообщений пока нет.</p>';
            return;
        }
        const caseItem = findCase(state.activeCaseId);
        const caseClosed = !!(caseItem && caseItem.approved);
        const threaded = buildMessageThreadGroups(messages);
        thread.innerHTML = threaded.groups
            .map(function (group) {
                const repliesHtml = group.replies.length
                    ? '<div class="approval-chat-message__replies">' +
                      group.replies
                          .map(function (reply) {
                              const parent = threaded.byId[reply.parent_id];
                              const showReplyTo = !!(parent && parent.parent_id);
                              return renderMessageArticle(reply, caseClosed, {
                                  isReply: true,
                                  showReplyTo: showReplyTo,
                              });
                          })
                          .join('') +
                      '</div>'
                    : '';
                return (
                    '<div class="approval-chat-thread-item">' +
                    renderMessageArticle(group.root, caseClosed, { isReply: false }) +
                    repliesHtml +
                    '</div>'
                );
            })
            .join('');
        bindMessageGeometryClicks();
        bindMessageReactionClicks();
        bindMessageReplyClicks();
        bindMessageDeleteClicks();
        bindAttachmentClicks();
        if (opts.autoScroll !== false) {
            thread.scrollTop = thread.scrollHeight;
        }
    }

    function formatParticipants(caseItem) {
        if (!caseItem || !caseItem.participants || !caseItem.participants.length) {
            return '';
        }
        return caseItem.participants
            .map(function (participant) {
                if (participant.kind === 'inspector') {
                    return 'инспектор: ' + participant.login;
                }
                if (participant.kind === 'login') {
                    return 'участник: ' + participant.login;
                }
                return 'владелец: ' + participant.id;
            })
            .join(', ');
    }

    function renderParticipants(caseItem) {
        const container = el('approval-active-participants');
        if (!container) {
            return;
        }
        const text = formatParticipants(caseItem);
        if (!text) {
            container.hidden = true;
            container.innerHTML = '';
            return;
        }
        container.hidden = false;
        container.innerHTML =
            '<span class="approval-events__participants-label">Участники:</span> ' + escapeHtml(text);
    }

    function userHasApproved(caseItem) {
        if (!caseItem) {
            return false;
        }
        if (typeof caseItem.current_user_approved === 'boolean') {
            return caseItem.current_user_approved;
        }
        return !!caseItem.current_owner_approved;
    }

    function setApproveConfirmMode(mode) {
        state.approveConfirmMode = mode || null;
    }

    function closeApproveConfirmDialog() {
        const dialog = el('approval-chat-confirm-dialog');
        if (dialog && typeof dialog.close === 'function' && dialog.open) {
            dialog.close();
        }
        setApproveConfirmMode(null);
    }

    function openApproveConfirmDialog(mode) {
        const dialog = el('approval-chat-confirm-dialog');
        const title = el('approval-chat-confirm-title');
        const text = el('approval-chat-confirm-text');
        const submit = el('approval-chat-confirm-submit');
        if (!dialog || !title || !text || !submit) {
            return;
        }
        setApproveConfirmMode(mode);
        if (mode === 'revoke') {
            title.textContent = 'Отмена согласования';
            text.textContent = 'Отменить ваше согласование по этому событию?';
            submit.textContent = 'Отменить согласование';
            submit.classList.add('approval-event-dialog__submit--danger');
        } else {
            title.textContent = 'Подтверждение согласования';
            text.textContent = 'Вы уверены, что хотите согласовать это событие?';
            submit.textContent = 'Подтвердить';
            submit.classList.remove('approval-event-dialog__submit--danger');
        }
        if (typeof dialog.showModal === 'function') {
            dialog.showModal();
        }
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
        const approvedByUser = userHasApproved(caseItem);

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
            if (!caseItem) {
                approveBtn.disabled = true;
                approveBtn.textContent = 'Согласовать';
                approveBtn.classList.remove('approval-chat-composer__approve--revoke');
            } else if (approvedByUser) {
                approveBtn.disabled = false;
                approveBtn.textContent = 'Отменить согласование';
                approveBtn.classList.add('approval-chat-composer__approve--revoke');
            } else {
                approveBtn.disabled = closed;
                approveBtn.textContent = 'Согласовать';
                approveBtn.classList.remove('approval-chat-composer__approve--revoke');
            }
        }

        if (closedBanner) {
            closedBanner.hidden = !closed;
        }
        if (progress && caseItem) {
            progress.hidden = false;
            let progressText =
                'Согласование: ' + caseItem.approvals_done + ' / ' + caseItem.approvals_total;
            if (caseItem.inspector_required && !caseItem.inspector_approved) {
                progressText += ' (ожидается подпись инспектора)';
            }
            progress.textContent = progressText;
        } else if (progress) {
            progress.hidden = true;
            progress.textContent = '';
        }
        renderMessageStats(caseItem);
    }

    function renderMessageStats(caseItem) {
        const root = el('approval-message-stats');
        const list = el('approval-message-stats-list');
        const toggle = el('approval-message-stats-toggle');
        if (!root || !list) {
            return;
        }
        if (!caseItem || !caseItem.current_user_is_inspector) {
            root.hidden = true;
            list.innerHTML = '';
            return;
        }
        const stats = caseItem.message_reaction_stats || {};
        const rows = [
            { key: 'unprocessed', label: 'Необработанных сообщений' },
            { key: 'in_progress', label: 'Сообщений в работе' },
            { key: 'done', label: 'Сообщений выполнено' },
            { key: 'accepted', label: 'Принято' },
            { key: 'rejected', label: 'Отклонено' },
        ];
        list.innerHTML = rows
            .map(function (row) {
                const count = Number(stats[row.key] || 0);
                return (
                    '<li class="approval-events__message-stats-item">' +
                    '<span class="approval-events__message-stats-label">' +
                    escapeHtml(row.label) +
                    '</span>' +
                    '<span class="approval-events__message-stats-count">' +
                    escapeHtml(String(count)) +
                    '</span>' +
                    '</li>'
                );
            })
            .join('');
        root.hidden = false;
        root.classList.toggle('is-collapsed', !!state.messageStatsCollapsed);
        if (toggle) {
            toggle.setAttribute('aria-expanded', state.messageStatsCollapsed ? 'false' : 'true');
            toggle.title = state.messageStatsCollapsed
                ? 'Развернуть статистику сообщений'
                : 'Свернуть статистику сообщений';
        }
    }

    function renderActiveCase(caseItem, options) {
        const infoBtn = el('approval-active-info-btn');
        const infoDialog = el('approval-active-info-dialog');
        if (!caseItem) {
            stopChatPolling();
            state.chatPollFingerprint = '';
            el('approval-active-title').textContent = '';
            const subtitle = el('approval-active-subtitle');
            if (subtitle) {
                subtitle.hidden = true;
                subtitle.textContent = '';
            }
            renderParticipants(null);
            el('approval-active-status').textContent = '';
            closeApproveConfirmDialog();
            renderChatMessages([]);
            updateComposerState(null);
            mapApi().highlightCase(null);
            mapApi().renderGeometries(null);
            mapApi().updateAdjacentLayers('');
            clearPendingMessageGeometry();
            clearReplyTarget();
            if (infoBtn) {
                infoBtn.disabled = true;
            }
            if (infoDialog && typeof infoDialog.close === 'function' && infoDialog.open) {
                infoDialog.close();
            }
            return;
        }

        const previousCaseId = state.activeCaseId;
        state.activeCaseId = caseItem.id;
        if (previousCaseId && previousCaseId !== caseItem.id) {
            clearPendingMessageGeometry();
            clearReplyTarget();
            closeApproveConfirmDialog();
        }
        state.activeMessageGeometryId = null;
        el('approval-active-title').textContent = caseItem.title;
        const subtitleEl = el('approval-active-subtitle');
        if (subtitleEl) {
            if (caseItem.n_root) {
                subtitleEl.hidden = false;
                subtitleEl.textContent = 'Паспорт ' + caseItem.n_root;
            } else if (caseItem.is_primary) {
                subtitleEl.hidden = false;
                subtitleEl.textContent = 'Основной чат по объекту съёмки';
            } else {
                subtitleEl.hidden = true;
                subtitleEl.textContent = '';
            }
        }
        renderParticipants(caseItem);
        const statusEl = el('approval-active-status');
        statusEl.textContent = caseItem.status;
        statusEl.className =
            'approval-events__status approval-events__status--' + (caseItem.status_class || 'active');

        mapApi().highlightCase(caseItem.id);
        mapApi().updateAdjacentLayers(caseItem.is_primary ? '' : (caseItem.n_root || ''));
        mapApi().renderGeometries(caseItem);
        const fitMap = !options || options.fitMap !== false;
        if (fitMap) {
            mapApi().fitCaseGeometry(caseItem.id);
        }
        if (infoBtn) {
            infoBtn.disabled = false;
        }
        updateComposerState(caseItem);
    }

    function buildEventCardHtml(caseItem, options) {
        const opts = options || {};
        const title = opts.titleOverride || eventCardTitle(caseItem);
        const extraClass = opts.extraClass || '';
        const active = caseItem.id === state.activeCaseId ? ' is-active' : '';
        const closedClass =
            caseItem.approved || caseItem.status_class === 'closed'
                ? ' approval-event-card--closed'
                : '';
        const overdueClass =
            caseItem.status_class === 'overdue' ? ' approval-event-card--overdue' : '';
        const addParticipantHtml = caseItem.can_manage_participants
            ? '<button type="button" class="approval-event-card__add-participant" data-case-id="' +
              caseItem.id +
              '">Добавить участника</button>'
            : '';
        const deleteHtml = caseItem.can_delete
            ? '<button type="button" class="approval-event-card__delete" data-case-id="' +
              caseItem.id +
              '" title="Удалить событие">Удалить</button>'
            : '';
        const startDate = caseItem.created_at_date || '';
        const startDateHtml = startDate
            ? '<p class="approval-event-card__meta">Дата начала: ' +
              escapeHtml(startDate) +
              '</p>'
            : '';
        return (
            '<div class="approval-event-card' +
            extraClass +
            closedClass +
            overdueClass +
            active +
            '" data-case-id="' +
            escapeHtml(caseItem.id) +
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
            startDateHtml +
            '<div class="approval-event-card__footer">' +
            '<span class="approval-event-card__count">' +
            caseItem.messages_count +
            ' сообщ.</span>' +
            '<span class="approval-event-card__progress">Согласовано: ' +
            caseItem.approvals_done +
            ' / ' +
            caseItem.approvals_total +
            '</span>' +
            addParticipantHtml +
            deleteHtml +
            '</div>' +
            '</div>'
        );
    }

    function setSecondaryChatsCollapsed(collapsed) {
        const section = document.querySelector('.approval-events__section--secondary');
        const toggle = el('approval-events-list-toggle');
        if (!section || !toggle) {
            return;
        }
        section.classList.toggle('is-collapsed', !!collapsed);
        toggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
        toggle.title = collapsed
            ? 'Развернуть процесс согласования границ'
            : 'Свернуть процесс согласования границ';
    }

    function bindEventCardClicks(root) {
        if (!root) {
            return;
        }
        root.querySelectorAll('.approval-event-card__add-participant').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.stopPropagation();
                openAddParticipantDialog(button.dataset.caseId);
            });
        });
        root.querySelectorAll('.approval-event-card__delete').forEach(function (button) {
            button.addEventListener('click', function (event) {
                event.stopPropagation();
                deleteCase(button.dataset.caseId).catch(showError);
            });
        });
        root.querySelectorAll('.approval-event-card').forEach(function (card) {
            card.addEventListener('click', async function (event) {
                if (
                    event.target.closest('.approval-event-card__add-participant') ||
                    event.target.closest('.approval-event-card__delete')
                ) {
                    return;
                }
                const caseId = card.dataset.caseId;
                if (caseId) {
                    await openCase(caseId, { fitMap: false });
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

    function renderEventsProgress() {
        const progress = el('approval-events-progress');
        if (!progress) {
            return;
        }
        const cases = state.cases || [];
        const total = cases.length;
        const done = cases.filter(function (caseItem) {
            return !!caseItem.approved;
        }).length;
        progress.textContent = 'Согласовано: ' + done + ' / ' + total;
    }

    function renderEventNav(split) {
        renderPrimaryEventCard(split.primary);
        renderSecondaryList(split.secondary);
        renderEventsProgress();
    }

    function findCase(caseId) {
        return state.cases.find(function (item) {
            return item.id === caseId;
        });
    }

    function caseChatFingerprint(caseItem) {
        if (!caseItem) {
            return '';
        }
        const messages = caseItem.messages || [];
        const messagesPart = messages
            .map(function (message) {
                const attachmentsCount =
                    message.attachments && message.attachments.length ? message.attachments.length : 0;
                const geometriesCount = messageGeometries(message).length;
                const reactionsPart = (message.reactions || [])
                    .map(function (reaction) {
                        return (reaction.kind || '') + ':' + (reaction.author || '');
                    })
                    .join(',');
                return [
                    message.id,
                    message.my_reaction || '',
                    attachmentsCount,
                    geometriesCount,
                    message.parent_id || '',
                    reactionsPart,
                ].join('|');
            })
            .join(';');
        return [
            caseItem.id,
            caseItem.approved ? '1' : '0',
            caseItem.status || '',
            caseItem.approvals_done || 0,
            caseItem.approvals_total || 0,
            caseItem.messages_count || messages.length,
            caseItem.preview || '',
            messagesPart,
        ].join('#');
    }

    function isChatThreadNearBottom(thread) {
        if (!thread) {
            return true;
        }
        return thread.scrollHeight - thread.scrollTop - thread.clientHeight < 48;
    }

    function stopChatPolling() {
        if (state.chatPollTimer) {
            clearInterval(state.chatPollTimer);
            state.chatPollTimer = null;
        }
    }

    function startChatPolling() {
        stopChatPolling();
        if (!state.activeCaseId) {
            return;
        }
        state.chatPollTimer = setInterval(function () {
            softRefreshActiveCase().catch(function () {
                /* ignore transient poll errors */
            });
        }, CHAT_POLL_INTERVAL_MS);
    }

    function applySoftCaseDetail(caseItem) {
        const index = state.cases.findIndex(function (item) {
            return item.id === caseItem.id;
        });
        if (index >= 0) {
            const prev = state.cases[index];
            state.cases[index] = Object.assign({}, prev, caseItem, {
                geometry: caseItem.geometry != null ? caseItem.geometry : prev && prev.geometry,
            });
        } else {
            state.cases.push(caseItem);
        }

        const preservedGeomId = state.activeMessageGeometryId;
        const thread = el('approval-chat-thread');
        const nearBottom = isChatThreadNearBottom(thread);
        const prevScrollTop = thread ? thread.scrollTop : 0;

        el('approval-active-title').textContent = caseItem.title;
        const subtitleEl = el('approval-active-subtitle');
        if (subtitleEl) {
            if (caseItem.n_root) {
                subtitleEl.hidden = false;
                subtitleEl.textContent = 'Паспорт ' + caseItem.n_root;
            } else if (caseItem.is_primary) {
                subtitleEl.hidden = false;
                subtitleEl.textContent = 'Основной чат по объекту съёмки';
            } else {
                subtitleEl.hidden = true;
                subtitleEl.textContent = '';
            }
        }
        renderParticipants(caseItem);
        const statusEl = el('approval-active-status');
        if (statusEl) {
            statusEl.textContent = caseItem.status;
            statusEl.className =
                'approval-events__status approval-events__status--' + (caseItem.status_class || 'active');
        }
        updateComposerState(caseItem);

        state.activeMessageGeometryId = preservedGeomId;
        renderChatMessages(caseItem.messages || [], { autoScroll: nearBottom });
        if (!nearBottom && thread) {
            thread.scrollTop = prevScrollTop;
        }

        if (mapApi().highlightCase) {
            mapApi().highlightCase(caseItem.id);
        }
        if (mapApi().updateAdjacentLayers) {
            mapApi().updateAdjacentLayers(caseItem.is_primary ? '' : caseItem.n_root || '');
        }
        if (mapApi().renderGeometries) {
            mapApi().renderGeometries(caseItem);
        }

        renderEventNav(splitCases(state.cases));
    }

    async function softRefreshActiveCase() {
        if (!state.activeCaseId || document.hidden || state.chatPollInFlight || !state.config) {
            return;
        }
        state.chatPollInFlight = true;
        try {
            const data = await fetchJson(
                mapApi().apiUrl(state.config.apiUrls.caseDetail, { caseId: state.activeCaseId })
            );
            const caseItem = data.case;
            if (!caseItem || String(caseItem.id) !== String(state.activeCaseId)) {
                return;
            }
            const fingerprint = caseChatFingerprint(caseItem);
            if (fingerprint === state.chatPollFingerprint) {
                return;
            }
            state.chatPollFingerprint = fingerprint;
            applySoftCaseDetail(caseItem);
        } finally {
            state.chatPollInFlight = false;
        }
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
        state.chatPollFingerprint = caseChatFingerprint(caseItem);
        startChatPolling();
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

        const requestedCaseId =
            state.activeCaseId ||
            (state.config && state.config.initialCaseId) ||
            null;
        let defaultCaseId = null;
        if (requestedCaseId) {
            const requested = state.cases.find(function (item) {
                return String(item.id) === String(requestedCaseId);
            });
            if (requested) {
                defaultCaseId = requested.id;
            }
        }
        if (!defaultCaseId) {
            defaultCaseId = data.primary_case_id || (split.primary && split.primary.id);
        }
        if (state.config) {
            state.config.initialCaseId = null;
        }
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
        const pendingGeometries = state.pendingMessageGeometries || [];
        if (!body && !files.length && !pendingGeometries.length) {
            return;
        }

        const formData = new FormData();
        formData.append('body', body);
        files.forEach(function (file) {
            formData.append('files', file);
        });
        if (pendingGeometries.length) {
            formData.append('geometries', JSON.stringify(pendingGeometries));
        }
        if (state.replyToMessageId) {
            formData.append('parent_id', String(state.replyToMessageId));
        }

        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.postMessage, { caseId: state.activeCaseId }),
            { method: 'POST', body: formData }
        );

        if (input) {
            input.value = '';
            resizeChatInput();
        }
        if (filesInput) {
            filesInput.value = '';
        }
        el('approval-chat-file-names').textContent = '';
        clearPendingMessageGeometry();
        clearReplyTarget();

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
        if (!caseItem || caseItem.approved || userHasApproved(caseItem)) {
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
        closeApproveConfirmDialog();
        await openCase(state.activeCaseId, { fitMap: false });
    }

    async function revokeCase() {
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || !userHasApproved(caseItem)) {
            return;
        }
        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.revokeCase, { caseId: state.activeCaseId }),
            { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' }
        );
        const index = state.cases.findIndex(function (item) {
            return item.id === state.activeCaseId;
        });
        if (index >= 0) {
            state.cases[index] = Object.assign({}, state.cases[index], data.case);
        }
        closeApproveConfirmDialog();
        await openCase(state.activeCaseId, { fitMap: false });
    }

    async function setMessageReaction(messageId, kind) {
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || caseItem.approved) {
            return;
        }
        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.messageReaction, { messageId: messageId }),
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ kind: kind }),
            }
        );
        await openCase(state.activeCaseId, { fitMap: false });
        return data;
    }

    async function deleteMessage(messageId) {
        const caseItem = findCase(state.activeCaseId);
        if (!caseItem || caseItem.approved) {
            return;
        }
        if (!window.confirm('Удалить это сообщение?')) {
            return;
        }
        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.deleteMessage, { messageId: messageId }),
            { method: 'DELETE' }
        );
        const index = state.cases.findIndex(function (item) {
            return item.id === state.activeCaseId;
        });
        if (index >= 0 && data.case) {
            state.cases[index] = Object.assign({}, state.cases[index], data.case);
        }
        await openCase(state.activeCaseId, { fitMap: false });
        return data;
    }

    async function deleteCase(caseId) {
        const caseItem = findCase(caseId);
        if (!caseItem || !caseItem.can_delete) {
            return;
        }
        if (!window.confirm('Удалить это событие? Действие необратимо.')) {
            return;
        }
        const deletedId = String(caseId);
        const data = await fetchJson(
            mapApi().apiUrl(state.config.apiUrls.deleteCase || state.config.apiUrls.caseDetail, {
                caseId: caseId,
            }),
            { method: 'DELETE' }
        );
        state.cases = (state.cases || []).filter(function (item) {
            return String(item.id) !== deletedId;
        });
        renderEventNav(splitCases(state.cases));
        if (String(state.activeCaseId) === deletedId) {
            const nextId = data.primary_case_id || (state.cases[0] && state.cases[0].id);
            if (nextId) {
                await openCase(nextId, { fitMap: false });
            } else {
                state.activeCaseId = null;
                renderActiveCase(null);
            }
        }
        return data;
    }

    function resizeChatInput() {
        const input = el('approval-chat-input');
        if (!input) {
            return;
        }
        input.style.height = 'auto';
        input.style.height = input.scrollHeight + 'px';
    }

    function initEventsListToggle() {
        const section = document.querySelector('.approval-events__section--secondary');
        const toggle = el('approval-events-list-toggle');
        if (!section || !toggle) {
            return;
        }

        toggle.addEventListener('click', function () {
            setSecondaryChatsCollapsed(!section.classList.contains('is-collapsed'));
        });
    }

    function syncEventTitleModeSwitch() {
        const input = el('approval-event-title-mode');
        if (!input) {
            return;
        }
        input.checked = state.eventTitleMode === 'names';
    }

    function initEventTitleModeSwitch() {
        const input = el('approval-event-title-mode');
        if (!input) {
            return;
        }
        state.eventTitleMode = readStoredEventTitleMode();
        syncEventTitleModeSwitch();
        input.addEventListener('change', function () {
            state.eventTitleMode = input.checked ? 'names' : 'numbers';
            persistEventTitleMode(state.eventTitleMode);
            renderEventNav(splitCases(state.cases));
        });
    }

    function initMessageStatsToggle() {
        const root = el('approval-message-stats');
        const toggle = el('approval-message-stats-toggle');
        if (!root || !toggle) {
            return;
        }
        toggle.addEventListener('click', function () {
            state.messageStatsCollapsed = !state.messageStatsCollapsed;
            root.classList.toggle('is-collapsed', state.messageStatsCollapsed);
            toggle.setAttribute('aria-expanded', state.messageStatsCollapsed ? 'false' : 'true');
            toggle.title = state.messageStatsCollapsed
                ? 'Развернуть статистику сообщений'
                : 'Свернуть статистику сообщений';
        });
    }

    function initActiveInfoDialog() {
        const trigger = el('approval-active-info-btn');
        const dialog = el('approval-active-info-dialog');
        const closeBtn = el('approval-active-info-close');
        if (!trigger || !dialog) {
            return;
        }
        trigger.disabled = true;
        trigger.addEventListener('click', function () {
            if (!state.activeCaseId || typeof dialog.showModal !== 'function') {
                return;
            }
            dialog.showModal();
        });
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                if (typeof dialog.close === 'function') {
                    dialog.close();
                }
            });
        }
        dialog.addEventListener('click', function (event) {
            if (event.target === dialog && typeof dialog.close === 'function') {
                dialog.close();
            }
        });
    }

    function currentUserIsInspectorForSelected() {
        const config = state.config || {};
        const currentUser = (config.currentUser || '').trim();
        if (!currentUser) {
            return false;
        }
        const selectedId = state.selectedApproveId || config.selectedApproveId;
        const approves = config.approves || [];
        for (let i = 0; i < approves.length; i += 1) {
            const item = approves[i];
            if (String(item.id) === String(selectedId) && item.can_delete) {
                return true;
            }
        }
        return false;
    }

    function setDialogError(errorEl, message) {
        if (!errorEl) {
            return;
        }
        if (!message) {
            errorEl.hidden = true;
            errorEl.textContent = '';
            return;
        }
        errorEl.hidden = false;
        errorEl.textContent = message;
    }

    async function openCreateEventFromAdjacent(opts) {
        if (drawApi().isDrawMode && drawApi().isDrawMode()) {
            return;
        }
        const options = opts || {};
        const rootId = String(options.rootId || '').trim();
        const ownerId = String(options.ownerId || '').trim();
        const name = String(options.name || '').trim();
        const geometry = options.geometry || null;
        if (!currentUserIsInspectorForSelected()) {
            window.alert('Создавать события может только инспектор.');
            return;
        }
        if (!state.selectedApproveId) {
            window.alert('Выберите согласование.');
            return;
        }
        if (!rootId) {
            window.alert('У объекта нет RootId.');
            return;
        }
        if (!ownerId) {
            window.alert('У смежного объекта нет OwnerLegalPersonId.');
            return;
        }
        if (!geometry) {
            window.alert('У объекта нет геометрии.');
            return;
        }
        const titleHint = name || ('Паспорт ' + rootId);
        const confirmed = window.confirm(
            'Создать событие для смежного объекта?\n\n' + titleHint + '\nRootId: ' + rootId
        );
        if (!confirmed) {
            return;
        }
        try {
            await fetchJson(
                mapApi().apiUrl(state.config.apiUrls.createAdjacentEvent, {
                    approveId: state.selectedApproveId,
                }),
                {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        n_root: rootId,
                        geometry: geometry,
                        title: name || undefined,
                        owner: ownerId,
                    }),
                }
            );
            await loadBootstrap();
        } catch (error) {
            window.alert((error && error.message) || 'Не удалось создать событие.');
        }
    }

    let addParticipantCaseId = null;

    function syncAddParticipantValueLabel() {
        const kindSelect = el('approval-add-participant-kind');
        const label = el('approval-add-participant-value-label');
        if (!kindSelect || !label) {
            return;
        }
        label.textContent = kindSelect.value === 'login' ? 'Login' : 'OwnerLegalPersonId';
    }

    function openAddParticipantDialog(caseId) {
        const dialog = el('approval-add-participant-dialog');
        const kindSelect = el('approval-add-participant-kind');
        const valueInput = el('approval-add-participant-value');
        const errorEl = el('approval-add-participant-error');
        const caseItem = findCase(caseId);
        if (!dialog || !caseItem || !caseItem.can_manage_participants) {
            return;
        }
        addParticipantCaseId = caseId;
        if (kindSelect) {
            kindSelect.value = 'owner';
        }
        if (valueInput) {
            valueInput.value = '';
        }
        syncAddParticipantValueLabel();
        setDialogError(errorEl, '');
        if (typeof dialog.showModal === 'function') {
            dialog.showModal();
        }
    }

    async function submitAddParticipant() {
        const kindSelect = el('approval-add-participant-kind');
        const valueInput = el('approval-add-participant-value');
        const errorEl = el('approval-add-participant-error');
        const dialog = el('approval-add-participant-dialog');
        const caseId = addParticipantCaseId;
        const kind = kindSelect && kindSelect.value;
        const value = valueInput && valueInput.value.trim();
        if (!caseId || !kind || !value) {
            setDialogError(errorEl, 'Заполните все поля.');
            return;
        }
        try {
            const data = await fetchJson(
                mapApi().apiUrl(state.config.apiUrls.addCaseParticipant, { caseId: caseId }),
                {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ kind: kind, value: value }),
                }
            );
            const index = state.cases.findIndex(function (item) {
                return item.id === caseId;
            });
            if (index >= 0) {
                state.cases[index] = Object.assign({}, state.cases[index], data.case);
            }
            addParticipantCaseId = null;
            if (dialog && typeof dialog.close === 'function') {
                dialog.close();
            }
            await openCase(state.activeCaseId || caseId, { fitMap: false });
        } catch (error) {
            setDialogError(errorEl, (error && error.message) || 'Не удалось добавить участника.');
        }
    }

    function bindParticipantDialogs() {
        const kindSelect = el('approval-add-participant-kind');
        if (kindSelect) {
            kindSelect.addEventListener('change', syncAddParticipantValueLabel);
        }
        const addForm = el('approval-add-participant-form');
        if (addForm) {
            addForm.addEventListener('submit', function (event) {
                const submitter = event.submitter;
                const value = submitter && submitter.value ? submitter.value : 'cancel';
                if (value !== 'confirm') {
                    addParticipantCaseId = null;
                    return;
                }
                event.preventDefault();
                submitAddParticipant();
            });
        }
    }

    function bindUi() {
        const sendBtn = el('approval-chat-send-btn');
        const approveBtn = el('approval-chat-approve-btn');
        const confirmDialog = el('approval-chat-confirm-dialog');
        const confirmForm = el('approval-chat-confirm-form');
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
            chatInput.addEventListener('input', resizeChatInput);
            chatInput.addEventListener('keydown', function (event) {
                if (event.key !== 'Enter' || event.shiftKey) {
                    return;
                }
                event.preventDefault();
                sendMessage().catch(showError);
            });
            resizeChatInput();
        }
        initEventsListToggle();
        initEventTitleModeSwitch();
        initMessageStatsToggle();
        initActiveInfoDialog();
        bindParticipantDialogs();
        if (approveBtn) {
            approveBtn.addEventListener('click', function () {
                const caseItem = findCase(state.activeCaseId);
                if (!caseItem) {
                    return;
                }
                if (userHasApproved(caseItem)) {
                    openApproveConfirmDialog('revoke');
                } else if (!caseItem.approved) {
                    openApproveConfirmDialog('approve');
                }
            });
        }
        if (confirmForm) {
            confirmForm.addEventListener('submit', function (event) {
                const submitter = event.submitter;
                const value = submitter && submitter.value ? submitter.value : 'cancel';
                if (value !== 'confirm') {
                    setApproveConfirmMode(null);
                    return;
                }
                event.preventDefault();
                const mode = state.approveConfirmMode;
                if (mode === 'revoke') {
                    revokeCase().catch(showError);
                } else if (mode === 'approve') {
                    approveCase().catch(showError);
                } else {
                    closeApproveConfirmDialog();
                }
            });
        }
        if (confirmDialog) {
            confirmDialog.addEventListener('close', function () {
                setApproveConfirmMode(null);
            });
        }
        const lightbox = el('approval-chat-image-lightbox');
        const lightboxClose = el('approval-chat-lightbox-close');
        if (lightboxClose) {
            lightboxClose.addEventListener('click', function () {
                closeImageLightbox();
            });
        }
        if (lightbox) {
            lightbox.addEventListener('click', function (event) {
                if (event.target === lightbox) {
                    closeImageLightbox();
                }
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
                const hasPending =
                    state.pendingMessageGeometries &&
                    state.pendingMessageGeometries.length > 0;
                startGeometryDrawMode({ append: hasPending });
            });
        }

        document.addEventListener('visibilitychange', function () {
            if (document.hidden) {
                stopChatPolling();
                return;
            }
            if (!state.activeCaseId) {
                return;
            }
            softRefreshActiveCase().catch(function () {
                /* ignore transient poll errors */
            });
            startChatPolling();
        });
    }

    function showError(error) {
        window.alert((error && error.message) || 'Произошла ошибка.');
    }

    window.ApprovalEvents = {
        openCreateEventFromAdjacent: openCreateEventFromAdjacent,
        openAddParticipantDialog: openAddParticipantDialog,
    };

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

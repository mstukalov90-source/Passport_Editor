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
    };

    const REACTION_LABELS = {
        in_progress: 'В работе',
        done: 'Выполнено',
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
                    '<li class="approval-chat-composer__geometry-hint-item">' +
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
                    event.target.closest('.approval-chat-message__reply-btn')
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

    function renderReactionActions(message, caseClosed) {
        if (message.is_own || caseClosed) {
            return '';
        }
        const myReaction = message.my_reaction || '';
        return (
            '<div class="approval-chat-message__reaction-actions">' +
            Object.keys(REACTION_LABELS)
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

    function messageGeometries(message) {
        if (message.geometries && message.geometries.length) {
            return message.geometries;
        }
        if (message.geometry) {
            return [{ id: message.geometry_id || null, geometry: message.geometry }];
        }
        return [];
    }

    function renderReplyButton(message, caseClosed) {
        if (caseClosed) {
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

    function renderMessageArticle(message, caseClosed, options) {
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

    function renderChatMessages(messages) {
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
        thread.scrollTop = thread.scrollHeight;
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
        }
    }

    function renderActiveCase(caseItem, options) {
        if (!caseItem) {
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
        updateComposerState(caseItem);
    }

    function buildEventCardHtml(caseItem, options) {
        const opts = options || {};
        const title = opts.titleOverride || caseItem.title;
        const extraClass = opts.extraClass || '';
        const active = caseItem.id === state.activeCaseId ? ' is-active' : '';
        const nRootHtml = caseItem.n_root
            ? '<p class="approval-event-card__n-root">Паспорт ' + escapeHtml(caseItem.n_root) + '</p>'
            : '';
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
            nRootHtml +
            '<p class="approval-event-card__preview">' +
            escapeHtml(caseItem.preview || '') +
            '</p>' +
            '<div class="approval-event-card__footer">' +
            '<span class="approval-event-card__count">' +
            caseItem.messages_count +
            ' сообщ.</span>' +
            '<span class="approval-event-card__progress">' +
            caseItem.approvals_done +
            ' / ' +
            caseItem.approvals_total +
            '</span>' +
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
            const collapsed = section.classList.toggle('is-collapsed');
            toggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
            toggle.title = collapsed ? 'Развернуть чаты событий' : 'Свернуть чаты событий';
        });
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

(function (global) {
    'use strict';

    const PV = global.PassViewer || (global.PassViewer = {});

    function cfg() {
        return PV.getPageConfig ? PV.getPageConfig() : {};
    }

    function requestId() {
        const c = cfg();
        return String(
            (c.effectiveRequestId || c.selectedRequestId || c.requestId || '')
        ).trim();
    }

    function getCookie(name) {
        return PV.getCookie ? PV.getCookie(name) : '';
    }

    function escapeHtml(value) {
        return PV.escapeHtml ? PV.escapeHtml(String(value ?? '')) : String(value ?? '');
    }

    function urls() {
        return (cfg().urls || {});
    }

    function showSection(el, visible) {
        if (!el) {
            return;
        }
        el.hidden = !visible;
    }

    function renderStatus(data) {
        const section = document.getElementById('ods-request-status-section');
        const body = document.getElementById('ods-request-status-body');
        if (!section || !body) {
            return;
        }
        if (!data || !data.present || !data.status) {
            showSection(section, false);
            return;
        }
        const s = data.status;
        const inRegistry = data.in_registry !== false;
        const timeline = s.timeline || {};
        const steps = Array.isArray(timeline.steps) ? timeline.steps : [];
        const pct = Number(timeline.progress_pct);
        const safePct = Number.isFinite(pct) ? Math.max(0, Math.min(100, pct)) : 0;
        const summary = timeline.summary ? String(timeline.summary) : '';
        let html = '';
        if (inRegistry && summary) {
            html += '<p class="add-object-approval__summary">' + escapeHtml(summary) + '</p>';
        }
        if (inRegistry) {
            html +=
                '<div class="add-object-approval__progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="' +
                safePct +
                '" aria-label="Прогресс исполнения заявки">' +
                '<div class="add-object-approval__progress-fill" style="width: ' +
                safePct +
                '%;"></div></div>';
        }
        if (steps.length) {
            html += '<ol class="add-object-approval__steps">';
            steps.forEach((step) => {
                const state = String(step.state || 'pending');
                const cls =
                    state === 'done'
                        ? ' add-object-approval__step--done'
                        : state === 'current'
                          ? ' add-object-approval__step--current'
                          : state === 'rejected'
                            ? ' add-object-approval__step--rejected'
                            : '';
                const date = String(step.date || '').trim();
                html +=
                    '<li class="add-object-approval__step' +
                    cls +
                    '">' +
                    '<span class="add-object-approval__step-marker" aria-hidden="true"></span>' +
                    '<span class="add-object-approval__step-body">' +
                    '<span class="add-object-approval__step-name">' +
                    escapeHtml(step.name || '') +
                    '</span>' +
                    (date
                        ? '<span class="add-object-approval__step-date">' + escapeHtml(date) + '</span>'
                        : '') +
                    '</span></li>';
            });
            html += '</ol>';
        }
        const rows = [
            ['Тип создания', s.create_type_name],
            ['Причина', s.reason_name],
        ].filter((row) => row[1]);
        html += rows
            .map(
                (row) =>
                    '<p class="add-object-approval__meta"><strong>' +
                    escapeHtml(row[0]) +
                    ':</strong> ' +
                    escapeHtml(row[1]) +
                    '</p>'
            )
            .join('');
        body.innerHTML = html;
        showSection(section, true);
    }

    function renderComments(items) {
        const section = document.getElementById('db-comments-section');
        const list = document.getElementById('db-comments-list');
        if (!section || !list) {
            return;
        }
        const rows = Array.isArray(items) ? items.slice() : [];
        if (!rows.length) {
            showSection(section, false);
            list.innerHTML = '';
            return;
        }
        list.innerHTML = '';
        rows.forEach((item) => {
            const li = document.createElement('li');
            li.className = 'add-object-db-comment';
            const head = document.createElement('div');
            head.className = 'add-object-db-comment__head';
            const badge = document.createElement('span');
            badge.className = 'add-object-db-comment__order';
            badge.textContent = '#' + (item.order_number || '');
            const date = document.createElement('span');
            date.className = 'add-object-db-comment__date';
            date.textContent = item.action_date || '';
            head.appendChild(badge);
            head.appendChild(date);
            const status = document.createElement('p');
            status.className = 'add-object-db-comment__status';
            status.textContent = item.description || '';
            const text = document.createElement('p');
            text.className = 'add-object-db-comment__text';
            text.textContent = item.comment || '';
            const footer = document.createElement('div');
            footer.className = 'add-object-db-comment__footer';
            const org = document.createElement('p');
            org.className = 'add-object-db-comment__org';
            org.textContent = item.org_name || '';
            footer.appendChild(org);
            li.appendChild(head);
            li.appendChild(status);
            li.appendChild(text);
            if (item.file_id && item.file_id.length) {
                const files = document.createElement('p');
                files.className = 'add-object-db-comment__files';
                files.textContent = 'Вложения: ' + item.file_id.length;
                li.appendChild(files);
            }
            li.appendChild(footer);
            list.appendChild(li);
        });
        showSection(section, true);
    }

    function renderAttachments(files) {
        const section = document.getElementById('attachments-section');
        const list = document.getElementById('attachments-list');
        if (!section || !list) {
            return;
        }
        const rid = requestId();
        showSection(section, !!rid);
        list.innerHTML = '';
        (files || []).forEach((file) => {
            const li = document.createElement('li');
            li.className = 'add-object-attachment';
            const link = document.createElement('a');
            link.className = 'add-object-attachment__link';
            link.href = file.download_url || '#';
            link.textContent = file.name || 'файл';
            link.title = 'Скачать ' + (file.name || '');
            const size = document.createElement('span');
            size.className = 'add-object-attachment__size';
            size.textContent = file.size || '';
            const del = document.createElement('button');
            del.type = 'button';
            del.className = 'map-toolbar-btn map-toolbar-btn--muted add-object-attachment__delete';
            del.textContent = 'Удалить';
            del.addEventListener('click', () => deleteAttachment(file));
            li.appendChild(link);
            li.appendChild(size);
            li.appendChild(del);
            list.appendChild(li);
        });
        const input = document.getElementById('request-attachment-input');
        const label = section.querySelector('label[for="request-attachment-input"]');
        if (input) {
            input.disabled = !rid;
        }
        if (label) {
            label.style.opacity = rid ? '1' : '0.5';
        }
    }

    function setAttachError(message) {
        const el = document.getElementById('attachments-error');
        if (!el) {
            return;
        }
        if (!message) {
            el.hidden = true;
            el.textContent = '';
            return;
        }
        el.hidden = false;
        el.textContent = message;
    }

    async function fetchJson(url, options) {
        const res = await fetch(url, options);
        const data = await res.json().catch(() => ({}));
        if (!res.ok || data.ok === false) {
            throw new Error(data.error || 'Ошибка запроса.');
        }
        return data;
    }

    async function loadAll() {
        const rid = requestId();
        const u = urls();
        // В режиме просмотра (модалка на home) секции комментариев и файлов не рендерятся — не запрашиваем их.
        const viewOnly = !!(cfg().features && cfg().features.viewOnly);
        if (!rid) {
            renderStatus({ present: false });
            renderComments([]);
            renderAttachments([]);
            return;
        }
        const q = '?request_id=' + encodeURIComponent(rid);
        let odsInRegistry = false;
        try {
            if (u.odsRequestStatus) {
                const statusData = await fetchJson(u.odsRequestStatus + q);
                odsInRegistry = !!statusData.in_registry;
                renderStatus(statusData);
            } else {
                renderStatus({ present: false });
            }
        } catch (_err) {
            renderStatus({ present: false });
        }
        try {
            if (!viewOnly && odsInRegistry && u.bidComments) {
                const data = await fetchJson(u.bidComments + q);
                renderComments(data.comments || []);
            } else {
                renderComments([]);
            }
        } catch (_err) {
            renderComments([]);
        }
        try {
            if (!viewOnly && u.listAttachments) {
                const data = await fetchJson(u.listAttachments + q);
                renderAttachments(data.files || []);
            }
        } catch (_err) {
            renderAttachments([]);
        }
    }

    async function uploadFile(file) {
        const rid = requestId();
        const u = urls();
        if (!rid || !u.uploadAttachment) {
            setAttachError('Нет номера заявки.');
            return;
        }
        setAttachError('');
        const body = new FormData();
        body.append('request_id', rid);
        body.append('file', file);
        try {
            await fetchJson(u.uploadAttachment, {
                method: 'POST',
                headers: { 'X-CSRFToken': getCookie('csrftoken') || '' },
                body,
                credentials: 'same-origin',
            });
            await loadAll();
        } catch (err) {
            setAttachError(err.message || 'Не удалось загрузить файл.');
        }
    }

    async function deleteAttachment(file) {
        if (!file || !file.delete_url) {
            return;
        }
        try {
            await fetchJson(file.delete_url, {
                method: 'POST',
                headers: { 'X-CSRFToken': getCookie('csrftoken') || '' },
                credentials: 'same-origin',
            });
            await loadAll();
        } catch (err) {
            setAttachError(err.message || 'Не удалось удалить файл.');
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        const input = document.getElementById('request-attachment-input');
        if (input) {
            input.addEventListener('change', () => {
                const file = input.files && input.files[0];
                input.value = '';
                if (file) {
                    void uploadFile(file);
                }
            });
        }
        void loadAll();
    });
})(window);

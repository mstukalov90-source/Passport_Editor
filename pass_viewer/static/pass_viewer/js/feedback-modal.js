/* Модалка обратной связи: открытие из меню пользователя, вложения, отправка. */
(function () {
    'use strict';

    var modal = document.getElementById('feedback-modal');
    var openBtn = document.getElementById('feedback-open-btn');
    if (!modal || !openBtn) {
        return;
    }

    var form = document.getElementById('feedback-form');
    var bodyInput = document.getElementById('feedback-body');
    var fileInput = document.getElementById('feedback-file-input');
    var fileList = document.getElementById('feedback-file-list');
    var attachBtn = document.getElementById('feedback-attach-btn');
    var closeBtn = document.getElementById('feedback-modal-close');
    var cancelBtn = document.getElementById('feedback-cancel-btn');
    var submitBtn = document.getElementById('feedback-submit-btn');
    var errorBox = document.getElementById('feedback-error');
    var successBox = document.getElementById('feedback-success');

    var ALLOWED_EXT = ['.jpg', '.jpeg', '.png', '.pdf', '.doc', '.docx'];
    var MAX_BYTES = 10 * 1024 * 1024;
    var MAX_FILES = 10;

    var selectedFiles = [];
    var previousOverflow = '';
    var closeTimer = null;

    function showError(message) {
        errorBox.textContent = message || '';
        errorBox.hidden = !message;
    }

    function humanSize(n) {
        if (n < 1024) {
            return n + ' Б';
        }
        if (n < 1024 * 1024) {
            return Math.round(n / 1024) + ' КБ';
        }
        return (n / (1024 * 1024)).toFixed(1).replace('.', ',') + ' МБ';
    }

    function renderFiles() {
        fileList.innerHTML = '';
        fileList.hidden = selectedFiles.length === 0;
        selectedFiles.forEach(function (file, index) {
            var item = document.createElement('li');
            item.className = 'feedback-modal__file-item';

            var name = document.createElement('span');
            name.className = 'feedback-modal__file-name';
            name.textContent = file.name;
            name.title = file.name;

            var size = document.createElement('span');
            size.className = 'feedback-modal__file-size';
            size.textContent = humanSize(file.size);

            var remove = document.createElement('button');
            remove.type = 'button';
            remove.className = 'feedback-modal__file-remove';
            remove.textContent = '✕';
            remove.setAttribute('aria-label', 'Убрать файл ' + file.name);
            remove.addEventListener('click', function () {
                selectedFiles.splice(index, 1);
                renderFiles();
            });

            item.appendChild(name);
            item.appendChild(size);
            item.appendChild(remove);
            fileList.appendChild(item);
        });
    }

    function closeUserMenu() {
        var menu = document.getElementById('site-header-user-menu');
        if (menu) {
            menu.hidden = true;
        }
        var toggle = document.querySelector('[aria-controls="site-header-user-menu"]');
        if (toggle) {
            toggle.setAttribute('aria-expanded', 'false');
        }
    }

    function openModal() {
        closeUserMenu();
        showError('');
        successBox.hidden = true;
        previousOverflow = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        modal.hidden = false;
        if (bodyInput) {
            bodyInput.focus();
        }
    }

    function closeModal() {
        if (closeTimer) {
            clearTimeout(closeTimer);
            closeTimer = null;
        }
        modal.hidden = true;
        document.body.style.overflow = previousOverflow || '';
    }

    openBtn.addEventListener('click', openModal);
    closeBtn.addEventListener('click', closeModal);
    cancelBtn.addEventListener('click', closeModal);
    modal.addEventListener('click', function (event) {
        if (event.target === modal) {
            closeModal();
        }
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && !modal.hidden) {
            closeModal();
        }
    });
    attachBtn.addEventListener('click', function () {
        fileInput.click();
    });

    fileInput.addEventListener('change', function () {
        Array.prototype.forEach.call(fileInput.files, function (file) {
            if (selectedFiles.length >= MAX_FILES) {
                showError('Можно прикрепить не более ' + MAX_FILES + ' файлов.');
                return;
            }
            var dot = file.name.lastIndexOf('.');
            var ext = dot === -1 ? '' : file.name.slice(dot).toLowerCase();
            if (ALLOWED_EXT.indexOf(ext) === -1) {
                showError('Файл «' + file.name + '»: допустимы только JPG, PNG, PDF, DOC и DOCX.');
                return;
            }
            if (file.size > MAX_BYTES) {
                showError('Файл «' + file.name + '» больше 10 МБ.');
                return;
            }
            selectedFiles.push(file);
        });
        fileInput.value = '';
        renderFiles();
    });

    form.addEventListener('submit', function (event) {
        event.preventDefault();
        showError('');
        successBox.hidden = true;

        var body = (bodyInput.value || '').trim();
        if (!body) {
            showError('Введите текст сообщения.');
            bodyInput.focus();
            return;
        }

        var data = new FormData(form);
        selectedFiles.forEach(function (file) {
            data.append('files', file, file.name);
        });

        submitBtn.disabled = true;
        submitBtn.textContent = 'Отправка…';

        fetch(form.action, {
            method: 'POST',
            body: data,
            credentials: 'same-origin',
            headers: { Accept: 'application/json' },
        })
            .then(function (response) {
                return response
                    .json()
                    .catch(function () {
                        return {};
                    })
                    .then(function (payload) {
                        return { ok: response.ok && payload.ok, payload: payload };
                    });
            })
            .then(function (result) {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Отправить';
                if (!result.ok) {
                    showError(result.payload.error || 'Не удалось отправить обращение. Попробуйте ещё раз.');
                    return;
                }
                successBox.hidden = false;
                form.reset();
                selectedFiles = [];
                renderFiles();
                closeTimer = setTimeout(closeModal, 2000);
            })
            .catch(function () {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Отправить';
                showError('Не удалось отправить обращение. Попробуйте ещё раз.');
            });
    });
})();

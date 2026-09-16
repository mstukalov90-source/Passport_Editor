/* Регистрация пользователя: полный текст длинных значений под полем.
   <input> не переносит текст, а datalist работает только с input — поэтому
   когда значение не влезает в поле, под ним показываем блок с полным текстом. */
(function () {
    'use strict';

    const OVERFLOW_EPSILON_PX = 4;

    function ensurePreview(input) {
        let preview = input.parentElement.querySelector('.login-input-preview');
        if (!preview) {
            preview = document.createElement('div');
            preview.className = 'login-input-preview';
            preview.setAttribute('aria-hidden', 'true');
            preview.hidden = true;
            input.insertAdjacentElement('afterend', preview);
        }
        return preview;
    }

    function syncPreview(input) {
        const preview = ensurePreview(input);
        const value = input.value || '';
        const overflowed = value && input.scrollWidth > input.clientWidth + OVERFLOW_EPSILON_PX;
        if (overflowed) {
            preview.textContent = value;
            preview.hidden = false;
        } else {
            preview.textContent = '';
            preview.hidden = true;
        }
    }

    function init() {
        const inputs = document.querySelectorAll('.login-form input:not([type="hidden"])');
        inputs.forEach((input) => {
            input.addEventListener('input', () => syncPreview(input));
            input.addEventListener('change', () => syncPreview(input));
            syncPreview(input);
        });
        window.addEventListener('resize', () => inputs.forEach(syncPreview));
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();

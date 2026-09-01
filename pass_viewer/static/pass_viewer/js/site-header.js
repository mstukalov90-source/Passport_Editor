(function () {
    'use strict';

    document.body.classList.add('has-site-header');

    const toggles = document.querySelectorAll('[data-header-dropdown-toggle]');
    const nav = document.querySelector('.site-header__nav');

    function resetMenuPosition(menu) {
        menu.style.position = '';
        menu.style.top = '';
        menu.style.left = '';
        menu.style.right = '';
        menu.style.zIndex = '';
    }

    function placeMenu(toggle, menu) {
        const rect = toggle.getBoundingClientRect();
        const gap = 8;
        menu.style.position = 'fixed';
        menu.style.top = `${Math.round(rect.bottom + gap)}px`;
        menu.style.zIndex = '1100';
        if (menu.classList.contains('site-header__dropdown--right')) {
            menu.style.left = 'auto';
            menu.style.right = `${Math.round(Math.max(8, window.innerWidth - rect.right))}px`;
            return;
        }
        menu.style.right = 'auto';
        const width = menu.offsetWidth || 220;
        let left = Math.round(rect.left);
        if (left + width > window.innerWidth - 8) {
            left = Math.max(8, window.innerWidth - width - 8);
        }
        menu.style.left = `${left}px`;
    }

    function closeMenus(exceptToggle) {
        toggles.forEach((toggle) => {
            if (toggle === exceptToggle) return;
            const menu = document.getElementById(toggle.getAttribute('aria-controls'));
            if (menu) {
                menu.hidden = true;
                resetMenuPosition(menu);
            }
            toggle.setAttribute('aria-expanded', 'false');
        });
    }

    toggles.forEach((toggle) => {
        const menu = document.getElementById(toggle.getAttribute('aria-controls'));
        if (!menu) return;
        toggle.addEventListener('click', (event) => {
            event.preventDefault();
            event.stopPropagation();
            const shouldOpen = menu.hidden;
            closeMenus(toggle);
            menu.hidden = !shouldOpen;
            toggle.setAttribute('aria-expanded', shouldOpen ? 'true' : 'false');
            if (shouldOpen) {
                placeMenu(toggle, menu);
            } else {
                resetMenuPosition(menu);
            }
        });
    });

    document.addEventListener('click', () => closeMenus());
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') closeMenus();
    });
    window.addEventListener('resize', () => closeMenus());

    function updateNavOverflow() {
        if (nav) nav.classList.toggle('is-scrollable', nav.scrollWidth > nav.clientWidth + 1);
    }

    updateNavOverflow();
    window.addEventListener('load', updateNavOverflow);
    window.addEventListener('resize', updateNavOverflow);

    document.querySelectorAll('[data-header-open-list]').forEach((link) => {
        link.addEventListener('click', (event) => {
            event.preventDefault();
            const tab = link.dataset.headerOpenList || 'requests';
            if (typeof window.openOwnedListsModal === 'function') {
                window.openOwnedListsModal(tab);
            }
        });
    });
})();

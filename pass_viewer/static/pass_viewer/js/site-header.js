(function () {
    'use strict';

    document.body.classList.add('has-site-header');

    const toggles = document.querySelectorAll('[data-header-dropdown-toggle]');
    const nav = document.querySelector('.site-header__nav');

    function closeMenus(exceptToggle) {
        toggles.forEach((toggle) => {
            if (toggle === exceptToggle) return;
            const menu = document.getElementById(toggle.getAttribute('aria-controls'));
            if (menu) menu.hidden = true;
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
        });
    });

    document.addEventListener('click', () => closeMenus());
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') closeMenus();
    });

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

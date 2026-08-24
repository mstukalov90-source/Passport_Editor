/* Shared site header injection, active-link highlight, dropdowns and notifications */
(function () {
    'use strict';

    var headerHTML =
        '<header class="site-header" role="banner">' +
            '<a class="site-header__brand" href="personal_account.html" aria-label="Главная — САПР МГГТ">' +
                '<img class="site-header__gsk" src="assets/pass_viewer/gsk.svg" alt="ГСК" />' +
                '<img class="site-header__logo" src="assets/pass_viewer/logo_dgp.png" alt="ДГП" />' +
                '<img class="site-header__cube" src="assets/pass_viewer/cube_red.svg" alt="Pass Viewer" />' +
            '</a>' +
            '<nav class="site-header__nav" aria-label="Главная навигация">' +
                '<ul class="site-header__nav-list">' +
                    '<li><a class="site-header__link" href="personal_account.html">Личный кабинет</a></li>' +
                    '<li><a class="site-header__link" href="add_object.html">Отрисовка границ заявок</a></li>' +
                    '<li><a class="site-header__link" href="approval.html">Согласование границ ОГХ</a></li>' +
                    '<li><a class="site-header__link site-header__link--disabled" href="#" aria-disabled="true" tabindex="-1">Согласование ЦГ</a></li>' +
                    '<li class="site-header__more-wrap">' +
                        '<button type="button" class="site-header__link site-header__more-btn" id="site-header-more-btn" data-header-dropdown-toggle aria-haspopup="menu" aria-expanded="false" aria-controls="site-header-more-menu">Ещё</button>' +
                        '<ul class="site-header__dropdown" id="site-header-more-menu" hidden>' +
                            '<li><a class="site-header__dropdown-link" href="#">Дополнительно</a></li>' +
                            '<li><a class="site-header__dropdown-link" href="#">Инструкция пользователя</a></li>' +
                        '</ul>' +
                    '</li>' +
                '</ul>' +
            '</nav>' +
            '<div class="site-header__actions">' +
                '<a class="site-header__icon-link" id="site-header-notifications" href="#" role="button" aria-label="Уведомления" aria-haspopup="dialog" aria-expanded="false" aria-controls="approval-notifications-modal">' +
                    '<img class="site-header__icon" src="assets/pass_viewer/notification-21_128x128.svg" alt="Уведомления" />' +
                    '<span class="site-header__badge" aria-label="3 непрочитанных уведомления">3</span>' +
                '</a>' +
                '<div class="site-header__user-menu">' +
                    '<button type="button" class="site-header__user" id="site-header-user" data-header-dropdown-toggle aria-haspopup="menu" aria-expanded="false" aria-controls="site-header-user-menu">' +
                        '<span class="site-header__user-avatar" aria-hidden="true">СА</span>' +
                        '<span class="site-header__user-name">Сидоров А.Н.</span>' +
                    '</button>' +
                    '<ul class="site-header__dropdown site-header__dropdown--right" id="site-header-user-menu" hidden>' +
                        '<li><a class="site-header__dropdown-link" href="#">Профиль</a></li>' +
                        '<li><a class="site-header__dropdown-link" href="#">Настройки</a></li>' +
                        '<li><a class="site-header__dropdown-link" href="#">Выйти</a></li>' +
                    '</ul>' +
                '</div>' +
            '</div>' +
        '</header>';

    function injectHeader() {
        var body = document.body;
        if (!body) return;
        body.insertAdjacentHTML('afterbegin', headerHTML);
        body.classList.add('has-site-header');
        highlightCurrentPage();
        initDropdowns();
        initNotifications();
        updateNavScrollIndicator();
    }

    if (document.body) {
        injectHeader();
    } else {
        document.addEventListener('DOMContentLoaded', injectHeader);
    }

    function updateNavScrollIndicator() {
        var nav = document.querySelector('.site-header__nav');
        if (!nav) return;
        nav.classList.toggle('is-scrollable', nav.scrollWidth > nav.clientWidth + 1);
    }

    window.addEventListener('load', updateNavScrollIndicator);
    window.addEventListener('resize', updateNavScrollIndicator);

    function highlightCurrentPage() {
        var currentPage = location.pathname.split('/').pop() || 'personal_account.html';
        if (currentPage === '') currentPage = 'personal_account.html';
        var sectionMap = {
            'home.html': 'personal_account.html',
            'main.html': 'personal_account.html'
        };
        var activeHref = sectionMap[currentPage] || currentPage;
        document.querySelectorAll('.site-header__link').forEach(function (link) {
            var href = link.getAttribute('href') || '';
            if (href === activeHref && !link.classList.contains('site-header__link--disabled')) {
                link.classList.add('is-active');
            }
        });
    }

    function initDropdowns() {
        var toggles = document.querySelectorAll('[data-header-dropdown-toggle]');
        if (!toggles.length) return;

        function closeAll() {
            toggles.forEach(function (toggle) {
                var menu = document.getElementById(toggle.getAttribute('aria-controls'));
                if (menu) menu.hidden = true;
                toggle.setAttribute('aria-expanded', 'false');
            });
        }

        toggles.forEach(function (toggle) {
            var menu = document.getElementById(toggle.getAttribute('aria-controls'));
            if (!menu) return;

            toggle.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                var isOpen = !menu.hidden;
                closeAll();
                if (!isOpen) {
                    menu.hidden = false;
                    toggle.setAttribute('aria-expanded', 'true');
                }
            });
        });

        document.addEventListener('click', function () {
            closeAll();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeAll();
        });
    }

    function initNotifications() {
        var btn = document.getElementById('site-header-notifications');
        var modal = document.getElementById('approval-notifications-modal');
        var closeBtn = document.getElementById('approval-notifications-close-btn');
        if (!btn || !modal) return;

        btn.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            modal.hidden = false;
            btn.setAttribute('aria-expanded', 'true');
        });

        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                modal.hidden = true;
                btn.setAttribute('aria-expanded', 'false');
            });
        }

        modal.addEventListener('click', function (e) {
            if (e.target === modal) {
                modal.hidden = true;
                btn.setAttribute('aria-expanded', 'false');
            }
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && !modal.hidden) {
                modal.hidden = true;
                btn.setAttribute('aria-expanded', 'false');
            }
        });
    }
})();

/* Animated tile background for auth pages (login, registration).
   Builds a full-viewport grid of header-blue tiles that flip near the
   cursor, revealing a red side or one of the header icons. Icon URLs
   come from window.PV_LOGIN_BG_ASSETS set by the page template. */
(function () {
    'use strict';

    var ASSETS = window.PV_LOGIN_BG_ASSETS || {};
    var ICONS = [ASSETS.gsk, ASSETS.logo, ASSETS.cube].filter(Boolean);
    var RED_RATIO = 0.35;
    var GAP = 4;
    var HOLD_MS = 1000;
    var CURSOR_RADIUS_PITCH = 1.4;
    var STAGGER_MS = 30;
    var RESIZE_DEBOUNCE_MS = 200;
    var FRONT_SHADES = ['#1a3f6e', '#1a3f6e', '#183b68', '#1c4374', '#1e4879'];

    var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    var container = null;
    var tiles = [];
    var tileSize = 80;
    var radius = 0;
    var pointerX = -1e4;
    var pointerY = -1e4;
    var pointerRaf = null;
    var ambientTimer = null;
    var resizeTimer = null;

    function randomItem(list) {
        return list[Math.floor(Math.random() * list.length)];
    }

    function buildBackFace() {
        var back = document.createElement('div');
        back.className = 'login-bg__face login-bg__face--back';
        if (!ICONS.length || Math.random() < RED_RATIO) {
            back.classList.add('login-bg__face--red');
            return back;
        }
        back.classList.add('login-bg__face--icon');
        var img = document.createElement('img');
        img.src = randomItem(ICONS);
        img.alt = '';
        img.draggable = false;
        back.appendChild(img);
        return back;
    }

    function flip(tile, delayMs, holdMs) {
        if (tile.timer) {
            window.clearTimeout(tile.timer);
        }
        if (!tile.flipped) {
            tile.inner.style.transitionDelay = delayMs + 'ms';
            tile.el.classList.add('is-flipped');
            tile.flipped = true;
        }
        tile.timer = window.setTimeout(function () {
            tile.inner.style.transitionDelay = '';
            tile.el.classList.remove('is-flipped');
            tile.flipped = false;
            tile.timer = null;
        }, delayMs + holdMs);
    }

    function updateCursorFlips() {
        var r2 = radius * radius;
        var pitch = tileSize + GAP;
        for (var i = 0; i < tiles.length; i++) {
            var tile = tiles[i];
            var dx = tile.cx - pointerX;
            var dy = tile.cy - pointerY;
            var d2 = dx * dx + dy * dy;
            if (d2 > r2) {
                continue;
            }
            var steps = Math.sqrt(d2) / pitch;
            flip(tile, Math.round(steps * STAGGER_MS), HOLD_MS);
        }
    }

    function onPointerMove(event) {
        pointerX = event.clientX;
        pointerY = event.clientY;
        if (pointerRaf !== null) {
            return;
        }
        pointerRaf = window.requestAnimationFrame(function () {
            pointerRaf = null;
            updateCursorFlips();
        });
    }

    function scheduleAmbient() {
        ambientTimer = window.setTimeout(function () {
            if (!document.hidden && tiles.length) {
                flip(randomItem(tiles), 0, HOLD_MS);
            }
            scheduleAmbient();
        }, 500 + Math.random() * 600);
    }

    function buildGrid() {
        tiles.forEach(function (tile) {
            if (tile.timer) {
                window.clearTimeout(tile.timer);
            }
        });
        var pitch = tileSize + GAP;
        var cols = Math.ceil(window.innerWidth / pitch) + 1;
        var rows = Math.ceil(window.innerHeight / pitch) + 1;
        radius = CURSOR_RADIUS_PITCH * pitch;
        container.innerHTML = '';
        container.style.gridTemplateColumns = 'repeat(' + cols + ', ' + tileSize + 'px)';
        container.style.gridTemplateRows = 'repeat(' + rows + ', ' + tileSize + 'px)';
        container.style.gap = GAP + 'px';
        tiles = [];
        for (var row = 0; row < rows; row++) {
            for (var col = 0; col < cols; col++) {
                var el = document.createElement('div');
                el.className = 'login-bg__tile' + (Math.random() < 0.5 ? '' : ' login-bg__tile--x');
                var inner = document.createElement('div');
                inner.className = 'login-bg__tile-inner';
                var front = document.createElement('div');
                front.className = 'login-bg__face login-bg__face--front';
                front.style.background = randomItem(FRONT_SHADES);
                inner.appendChild(front);
                inner.appendChild(buildBackFace());
                el.appendChild(inner);
                container.appendChild(el);
                tiles.push({
                    el: el,
                    inner: inner,
                    cx: col * pitch + tileSize / 2,
                    cy: row * pitch + tileSize / 2,
                    flipped: false,
                    timer: null,
                });
            }
        }
    }

    function onResize() {
        window.clearTimeout(resizeTimer);
        resizeTimer = window.setTimeout(function () {
            tileSize = window.innerWidth < 480 ? 64 : 80;
            buildGrid();
        }, RESIZE_DEBOUNCE_MS);
    }

    function init() {
        document.body.classList.add('has-login-bg');
        container = document.createElement('div');
        container.className = 'login-bg';
        container.setAttribute('aria-hidden', 'true');
        document.body.appendChild(container);
        tileSize = window.innerWidth < 480 ? 64 : 80;
        buildGrid();
        if (reducedMotion) {
            return;
        }
        window.addEventListener('pointermove', onPointerMove, { passive: true });
        window.addEventListener('resize', onResize);
        scheduleAmbient();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();

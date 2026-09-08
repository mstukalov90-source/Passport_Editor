(function (global) {
    'use strict';

    function invalidateEditorMap() {
        const el = document.getElementById('map');
        if (!el || !global.L) {
            return;
        }
        const map = el._leaflet_map || (global.PassViewer && global.PassViewer._editorMap);
        if (map && typeof map.invalidateSize === 'function') {
            map.invalidateSize(false);
            window.setTimeout(() => map.invalidateSize(false), 120);
        }
    }

    function bindLayerPanelCollapse() {
        const panel = document.getElementById('layer-management-panel');
        const toggle = document.getElementById('add-object-layers-toggle');
        if (!panel || !toggle) {
            return;
        }
        toggle.addEventListener('click', (event) => {
            event.stopPropagation();
            const collapsed = panel.classList.toggle('is-collapsed');
            toggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
            toggle.title = collapsed
                ? 'Развернуть панель управления слоями'
                : 'Свернуть панель управления слоями';
            invalidateEditorMap();
        });
        panel.addEventListener('click', () => {
            if (!panel.classList.contains('is-collapsed')) {
                return;
            }
            panel.classList.remove('is-collapsed');
            toggle.setAttribute('aria-expanded', 'true');
            toggle.title = 'Свернуть панель управления слоями';
            invalidateEditorMap();
        });
    }

    function bindSectionToggles() {
        document.querySelectorAll('.add-object-tools__section-toggle').forEach((btn) => {
            btn.addEventListener('click', () => {
                const section = btn.closest('.add-object-tools__section');
                if (!section) {
                    return;
                }
                const collapsed = section.classList.toggle('is-collapsed');
                btn.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
                btn.title = collapsed ? 'Развернуть блок' : 'Свернуть блок';
            });
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        bindLayerPanelCollapse();
        bindSectionToggles();
        invalidateEditorMap();
    });

    global.PassViewer = global.PassViewer || {};
    global.PassViewer.invalidateEditorMap = invalidateEditorMap;
    global.PassViewer.setMapToolbarLabel = function setMapToolbarLabel(button, text) {
        if (!button) {
            return;
        }
        const label = button.querySelector('.map-toolbar-btn__label');
        if (label) {
            label.textContent = text;
            return;
        }
        const textNodes = Array.from(button.childNodes).filter(
            (node) => node.nodeType === 3 && String(node.textContent || '').trim()
        );
        if (textNodes.length) {
            textNodes[textNodes.length - 1].textContent = text;
            return;
        }
        button.textContent = text;
    };
    global.PassViewer.buildExportFileButtonHtml = function buildExportFileButtonHtml(href, label, attrs) {
        const extra = attrs ? ' ' + attrs : '';
        return (
            '<a class="map-toolbar-btn map-toolbar-btn--primary" href="' +
            String(href || '#') +
            '"' +
            extra +
            '>' +
            '<svg class="map-toolbar-btn__icon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true" focusable="false"><path fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" d="M8 2.5v8M5 7.5L8 10.5l3-3M3 13.5h10"/></svg>' +
            '<span class="map-toolbar-btn__label">' +
            String(label || '') +
            '</span></a>'
        );
    };
})(window);

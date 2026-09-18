(function () {
    'use strict';

    const configEl = document.getElementById('recheck-config');
    if (!configEl) return;
    const config = JSON.parse(configEl.textContent || '{}');
    const eventId = config.selectedEventId;
    const mapLayers = new Map();
    let map = null;
    let qmlRenderer = null;
    let selectedFeature = null;
    let selectedLayerKey = '';

    const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (ch) => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
    }[ch]));
    const csrf = () => (document.cookie.match(/(?:^|; )csrftoken=([^;]+)/) || [])[1] || '';

    function readJsonScript(id) {
        const element = document.getElementById(id);
        if (!element || !element.textContent) return null;
        try {
            return JSON.parse(element.textContent);
        } catch (_error) {
            return null;
        }
    }

    async function jsonFetch(url, options) {
        const response = await fetch(url, options);
        const data = await response.json();
        if (!response.ok || !data.ok) throw new Error(data.error || 'Ошибка запроса.');
        return data;
    }

    function setInfoCollapsed(collapsed) {
        const section = document.getElementById('recheck-info-section');
        const toggle = document.getElementById('recheck-info-toggle');
        if (!section || !toggle) return;
        section.classList.toggle('is-collapsed', collapsed);
        toggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
        toggle.title = collapsed ? 'Развернуть информацию о проверке' : 'Свернуть информацию о проверке';
    }

    const infoToggle = document.getElementById('recheck-info-toggle');
    if (infoToggle) {
        infoToggle.addEventListener('click', () => {
            const section = document.getElementById('recheck-info-section');
            setInfoCollapsed(!section.classList.contains('is-collapsed'));
        });
    }

    async function loadEvent() {
        if (!eventId) return;
        const data = await jsonFetch(config.urls.bootstrap + '?event=' + encodeURIComponent(eventId));
        const item = data.selected;
        if (!item) return;
        const approvals = Object.values(item.approvals || {});
        const progress = Object.keys(item.approvals || {}).length;
        const progressEl = document.getElementById('recheck-event-progress');
        const statusEl = document.getElementById('recheck-active-status');
        const titleEl = document.getElementById('recheck-active-title');
        const summaryEl = document.getElementById('recheck-event-summary');
        const closedBanner = document.getElementById('recheck-closed-banner');
        if (progressEl) progressEl.textContent = 'Согласовано: ' + progress + ' / 2';
        if (statusEl) {
            statusEl.textContent = item.status_label;
            statusEl.classList.toggle('approval-events__status--closed', item.status !== 'open');
        }
        if (titleEl) titleEl.textContent = item.title;
        if (summaryEl) {
            summaryEl.innerHTML =
                '<p><strong>TaskGUID:</strong> ' + escapeHtml(item.task_guid) + '</p>' +
                '<p><strong>Организация задания:</strong> ' + escapeHtml(item.task_owner_id || 'не назначена') + '</p>' +
                '<p><strong>Срок:</strong> ' + escapeHtml(new Date(item.due_at).toLocaleString('ru-RU')) + '</p>' +
                '<p><strong>Согласовали:</strong> ' + escapeHtml(approvals.join(', ') || '—') + '</p>';
        }
        const messagesEl = document.getElementById('recheck-messages');
        if (messagesEl) {
            messagesEl.innerHTML = (item.messages || []).map((message) =>
                '<article class="recheck-message"><strong>' + escapeHtml(message.author_login) + '</strong>' +
                escapeHtml(message.body) + '<time>' +
                escapeHtml(new Date(message.created_at).toLocaleString('ru-RU')) + '</time></article>'
            ).join('') || '<p class="approval-events__empty">Сообщений пока нет.</p>';
            messagesEl.scrollTop = messagesEl.scrollHeight;
        }
        const approve = document.getElementById('recheck-approve');
        if (approve) approve.hidden = !item.can_approve;
        const composer = document.getElementById('recheck-message-form');
        if (composer) composer.hidden = item.status !== 'open';
        if (closedBanner) closedBanner.hidden = item.status === 'open';
    }

    const messageForm = document.getElementById('recheck-message-form');
    if (messageForm) {
        messageForm.addEventListener('submit', async (event) => {
            event.preventDefault();
            const input = document.getElementById('recheck-message-body');
            try {
                await jsonFetch(config.urls.messages, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json', 'X-CSRFToken': csrf()},
                    body: JSON.stringify({body: input.value}),
                });
                input.value = '';
                await loadEvent();
            } catch (error) {
                window.alert(error.message);
            }
        });
    }

    const approveButton = document.getElementById('recheck-approve');
    if (approveButton) {
        approveButton.addEventListener('click', async () => {
            if (!window.confirm('Согласовать проверку геоподосновы?')) return;
            try {
                await jsonFetch(config.urls.approve, {method: 'POST', headers: {'X-CSRFToken': csrf()}});
                await loadEvent();
            } catch (error) {
                window.alert(error.message);
            }
        });
    }

    function featureIdentity(feature, fallback) {
        const properties = feature.properties || {};
        return properties.rootid ?? properties.RootId ?? properties.objectid ??
            properties.ObjectId ?? properties.id ?? feature.id ?? fallback;
    }

    function geometryKey(feature, prefix) {
        const raw = JSON.stringify(feature.geometry || {});
        let hash = 2166136261;
        for (let index = 0; index < raw.length; index += 1) {
            hash ^= raw.charCodeAt(index);
            hash = Math.imul(hash, 16777619);
        }
        return prefix + ':' + (hash >>> 0).toString(16);
    }

    function openChangeModal(feature, layerKey, fallback) {
        selectedFeature = feature;
        selectedLayerKey = layerKey;
        const properties = feature.properties || {};
        const identity = featureIdentity(feature, fallback);
        document.getElementById('recheck-object-caption').textContent = 'Объект: ' + identity;
        document.getElementById('recheck-fields').innerHTML = Object.entries(properties).map(([key, value]) => {
            const text = value == null ? '' : (typeof value === 'object' ? JSON.stringify(value) : String(value));
            return '<label class="recheck-field"><input type="checkbox" data-change-check="' + escapeHtml(key) + '">' +
                '<span>' + escapeHtml(key) + '</span><code title="' + escapeHtml(text) + '">' + escapeHtml(text) + '</code>' +
                '<input type="text" data-change-value="' + escapeHtml(key) + '" value="' + escapeHtml(text) + '" disabled></label>';
        }).join('');
        document.querySelectorAll('[data-change-check]').forEach((check) => {
            check.addEventListener('change', () => {
                document.querySelector('[data-change-value="' + CSS.escape(check.dataset.changeCheck) + '"]').disabled = !check.checked;
            });
        });
        document.getElementById('recheck-change-error').textContent = '';
        document.getElementById('recheck-change-modal').hidden = false;
    }

    function closeModal() {
        document.getElementById('recheck-change-modal').hidden = true;
        selectedFeature = null;
    }

    ['recheck-modal-close', 'recheck-modal-cancel'].forEach((id) => {
        const element = document.getElementById(id);
        if (element) element.addEventListener('click', closeModal);
    });

    const changeForm = document.getElementById('recheck-change-form');
    if (changeForm) {
        changeForm.addEventListener('submit', async (event) => {
            event.preventDefault();
            const properties = selectedFeature.properties || {};
            const changes = Array.from(document.querySelectorAll('[data-change-check]:checked')).map((check) => {
                const field = check.dataset.changeCheck;
                const oldValue = properties[field];
                const rawValue = document.querySelector('[data-change-value="' + CSS.escape(field) + '"]').value;
                let newValue = rawValue;
                if (typeof oldValue === 'number' && rawValue.trim() !== '' && Number.isFinite(Number(rawValue))) {
                    newValue = Number(rawValue);
                } else if (typeof oldValue === 'boolean' && /^(true|false)$/i.test(rawValue.trim())) {
                    newValue = rawValue.trim().toLowerCase() === 'true';
                } else if (oldValue && typeof oldValue === 'object') {
                    try { newValue = JSON.parse(rawValue); } catch (ignore) { newValue = rawValue; }
                }
                return {field_name: field, field_label: field, old_value: oldValue, new_value: newValue};
            });
            const identity = String(featureIdentity(selectedFeature, selectedLayerKey));
            const payload = {
                source_layer: selectedLayerKey,
                object_key: identity,
                root_id: String(properties.rootid ?? properties.RootId ?? ''),
                object_name: String(properties.name ?? properties.Name ?? ''),
                properties,
                geometry: selectedFeature.geometry,
                changes,
            };
            try {
                await jsonFetch(config.urls.objectRequests, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json', 'X-CSRFToken': csrf()},
                    body: JSON.stringify(payload),
                });
                closeModal();
                await loadEvent();
            } catch (error) {
                document.getElementById('recheck-change-error').textContent = error.message;
            }
        });
    }

    function syncLayerVisibility(layerKey, visible) {
        const layer = mapLayers.get(layerKey);
        if (!map || !layer) return;
        if (visible && !map.hasLayer(layer)) layer.addTo(map);
        if (!visible && map.hasLayer(layer)) map.removeLayer(layer);
    }

    function bindLayerControls() {
        const panel = document.getElementById('recheck-layer-panel');
        const panelHost = document.getElementById('recheck-panel-layers');
        const workspace = document.getElementById('recheck-workspace');
        const toggle = document.getElementById('recheck-layer-panel-toggle');
        if (toggle && panel && panelHost && workspace) {
            toggle.addEventListener('click', () => {
                const collapsed = !panel.classList.contains('is-collapsed');
                panel.classList.toggle('is-collapsed', collapsed);
                panelHost.classList.toggle('is-collapsed', collapsed);
                workspace.classList.toggle('approval-workspace--layers-collapsed', collapsed);
                toggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
                toggle.title = collapsed ? 'Развернуть панель слоёв' : 'Свернуть панель слоёв';
                if (map) window.setTimeout(() => map.invalidateSize(), 180);
            });
        }
        document.querySelectorAll('[data-recheck-layer-key]').forEach((checkbox) => {
            checkbox.addEventListener('change', () => syncLayerVisibility(checkbox.dataset.recheckLayerKey, checkbox.checked));
        });
        document.querySelectorAll('[data-recheck-layer-group]').forEach((checkbox) => {
            checkbox.addEventListener('change', () => {
                document.querySelectorAll('[data-recheck-layer-parent="' + CSS.escape(checkbox.dataset.recheckLayerGroup) + '"]').forEach((child) => {
                    child.checked = checkbox.checked;
                    syncLayerVisibility(child.dataset.recheckLayerKey, child.checked);
                });
            });
        });
    }

    async function initMap() {
        const mapEl = document.getElementById('recheck-map');
        if (!mapEl || !eventId || typeof L === 'undefined') return;
        map = L.map(mapEl, {
            zoomControl: true,
            attributionControl: true,
            maxZoom: 20.5,
            markerZoomAnimation: false,
            zoomSnap: 0.25,
            zoomDelta: 0.5,
            wheelPxPerZoomLevel: 80,
        }).setView([55.75, 37.61], 11);
        map.attributionControl.setPrefix(
            '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>'
        );
        if (window.PassViewer && typeof window.PassViewer.attachBasemapControl === 'function') {
            window.PassViewer.attachBasemapControl(map, {
                defaultMode: 'none',
                position: 'topright',
                scopeRoot: mapEl.parentElement,
            });
        }
        if (window.PassViewer && typeof window.PassViewer.attachMapUtilityControls === 'function') {
            window.PassViewer.attachMapUtilityControls(map);
        }
        if (window.PassViewer && typeof window.PassViewer.createQmlRenderer === 'function') {
            qmlRenderer = window.PassViewer.createQmlRenderer(map, {
                manifest: readJsonScript('recheck-work-layer-styles') || {tables: {}},
                svgIndex: readJsonScript('recheck-svg-index') || {},
                iconsBase: '/static/approval/icons/svg/',
                actionLabel: 'Запросить изменение',
                onAction: (feature) => {
                    const props = feature.properties || {};
                    const layerKey = props.layerKey || props.sourceTable || '';
                    const objectKey = featureIdentity(feature, geometryKey(feature, layerKey));
                    openChangeModal(feature, layerKey, objectKey);
                },
            });
        }
        bindLayerControls();
        const bounds = L.latLngBounds([]);
        let count = 0;
        for (const spec of (config.layerOrder || [])) {
            try {
                const data = await jsonFetch(config.urls.mapLayer, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json', 'X-CSRFToken': csrf()},
                    body: JSON.stringify({event_id: eventId, layer: spec.key}),
                });
                const features = (data.features || []).map((feature) => {
                    feature.properties = feature.properties || {};
                    if (!feature.properties.layerKey) feature.properties.layerKey = spec.key;
                    return feature;
                });
                const group = L.geoJSON({type: 'FeatureCollection', features}, {
                    style: qmlRenderer ? qmlRenderer.style : {color: '#b7192e', weight: 2, fillColor: '#ef8b98', fillOpacity: 0.28},
                    pointToLayer: qmlRenderer ? qmlRenderer.pointToLayer : undefined,
                    onEachFeature: (feature, layer) => {
                        if (qmlRenderer) {
                            qmlRenderer.onEachFeature(feature, layer);
                            return;
                        }
                        const key = featureIdentity(feature, geometryKey(feature, spec.key));
                        layer.bindPopup('<strong>' + escapeHtml(spec.label) + '</strong><br>Объект: ' +
                            escapeHtml(key) + '<br><button type="button" class="recheck-popup-btn">Запросить изменение</button>');
                        layer.on('popupopen', (popupEvent) => {
                            const button = popupEvent.popup.getElement().querySelector('.recheck-popup-btn');
                            if (button) button.onclick = () => openChangeModal(feature, spec.key, key);
                        });
                    },
                });
                mapLayers.set(spec.key, group);
                const checkbox = document.querySelector('[data-recheck-layer-key="' + CSS.escape(spec.key) + '"]');
                if (!checkbox || checkbox.checked) group.addTo(map);
                if (group.getBounds().isValid()) bounds.extend(group.getBounds());
                count += features.length;
            } catch (error) {
                document.getElementById('recheck-map-status').textContent = error.message;
            }
        }
        if (bounds.isValid()) map.fitBounds(bounds.pad(0.08));
        if (qmlRenderer) qmlRenderer.refresh();
        document.getElementById('recheck-map-status').textContent = count
            ? 'Загружено объектов: ' + count
            : 'Для задания объекты не найдены.';
    }

    loadEvent().catch((error) => window.alert(error.message));
    initMap();
})();

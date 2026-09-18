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
    let selectedObjectKey = '';

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
        const properties = (feature && feature.properties) || {};
        const candidates = [
            properties.fid,
            properties.objectid,
            properties.ObjectId,
            properties.id,
            feature && feature.id,
        ];
        for (let index = 0; index < candidates.length; index += 1) {
            const value = candidates[index];
            if (value != null && String(value).trim() !== '') return String(value).trim();
        }
        return fallback;
    }

    function layerTableKey(layerKey) {
        const key = String(layerKey || '');
        return key.indexOf('topo:') === 0 ? key.slice(5) : key;
    }

    function isPhotoFixLayer(layerKey) {
        return layerTableKey(layerKey) === 'PhotoFixPoint';
    }

    let modalFields = [];

    function lookupParents(item) {
        const lookup = (item && item.lookup) || {};
        if (Array.isArray(lookup.parents) && lookup.parents.length) return lookup.parents;
        if (item.field === 'MafTypeLevel2') return [{column: 'ParentCode', field: 'MafTypeLevel1'}];
        if (item.field === 'MafTypeLevel3') {
            return [
                {column: 'ParentLevel1Code', field: 'MafTypeLevel1'},
                {column: 'ParentLevel2Code', field: 'MafTypeLevel2'},
            ];
        }
        return [];
    }

    function fieldItem(field) {
        return modalFields.find((item) => item.field === field) || null;
    }

    function optionLabel(option) {
        if (!option) return '';
        const label = option.label == null || option.label === '' ? option.value : option.label;
        return String(label);
    }

    function normalizeLookupText(value) {
        return String(value == null ? '' : value).trim().replace(/\s+/g, ' ').toLowerCase();
    }

    function findLookupOption(options, typed) {
        const text = String(typed == null ? '' : typed).trim();
        if (!text || !Array.isArray(options) || !options.length) return null;
        const normalized = normalizeLookupText(text);
        return options.find((option) => String(option.value) === text)
            || options.find((option) => optionLabel(option) === text)
            || options.find((option) => normalizeLookupText(option.value) === normalized)
            || options.find((option) => normalizeLookupText(optionLabel(option)) === normalized)
            || null;
    }

    function resolveStoredValue(field, typed, fallback) {
        const item = fieldItem(field);
        const matched = findLookupOption((item && item.options) || [], typed);
        if (matched) return String(matched.value);
        const text = String(typed == null ? '' : typed).trim();
        if (text) return text;
        return fallback == null ? '' : String(fallback);
    }

    function resolvedLookupCode(field, fallback) {
        const item = fieldItem(field);
        const options = (item && item.options) || [];
        const control = document.querySelector('#recheck-fields [data-change-value="' + CSS.escape(field) + '"]');
        const typed = control ? control.value : fallback;
        const matched = findLookupOption(options, typed) || findLookupOption(options, fallback);
        return matched ? String(matched.value) : '';
    }

    function currentModalValue(field, fallback) {
        const resolved = resolvedLookupCode(field, fallback);
        if (resolved) return resolved;
        const control = document.querySelector('#recheck-fields [data-change-value="' + CSS.escape(field) + '"]');
        if (control) return resolveStoredValue(field, control.value, fallback);
        return fallback == null ? '' : String(fallback);
    }

    function fillComboOptions(input, options, current, currentLabel, replace) {
        const list = Array.isArray(options) ? options.slice() : [];
        const currentValue = current == null ? '' : String(current);
        if (!replace && currentValue && !list.some((option) => String(option.value) === currentValue)) {
            const extraLabel = currentLabel && String(currentLabel) !== currentValue &&
                (!input.value || input.value === currentLabel)
                ? currentLabel
                : currentValue;
            list.unshift({value: currentValue, label: extraLabel});
        }
        const item = fieldItem(input.dataset.changeValue);
        if (item) item.options = list;
        const datalist = document.getElementById('recheck-dl-' + input.dataset.changeValue);
        if (datalist) {
            const seenLabels = new Set();
            datalist.innerHTML = list.map((option) => {
                let label = optionLabel(option);
                if (seenLabels.has(label) && String(option.value) && String(option.value) !== label) {
                    label = label + ' (' + option.value + ')';
                }
                seenLabels.add(label);
                return '<option value="' + escapeHtml(label) + '"></option>';
            }).join('');
        }
        if (!input.value) {
            const matched = list.find((option) => String(option.value) === currentValue);
            input.value = matched ? optionLabel(matched) : (currentLabel || currentValue);
        }
    }

    function fieldEditorHtml(item) {
        const field = escapeHtml(item.field);
        const text = item.value == null ? '' : String(item.value);
        if ((item.options && item.options.length) || item.lookup) {
            return '<span class="recheck-combo"><input type="text" list="recheck-dl-' + field +
                '" data-change-value="' + field + '" value="' + escapeHtml(text) +
                '" autocomplete="off" disabled><datalist id="recheck-dl-' + field + '"></datalist></span>';
        }
        return '<input type="text" data-change-value="' + field + '" value="' + escapeHtml(text) + '" disabled>';
    }

    function parentFilters(item, properties) {
        const filters = {};
        const parents = lookupParents(item);
        for (let index = 0; index < parents.length; index += 1) {
            const parent = parents[index];
            const code = resolvedLookupCode(parent.field, properties[parent.field]);
            if (!code) return null;
            filters[parent.column] = code;
        }
        return filters;
    }

    async function refreshLookupSelect(item, properties, replace) {
        const input = document.querySelector('#recheck-fields [data-change-value="' + CSS.escape(item.field) + '"]');
        if (!input || !item.lookup || !config.urls.lookupOptions) return;
        const parents = lookupParents(item);
        const filters = parentFilters(item, properties);
        const current = resolveStoredValue(item.field, input.value, item.rawValue);
        if (parents.length && filters === null) {
            return;
        }
        try {
            const data = await jsonFetch(config.urls.lookupOptions, {
                method: 'POST',
                headers: {'Content-Type': 'application/json', 'X-CSRFToken': csrf()},
                body: JSON.stringify({
                    table: item.lookup.table,
                    key: item.lookup.key || 'Code',
                    value: item.lookup.value || 'Name',
                    filters: filters || {},
                }),
            });
            fillComboOptions(input, data.options || [], current, item.value, replace);
        } catch (_error) {
            fillComboOptions(input, [], current, item.value, replace);
        }
    }

    function dependentsOf(field) {
        return modalFields.filter((item) => {
            return item.lookup && lookupParents(item).some((parent) => parent.field === field);
        });
    }

    async function refreshDependentLookups(field, properties) {
        const dependents = dependentsOf(field);
        for (let index = 0; index < dependents.length; index += 1) {
            await refreshLookupSelect(dependents[index], properties, true);
            await refreshDependentLookups(dependents[index].field, properties);
        }
    }

    async function loadLookupWaves(properties) {
        const pending = modalFields.filter((item) => item.lookup);
        const loaded = new Set();
        while (loaded.size < pending.length) {
            const wave = pending.filter((item) => {
                if (loaded.has(item.field)) return false;
                return lookupParents(item).every((parent) => {
                    const parentItem = fieldItem(parent.field);
                    return !parentItem || !parentItem.lookup || loaded.has(parent.field);
                });
            });
            if (!wave.length) {
                await Promise.all(pending.filter((item) => !loaded.has(item.field)).map((item) => refreshLookupSelect(item, properties)));
                break;
            }
            await Promise.all(wave.map((item) => refreshLookupSelect(item, properties)));
            wave.forEach((item) => loaded.add(item.field));
        }
    }

    function bindDependentLookups(properties) {
        document.querySelectorAll('#recheck-fields [data-change-value]').forEach((control) => {
            let timer = null;
            let lastCode = resolvedLookupCode(control.dataset.changeValue, properties[control.dataset.changeValue]);
            const onUpdate = () => {
                const code = resolvedLookupCode(control.dataset.changeValue, properties[control.dataset.changeValue]);
                if (!code || code === lastCode) return;
                lastCode = code;
                void refreshDependentLookups(control.dataset.changeValue, properties);
            };
            control.addEventListener('change', onUpdate);
            control.addEventListener('input', () => {
                window.clearTimeout(timer);
                timer = window.setTimeout(onUpdate, 250);
            });
        });
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
        selectedObjectKey = String(featureIdentity(feature, fallback || geometryKey(feature, layerKey)));
        const properties = feature.properties || {};
        const identity = featureIdentity(feature, fallback);
        const title = qmlRenderer && typeof qmlRenderer.popupTitle === 'function'
            ? qmlRenderer.popupTitle(feature)
            : '';
        document.getElementById('recheck-object-caption').textContent = title || ('Объект: ' + identity);
        modalFields = qmlRenderer && typeof qmlRenderer.popupFields === 'function'
            ? qmlRenderer.popupFields(feature, {includeEmptyLookups: true})
            : [];
        const fieldsEl = document.getElementById('recheck-fields');
        if (!modalFields.length) {
            fieldsEl.innerHTML = '<p class="recheck-fields-empty">Нет полей для изменения.</p>';
        } else {
            fieldsEl.innerHTML = modalFields.map((item) => {
                const text = item.value == null ? '' : String(item.value);
                return '<label class="recheck-field"><input type="checkbox" data-change-check="' + escapeHtml(item.field) +
                    '" data-change-label="' + escapeHtml(item.label) + '">' +
                    '<span>' + escapeHtml(item.label) + '</span><code title="' + escapeHtml(text) + '">' + escapeHtml(text) + '</code>' +
                    fieldEditorHtml(item) + '</label>';
            }).join('');
            modalFields.forEach((item) => {
                const input = document.querySelector('#recheck-fields [data-change-value="' + CSS.escape(item.field) + '"]');
                if (!input || !((item.options && item.options.length) || item.lookup)) return;
                fillComboOptions(input, item.options || [], item.rawValue, item.value);
            });
            document.querySelectorAll('#recheck-fields [data-change-check]').forEach((check) => {
                check.addEventListener('change', () => {
                    document.querySelector('[data-change-value="' + CSS.escape(check.dataset.changeCheck) + '"]').disabled = !check.checked;
                });
            });
            bindDependentLookups(properties);
            void loadLookupWaves(properties);
        }
        document.getElementById('recheck-change-error').textContent = '';
        document.getElementById('recheck-change-modal').hidden = false;
    }

    function closeModal() {
        document.getElementById('recheck-change-modal').hidden = true;
        selectedFeature = null;
        selectedLayerKey = '';
        selectedObjectKey = '';
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
                const typed = document.querySelector('[data-change-value="' + CSS.escape(field) + '"]').value;
                let newValue = resolveStoredValue(field, typed, typed);
                if (typeof oldValue === 'number' && String(newValue).trim() !== '' && Number.isFinite(Number(newValue))) {
                    newValue = Number(newValue);
                } else if (typeof oldValue === 'boolean' && /^(true|false)$/i.test(String(newValue).trim())) {
                    newValue = String(newValue).trim().toLowerCase() === 'true';
                } else if (oldValue && typeof oldValue === 'object') {
                    try { newValue = JSON.parse(String(newValue)); } catch (ignore) { /* keep text */ }
                }
                return {
                    field_name: field,
                    field_label: check.dataset.changeLabel || field,
                    old_value: oldValue,
                    new_value: newValue,
                };
            });
            const identity = selectedObjectKey || String(featureIdentity(selectedFeature, geometryKey(selectedFeature, selectedLayerKey)));
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

    function showDbLoadingModal(detailText) {
        const modal = document.getElementById('db-loading-modal');
        const detail = document.getElementById('recheck-db-loading-detail');
        if (detail) detail.textContent = detailText || '';
        if (modal) modal.style.display = 'flex';
    }

    function hideDbLoadingModal() {
        const modal = document.getElementById('db-loading-modal');
        if (modal) modal.style.display = 'none';
    }

    function setMapLoadStatus(text) {
        const el = document.getElementById('recheck-map-status');
        if (!el) return;
        if (!text) {
            el.hidden = true;
            el.textContent = '';
            return;
        }
        el.hidden = false;
        el.textContent = text;
    }

    async function initMap() {
        const mapEl = document.getElementById('recheck-map');
        if (!mapEl || !eventId || typeof L === 'undefined') {
            hideDbLoadingModal();
            return;
        }
        showDbLoadingModal();
        try {
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
                canAction: (feature) => {
                    const props = (feature && feature.properties) || {};
                    return !isPhotoFixLayer(props.layerKey || props.sourceTable || '');
                },
                onAction: (feature) => {
                    const props = feature.properties || {};
                    const layerKey = props.layerKey || props.sourceTable || '';
                    if (isPhotoFixLayer(layerKey)) return;
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
                    showDbLoadingModal(spec.label || spec.key);
                    setMapLoadStatus('Загружаем: ' + (spec.label || spec.key) + '…');
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
                            let html = '<strong>' + escapeHtml(spec.label) + '</strong><br>Объект: ' + escapeHtml(key);
                            if (!isPhotoFixLayer(spec.key)) {
                                html += '<br><button type="button" class="recheck-popup-btn">Запросить изменение</button>';
                            }
                            layer.bindPopup(html);
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
                    setMapLoadStatus(error.message);
                }
            }
            if (bounds.isValid()) map.fitBounds(bounds.pad(0.08));
            if (qmlRenderer) qmlRenderer.refresh();
            setMapLoadStatus(count
                ? 'Загружено объектов: ' + count
                : 'Для задания объекты не найдены.');
        } finally {
            hideDbLoadingModal();
        }
    }

    loadEvent().catch((error) => window.alert(error.message));
    initMap();
})();

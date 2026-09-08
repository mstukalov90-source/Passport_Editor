(function (global) {
    'use strict';

    const PV = global.PassViewer || (global.PassViewer = {});
    const STORAGE_KEY = 'pv-layer-opacity';
    const MAX_OBJECTS = 200;
    const COMMENT_KEY = 'comments';
    const GROUP_KEYS = {
        municipal: ['selected', 'dt', 'oo', 'odh', 'top'],
        requests: ['requests', 'recaps', 'comments'],
        dgi: [
            'dgi_moscow_rent',
            'dgi_moscow_no_rent',
            'dgi_private_rent',
            'dgi_private_no_rent',
            'dgi_renovation',
        ],
        external: ['renew', 'oozt', 'rzd'],
    };
    const GROUP_NAMES = Object.keys(GROUP_KEYS);

    let mapRef = null;
    let managedLayers = {};
    let opacityRatio = 1;
    let groupRatios = {
        municipal: 1,
        requests: 1,
        dgi: 1,
        external: 1,
    };

    function getCookie(name) {
        return PV.getCookie ? PV.getCookie(name) : '';
    }

    function escapeHtml(value) {
        return PV.escapeHtml ? PV.escapeHtml(String(value ?? '')) : String(value ?? '');
    }

    function clampStoredPercent(raw) {
        const n = Number(raw);
        if (Number.isFinite(n) && n >= 15 && n <= 100) {
            return n / 100;
        }
        return 1;
    }

    function readStoredOpacity() {
        try {
            return clampStoredPercent(window.localStorage.getItem(STORAGE_KEY));
        } catch (_err) {
            return 1;
        }
    }

    function readStoredGroupOpacity(group) {
        try {
            const grouped = window.localStorage.getItem(STORAGE_KEY + '-' + group);
            if (grouped != null) {
                return clampStoredPercent(grouped);
            }
        } catch (_err) {
            /* ignore */
        }
        return readStoredOpacity();
    }

    function writeStoredOpacity(ratio) {
        try {
            window.localStorage.setItem(STORAGE_KEY, String(Math.round(ratio * 100)));
        } catch (_err) {
            /* ignore */
        }
    }

    function writeStoredGroupOpacity(group, ratio) {
        try {
            window.localStorage.setItem(STORAGE_KEY + '-' + group, String(Math.round(ratio * 100)));
        } catch (_err) {
            /* ignore */
        }
    }

    function keyToGroup(layerKey) {
        for (let i = 0; i < GROUP_NAMES.length; i += 1) {
            const name = GROUP_NAMES[i];
            if (GROUP_KEYS[name].indexOf(layerKey) !== -1) {
                return name;
            }
        }
        return null;
    }

    function ratioForKey(layerKey) {
        const group = keyToGroup(layerKey);
        const ratio = group ? groupRatios[group] : opacityRatio;
        if (layerKey === COMMENT_KEY) {
            return Math.min(1, ratio + 0.25);
        }
        return ratio;
    }

    function eachFeatureLayer(group, cb) {
        if (!group || typeof group.eachLayer !== 'function') {
            return;
        }
        group.eachLayer((layer) => {
            if (layer && layer.feature) {
                cb(layer);
            } else if (layer && typeof layer.eachLayer === 'function') {
                eachFeatureLayer(layer, cb);
            }
        });
    }

    function meaningfulProp(value) {
        const text = String(value ?? '').trim();
        if (!text || ['-', 'null', 'none'].includes(text.toLowerCase())) {
            return '';
        }
        return text;
    }

    function featureId(layer, index) {
        const props = (layer && layer.feature && layer.feature.properties) || {};
        const parts = [
            props.descr,
            props.rootid,
            props.request_id,
            props.name,
            props.recap_id,
            layer && layer._leaflet_id,
            index,
        ];
        return parts.filter((part) => part != null && String(part).trim() !== '').join(':') || String(index);
    }

    function featureLabel(layer, index) {
        const props = (layer && layer.feature && layer.feature.properties) || {};
        return (
            meaningfulProp(props.descr) ||
            meaningfulProp(props.name) ||
            meaningfulProp(props.rootid) ||
            meaningfulProp(props.request_id) ||
            meaningfulProp(props.nomer1) ||
            'Полигон ' + (index + 1)
        );
    }

    function applySignalTapeOpacity(layer, ratio, hidden) {
        if (typeof layer._passViewerRestoreDgiDom !== 'function') {
            return false;
        }
        if (!hidden) {
            layer._passViewerRestoreDgiDom();
        }
        const el = layer.getElement && layer.getElement();
        if (!el) {
            return true;
        }
        el.setAttribute('fill-opacity', hidden ? '0' : String(0.25 * Math.max(ratio, 0)));
        el.setAttribute('stroke-opacity', hidden ? '0' : String(Math.min(1, Math.max(ratio, 0.35))));
        el.style.pointerEvents = hidden ? 'none' : '';
        return true;
    }

    function applyLayerOpacity(layer, ratio, hidden) {
        if (!layer) {
            return;
        }
        if (applySignalTapeOpacity(layer, ratio, hidden)) {
            return;
        }
        if (typeof layer.setOpacity === 'function' && !layer.setStyle) {
            layer.setOpacity(hidden ? 0 : ratio);
            return;
        }
        if (typeof layer.setStyle !== 'function') {
            return;
        }
        const opt = layer.options || {};
        const baseFill = typeof opt.fillOpacity === 'number' ? opt.fillOpacity : 0.25;
        const baseOp = typeof opt.opacity === 'number' ? opt.opacity : 1;
        if (layer._panelBaseFill == null) {
            layer._panelBaseFill = baseFill;
            layer._panelBaseOp = baseOp;
        }
        if (hidden) {
            layer.setStyle({ opacity: 0, fillOpacity: 0 });
            return;
        }
        layer.setStyle({
            opacity: Math.min(1, layer._panelBaseOp * Math.max(ratio, 0.35)),
            fillOpacity: layer._panelBaseFill * ratio,
        });
    }

    function applyAllOpacity() {
        Object.keys(managedLayers).forEach((key) => {
            const group = managedLayers[key];
            const ratio = ratioForKey(key);
            eachFeatureLayer(group, (layer) => {
                applyLayerOpacity(layer, ratio, !!layer._panelHidden);
            });
        });
    }

    function rebuildObjectLists() {
        const panel = document.getElementById('layer-management-panel');
        if (!panel) {
            return;
        }
        panel.querySelectorAll('.layer-panel-row').forEach((row) => {
            const checkbox = row.querySelector('input[data-layer-key]');
            const list = row.querySelector('.layer-panel-objects');
            if (!checkbox || !list) {
                return;
            }
            const key = checkbox.dataset.layerKey;
            const group = managedLayers[key];
            const items = [];
            eachFeatureLayer(group, (layer) => {
                if (items.length >= MAX_OBJECTS) {
                    return;
                }
                items.push(layer);
            });
            const open = row.classList.contains('is-open');
            list.innerHTML = items
                .map((layer, index) => {
                    const id = featureId(layer, index);
                    const checked = layer._panelHidden ? '' : ' checked';
                    return (
                        '<li class="layer-panel-object">' +
                        '<input type="checkbox" class="layer-panel-object-toggle" data-layer-key="' +
                        escapeHtml(key) +
                        '" data-object-id="' +
                        escapeHtml(id) +
                        '"' +
                        checked +
                        '>' +
                        '<span class="layer-panel-object__name">' +
                        escapeHtml(featureLabel(layer, index)) +
                        '</span></li>'
                    );
                })
                .join('');
            if (items.length === 0) {
                list.innerHTML = '<li class="layer-panel-object"><span class="layer-panel-object__name">Нет загруженных объектов</span></li>';
            }
            list.hidden = !open;
            list.querySelectorAll('.layer-panel-object-toggle').forEach((input) => {
                input.addEventListener('change', () => {
                    toggleObject(input.dataset.layerKey, input.dataset.objectId, input.checked);
                });
            });
        });
    }

    function toggleObject(layerKey, objectId, visible) {
        const group = managedLayers[layerKey];
        let index = 0;
        eachFeatureLayer(group, (layer) => {
            const id = featureId(layer, index);
            index += 1;
            if (id !== objectId) {
                return;
            }
            layer._panelHidden = !visible;
            applyLayerOpacity(layer, ratioForKey(layerKey), !visible);
        });
    }

    function bindExpandButtons() {
        const panel = document.getElementById('layer-management-panel');
        if (!panel || panel._pvExpandBound) {
            return;
        }
        panel._pvExpandBound = true;
        panel.addEventListener('click', (event) => {
            const btn = event.target.closest('.layer-panel-row__expand');
            if (!btn || !panel.contains(btn)) {
                return;
            }
            event.preventDefault();
            event.stopPropagation();
            const row = btn.closest('.layer-panel-row');
            const list = row && row.querySelector('.layer-panel-objects');
            if (!row || !list) {
                return;
            }
            const open = row.classList.toggle('is-open');
            btn.setAttribute('aria-expanded', open ? 'true' : 'false');
            list.hidden = !open;
            if (open) {
                rebuildObjectLists();
            }
        });
    }

    function bindOpacitySlider() {
        const panel = document.getElementById('layer-management-panel');
        const header = document.getElementById('layer-opacity-slider');
        opacityRatio = readStoredOpacity();
        GROUP_NAMES.forEach((name) => {
            groupRatios[name] = readStoredGroupOpacity(name);
        });
        if (header) {
            header.value = String(Math.round(opacityRatio * 100));
            header.addEventListener('input', () => {
                opacityRatio = Number(header.value) / 100;
                writeStoredOpacity(opacityRatio);
                GROUP_NAMES.forEach((name) => {
                    groupRatios[name] = opacityRatio;
                    writeStoredGroupOpacity(name, opacityRatio);
                    const input =
                        panel && panel.querySelector('[data-layer-opacity-group="' + name + '"]');
                    if (input) {
                        input.value = header.value;
                    }
                });
                applyAllOpacity();
            });
        }
        if (!panel) {
            return;
        }
        panel.querySelectorAll('[data-layer-opacity-group]').forEach((input) => {
            const name = input.dataset.layerOpacityGroup;
            if (!GROUP_KEYS[name]) {
                return;
            }
            input.value = String(Math.round(groupRatios[name] * 100));
            input.addEventListener('input', () => {
                groupRatios[name] = Number(input.value) / 100;
                writeStoredGroupOpacity(name, groupRatios[name]);
                applyAllOpacity();
            });
        });
    }

    PV.LayerPanel = {
        init(opts) {
            mapRef = opts.map || null;
            managedLayers = opts.managedLayers || {};
            if (mapRef) {
                PV._editorMap = mapRef;
                mapRef.getContainer()._leaflet_map = mapRef;
            }
            bindExpandButtons();
            bindOpacitySlider();
            applyAllOpacity();
            rebuildObjectLists();
            window.requestAnimationFrame(applyAllOpacity);
        },
        refresh() {
            applyAllOpacity();
            rebuildObjectLists();
            window.requestAnimationFrame(applyAllOpacity);
        },
    };

    void getCookie;
})(window);

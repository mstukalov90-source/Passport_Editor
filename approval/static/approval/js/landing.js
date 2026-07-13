(function () {
    'use strict';

    function readJsonScript(id) {
        const el = document.getElementById(id);
        if (!el || !el.textContent) {
            return null;
        }
        try {
            return JSON.parse(el.textContent);
        } catch (e) {
            return null;
        }
    }

    function getCookie(name) {
        const cookieValue = document.cookie.split('; ').find(function (row) {
            return row.startsWith(name + '=');
        });
        return cookieValue ? decodeURIComponent(cookieValue.split('=')[1]) : null;
    }

    function apiUrl(template, params) {
        let url = template;
        Object.keys(params || {}).forEach(function (key) {
            url = url.replace('{' + key + '}', encodeURIComponent(params[key]));
        });
        return url;
    }

    let map = null;
    let managedLayers = {};
    let eventGeometriesGroup = null;
    let geometryLayerByKey = {};
    let activeCaseId = null;
    let activeMessageGeometryId = null;
    let pendingGeometryGeoJson = null;
    const PENDING_LAYER_KEY = 'pending:draft';
    let layerStylesManifest = null;
    let layerStyleIconsBase = '/static/approval/icons/svg/';
    let svgIndex = null;
    const SVG_MARKER_SIZE_SCALE = 2;
    const CIRCLE_MARKER_SIZE_SCALE = 1.5;

    function getSvgIndex() {
        if (svgIndex) {
            return svgIndex;
        }
        svgIndex = readJsonScript('approval-svg-index') || {};
        return svgIndex;
    }

    function normalizeSvgLookupKey(raw) {
        if (!raw) {
            return null;
        }
        const normalized = String(raw).replace(/\\/g, '/');
        const marker = '/svg/';
        const svgPos = normalized.lastIndexOf(marker);
        let rel = svgPos >= 0 ? normalized.slice(svgPos + marker.length) : normalized;
        rel = rel.replace(/^\/+/, '');
        if (!rel || rel.indexOf('.svg') === -1) {
            return null;
        }
        return rel;
    }

    function resolveSvgRelativePath(raw) {
        const rel = normalizeSvgLookupKey(raw);
        if (!rel) {
            return null;
        }
        const index = getSvgIndex();
        if (index[rel]) {
            return index[rel];
        }
        const basename = rel.split('/').pop();
        if (basename && index[basename]) {
            return index[basename];
        }
        if (typeof basename.normalize === 'function') {
            const nfcBasename = basename.normalize('NFC');
            if (nfcBasename && index[nfcBasename]) {
                return index[nfcBasename];
            }
        }
        if (typeof rel.normalize === 'function') {
            const nfcRel = rel.normalize('NFC');
            if (nfcRel && index[nfcRel]) {
                return index[nfcRel];
            }
        }
        return null;
    }

    function encodeSvgPath(relativePath) {
        return relativePath.split('/').map(encodeURIComponent).join('/');
    }

    function invalidateMapSize() {
        if (!map) {
            return;
        }
        window.requestAnimationFrame(function () {
            map.invalidateSize();
        });
    }

    function hashColor(value) {
        let hash = 0;
        const text = String(value || 'work');
        for (let i = 0; i < text.length; i += 1) {
            hash = text.charCodeAt(i) + ((hash << 5) - hash);
        }
        const hue = Math.abs(hash) % 360;
        return {
            stroke: 'hsl(' + hue + ', 55%, 35%)',
            fill: 'hsla(' + hue + ', 70%, 55%, 0.35)',
        };
    }

    function getLayerStylesManifest() {
        if (layerStylesManifest) {
            return layerStylesManifest;
        }
        layerStylesManifest = readJsonScript('approval-work-layer-styles') || { tables: {} };
        return layerStylesManifest;
    }

    function getTableStyleDef(layerKey) {
        const manifest = getLayerStylesManifest();
        return (manifest.tables || {})[layerKey] || null;
    }

    function propertyValue(props, field) {
        if (!field || !props) {
            return null;
        }
        const value = props[field];
        if (value === undefined || value === null || value === '') {
            return null;
        }
        return value;
    }

    function matchFilter(props, filter) {
        if (!filter) {
            return true;
        }
        const value = propertyValue(props, filter.field);
        if (filter.type === 'eq') {
            return String(value) === String(filter.value);
        }
        if (filter.type === 'null') {
            return value === null;
        }
        if (filter.type === 'not_null') {
            return value !== null;
        }
        return false;
    }

    function resolveRuleStyle(layerKey, props) {
        const tableDef = getTableStyleDef(layerKey);
        if (!tableDef || !Array.isArray(tableDef.rules) || !tableDef.rules.length) {
            return null;
        }
        for (let i = 0; i < tableDef.rules.length; i += 1) {
            const rule = tableDef.rules[i];
            if (matchFilter(props, rule.filter)) {
                return rule.style || null;
            }
        }
        const defaultIdx = tableDef.defaultRule;
        if (typeof defaultIdx === 'number' && tableDef.rules[defaultIdx]) {
            return tableDef.rules[defaultIdx].style || null;
        }
        return tableDef.rules[tableDef.rules.length - 1].style || null;
    }

    function svgIconUrl(style, props) {
        if (!style) {
            return null;
        }
        let raw = style.svg || null;
        const svgField = style.svgField;
        if (svgField) {
            const fromProps = propertyValue(props, svgField);
            if (fromProps) {
                raw = fromProps;
            }
        }
        if (!raw) {
            return null;
        }
        const resolved = resolveSvgRelativePath(raw);
        if (!resolved) {
            return null;
        }
        return layerStyleIconsBase + encodeSvgPath(resolved);
    }

    function leafletPathStyle(style, layerKey, geometryType) {
        if (!style) {
            const colors = hashColor(layerKey);
            if (geometryType === 'line') {
                return { color: colors.stroke, weight: 2, opacity: 0.9 };
            }
            return {
                color: colors.stroke,
                weight: 2,
                fillColor: colors.fill,
                fillOpacity: 0.55,
            };
        }

        const pathStyle = {};
        if (style.color) {
            pathStyle.color = style.color;
            pathStyle.opacity = style.opacity !== undefined ? style.opacity : 1;
        }
        if (style.fillColor) {
            pathStyle.fillColor = style.fillColor;
            pathStyle.fillOpacity = style.fillOpacity !== undefined ? style.fillOpacity : 0.55;
        }
        if (style.weight !== undefined) {
            pathStyle.weight = style.weight;
        }
        if (style.dashArray) {
            pathStyle.dashArray = style.dashArray;
        }
        if (!pathStyle.color && style.fillColor) {
            pathStyle.color = style.fillColor;
        }
        if (!pathStyle.fillColor && geometryType === 'polygon') {
            pathStyle.fillColor = style.color || '#94a3b8';
            pathStyle.fillOpacity = pathStyle.fillOpacity || 0.45;
        }
        return pathStyle;
    }

    function styleTableKey(props) {
        return props.sourceTable || props.layerKey || 'work';
    }

    function adjacentLayerLabel(layerKey) {
        if (layerKey === 'adjacent_approval') {
            return 'Смежный объект для согласования';
        }
        if (layerKey === 'adjacent_objects') {
            return 'Смежные объекты';
        }
        return null;
    }

    function styleFeature(feature) {
        const props = feature.properties || {};
        const styleKey = styleTableKey(props);
        const displayKey = props.layerKey || props.sourceTable || 'work';
        const geometry = feature.geometry || {};
        const type = geometry.type || '';
        const tableDef = getTableStyleDef(styleKey);
        const geometryType = tableDef ? tableDef.geometry : null;

        if (type === 'Point' || type === 'MultiPoint') {
            return {};
        }
        if (type === 'LineString' || type === 'MultiLineString') {
            return leafletPathStyle(resolveRuleStyle(styleKey, props), displayKey, geometryType || 'line');
        }
        return leafletPathStyle(resolveRuleStyle(styleKey, props), displayKey, geometryType || 'polygon');
    }

    function featureTooltip(feature) {
        const props = feature.properties || {};
        const parts = [];
        const panelLayerKey = props.layerKey;
        const adjacentLabel = adjacentLayerLabel(panelLayerKey);
        if (adjacentLabel) {
            parts.push(adjacentLabel);
        }
        const styleKey = styleTableKey(props);
        const tableDef = styleKey ? getTableStyleDef(styleKey) : null;
        if (!adjacentLabel) {
            if (tableDef && tableDef.label) {
                parts.push(tableDef.label);
            } else if (props.sourceTable) {
                parts.push(props.sourceTable);
            }
        }
        if (props.Name) {
            parts.push(props.Name);
        }
        if (props.RootId) {
            parts.push('RootId: ' + props.RootId);
        }
        if (props.caseTitle) {
            parts.push(props.caseTitle);
        }
        if (props.fid !== undefined && props.fid !== null && props.fid !== '') {
            parts.push('fid: ' + props.fid);
        }
        return parts.join(' · ') || 'объект';
    }

    function pointToLayer(feature, latlng) {
        const props = feature.properties || {};
        const styleKey = styleTableKey(props);
        const displayKey = props.layerKey || props.sourceTable || 'work';
        const ruleStyle = resolveRuleStyle(styleKey, props);
        const iconUrl = svgIconUrl(ruleStyle, props);
        if (iconUrl) {
            const baseSize = ruleStyle && ruleStyle.iconSize ? ruleStyle.iconSize : 18;
            const size = Math.round(baseSize * SVG_MARKER_SIZE_SCALE);
            return L.marker(latlng, {
                icon: L.icon({
                    iconUrl: iconUrl,
                    iconSize: [size, size],
                    iconAnchor: [size / 2, size / 2],
                }),
            }).bindTooltip(featureTooltip(feature), { sticky: true });
        }

        const colors = hashColor(displayKey);
        const baseRadius = (ruleStyle && ruleStyle.radius) || 5;
        const radius = Math.round(baseRadius * CIRCLE_MARKER_SIZE_SCALE);
        const stroke = (ruleStyle && ruleStyle.color) || colors.stroke;
        const fill = (ruleStyle && ruleStyle.fillColor) || colors.fill;
        const fillOpacity = (ruleStyle && ruleStyle.fillOpacity) || 0.85;
        return L.circleMarker(latlng, {
            radius: radius,
            color: stroke,
            weight: 2,
            fillColor: fill,
            fillOpacity: fillOpacity,
        }).bindTooltip(featureTooltip(feature), { sticky: true });
    }

    function ensureLayerGroup(layerKey) {
        if (!managedLayers[layerKey]) {
            managedLayers[layerKey] = L.featureGroup();
            if (map) {
                managedLayers[layerKey].addTo(map);
            }
        }
        return managedLayers[layerKey];
    }

    function setLayerVisible(layerKey, isVisible) {
        const group = managedLayers[layerKey];
        if (!group || !map) {
            return;
        }
        if (isVisible) {
            if (!map.hasLayer(group)) {
                group.addTo(map);
            }
        } else if (map.hasLayer(group)) {
            map.removeLayer(group);
        }
    }

    function fitVisibleBounds() {
        if (!map) {
            return;
        }
        const boundsGroup = L.featureGroup();
        Object.keys(managedLayers).forEach(function (layerKey) {
            const group = managedLayers[layerKey];
            const checkbox = document.querySelector('input[data-layer-key="' + layerKey + '"]');
            const isVisible = !checkbox || checkbox.checked;
            if (isVisible && group && map.hasLayer(group)) {
                boundsGroup.addLayer(group);
            }
        });
        const bounds = boundsGroup.getBounds();
        if (bounds.isValid()) {
            map.fitBounds(bounds.pad(0.12));
        }
    }

    function initLayerPanelControls(config) {
        const layerGroupMap = (config && config.layerGroups) || {};
        const layerCheckboxes = Array.from(document.querySelectorAll('input[data-layer-key]'));
        const groupCheckboxes = Array.from(document.querySelectorAll('input[data-layer-group]'));

        layerCheckboxes.forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                setLayerVisible(checkbox.dataset.layerKey, checkbox.checked);
            });
        });

        groupCheckboxes.forEach(function (groupCheckbox) {
            groupCheckbox.addEventListener('change', function () {
                const groupKeys = layerGroupMap[groupCheckbox.dataset.layerGroup] || [];
                groupKeys.forEach(function (layerKey) {
                    setLayerVisible(layerKey, groupCheckbox.checked);
                    const layerCheckbox = document.querySelector(
                        'input[data-layer-key="' + layerKey + '"]'
                    );
                    if (layerCheckbox) {
                        layerCheckbox.checked = groupCheckbox.checked;
                    }
                });
            });
        });
    }

    function geometryStyle(layerKey, isActive) {
        const colors = hashColor(layerKey);
        return {
            color: isActive ? '#dc2626' : colors.stroke,
            weight: isActive ? 4 : 2,
            fillColor: colors.fill,
            fillOpacity: isActive ? 0.45 : 0.3,
        };
    }

    function eventStyle(caseId, isActive) {
        return geometryStyle(caseId, isActive);
    }

    function geometryLayerKey(kind, id) {
        return kind + ':' + id;
    }

    function pendingGeometryStyle() {
        return {
            color: '#7c3aed',
            weight: 3,
            dashArray: '8 6',
            fillColor: '#7c3aed',
            fillOpacity: 0.15,
        };
    }

    function applyStyleToGeometryLayer(layer, layerKey, isActive) {
        const style =
            layerKey === PENDING_LAYER_KEY
                ? pendingGeometryStyle()
                : geometryStyle(layerKey, isActive);
        layer.eachLayer(function (child) {
            if (typeof child.setRadius === 'function') {
                child.setStyle(style);
                child.setRadius(
                    layerKey === PENDING_LAYER_KEY ? 7 : isActive ? 8 : 6
                );
            } else if (typeof child.setStyle === 'function') {
                child.setStyle(style);
            }
        });
    }

    function removePendingGeometryLayer() {
        const layer = geometryLayerByKey[PENDING_LAYER_KEY];
        if (layer && eventGeometriesGroup) {
            eventGeometriesGroup.removeLayer(layer);
        }
        delete geometryLayerByKey[PENDING_LAYER_KEY];
        pendingGeometryGeoJson = null;
    }

    function setPendingMessageGeometry(geometry) {
        if (!map || !eventGeometriesGroup || !geometry) {
            return;
        }
        removePendingGeometryLayer();
        pendingGeometryGeoJson = geometry;
        const feature = {
            type: 'Feature',
            geometry: geometry,
            properties: {
                layerKey: PENDING_LAYER_KEY,
            },
        };
        const layer = L.geoJSON(feature, {
            style: function () {
                return pendingGeometryStyle();
            },
            pointToLayer: function (_feat, latlng) {
                return L.circleMarker(latlng, {
                    radius: 7,
                    color: '#7c3aed',
                    weight: 3,
                    dashArray: '8 6',
                    fillColor: 'rgba(124, 58, 237, 0.35)',
                    fillOpacity: 0.9,
                }).bindTooltip('Черновик геометрии', { sticky: true });
            },
            onEachFeature: function (_feat, lyr) {
                lyr.bindTooltip('Черновик геометрии', { sticky: true });
            },
        });
        geometryLayerByKey[PENDING_LAYER_KEY] = layer;
        layer.addTo(eventGeometriesGroup);
    }

    function clearPendingMessageGeometry() {
        removePendingGeometryLayer();
    }

    function getPendingMessageGeometry() {
        return pendingGeometryGeoJson;
    }

    function addGeometryLayer(layerKey, geometry, tooltip, isActive) {
        if (!map || !eventGeometriesGroup || !geometry) {
            return;
        }
        const feature = {
            type: 'Feature',
            geometry: geometry,
            properties: {
                layerKey: layerKey,
            },
        };
        const layer = L.geoJSON(feature, {
            style: function () {
                return geometryStyle(layerKey, isActive);
            },
            pointToLayer: function (_feat, latlng) {
                return L.circleMarker(latlng, {
                    radius: isActive ? 8 : 6,
                    color: isActive ? '#dc2626' : '#7c3aed',
                    weight: 2,
                    fillColor: 'rgba(124, 58, 237, 0.5)',
                    fillOpacity: 0.9,
                }).bindTooltip(tooltip || 'геометрия', { sticky: true });
            },
            onEachFeature: function (_feat, lyr) {
                if (tooltip) {
                    lyr.bindTooltip(tooltip, { sticky: true });
                }
            },
        });
        geometryLayerByKey[layerKey] = layer;
        layer.addTo(eventGeometriesGroup);
    }

    function clearSavedGeometries() {
        const pendingLayer = geometryLayerByKey[PENDING_LAYER_KEY];
        const savedKeys = Object.keys(geometryLayerByKey).filter(function (key) {
            return key !== PENDING_LAYER_KEY;
        });
        savedKeys.forEach(function (key) {
            delete geometryLayerByKey[key];
        });
        if (eventGeometriesGroup) {
            eventGeometriesGroup.clearLayers();
            Object.keys(geometryLayerByKey).forEach(function (key) {
                const layer = geometryLayerByKey[key];
                if (layer) {
                    layer.addTo(eventGeometriesGroup);
                }
            });
        }
        if (pendingLayer && !geometryLayerByKey[PENDING_LAYER_KEY]) {
            geometryLayerByKey[PENDING_LAYER_KEY] = pendingLayer;
            pendingLayer.addTo(eventGeometriesGroup);
        }
    }

    function clearEventGeometries() {
        geometryLayerByKey = {};
        pendingGeometryGeoJson = null;
        if (eventGeometriesGroup) {
            eventGeometriesGroup.clearLayers();
        }
    }

    function renderGeometries(caseItem) {
        if (!map || !eventGeometriesGroup) {
            return;
        }
        clearSavedGeometries();
        activeMessageGeometryId = null;
        if (!caseItem) {
            return;
        }

        if (caseItem.geometry) {
            const caseKey = geometryLayerKey('case', caseItem.id);
            let label = caseItem.title || 'событие';
            if (caseItem.n_root) {
                label = 'Паспорт ' + caseItem.n_root + ': ' + label;
            }
            addGeometryLayer(caseKey, caseItem.geometry, label, false);
        }

        (caseItem.messages || []).forEach(function (message) {
            if (!message.geometry) {
                return;
            }
            const messageKey = geometryLayerKey('message', message.id);
            addGeometryLayer(
                messageKey,
                message.geometry,
                'Геометрия сообщения',
                false
            );
        });
    }

    function renderEventGeometries(cases) {
        const activeCase = (cases || []).find(function (caseItem) {
            return caseItem.id === activeCaseId;
        });
        if (activeCase) {
            renderGeometries(activeCase);
        } else {
            clearEventGeometries();
        }
    }

    function refreshGeometryStyles() {
        Object.keys(geometryLayerByKey).forEach(function (layerKey) {
            const layer = geometryLayerByKey[layerKey];
            if (!layer) {
                return;
            }
            const isActive =
                layerKey === geometryLayerKey('case', activeCaseId) ||
                layerKey === geometryLayerKey('message', activeMessageGeometryId);
            applyStyleToGeometryLayer(layer, layerKey, isActive);
        });
    }

    function highlightCase(caseId) {
        activeCaseId = caseId || null;
        refreshGeometryStyles();
    }

    function highlightMessageGeometry(messageId) {
        activeMessageGeometryId = messageId || null;
        refreshGeometryStyles();
    }

    function fitGeometryLayer(layerKey) {
        const layer = geometryLayerByKey[layerKey];
        if (!layer || !map) {
            return;
        }
        const bounds = layer.getBounds();
        if (!bounds.isValid()) {
            return;
        }
        const northEast = bounds.getNorthEast();
        const southWest = bounds.getSouthWest();
        if (northEast.lat === southWest.lat && northEast.lng === southWest.lng) {
            map.setView(bounds.getCenter(), Math.max(map.getZoom(), 17));
            return;
        }
        map.fitBounds(bounds.pad(0.2));
    }

    function fitCaseGeometry(caseId) {
        fitGeometryLayer(geometryLayerKey('case', caseId));
    }

    function fitMessageGeometry(messageId) {
        fitGeometryLayer(geometryLayerKey('message', messageId));
    }

    function initMap() {
        const config = readJsonScript('page-config') || {};
        const mapGeojson = readJsonScript('approval-map-geojson');
        const mapElementId = config.mapElementId || 'approval-map';
        const mapEl = document.getElementById(mapElementId);
        if (!mapEl || typeof L === 'undefined') {
            return;
        }

        if (config.layerStyleIconsBase) {
            layerStyleIconsBase = config.layerStyleIconsBase;
        }
        getLayerStylesManifest();

        const center = Array.isArray(config.center) ? config.center : [55.75, 37.61];
        const defaultZoom = Number(config.defaultZoom) || 10;

        map = L.map(mapElementId, {
            zoomControl: true,
            attributionControl: true,
        }).setView(center, defaultZoom);

        map.attributionControl.setPrefix(
            '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>'
        );

        managedLayers = {};
        eventGeometriesGroup = L.featureGroup().addTo(map);

        function onEachFeature(feature, layer) {
            layer.bindTooltip(featureTooltip(feature), { sticky: true });
        }

        if (mapGeojson && Array.isArray(mapGeojson.features)) {
            mapGeojson.features.forEach(function (feature) {
                const props = feature.properties || {};
                const layerKey = props.layerKey || props.sourceTable;
                if (!layerKey) {
                    return;
                }
                const targetGroup = ensureLayerGroup(layerKey);
                const checkbox = document.querySelector('input[data-layer-key="' + layerKey + '"]');
                const isVisible = !checkbox || checkbox.checked;

                L.geoJSON(feature, {
                    style: styleFeature,
                    onEachFeature: onEachFeature,
                    pointToLayer: pointToLayer,
                }).eachLayer(function (layer) {
                    targetGroup.addLayer(layer);
                });

                if (!isVisible) {
                    setLayerVisible(layerKey, false);
                }
            });
        }

        initLayerPanelControls(config);
        fitVisibleBounds();
    }

    function initLayerPanelToggle() {
        const panel = document.getElementById('approval-layer-panel');
        const layersAside = document.getElementById('approval-panel-layers');
        const workspace = document.querySelector('.approval-workspace');
        const toggle = document.getElementById('approval-layer-panel-toggle');
        if (!panel || !toggle) {
            return;
        }

        toggle.addEventListener('click', function () {
            const collapsed = panel.classList.toggle('is-collapsed');
            if (layersAside) {
                layersAside.classList.toggle('is-collapsed', collapsed);
            }
            if (workspace) {
                workspace.classList.toggle('approval-workspace--layers-collapsed', collapsed);
            }
            toggle.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
            toggle.title = collapsed ? 'Развернуть панель слоёв' : 'Свернуть панель слоёв';
            invalidateMapSize();
            window.setTimeout(invalidateMapSize, 120);
        });
    }

    initLayerPanelToggle();
    initMap();

    window.addEventListener('load', invalidateMapSize);
    window.addEventListener('resize', invalidateMapSize);

    window.ApprovalMap = {
        getMap: function () {
            return map;
        },
        getEventGeometriesGroup: function () {
            return eventGeometriesGroup;
        },
        renderEventGeometries: renderEventGeometries,
        renderGeometries: renderGeometries,
        highlightCase: highlightCase,
        highlightMessageGeometry: highlightMessageGeometry,
        fitCaseGeometry: fitCaseGeometry,
        fitMessageGeometry: fitMessageGeometry,
        setPendingMessageGeometry: setPendingMessageGeometry,
        clearPendingMessageGeometry: clearPendingMessageGeometry,
        getPendingMessageGeometry: getPendingMessageGeometry,
        invalidateMapSize: invalidateMapSize,
        getConfig: function () {
            return readJsonScript('page-config') || {};
        },
        getCookie: getCookie,
        apiUrl: apiUrl,
    };
})();

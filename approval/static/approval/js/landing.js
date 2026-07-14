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
    let svgHotspots = null;
    let layerStackOrder = [];
    const adjacentFeatureRegistry = {};
    let activeAdjacentNRoot = '';
    const ADJACENT_ACTIVE_STROKE_SOFT = '#fde68a';
    const ADJACENT_ACTIVE_STROKE_STRONG = '#ca8a04';
    const ADJACENT_ACTIVE_WEIGHT = 4;
    const ADJACENT_PULSE_PERIOD_MS = 2800;
    let adjacentPulseRaf = null;
    let adjacentPulseStart = 0;
    const MM_MARKER_SIZE_SCALE = 1;
    const CIRCLE_MARKER_SIZE_SCALE = 1.5;
    /** Visual multiplier for MapUnit markers (zoom scaling preserved). */
    const MAP_UNIT_VISUAL_SCALE = 2;
    const MAP_UNIT_MARKER_MIN_PX = 20;
    const MAP_UNIT_MARKER_MAX_PX = 128;
    let mapUnitMarkers = [];

    function getSvgIndex() {
        if (svgIndex) {
            return svgIndex;
        }
        svgIndex = readJsonScript('approval-svg-index') || {};
        return svgIndex;
    }

    function getSvgHotspots() {
        if (svgHotspots) {
            return svgHotspots;
        }
        svgHotspots = readJsonScript('approval-svg-hotspots') || {};
        return svgHotspots;
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

    function isUnknownSvgPath(resolvedPath) {
        if (!resolvedPath) {
            return false;
        }
        const basename = resolvedPath.split('/').pop() || '';
        return basename.indexOf('Неизвестн') === 0;
    }

    function photoFixIconUrl() {
        const resolved = resolveSvgRelativePath('Фотофиксация.svg');
        if (!resolved) {
            return null;
        }
        return layerStyleIconsBase + encodeSvgPath(resolved);
    }

    function clampNumber(value, min, max) {
        return Math.max(min, Math.min(max, value));
    }

    function estimateMetersToPixels(meters, lat, zoom) {
        if (!map || !Number.isFinite(Number(meters))) {
            return MAP_UNIT_MARKER_MIN_PX;
        }
        const latitude = Number.isFinite(Number(lat)) ? Number(lat) : map.getCenter().lat;
        const z = Number.isFinite(Number(zoom)) ? Number(zoom) : map.getZoom();
        const metersPerPixel =
            (156543.03392 * Math.cos((latitude * Math.PI) / 180)) / Math.pow(2, z);
        if (!Number.isFinite(metersPerPixel) || metersPerPixel <= 0) {
            return MAP_UNIT_MARKER_MIN_PX;
        }
        const px = Number(meters) / metersPerPixel;
        return Number.isFinite(px) ? px : MAP_UNIT_MARKER_MIN_PX;
    }

    function resolveMarkerPixelSize(latlng, sizeValue, sizeUnit, zoom) {
        const raw = Number(sizeValue);
        if (sizeUnit === 'MapUnit') {
            const meters = Number.isFinite(raw) && raw > 0 ? raw : 14;
            // Mercator zoom formula at every zoom level — avoids mid-animation layer
            // projection drift that made markers look off-center.
            const scaled =
                estimateMetersToPixels(meters, latlng && latlng.lat, zoom) * MAP_UNIT_VISUAL_SCALE;
            return Math.round(clampNumber(scaled, MAP_UNIT_MARKER_MIN_PX, MAP_UNIT_MARKER_MAX_PX));
        }
        const screenPx = (Number.isFinite(raw) && raw > 0 ? raw : 18) * MM_MARKER_SIZE_SCALE;
        return Math.round(clampNumber(screenPx, 10, 64));
    }

    function clampFraction(value, fallback) {
        const n = Number(value);
        if (!Number.isFinite(n)) {
            return fallback;
        }
        return Math.min(1, Math.max(0, n));
    }

    function enumAnchorToFraction(axis, name) {
        const raw = String(name || '')
            .trim()
            .toLowerCase()
            .replace(/[_-]+/g, ' ');
        if (axis === 'x') {
            if (raw === 'left' || raw === '0') {
                return 0;
            }
            if (raw === 'right' || raw === '2') {
                return 1;
            }
            if (
                raw === 'center' ||
                raw === 'hcenter' ||
                raw === 'h center' ||
                raw === 'horizontal center' ||
                raw === '1'
            ) {
                return 0.5;
            }
            return null;
        }
        if (raw === 'top' || raw === '0') {
            return 0;
        }
        if (raw === 'bottom' || raw === '2') {
            return 1;
        }
        if (
            raw === 'center' ||
            raw === 'vcenter' ||
            raw === 'v center' ||
            raw === 'vertical center' ||
            raw === '1'
        ) {
            return 0.5;
        }
        return null;
    }

    function hotspotBasenameFromIconUrl(iconUrl) {
        if (!iconUrl) {
            return null;
        }
        let path = String(iconUrl);
        try {
            path = decodeURIComponent(path);
        } catch (e) {
            /* keep raw */
        }
        const marker = '/svg/';
        const svgPos = path.lastIndexOf(marker);
        let rel = svgPos >= 0 ? path.slice(svgPos + marker.length) : path;
        rel = rel.split('?')[0].split('#')[0];
        const basename = rel.split('/').pop();
        return basename || null;
    }

    function lookupSvgHotspot(iconUrl) {
        const basename = hotspotBasenameFromIconUrl(iconUrl);
        if (!basename) {
            return null;
        }
        const hotspots = getSvgHotspots();
        const keys = [basename];
        if (typeof basename.normalize === 'function') {
            keys.push(basename.normalize('NFC'));
            keys.push(basename.normalize('NFD'));
        }
        for (let i = 0; i < keys.length; i += 1) {
            const hit = hotspots[keys[i]];
            if (
                hit &&
                hit.length >= 2 &&
                Number.isFinite(Number(hit[0])) &&
                Number.isFinite(Number(hit[1]))
            ) {
                return [clampFraction(hit[0], 0.5), clampFraction(hit[1], 0.5)];
            }
        }
        return null;
    }

    function resolveIconAnchorFractions(iconUrl, props, ruleStyle, defaultX, defaultY) {
        const hotspot = lookupSvgHotspot(iconUrl);
        if (hotspot) {
            return hotspot;
        }
        const ha = enumAnchorToFraction('x', propertyValue(props, 'Svg_HAPoint'));
        const va = enumAnchorToFraction('y', propertyValue(props, 'Svg_VAPoint'));
        const ruleX = enumAnchorToFraction(
            'x',
            (ruleStyle && ruleStyle.iconAnchorX) || defaultX || 'center'
        );
        const ruleY = enumAnchorToFraction(
            'y',
            (ruleStyle && ruleStyle.iconAnchorY) || defaultY || 'bottom'
        );
        return [
            ha != null ? ha : ruleX != null ? ruleX : 0.5,
            va != null ? va : ruleY != null ? ruleY : 1,
        ];
    }

    function anchorPixelsFromFractions(size, fx, fy) {
        const safeSize = Math.max(
            MAP_UNIT_MARKER_MIN_PX,
            Math.round(Number.isFinite(size) && size > 0 ? size : MAP_UNIT_MARKER_MIN_PX)
        );
        return {
            size: safeSize,
            ax: Math.round(clampFraction(fx, 0.5) * safeSize),
            ay: Math.round(clampFraction(fy, 1) * safeSize),
        };
    }

    function buildSvgIcon(iconUrl, size, anchorFx, anchorFy) {
        const anchored = anchorPixelsFromFractions(size, anchorFx, anchorFy);
        return L.icon({
            iconUrl: iconUrl,
            iconSize: [anchored.size, anchored.size],
            iconAnchor: [anchored.ax, anchored.ay],
        });
    }

    function applySvgMarkerSize(entry, size) {
        if (!entry || !entry.marker || entry.lastSize === size) {
            return;
        }
        entry.lastSize = size;
        const fx = entry.anchorFx != null ? entry.anchorFx : 0.5;
        const fy = entry.anchorFy != null ? entry.anchorFy : 1;
        const anchored = anchorPixelsFromFractions(size, fx, fy);
        const ax = anchored.ax;
        const ay = anchored.ay;
        const icon = entry.marker.options && entry.marker.options.icon;
        if (icon && icon.options) {
            icon.options.iconSize = [size, size];
            icon.options.iconAnchor = [ax, ay];
        }
        const el = entry.marker._icon;
        if (el) {
            el.style.width = size + 'px';
            el.style.height = size + 'px';
            el.style.marginLeft = -ax + 'px';
            el.style.marginTop = -ay + 'px';
            if (typeof entry.marker.update === 'function' && entry.marker._map) {
                entry.marker.update();
            }
        } else {
            entry.marker.setIcon(buildSvgIcon(entry.iconUrl, size, fx, fy));
        }
    }

    function createSvgMarker(latlng, iconUrl, size, feature, mapUnitMeters, anchorFx, anchorFy) {
        const fx = clampFraction(anchorFx, 0.5);
        const fy = clampFraction(anchorFy, 1);
        const marker = L.marker(latlng, {
            icon: buildSvgIcon(iconUrl, size, fx, fy),
            zIndexOffset: 600,
        }).bindTooltip(featureTooltip(feature), { sticky: true });
        if (mapUnitMeters != null && Number.isFinite(Number(mapUnitMeters))) {
            mapUnitMarkers.push({
                kind: 'svg',
                marker: marker,
                iconUrl: iconUrl,
                meters: Number(mapUnitMeters),
                lastSize: size,
                anchorFx: fx,
                anchorFy: fy,
            });
        }
        return marker;
    }

    let mapUnitRefreshRaf = null;

    function refreshMapUnitMarkers(zoomOverride) {
        if (!map || !mapUnitMarkers.length) {
            return;
        }
        const zoom = Number.isFinite(Number(zoomOverride)) ? Number(zoomOverride) : map.getZoom();
        mapUnitMarkers.forEach(function (entry) {
            if (!entry || !entry.marker) {
                return;
            }
            const latlng = entry.marker.getLatLng();
            if (entry.kind === 'svg') {
                applySvgMarkerSize(entry, resolveMarkerPixelSize(latlng, entry.meters, 'MapUnit', zoom));
                return;
            }
            if (entry.kind === 'circle' && typeof entry.marker.setRadius === 'function') {
                const diameterPx = resolveMarkerPixelSize(latlng, entry.meters, 'MapUnit', zoom);
                const radius = Math.max(2, Math.round(diameterPx / 2));
                if (entry.lastSize !== radius) {
                    entry.lastSize = radius;
                    entry.marker.setRadius(radius);
                }
            }
        });
    }

    function scheduleMapUnitMarkersRefresh(zoomOverride) {
        if (mapUnitRefreshRaf !== null) {
            window.cancelAnimationFrame(mapUnitRefreshRaf);
        }
        mapUnitRefreshRaf = window.requestAnimationFrame(function () {
            mapUnitRefreshRaf = null;
            refreshMapUnitMarkers(zoomOverride);
        });
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
        if (!resolved || isUnknownSvgPath(resolved)) {
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

    function isAdjacentFeature(props) {
        if (!props) {
            return false;
        }
        if (props.adjacentRootKind) {
            return true;
        }
        return props.layerKey === 'adjacent_approval' || props.layerKey === 'adjacent_objects';
    }

    function adjacentFeatureKey(props) {
        return (
            String(props.sourceTable || '') +
            ':' +
            String(props.fid ?? '') +
            ':' +
            String(props.RootId || '')
        );
    }

    function adjacentLayerForRoot(rootId, kind, activeNRoot) {
        const active = String(activeNRoot || '').trim();
        const normalizedRoot = String(rootId || '').trim();
        if (!active) {
            return kind === 'n' ? 'adjacent_approval' : 'adjacent_objects';
        }
        if (normalizedRoot === active) {
            return 'adjacent_approval';
        }
        return 'adjacent_objects';
    }

    function isAdjacentRootHighlighted(rootId, kind, activeNRoot) {
        const active = String(activeNRoot || '').trim();
        const normalizedRoot = String(rootId || '').trim();
        if (!active) {
            return kind === 'n';
        }
        return normalizedRoot === active;
    }

    function adjacentBaseStyle(leafletLayer, props) {
        if (leafletLayer && leafletLayer.feature) {
            return styleFeature(leafletLayer.feature);
        }
        return styleFeature({
            type: 'Feature',
            properties: props || {},
            geometry: { type: 'Polygon' },
        });
    }

    function parseHexColor(hex) {
        const raw = String(hex || '').replace('#', '');
        if (raw.length !== 6) {
            return null;
        }
        const r = parseInt(raw.slice(0, 2), 16);
        const g = parseInt(raw.slice(2, 4), 16);
        const b = parseInt(raw.slice(4, 6), 16);
        if (Number.isNaN(r) || Number.isNaN(g) || Number.isNaN(b)) {
            return null;
        }
        return { r: r, g: g, b: b };
    }

    function lerpHexColor(a, b, t) {
        const from = parseHexColor(a);
        const to = parseHexColor(b);
        if (!from || !to) {
            return a;
        }
        const clamped = Math.max(0, Math.min(1, t));
        const mix = function (x, y) {
            return Math.round(x + (y - x) * clamped);
        };
        const toHex = function (n) {
            const s = n.toString(16);
            return s.length === 1 ? '0' + s : s;
        };
        return (
            '#' +
            toHex(mix(from.r, to.r)) +
            toHex(mix(from.g, to.g)) +
            toHex(mix(from.b, to.b))
        );
    }

    function adjacentPulsePhase(nowMs) {
        const elapsed = Math.max(0, nowMs - adjacentPulseStart);
        const t = (elapsed % ADJACENT_PULSE_PERIOD_MS) / ADJACENT_PULSE_PERIOD_MS;
        return 0.5 - 0.5 * Math.cos(2 * Math.PI * t);
    }

    function setAdjacentHighlightStroke(entry, color) {
        const layer = entry && entry.leafletLayer;
        if (!layer || typeof layer.setStyle !== 'function') {
            return;
        }
        const base = entry.baseStyle || {};
        layer.setStyle(
            Object.assign({}, base, {
                color: color,
                weight: ADJACENT_ACTIVE_WEIGHT,
            })
        );
    }

    function hasAdjacentHighlightedEntries() {
        return Object.keys(adjacentFeatureRegistry).some(function (key) {
            const entry = adjacentFeatureRegistry[key];
            return entry && entry._adjacentHighlighted;
        });
    }

    function stopAdjacentHighlightPulse() {
        if (adjacentPulseRaf != null) {
            window.cancelAnimationFrame(adjacentPulseRaf);
            adjacentPulseRaf = null;
        }
        adjacentPulseStart = 0;
    }

    function tickAdjacentHighlightPulse(nowMs) {
        adjacentPulseRaf = null;
        if (!hasAdjacentHighlightedEntries()) {
            stopAdjacentHighlightPulse();
            return;
        }
        const color = lerpHexColor(
            ADJACENT_ACTIVE_STROKE_SOFT,
            ADJACENT_ACTIVE_STROKE_STRONG,
            adjacentPulsePhase(nowMs)
        );
        Object.keys(adjacentFeatureRegistry).forEach(function (key) {
            const entry = adjacentFeatureRegistry[key];
            if (!entry || !entry._adjacentHighlighted) {
                return;
            }
            setAdjacentHighlightStroke(entry, color);
        });
        adjacentPulseRaf = window.requestAnimationFrame(tickAdjacentHighlightPulse);
    }

    function startAdjacentHighlightPulse() {
        if (adjacentPulseRaf != null) {
            return;
        }
        if (!hasAdjacentHighlightedEntries()) {
            return;
        }
        adjacentPulseStart = window.performance.now();
        adjacentPulseRaf = window.requestAnimationFrame(tickAdjacentHighlightPulse);
    }

    function syncAdjacentHighlightPulse() {
        if (hasAdjacentHighlightedEntries()) {
            startAdjacentHighlightPulse();
            return;
        }
        stopAdjacentHighlightPulse();
    }

    function applyAdjacentFeatureStyle(entry, isActive) {
        const layer = entry && entry.leafletLayer;
        if (!layer || typeof layer.setStyle !== 'function') {
            return;
        }
        const base = entry.baseStyle || {};
        if (isActive) {
            entry._adjacentHighlighted = true;
            setAdjacentHighlightStroke(entry, ADJACENT_ACTIVE_STROKE_SOFT);
            return;
        }
        entry._adjacentHighlighted = false;
        layer.setStyle(base);
    }

    function findManagedGroupContaining(leafletLayer) {
        const groups = Object.keys(managedLayers);
        for (let i = 0; i < groups.length; i += 1) {
            const group = managedLayers[groups[i]];
            if (group && group.hasLayer(leafletLayer)) {
                return group;
            }
        }
        return null;
    }

    function moveLeafletLayerToGroup(leafletLayer, targetKey) {
        const targetGroup = ensureLayerGroup(targetKey);
        const currentGroup = findManagedGroupContaining(leafletLayer);
        if (currentGroup && currentGroup !== targetGroup) {
            currentGroup.removeLayer(leafletLayer);
        }
        if (!targetGroup.hasLayer(leafletLayer)) {
            targetGroup.addLayer(leafletLayer);
        }
        const checkbox = document.querySelector('input[data-layer-key="' + targetKey + '"]');
        const isVisible = !checkbox || checkbox.checked;
        setLayerVisible(targetKey, isVisible);
    }

    function registerAdjacentLeafletLayer(props, leafletLayer) {
        const key = adjacentFeatureKey(props);
        const kind = props.adjacentRootKind || (props.layerKey === 'adjacent_approval' ? 'n' : 'v');
        adjacentFeatureRegistry[key] = {
            leafletLayer: leafletLayer,
            rootId: props.RootId || '',
            kind: kind,
            baseStyle: adjacentBaseStyle(leafletLayer, props),
        };
        leafletLayer._adjacentFeatureKey = key;
    }

    function updateAdjacentLayers(activeNRoot) {
        if (!map) {
            return;
        }
        activeAdjacentNRoot = activeNRoot == null ? '' : String(activeNRoot);
        Object.keys(adjacentFeatureRegistry).forEach(function (key) {
            const entry = adjacentFeatureRegistry[key];
            if (!entry || !entry.leafletLayer) {
                return;
            }
            const targetKey = adjacentLayerForRoot(
                entry.rootId,
                entry.kind,
                activeAdjacentNRoot
            );
            moveLeafletLayerToGroup(entry.leafletLayer, targetKey);
            applyAdjacentFeatureStyle(
                entry,
                isAdjacentRootHighlighted(entry.rootId, entry.kind, activeAdjacentNRoot)
            );
        });
        syncAdjacentHighlightPulse();
        reorderMapLayers();
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
        const sizeUnit =
            (ruleStyle && (ruleStyle.iconSizeUnit || ruleStyle.sizeUnit)) || 'MM';

        if (styleKey === 'PhotoFixPoint') {
            const photoUrl = photoFixIconUrl();
            if (photoUrl) {
                const baseSize = (ruleStyle && ruleStyle.iconSize) || 12;
                const size = resolveMarkerPixelSize(latlng, baseSize, sizeUnit);
                const mapMeters = sizeUnit === 'MapUnit' ? baseSize : null;
                const fractions = resolveIconAnchorFractions(
                    photoUrl,
                    props,
                    ruleStyle,
                    'center',
                    'center'
                );
                return createSvgMarker(
                    latlng,
                    photoUrl,
                    size,
                    feature,
                    mapMeters,
                    fractions[0],
                    fractions[1]
                );
            }
        }

        const iconUrl = svgIconUrl(ruleStyle, props);
        if (iconUrl) {
            const baseSize = ruleStyle && ruleStyle.iconSize ? ruleStyle.iconSize : 18;
            const size = resolveMarkerPixelSize(latlng, baseSize, sizeUnit);
            const mapMeters = sizeUnit === 'MapUnit' ? baseSize : null;
            // Prefer SVG hotspots / feature Svg_*APoint; else QML enum (often bottom).
            const fractions = resolveIconAnchorFractions(
                iconUrl,
                props,
                ruleStyle,
                'center',
                'bottom'
            );
            return createSvgMarker(
                latlng,
                iconUrl,
                size,
                feature,
                mapMeters,
                fractions[0],
                fractions[1]
            );
        }

        const colors = hashColor(displayKey);
        const baseRadius = (ruleStyle && ruleStyle.radius) || 5;
        const stroke = (ruleStyle && ruleStyle.color) || colors.stroke;
        const fill = (ruleStyle && ruleStyle.fillColor) || colors.fill;
        const fillOpacity = (ruleStyle && ruleStyle.fillOpacity) || 0.85;
        let radius;
        if (sizeUnit === 'MapUnit') {
            // QGIS SimpleMarker size is diameter; prefer iconSize when radius is a tiny halo.
            const mapMeters =
                Number(baseRadius) > 0.5
                    ? Number(baseRadius)
                    : Number(ruleStyle && ruleStyle.iconSize) > 0.5
                      ? Number(ruleStyle.iconSize)
                      : 14;
            const diameterPx = resolveMarkerPixelSize(latlng, mapMeters, 'MapUnit');
            radius = Math.max(2, Math.round(diameterPx / 2));
        } else {
            radius = Math.round(baseRadius * CIRCLE_MARKER_SIZE_SCALE);
        }
        const circle = L.circleMarker(latlng, {
            radius: radius,
            color: stroke,
            weight: 2,
            fillColor: fill,
            fillOpacity: fillOpacity,
            pane: 'markerPane',
        }).bindTooltip(featureTooltip(feature), { sticky: true });
        if (sizeUnit === 'MapUnit') {
            mapUnitMarkers.push({
                kind: 'circle',
                marker: circle,
                meters: Number(baseRadius) > 0.5 ? Number(baseRadius) : (ruleStyle && ruleStyle.iconSize) || 14,
            });
        }
        return circle;
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
        reorderMapLayers();
    }

    function reorderMapLayers() {
        if (!map) {
            return;
        }
        const order = layerStackOrder.length
            ? layerStackOrder
            : Object.keys(managedLayers).sort();
        order.forEach(function (layerKey) {
            const group = managedLayers[layerKey];
            if (group && map.hasLayer(group)) {
                group.bringToFront();
            }
        });
        if (eventGeometriesGroup && map.hasLayer(eventGeometriesGroup)) {
            eventGeometriesGroup.bringToFront();
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

    function fitTaskGuidBounds(taskGuid) {
        if (!map || !taskGuid) {
            return false;
        }
        const normalized = String(taskGuid).toLowerCase();
        const boundsGroup = L.featureGroup();
        Object.keys(managedLayers).forEach(function (layerKey) {
            const group = managedLayers[layerKey];
            if (!group) {
                return;
            }
            group.eachLayer(function (leafletLayer) {
                const feature = leafletLayer.feature;
                const props = feature && feature.properties;
                const guid = props && props.taskGuid;
                if (guid && String(guid).toLowerCase() === normalized) {
                    boundsGroup.addLayer(leafletLayer);
                }
            });
        });
        const bounds = boundsGroup.getBounds();
        if (!bounds.isValid()) {
            return false;
        }
        const northEast = bounds.getNorthEast();
        const southWest = bounds.getSouthWest();
        if (northEast.lat === southWest.lat && northEast.lng === southWest.lng) {
            map.setView(bounds.getCenter(), Math.max(map.getZoom(), 17));
        } else {
            map.fitBounds(bounds.pad(0.12));
        }
        return true;
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
        if (!geometry) {
            clearPendingMessageGeometry();
            return;
        }
        setPendingMessageGeometries([geometry]);
    }

    function setPendingMessageGeometries(geometries) {
        if (!map || !eventGeometriesGroup) {
            return;
        }
        removePendingGeometryLayer();
        const items = (geometries || []).filter(Boolean);
        if (!items.length) {
            return;
        }
        pendingGeometryGeoJson = items.length === 1 ? items[0] : items;
        const features = items.map(function (geometry) {
            return {
                type: 'Feature',
                geometry: geometry,
                properties: {
                    layerKey: PENDING_LAYER_KEY,
                },
            };
        });
        const layer = L.geoJSON(
            { type: 'FeatureCollection', features: features },
            {
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
            }
        );
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

    function messageGeometryItems(message) {
        if (message.geometries && message.geometries.length) {
            return message.geometries;
        }
        if (message.geometry) {
            return [{ id: message.geometry_id || '0', geometry: message.geometry }];
        }
        return [];
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
            const items = messageGeometryItems(message);
            items.forEach(function (item, index) {
                if (!item || !item.geometry) {
                    return;
                }
                const geomId = item.id != null ? item.id : index;
                const messageKey = geometryLayerKey('message', message.id + ':' + geomId);
                addGeometryLayer(
                    messageKey,
                    item.geometry,
                    'Геометрия сообщения',
                    false
                );
            });
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

    function isMessageLayerActive(layerKey, messageId) {
        if (!messageId) {
            return false;
        }
        const prefix = geometryLayerKey('message', messageId + ':');
        const legacyKey = geometryLayerKey('message', messageId);
        return layerKey === legacyKey || layerKey.indexOf(prefix) === 0;
    }

    function refreshGeometryStyles() {
        Object.keys(geometryLayerByKey).forEach(function (layerKey) {
            const layer = geometryLayerByKey[layerKey];
            if (!layer) {
                return;
            }
            const isActive =
                layerKey === geometryLayerKey('case', activeCaseId) ||
                isMessageLayerActive(layerKey, activeMessageGeometryId);
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

    function fitGeometryLayers(layerKeys) {
        if (!map || !layerKeys || !layerKeys.length) {
            return;
        }
        let combined = null;
        layerKeys.forEach(function (layerKey) {
            const layer = geometryLayerByKey[layerKey];
            if (!layer) {
                return;
            }
            const bounds = layer.getBounds();
            if (!bounds.isValid()) {
                return;
            }
            combined = combined ? combined.extend(bounds) : bounds;
        });
        if (!combined || !combined.isValid()) {
            return;
        }
        const northEast = combined.getNorthEast();
        const southWest = combined.getSouthWest();
        if (northEast.lat === southWest.lat && northEast.lng === southWest.lng) {
            map.setView(combined.getCenter(), Math.max(map.getZoom(), 17));
            return;
        }
        map.fitBounds(combined.pad(0.2));
    }

    function fitCaseGeometry(caseId) {
        fitGeometryLayer(geometryLayerKey('case', caseId));
    }

    function fitMessageGeometry(messageId) {
        if (!messageId) {
            return;
        }
        const prefix = geometryLayerKey('message', messageId + ':');
        const legacyKey = geometryLayerKey('message', messageId);
        const keys = Object.keys(geometryLayerByKey).filter(function (layerKey) {
            return layerKey === legacyKey || layerKey.indexOf(prefix) === 0;
        });
        if (keys.length === 1) {
            fitGeometryLayer(keys[0]);
            return;
        }
        fitGeometryLayers(keys);
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
        if (Array.isArray(config.layerStackOrder)) {
            layerStackOrder = config.layerStackOrder;
        }
        getLayerStylesManifest();

        const center = Array.isArray(config.center) ? config.center : [55.75, 37.61];
        const defaultZoom = Number(config.defaultZoom) || 10;

        map = L.map(mapElementId, {
            zoomControl: true,
            attributionControl: true,
            // Own MapUnit sizing must drive marker scale; Leaflet CSS zoom-anim
            // on markers would double-scale and look like drift.
            markerZoomAnimation: false,
            // Finer zoom steps → size updates more often (smoother).
            zoomSnap: 0.25,
            zoomDelta: 0.5,
            wheelPxPerZoomLevel: 80,
        }).setView(center, defaultZoom);

        map.attributionControl.setPrefix(
            '<a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>'
        );

        managedLayers = {};
        mapUnitMarkers = [];
        eventGeometriesGroup = L.featureGroup().addTo(map);
        map.invalidateSize();

        function liveMapZoom(eventZoom) {
            if (Number.isFinite(Number(eventZoom))) {
                return Number(eventZoom);
            }
            if (map._animatingZoom && Number.isFinite(map._animateToZoom)) {
                return map._animateToZoom;
            }
            return map.getZoom();
        }

        map.on('zoomanim', function (event) {
            scheduleMapUnitMarkersRefresh(liveMapZoom(event && event.zoom));
        });
        map.on('zoom', function () {
            scheduleMapUnitMarkersRefresh(liveMapZoom());
        });
        map.on('zoomend', function () {
            refreshMapUnitMarkers(map.getZoom());
        });
        map.on('moveend', function () {
            refreshMapUnitMarkers(map.getZoom());
        });

        function isInspectorForSelectedApprove() {
            const pageConfig = readJsonScript('page-config') || {};
            const currentUser = (pageConfig.currentUser || '').trim();
            if (!currentUser) {
                return false;
            }
            const selectedId = pageConfig.selectedApproveId;
            const approves = pageConfig.approves || [];
            for (let i = 0; i < approves.length; i += 1) {
                const item = approves[i];
                if (String(item.id) === String(selectedId) && item.can_delete) {
                    return true;
                }
            }
            return false;
        }

        function onEachFeature(feature, layer) {
            layer.bindTooltip(featureTooltip(feature), { sticky: true });
            const props = feature.properties || {};
            if (isAdjacentFeature(props)) {
                return;
            }
            if (!isInspectorForSelectedApprove()) {
                return;
            }
            layer.on('click', function () {
                const taskGuid = props.taskGuid || props.TaskGUID;
                if (
                    window.ApprovalEvents &&
                    typeof window.ApprovalEvents.openChangeOwnerForTaskGuid === 'function'
                ) {
                    window.ApprovalEvents.openChangeOwnerForTaskGuid(taskGuid);
                }
            });
        }

        if (mapGeojson && Array.isArray(mapGeojson.features)) {
            mapGeojson.features.forEach(function (feature) {
                try {
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
                        if (isAdjacentFeature(props)) {
                            registerAdjacentLeafletLayer(props, layer);
                        }
                        targetGroup.addLayer(layer);
                    });

                    if (!isVisible) {
                        setLayerVisible(layerKey, false);
                    }
                } catch (err) {
                    console.warn('approval map: failed to add feature', err);
                }
            });
        }

        initLayerPanelControls(config);
        updateAdjacentLayers('');
        reorderMapLayers();
        if (!fitTaskGuidBounds(config.focusTaskGuid)) {
            fitVisibleBounds();
        }
        map.invalidateSize();
        refreshMapUnitMarkers();
        window.setTimeout(function () {
            if (!map) {
                return;
            }
            map.invalidateSize();
            refreshMapUnitMarkers();
        }, 0);
    }

    function initLayerPanelToggle() {
        const panel = document.getElementById('approval-layer-panel');
        const layersAside = document.getElementById('approval-panel-layers');
        const workspace = document.querySelector('.approval-workspace');
        const toggle = document.getElementById('approval-layer-panel-toggle');
        if (!panel || !toggle) {
            return;
        }

        function applyCollapsedState(collapsed) {
            panel.classList.toggle('is-collapsed', collapsed);
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
        }

        applyCollapsedState(panel.classList.contains('is-collapsed'));

        toggle.addEventListener('click', function () {
            applyCollapsedState(!panel.classList.contains('is-collapsed'));
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
        updateAdjacentLayers: updateAdjacentLayers,
        fitCaseGeometry: fitCaseGeometry,
        fitMessageGeometry: fitMessageGeometry,
        setPendingMessageGeometry: setPendingMessageGeometry,
        setPendingMessageGeometries: setPendingMessageGeometries,
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

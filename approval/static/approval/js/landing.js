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
    let approvalObjectLayerKeySet = null;
    let layerStackOrder = [];
    const adjacentFeatureRegistry = {};
    let activeAdjacentNRoot = '';
    const dgiFeatureRegistry = [];
    const dgiSubKeyChecked = {};
    const DGI_SUBLAYER_SPECS = [
        { key: 'dgi_moscow_rent', name: 'З/У г. Москва с арендой' },
        { key: 'dgi_moscow_no_rent', name: 'З/У г. Москва без аренды' },
        {
            key: 'dgi_private_rent',
            name: 'З/У Частная или федеральная собственность с арендой',
        },
        {
            key: 'dgi_private_no_rent',
            name: 'З/У Частная или федеральная собственность без аренды',
        },
        { key: 'dgi_renovation', name: 'З/У Реновация' },
    ];
    DGI_SUBLAYER_SPECS.forEach(function (spec) {
        dgiSubKeyChecked[spec.key] = true;
    });
    const ADJACENT_ACTIVE_STROKE_SOFT = '#fde68a';
    const ADJACENT_ACTIVE_STROKE_STRONG = '#ca8a04';
    const ADJACENT_ACTIVE_WEIGHT = 4;
    const ADJACENT_ACTIVE_FILL_OPACITY_SOFT = 0.25;
    const ADJACENT_ACTIVE_FILL_OPACITY_STRONG = 0.55;
    const ADJACENT_PULSE_PERIOD_MS = 2800;
    let adjacentPulseRaf = null;
    let adjacentPulseStart = 0;
    const MM_MARKER_SIZE_SCALE = 1;
    const CIRCLE_MARKER_SIZE_SCALE = 1.5;
    /**
     * QGIS MapUnit = meters on ground (no artificial screen boost).
     * Hide when on-screen size drops below fontMinPixelSize-like threshold.
     */
    const MAP_UNIT_VISUAL_SCALE = 1;
    const MAP_UNIT_HIDE_BELOW_PX = 3;
    const MAP_UNIT_MARKER_MAX_PX = 10000;
    let mapUnitMarkers = [];
    let selectablePolygonLayers = [];
    let signalTapeRenderer = null;
    // ~1:200 at Moscow latitude (Web Mercator, 0.28 mm CSS pixel).
    const APPROVAL_MAP_MAX_ZOOM = 20.5;

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

    function getApprovalObjectLayerKeySet() {
        if (approvalObjectLayerKeySet) {
            return approvalObjectLayerKeySet;
        }
        const config = readJsonScript('page-config') || {};
        const layerGroups = config.layerGroups || {};
        approvalObjectLayerKeySet = new Set(layerGroups.work || []);
        return approvalObjectLayerKeySet;
    }

    function isApprovalObjectFeature(feature) {
        const props = (feature && feature.properties) || {};
        const layerKey = String(props.layerKey || props.sourceTable || '');
        return Boolean(layerKey) && getApprovalObjectLayerKeySet().has(layerKey);
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
        const tables = manifest.tables || {};
        if (tables[layerKey]) {
            return tables[layerKey];
        }
        const key = String(layerKey || '');
        if (key.indexOf('topo:') === 0) {
            const bare = key.slice(5);
            return tables[bare] || null;
        }
        return null;
    }

    function propertyValue(props, field) {
        if (!field || !props) {
            return null;
        }
        const direct = props[field];
        if (direct !== undefined && direct !== null && direct !== '') {
            return direct;
        }
        const lower = String(field).toLowerCase();
        const keys = Object.keys(props);
        for (let i = 0; i < keys.length; i += 1) {
            if (keys[i].toLowerCase() === lower) {
                const value = props[keys[i]];
                if (value !== undefined && value !== null && value !== '') {
                    return value;
                }
            }
        }
        return null;
    }

    function likeMatch(value, pattern) {
        const text = String(value == null ? '' : value);
        const raw = String(pattern == null ? '' : pattern);
        let regexSrc = '';
        for (let i = 0; i < raw.length; i += 1) {
            const ch = raw.charAt(i);
            if (ch === '%') {
                regexSrc += '.*';
            } else if (ch === '_') {
                regexSrc += '.';
            } else if (/[.*+?^${}()|[\]\\]/.test(ch)) {
                regexSrc += '\\' + ch;
            } else {
                regexSrc += ch;
            }
        }
        try {
            return new RegExp('^' + regexSrc + '$').test(text);
        } catch (err) {
            return false;
        }
    }

    function matchFilter(props, filter) {
        if (!filter) {
            return true;
        }
        const ftype = filter.type;
        if (ftype === 'else') {
            return true;
        }
        if (ftype === 'and') {
            const children = filter.children || [];
            for (let i = 0; i < children.length; i += 1) {
                if (!matchFilter(props, children[i])) {
                    return false;
                }
            }
            return children.length > 0;
        }
        if (ftype === 'or') {
            const children = filter.children || [];
            for (let i = 0; i < children.length; i += 1) {
                if (matchFilter(props, children[i])) {
                    return true;
                }
            }
            return false;
        }
        if (ftype === 'in') {
            const value = propertyValue(props, filter.field);
            if (value === null) {
                return false;
            }
            const values = filter.values || [];
            const asText = String(value);
            for (let i = 0; i < values.length; i += 1) {
                if (asText === String(values[i])) {
                    return true;
                }
            }
            return false;
        }
        if (ftype === 'like') {
            const value = propertyValue(props, filter.field);
            if (value === null) {
                return false;
            }
            return likeMatch(value, filter.pattern);
        }
        if (ftype === 'ne') {
            const value = propertyValue(props, filter.field);
            if (value === null) {
                return false;
            }
            return String(value) !== String(filter.value);
        }
        const value = propertyValue(props, filter.field);
        if (ftype === 'eq') {
            return value !== null && String(value) === String(filter.value);
        }
        if (ftype === 'null') {
            return value === null;
        }
        if (ftype === 'not_null') {
            return value !== null;
        }
        return false;
    }

    function resolveRuleStyle(layerKey, props) {
        const tableDef = getTableStyleDef(layerKey);
        if (!tableDef || !Array.isArray(tableDef.rules) || !tableDef.rules.length) {
            return null;
        }
        let elseStyle = null;
        for (let i = 0; i < tableDef.rules.length; i += 1) {
            const rule = tableDef.rules[i];
            const filt = rule.filter;
            if (filt && filt.type === 'else') {
                elseStyle = rule.style || null;
                continue;
            }
            if (matchFilter(props, filt)) {
                return rule.style || null;
            }
        }
        if (elseStyle) {
            return elseStyle;
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
            return 0;
        }
        const latitude = Number.isFinite(Number(lat)) ? Number(lat) : map.getCenter().lat;
        const z = Number.isFinite(Number(zoom)) ? Number(zoom) : map.getZoom();
        const metersPerPixel =
            (156543.03392 * Math.cos((latitude * Math.PI) / 180)) / Math.pow(2, z);
        if (!Number.isFinite(metersPerPixel) || metersPerPixel <= 0) {
            return 0;
        }
        const px = Number(meters) / metersPerPixel;
        return Number.isFinite(px) ? px : 0;
    }

    function resolveMarkerPixelSize(latlng, sizeValue, sizeUnit, zoom) {
        const raw = Number(sizeValue);
        if (sizeUnit === 'MapUnit') {
            const meters = Number.isFinite(raw) && raw > 0 ? raw : 14;
            // True QGIS MapUnit → screen px (Mercator). No min floor — tiny sizes hide.
            const scaled =
                estimateMetersToPixels(meters, latlng && latlng.lat, zoom) * MAP_UNIT_VISUAL_SCALE;
            if (!Number.isFinite(scaled) || scaled <= 0) {
                return 0;
            }
            return Math.round(clampNumber(scaled, 0, MAP_UNIT_MARKER_MAX_PX));
        }
        const screenPx = (Number.isFinite(raw) && raw > 0 ? raw : 18) * MM_MARKER_SIZE_SCALE;
        return Math.round(clampNumber(screenPx, 10, 64));
    }

    function isMapUnitVisible(sizePx) {
        return Number(sizePx) >= MAP_UNIT_HIDE_BELOW_PX;
    }

    function setLeafletMarkerOpacity(marker, opacity) {
        if (!marker) {
            return;
        }
        if (typeof marker.setOpacity === 'function') {
            marker.setOpacity(opacity);
            return;
        }
        if (typeof marker.setStyle === 'function') {
            marker.setStyle({ opacity: opacity, fillOpacity: opacity });
        }
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
            1,
            Math.round(Number.isFinite(size) && size > 0 ? size : 1)
        );
        return {
            size: safeSize,
            ax: Math.round(clampFraction(fx, 0.5) * safeSize),
            ay: Math.round(clampFraction(fy, 1) * safeSize),
        };
    }

    const svgClickMarkers = {};
    const svgOpaqueBoundsCache = {};
    let nextSvgClickMarkerId = 1;

    function buildSvgIcon(iconUrl, size, anchorFx, anchorFy, markerId, interactive) {
        const anchored = anchorPixelsFromFractions(size, anchorFx, anchorFy);
        return L.divIcon({
            className: 'approval-svg-marker',
            html:
                '<img class="approval-svg-marker__image" style="width:' +
                anchored.size +
                'px;height:' +
                anchored.size +
                'px;left:' +
                -anchored.ax +
                'px;top:' +
                -anchored.ay +
                'px" src="' +
                escapeHtml(iconUrl) +
                '" alt="" aria-hidden="true">' +
                '<span class="approval-svg-marker__hit" style="left:' +
                -anchored.ax +
                'px;top:' +
                -anchored.ay +
                'px;width:' +
                anchored.size +
                'px;height:' +
                anchored.size +
                'px;pointer-events:' +
                (interactive ? 'auto' : 'none') +
                '" data-svg-marker-id="' +
                escapeHtml(markerId || '') +
                '"></span>',
            iconSize: [0, 0],
            iconAnchor: [0, 0],
            // Keep popup placement stable for both pixel-sized and MapUnit SVGs.
            // Using the artwork height here can move it thousands of pixels away
            // at maximum zoom, so position it 50 px above the geometry point.
            popupAnchor: [0, -50],
        });
    }

    function svgOpaqueBounds(image) {
        if (!image || !image.complete || !image.naturalWidth || !image.naturalHeight) {
            return null;
        }
        const cacheKey = image.currentSrc || image.src || '';
        if (cacheKey && Object.prototype.hasOwnProperty.call(svgOpaqueBoundsCache, cacheKey)) {
            return svgOpaqueBoundsCache[cacheKey];
        }
        let bounds = null;
        try {
            const maxSide = 192;
            const scale = Math.min(
                1,
                maxSide / Math.max(image.naturalWidth, image.naturalHeight)
            );
            const width = Math.max(1, Math.round(image.naturalWidth * scale));
            const height = Math.max(1, Math.round(image.naturalHeight * scale));
            const canvas = document.createElement('canvas');
            canvas.width = width;
            canvas.height = height;
            const context = canvas.getContext('2d', { willReadFrequently: true });
            context.drawImage(image, 0, 0, width, height);
            const pixels = context.getImageData(0, 0, width, height).data;
            let minX = width;
            let minY = height;
            let maxX = -1;
            let maxY = -1;
            for (let y = 0; y < height; y += 1) {
                for (let x = 0; x < width; x += 1) {
                    if (pixels[(y * width + x) * 4 + 3] <= 16) {
                        continue;
                    }
                    minX = Math.min(minX, x);
                    minY = Math.min(minY, y);
                    maxX = Math.max(maxX, x);
                    maxY = Math.max(maxY, y);
                }
            }
            if (maxX >= minX && maxY >= minY) {
                bounds = {
                    left: minX / width,
                    top: minY / height,
                    right: (maxX + 1) / width,
                    bottom: (maxY + 1) / height,
                };
            }
        } catch (error) {
            bounds = null;
        }
        if (cacheKey) {
            svgOpaqueBoundsCache[cacheKey] = bounds;
        }
        return bounds;
    }

    function anchorPopupToSvgSilhouette(layer) {
        const iconElement = layer && layer._icon;
        const icon = layer && layer.options && layer.options.icon;
        if (!iconElement || !icon || !icon.options) {
            return;
        }
        const image = iconElement.querySelector('.approval-svg-marker__image');
        const bounds = svgOpaqueBounds(image);
        if (!image || !bounds) {
            icon.options.popupAnchor = [0, -50];
            return;
        }
        const width = parseFloat(image.style.width) || image.getBoundingClientRect().width;
        const height = parseFloat(image.style.height) || image.getBoundingClientRect().height;
        const left = parseFloat(image.style.left) || 0;
        const top = parseFloat(image.style.top) || 0;
        const silhouetteCenterX = left + ((bounds.left + bounds.right) / 2) * width;
        const silhouetteTopY = top + bounds.top * height;
        icon.options.popupAnchor = [
            Math.round(silhouetteCenterX),
            Math.round(silhouetteTopY - 8),
        ];
    }

    function pointInChoiceRing(point, ring) {
        if (!Array.isArray(ring) || ring.length < 3) {
            return false;
        }
        let inside = false;
        for (let i = 0, j = ring.length - 1; i < ring.length; j = i, i += 1) {
            const xi = Number(ring[i] && ring[i][0]);
            const yi = Number(ring[i] && ring[i][1]);
            const xj = Number(ring[j] && ring[j][0]);
            const yj = Number(ring[j] && ring[j][1]);
            if (![xi, yi, xj, yj].every(Number.isFinite)) {
                continue;
            }
            const crosses =
                yi > point[1] !== yj > point[1] &&
                point[0] < ((xj - xi) * (point[1] - yi)) / (yj - yi) + xi;
            if (crosses) {
                inside = !inside;
            }
        }
        return inside;
    }

    function pointInChoicePolygon(point, coordinates) {
        if (!Array.isArray(coordinates) || !coordinates.length) {
            return false;
        }
        if (!pointInChoiceRing(point, coordinates[0])) {
            return false;
        }
        for (let i = 1; i < coordinates.length; i += 1) {
            if (pointInChoiceRing(point, coordinates[i])) {
                return false;
            }
        }
        return true;
    }

    function choiceGeometryContains(geometry, latlng) {
        if (!geometry || !latlng) {
            return false;
        }
        const point = [latlng.lng, latlng.lat];
        if (geometry.type === 'Polygon') {
            return pointInChoicePolygon(point, geometry.coordinates);
        }
        if (geometry.type === 'MultiPolygon') {
            return (geometry.coordinates || []).some(function (coordinates) {
                return pointInChoicePolygon(point, coordinates);
            });
        }
        return false;
    }

    function polygonUnderChoicePoint(latlng, originalEvent) {
        if (originalEvent) {
            const stack = document.elementsFromPoint(
                originalEvent.clientX,
                originalEvent.clientY
            );
            for (let i = 0; i < stack.length; i += 1) {
                for (let j = 0; j < selectablePolygonLayers.length; j += 1) {
                    const stackedLayer = selectablePolygonLayers[j];
                    if (
                        stackedLayer &&
                        stackedLayer._map === map &&
                        stackedLayer.getPopup &&
                        stackedLayer.getPopup() &&
                        stackedLayer._path === stack[i]
                    ) {
                        return stackedLayer;
                    }
                }
            }
        }
        const containing = selectablePolygonLayers.filter(function (layer) {
            const feature = layer && layer._approvalFeature;
            return (
                layer &&
                layer._map === map &&
                layer.getPopup &&
                layer.getPopup() &&
                feature &&
                choiceGeometryContains(feature.geometry, latlng)
            );
        });
        if (!containing.length) {
            return null;
        }
        return containing[containing.length - 1];
    }

    function mapChoiceCandidates(event) {
        if (!map || !event) {
            return { candidates: [], latlng: null };
        }
        const originalEvent = event.originalEvent;
        const clickPoint = originalEvent
            ? map.mouseEventToContainerPoint(originalEvent)
            : map.latLngToContainerPoint(event.latlng);
        const clickLatLng = map.containerPointToLatLng(clickPoint);
        const candidates = [];
        Object.keys(svgClickMarkers).forEach(function (markerId) {
            const marker = svgClickMarkers[markerId];
            if (
                !marker ||
                marker._map !== map ||
                !isApprovalObjectFeature(marker._approvalFeature) ||
                !marker.getPopup ||
                !marker.getPopup()
            ) {
                return;
            }
            const icon = marker._icon;
            const hit = icon && icon.querySelector('.approval-svg-marker__hit');
            if (!hit || hit.style.pointerEvents === 'none') {
                return;
            }
            const markerPoint = map.latLngToContainerPoint(marker.getLatLng());
            const dx = clickPoint.x - markerPoint.x;
            const dy = clickPoint.y - markerPoint.y;
            const distanceSquared = dx * dx + dy * dy;
            if (distanceSquared <= 200 * 200) {
                candidates.push({ layer: marker, kind: 'svg', distanceSquared: distanceSquared });
            }
        });
        candidates.sort(function (left, right) {
            return left.distanceSquared - right.distanceSquared;
        });
        const nearest = candidates.slice(0, 5);
        const polygon = polygonUnderChoicePoint(clickLatLng, originalEvent);
        if (polygon) {
            nearest.push({ layer: polygon, kind: 'polygon', distanceSquared: 0 });
        }
        return { candidates: nearest, latlng: clickLatLng };
    }

    function mapChoiceLabel(candidate, index) {
        const layer = candidate && candidate.layer;
        const feature = layer && layer._approvalFeature;
        const props = (feature && feature.properties) || {};
        const tableDef = getTableStyleDef(props.sourceTable || props.layerKey);
        const aliases = tableDef && Array.isArray(tableDef.aliases) ? tableDef.aliases : [];
        let label = '';
        for (let i = 0; i < aliases.length; i += 1) {
            const field = String(aliases[i].field || '');
            if (!field || /svg|path|count|nocalc/i.test(field)) {
                continue;
            }
            const displayField = field + '__display';
            const value = Object.prototype.hasOwnProperty.call(props, displayField)
                ? props[displayField]
                : props[field];
            if (value !== null && value !== undefined && String(value).trim() !== '') {
                const aliasLabel = formatPopupAliasLabel(aliases[i].label);
                label =
                    (aliasLabel ? aliasLabel + ': ' : '') +
                    String(formatPopupDisplayValue(value, field, aliasLabel)).trim();
                break;
            }
        }
        if (!label) {
            label = String((tableDef && tableDef.label) || props.sourceTable || 'Объект');
        }
        const fid = props.fid !== null && props.fid !== undefined ? String(props.fid) : '';
        const kindLabel = candidate && candidate.kind === 'polygon' ? 'Полигон · ' : '';
        return kindLabel + label + (fid ? ' · #' + fid : ' · ' + String(index + 1));
    }

    let activeMapChoiceHighlight = null;

    function clearMapChoiceHighlight(force) {
        const active = activeMapChoiceHighlight;
        if (active && active.persistent && !force) {
            return;
        }
        activeMapChoiceHighlight = null;
        if (!active) {
            return;
        }
        if (active.markerIcon) {
            active.markerIcon.classList.remove('approval-svg-marker--choice-hover');
            active.markerIcon.classList.remove('approval-svg-marker--choice-active');
        }
        if (active.layer && active.originalStyle && active.layer.setStyle) {
            active.layer.setStyle(active.originalStyle);
        }
    }

    function highlightMapChoice(candidate, persistent) {
        clearMapChoiceHighlight(true);
        const layer = candidate && candidate.layer;
        // Child markers of a GeoJSON MultiPoint can temporarily lose their
        // private `_map` reference while their parent FeatureGroup is redrawn.
        // Their icon/coordinate remain valid and are sufficient for highlighting.
        if (!layer) {
            return;
        }
        const active = {
            layer: layer,
            markerIcon: null,
            originalStyle: null,
            persistent: Boolean(persistent),
        };
        if (candidate.kind === 'svg' && layer.getLatLng) {
            // Highlight the existing Leaflet marker itself. No duplicate marker is
            // added to the map, so the visual object and its hit target stay one.
            active.markerIcon = layer._icon || null;
            if (active.markerIcon) {
                active.markerIcon.classList.add('approval-svg-marker--choice-hover');
                if (persistent) {
                    active.markerIcon.classList.add('approval-svg-marker--choice-active');
                }
            }
        } else if (candidate.kind === 'polygon' && layer.setStyle) {
            active.originalStyle = Object.assign({}, layer.options || {});
            layer.setStyle({ color: '#f59e0b', weight: 5, fillOpacity: 0.45 });
            if (layer.bringToFront) {
                layer.bringToFront();
            }
        }
        activeMapChoiceHighlight = active;
    }

    function focusMapChoiceCandidate(candidate) {
        const layer = candidate && candidate.layer;
        if (!map || !layer) {
            return;
        }
        if (candidate.kind === 'svg' && layer.getLatLng) {
            // Complete the zoom synchronously so the SVG DOM node used for the
            // persistent highlight is the final one at maximum scale.
            map.setView(layer.getLatLng(), APPROVAL_MAP_MAX_ZOOM, { animate: false });
            return;
        }
        if (layer.getBounds) {
            const bounds = layer.getBounds();
            if (bounds && bounds.isValid && bounds.isValid()) {
                map.fitBounds(bounds.pad(0.12), { maxZoom: APPROVAL_MAP_MAX_ZOOM });
            }
        }
    }

    function openSelectedMapChoice(candidate) {
        const layer = candidate && candidate.layer;
        if (!layer || !layer.openPopup) {
            return;
        }
        focusMapChoiceCandidate(candidate);
        if (candidate.kind === 'svg') {
            anchorPopupToSvgSilhouette(layer);
        }
        highlightMapChoice(candidate, true);
        layer.openPopup();
        function watchSelectedPopup() {
            if (
                !activeMapChoiceHighlight ||
                activeMapChoiceHighlight.layer !== layer
            ) {
                return;
            }
            if (document.querySelector('.leaflet-popup')) {
                window.setTimeout(watchSelectedPopup, 250);
                return;
            }
            clearMapChoiceHighlight(true);
        }
        // A MultiPoint popup can be handed from its child marker to the parent
        // FeatureGroup with several delayed close/open events. Observe the final
        // visible state instead of relying on that noisy event sequence.
        window.setTimeout(watchSelectedPopup, 5000);
    }

    function openMapChoicePopup(latlng, candidates) {
        if (!map || !candidates.length) {
            return;
        }
        clearMapChoiceHighlight();
        const content = document.createElement('div');
        content.className = 'approval-svg-choice';
        const title = document.createElement('div');
        title.className = 'approval-svg-choice__title';
        title.textContent = 'Выберите объект';
        content.appendChild(title);

        candidates.forEach(function (candidate, index) {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'approval-svg-choice__item';
            button.textContent = mapChoiceLabel(candidate, index);
            button.addEventListener('mouseenter', function () {
                highlightMapChoice(candidate);
            });
            button.addEventListener('mouseleave', function () {
                clearMapChoiceHighlight(false);
            });
            button.addEventListener('focus', function () {
                highlightMapChoice(candidate);
            });
            button.addEventListener('blur', function () {
                clearMapChoiceHighlight(false);
            });
            button.addEventListener('click', function (buttonEvent) {
                buttonEvent.preventDefault();
                buttonEvent.stopPropagation();
                clearMapChoiceHighlight(true);
                choicePopup.remove();
                openSelectedMapChoice(candidate);
            });
            content.appendChild(button);
        });

        const choicePopup = L.popup({
            className: 'approval-svg-choice-popup',
            closeButton: false,
            autoPan: false,
            offset: [0, -8],
        })
            .setLatLng(latlng)
            .setContent(content)
            .openOn(map);
        choicePopup.on('remove', function () {
            clearMapChoiceHighlight(false);
        });
    }

    function handleMapObjectChoice(event) {
        if (!map || !event || isMeasureModeActive()) {
            return;
        }
        if (
            window.ApprovalEventDraw &&
            typeof window.ApprovalEventDraw.isDrawMode === 'function' &&
            window.ApprovalEventDraw.isDrawMode()
        ) {
            return;
        }
        const originalEvent = event.originalEvent;
        if (originalEvent && originalEvent._approvalChoiceScheduled) {
            return;
        }
        if (originalEvent) {
            originalEvent._approvalChoiceScheduled = true;
        }
        const selection = mapChoiceCandidates(event);
        if (!selection.candidates.length) {
            return;
        }
        window.setTimeout(function () {
            openMapChoicePopup(selection.latlng, selection.candidates);
        }, 0);
    }

    function applySvgMarkerSize(entry, size) {
        if (!entry || !entry.marker) {
            return;
        }
        const visible = isMapUnitVisible(size);
        const renderSize = visible ? Math.max(1, size) : 1;
        if (entry.lastSize === renderSize && entry.lastVisible === visible) {
            return;
        }
        entry.lastSize = renderSize;
        entry.lastVisible = visible;
        const fx = entry.anchorFx != null ? entry.anchorFx : 0.5;
        const fy = entry.anchorFy != null ? entry.anchorFy : 1;
        const anchored = anchorPixelsFromFractions(renderSize, fx, fy);
        const ax = anchored.ax;
        const ay = anchored.ay;
        const icon = entry.marker.options && entry.marker.options.icon;
        if (icon && icon.options) {
            icon.options.iconSize = [0, 0];
            icon.options.iconAnchor = [0, 0];
            icon.options.popupAnchor = [0, -50];
        }
        const el = entry.marker._icon;
        if (el) {
            const image = el.querySelector('.approval-svg-marker__image');
            const hit = el.querySelector('.approval-svg-marker__hit');
            if (image) {
                image.style.width = renderSize + 'px';
                image.style.height = renderSize + 'px';
                image.style.left = -ax + 'px';
                image.style.top = -ay + 'px';
            }
            if (hit) {
                hit.style.left = -ax + 'px';
                hit.style.top = -ay + 'px';
                hit.style.width = renderSize + 'px';
                hit.style.height = renderSize + 'px';
                hit.style.pointerEvents = visible ? 'auto' : 'none';
            }
            if (typeof entry.marker.update === 'function' && entry.marker._map) {
                entry.marker.update();
            }
        } else if (visible) {
            entry.marker.setIcon(
                buildSvgIcon(entry.iconUrl, renderSize, fx, fy, entry.markerId, visible)
            );
        }
        setLeafletMarkerOpacity(entry.marker, visible ? 1 : 0);
    }

    function createSvgMarker(latlng, iconUrl, size, feature, mapUnitMeters, anchorFx, anchorFy) {
        const fx = clampFraction(anchorFx, 0.5);
        const fy = clampFraction(anchorFy, 1);
        const visible = mapUnitMeters != null ? isMapUnitVisible(size) : true;
        const renderSize = visible ? Math.max(1, size) : 1;
        const markerId = String(nextSvgClickMarkerId);
        nextSvgClickMarkerId += 1;
        const marker = L.marker(latlng, {
            icon: buildSvgIcon(iconUrl, renderSize, fx, fy, markerId, visible),
            opacity: visible ? 1 : 0,
            zIndexOffset: 600,
        });
        svgClickMarkers[markerId] = marker;
        marker._approvalFeature = feature;
        marker._approvalIsSvgMarker = true;
        marker.on('click', handleMapObjectChoice);
        if (mapUnitMeters != null && Number.isFinite(Number(mapUnitMeters))) {
            mapUnitMarkers.push({
                kind: 'svg',
                marker: marker,
                markerId: markerId,
                iconUrl: iconUrl,
                meters: Number(mapUnitMeters),
                lastSize: renderSize,
                lastVisible: visible,
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
            if (entry.kind === 'text') {
                applyTextLabelSize(entry, resolveMarkerPixelSize(latlng, entry.meters, 'MapUnit', zoom));
                return;
            }
            if (entry.kind === 'circle' && typeof entry.marker.setRadius === 'function') {
                const diameterPx = resolveMarkerPixelSize(latlng, entry.meters, 'MapUnit', zoom);
                const visible = isMapUnitVisible(diameterPx);
                const radius = visible ? Math.max(0.5, diameterPx / 2) : 0;
                if (entry.lastSize !== radius || entry.lastVisible !== visible) {
                    entry.lastSize = radius;
                    entry.lastVisible = visible;
                    entry.marker.setRadius(radius);
                    entry.marker.setStyle({
                        opacity: visible ? (entry.strokeOpacity != null ? entry.strokeOpacity : 1) : 0,
                        fillOpacity: visible
                            ? entry.fillOpacity != null
                                ? entry.fillOpacity
                                : 0.85
                            : 0,
                    });
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
        const sourceTable = props.sourceTable;
        if (sourceTable) {
            return sourceTable;
        }
        const layerKey = String(props.layerKey || '');
        if (layerKey.indexOf('topo:') === 0) {
            return layerKey.slice(5);
        }
        return layerKey || 'work';
    }

    const REFERENCE_LAYER_STYLES = {
        dgi: { color: '#dc2626', weight: 4, opacity: 0.95, fillOpacity: 0, dashArray: '10 8' },
        dgi_moscow_no_rent: { color: '#16a34a', weight: 4, opacity: 0.95, fillOpacity: 0, dashArray: '10 8' },
        oozt: { color: '#b45309', weight: 4, opacity: 0.95, fillOpacity: 0, dashArray: '10 8' },
        renew: { color: '#1d4ed8', weight: 4, opacity: 0.95, fillOpacity: 0, dashArray: '10 8' },
        rzd: { color: '#dc2626', weight: 4, opacity: 0.95, fillOpacity: 0, dashArray: '10 8' },
    };

    const REFERENCE_SIGNAL_TAPE = {
        dgi: {
            patternId: 'approval-dgi-signal-tape-pattern',
            stripe: '#dc2626',
            bg: '#ffffff',
            stroke: '#dc2626',
            title: 'Земельные участки',
        },
        dgi_moscow_no_rent: {
            patternId: 'approval-dgi-moscow-no-rent-tape',
            stripe: '#16a34a',
            bg: '#ffffff',
            stroke: '#16a34a',
            title: 'З/У г. Москва без аренды',
        },
        oozt: {
            patternId: 'approval-oozt-signal-tape-pattern',
            stripe: '#f59e0b',
            bg: '#ffffff',
            stroke: '#b45309',
            title: 'ООЗТ/ООПТ',
        },
        renew: {
            patternId: 'approval-renew-signal-tape-pattern',
            stripe: '#2563eb',
            bg: '#ffffff',
            stroke: '#1d4ed8',
            title: 'Реновация',
        },
        rzd: {
            patternId: 'approval-rzd-signal-tape-pattern',
            stripe: '#dc2626',
            bg: '#16a34a',
            stroke: '#dc2626',
            title: 'Полосы отвода ЖД',
        },
    };

    function referenceStyleKey(props) {
        const layerKey = (props && (props.layerKey || props.sourceTable)) || '';
        const subKey = layerKey === 'dgi' ? props.dgiSubKey : '';
        return subKey && REFERENCE_LAYER_STYLES[subKey] ? subKey : layerKey;
    }

    function referenceLayerStyle(layerKey) {
        return REFERENCE_LAYER_STYLES[layerKey] || null;
    }

    function isReferenceLayerKey(layerKey) {
        return Boolean(REFERENCE_LAYER_STYLES[layerKey]);
    }

    function syncReferencePanelVisibility() {
        Object.keys(REFERENCE_LAYER_STYLES).forEach(function (layerKey) {
            const input = document.querySelector('input[data-layer-key="' + layerKey + '"]');
            const row = input && input.closest ? input.closest('.approval-layer-row') : null;
            if (!row) {
                return;
            }
            const countEl = row.querySelector('.approval-layer-row__count');
            const raw = countEl
                ? parseInt(String(countEl.textContent || '').replace(/[^\d]/g, ''), 10)
                : 0;
            const count = Number.isFinite(raw) ? raw : 0;
            row.hidden = count <= 0;
            const featuresList = row.nextElementSibling;
            if (
                featuresList &&
                featuresList.classList &&
                featuresList.classList.contains('approval-layer-features')
            ) {
                if (row.hidden) {
                    featuresList.hidden = true;
                } else if (layerKey === 'dgi' && dgiFeatureRegistry.length) {
                    featuresList.hidden = false;
                }
            }
        });
        const groupInput = document.querySelector('input[data-layer-group="reference"]');
        const group = groupInput && groupInput.closest ? groupInput.closest('.approval-layer-group') : null;
        if (!group) {
            return;
        }
        const rows = group.querySelectorAll('.approval-layer-row');
        let anyVisible = false;
        for (let i = 0; i < rows.length; i += 1) {
            if (!rows[i].hidden) {
                anyVisible = true;
                break;
            }
        }
        group.hidden = !anyVisible;
    }

    function isDgiSubKeyChecked(subKey) {
        return dgiSubKeyChecked[subKey] !== false;
    }

    function setDgiFeatureVisible(entry) {
        if (!entry || !entry.leafletLayer || !map) {
            return;
        }
        const group = ensureLayerGroup('dgi');
        const parentCheckbox = document.querySelector('input[data-layer-key="dgi"]');
        const parentOn = (!parentCheckbox || parentCheckbox.checked) && map.hasLayer(group);
        const visible = isDgiSubKeyChecked(entry.dgiSubKey);
        if (visible && parentOn) {
            if (!group.hasLayer(entry.leafletLayer)) {
                group.addLayer(entry.leafletLayer);
            }
        } else if (group.hasLayer(entry.leafletLayer)) {
            group.removeLayer(entry.leafletLayer);
        }
    }

    function syncDgiFeaturesInLayer() {
        dgiFeatureRegistry.forEach(function (entry) {
            setDgiFeatureVisible(entry);
        });
    }

    function setDgiSubKeysChecked(checked) {
        DGI_SUBLAYER_SPECS.forEach(function (spec) {
            dgiSubKeyChecked[spec.key] = Boolean(checked);
        });
        document.querySelectorAll('input[data-dgi-sub-key]').forEach(function (checkbox) {
            checkbox.checked = Boolean(checked);
        });
    }

    function refreshDgiFeaturePanel() {
        const input = document.querySelector('input[data-layer-key="dgi"]');
        const row = input && input.closest ? input.closest('.approval-layer-row') : null;
        if (!row) {
            return;
        }

        const counts = {};
        dgiFeatureRegistry.forEach(function (entry) {
            if (!entry || !entry.dgiSubKey) {
                return;
            }
            counts[entry.dgiSubKey] = (counts[entry.dgiSubKey] || 0) + 1;
        });

        let list = row.nextElementSibling;
        if (!list || !list.classList || !list.classList.contains('approval-layer-features')) {
            list = document.createElement('ul');
            list.className = 'approval-layer-features';
            row.insertAdjacentElement('afterend', list);
        }
        list.setAttribute('data-for-layer', 'dgi');

        const items = DGI_SUBLAYER_SPECS.filter(function (spec) {
            return (counts[spec.key] || 0) > 0;
        });
        if (!items.length) {
            list.innerHTML = '';
            list.hidden = true;
            return;
        }
        list.hidden = false;
        list.innerHTML = items
            .map(function (spec) {
                const checked = isDgiSubKeyChecked(spec.key) ? ' checked' : '';
                return (
                    '<li class="approval-layer-feature">' +
                    '<label class="approval-layer-feature__label">' +
                    '<input type="checkbox" data-dgi-sub-key="' +
                    escapeHtml(spec.key) +
                    '"' +
                    checked +
                    ' />' +
                    '<span class="approval-layer-feature__name" title="' +
                    escapeHtml(spec.name) +
                    '">' +
                    escapeHtml(spec.name) +
                    '</span>' +
                    '</label>' +
                    '</li>'
                );
            })
            .join('');

        list.querySelectorAll('input[data-dgi-sub-key]').forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                const subKey = checkbox.dataset.dgiSubKey;
                dgiSubKeyChecked[subKey] = checkbox.checked;
                syncDgiFeaturesInLayer();
                reorderMapLayers();
            });
        });
    }

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function isBlankDisplayValue(value) {
        const text = String(value == null ? '' : value).trim();
        return !text || ['null', 'none', '-'].includes(text.toLowerCase());
    }

    function formatPopupAliasLabel(label) {
        return String(label || '')
            .replace(/\s*\(RootId\)\s*/gi, ' ')
            .replace(/\s+/g, ' ')
            .trim();
    }

    function isAreaPopupField(field, label) {
        return /площад/i.test(String(label || '')) || /area/i.test(String(field || ''));
    }

    function formatPopupNumber(value) {
        const text = String(value == null ? '' : value).trim().replace(',', '.');
        const number = Number(text);
        if (!Number.isFinite(number)) {
            return value;
        }
        return number.toFixed(2);
    }

    function formatPopupDisplayValue(value, field, label) {
        if (typeof value === 'boolean') {
            return value ? 'Да' : 'Нет';
        }
        const text = String(value == null ? '' : value).trim();
        const lower = text.toLowerCase();
        if (lower === 'true' || lower === 't') {
            return 'Да';
        }
        if (lower === 'false' || lower === 'f') {
            return 'Нет';
        }
        if (isAreaPopupField(field, label)) {
            return formatPopupNumber(value);
        }
        return value;
    }

    function styleTableNameFromProps(props) {
        const key = String((props && (props.sourceTable || props.layerKey)) || '');
        if (key.indexOf('topo:') === 0) {
            return key.slice(5);
        }
        return key;
    }

    const POPUP_HIDDEN_FIELDS = {
        svg: true,
        svg_vapoint: true,
        svg_hapoint: true,
    };

    function shouldHidePopupAlias(field, tableName) {
        const normalized = String(field || '').toLowerCase();
        if (!normalized) {
            return true;
        }
        if (POPUP_HIDDEN_FIELDS[normalized]) {
            return true;
        }
        if (normalized === 'nocalc' && tableName !== 'AbutmentLine') {
            return true;
        }
        return false;
    }

    function formatDgiShortSobstvRr(value) {
        const raw = String(value == null ? '' : value).trim();
        if (!raw || ['null', 'none', '-'].includes(raw.toLowerCase())) {
            return '';
        }
        if (raw.toUpperCase() === 'ЧС') {
            return 'Частная собственность';
        }
        return raw;
    }

    function ensureSignalPattern(patternId, stripeColorHex, backgroundColorHex) {
        if (!map || !patternId) {
            return null;
        }
        const svg =
            (signalTapeRenderer &&
                signalTapeRenderer._container &&
                signalTapeRenderer._container.ownerSVGElement) ||
            map.getPanes().overlayPane.querySelector('svg');
        if (!svg) {
            return null;
        }
        let defs = svg.querySelector('defs');
        if (!defs) {
            defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
            svg.insertBefore(defs, svg.firstChild);
        }
        if (!svg.querySelector('#' + patternId)) {
            const pattern = document.createElementNS('http://www.w3.org/2000/svg', 'pattern');
            pattern.setAttribute('id', patternId);
            pattern.setAttribute('patternUnits', 'userSpaceOnUse');
            pattern.setAttribute('width', '24');
            pattern.setAttribute('height', '24');
            pattern.setAttribute('patternTransform', 'rotate(45)');

            const bgRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
            bgRect.setAttribute('x', '0');
            bgRect.setAttribute('y', '0');
            bgRect.setAttribute('width', '24');
            bgRect.setAttribute('height', '24');
            bgRect.setAttribute('fill', backgroundColorHex);

            const stripeRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
            stripeRect.setAttribute('x', '0');
            stripeRect.setAttribute('y', '0');
            stripeRect.setAttribute('width', '12');
            stripeRect.setAttribute('height', '24');
            stripeRect.setAttribute('fill', stripeColorHex);

            pattern.appendChild(bgRect);
            pattern.appendChild(stripeRect);
            defs.appendChild(pattern);
        }
        return patternId;
    }

    function bindReferenceLayerPopup(layer, feature, layerKey) {
        const props = (feature && feature.properties) || {};
        const tape = REFERENCE_SIGNAL_TAPE[layerKey];
        if (!tape) {
            return;
        }
        let html = '<div class="approval-feature-popup"><div><strong>' + escapeHtml(tape.title) + '</strong></div>';
        if (layerKey === 'dgi') {
            const descr = props.descr;
            const address = props.address;
            const vri = props.vri;
            const sobstvRrDisplay = formatDgiShortSobstvRr(props.short_sobstv_rr);
            if (!isBlankDisplayValue(descr)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Кадастровый номер:</strong> ' +
                    escapeHtml(descr) +
                    '</div>';
            }
            if (!isBlankDisplayValue(address)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Адрес:</strong> ' +
                    escapeHtml(address) +
                    '</div>';
            }
            if (!isBlankDisplayValue(vri)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Назначение:</strong> ' +
                    escapeHtml(vri) +
                    '</div>';
            }
            if (sobstvRrDisplay) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Собственник:</strong> ' +
                    escapeHtml(sobstvRrDisplay) +
                    '</div>';
            }
        } else if (layerKey === 'oozt') {
            if (!isBlankDisplayValue(props.type)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Тип:</strong> ' +
                    escapeHtml(props.type) +
                    '</div>';
            }
            if (!isBlankDisplayValue(props.nomer1)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Номер:</strong> ' +
                    escapeHtml(props.nomer1) +
                    '</div>';
            }
            if (!isBlankDisplayValue(props.comment)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Комментарий:</strong> ' +
                    escapeHtml(props.comment) +
                    '</div>';
            }
        } else if (layerKey === 'rzd') {
            if (!isBlankDisplayValue(props.name)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Название:</strong> ' +
                    escapeHtml(props.name) +
                    '</div>';
            }
            if (!isBlankDisplayValue(props.comment_)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Комментарий:</strong> ' +
                    escapeHtml(props.comment_) +
                    '</div>';
            }
        } else if (layerKey === 'renew') {
            if (!isBlankDisplayValue(props.name)) {
                html +=
                    '<div class="approval-feature-popup__row"><strong>Название:</strong> ' +
                    escapeHtml(props.name) +
                    '</div>';
            }
        }
        html += '</div>';
        layer.bindPopup(html);
    }

    function attachSignalTapeHatching(layer, layerKey) {
        const tapeConfig = REFERENCE_SIGNAL_TAPE[layerKey];
        if (!tapeConfig || !layer) {
            return;
        }
        const restoreDom = function () {
            const patternId = ensureSignalPattern(
                tapeConfig.patternId,
                tapeConfig.stripe,
                tapeConfig.bg
            );
            const el = layer.getElement && layer.getElement();
            if (!patternId || !el) {
                return;
            }
            const o = layer.options || {};
            const dash =
                o.dashArray != null && o.dashArray !== ''
                    ? String(o.dashArray)
                    : '10 8';
            el.setAttribute('fill', 'url(#' + patternId + ')');
            el.setAttribute('fill-opacity', '0.25');
            el.setAttribute('stroke', tapeConfig.stroke);
            el.setAttribute('stroke-width', '2');
            el.setAttribute('stroke-dasharray', dash);
        };
        layer._approvalRestoreSignalTapeDom = restoreDom;
        layer.on('add', restoreDom);
        if (layer._map) {
            restoreDom();
        }
    }

    function adjacentBaseKey(layerKey) {
        const key = String(layerKey || '');
        if (key.indexOf('adjacent_approval') === 0) {
            return 'adjacent_approval';
        }
        if (key.indexOf('adjacent_objects') === 0) {
            return 'adjacent_objects';
        }
        return '';
    }

    function isAdjacentFeature(props) {
        if (!props) {
            return false;
        }
        if (props.adjacentRootKind) {
            return true;
        }
        return Boolean(adjacentBaseKey(props.layerKey));
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

    function adjacentLayerKey(base, sourceTable) {
        const table = String(sourceTable || '').trim();
        if (!table) {
            return base;
        }
        return base + ':' + table;
    }

    function adjacentLayerForRoot(rootId, kind, activeNRoot, sourceTable) {
        const active = String(activeNRoot || '').trim();
        const normalizedRoot = String(rootId || '').trim();
        let base;
        if (!active) {
            base = kind === 'n' ? 'adjacent_approval' : 'adjacent_objects';
        } else if (normalizedRoot === active) {
            base = 'adjacent_approval';
        } else {
            base = 'adjacent_objects';
        }
        return adjacentLayerKey(base, sourceTable);
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

    function setAdjacentHighlightStyle(entry, color, fillOpacity) {
        const layer = entry && entry.leafletLayer;
        if (!layer || typeof layer.setStyle !== 'function') {
            return;
        }
        const base = entry.baseStyle || {};
        const opacity =
            fillOpacity == null ? ADJACENT_ACTIVE_FILL_OPACITY_SOFT : fillOpacity;
        layer.setStyle(
            Object.assign({}, base, {
                color: color,
                weight: ADJACENT_ACTIVE_WEIGHT,
                fillOpacity: opacity,
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
        const phase = adjacentPulsePhase(nowMs);
        const color = lerpHexColor(
            ADJACENT_ACTIVE_STROKE_SOFT,
            ADJACENT_ACTIVE_STROKE_STRONG,
            phase
        );
        const fillOpacity =
            ADJACENT_ACTIVE_FILL_OPACITY_SOFT +
            (ADJACENT_ACTIVE_FILL_OPACITY_STRONG - ADJACENT_ACTIVE_FILL_OPACITY_SOFT) * phase;
        Object.keys(adjacentFeatureRegistry).forEach(function (key) {
            const entry = adjacentFeatureRegistry[key];
            if (!entry || !entry._adjacentHighlighted) {
                return;
            }
            setAdjacentHighlightStyle(entry, color, fillOpacity);
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
            setAdjacentHighlightStyle(
                entry,
                ADJACENT_ACTIVE_STROKE_SOFT,
                ADJACENT_ACTIVE_FILL_OPACITY_SOFT
            );
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
        const featureKey = leafletLayer._adjacentFeatureKey;
        const entry = featureKey ? adjacentFeatureRegistry[featureKey] : null;
        const featureChecked = !entry || entry.checked !== false;
        if (featureChecked) {
            if (!targetGroup.hasLayer(leafletLayer)) {
                targetGroup.addLayer(leafletLayer);
            }
        } else if (targetGroup.hasLayer(leafletLayer)) {
            targetGroup.removeLayer(leafletLayer);
        }
        const checkbox = document.querySelector('input[data-layer-key="' + targetKey + '"]');
        setLayerVisible(targetKey, !checkbox || checkbox.checked);
    }

    function registerAdjacentLeafletLayer(props, leafletLayer) {
        const key = adjacentFeatureKey(props);
        const kind =
            props.adjacentRootKind ||
            (adjacentBaseKey(props.layerKey) === 'adjacent_approval' ? 'n' : 'v');
        const existing = adjacentFeatureRegistry[key];
        const layerKey = String(props.layerKey || '');
        adjacentFeatureRegistry[key] = {
            leafletLayer: leafletLayer,
            rootId: props.RootId || '',
            kind: kind,
            sourceTable: props.sourceTable || '',
            name: props.Name || '',
            layerKey: layerKey,
            checked: existing && typeof existing.checked === 'boolean' ? existing.checked : true,
            baseStyle: adjacentBaseStyle(leafletLayer, props),
        };
        leafletLayer._adjacentFeatureKey = key;
    }

    function adjacentFeatureDisplayName(entry) {
        const name = String((entry && entry.name) || '').trim();
        if (name && !isBlankDisplayValue(name)) {
            return name;
        }
        const rootId = String((entry && entry.rootId) || '').trim();
        if (rootId) {
            return 'ID Паспорта ' + rootId;
        }
        return 'Без названия';
    }

    function isAdjacentLayerKey(layerKey) {
        return Boolean(adjacentBaseKey(layerKey));
    }

    function isAdjacentParentLayerChecked(layerKey) {
        const checkbox = document.querySelector('input[data-layer-key="' + layerKey + '"]');
        return !checkbox || checkbox.checked;
    }

    function setAdjacentFeatureVisible(featureKey, visible) {
        const entry = adjacentFeatureRegistry[featureKey];
        if (!entry || !entry.leafletLayer || !map) {
            return;
        }
        const layerKey = entry.layerKey || '';
        if (!layerKey) {
            return;
        }
        const group = ensureLayerGroup(layerKey);
        const parentOn = isAdjacentParentLayerChecked(layerKey) && map.hasLayer(group);
        if (visible && parentOn) {
            if (!group.hasLayer(entry.leafletLayer)) {
                group.addLayer(entry.leafletLayer);
            }
        } else if (group.hasLayer(entry.leafletLayer)) {
            group.removeLayer(entry.leafletLayer);
        }
    }

    function syncAdjacentFeaturesInLayer(layerKey) {
        if (!isAdjacentLayerKey(layerKey)) {
            return;
        }
        Object.keys(adjacentFeatureRegistry).forEach(function (key) {
            const entry = adjacentFeatureRegistry[key];
            if (!entry || entry.layerKey !== layerKey) {
                return;
            }
            setAdjacentFeatureVisible(key, entry.checked !== false);
        });
    }

    function refreshAdjacentFeaturePanel() {
        const groupInput = document.querySelector('input[data-layer-group="adjacent"]');
        const group = groupInput && groupInput.closest ? groupInput.closest('.approval-layer-group') : null;
        if (!group) {
            return;
        }

        const byLayer = {};
        Object.keys(adjacentFeatureRegistry).forEach(function (key) {
            const entry = adjacentFeatureRegistry[key];
            if (!entry || !entry.layerKey) {
                return;
            }
            if (!byLayer[entry.layerKey]) {
                byLayer[entry.layerKey] = [];
            }
            byLayer[entry.layerKey].push({ key: key, entry: entry });
        });

        const layerInputs = group.querySelectorAll('input[data-layer-key]');
        layerInputs.forEach(function (input) {
            const layerKey = input.dataset.layerKey || '';
            if (!isAdjacentLayerKey(layerKey)) {
                return;
            }
            const row = input.closest('.approval-layer-row');
            if (!row) {
                return;
            }

            let list = row.nextElementSibling;
            if (!list || !list.classList || !list.classList.contains('approval-layer-features')) {
                list = document.createElement('ul');
                list.className = 'approval-layer-features';
                row.insertAdjacentElement('afterend', list);
            }
            list.setAttribute('data-for-layer', layerKey);

            const items = byLayer[layerKey] || [];
            items.sort(function (a, b) {
                const an = adjacentFeatureDisplayName(a.entry).toLowerCase();
                const bn = adjacentFeatureDisplayName(b.entry).toLowerCase();
                if (an < bn) {
                    return -1;
                }
                if (an > bn) {
                    return 1;
                }
                return String(a.key).localeCompare(String(b.key));
            });

            if (!items.length) {
                list.innerHTML = '';
                list.hidden = true;
                return;
            }
            list.hidden = false;
            list.innerHTML = items
                .map(function (item) {
                    const label = adjacentFeatureDisplayName(item.entry);
                    const checked = item.entry.checked !== false ? ' checked' : '';
                    return (
                        '<li class="approval-layer-feature">' +
                        '<label class="approval-layer-feature__label">' +
                        '<input type="checkbox" data-adjacent-feature-key="' +
                        escapeHtml(item.key) +
                        '"' +
                        checked +
                        ' />' +
                        '<span class="approval-layer-feature__name" title="' +
                        escapeHtml(label) +
                        '">' +
                        escapeHtml(label) +
                        '</span>' +
                        '</label>' +
                        '</li>'
                    );
                })
                .join('');

            list.querySelectorAll('input[data-adjacent-feature-key]').forEach(function (checkbox) {
                checkbox.addEventListener('change', function () {
                    const featureKey = checkbox.dataset.adjacentFeatureKey;
                    const entry = adjacentFeatureRegistry[featureKey];
                    if (!entry) {
                        return;
                    }
                    entry.checked = checkbox.checked;
                    setAdjacentFeatureVisible(featureKey, checkbox.checked);
                    reorderMapLayers();
                });
            });
        });
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
                activeAdjacentNRoot,
                entry.sourceTable
            );
            entry.layerKey = targetKey;
            moveLeafletLayerToGroup(entry.leafletLayer, targetKey);
            applyAdjacentFeatureStyle(
                entry,
                isAdjacentRootHighlighted(entry.rootId, entry.kind, activeAdjacentNRoot)
            );
            setAdjacentFeatureVisible(key, entry.checked !== false);
        });
        syncAdjacentHighlightPulse();
        refreshAdjacentFeaturePanel();
        reorderMapLayers();
    }

    function styleFeature(feature) {
        const props = feature.properties || {};
        const displayKey = props.layerKey || props.sourceTable || 'work';
        const refStyle = referenceLayerStyle(referenceStyleKey(props));
        if (refStyle) {
            return Object.assign({}, refStyle);
        }
        const styleKey = styleTableKey(props);
        const geometry = feature.geometry || {};
        const type = geometry.type || '';
        const tableDef = getTableStyleDef(styleKey);
        const geometryType = tableDef ? tableDef.geometry : null;
        // Use bare table name so topo:X and work X share the same hashColor fallback.
        const fallbackKey = styleKey || displayKey;

        if (type === 'Point' || type === 'MultiPoint') {
            return {};
        }
        if (type === 'LineString' || type === 'MultiLineString') {
            return leafletPathStyle(resolveRuleStyle(styleKey, props), fallbackKey, geometryType || 'line');
        }
        return leafletPathStyle(resolveRuleStyle(styleKey, props), fallbackKey, geometryType || 'polygon');
    }

    function buildTextLabelIcon(textHtml, fontPx, color, rotationDeg) {
        const fontSize = Math.max(1, Math.round(fontPx));
        const size = Math.max(2, Math.round(fontSize * 1.4));
        const half = Math.round(size / 2);
        const rotate =
            Number.isFinite(rotationDeg) && rotationDeg !== 0
                ? 'transform:rotate(' + rotationDeg + 'deg);'
                : '';
        return L.divIcon({
            className: 'approval-topo-text-label',
            html:
                '<div style="color:' +
                color +
                ';font-size:' +
                fontSize +
                'px;font-weight:500;line-height:1.1;white-space:pre;text-align:center;' +
                'pointer-events:none;user-select:none;' +
                rotate +
                '">' +
                textHtml +
                '</div>',
            iconSize: [size * 4, size],
            iconAnchor: [size * 2, half],
        });
    }

    function applyTextLabelSize(entry, fontPx) {
        if (!entry || !entry.marker) {
            return;
        }
        const visible = isMapUnitVisible(fontPx);
        const size = visible ? Math.max(1, Math.round(fontPx)) : 1;
        if (entry.lastSize === size && entry.lastVisible === visible) {
            return;
        }
        entry.lastSize = size;
        entry.lastVisible = visible;
        const color = entry.color || '#000000';
        const rotationDeg = entry.rotationDeg;
        if (visible) {
            entry.marker.setIcon(buildTextLabelIcon(entry.textHtml, size, color, rotationDeg));
        }
        setLeafletMarkerOpacity(entry.marker, visible ? 1 : 0);
    }

    function createTextLabelMarker(latlng, feature, labeling) {
        const props = feature.properties || {};
        const field = labeling.field;
        const rawText = propertyValue(props, field);
        if (rawText === null) {
            return null;
        }
        const text = String(rawText).replace(/\\P/g, '\n');
        if (!text.trim()) {
            return null;
        }
        const sizeUnit = labeling.fontSizeUnit || 'Point';
        const baseSize = Number(labeling.fontSize) > 0 ? Number(labeling.fontSize) : 12;
        const color = labeling.color || '#000000';
        let fontPx;
        if (sizeUnit === 'MapUnit') {
            fontPx = resolveMarkerPixelSize(latlng, baseSize, 'MapUnit');
        } else if (sizeUnit === 'MM') {
            fontPx = Math.max(8, Math.round(baseSize * 3.78));
        } else {
            // Point ≈ CSS px at 1:1 for screen labels
            fontPx = Math.max(8, Math.round(baseSize));
        }

        let rotationDeg = null;
        const rotField = labeling.rotationField;
        if (rotField) {
            const angleRaw = propertyValue(props, rotField);
            const angleNum = Number(angleRaw);
            if (Number.isFinite(angleNum)) {
                rotationDeg =
                    labeling.rotationMode === 'complement' ? 360 - angleNum : angleNum;
            }
        }

        const textHtml = escapeHtml(text).replace(/\n/g, '<br>');
        const mapUnit = sizeUnit === 'MapUnit';
        const visible = mapUnit ? isMapUnitVisible(fontPx) : true;
        const renderPx = mapUnit ? (visible ? Math.max(1, Math.round(fontPx)) : 1) : fontPx;
        const marker = L.marker(latlng, {
            icon: buildTextLabelIcon(textHtml, renderPx, color, rotationDeg),
            opacity: visible ? 1 : 0,
            interactive: false,
            zIndexOffset: 500,
        });

        if (mapUnit) {
            mapUnitMarkers.push({
                kind: 'text',
                marker: marker,
                meters: baseSize,
                textHtml: textHtml,
                color: color,
                rotationDeg: rotationDeg,
                lastSize: renderPx,
                lastVisible: visible,
            });
        }
        return marker;
    }

    function invisiblePointMarker(latlng) {
        // Placeholder so GeoJSON still has a layer; never a white MapUnit disk.
        return L.circleMarker(latlng, {
            radius: 0,
            opacity: 0,
            fillOpacity: 0,
            weight: 0,
            interactive: false,
            pane: 'markerPane',
        });
    }

    function topotextLabelingConfig(tableDef) {
        const labeling = tableDef && tableDef.labeling;
        if (labeling && labeling.field) {
            return labeling;
        }
        // Hardcoded defaults if page embed is stale / missing labeling block.
        return {
            field: 'text',
            fontSize: 1,
            fontSizeUnit: 'MapUnit',
            color: '#000000',
            rotationField: 'angle',
            rotationMode: 'complement',
        };
    }

    function pointToLayer(feature, latlng) {
        const props = feature.properties || {};
        const styleKey = styleTableKey(props);
        const tableDef = getTableStyleDef(styleKey);
        const isTopotext = String(styleKey || '').toLowerCase() === 'topotext';

        // Only "Тексты топоосновы" use QGIS labeling as primary symbology.
        // Never fall through to white SimpleMarker (QGIS uses alpha=0 anchors).
        if (isTopotext) {
            if (String(props.layer || '') === 'Фотофиксация') {
                const photoUrl = photoFixIconUrl();
                if (photoUrl) {
                    const size = resolveMarkerPixelSize(latlng, 12, 'MM');
                    const fractions = resolveIconAnchorFractions(
                        photoUrl,
                        props,
                        null,
                        'center',
                        'center'
                    );
                    return createSvgMarker(
                        latlng,
                        photoUrl,
                        size,
                        feature,
                        null,
                        fractions[0],
                        fractions[1]
                    );
                }
                return invisiblePointMarker(latlng);
            }
            const textMarker = createTextLabelMarker(
                latlng,
                feature,
                topotextLabelingConfig(tableDef)
            );
            if (textMarker) {
                return textMarker;
            }
            return invisiblePointMarker(latlng);
        }

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

        const colors = hashColor(styleKey);
        const baseRadius = (ruleStyle && ruleStyle.radius) || 5;
        const stroke = (ruleStyle && ruleStyle.color) || colors.stroke;
        const fill = (ruleStyle && ruleStyle.fillColor) || colors.fill;
        const fillOpacity = (ruleStyle && ruleStyle.fillOpacity) !== undefined
            ? Number(ruleStyle.fillOpacity)
            : 0.85;
        const strokeOpacity =
            ruleStyle && ruleStyle.opacity !== undefined ? Number(ruleStyle.opacity) : 1;
        // QGIS alpha=0 labeling anchors must stay invisible.
        if (
            Number.isFinite(fillOpacity) &&
            fillOpacity <= 0 &&
            Number.isFinite(strokeOpacity) &&
            strokeOpacity <= 0
        ) {
            return invisiblePointMarker(latlng);
        }
        let radius;
        let mapMetersForCircle = null;
        if (sizeUnit === 'MapUnit') {
            // QGIS SimpleMarker size is diameter; prefer iconSize when radius is a tiny halo.
            mapMetersForCircle =
                Number(baseRadius) > 0.5
                    ? Number(baseRadius)
                    : Number(ruleStyle && ruleStyle.iconSize) > 0.5
                      ? Number(ruleStyle.iconSize)
                      : 14;
            const diameterPx = resolveMarkerPixelSize(latlng, mapMetersForCircle, 'MapUnit');
            if (!isMapUnitVisible(diameterPx)) {
                radius = 0;
            } else {
                radius = Math.max(0.5, diameterPx / 2);
            }
        } else {
            radius = Math.round(baseRadius * CIRCLE_MARKER_SIZE_SCALE);
        }
        const circleVisible = sizeUnit !== 'MapUnit' || radius > 0;
        const circle = L.circleMarker(latlng, {
            radius: radius,
            color: stroke,
            weight: 2,
            opacity: circleVisible ? (Number.isFinite(strokeOpacity) ? strokeOpacity : 1) : 0,
            fillColor: fill,
            fillOpacity: circleVisible
                ? Number.isFinite(fillOpacity)
                    ? fillOpacity
                    : 0.85
                : 0,
            pane: 'markerPane',
        });
        if (sizeUnit === 'MapUnit' && mapMetersForCircle != null) {
            mapUnitMarkers.push({
                kind: 'circle',
                marker: circle,
                meters: mapMetersForCircle,
                lastSize: radius,
                lastVisible: circleVisible,
                strokeOpacity: Number.isFinite(strokeOpacity) ? strokeOpacity : 1,
                fillOpacity: Number.isFinite(fillOpacity) ? fillOpacity : 0.85,
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
            if (isAdjacentLayerKey(layerKey)) {
                syncAdjacentFeaturesInLayer(layerKey);
            }
            if (layerKey === 'dgi') {
                syncDgiFeaturesInLayer();
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
            map.fitBounds(bounds.pad(0.12), { maxZoom: APPROVAL_MAP_MAX_ZOOM });
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
            map.fitBounds(bounds.pad(0.12), { maxZoom: APPROVAL_MAP_MAX_ZOOM });
        }
        return true;
    }

    function initLayerPanelControls(config) {
        const layerGroupMap = (config && config.layerGroups) || {};
        const layerCheckboxes = Array.from(document.querySelectorAll('input[data-layer-key]'));
        const groupCheckboxes = Array.from(document.querySelectorAll('input[data-layer-group]'));

        layerCheckboxes.forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                const layerKey = checkbox.dataset.layerKey;
                if (layerKey === 'dgi') {
                    setDgiSubKeysChecked(checkbox.checked);
                }
                setLayerVisible(layerKey, checkbox.checked);
            });
        });

        groupCheckboxes.forEach(function (groupCheckbox) {
            groupCheckbox.addEventListener('change', function () {
                const groupKeys = layerGroupMap[groupCheckbox.dataset.layerGroup] || [];
                groupKeys.forEach(function (layerKey) {
                    const layerCheckbox = document.querySelector(
                        'input[data-layer-key="' + layerKey + '"]'
                    );
                    if (layerCheckbox) {
                        layerCheckbox.checked = groupCheckbox.checked;
                    }
                    if (layerKey === 'dgi') {
                        setDgiSubKeysChecked(groupCheckbox.checked);
                    }
                    setLayerVisible(layerKey, groupCheckbox.checked);
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

    function pendingGeometryHighlightStyle() {
        return {
            color: '#5b21b6',
            weight: 5,
            dashArray: null,
            fillColor: '#7c3aed',
            fillOpacity: 0.4,
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

    function applyStyleToPendingChild(child, isHighlighted) {
        if (!child || typeof child.setStyle !== 'function') {
            return;
        }
        const style = isHighlighted
            ? pendingGeometryHighlightStyle()
            : pendingGeometryStyle();
        child.setStyle(style);
        if (typeof child.setRadius === 'function') {
            child.setRadius(isHighlighted ? 9 : 7);
        }
        if (isHighlighted && typeof child.bringToFront === 'function') {
            child.bringToFront();
        }
    }

    function highlightPendingGeometry(index) {
        const layer = geometryLayerByKey[PENDING_LAYER_KEY];
        if (!layer) {
            return;
        }
        const targetIndex = Number(index);
        layer.eachLayer(function (child) {
            const props =
                (child.feature && child.feature.properties) || {};
            const childIndex = Number(props.pendingIndex);
            applyStyleToPendingChild(
                child,
                !Number.isNaN(targetIndex) && childIndex === targetIndex
            );
        });
    }

    function clearPendingGeometryHighlight() {
        const layer = geometryLayerByKey[PENDING_LAYER_KEY];
        if (!layer) {
            return;
        }
        layer.eachLayer(function (child) {
            applyStyleToPendingChild(child, false);
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
        const features = items.map(function (geometry, index) {
            return {
                type: 'Feature',
                geometry: geometry,
                properties: {
                    layerKey: PENDING_LAYER_KEY,
                    pendingIndex: index,
                },
            };
        });
        const layer = L.geoJSON(
            { type: 'FeatureCollection', features: features },
            {
                style: function () {
                    return pendingGeometryStyle();
                },
                pointToLayer: function (feat, latlng) {
                    const index =
                        feat && feat.properties
                            ? Number(feat.properties.pendingIndex) + 1
                            : 1;
                    return L.circleMarker(latlng, {
                        radius: 7,
                        color: '#7c3aed',
                        weight: 3,
                        dashArray: '8 6',
                        fillColor: 'rgba(124, 58, 237, 0.35)',
                        fillOpacity: 0.9,
                    }).bindTooltip('Объект ' + index, { sticky: true });
                },
                onEachFeature: function (feat, lyr) {
                    const index =
                        feat && feat.properties
                            ? Number(feat.properties.pendingIndex) + 1
                            : 1;
                    lyr.bindTooltip('Объект ' + index, { sticky: true });
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
                label = 'ID Паспорта ' + caseItem.n_root + ': ' + label;
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
        map.fitBounds(bounds.pad(0.2), { maxZoom: APPROVAL_MAP_MAX_ZOOM });
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
        map.fitBounds(combined.pad(0.2), { maxZoom: APPROVAL_MAP_MAX_ZOOM });
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

    function isMeasureModeActive() {
        return !!(
            window.PassViewer &&
            typeof window.PassViewer.isMeasureMode === 'function' &&
            window.PassViewer.isMeasureMode(map)
        );
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
            maxZoom: APPROVAL_MAP_MAX_ZOOM,
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

        if (window.PassViewer && typeof window.PassViewer.attachBasemapControl === 'function') {
            window.PassViewer.attachBasemapControl(map, {
                defaultMode: 'none',
                position: 'topright',
                scopeRoot: mapEl.parentElement,
            });
        }
        if (window.PassViewer && typeof window.PassViewer.attachMapUtilityControls === 'function') {
            window.PassViewer.attachMapUtilityControls(map, {
                extraUiSelectors: '.approval-draw-toolbar, .approval-map-notice',
                onStartMeasure: function () {
                    if (
                        window.ApprovalEventDraw &&
                        typeof window.ApprovalEventDraw.stopDrawMode === 'function'
                    ) {
                        window.ApprovalEventDraw.stopDrawMode();
                    }
                },
                shouldPreserveCursor: function () {
                    return !!(
                        window.ApprovalEventDraw &&
                        typeof window.ApprovalEventDraw.isDrawMode === 'function' &&
                        window.ApprovalEventDraw.isDrawMode()
                    );
                },
            });
        }

        managedLayers = {};
        mapUnitMarkers = [];
        selectablePolygonLayers = [];
        signalTapeRenderer = L.svg({ padding: 0.5 });
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
        map.on('click', handleMapObjectChoice);

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

        function isDrawModeActive() {
            return !!(
                window.ApprovalEventDraw &&
                typeof window.ApprovalEventDraw.isDrawMode === 'function' &&
                window.ApprovalEventDraw.isDrawMode()
            );
        }

        // Зеркало ADJACENT_SOURCE_LABELS из approval/work_adjacent.py (панель слоёв).
        const ADJACENT_SOURCE_LABELS = {
            YardPoly: 'ДТ',
            OdhPoly: 'ОДХ',
            OznPoly: 'ОО',
        };

        function bindAdjacentPopup(layer, feature) {
            const props = feature.properties || {};
            // «Добавить событие» доступна инспектору только для смежных объектов
            // вне согласования; участники согласования получают инфо-попап.
            const withAction =
                (props.layerKey === 'adjacent_objects' || props.adjacentRootKind === 'v') &&
                isInspectorForSelectedApprove();

            const rootId = String(props.RootId || '');
            const name = String(props.Name || '');
            const ownerId = String(props.OwnerLegalPersonId || '');
            const ownerName = String(props.OwnerLegalPersonName || '');
            const sourceLabel =
                ADJACENT_SOURCE_LABELS[props.sourceTable] || props.sourceTable || '';
            const layerTitle =
                (props.adjacentRootKind === 'v' ? 'Смежные объекты' : 'Смежный объект для согласования') +
                (sourceLabel ? ' · ' + sourceLabel : '');

            function popupRow(label, value) {
                return (
                    '<div class="approval-adjacent-popup__row"><strong>' +
                    label +
                    ':</strong> ' +
                    escapeHtml(value) +
                    '</div>'
                );
            }

            const titleHtml =
                '<div class="approval-adjacent-popup__title">' +
                escapeHtml(layerTitle) +
                '</div>';
            const rows =
                (rootId ? popupRow('ID Паспорта', rootId) : '') +
                (name ? popupRow('Название', name) : '') +
                (ownerName || ownerId
                    ? popupRow('Балансодержатель', ownerName || ownerId)
                    : '');
            let actionHtml = '';
            if (withAction) {
                const geomEncoded = feature.geometry
                    ? encodeURIComponent(JSON.stringify(feature.geometry))
                    : '';
                actionHtml =
                    '<button type="button" class="approval-adjacent-popup__action"' +
                    ' data-action="create-event"' +
                    ' data-root-id="' +
                    escapeHtml(rootId) +
                    '"' +
                    ' data-name="' +
                    escapeHtml(name) +
                    '"' +
                    ' data-owner-id="' +
                    escapeHtml(ownerId) +
                    '"' +
                    ' data-geometry="' +
                    geomEncoded +
                    '">Добавить событие</button>';
            }
            const html =
                '<div class="approval-adjacent-popup">' + titleHtml + rows + actionHtml + '</div>';

            layer.bindPopup(html);
            layer.on('popupopen', function () {
                if (isDrawModeActive() || isMeasureModeActive()) {
                    layer.closePopup();
                    return;
                }
                const popup = layer.getPopup();
                const container = popup && popup.getElement ? popup.getElement() : null;
                if (!container) {
                    return;
                }
                const btn = container.querySelector('.approval-adjacent-popup__action');
                if (!btn || btn.dataset.bound === '1') {
                    return;
                }
                btn.dataset.bound = '1';
                L.DomEvent.disableClickPropagation(btn);
                btn.addEventListener('click', function () {
                    if (isDrawModeActive()) {
                        return;
                    }
                    const eventsApi = window.ApprovalEvents || {};
                    const root = btn.getAttribute('data-root-id') || '';
                    let geometry = null;
                    const encoded = btn.getAttribute('data-geometry') || '';
                    if (encoded) {
                        try {
                            geometry = JSON.parse(decodeURIComponent(encoded));
                        } catch (err) {
                            geometry = null;
                        }
                    }
                    if (typeof eventsApi.openCreateEventFromAdjacent === 'function') {
                        eventsApi.openCreateEventFromAdjacent({
                            rootId: root,
                            name: btn.getAttribute('data-name') || '',
                            ownerId: btn.getAttribute('data-owner-id') || '',
                            geometry: geometry,
                        });
                    }
                    layer.closePopup();
                });
            });
        }

        function bindTaskObjectPopup(layer, feature) {
            const props = feature.properties || {};
            if (!isApprovalObjectFeature(feature)) {
                return;
            }
            const tableName = styleTableNameFromProps(props);
            const tableDef = getTableStyleDef(props.sourceTable || props.layerKey);
            const aliases = tableDef && Array.isArray(tableDef.aliases) ? tableDef.aliases : [];
            const layerTitle = String((tableDef && tableDef.label) || tableName || '').trim();
            const rows = aliases.map(function (alias) {
                const field = String(alias.field || '');
                const label = formatPopupAliasLabel(alias.label);
                if (
                    !field ||
                    !label ||
                    shouldHidePopupAlias(field, tableName) ||
                    !Object.prototype.hasOwnProperty.call(props, field)
                ) {
                    return '';
                }
                const displayField = field + '__display';
                const value = Object.prototype.hasOwnProperty.call(props, displayField)
                    ? props[displayField]
                    : props[field];
                if (value === null || value === undefined || String(value).trim() === '') {
                    return '';
                }
                return (
                    '<div class="approval-feature-popup__row"><strong>' +
                    escapeHtml(label) +
                    ':</strong> ' +
                    escapeHtml(formatPopupDisplayValue(value, field, label)) +
                    '</div>'
                );
            }).filter(Boolean);
            if (!rows.length && !layerTitle) {
                return;
            }
            const titleHtml = layerTitle
                ? '<div class="approval-feature-popup__title">' + escapeHtml(layerTitle) + '</div>'
                : '';
            const popupHtml =
                '<div class="approval-feature-popup">' + titleHtml + rows.join('') + '</div>';
            let popupLayers = [layer];
            // PostGIS point tables are commonly stored as MultiPoint even when each
            // feature contains one coordinate. Leaflet represents such a feature as
            // a FeatureGroup, while the SVG registry contains its child Marker. Bind
            // the popup to those markers so they also participate in radius search.
            if (
                feature.geometry &&
                feature.geometry.type === 'MultiPoint' &&
                layer.eachLayer
            ) {
                popupLayers = [];
                layer.eachLayer(function (childLayer) {
                    if (childLayer && childLayer.bindPopup) {
                        childLayer._approvalFeature = feature;
                        popupLayers.push(childLayer);
                    }
                });
            }
            popupLayers.forEach(function (popupLayer) {
                popupLayer.bindPopup(popupHtml, { autoPan: false });
                popupLayer.on('popupopen', function () {
                    if (isDrawModeActive() || isMeasureModeActive()) {
                        popupLayer.closePopup();
                    }
                });
            });
        }

        function onEachFeature(feature, layer) {
            layer._approvalFeature = feature;
            const props = feature.properties || {};
            const layerKey = props.layerKey || props.sourceTable;
            if (isReferenceLayerKey(layerKey)) {
                bindReferenceLayerPopup(layer, feature, layerKey);
                attachSignalTapeHatching(layer, referenceStyleKey(props));
            }
            if (isAdjacentFeature(props)) {
                bindAdjacentPopup(layer, feature);
            }
            bindTaskObjectPopup(layer, feature);
            if (
                feature.geometry &&
                (feature.geometry.type === 'Polygon' || feature.geometry.type === 'MultiPolygon') &&
                isApprovalObjectFeature(feature) &&
                layer.getPopup &&
                layer.getPopup()
            ) {
                selectablePolygonLayers.push(layer);
            }
        }

        function addMapFeatures(features) {
            if (!Array.isArray(features) || !features.length) {
                return 0;
            }
            let added = 0;
            const countsByKey = {};
            features.forEach(function (feature) {
                try {
                    const props = feature.properties || {};
                    const layerKey = props.layerKey || props.sourceTable;
                    if (!layerKey) {
                        return;
                    }
                    const targetGroup = ensureLayerGroup(layerKey);
                    const checkbox = document.querySelector('input[data-layer-key="' + layerKey + '"]');
                    const isVisible = !checkbox || checkbox.checked;
                    const geoJsonOptions = {
                        style: styleFeature,
                        onEachFeature: onEachFeature,
                        pointToLayer: pointToLayer,
                    };
                    if (isReferenceLayerKey(layerKey) && signalTapeRenderer) {
                        geoJsonOptions.renderer = signalTapeRenderer;
                    }

                    L.geoJSON(feature, geoJsonOptions).eachLayer(function (layer) {
                        if (isAdjacentFeature(props)) {
                            registerAdjacentLeafletLayer(props, layer);
                            const entry = adjacentFeatureRegistry[adjacentFeatureKey(props)];
                            if (!entry || entry.checked !== false) {
                                targetGroup.addLayer(layer);
                            }
                        } else if (layerKey === 'dgi' && props.dgiSubKey) {
                            dgiFeatureRegistry.push({
                                leafletLayer: layer,
                                dgiSubKey: props.dgiSubKey,
                            });
                            if (isDgiSubKeyChecked(props.dgiSubKey)) {
                                targetGroup.addLayer(layer);
                            }
                        } else {
                            targetGroup.addLayer(layer);
                        }
                    });

                    if (!isVisible) {
                        setLayerVisible(layerKey, false);
                    } else if (isAdjacentLayerKey(layerKey)) {
                        syncAdjacentFeaturesInLayer(layerKey);
                    } else if (layerKey === 'dgi') {
                        syncDgiFeaturesInLayer();
                    }
                    added += 1;
                    countsByKey[layerKey] = (countsByKey[layerKey] || 0) + 1;
                } catch (err) {
                    console.warn('approval map: failed to add feature', err);
                }
            });
            Object.keys(countsByKey).forEach(function (layerKey) {
                if (REFERENCE_LAYER_STYLES[layerKey]) {
                    setLayerCount(layerKey, countsByKey[layerKey], true);
                }
            });
            if (Object.keys(countsByKey).some(isAdjacentLayerKey)) {
                refreshAdjacentFeaturePanel();
            }
            if (countsByKey.dgi) {
                refreshDgiFeaturePanel();
            }
            return added;
        }

        function setLayerCount(layerKey, count, accumulate) {
            const row = document.querySelector('input[data-layer-key="' + layerKey + '"]');
            if (!row) {
                return;
            }
            const countEl = row.parentElement && row.parentElement.querySelector('.approval-layer-row__count');
            if (!countEl) {
                return;
            }
            let next = count;
            if (accumulate) {
                const current = parseInt(String(countEl.textContent || '').replace(/[^\d]/g, ''), 10);
                next = (Number.isFinite(current) ? current : 0) + count;
            }
            countEl.textContent = '(' + next + ')';
            if (isReferenceLayerKey(layerKey)) {
                syncReferencePanelVisibility();
            }
        }

        syncReferencePanelVisibility();

        if (mapGeojson && Array.isArray(mapGeojson.features)) {
            addMapFeatures(mapGeojson.features);
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

        loadDeferredMapLayers(config, addMapFeatures);
    }

    function showDbLoadingModal(detailText) {
        const modal = document.getElementById('db-loading-modal');
        const detail = document.getElementById('approval-db-loading-detail');
        if (detail) {
            detail.textContent = detailText || '';
        }
        if (modal) {
            modal.style.display = 'flex';
        }
    }

    function hideDbLoadingModal() {
        const modal = document.getElementById('db-loading-modal');
        if (modal) {
            modal.style.display = 'none';
        }
    }

    function setMapLoadStatus(text) {
        const el = document.getElementById('approval-map-load-status');
        if (!el) {
            return;
        }
        if (!text) {
            el.hidden = true;
            el.textContent = '';
            return;
        }
        el.hidden = false;
        el.textContent = text;
    }

    async function fetchMapLayerFeatures(url, approveId, layerKey) {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': getCookie('csrftoken') || '',
            },
            body: JSON.stringify({
                approve_id: approveId,
                layer: layerKey,
            }),
        });
        let data = {};
        try {
            data = await response.json();
        } catch (err) {
            throw new Error('Некорректный ответ сервера.');
        }
        if (!response.ok || !data.ok) {
            throw new Error(data.error || 'Ошибка загрузки слоя.');
        }
        return Array.isArray(data.features) ? data.features : [];
    }

    async function loadDeferredMapLayers(config, addMapFeatures) {
        const specs = Array.isArray(config.mapLayerLoadOrder) ? config.mapLayerLoadOrder : [];
        const approveId = config.selectedApproveId;
        const url = config.apiUrls && config.apiUrls.mapLayer;
        if (!specs.length || !approveId || !url || typeof addMapFeatures !== 'function') {
            return;
        }

        showDbLoadingModal();
        let loadedCount = 0;
        let failedCount = 0;
        let didFit = false;
        try {
            for (let i = 0; i < specs.length; i += 1) {
                const spec = specs[i] || {};
                const layerKey = spec.key;
                if (!layerKey) {
                    continue;
                }
                const label = spec.label || layerKey;
                setMapLoadStatus('Загружаем: ' + label + '...');
                showDbLoadingModal(label);
                try {
                    const features = await fetchMapLayerFeatures(url, approveId, layerKey);
                    const added = addMapFeatures(features);
                    if (isReferenceLayerKey(layerKey) && !added) {
                        const row = document.querySelector('input[data-layer-key="' + layerKey + '"]');
                        const countEl =
                            row &&
                            row.parentElement &&
                            row.parentElement.querySelector('.approval-layer-row__count');
                        if (countEl) {
                            countEl.textContent = '(0)';
                        }
                        syncReferencePanelVisibility();
                    }
                    if (added) {
                        loadedCount += 1;
                        reorderMapLayers();
                        if (!didFit) {
                            if (!fitTaskGuidBounds(config.focusTaskGuid)) {
                                fitVisibleBounds();
                            }
                            didFit = true;
                        }
                        refreshMapUnitMarkers();
                    } else {
                        loadedCount += 1;
                    }
                } catch (layerError) {
                    failedCount += 1;
                    console.warn('approval map layer load failed:', layerKey, layerError);
                }
            }
            if (!loadedCount && failedCount) {
                setMapLoadStatus('Не удалось загрузить слои карты.');
            } else if (failedCount) {
                setMapLoadStatus(
                    'Карта готова (загружено ' + (specs.length - failedCount) + ' из ' + specs.length + ' слоёв).'
                );
            } else {
                setMapLoadStatus('');
            }
        } finally {
            hideDbLoadingModal();
        }
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
        highlightPendingGeometry: highlightPendingGeometry,
        clearPendingGeometryHighlight: clearPendingGeometryHighlight,
        getPendingMessageGeometry: getPendingMessageGeometry,
        stopMeasureMode: function () {
            if (window.PassViewer && typeof window.PassViewer.stopMeasureMode === 'function') {
                window.PassViewer.stopMeasureMode(map);
            }
        },
        isMeasureMode: function () {
            return isMeasureModeActive();
        },
        invalidateMapSize: invalidateMapSize,
        getConfig: function () {
            return readJsonScript('page-config') || {};
        },
        getCookie: getCookie,
        apiUrl: apiUrl,
    };
})();

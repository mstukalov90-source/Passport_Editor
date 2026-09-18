(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});
    const MM_MARKER_SIZE_SCALE = 1;
    const CIRCLE_MARKER_SIZE_SCALE = 1.5;
    const MAP_UNIT_HIDE_BELOW_PX = 3;
    const MAP_UNIT_MARKER_MAX_PX = 10000;

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
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

    function propertyValue(props, field) {
        if (!field || !props) return null;
        const direct = props[field];
        if (direct !== undefined && direct !== null && direct !== '') return direct;
        const lower = String(field).toLowerCase();
        const keys = Object.keys(props);
        for (let i = 0; i < keys.length; i += 1) {
            if (keys[i].toLowerCase() === lower) {
                const value = props[keys[i]];
                if (value !== undefined && value !== null && value !== '') return value;
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
            if (ch === '%') regexSrc += '.*';
            else if (ch === '_') regexSrc += '.';
            else if (/[.*+?^${}()|[\]\\]/.test(ch)) regexSrc += '\\' + ch;
            else regexSrc += ch;
        }
        try {
            return new RegExp('^' + regexSrc + '$').test(text);
        } catch (_error) {
            return false;
        }
    }

    function matchFilter(props, filter) {
        if (!filter) return true;
        const type = filter.type;
        const children = filter.children || [];
        if (type === 'else') return true;
        if (type === 'and') return children.length > 0 && children.every((item) => matchFilter(props, item));
        if (type === 'or') return children.some((item) => matchFilter(props, item));
        const value = propertyValue(props, filter.field);
        if (type === 'in') return value !== null && (filter.values || []).some((item) => String(item) === String(value));
        if (type === 'like') return value !== null && likeMatch(value, filter.pattern);
        if (type === 'ne') return value !== null && String(value) !== String(filter.value);
        if (type === 'eq') return value !== null && String(value) === String(filter.value);
        if (type === 'null') return value === null;
        if (type === 'not_null') return value !== null;
        return false;
    }

    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value));
    }

    function clampFraction(value, fallback) {
        const number = Number(value);
        return Number.isFinite(number) ? clamp(number, 0, 1) : fallback;
    }

    function enumAnchorToFraction(axis, name) {
        const raw = String(name || '').trim().toLowerCase().replace(/[_-]+/g, ' ');
        if (axis === 'x') {
            if (raw === 'left' || raw === '0') return 0;
            if (raw === 'right' || raw === '2') return 1;
            if (['center', 'hcenter', 'h center', 'horizontal center', '1'].includes(raw)) return 0.5;
            return null;
        }
        if (raw === 'top' || raw === '0') return 0;
        if (raw === 'bottom' || raw === '2') return 1;
        if (['center', 'vcenter', 'v center', 'vertical center', '1'].includes(raw)) return 0.5;
        return null;
    }

    PassViewer.createQmlRenderer = function createQmlRenderer(map, options) {
        const opts = options || {};
        const manifest = opts.manifest || { tables: {} };
        const svgIndex = opts.svgIndex || {};
        const svgHotspots = opts.svgHotspots || {};
        const iconsBase = opts.iconsBase || '/static/approval/icons/svg/';
        const mapUnitMarkers = [];
        const svgClickMarkers = {};
        const selectablePolygonLayers = [];
        const svgOpaqueBoundsCache = {};
        let nextSvgClickMarkerId = 1;
        let activeChoiceHighlight = null;
        let refreshRaf = null;

        function tableStyle(layerKey) {
            const tables = manifest.tables || {};
            if (tables[layerKey]) return tables[layerKey];
            const key = String(layerKey || '');
            return key.indexOf('topo:') === 0 ? tables[key.slice(5)] || null : null;
        }

        function styleTableKey(props) {
            if (props.sourceTable) return props.sourceTable;
            const layerKey = String(props.layerKey || '');
            return layerKey.indexOf('topo:') === 0 ? layerKey.slice(5) : layerKey || 'work';
        }

        function resolveRuleStyle(layerKey, props) {
            const definition = tableStyle(layerKey);
            if (!definition || !Array.isArray(definition.rules) || !definition.rules.length) return null;
            let elseStyle = null;
            for (let i = 0; i < definition.rules.length; i += 1) {
                const rule = definition.rules[i];
                if (rule.filter && rule.filter.type === 'else') {
                    elseStyle = rule.style || null;
                } else if (matchFilter(props, rule.filter)) {
                    return rule.style || null;
                }
            }
            if (elseStyle) return elseStyle;
            const index = definition.defaultRule;
            if (typeof index === 'number' && definition.rules[index]) return definition.rules[index].style || null;
            return definition.rules[definition.rules.length - 1].style || null;
        }

        function normalizeSvgPath(raw) {
            if (!raw) return null;
            const normalized = String(raw).replace(/\\/g, '/');
            const marker = '/svg/';
            const pos = normalized.lastIndexOf(marker);
            const relative = (pos >= 0 ? normalized.slice(pos + marker.length) : normalized).replace(/^\/+/, '');
            return relative && relative.indexOf('.svg') !== -1 ? relative : null;
        }

        function resolveSvgPath(raw) {
            const relative = normalizeSvgPath(raw);
            if (!relative) return null;
            const basename = relative.split('/').pop();
            const keys = [relative, basename];
            if (typeof relative.normalize === 'function') keys.push(relative.normalize('NFC'));
            if (basename && typeof basename.normalize === 'function') keys.push(basename.normalize('NFC'));
            for (let i = 0; i < keys.length; i += 1) {
                if (keys[i] && svgIndex[keys[i]]) return svgIndex[keys[i]];
            }
            return null;
        }

        function svgUrl(style, props) {
            if (!style) return null;
            let raw = style.svg || null;
            if (style.svgField && propertyValue(props, style.svgField)) raw = propertyValue(props, style.svgField);
            const resolved = resolveSvgPath(raw);
            if (!resolved || (resolved.split('/').pop() || '').indexOf('Неизвестн') === 0) return null;
            return iconsBase + resolved.split('/').map(encodeURIComponent).join('/');
        }

        function photoFixUrl() {
            const resolved = resolveSvgPath('Фотофиксация.svg');
            return resolved ? iconsBase + resolved.split('/').map(encodeURIComponent).join('/') : null;
        }

        function metersToPixels(meters, lat, zoom) {
            const latitude = Number.isFinite(Number(lat)) ? Number(lat) : map.getCenter().lat;
            const level = Number.isFinite(Number(zoom)) ? Number(zoom) : map.getZoom();
            const metersPerPixel = (156543.03392 * Math.cos((latitude * Math.PI) / 180)) / Math.pow(2, level);
            return metersPerPixel > 0 ? Number(meters) / metersPerPixel : 0;
        }

        function markerPixelSize(latlng, sizeValue, sizeUnit, zoom) {
            const raw = Number(sizeValue);
            if (sizeUnit === 'MapUnit') {
                const meters = Number.isFinite(raw) && raw > 0 ? raw : 14;
                return Math.round(clamp(metersToPixels(meters, latlng && latlng.lat, zoom), 0, MAP_UNIT_MARKER_MAX_PX));
            }
            return Math.round(clamp((Number.isFinite(raw) && raw > 0 ? raw : 18) * MM_MARKER_SIZE_SCALE, 10, 64));
        }

        function mapUnitVisible(size) {
            return Number(size) >= MAP_UNIT_HIDE_BELOW_PX;
        }

        function iconBasename(url) {
            let path = String(url || '');
            try { path = decodeURIComponent(path); } catch (_error) { /* keep source */ }
            return path.split('?')[0].split('#')[0].split('/').pop() || null;
        }

        function anchorFractions(iconUrl, props, style, defaultX, defaultY) {
            const basename = iconBasename(iconUrl);
            const hotspot = basename && (svgHotspots[basename] || svgHotspots[basename.normalize ? basename.normalize('NFC') : basename]);
            if (hotspot && hotspot.length >= 2) return [clampFraction(hotspot[0], 0.5), clampFraction(hotspot[1], 1)];
            const featureX = enumAnchorToFraction('x', propertyValue(props, 'Svg_HAPoint'));
            const featureY = enumAnchorToFraction('y', propertyValue(props, 'Svg_VAPoint'));
            const ruleX = enumAnchorToFraction('x', (style && style.iconAnchorX) || defaultX);
            const ruleY = enumAnchorToFraction('y', (style && style.iconAnchorY) || defaultY);
            return [featureX != null ? featureX : ruleX != null ? ruleX : 0.5, featureY != null ? featureY : ruleY != null ? ruleY : 1];
        }

        function svgDivIcon(iconUrl, size, anchorX, anchorY, markerId, interactive) {
            const safeSize = Math.max(1, Math.round(size || 1));
            const ax = Math.round(clampFraction(anchorX, 0.5) * safeSize);
            const ay = Math.round(clampFraction(anchorY, 1) * safeSize);
            return L.divIcon({
                className: 'approval-svg-marker',
                html: '<img class="approval-svg-marker__image" style="width:' + safeSize + 'px;height:' + safeSize + 'px;left:' + (-ax) + 'px;top:' + (-ay) + 'px" src="' + escapeHtml(iconUrl) + '" alt="" aria-hidden="true">' +
                    '<span class="approval-svg-marker__hit" style="left:' + (-ax) + 'px;top:' + (-ay) + 'px;width:' + safeSize + 'px;height:' + safeSize + 'px;pointer-events:' + (interactive ? 'auto' : 'none') + '" data-svg-marker-id="' + escapeHtml(markerId || '') + '"></span>',
                iconSize: [0, 0],
                iconAnchor: [0, 0],
                popupAnchor: [0, -50],
            });
        }

        function createSvgMarker(latlng, iconUrl, size, feature, meters, anchorX, anchorY) {
            const visible = meters == null || mapUnitVisible(size);
            const renderSize = visible ? Math.max(1, size) : 1;
            const markerId = String(nextSvgClickMarkerId++);
            const marker = L.marker(latlng, {
                icon: svgDivIcon(iconUrl, renderSize, anchorX, anchorY, markerId, visible),
                opacity: visible ? 1 : 0,
                zIndexOffset: 600,
            });
            marker._approvalFeature = feature;
            marker._approvalIsSvgMarker = true;
            svgClickMarkers[markerId] = marker;
            marker.on('click', handleMapObjectChoice);
            if (meters != null) mapUnitMarkers.push({ kind: 'svg', marker, markerId, iconUrl, meters: Number(meters), anchorX, anchorY, lastSize: renderSize, lastVisible: visible });
            return marker;
        }

        function textIcon(text, size, color, rotation) {
            const fontSize = Math.max(1, Math.round(size));
            const box = Math.max(2, Math.round(fontSize * 1.4));
            const transform = Number.isFinite(rotation) && rotation !== 0 ? 'transform:rotate(' + rotation + 'deg);' : '';
            return L.divIcon({
                className: 'approval-topo-text-label',
                html: '<div style="color:' + color + ';font-size:' + fontSize + 'px;font-weight:500;line-height:1.1;white-space:pre;text-align:center;pointer-events:none;user-select:none;' + transform + '">' + text + '</div>',
                iconSize: [box * 4, box],
                iconAnchor: [box * 2, Math.round(box / 2)],
            });
        }

        function createTextMarker(latlng, feature, labeling) {
            const props = feature.properties || {};
            const rawText = propertyValue(props, labeling.field);
            if (rawText === null || !String(rawText).trim()) return null;
            const text = escapeHtml(String(rawText).replace(/\\P/g, '\n')).replace(/\n/g, '<br>');
            const unit = labeling.fontSizeUnit || 'Point';
            const baseSize = Number(labeling.fontSize) > 0 ? Number(labeling.fontSize) : 12;
            const color = labeling.color || '#000000';
            let size = unit === 'MapUnit' ? markerPixelSize(latlng, baseSize, unit) : unit === 'MM' ? Math.max(8, Math.round(baseSize * 3.78)) : Math.max(8, Math.round(baseSize));
            const rotationValue = labeling.rotationField ? Number(propertyValue(props, labeling.rotationField)) : NaN;
            const rotation = Number.isFinite(rotationValue) ? (labeling.rotationMode === 'complement' ? 360 - rotationValue : rotationValue) : null;
            const visible = unit !== 'MapUnit' || mapUnitVisible(size);
            size = visible ? Math.max(1, size) : 1;
            const marker = L.marker(latlng, { icon: textIcon(text, size, color, rotation), opacity: visible ? 1 : 0, interactive: false, zIndexOffset: 500 });
            if (unit === 'MapUnit') mapUnitMarkers.push({ kind: 'text', marker, meters: baseSize, text, color, rotation, lastSize: size, visible });
            return marker;
        }

        function invisiblePoint(latlng) {
            return L.circleMarker(latlng, { radius: 0, opacity: 0, fillOpacity: 0, weight: 0, interactive: false, pane: 'markerPane' });
        }

        function pathStyle(style, layerKey, geometryType) {
            if (!style) {
                const colors = hashColor(layerKey);
                return geometryType === 'line'
                    ? { color: colors.stroke, weight: 2, opacity: 0.9 }
                    : { color: colors.stroke, weight: 2, fillColor: colors.fill, fillOpacity: 0.55 };
            }
            const result = {};
            if (style.color) { result.color = style.color; result.opacity = style.opacity !== undefined ? style.opacity : 1; }
            if (style.fillColor) { result.fillColor = style.fillColor; result.fillOpacity = style.fillOpacity !== undefined ? style.fillOpacity : 0.55; }
            if (style.weight !== undefined) result.weight = style.weight;
            if (style.dashArray) result.dashArray = style.dashArray;
            if (!result.color && style.fillColor) result.color = style.fillColor;
            if (!result.fillColor && geometryType === 'polygon') { result.fillColor = style.color || '#94a3b8'; result.fillOpacity = result.fillOpacity || 0.45; }
            return result;
        }

        function styleFeature(feature) {
            const props = feature.properties || {};
            const key = styleTableKey(props);
            const type = (feature.geometry || {}).type || '';
            if (type === 'Point' || type === 'MultiPoint') return {};
            const definition = tableStyle(key);
            const geometryType = definition && definition.geometry;
            return pathStyle(resolveRuleStyle(key, props), key, geometryType || (type.indexOf('Line') !== -1 ? 'line' : 'polygon'));
        }

        function pointToLayer(feature, latlng) {
            const props = feature.properties || {};
            const key = styleTableKey(props);
            const definition = tableStyle(key);
            const isTopoText = String(key).toLowerCase() === 'topotext';
            if (isTopoText) {
                if (String(props.layer || '') === 'Фотофиксация') {
                    const photoUrl = photoFixUrl();
                    if (photoUrl) {
                        const size = markerPixelSize(latlng, 12, 'MM');
                        const anchors = anchorFractions(photoUrl, props, null, 'center', 'center');
                        return createSvgMarker(latlng, photoUrl, size, feature, null, anchors[0], anchors[1]);
                    }
                    return invisiblePoint(latlng);
                }
                const labeling = (definition && definition.labeling) || { field: 'text', fontSize: 1, fontSizeUnit: 'MapUnit', color: '#000000', rotationField: 'angle', rotationMode: 'complement' };
                return createTextMarker(latlng, feature, labeling) || invisiblePoint(latlng);
            }
            const style = resolveRuleStyle(key, props);
            const unit = (style && (style.iconSizeUnit || style.sizeUnit)) || 'MM';
            const iconUrl = svgUrl(style, props);
            if (iconUrl) {
                const baseSize = style && style.iconSize ? style.iconSize : 18;
                const size = markerPixelSize(latlng, baseSize, unit);
                const anchors = anchorFractions(iconUrl, props, style, 'center', key === 'PhotoFixPoint' ? 'center' : 'bottom');
                return createSvgMarker(latlng, iconUrl, size, feature, unit === 'MapUnit' ? baseSize : null, anchors[0], anchors[1]);
            }
            const colors = hashColor(key);
            const baseRadius = (style && style.radius) || 5;
            const strokeOpacity = style && style.opacity !== undefined ? Number(style.opacity) : 1;
            const fillOpacity = style && style.fillOpacity !== undefined ? Number(style.fillOpacity) : 0.85;
            if (fillOpacity <= 0 && strokeOpacity <= 0) return invisiblePoint(latlng);
            let radius = Math.round(baseRadius * CIRCLE_MARKER_SIZE_SCALE);
            let meters = null;
            if (unit === 'MapUnit') {
                meters = Number(baseRadius) > 0.5 ? Number(baseRadius) : Number(style && style.iconSize) > 0.5 ? Number(style.iconSize) : 14;
                const diameter = markerPixelSize(latlng, meters, unit);
                radius = mapUnitVisible(diameter) ? Math.max(0.5, diameter / 2) : 0;
            }
            const visible = unit !== 'MapUnit' || radius > 0;
            const marker = L.circleMarker(latlng, {
                radius,
                color: (style && style.color) || colors.stroke,
                weight: 2,
                opacity: visible ? strokeOpacity : 0,
                fillColor: (style && style.fillColor) || colors.fill,
                fillOpacity: visible ? fillOpacity : 0,
                pane: 'markerPane',
            });
            if (meters != null) mapUnitMarkers.push({ kind: 'circle', marker, meters, strokeOpacity, fillOpacity, lastSize: radius, visible });
            return marker;
        }

        function setMarkerOpacity(marker, opacity) {
            if (marker && typeof marker.setOpacity === 'function') marker.setOpacity(opacity);
            else if (marker && typeof marker.setStyle === 'function') marker.setStyle({ opacity, fillOpacity: opacity });
        }

        function applySvgMarkerSize(entry, size) {
            if (!entry || !entry.marker) return;
            const visible = mapUnitVisible(size);
            const renderSize = visible ? Math.max(1, size) : 1;
            if (entry.lastSize === renderSize && entry.lastVisible === visible) return;
            entry.lastSize = renderSize;
            entry.lastVisible = visible;
            const anchorX = entry.anchorX != null ? entry.anchorX : 0.5;
            const anchorY = entry.anchorY != null ? entry.anchorY : 1;
            const ax = Math.round(clampFraction(anchorX, 0.5) * renderSize);
            const ay = Math.round(clampFraction(anchorY, 1) * renderSize);
            const icon = entry.marker.options && entry.marker.options.icon;
            if (icon && icon.options) {
                icon.options.iconSize = [0, 0];
                icon.options.iconAnchor = [0, 0];
                icon.options.popupAnchor = [0, -50];
            }
            const element = entry.marker._icon;
            if (element) {
                const image = element.querySelector('.approval-svg-marker__image');
                const hit = element.querySelector('.approval-svg-marker__hit');
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
                if (typeof entry.marker.update === 'function' && entry.marker._map) entry.marker.update();
            } else if (visible) {
                entry.marker.setIcon(svgDivIcon(entry.iconUrl, renderSize, anchorX, anchorY, entry.markerId, visible));
            }
            setMarkerOpacity(entry.marker, visible ? 1 : 0);
        }

        function svgOpaqueBounds(image) {
            if (!image || !image.complete || !image.naturalWidth || !image.naturalHeight) return null;
            const cacheKey = image.currentSrc || image.src || '';
            if (cacheKey && Object.prototype.hasOwnProperty.call(svgOpaqueBoundsCache, cacheKey)) return svgOpaqueBoundsCache[cacheKey];
            let bounds = null;
            try {
                const scale = Math.min(1, 192 / Math.max(image.naturalWidth, image.naturalHeight));
                const width = Math.max(1, Math.round(image.naturalWidth * scale));
                const height = Math.max(1, Math.round(image.naturalHeight * scale));
                const canvas = document.createElement('canvas');
                canvas.width = width;
                canvas.height = height;
                const context = canvas.getContext('2d', { willReadFrequently: true });
                context.drawImage(image, 0, 0, width, height);
                const pixels = context.getImageData(0, 0, width, height).data;
                let minX = width, minY = height, maxX = -1, maxY = -1;
                for (let y = 0; y < height; y += 1) {
                    for (let x = 0; x < width; x += 1) {
                        if (pixels[(y * width + x) * 4 + 3] <= 16) continue;
                        minX = Math.min(minX, x); minY = Math.min(minY, y);
                        maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
                    }
                }
                if (maxX >= minX && maxY >= minY) bounds = { left: minX / width, top: minY / height, right: (maxX + 1) / width, bottom: (maxY + 1) / height };
            } catch (_error) { bounds = null; }
            if (cacheKey) svgOpaqueBoundsCache[cacheKey] = bounds;
            return bounds;
        }

        function anchorPopupToSvgSilhouette(layer) {
            const element = layer && layer._icon;
            const icon = layer && layer.options && layer.options.icon;
            if (!element || !icon || !icon.options) return;
            const image = element.querySelector('.approval-svg-marker__image');
            const bounds = svgOpaqueBounds(image);
            if (!image || !bounds) { icon.options.popupAnchor = [0, -50]; return; }
            const width = parseFloat(image.style.width) || image.getBoundingClientRect().width;
            const height = parseFloat(image.style.height) || image.getBoundingClientRect().height;
            const left = parseFloat(image.style.left) || 0;
            const top = parseFloat(image.style.top) || 0;
            icon.options.popupAnchor = [
                Math.round(left + ((bounds.left + bounds.right) / 2) * width),
                Math.round(top + bounds.top * height - 8),
            ];
        }

        function formatAliasLabel(label) {
            return String(label || '').replace(/\s*\(RootId\)\s*/gi, ' ').replace(/\s+/g, ' ').trim();
        }

        function formatDisplayValue(value, field, label) {
            if (typeof value === 'boolean') return value ? 'Да' : 'Нет';
            const text = String(value == null ? '' : value).trim();
            if (['true', 't'].includes(text.toLowerCase())) return 'Да';
            if (['false', 'f'].includes(text.toLowerCase())) return 'Нет';
            if (/площад/i.test(String(label || '')) || /area/i.test(String(field || ''))) {
                const number = Number(text.replace(',', '.'));
                if (Number.isFinite(number)) return number.toFixed(2);
            }
            return value;
        }

        function shouldHideAlias(field, tableName) {
            const normalized = String(field || '').toLowerCase();
            return !normalized || ['svg', 'svg_vapoint', 'svg_hapoint'].includes(normalized) || (normalized === 'nocalc' && tableName !== 'AbutmentLine');
        }

        function popupTitle(feature) {
            const props = (feature && feature.properties) || {};
            const tableName = styleTableKey(props);
            const definition = tableStyle(tableName);
            return String((definition && definition.label) || tableName || '').trim();
        }

        function valueMapOptions(alias) {
            const valueMap = alias && alias.valueMap;
            if (!valueMap || typeof valueMap !== 'object') return [];
            return Object.keys(valueMap).map((code) => ({
                value: code,
                label: valueMap[code] == null || valueMap[code] === '' ? code : String(valueMap[code]),
            }));
        }

        function popupFields(feature, options) {
            const props = (feature && feature.properties) || {};
            const tableName = styleTableKey(props);
            const definition = tableStyle(tableName);
            const aliases = definition && Array.isArray(definition.aliases) ? definition.aliases : [];
            const includeEmptyLookups = Boolean(options && options.includeEmptyLookups);
            const fields = [];
            aliases.forEach((alias) => {
                const field = String(alias.field || '');
                const label = formatAliasLabel(alias.label);
                if (!field || !label || shouldHideAlias(field, tableName) || !Object.prototype.hasOwnProperty.call(props, field)) return;
                const displayField = field + '__display';
                const value = Object.prototype.hasOwnProperty.call(props, displayField) ? props[displayField] : props[field];
                const hasChoices = Boolean(alias.lookup) || valueMapOptions(alias).length > 0;
                const empty = value === null || value === undefined || String(value).trim() === '';
                if (empty && !(includeEmptyLookups && hasChoices)) return;
                fields.push({
                    field: field,
                    label: label,
                    value: empty ? '' : formatDisplayValue(value, field, label),
                    rawValue: props[field],
                    options: valueMapOptions(alias),
                    lookup: alias.lookup && typeof alias.lookup === 'object' ? alias.lookup : null,
                });
            });
            return fields;
        }

        function allowAction(feature) {
            return typeof opts.onAction === 'function' && (typeof opts.canAction !== 'function' || opts.canAction(feature));
        }

        function bindFeaturePopup(layer, feature) {
            const title = popupTitle(feature);
            const rows = popupFields(feature).map((item) => {
                return '<div class="approval-feature-popup__row"><strong>' + escapeHtml(item.label) + ':</strong> ' + escapeHtml(item.value) + '</div>';
            });
            let action = '';
            if (allowAction(feature)) {
                action = '<button type="button" class="approval-adjacent-popup__action recheck-feature-popup__action">' + escapeHtml(opts.actionLabel || 'Выбрать объект') + '</button>';
            }
            const html = '<div class="approval-feature-popup">' + (title ? '<div class="approval-feature-popup__title">' + escapeHtml(title) + '</div>' : '') + rows.join('') + action + '</div>';
            let popupLayers = [layer];
            if (feature.geometry && feature.geometry.type === 'MultiPoint' && layer.eachLayer) {
                popupLayers = [];
                layer.eachLayer((child) => {
                    if (child && child.bindPopup) { child._approvalFeature = feature; popupLayers.push(child); }
                });
            }
            popupLayers.forEach((popupLayer) => {
                popupLayer.bindPopup(html, { autoPan: false });
                popupLayer.on('popupopen', () => {
                    if (global.PassViewer && typeof global.PassViewer.isMeasureMode === 'function' && global.PassViewer.isMeasureMode(map)) {
                        popupLayer.closePopup();
                        return;
                    }
                    const popup = popupLayer.getPopup && popupLayer.getPopup();
                    const container = popup && popup.getElement ? popup.getElement() : null;
                    const button = container && container.querySelector('.recheck-feature-popup__action');
                    if (!button || button.dataset.bound === '1') return;
                    button.dataset.bound = '1';
                    L.DomEvent.disableClickPropagation(button);
                    button.addEventListener('click', () => {
                        opts.onAction(feature, popupLayer);
                        popupLayer.closePopup();
                    });
                });
            });
        }

        function onEachFeature(feature, layer) {
            layer._approvalFeature = feature;
            bindFeaturePopup(layer, feature);
            const geometryType = feature.geometry && feature.geometry.type;
            if ((geometryType === 'Polygon' || geometryType === 'MultiPolygon') && layer.getPopup && layer.getPopup()) selectablePolygonLayers.push(layer);
        }

        function pointInRing(point, ring) {
            if (!Array.isArray(ring) || ring.length < 3) return false;
            let inside = false;
            for (let i = 0, j = ring.length - 1; i < ring.length; j = i, i += 1) {
                const xi = Number(ring[i] && ring[i][0]), yi = Number(ring[i] && ring[i][1]);
                const xj = Number(ring[j] && ring[j][0]), yj = Number(ring[j] && ring[j][1]);
                if (![xi, yi, xj, yj].every(Number.isFinite)) continue;
                if (yi > point[1] !== yj > point[1] && point[0] < ((xj - xi) * (point[1] - yi)) / (yj - yi) + xi) inside = !inside;
            }
            return inside;
        }

        function geometryContains(geometry, latlng) {
            const point = [latlng.lng, latlng.lat];
            const polygonContains = (coordinates) => Array.isArray(coordinates) && coordinates.length > 0 && pointInRing(point, coordinates[0]) && !coordinates.slice(1).some((ring) => pointInRing(point, ring));
            if (!geometry) return false;
            if (geometry.type === 'Polygon') return polygonContains(geometry.coordinates);
            if (geometry.type === 'MultiPolygon') return (geometry.coordinates || []).some(polygonContains);
            return false;
        }

        function polygonUnderPoint(latlng, originalEvent) {
            if (originalEvent) {
                const stack = document.elementsFromPoint(originalEvent.clientX, originalEvent.clientY);
                for (let i = 0; i < stack.length; i += 1) {
                    const hit = selectablePolygonLayers.find((layer) => layer && layer._map === map && layer._path === stack[i] && layer.getPopup && layer.getPopup());
                    if (hit) return hit;
                }
            }
            const containing = selectablePolygonLayers.filter((layer) => layer && layer._map === map && layer.getPopup && layer.getPopup() && layer._approvalFeature && geometryContains(layer._approvalFeature.geometry, latlng));
            return containing.length ? containing[containing.length - 1] : null;
        }

        function choiceCandidates(event) {
            if (!map || !event) return { candidates: [], latlng: null };
            const originalEvent = event.originalEvent;
            const clickPoint = originalEvent ? map.mouseEventToContainerPoint(originalEvent) : map.latLngToContainerPoint(event.latlng);
            const latlng = map.containerPointToLatLng(clickPoint);
            const candidates = [];
            Object.keys(svgClickMarkers).forEach((markerId) => {
                const marker = svgClickMarkers[markerId];
                if (!marker || marker._map !== map || !marker.getPopup || !marker.getPopup()) return;
                const hit = marker._icon && marker._icon.querySelector('.approval-svg-marker__hit');
                if (!hit || hit.style.pointerEvents === 'none') return;
                const markerPoint = map.latLngToContainerPoint(marker.getLatLng());
                const dx = clickPoint.x - markerPoint.x, dy = clickPoint.y - markerPoint.y;
                const distanceSquared = dx * dx + dy * dy;
                if (distanceSquared <= 200 * 200) candidates.push({ layer: marker, kind: 'svg', distanceSquared });
            });
            candidates.sort((left, right) => left.distanceSquared - right.distanceSquared);
            const nearest = candidates.slice(0, 5);
            const polygon = polygonUnderPoint(latlng, originalEvent);
            if (polygon) nearest.push({ layer: polygon, kind: 'polygon', distanceSquared: 0 });
            return { candidates: nearest, latlng };
        }

        function choiceLabel(candidate, index) {
            const props = (candidate.layer._approvalFeature && candidate.layer._approvalFeature.properties) || {};
            const definition = tableStyle(styleTableKey(props));
            const aliases = definition && Array.isArray(definition.aliases) ? definition.aliases : [];
            let label = '';
            for (let i = 0; i < aliases.length; i += 1) {
                const field = String(aliases[i].field || '');
                if (!field || /svg|path|count|nocalc/i.test(field)) continue;
                const value = Object.prototype.hasOwnProperty.call(props, field + '__display') ? props[field + '__display'] : props[field];
                if (value !== null && value !== undefined && String(value).trim() !== '') {
                    const aliasLabel = formatAliasLabel(aliases[i].label);
                    label = (aliasLabel ? aliasLabel + ': ' : '') + String(formatDisplayValue(value, field, aliasLabel)).trim();
                    break;
                }
            }
            if (!label) label = String((definition && definition.label) || props.sourceTable || 'Объект');
            const fid = props.fid !== null && props.fid !== undefined ? String(props.fid) : '';
            return (candidate.kind === 'polygon' ? 'Полигон · ' : '') + label + (fid ? ' · #' + fid : ' · ' + (index + 1));
        }

        function clearChoiceHighlight(force) {
            const active = activeChoiceHighlight;
            if (active && active.persistent && !force) return;
            activeChoiceHighlight = null;
            if (!active) return;
            if (active.icon) {
                active.icon.classList.remove('approval-svg-marker--choice-hover');
                active.icon.classList.remove('approval-svg-marker--choice-active');
            }
            if (active.layer && active.originalStyle && active.layer.setStyle) active.layer.setStyle(active.originalStyle);
        }

        function highlightChoice(candidate, persistent) {
            clearChoiceHighlight(true);
            const layer = candidate && candidate.layer;
            if (!layer) return;
            const active = { layer, icon: null, originalStyle: null, persistent: Boolean(persistent) };
            if (candidate.kind === 'svg') {
                active.icon = layer._icon || null;
                if (active.icon) {
                    active.icon.classList.add('approval-svg-marker--choice-hover');
                    if (persistent) active.icon.classList.add('approval-svg-marker--choice-active');
                }
            } else if (layer.setStyle) {
                active.originalStyle = Object.assign({}, layer.options || {});
                layer.setStyle({ color: '#f59e0b', weight: 5, fillOpacity: 0.45 });
                if (layer.bringToFront) layer.bringToFront();
            }
            activeChoiceHighlight = active;
        }

        function openSelectedChoice(candidate) {
            const layer = candidate && candidate.layer;
            if (!layer || !layer.openPopup) return;
            if (candidate.kind === 'svg' && layer.getLatLng) {
                map.setView(layer.getLatLng(), 20.5, { animate: false });
                anchorPopupToSvgSilhouette(layer);
            } else if (layer.getBounds) {
                const bounds = layer.getBounds();
                if (bounds && bounds.isValid && bounds.isValid()) map.fitBounds(bounds.pad(0.12), { maxZoom: 20.5 });
            }
            highlightChoice(candidate, true);
            layer.openPopup();
        }

        function openChoicePopup(latlng, candidates) {
            if (!map || !candidates.length) return;
            clearChoiceHighlight();
            const content = document.createElement('div');
            content.className = 'approval-svg-choice';
            const title = document.createElement('div');
            title.className = 'approval-svg-choice__title';
            title.textContent = 'Выберите объект';
            content.appendChild(title);
            let choicePopup = null;
            candidates.forEach((candidate, index) => {
                const button = document.createElement('button');
                button.type = 'button';
                button.className = 'approval-svg-choice__item';
                button.textContent = choiceLabel(candidate, index);
                button.addEventListener('mouseenter', () => highlightChoice(candidate));
                button.addEventListener('mouseleave', () => clearChoiceHighlight(false));
                button.addEventListener('focus', () => highlightChoice(candidate));
                button.addEventListener('blur', () => clearChoiceHighlight(false));
                button.addEventListener('click', (buttonEvent) => {
                    buttonEvent.preventDefault(); buttonEvent.stopPropagation();
                    clearChoiceHighlight(true);
                    choicePopup.remove();
                    openSelectedChoice(candidate);
                });
                content.appendChild(button);
            });
            choicePopup = L.popup({ className: 'approval-svg-choice-popup', closeButton: false, autoPan: false, offset: [0, -8] })
                .setLatLng(latlng).setContent(content).openOn(map);
            choicePopup.on('remove', () => clearChoiceHighlight(false));
        }

        function handleMapObjectChoice(event) {
            if (!map || !event || (global.PassViewer && typeof global.PassViewer.isMeasureMode === 'function' && global.PassViewer.isMeasureMode(map))) return;
            const originalEvent = event.originalEvent;
            if (originalEvent && originalEvent._approvalChoiceScheduled) return;
            if (originalEvent) originalEvent._approvalChoiceScheduled = true;
            const selection = choiceCandidates(event);
            if (selection.candidates.length) global.setTimeout(() => openChoicePopup(selection.latlng, selection.candidates), 0);
        }

        function refresh(zoomOverride) {
            const zoom = Number.isFinite(Number(zoomOverride)) ? Number(zoomOverride) : map.getZoom();
            mapUnitMarkers.forEach((entry) => {
                const size = markerPixelSize(entry.marker.getLatLng(), entry.meters, 'MapUnit', zoom);
                const visible = mapUnitVisible(size);
                if (entry.kind === 'svg') {
                    applySvgMarkerSize(entry, size);
                } else if (entry.kind === 'text') {
                    const renderSize = visible ? Math.max(1, size) : 1;
                    if (entry.lastSize !== renderSize || entry.visible !== visible) {
                        entry.lastSize = renderSize;
                        entry.visible = visible;
                        if (visible) entry.marker.setIcon(textIcon(entry.text, renderSize, entry.color, entry.rotation));
                        entry.marker.setOpacity(visible ? 1 : 0);
                    }
                } else if (entry.kind === 'circle') {
                    const radius = visible ? Math.max(0.5, size / 2) : 0;
                    entry.marker.setRadius(radius);
                    entry.marker.setStyle({ opacity: visible ? entry.strokeOpacity : 0, fillOpacity: visible ? entry.fillOpacity : 0 });
                }
            });
        }

        function liveZoom(eventZoom) {
            if (Number.isFinite(Number(eventZoom))) return Number(eventZoom);
            if (map._animatingZoom && Number.isFinite(map._animateToZoom)) return map._animateToZoom;
            return map.getZoom();
        }

        function scheduleRefresh(event) {
            if (refreshRaf !== null) global.cancelAnimationFrame(refreshRaf);
            refreshRaf = global.requestAnimationFrame(() => {
                refreshRaf = null;
                refresh(liveZoom(event && event.zoom));
            });
        }

        map.on('zoomanim', scheduleRefresh);
        map.on('zoom', scheduleRefresh);
        map.on('zoomend', () => refresh(map.getZoom()));
        map.on('moveend', () => refresh(map.getZoom()));
        map.on('click', handleMapObjectChoice);

        return {
            style: styleFeature,
            pointToLayer,
            onEachFeature,
            refresh,
            resolveRuleStyle,
            tableStyle,
            popupFields,
            popupTitle,
        };
    };
})(window);

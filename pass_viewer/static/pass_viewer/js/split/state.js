(function (global) {
    'use strict';

    const Split = (global.PassViewerSplit = global.PassViewerSplit || {});

    Split.PROP = {
        PART_ID: '_splitPartId',
        ASSIGNMENT_HISTORY: '_splitAssignmentHistory',
        INSIDE_LOCK: '_polygonSelectionInsideLocked',
        LINE_CUT_TOUCHED: '_polygonLineCutTouched',
        LINE_CUT_PRESERVE: '_lineCutOutsideSelectionPreserve',
    };

    Split.SOURCE = {
        PASSPORT: 'passport',
        SELECTION_INSIDE: 'selection_inside',
        SELECTION_INSIDE_REENTRY: 'selection_inside_reentry',
        SELECTION_OUTSIDE: 'selection_outside',
        LINE_CUT: 'line_cut',
    };

    Split.createSplitState = function createSplitState(cfg) {
        let partIdCounter = 0;

        const state = {
            cfg,
            selectedName: cfg.selectedName || '',
            selectedRequestId: cfg.selectedRequestId || '',
            selectedSourceLabel: cfg.selectedSourceLabel || 'ДТ',
            mode: null,
            isEditing: false,
            cutObjectMode: false,
            selectionPolygonMode: false,
            initialPolygonCount: 0,
            polygonSelectionDone: false,
            lastOutsideRequestId: '',
            selectedEditableGeo: null,
        };

        state.nextPartId = function nextPartId(suffix) {
            partIdCounter += 1;
            const base = 'p-' + partIdCounter;
            return suffix ? base + suffix : base;
        };

        state.resetPartIdCounter = function resetPartIdCounter() {
            partIdCounter = 0;
        };

        state.objectMode = function objectMode() {
            if (state.initialPolygonCount <= 1) return 'single';
            return 'multi';
        };

        state.setModeFromPolygonCount = function setModeFromPolygonCount(count) {
            state.initialPolygonCount = count;
            state.mode = count <= 1 ? 'single' : 'multi';
            state.polygonSelectionDone = false;
        };

        return state;
    };

    Split.getProps = function getProps(layer) {
        return layer?.feature?.properties || {};
    };

    Split.ensureFeature = function ensureFeature(layer, stripGeometryTo2D) {
        const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
        layer.feature = layer.feature || { type: 'Feature', properties: {}, geometry: g };
        layer.feature.properties = layer.feature.properties || {};
        layer.feature.geometry = g;
        return layer.feature.properties;
    };

    Split.getHistory = function getHistory(props) {
        const h = props[Split.PROP.ASSIGNMENT_HISTORY];
        return Array.isArray(h) ? h : [];
    };

    Split.appendHistory = function appendHistory(props, requestId, name, source) {
        const history = Split.getHistory(props);
        history.push({
            request_id: String(requestId || '').trim(),
            name: String(name || '').trim(),
            source,
            at: new Date().toISOString(),
        });
        props[Split.PROP.ASSIGNMENT_HISTORY] = history;
    };

    Split.initPartFromPassport = function initPartFromPassport(layer, partId, requestId, name, stripGeometryTo2D) {
        const p = Split.ensureFeature(layer, stripGeometryTo2D);
        p[Split.PROP.PART_ID] = partId;
        p.request_id = requestId;
        p.name = name;
        p[Split.PROP.ASSIGNMENT_HISTORY] = [];
        if (requestId || name) {
            Split.appendHistory(p, requestId, name, Split.SOURCE.PASSPORT);
        }
    };

    Split.isInsideLocked = function isInsideLocked(props) {
        return !!(props && props[Split.PROP.INSIDE_LOCK]);
    };

    Split.isLineCutPreserve = function isLineCutPreserve(props) {
        return !!(props && props[Split.PROP.LINE_CUT_PRESERVE]);
    };

    Split.isLineCutTouched = function isLineCutTouched(props) {
        return !!(props && props[Split.PROP.LINE_CUT_TOUCHED]);
    };

    Split.assignRequest = function assignRequest(props, requestId, name, source, options) {
        const opts = options || {};
        props.request_id = requestId;
        props.name = name;
        Split.appendHistory(props, requestId, name, source);
        if (opts.insideLock) {
            props[Split.PROP.INSIDE_LOCK] = true;
        }
        if (opts.clearLineCutPreserve) {
            delete props[Split.PROP.LINE_CUT_PRESERVE];
        }
        if (opts.lineCutPreserve) {
            props[Split.PROP.LINE_CUT_PRESERVE] = true;
            delete props[Split.PROP.LINE_CUT_TOUCHED];
        }
    };

    Split.copyPartFlags = function copyPartFlags(target, source) {
        if (source[Split.PROP.INSIDE_LOCK]) {
            target[Split.PROP.INSIDE_LOCK] = true;
        }
        if (source[Split.PROP.LINE_CUT_PRESERVE]) {
            target[Split.PROP.LINE_CUT_PRESERVE] = true;
        }
        const hist = Split.getHistory(source);
        if (hist.length) {
            target[Split.PROP.ASSIGNMENT_HISTORY] = hist.map((e) => ({ ...e }));
        }
        if (source[Split.PROP.PART_ID]) {
            target[Split.PROP.PART_ID] = source[Split.PROP.PART_ID];
        }
    };
})(typeof window !== 'undefined' ? window : global);

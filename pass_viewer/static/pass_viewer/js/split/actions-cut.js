(function (global) {
    'use strict';

    const PV = global.PassViewer;
    const Split = global.PassViewerSplit;

    const getCookie = PV.getCookie.bind(PV);
    const stripGeometryTo2D = PV.stripGeometryTo2D.bind(PV);
    const toEditableFeatureCollection = PV.toEditableFeatureCollection.bind(PV);

    Split.applyGeometryToEditableGroup = function applyGeometryToEditableGroup(ctx, geometry, partIdMap) {
        const editableGeo = toEditableFeatureCollection(geometry);
        if (!editableGeo?.features?.length) return false;

        ctx.editableGroup.clearLayers();
        const layer = L.geoJSON(editableGeo, {
            style: { color: '#ef4444', weight: 3, fillOpacity: 0.25 },
        });
        let idx = 0;
        layer.eachLayer((partLayer) => {
            partLayer.feature = partLayer.feature || {
                type: 'Feature',
                properties: {},
                geometry: stripGeometryTo2D(partLayer.toGeoJSON().geometry),
            };
            partLayer.feature.properties = partLayer.feature.properties || {};
            if (partIdMap && partIdMap[idx] !== undefined) {
                partLayer.feature.properties[Split.PROP.PART_ID] = partIdMap[idx];
            }
            ctx.editableGroup.addLayer(partLayer);
            idx += 1;
        });
        return true;
    };

    Split.tagPartsAfterLineCut = function tagPartsAfterLineCut(ctx, cutterLineGeometry, preCutParts, preTouchedParentIndices) {
        const state = ctx.state;
        const isSingle = state.objectMode() === 'single';
        const parentTouched = preTouchedParentIndices || new Set();
        const childSuffixCounters = {};

        ctx.editableGroup.eachLayer((layer) => {
            if (typeof layer.toGeoJSON !== 'function') return;
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            const p = Split.ensureFeature(layer, stripGeometryTo2D);

            delete p[Split.PROP.LINE_CUT_TOUCHED];
            delete p[Split.PROP.LINE_CUT_PRESERVE];

            if (isSingle) {
                delete p.request_id;
                delete p.name;
                p[Split.PROP.LINE_CUT_TOUCHED] = true;
                if (!p[Split.PROP.PART_ID]) {
                    p[Split.PROP.PART_ID] = state.nextPartId('-cut');
                }
                Split.bindReadOnlyPartPopup(layer);
                return;
            }

            let parentIdx = Split.findBestParentPolygonIndex(g, preCutParts);
            if (
                parentIdx < 0 &&
                parentTouched.size === 1 &&
                Split.lineGeometryTouchesPolygon2d(g, cutterLineGeometry)
            ) {
                parentIdx = parentTouched.values().next().value;
            }

            let touched = false;
            if (parentIdx >= 0) {
                touched = parentTouched.has(parentIdx);
                const src = preCutParts[parentIdx].properties || {};
                const parentPartId = src[Split.PROP.PART_ID] || 'p-' + (parentIdx + 1);

                if (!touched) {
                    p.request_id = String(src.request_id || '').trim();
                    p.name = String(src.name || '').trim();
                    p[Split.PROP.PART_ID] = parentPartId;
                    Split.copyPartFlags(p, src);
                } else {
                    delete p.request_id;
                    delete p.name;
                    const key = parentPartId;
                    childSuffixCounters[key] = (childSuffixCounters[key] || 0) + 1;
                    const suffix = String.fromCharCode(96 + childSuffixCounters[key]);
                    p[Split.PROP.PART_ID] = parentPartId + '-' + suffix;
                    if (src[Split.PROP.ASSIGNMENT_HISTORY]) {
                        p[Split.PROP.ASSIGNMENT_HISTORY] = src[Split.PROP.ASSIGNMENT_HISTORY].map((e) => ({
                            ...e,
                        }));
                    }
                    p[Split.PROP.LINE_CUT_TOUCHED] = true;
                }
            } else {
                p[Split.PROP.PART_ID] = state.nextPartId('-orphan');
                p[Split.PROP.LINE_CUT_TOUCHED] = true;
            }

            if (touched) {
                p[Split.PROP.LINE_CUT_TOUCHED] = true;
            }

            Split.bindReadOnlyPartPopup(layer);
        });
    };

    Split.applyCutFromDrawLayer = async function applyCutFromDrawLayer(ctx, cutterLayer, cutterType) {
        const state = ctx.state;
        const map = ctx.map;
        const statusEl = ctx.statusEl;

        if (state.objectMode() === 'multi' && !state.polygonSelectionDone) {
            statusEl.textContent =
                'Сначала выполните выборку полигоном: разрезание линией станет доступно после неё.';
            if (cutterLayer && map.hasLayer(cutterLayer)) {
                map.removeLayer(cutterLayer);
            }
            return;
        }

        const geometry = stripGeometryTo2D(Split.buildCurrentGeometry(ctx.editableGroup));
        const cutterGeometry = stripGeometryTo2D(cutterLayer?.toGeoJSON?.()?.geometry);
        if (!geometry || !cutterGeometry) {
            statusEl.textContent = 'Не удалось выполнить разрезание: нет геометрии.';
            return;
        }

        statusEl.textContent = 'Выполняем разрезание полигона...';

        try {
            const preFc = ctx.editableGroup.toGeoJSON();
            const preCutParts = (preFc.features || [])
                .map((f) => ({
                    geometry: stripGeometryTo2D(f.geometry),
                    properties: { ...(f.properties || {}) },
                }))
                .filter((x) => x.geometry?.type === 'Polygon');

            const preTouchedParentIndices = new Set();
            preCutParts.forEach((part, idx) => {
                if (Split.lineGeometryTouchesPolygon2d(part.geometry, cutterGeometry)) {
                    preTouchedParentIndices.add(idx);
                }
            });

            const response = await fetch(state.cfg.urls.cutGeometry, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCookie('csrftoken') || '',
                },
                body: JSON.stringify({
                    geometry,
                    cutter_geometry: cutterGeometry,
                    cutter_type: cutterType,
                }),
            });
            const data = await response.json();
            if (!response.ok || !data.ok) {
                throw new Error(data.error || 'Не удалось разрезать полигон.');
            }
            if (!data.geometry) {
                throw new Error('После разрезания геометрия не содержит площади.');
            }
            if (!Split.applyGeometryToEditableGroup(ctx, data.geometry)) {
                throw new Error('Не удалось применить результат разрезания.');
            }
            if (map.hasLayer(cutterLayer)) {
                map.removeLayer(cutterLayer);
            }

            Split.tagPartsAfterLineCut(ctx, cutterGeometry, preCutParts, preTouchedParentIndices);

            const layers = Split.getEditableLayers(ctx.editableGroup);
            const isSingle = state.objectMode() === 'single';
            const attrsOk = await Split.promptPartAttributes(ctx, layers, {
                allPartsInSingleMode: isSingle,
                onlyLineCutTouched: !isSingle,
            });
            if (!attrsOk) {
                throw new Error('Не удалось заполнить атрибуты частей.');
            }

            if (isSingle) {
                statusEl.textContent =
                    'Разрезание выполнено. Заполните заявки для каждой части, затем нажмите «Выгрузить файлы».';
            } else {
                statusEl.textContent =
                    'Разрезание выполнено. Заявки введены для частей вдоль линии; остальные сохранили текущие номера.';
            }
        } catch (error) {
            statusEl.textContent = error.message || 'Не удалось разрезать полигон.';
        }
    };
})(typeof window !== 'undefined' ? window : global);

(function (global) {
    'use strict';

    const PV = global.PassViewer;
    const Split = global.PassViewerSplit;

    const stripGeometryTo2D = PV.stripGeometryTo2D.bind(PV);
    const partCentroidInsideSelection = PV.partCentroidInsideSelection.bind(PV);

    Split.applySelectionFromDrawLayer = async function applySelectionFromDrawLayer(ctx, drawnLayer) {
        const state = ctx.state;
        const map = ctx.map;
        const editableGroup = ctx.editableGroup;
        const statusEl = ctx.statusEl;

        const selectionGeom = stripGeometryTo2D(drawnLayer?.toGeoJSON?.()?.geometry);
        if (!selectionGeom || selectionGeom.type !== 'Polygon') {
            statusEl.textContent = 'Ожидался полигон выделения.';
            return;
        }
        if (map.hasLayer(drawnLayer)) {
            map.removeLayer(drawnLayer);
        }

        const layers = Split.getEditableLayers(editableGroup);
        if (!layers.length) {
            statusEl.textContent = 'Нет частей для классификации.';
            return;
        }

        const counts = Split.classifyPartsForSelection(layers, selectionGeom, partCentroidInsideSelection);
        const {
            inside,
            outside,
            preservedInsideLocked,
            preservedLineCut,
            reentryInsideLocked,
        } = counts;

        const dualPossible = inside > 0 && outside > 0;
        const outsideOnlyPossible =
            inside === 0 && outside > 0 && (preservedInsideLocked > 0 || preservedLineCut > 0);

        if (!dualPossible && !outsideOnlyPossible) {
            if (layers.length && inside === 0 && outside === 0) {
                statusEl.textContent =
                    'Нет частей для назначения: все отнесены к сохранённым (внутри выборки или заявка после линии вне выделения).';
                return;
            }
            if (preservedInsideLocked + reentryInsideLocked === layers.length && inside === 0 && outside === 0) {
                statusEl.textContent =
                    'Все части зафиксированы снаружи выделения; переназначение не требуется.';
                return;
            }
            statusEl.textContent =
                'Среди назначаемых частей все оказались только ' +
                (!inside ? 'снаружи' : 'внутри') +
                ' выделения. Нарисуйте другой полигон или используйте разрезание линией.';
            return;
        }

        let insidePack = null;
        let outsidePack = null;

        if (dualPossible) {
            const assignment = await Split.openDualAssignmentPopup(ctx, inside, outside);
            if (!assignment) {
                statusEl.textContent = 'Назначение заявок отменено.';
                return;
            }
            insidePack = assignment.inside;
            outsidePack = assignment.outside;
        } else {
            const outOnly = await Split.openOutsideOnlyAssignmentPopup(
                ctx,
                outside,
                preservedInsideLocked + preservedLineCut
            );
            if (!outOnly) {
                statusEl.textContent = 'Назначение заявок отменено.';
                return;
            }
            outsidePack = outOnly;
        }

        layers.forEach((layer) => {
            const g = stripGeometryTo2D(layer.toGeoJSON().geometry);
            const p = Split.ensureFeature(layer, stripGeometryTo2D);
            const centroidInside = partCentroidInsideSelection(g, selectionGeom);

            if (Split.isInsideLocked(p)) {
                if (centroidInside && insidePack) {
                    Split.assignRequest(
                        p,
                        insidePack.request_id,
                        insidePack.name,
                        Split.SOURCE.SELECTION_INSIDE_REENTRY,
                        {
                        insideLock: true,
                        clearLineCutPreserve: true,
                    });
                }
                Split.bindReadOnlyPartPopup(layer);
                return;
            }

            if (Split.isLineCutPreserve(p) && !centroidInside) {
                Split.bindReadOnlyPartPopup(layer);
                return;
            }

            if (centroidInside && insidePack) {
                Split.assignRequest(p, insidePack.request_id, insidePack.name, Split.SOURCE.SELECTION_INSIDE, {
                    insideLock: true,
                    clearLineCutPreserve: true,
                });
            } else if (outsidePack) {
                Split.assignRequest(
                    p,
                    outsidePack.request_id,
                    outsidePack.name,
                    Split.SOURCE.SELECTION_OUTSIDE
                );
            }
            Split.bindReadOnlyPartPopup(layer);
        });

        const outReq = String(outsidePack?.request_id || '').trim();
        if (outReq) {
            state.lastOutsideRequestId = outReq;
        }

        if (dualPossible) {
            let tail = '';
            if (preservedInsideLocked) {
                tail += ' ' + preservedInsideLocked + ' ч. с заявкой «внутри» (снаружи выделения) без изменений.';
            }
            if (preservedLineCut) {
                tail += ' ' + preservedLineCut + ' ч. с заявкой после линии (вне выделения) без изменений.';
            }
            if (reentryInsideLocked) {
                tail += ' ' + reentryInsideLocked + ' ч. переназначены внутри нового выделения.';
            }
            statusEl.textContent =
                'Готово: ' +
                inside +
                ' ч. внутри → заявка ' +
                insidePack.request_id +
                ', ' +
                outside +
                ' снаружи → заявка ' +
                outsidePack.request_id +
                '.' +
                tail;
        } else {
            statusEl.textContent =
                'Готово: ' +
                outside +
                ' ч. снаружи → заявка ' +
                outsidePack.request_id +
                '; ' +
                preservedInsideLocked +
                ' ч. с заявкой «внутри» (вне выделения) без изменений' +
                (preservedLineCut
                    ? '; ' + preservedLineCut + ' ч. с заявкой после линии без изменений'
                    : '') +
                '.';
        }

        if (state.objectMode() === 'multi') {
            state.polygonSelectionDone = true;
            ctx.refreshToolbar();
        }
    };
})(typeof window !== 'undefined' ? window : global);

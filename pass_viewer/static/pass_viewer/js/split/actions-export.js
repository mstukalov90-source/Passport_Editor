(function (global) {
    'use strict';

    const PV = global.PassViewer;
    const Split = global.PassViewerSplit;

    const getCookie = PV.getCookie.bind(PV);
    const escapeHtml = PV.escapeHtml.bind(PV);

    Split.exportAllParts = async function exportAllParts(ctx) {
        const state = ctx.state;
        const statusEl = ctx.statusEl;
        const exportLinksEl = ctx.exportLinksEl;
        const saveButton = ctx.saveButton;

        if (!state.isEditing) {
            statusEl.textContent = 'Сначала включите режим редактирования.';
            return;
        }

        const layers = Split.getEditableLayers(ctx.editableGroup);
        if (!layers.length) {
            statusEl.textContent = 'Нет геометрии для выгрузки.';
            return;
        }

        const isSingle = state.objectMode() === 'single';
        const attrsOk = await Split.promptPartAttributes(ctx, layers, {
            allPartsInSingleMode: isSingle,
            onlyLineCutTouched: !isSingle,
        });
        if (!attrsOk) return;

        const layersAfterAttrs = Split.getEditableLayers(ctx.editableGroup);
        const byRequestId = new Map();
        for (let i = 0; i < layersAfterAttrs.length; i += 1) {
            const layer = layersAfterAttrs[i];
            const rid = String(Split.getProps(layer).request_id || '').trim();
            if (!byRequestId.has(rid)) byRequestId.set(rid, []);
            byRequestId.get(rid).push(layer);
        }

        for (const [rid, groupLayers] of byRequestId) {
            const names = new Set(
                groupLayers.map((l) => String(Split.getProps(l).name || '').trim()).filter(Boolean)
            );
            if (names.size > 1) {
                statusEl.textContent =
                    'У частей с номером заявки ' +
                    escapeHtml(rid) +
                    ' указаны разные названия. Укажите одно название на заявку или разные номера заявок.';
                return;
            }
        }

        const requestIdsSorted = Array.from(byRequestId.keys()).sort((a, b) => {
            const na = parseInt(a, 10);
            const nb = parseInt(b, 10);
            const aNum = !Number.isNaN(na) && String(na) === a;
            const bNum = !Number.isNaN(nb) && String(nb) === b;
            if (aNum && bNum) return na - nb;
            return a.localeCompare(b, undefined, { numeric: true });
        });

        saveButton.disabled = true;
        statusEl.textContent = 'Сохраняем части в базе и формируем файлы...';
        const links = [];

        try {
            for (let g = 0; g < requestIdsSorted.length; g += 1) {
                const rid = requestIdsSorted[g];
                const groupLayers = byRequestId.get(rid);
                const geometry = Split.buildMergedGeometryFromLayers(groupLayers);
                if (!geometry) {
                    throw new Error('Нет полигонов для заявки ' + rid + '.');
                }
                const props = Split.getProps(groupLayers[0]);
                const saveResponse = await fetch(state.cfg.urls.saveNewObject, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    body: JSON.stringify({
                        geometry,
                        name: props.name,
                        request_id: props.request_id,
                        source_label: state.selectedSourceLabel,
                    }),
                });
                const saveResult = await saveResponse.json();
                if (!saveResponse.ok || !saveResult.ok) {
                    throw new Error(
                        saveResult.error ||
                            'Ошибка сохранения в базе (заявка ' + rid + ', ' + groupLayers.length + ' ч.).'
                    );
                }
                const response = await fetch(state.cfg.urls.exportGeometry, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRFToken': getCookie('csrftoken') || '',
                    },
                    body: JSON.stringify({
                        geometry,
                        properties: {
                            request_id: props.request_id,
                            name: props.name,
                            OwnerLegalPersonId: saveResult.owner_id,
                        },
                    }),
                });
                const result = await response.json();
                if (!response.ok || !result.ok) {
                    throw new Error(result.error || 'Ошибка выгрузки (заявка ' + rid + ').');
                }
                links.push({
                    partCount: groupLayers.length,
                    name: props.name,
                    requestId: props.request_id,
                    geojson: result.geojson_url,
                    shp: result.shapefile_url,
                });
            }

            exportLinksEl.innerHTML = links
                .map(
                    (item) =>
                        '<div style="margin:6px 0;">' +
                        '<strong>Заявка ' +
                        escapeHtml(String(item.requestId)) +
                        '</strong>' +
                        (item.partCount > 1 ? ' (' + item.partCount + ' полигонов)' : '') +
                        ', название: ' +
                        escapeHtml(item.name) +
                        ' — ' +
                        '<a class="button-link" href="' +
                        item.geojson +
                        '" download>GeoJSON</a> ' +
                        '<a class="button-link" href="' +
                        item.shp +
                        '">SHP (ZIP)</a>' +
                        '</div>'
                )
                .join('');

            statusEl.textContent =
                'Сохранено и выгружено записей по заявкам: ' +
                links.length +
                ' (полигонов на карте: ' +
                layersAfterAttrs.length +
                ').';
        } catch (error) {
            statusEl.textContent = error.message || 'Не удалось сохранить и выгрузить части.';
        } finally {
            saveButton.disabled = false;
        }
    };
})(typeof window !== 'undefined' ? window : global);

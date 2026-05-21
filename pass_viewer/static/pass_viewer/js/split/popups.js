(function (global) {
    'use strict';

    const PV = global.PassViewer;
    const Split = global.PassViewerSplit;

    const escapeHtml = PV.escapeHtml.bind(PV);
    const stripGeometryTo2D = PV.stripGeometryTo2D.bind(PV);

    function historyNote(props) {
        const hist = Split.getHistory(props);
        if (!hist.length) return '';
        const last = hist[hist.length - 1];
        const srcLabels = {
            passport: 'паспорт',
            selection_inside: 'выборка внутри',
            selection_inside_reentry: 'повторная выборка внутри',
            selection_outside: 'выборка снаружи',
            line_cut: 'разрез линией',
        };
        const label = srcLabels[last.source] || last.source;
        return (
            '<div style="margin-top:6px;font-size:11px;color:#64748b;">Последнее назначение: ' +
            escapeHtml(last.request_id || '-') +
            ' (' +
            escapeHtml(label) +
            ')</div>'
        );
    }

    Split.bindReadOnlyPartPopup = function bindReadOnlyPartPopup(layer) {
        const props = Split.getProps(layer);
        const lockedNote = Split.isInsideLocked(props)
            ? '<div style="margin-top:8px;font-size:12px;color:#0f766e;">Заявка зафиксирована после выборки «внутри». При повторном попадании внутрь нового полигона выборки можно переназначить.</div>'
            : '';
        const lineCutNote = Split.isLineCutPreserve(props)
            ? '<div style="margin-top:8px;font-size:12px;color:#92400e;">Заявка после разрезания линией не перезаписывается выборкой полигоном, если центроид снаружи выделения.</div>'
            : '';
        const html =
            '<div style="min-width:220px;">' +
            '<div><strong>Часть объекта</strong></div>' +
            '<div style="margin-top:6px;"><strong>№ Заявки:</strong> ' +
            escapeHtml(props.request_id || '-') +
            '</div>' +
            '<div style="margin-top:6px;"><strong>Название:</strong> ' +
            escapeHtml(props.name || '-') +
            '</div>' +
            historyNote(props) +
            lockedNote +
            lineCutNote +
            '</div>';
        layer.bindPopup(html);
    };

    Split.openPartAttributePopup = function openPartAttributePopup(ctx, layer, idx, total, options) {
        const opts = options || {};
        const state = ctx.state;
        const map = ctx.map;

        return new Promise((resolve) => {
            const popupId = 'split-attrs-' + Date.now() + '-' + idx;
            const center = layer.getBounds().getCenter();
            const touchedLine = Split.isLineCutTouched(Split.getProps(layer));
            let hint = '';
            if (touchedLine) {
                hint =
                    '<p style="margin:0 0 8px;font-size:12px;color:#92400e;">Пересечена линией разреза — укажите заявку для этой части.</p>';
            } else if (opts.singleMode) {
                hint =
                    '<p style="margin:0 0 8px;font-size:12px;color:#475569;">Укажите № заявки и название для этой части после разрезания.</p>';
            }
            const popupHtml =
                '<div id="' +
                popupId +
                '" style="min-width:230px;">' +
                '<div style="font-weight:700;margin-bottom:8px;">Часть ' +
                idx +
                ' из ' +
                total +
                '</div>' +
                hint +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ Заявки:</label>' +
                '<input data-field="request" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name" type="text" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<div data-error style="color:#b42318;font-size:12px;min-height:16px;"></div>' +
                '<button type="button" data-save class="map-toolbar-btn map-toolbar-btn--primary" style="width:100%;margin-top:6px;">Сохранить</button>' +
                '</div>';
            const popup = L.popup({ closeButton: false, closeOnClick: false, autoClose: false })
                .setLatLng(center)
                .setContent(popupHtml)
                .openOn(map);

            let settled = false;
            const finish = (value) => {
                if (settled) return;
                settled = true;
                resolve(value);
            };

            popup.on('remove', () => finish(false));

            setTimeout(() => {
                const root = document.getElementById(popupId);
                if (!root) {
                    finish(false);
                    return;
                }
                const requestInput = root.querySelector('[data-field="request"]');
                const nameInput = root.querySelector('[data-field="name"]');
                const saveBtn = root.querySelector('[data-save]');
                const errEl = root.querySelector('[data-error]');
                const props = Split.getProps(layer);
                requestInput.value = (props.request_id || '').trim();
                nameInput.value = (props.name || '').trim();
                requestInput.focus();

                saveBtn.addEventListener('click', () => {
                    const requestId = (requestInput.value || '').trim();
                    const name = (nameInput.value || '').trim();
                    if (!requestId || !/^\d+$/.test(requestId)) {
                        errEl.textContent = 'Введите № заявки (только цифры).';
                        return;
                    }
                    if (!name) {
                        errEl.textContent = 'Введите название.';
                        return;
                    }
                    const p = Split.ensureFeature(layer, stripGeometryTo2D);
                    Split.assignRequest(p, requestId, name, Split.SOURCE.LINE_CUT, {
                        lineCutPreserve: !opts.singleMode,
                    });
                    if (opts.singleMode) {
                        delete p[Split.PROP.LINE_CUT_TOUCHED];
                    }
                    Split.bindReadOnlyPartPopup(layer);
                    map.closePopup(popup);
                    finish(true);
                });
            }, 0);
        });
    };

    Split.openDualAssignmentPopup = function openDualAssignmentPopup(ctx, insideCount, outsideCount) {
        const state = ctx.state;
        const map = ctx.map;

        return new Promise((resolve) => {
            const popupId = 'split-dual-' + Date.now();
            const popupHtml =
                '<div id="' +
                popupId +
                '" style="min-width:280px;">' +
                '<div style="font-weight:700;margin-bottom:8px;">Назначение заявок</div>' +
                '<p style="margin:0 0 10px;font-size:13px;color:#475569;">Внутри выделения: <strong>' +
                insideCount +
                '</strong> ч., снаружи: <strong>' +
                outsideCount +
                '</strong> ч.</p>' +
                '<div style="font-weight:600;margin:8px 0 4px;color:#0f766e;">Внутри полигона</div>' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ заявки:</label>' +
                '<input data-field="req-in" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:6px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name-in" type="text" style="width:100%;box-sizing:border-box;margin-bottom:10px;" />' +
                '<div style="font-weight:600;margin:8px 0 4px;color:#92400e;">Снаружи полигона</div>' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ заявки:</label>' +
                '<input data-field="req-out" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:6px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name-out" type="text" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<div data-error style="color:#b42318;font-size:12px;min-height:16px;"></div>' +
                '<button type="button" data-save class="map-toolbar-btn map-toolbar-btn--primary" style="width:100%;margin-top:6px;">Применить</button>' +
                '</div>';
            const popup = L.popup({ closeButton: true, closeOnClick: false, autoClose: false })
                .setLatLng(map.getCenter())
                .setContent(popupHtml)
                .openOn(map);

            let settled = false;
            const finish = (value) => {
                if (settled) return;
                settled = true;
                resolve(value);
            };
            popup.on('remove', () => finish(null));

            setTimeout(() => {
                const root = document.getElementById(popupId);
                if (!root) {
                    finish(null);
                    return;
                }
                const rIn = root.querySelector('[data-field="req-in"]');
                const nIn = root.querySelector('[data-field="name-in"]');
                const rOut = root.querySelector('[data-field="req-out"]');
                const nOut = root.querySelector('[data-field="name-out"]');
                const errEl = root.querySelector('[data-error]');
                const saveBtn = root.querySelector('[data-save]');
                rIn.value = (state.selectedRequestId || '').trim();
                nIn.value = (state.selectedName || '').trim();
                rOut.value = (state.lastOutsideRequestId || state.selectedRequestId || '').trim();
                nOut.value = state.selectedName ? state.selectedName + ' (вне выделения)' : '';
                rIn.focus();

                saveBtn.addEventListener('click', () => {
                    const ri = (rIn.value || '').trim();
                    const ni = (nIn.value || '').trim();
                    const ro = (rOut.value || '').trim();
                    const no = (nOut.value || '').trim();
                    if (!ri || !/^\d+$/.test(ri)) {
                        errEl.textContent = 'Внутри: укажите № заявки (только цифры).';
                        return;
                    }
                    if (!ni) {
                        errEl.textContent = 'Внутри: введите название.';
                        return;
                    }
                    if (!ro || !/^\d+$/.test(ro)) {
                        errEl.textContent = 'Снаружи: укажите № заявки (только цифры).';
                        return;
                    }
                    if (!no) {
                        errEl.textContent = 'Снаружи: введите название.';
                        return;
                    }
                    if (ri === ro) {
                        errEl.textContent = 'Номера заявок внутри и снаружи должны различаться.';
                        return;
                    }
                    finish({ inside: { request_id: ri, name: ni }, outside: { request_id: ro, name: no } });
                    map.closePopup(popup);
                });
            }, 0);
        });
    };

    Split.openOutsideOnlyAssignmentPopup = function openOutsideOnlyAssignmentPopup(ctx, outsideCount, skippedPreservedCount) {
        const state = ctx.state;
        const map = ctx.map;

        return new Promise((resolve) => {
            const popupId = 'split-out-only-' + Date.now();
            const popupHtml =
                '<div id="' +
                popupId +
                '" style="min-width:280px;">' +
                '<div style="font-weight:700;margin-bottom:8px;">Назначение заявки (снаружи)</div>' +
                '<p style="margin:0 0 10px;font-size:13px;color:#475569;">Новых незафиксированных частей внутри выделения нет. ' +
                'Снаружи для назначения: <strong>' +
                outsideCount +
                '</strong> ч.; без изменений: <strong>' +
                skippedPreservedCount +
                '</strong> ч.</p>' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">№ заявки:</label>' +
                '<input data-field="req-out" type="text" inputmode="numeric" pattern="[0-9]*" style="width:100%;box-sizing:border-box;margin-bottom:6px;" />' +
                '<label style="display:block;font-size:12px;margin-bottom:4px;">Название:</label>' +
                '<input data-field="name-out" type="text" style="width:100%;box-sizing:border-box;margin-bottom:8px;" />' +
                '<div data-error style="color:#b42318;font-size:12px;min-height:16px;"></div>' +
                '<button type="button" data-save class="map-toolbar-btn map-toolbar-btn--primary" style="width:100%;margin-top:6px;">Применить</button>' +
                '</div>';
            const popup = L.popup({ closeButton: true, closeOnClick: false, autoClose: false })
                .setLatLng(map.getCenter())
                .setContent(popupHtml)
                .openOn(map);

            let settled = false;
            const finish = (value) => {
                if (settled) return;
                settled = true;
                resolve(value);
            };
            popup.on('remove', () => finish(null));

            setTimeout(() => {
                const root = document.getElementById(popupId);
                if (!root) {
                    finish(null);
                    return;
                }
                const rOut = root.querySelector('[data-field="req-out"]');
                const nOut = root.querySelector('[data-field="name-out"]');
                const errEl = root.querySelector('[data-error]');
                const saveBtn = root.querySelector('[data-save]');
                rOut.value = (state.lastOutsideRequestId || state.selectedRequestId || '').trim();
                nOut.value = (state.selectedName || '').trim();
                rOut.focus();

                saveBtn.addEventListener('click', () => {
                    const ro = (rOut.value || '').trim();
                    const no = (nOut.value || '').trim();
                    if (!ro || !/^\d+$/.test(ro)) {
                        errEl.textContent = 'Укажите № заявки (только цифры).';
                        return;
                    }
                    if (!no) {
                        errEl.textContent = 'Введите название.';
                        return;
                    }
                    finish({ request_id: ro, name: no });
                    map.closePopup(popup);
                });
            }, 0);
        });
    };

    Split.promptPartAttributes = async function promptPartAttributes(ctx, layers, options) {
        const opts = options || {};
        const needPrompt = layers.filter((layer) => {
            const p = Split.getProps(layer);
            if (opts.onlyLineCutTouched && !Split.isLineCutTouched(p)) return false;
            const requestId = String(p.request_id || '').trim();
            const name = String(p.name || '').trim();
            return !requestId || !name;
        });

        if (!needPrompt.length) return true;

        for (let i = 0; i < needPrompt.length; i += 1) {
            const layer = needPrompt[i];
            if (opts.onlyLineCutTouched) {
                ctx.statusEl.textContent =
                    'Заполните атрибуты для частей, пересечённых линией разреза (остальные сохраняют текущие заявки).';
            } else if (opts.allPartsInSingleMode) {
                ctx.statusEl.textContent = 'Заполните атрибуты для каждой части после разрезания.';
            }
            const ok = await Split.openPartAttributePopup(ctx, layer, i + 1, needPrompt.length, {
                singleMode: !!opts.allPartsInSingleMode,
            });
            if (!ok) return false;
        }
        return true;
    };
})(typeof window !== 'undefined' ? window : global);

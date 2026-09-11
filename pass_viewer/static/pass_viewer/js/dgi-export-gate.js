(function (global) {
    'use strict';

    const PV = global.PassViewer = global.PassViewer || {};

    // Слои группы «Границы З/У»: подтверждение требуется при пересечении 10+%.
    const ZU_GATE_LAYERS = [
        { key: 'percent_moscow_rent', label: 'г. Москва с арендой' },
        { key: 'percent_private_rent', label: 'Частная или федеральная собственность с арендой' },
        { key: 'percent_private_no_rent', label: 'Частная или федеральная собственность без аренды' },
        { key: 'percent_dgi_renovation', label: 'Реновация' },
    ];
    const ZU_GATE_THRESHOLD = 10;

    function topZuLayer(data) {
        let top = null;
        ZU_GATE_LAYERS.forEach((layer) => {
            const pct = Number(data && data[layer.key]) || 0;
            if (pct > 0 && (!top || pct > top.percent)) {
                top = { key: layer.key, label: layer.label, percent: pct };
            }
        });
        return top;
    }

    function hasAttachedFiles() {
        return document.querySelectorAll('#attachments-list .add-object-attachment').length > 0;
    }

    /**
     * Hidden DGI intersection check before export modal.
     * Подтверждение требуется при пересечении 10+% с любым слоем группы «Границы З/У».
     * @returns {Promise<{available: boolean, percentPrivate: number, intersectsPrivate: boolean, requiresConfirm: boolean, triggerLayer: string, triggerPercent: number}>}
     */
    PV.runDgiExportGate = async function runDgiExportGate(options) {
        const geometry = options && options.geometry;
        const checkDgiUrl = options && options.checkDgiUrl;
        const getCookie =
            (options && options.getCookie) ||
            (PV.getCookie && PV.getCookie.bind(PV)) ||
            function () {
                return '';
            };

        const empty = {
            available: false,
            percentPrivate: 0,
            intersectsPrivate: false,
            requiresConfirm: false,
            triggerLayer: '',
            triggerPercent: 0,
        };

        if (!geometry || !checkDgiUrl) {
            return empty;
        }

        try {
            const response = await fetch(checkDgiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': getCookie('csrftoken') || '',
                },
                body: JSON.stringify({geometry, for_export: true}),
            });
            const data = await response.json();
            if (!response.ok || !data.ok) {
                console.error('DGI export gate: API error', data.error || response.status);
                return empty;
            }
            if (data.available === false) {
                return empty;
            }
            const percentPrivate = Number(data.percent_private) || 0;
            const trigger = topZuLayer(data);
            return {
                available: true,
                percentPrivate: percentPrivate,
                intersectsPrivate: percentPrivate > 0,
                requiresConfirm: !!trigger && trigger.percent >= ZU_GATE_THRESHOLD,
                triggerLayer: trigger ? trigger.label : '',
                triggerPercent: trigger ? trigger.percent : 0,
            };
        } catch (error) {
            console.error('DGI export gate: request failed', error);
            return empty;
        }
    };

    PV.buildDgiExportWarningText = function buildDgiExportWarningText(percent, layerLabel) {
        const pct = Number(percent);
        if (!pct || pct <= 0) {
            return '';
        }
        const where = layerLabel
            ? 'слой «' + layerLabel + '» (группа «Границы З/У»)'
            : 'Частную собственность';
        return 'Внимание: Границы объекта пересекают ' + where + ' на ' + pct + '%';
    };

    PV.createPendingDgiApprove = function createPendingDgiApprove(percent, layerLabel) {
        return {
            approved_at: new Date().toISOString(),
            percent: Number(percent) || 0,
            user: '',
            ownership: 'private',
            layer: layerLabel || '',
        };
    };

    /**
     * Wire export button: DGI check -> optional confirm (with required attachment) -> save modal.
     */
    PV.initDgiExportGateFlow = function initDgiExportGateFlow(config) {
        const exportButton = config.exportButton;
        const checkDgiUrl = config.checkDgiUrl;
        const getCookie = config.getCookie;
        const getGeometry = config.getGeometry;
        const openSaveModal = config.openSaveModal;
        const dgiConfirmModal = config.dgiConfirmModal;
        const dgiConfirmAgree = config.dgiConfirmAgree;
        const dgiConfirmBack = config.dgiConfirmBack;
        const getPendingApprove = config.getPendingApprove;
        const setPendingApprove = config.setPendingApprove;

        if (!exportButton || !getGeometry || !openSaveModal) {
            return;
        }

        let gateResult = null;
        const labelEl = exportButton.querySelector('.map-toolbar-btn__label');
        const originalLabel = labelEl ? labelEl.textContent : exportButton.textContent;
        const confirmTextEl = document.getElementById('dgi-export-confirm-text');

        function setExportLabel(text) {
            if (PV.setMapToolbarLabel) {
                PV.setMapToolbarLabel(exportButton, text);
            } else if (labelEl) {
                labelEl.textContent = text;
            } else {
                exportButton.textContent = text;
            }
        }

        function setButtonLoading(loading) {
            exportButton.disabled = !!loading;
            setExportLabel(loading ? 'Проверка…' : originalLabel);
        }

        function isConfirmModalOpen() {
            return !!dgiConfirmModal && dgiConfirmModal.style.display !== 'none';
        }

        function closeConfirmModal() {
            if (dgiConfirmModal) {
                dgiConfirmModal.style.display = 'none';
            }
        }

        function refreshAgreeState() {
            if (!dgiConfirmAgree) {
                return;
            }
            dgiConfirmAgree.disabled = !hasAttachedFiles();
            dgiConfirmAgree.title = dgiConfirmAgree.disabled
                ? 'Сначала загрузите файл-обоснование'
                : '';
        }

        function showConfirmModal() {
            if (!dgiConfirmModal) {
                return;
            }
            if (confirmTextEl && gateResult) {
                confirmTextEl.textContent =
                    'Я уведомлён, что пересечение со слоем «' +
                    (gateResult.triggerLayer || '—') +
                    '» группы «Границы З/У» составляет ' +
                    gateResult.triggerPercent +
                    '% (более 10%).';
            }
            dgiConfirmModal.style.display = 'flex';
            refreshAgreeState();
        }

        async function proceedAfterGate() {
            if (!gateResult) {
                openSaveModal({});
                return;
            }
            if (gateResult.requiresConfirm) {
                showConfirmModal();
                return;
            }
            openSaveModal({
                warningPercent: gateResult.triggerPercent > 0 ? gateResult.triggerPercent : null,
                warningLayer: gateResult.triggerLayer || '',
            });
        }

        exportButton.addEventListener('click', async () => {
            const geometry = getGeometry();
            if (!geometry) {
                return;
            }
            setButtonLoading(true);
            gateResult = null;
            if (setPendingApprove) {
                setPendingApprove(null);
            }
            try {
                gateResult = await PV.runDgiExportGate({
                    geometry,
                    checkDgiUrl,
                    getCookie,
                });
            } finally {
                setButtonLoading(false);
            }
            await proceedAfterGate();
        });

        if (dgiConfirmAgree) {
            dgiConfirmAgree.addEventListener('click', () => {
                if (!gateResult || !gateResult.requiresConfirm) {
                    closeConfirmModal();
                    return;
                }
                if (!hasAttachedFiles()) {
                    refreshAgreeState();
                    return;
                }
                if (setPendingApprove) {
                    setPendingApprove(
                        PV.createPendingDgiApprove(
                            gateResult.triggerPercent,
                            gateResult.triggerLayer
                        )
                    );
                }
                closeConfirmModal();
                openSaveModal({
                    warningPercent: gateResult.triggerPercent,
                    warningLayer: gateResult.triggerLayer || '',
                });
            });
        }

        if (dgiConfirmBack) {
            dgiConfirmBack.addEventListener('click', () => {
                closeConfirmModal();
                gateResult = null;
                if (setPendingApprove) {
                    setPendingApprove(null);
                }
            });
        }

        if (dgiConfirmModal) {
            dgiConfirmModal.addEventListener('click', (event) => {
                if (event.target === dgiConfirmModal) {
                    closeConfirmModal();
                    gateResult = null;
                    if (setPendingApprove) {
                        setPendingApprove(null);
                    }
                }
            });
        }

        // Загрузка/удаление вложения из модалки подтверждения меняет доступность «Согласен».
        document.addEventListener('pv:attachments-changed', () => {
            if (isConfirmModalOpen()) {
                refreshAgreeState();
            }
        });

        return {
            getGateResult: () => gateResult,
            getPendingApprove: getPendingApprove,
        };
    };
})(typeof window !== 'undefined' ? window : global);

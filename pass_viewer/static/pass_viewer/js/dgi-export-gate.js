(function (global) {
    'use strict';

    const PV = global.PassViewer = global.PassViewer || {};

    /**
     * Hidden DGI intersection check before export modal (private ownership layer only).
     * @returns {Promise<{available: boolean, percentPrivate: number, intersectsPrivate: boolean, requiresConfirm: boolean}>}
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
            return {
                available: true,
                percentPrivate: percentPrivate,
                intersectsPrivate: percentPrivate > 0,
                requiresConfirm: percentPrivate > 10,
            };
        } catch (error) {
            console.error('DGI export gate: request failed', error);
            return empty;
        }
    };

    PV.buildDgiExportWarningText = function buildDgiExportWarningText(percentPrivate) {
        const pct = Number(percentPrivate);
        if (!pct || pct <= 0) {
            return '';
        }
        return (
            'Внимание: Границы объекта пересекают Частную собственность на ' + pct + '%'
        );
    };

    PV.createPendingDgiApprove = function createPendingDgiApprove(percentPrivate) {
        return {
            approved_at: new Date().toISOString(),
            percent: Number(percentPrivate) || 0,
            user: '',
            ownership: 'private',
        };
    };

    /**
     * Wire export button: DGI check -> optional confirm -> open save modal.
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
        const originalLabel = exportButton.textContent;

        function setButtonLoading(loading) {
            exportButton.disabled = !!loading;
            if (loading) {
                exportButton.textContent = 'Проверка…';
            } else {
                exportButton.textContent = originalLabel;
            }
        }

        function closeConfirmModal() {
            if (dgiConfirmModal) {
                dgiConfirmModal.style.display = 'none';
            }
        }

        function showConfirmModal() {
            if (dgiConfirmModal) {
                dgiConfirmModal.style.display = 'flex';
            }
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
                warningPercent: gateResult.intersectsPrivate ? gateResult.percentPrivate : null,
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
                if (setPendingApprove) {
                    setPendingApprove(PV.createPendingDgiApprove(gateResult.percentPrivate));
                }
                closeConfirmModal();
                openSaveModal({warningPercent: gateResult.percentPrivate});
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

        return {
            getGateResult: () => gateResult,
            getPendingApprove: getPendingApprove,
        };
    };
})(typeof window !== 'undefined' ? window : global);

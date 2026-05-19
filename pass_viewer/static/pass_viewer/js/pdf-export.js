(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    const PDF_BLOCK_WIDTH_PX = 794;
    const PDF_MARGIN_MM = 10;
    const PDF_BLOCK_GAP_MM = 4;
    const PDF_BLOCK_CANVAS_SCALE = 1.75;

    function stripPopupButtons(html) {
        return String(html || '').replace(/<button[\s\S]*?<\/button>/gi, '');
    }

    function mergePdfIntersectFeatureCollections(passportFc, dgiFc, odhFc) {
        const normalizeGeoJson = PassViewer.normalizeGeoJson;
        const out = [];
        const passportKey = (props) => {
            const r = String(props?.rootid ?? '').trim();
            const q = String(props?.request_id ?? '').trim();
            return 'p:' + r + ':' + q;
        };
        const seenPassportLike = new Set();
        const pushFc = (fc) => {
            const n = normalizeGeoJson(fc);
            if (!n || !Array.isArray(n.features)) {
                return;
            }
            n.features.forEach((f) => {
                const props = f?.properties || {};
                const src = String(props.source ?? '').trim();
                if (src !== 'ДГИ' && src !== 'ОДХ') {
                    out.push(f);
                    const k = passportKey(props);
                    if (k && k !== 'p::' && k !== 'p:null:null') {
                        seenPassportLike.add(k);
                    }
                    return;
                }
                if (src === 'ОДХ' || src === 'ОЗН') {
                    const k = passportKey(props);
                    if (k && seenPassportLike.has(k)) {
                        return;
                    }
                }
                out.push(f);
            });
        };
        pushFc(passportFc);
        pushFc(dgiFc);
        pushFc(odhFc);
        return {type: 'FeatureCollection', features: out};
    }

    function formatAreaText(geometry) {
        const area = PassViewer.calculateGeometryAreaSqMeters(geometry);
        if (!Number.isFinite(area) || area <= 0) {
            return '—';
        }
        return area.toFixed(2) + ' м² (' + (area / 10000).toFixed(2) + ' га)';
    }

    function displayField(value) {
        const t = String(value ?? '').trim();
        if (!t || ['null', 'none', '-'].includes(t.toLowerCase())) {
            return '—';
        }
        return t;
    }

    function buildObjectInfoElement(objectInfo) {
        const wrap = document.createElement('div');
        wrap.style.cssText = 'padding:0 0 8px;box-sizing:border-box;width:100%;';
        const title = document.createElement('h2');
        title.textContent = 'Сведения об объекте';
        title.style.cssText = 'margin:0 0 10px;font-size:16px;font-weight:700;color:#0f172a;';
        wrap.appendChild(title);
        const rows = [
            ['№ заявки', displayField(objectInfo.requestId)],
            ['Название', displayField(objectInfo.name)],
            ['Площадь', displayField(objectInfo.areaText)],
        ];
        rows.forEach(([label, value]) => {
            const row = document.createElement('div');
            row.style.cssText = 'margin:0 0 6px;font-size:12px;line-height:1.45;color:#334155;';
            row.innerHTML =
                '<strong style="color:#0f172a;">' +
                escapeHtml(label) +
                ':</strong> ' +
                escapeHtml(value);
            wrap.appendChild(row);
        });
        const intTitle = document.createElement('h2');
        intTitle.textContent = 'Пересечения (паспорта, ДГИ, ОДХ)';
        intTitle.style.cssText = 'margin:14px 0 8px;font-size:15px;font-weight:700;color:#0f172a;';
        wrap.appendChild(intTitle);
        const sub = document.createElement('div');
        sub.style.cssText = 'margin:0 0 4px;font-size:11px;line-height:1.4;color:#64748b;';
        sub.textContent =
            'Содержимое всплывающих окон для паспортов ДТ/ОДХ и пересекающихся объектов ДГИ и ОДХ (по данным PostGIS).';
        wrap.appendChild(sub);
        return wrap;
    }

    function escapeHtml(text) {
        return PassViewer.escapeHtml(String(text ?? ''));
    }

    function placeBlockCanvasOnPdf(pdf, blockCanvas, yMm, layout) {
        const {marginMm, pageW, pageH, contentW, maxContentHmm} = layout;
        const pxPerMm = blockCanvas.width / contentW;
        let blockHmm = blockCanvas.height / pxPerMm;
        let drawW = contentW;
        let drawH = blockHmm;
        if (blockHmm > maxContentHmm) {
            const scale = maxContentHmm / blockHmm;
            drawH = maxContentHmm;
            drawW = contentW * scale;
            blockHmm = drawH;
        }
        if (yMm + blockHmm + PDF_BLOCK_GAP_MM > pageH - marginMm) {
            pdf.addPage('a4', 'p');
            yMm = marginMm;
        }
        const offX = marginMm + (contentW - drawW) / 2;
        pdf.addImage(blockCanvas.toDataURL('image/png'), 'PNG', offX, yMm, drawW, drawH);
        return yMm + blockHmm + PDF_BLOCK_GAP_MM;
    }

    function createOffscreenBlockRoot() {
        const root = document.createElement('div');
        Object.assign(root.style, {
            position: 'fixed',
            left: '-12000px',
            top: '0',
            width: PDF_BLOCK_WIDTH_PX + 'px',
            background: '#ffffff',
            color: '#0f172a',
            fontFamily: 'system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
            padding: '0',
            boxSizing: 'border-box',
        });
        document.body.appendChild(root);
        return root;
    }

    function buildIntersectionBlockElement(feature, idx, buildIntersectionHtml) {
        const props = feature?.properties || {};
        const rawHtml = buildIntersectionHtml(props);
        const box = document.createElement('div');
        box.className = 'pdf-intersection-block';
        box.style.cssText =
            'border:1px solid #cbd5e1;border-radius:8px;padding:12px;background:#f8fafc;font-size:13px;line-height:1.45;box-sizing:border-box;width:100%;';
        const head = document.createElement('div');
        head.style.cssText = 'font-weight:600;margin-bottom:8px;color:#0369a1;';
        head.textContent = 'Пересечение ' + (idx + 1);
        box.appendChild(head);
        const inner = document.createElement('div');
        inner.innerHTML = stripPopupButtons(rawHtml);
        box.appendChild(inner);
        return box;
    }

    async function renderBlockCanvas(blockEl) {
        await new Promise((r) => requestAnimationFrame(() => r()));
        return html2canvas(blockEl, {
            scale: PDF_BLOCK_CANVAS_SCALE,
            useCORS: true,
            allowTaint: true,
            logging: false,
            backgroundColor: '#ffffff',
        });
    }

    async function addPortraitContentPages(pdf, objectInfo, features, buildIntersectionHtml) {
        const marginMm = PDF_MARGIN_MM;
        const pageW = pdf.internal.pageSize.getWidth();
        const pageH = pdf.internal.pageSize.getHeight();
        const contentW = pageW - 2 * marginMm;
        const maxContentHmm = pageH - 2 * marginMm;
        const layout = {marginMm, pageW, pageH, contentW, maxContentHmm};
        let yMm = marginMm;
        const root = createOffscreenBlockRoot();

        try {
            const infoEl = buildObjectInfoElement(objectInfo);
            root.appendChild(infoEl);
            const infoCanvas = await renderBlockCanvas(infoEl);
            root.removeChild(infoEl);
            yMm = placeBlockCanvasOnPdf(pdf, infoCanvas, yMm, layout);

            if (!features.length) {
                const emptyEl = document.createElement('p');
                emptyEl.style.cssText = 'margin:0;font-size:12px;color:#334155;';
                emptyEl.textContent = 'Пересечений с паспортами и объектами ДГИ/ОДХ не найдено.';
                root.appendChild(emptyEl);
                const emptyCanvas = await renderBlockCanvas(emptyEl);
                root.removeChild(emptyEl);
                placeBlockCanvasOnPdf(pdf, emptyCanvas, yMm, layout);
                return;
            }

            for (let idx = 0; idx < features.length; idx += 1) {
                const blockEl = buildIntersectionBlockElement(features[idx], idx, buildIntersectionHtml);
                root.appendChild(blockEl);
                const blockCanvas = await renderBlockCanvas(blockEl);
                root.removeChild(blockEl);
                yMm = placeBlockCanvasOnPdf(pdf, blockCanvas, yMm, layout);
            }
        } finally {
            if (root.parentNode) {
                root.parentNode.removeChild(root);
            }
        }
    }

    async function buildAndSavePdf(options) {
        const {objectInfo, features, buildIntersectionHtml, fileName} = options;

        const pdf = new global.jspdf.jsPDF({
            unit: 'mm',
            format: 'a4',
            orientation: 'p',
        });
        await addPortraitContentPages(pdf, objectInfo, features, buildIntersectionHtml);
        pdf.save(fileName);
        return fileName;
    }

    function buildExportFileName(ctx) {
        const idPart = String(ctx.passportNo || ctx.requestId || 'object').replace(/\W+/g, '_');
        return 'export_map_' + idPart + '_' + new Date().toISOString().slice(0, 10) + '.pdf';
    }

    function buildObjectInfoFromContext(ctx) {
        return {
            passportNo: ctx.passportNo || '',
            requestId: ctx.requestId || '',
            name: ctx.name || '',
            areaText: formatAreaText(ctx.geometry),
        };
    }

    PassViewer.PdfExport = {
        mergePdfIntersectFeatureCollections,
        stripPopupButtons,
        buildAndSavePdf,
        buildExportFileName,
        buildObjectInfoFromContext,
    };
})(typeof window !== 'undefined' ? window : global);

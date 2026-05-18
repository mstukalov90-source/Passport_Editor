(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    const PDF_FRAME_ASPECT = 287 / 200;
    const PDF_FRAME_MAX_FILL = 0.88;
    const PDF_BLOCK_WIDTH_PX = 794;
    const PDF_MARGIN_MM = 10;
    const PDF_BLOCK_GAP_MM = 4;
    const PDF_HTML2CANVAS_SCALE = 1;
    const PDF_MAP_OUTPUT_SCALE = 2;
    const PDF_BLOCK_CANVAS_SCALE = 1.75;

    let frameState = null;

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

    function waitForVisibleTilesLoaded(mapElement, timeoutMs) {
        const started = Date.now();
        return new Promise((resolve) => {
            const tick = () => {
                const tiles = mapElement.querySelectorAll('img.leaflet-tile');
                let pending = 0;
                tiles.forEach((img) => {
                    if (!img.complete || img.naturalWidth === 0) {
                        pending += 1;
                    }
                });
                if (pending === 0 || Date.now() - started > timeoutMs) {
                    requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
                    return;
                }
                setTimeout(tick, 90);
            };
            setTimeout(tick, 100);
        });
    }

    function leafletRedrawAllVectorLayers(leafletMap) {
        const visit = (layer) => {
            if (!layer) {
                return;
            }
            if (typeof layer.eachLayer === 'function') {
                layer.eachLayer(visit);
                return;
            }
            if (typeof layer.redraw === 'function') {
                try {
                    layer.redraw();
                } catch (e) {
                    /* ignore */
                }
            }
        };
        leafletMap.eachLayer(visit);
    }

    function parseTranslateFromTransform(transform) {
        if (!transform || transform === 'none') {
            return {x: 0, y: 0};
        }
        const matrixMatch = transform.match(/^matrix\((.+)\)$/);
        if (matrixMatch) {
            const parts = matrixMatch[1].split(',').map((s) => parseFloat(s.trim()));
            if (parts.length >= 6) {
                return {x: parts[4] || 0, y: parts[5] || 0};
            }
        }
        const matrix3dMatch = transform.match(/^matrix3d\((.+)\)$/);
        if (matrix3dMatch) {
            const parts = matrix3dMatch[1].split(',').map((s) => parseFloat(s.trim()));
            if (parts.length >= 16) {
                return {x: parts[12] || 0, y: parts[13] || 0};
            }
        }
        const translate3dMatch = transform.match(/translate3d\(([^)]+)\)/);
        if (translate3dMatch) {
            const parts = translate3dMatch[1].split(',').map((s) => parseFloat(s.trim()));
            return {x: parts[0] || 0, y: parts[1] || 0};
        }
        const translateMatch = transform.match(/translate\(([^)]+)\)/);
        if (translateMatch) {
            const parts = translateMatch[1].split(',').map((s) => parseFloat(s.trim()));
            return {x: parts[0] || 0, y: parts[1] || 0};
        }
        return {x: 0, y: 0};
    }

    function flattenElementTransform(el, stash) {
        if (!el || !stash) {
            return;
        }
        const computed = window.getComputedStyle(el);
        const transform = computed.transform || el.style.transform;
        if (!transform || transform === 'none') {
            return;
        }
        const {x, y} = parseTranslateFromTransform(transform);
        if (x === 0 && y === 0) {
            return;
        }
        stash.push({
            el,
            transform: el.style.transform,
            left: el.style.left,
            top: el.style.top,
        });
        const leftBase = parseFloat(computed.left) || 0;
        const topBase = parseFloat(computed.top) || 0;
        el.style.transform = 'none';
        el.style.left = leftBase + x + 'px';
        el.style.top = topBase + y + 'px';
    }

    function flattenLeafletMapForCapture(map) {
        const stash = [];
        const mapDiv = map.getContainer();
        const paneSelectors = [
            '.leaflet-map-pane',
            '.leaflet-tile-pane',
            '.leaflet-overlay-pane',
            '.leaflet-shadow-pane',
            '.leaflet-marker-pane',
        ];
        paneSelectors.forEach((sel) => {
            const pane = mapDiv.querySelector(sel);
            if (pane) {
                flattenElementTransform(pane, stash);
            }
        });
        mapDiv.querySelectorAll('img.leaflet-tile').forEach((img) => {
            flattenElementTransform(img, stash);
        });
        mapDiv.querySelectorAll('.leaflet-overlay-pane .leaflet-zoom-animated').forEach((el) => {
            flattenElementTransform(el, stash);
        });
        return stash;
    }

    function restoreLeafletMapAfterCapture(stash) {
        if (!stash || !stash.length) {
            return;
        }
        stash.forEach((item) => {
            item.el.style.transform = item.transform;
            item.el.style.left = item.left;
            item.el.style.top = item.top;
        });
    }

    function zeroRendererPaddingForCapture(map) {
        const stash = [];
        const visit = (layer) => {
            if (!layer) {
                return;
            }
            if (typeof layer.eachLayer === 'function') {
                layer.eachLayer(visit);
                return;
            }
            const renderer = layer._renderer;
            if (renderer && renderer.options && typeof renderer.options.padding === 'number') {
                stash.push({renderer, padding: renderer.options.padding});
                renderer.options.padding = 0;
            }
        };
        map.eachLayer(visit);
        return stash;
    }

    function restoreRendererPaddingAfterCapture(stash) {
        if (!stash || !stash.length) {
            return;
        }
        stash.forEach((item) => {
            item.renderer.options.padding = item.padding;
        });
    }

    function upscaleCanvas(source, factor) {
        if (!source || !factor || factor <= 1) {
            return source;
        }
        const out = document.createElement('canvas');
        out.width = Math.round(source.width * factor);
        out.height = Math.round(source.height * factor);
        const ctx = out.getContext('2d');
        ctx.imageSmoothingEnabled = true;
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(source, 0, 0, out.width, out.height);
        return out;
    }

    function computeCenteredFrameRect(mapEl) {
        const w = mapEl.clientWidth;
        const h = mapEl.clientHeight;
        const maxW = w * PDF_FRAME_MAX_FILL;
        const maxH = h * PDF_FRAME_MAX_FILL;
        let fw;
        let fh;
        if (maxW / maxH > PDF_FRAME_ASPECT) {
            fh = maxH;
            fw = fh * PDF_FRAME_ASPECT;
        } else {
            fw = maxW;
            fh = fw / PDF_FRAME_ASPECT;
        }
        return {
            left: (w - fw) / 2,
            top: (h - fh) / 2,
            width: fw,
            height: fh,
        };
    }

    function cropCanvasToRect(fullCanvas, frameRect, scale) {
        let x = Math.floor(frameRect.left * scale);
        let y = Math.floor(frameRect.top * scale);
        let w = Math.ceil(frameRect.width * scale);
        let h = Math.ceil(frameRect.height * scale);
        x = Math.max(0, x);
        y = Math.max(0, y);
        if (x + w > fullCanvas.width) {
            w = fullCanvas.width - x;
        }
        if (y + h > fullCanvas.height) {
            h = fullCanvas.height - y;
        }
        if (w <= 0 || h <= 0) {
            return fullCanvas;
        }
        const out = document.createElement('canvas');
        out.width = w;
        out.height = h;
        out.getContext('2d').drawImage(fullCanvas, x, y, w, h, 0, 0, w, h);
        return out;
    }

    function applyFrameRectToWindow(windowEl, frameRect) {
        windowEl.style.left = frameRect.left + 'px';
        windowEl.style.top = frameRect.top + 'px';
        windowEl.style.width = frameRect.width + 'px';
        windowEl.style.height = frameRect.height + 'px';
    }

    function mountPdfFrameOverlay(map) {
        const mapDiv = map.getContainer();
        const existing = mapDiv.querySelector('.pdf-frame-overlay');
        if (existing) {
            existing.remove();
        }
        const frameRect = computeCenteredFrameRect(mapDiv);
        const overlay = document.createElement('div');
        overlay.className = 'pdf-frame-overlay';
        const hint = document.createElement('p');
        hint.className = 'pdf-frame-overlay__hint';
        hint.textContent = 'Подгоните карту под рамку (альбом A4)';
        const windowEl = document.createElement('div');
        windowEl.className = 'pdf-frame-overlay__window';
        applyFrameRectToWindow(windowEl, frameRect);
        overlay.appendChild(hint);
        overlay.appendChild(windowEl);
        mapDiv.appendChild(overlay);
        mapDiv.classList.add('map--pdf-frame-mode');
        return {overlay, windowEl, frameRect};
    }

    function layoutPdfFrameOverlay(map) {
        if (!frameState || !frameState.windowEl) {
            return null;
        }
        const mapDiv = map.getContainer();
        const frameRect = computeCenteredFrameRect(mapDiv);
        applyFrameRectToWindow(frameState.windowEl, frameRect);
        frameState.frameRect = frameRect;
        return frameRect;
    }

    function addMapCanvasAsFullFirstPdfPage(pdf, canvas) {
        const pageW = pdf.internal.pageSize.getWidth();
        const pageH = pdf.internal.pageSize.getHeight();
        const marginMm = 5;
        const innerW = pageW - 2 * marginMm;
        const innerH = pageH - 2 * marginMm;
        const imgRatio = canvas.width / canvas.height;
        const boxRatio = innerW / innerH;
        if (Math.abs(imgRatio - boxRatio) < 0.02) {
            pdf.addImage(canvas.toDataURL('image/png', 0.93), 'PNG', marginMm, marginMm, innerW, innerH);
            return;
        }
        let drawW;
        let drawH;
        let offX;
        let offY;
        if (imgRatio > boxRatio) {
            drawH = innerH;
            drawW = drawH * imgRatio;
            offX = marginMm + (innerW - drawW) / 2;
            offY = marginMm;
        } else {
            drawW = innerW;
            drawH = drawW / imgRatio;
            offX = marginMm;
            offY = marginMm + (innerH - drawH) / 2;
        }
        pdf.addImage(canvas.toDataURL('image/png', 0.93), 'PNG', offX, offY, drawW, drawH);
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

    async function captureMapInFrame(map, frameRect, hooks) {
        const mapDiv = map.getContainer();
        const htmlScale = PDF_HTML2CANVAS_SCALE;

        if (hooks && typeof hooks.beforeCapture === 'function') {
            hooks.beforeCapture();
        }

        const overlay = mapDiv.querySelector('.pdf-frame-overlay');
        const prevOverlayDisplay = overlay ? overlay.style.display : '';
        if (overlay) {
            overlay.style.display = 'none';
        }

        mapDiv.classList.add('pass-viewer-pdf-capture');
        const controls = mapDiv.querySelector('.leaflet-control-container');
        const prevCtrl = controls ? controls.style.display : '';
        if (controls) {
            controls.style.display = 'none';
        }

        let canvas;
        let transformStash = null;
        let rendererStash = null;
        try {
            map.invalidateSize(false);
            mapDiv.scrollTop = 0;
            mapDiv.scrollLeft = 0;
            await waitForVisibleTilesLoaded(mapDiv, 3200);
            await new Promise((r) => setTimeout(r, 80));
            rendererStash = zeroRendererPaddingForCapture(map);
            leafletRedrawAllVectorLayers(map);
            await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(() => setTimeout(r, 40))));
            transformStash = flattenLeafletMapForCapture(map);
            const w = mapDiv.clientWidth;
            const h = mapDiv.clientHeight;
            const fullCanvas = await html2canvas(mapDiv, {
                useCORS: true,
                allowTaint: false,
                scale: htmlScale,
                logging: false,
                backgroundColor: '#f1f5f9',
                foreignObjectRendering: false,
                x: 0,
                y: 0,
                width: w,
                height: h,
                windowWidth: w,
                windowHeight: h,
            });
            const cropped = cropCanvasToRect(fullCanvas, frameRect, htmlScale);
            canvas = upscaleCanvas(cropped, PDF_MAP_OUTPUT_SCALE);
        } finally {
            restoreLeafletMapAfterCapture(transformStash);
            restoreRendererPaddingAfterCapture(rendererStash);
            mapDiv.classList.remove('pass-viewer-pdf-capture');
            if (controls) {
                controls.style.display = prevCtrl;
            }
            if (overlay) {
                overlay.style.display = prevOverlayDisplay;
            }
            if (hooks && typeof hooks.afterCapture === 'function') {
                hooks.afterCapture();
            }
        }
        return canvas;
    }

    function cleanupFrameComposition() {
        if (!frameState) {
            return;
        }
        const st = frameState;
        frameState = null;
        if (st.map) {
            const mapDiv = st.map.getContainer();
            mapDiv.classList.remove('map--pdf-frame-mode');
            const overlay = mapDiv.querySelector('.pdf-frame-overlay');
            if (overlay) {
                overlay.remove();
            }
            if (st.onResize) {
                st.map.off('resize', st.onResize);
            }
        }
        if (st.actionsEl) {
            st.actionsEl.style.display = 'none';
        }
        if (st.onEnd) {
            st.onEnd();
        }
    }

    function startFrameComposition(opts) {
        if (frameState) {
            cleanupFrameComposition();
        }
        const map = opts.map;
        if (!map) {
            return;
        }
        if (opts.onStart) {
            opts.onStart();
        }

        const actionsEl = opts.actionsEl;
        const confirmBtn = opts.confirmBtn;
        const cancelBtn = opts.cancelBtn;
        const statusEl = opts.statusEl;

        if (actionsEl) {
            actionsEl.style.display = 'flex';
        }
        if (statusEl) {
            statusEl.textContent =
                'Сдвиньте и масштабируйте карту, чтобы объект попал в рамку. Затем нажмите «Подтвердить снимок».';
        }

        const mounted = mountPdfFrameOverlay(map);
        const onResize = () => {
            layoutPdfFrameOverlay(map);
        };
        map.on('resize', onResize);

        const confirmHandler = () => {
            const frameRect = layoutPdfFrameOverlay(map) || mounted.frameRect;
            cleanupFrameComposition();
            if (opts.onConfirm) {
                opts.onConfirm(frameRect);
            }
        };

        const cancelHandler = () => {
            cleanupFrameComposition();
            if (statusEl && opts.restoreStatus) {
                statusEl.textContent = opts.restoreStatus;
            }
            if (opts.onCancel) {
                opts.onCancel();
            }
        };

        if (confirmBtn) {
            confirmBtn.onclick = confirmHandler;
        }
        if (cancelBtn) {
            cancelBtn.onclick = cancelHandler;
        }

        frameState = {
            map,
            overlay: mounted.overlay,
            windowEl: mounted.windowEl,
            frameRect: mounted.frameRect,
            actionsEl,
            onResize,
            onEnd: opts.onEnd,
        };
    }

    function isFrameModeActive() {
        return !!frameState;
    }

    async function buildAndSavePdf(options) {
        const {
            mapCanvas,
            objectInfo,
            features,
            buildIntersectionHtml,
            fileName,
        } = options;

        const pdf = new global.jspdf.jsPDF({unit: 'mm', format: 'a4', orientation: 'landscape'});
        addMapCanvasAsFullFirstPdfPage(pdf, mapCanvas);
        pdf.addPage('a4', 'p');
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
        captureMapInFrame,
        buildAndSavePdf,
        buildExportFileName,
        buildObjectInfoFromContext,
        startFrameComposition,
        cancelFrameComposition: cleanupFrameComposition,
        isFrameModeActive,
    };
})(typeof window !== 'undefined' ? window : global);

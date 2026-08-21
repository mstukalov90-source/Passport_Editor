(function (global) {
    'use strict';

    const PassViewer = (global.PassViewer = global.PassViewer || {});

    const PDF_BLOCK_WIDTH_PX = 794;
    const PDF_MARGIN_MM = 10;
    const PDF_BLOCK_GAP_MM = 4;
    const PDF_BLOCK_CANVAS_SCALE = 1.75;
    const PDF_MAP_TARGET_WIDTH_PX = 1400;
    const PDF_MAP_TARGET_HEIGHT_PX = 990;
    const PDF_MAP_SELECTED_STYLE = {color: '#ff0000', weight: 3, fillOpacity: 0.25};

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

    function isSameOriginTileUrl(url) {
        const text = String(url || '');
        if (!text || text.indexOf('data:') === 0) {
            return false;
        }
        if (text.charAt(0) === '/') {
            return true;
        }
        try {
            const parsed = new URL(text, window.location.href);
            return parsed.origin === window.location.origin;
        } catch (e) {
            return false;
        }
    }

    /* Ensure active tile layers request CORS-anonymous so html2canvas can read pixels. */
    function ensureTileLayerCors(leafletMap) {
        const restores = [];
        leafletMap.eachLayer((layer) => {
            if (!layer || typeof layer.redraw !== 'function' || !layer._url) {
                return;
            }
            const opts = layer.options || {};
            if (opts.crossOrigin === 'anonymous' || opts.crossOrigin === true) {
                return;
            }
            if (isSameOriginTileUrl(layer._url)) {
                return;
            }
            const prev = opts.crossOrigin;
            opts.crossOrigin = 'anonymous';
            try {
                layer.redraw();
            } catch (e) {
                /* ignore */
            }
            restores.push(() => {
                opts.crossOrigin = prev;
            });
        });
        return () => {
            restores.forEach((fn) => {
                try {
                    fn();
                } catch (e) {
                    /* ignore */
                }
            });
        };
    }

    function collectBoundsFromGeoJson(geojson) {
        const bounds = L.latLngBounds([]);
        if (!geojson) {
            return bounds;
        }
        try {
            const tmp = L.geoJSON(geojson);
            const b = tmp.getBounds();
            if (b && b.isValid && b.isValid()) {
                bounds.extend(b);
            }
        } catch (e) {
            /* ignore */
        }
        return bounds;
    }

    /* Hide groups and apply layers to the live map; return a function that restores state. */
    function prepareMapForPdfCapture(leafletMap, options) {
        const {
            mapLayers = {},
            renderMapLayers,
            hiddenGroups = [],
            beforeRender,
            selectedStyle = PDF_MAP_SELECTED_STYLE,
            targetWidthPx = PDF_MAP_TARGET_WIDTH_PX,
            targetHeightPx = PDF_MAP_TARGET_HEIGHT_PX,
        } = options || {};

        const restorations = [];

        if (typeof beforeRender === 'function') {
            try {
                beforeRender();
            } catch (e) {
                /* ignore */
            }
        }

        hiddenGroups.forEach((group) => {
            if (group && leafletMap.hasLayer(group)) {
                leafletMap.removeLayer(group);
                restorations.push(() => group.addTo(leafletMap));
            }
        });

        const mapDiv = leafletMap.getContainer();
        const prevInlineStyles = {
            width: mapDiv.style.width,
            height: mapDiv.style.height,
            minHeight: mapDiv.style.minHeight,
            maxWidth: mapDiv.style.maxWidth,
            maxHeight: mapDiv.style.maxHeight,
        };
        mapDiv.style.width = targetWidthPx + 'px';
        mapDiv.style.height = targetHeightPx + 'px';
        mapDiv.style.minHeight = targetHeightPx + 'px';
        mapDiv.style.maxWidth = 'none';
        mapDiv.style.maxHeight = 'none';
        try {
            leafletMap.invalidateSize(false);
        } catch (e) {
            /* ignore */
        }
        restorations.push(() => {
            mapDiv.style.width = prevInlineStyles.width;
            mapDiv.style.height = prevInlineStyles.height;
            mapDiv.style.minHeight = prevInlineStyles.minHeight;
            mapDiv.style.maxWidth = prevInlineStyles.maxWidth;
            mapDiv.style.maxHeight = prevInlineStyles.maxHeight;
            try {
                leafletMap.invalidateSize(false);
            } catch (e) {
                /* ignore */
            }
        });

        const selectedGeo = mapLayers.selected;
        if (selectedGeo) {
            const pdfSelectedGroup = L.featureGroup().addTo(leafletMap);
            try {
                L.geoJSON(selectedGeo, {style: selectedStyle}).addTo(pdfSelectedGroup);
            } catch (e) {
                /* ignore */
            }
            restorations.push(() => {
                if (leafletMap.hasLayer(pdfSelectedGroup)) {
                    leafletMap.removeLayer(pdfSelectedGroup);
                }
                pdfSelectedGroup.clearLayers();
            });
        }

        if (typeof renderMapLayers === 'function') {
            try {
                renderMapLayers(mapLayers);
            } catch (e) {
                /* ignore */
            }
        }

        const restoreCors = ensureTileLayerCors(leafletMap);
        restorations.push(restoreCors);

        /* Центрируем на выбранном объекте, padding ≤ 50% размеров объекта (pad(0.5)).
           Соседи попадают в кадр только если лежат внутри этой области.
           Если selected недоступен — fallback на union всех слоёв. */
        let targetBounds = null;
        const selBounds = collectBoundsFromGeoJson(mapLayers.selected);
        if (selBounds && selBounds.isValid && selBounds.isValid()) {
            try {
                targetBounds = selBounds.pad(0.5);
            } catch (e) {
                targetBounds = selBounds;
            }
        } else {
            const unionBounds = L.latLngBounds([]);
            [mapLayers.adjacentDt, mapLayers.odh, mapLayers.ozn].forEach((geo) => {
                const b = collectBoundsFromGeoJson(geo);
                if (b && b.isValid && b.isValid()) {
                    unionBounds.extend(b);
                }
            });
            if (unionBounds.isValid && unionBounds.isValid()) {
                targetBounds = unionBounds;
            }
        }

        if (targetBounds) {
            try {
                leafletMap.invalidateSize(false);
                leafletMap.fitBounds(targetBounds, {padding: [0, 0], maxZoom: 22, animate: false});
            } catch (e) {
                /* ignore */
            }
        }

        return function restoreMapAfterPdfCapture() {
            for (let i = restorations.length - 1; i >= 0; i -= 1) {
                try {
                    restorations[i]();
                } catch (e) {
                    /* ignore */
                }
            }
        };
    }

    /* Snapshot the visible Leaflet map container into a PNG canvas. */
    async function captureLeafletMapPngCanvas(leafletMap, hooks) {
        const {
            beforeCapture,
            afterCapture,
        } = hooks || {};

        const mapDiv = leafletMap.getContainer();
        const restoreCallbacks = [];

        if (typeof beforeCapture === 'function') {
            try {
                const r = beforeCapture();
                if (typeof r === 'function') {
                    restoreCallbacks.push(r);
                }
            } catch (e) {
                /* ignore */
            }
        }

        mapDiv.classList.add('pass-viewer-pdf-capture');
        const controls = mapDiv.querySelector('.leaflet-control-container');
        const prevCtrl = controls ? controls.style.display : '';
        if (controls) {
            controls.style.display = 'none';
        }
        const dragWas = leafletMap.dragging && leafletMap.dragging.enabled();
        if (dragWas) {
            leafletMap.dragging.disable();
        }
        const wheelWas = leafletMap.scrollWheelZoom && leafletMap.scrollWheelZoom.enabled();
        if (wheelWas) {
            leafletMap.scrollWheelZoom.disable();
        }

        let canvas;
        try {
            leafletMap.invalidateSize(false);
            mapDiv.scrollTop = 0;
            mapDiv.scrollLeft = 0;
            await waitForVisibleTilesLoaded(mapDiv, 3200);
            await new Promise((r) => setTimeout(r, 80));
            leafletRedrawAllVectorLayers(leafletMap);
            await new Promise((r) =>
                requestAnimationFrame(() => requestAnimationFrame(() => setTimeout(r, 40)))
            );
            const w = mapDiv.clientWidth;
            const h = mapDiv.clientHeight;
            canvas = await html2canvas(mapDiv, {
                useCORS: true,
                allowTaint: false,
                scale: 1,
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
        } finally {
            mapDiv.classList.remove('pass-viewer-pdf-capture');
            if (controls) {
                controls.style.display = prevCtrl;
            }
            if (dragWas) {
                leafletMap.dragging.enable();
            }
            if (wheelWas) {
                leafletMap.scrollWheelZoom.enable();
            }
            restoreCallbacks.forEach((fn) => {
                try {
                    fn();
                } catch (e) {
                    /* ignore */
                }
            });
            if (typeof afterCapture === 'function') {
                try {
                    afterCapture();
                } catch (e) {
                    /* ignore */
                }
            }
        }
        return canvas;
    }

    function drawCanvasContainOnCurrentPage(pdf, canvas, marginMm) {
        const pageW = pdf.internal.pageSize.getWidth();
        const pageH = pdf.internal.pageSize.getHeight();
        const innerW = pageW - 2 * marginMm;
        const innerH = pageH - 2 * marginMm;
        const imgRatio = canvas.width / canvas.height;
        const boxRatio = innerW / innerH;
        let drawW;
        let drawH;
        let offX;
        let offY;
        if (imgRatio > boxRatio) {
            drawW = innerW;
            drawH = drawW / imgRatio;
            offX = marginMm;
            offY = marginMm + (innerH - drawH) / 2;
        } else {
            drawH = innerH;
            drawW = drawH * imgRatio;
            offX = marginMm + (innerW - drawW) / 2;
            offY = marginMm;
        }
        pdf.addImage(canvas.toDataURL('image/png', 0.93), 'PNG', offX, offY, drawW, drawH);
    }

    function addMapLandscapePage(pdf, canvas) {
        pdf.addPage('a4', 'l');
        drawCanvasContainOnCurrentPage(pdf, canvas, 5);
    }

    async function buildAndSavePdf(options) {
        const {objectInfo, features, buildIntersectionHtml, fileName, mapCanvas} = options;

        const initialOrientation = mapCanvas ? 'l' : 'p';
        const pdf = new global.jspdf.jsPDF({
            unit: 'mm',
            format: 'a4',
            orientation: initialOrientation,
        });
        if (mapCanvas) {
            drawCanvasContainOnCurrentPage(pdf, mapCanvas, 5);
            pdf.addPage('a4', 'p');
        }
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
        prepareMapForPdfCapture,
        captureLeafletMapPngCanvas,
        addMapLandscapePage,
    };
})(typeof window !== 'undefined' ? window : global);

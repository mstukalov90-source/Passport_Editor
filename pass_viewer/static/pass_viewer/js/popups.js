(function (global) {
    'use strict';
    const PassViewer = (global.PassViewer = global.PassViewer || {});

    PassViewer.pickPopupProperty = function pickPopupProperty(props, ...keys) {
                if (!props) {
                    return '';
                }
                for (let i = 0; i < keys.length; i += 1) {
                    const k = keys[i];
                    if (Object.prototype.hasOwnProperty.call(props, k) && props[k] != null && String(props[k]).trim() !== '') {
                        return props[k];
                    }
                }
                return '';
            }

    PassViewer.formatPopupDateToDay = function formatPopupDateToDay(value) {
                if (value == null || value === '') {
                    return '';
                }
                const s = String(value).trim();
                if (!s || ['null', 'none', '-'].includes(s.toLowerCase())) {
                    return '';
                }
                const ymd = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
                if (ymd) {
                    return PassViewer.escapeHtml(ymd[3] + '.' + ymd[2] + '.' + ymd[1]);
                }
                const d = new Date(s);
                if (!Number.isFinite(d.getTime())) {
                    return PassViewer.escapeHtml(s);
                }
                const y = d.getFullYear();
                const mo = String(d.getMonth() + 1).padStart(2, '0');
                const day = String(d.getDate()).padStart(2, '0');
                return PassViewer.escapeHtml(day + '.' + mo + '.' + y);
            }

    PassViewer.buildPopupMetaFieldsHtml = function buildPopupMetaFieldsHtml(properties) {
                const props = properties || {};
                const startRaw = PassViewer.pickPopupProperty(props, 'startdate', 'StartDate');
                const surveyRaw = PassViewer.pickPopupProperty(props, 'datesurvey', 'DateSurvey');
                const createRaw = PassViewer.pickPopupProperty(props, 'createtype', 'CreateType');
                const startDis = PassViewer.formatPopupDateToDay(startRaw);
                const surveyDis = PassViewer.formatPopupDateToDay(surveyRaw);
                const createTxt = String(createRaw == null ? '' : createRaw).trim();
                const createDis =
                    createTxt && !['null', 'none', '-'].includes(createTxt.toLowerCase())
                        ? PassViewer.escapeHtml(createTxt)
                        : '—';
                return (
                    '<div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid #e5e7eb;">' +
                    '<div style="margin-top: 4px;"><strong>Дата утверждения:</strong> ' +
                    (startDis || '—') +
                    '</div>' +
                    '<div style="margin-top: 4px;"><strong>Дата полевого обследования:</strong> ' +
                    (surveyDis || '—') +
                    '</div>' +
                    '<div style="margin-top: 4px;"><strong>Тип создания:</strong> ' +
                    createDis +
                    '</div>' +
                    '</div>'
                );
            }

    PassViewer.calculateGeometryAreaSqMeters = function calculateGeometryAreaSqMeters(geometry) {
                if (!geometry || !L?.GeometryUtil?.geodesicArea) {
                    return null;
                }
                const ringArea = (ring) => {
                    if (!Array.isArray(ring) || ring.length < 3) {
                        return 0;
                    }
                    const latLngs = ring.map((coord) => L.latLng(coord[1], coord[0]));
                    return Math.abs(L.GeometryUtil.geodesicArea(latLngs));
                };
                const polygonArea = (coordinates) => {
                    if (!Array.isArray(coordinates) || !coordinates.length) {
                        return 0;
                    }
                    const outer = ringArea(coordinates[0]);
                    const holes = coordinates.slice(1).reduce((sum, hole) => sum + ringArea(hole), 0);
                    return Math.max(0, outer - holes);
                };
                if (geometry.type === 'Polygon') {
                    return polygonArea(geometry.coordinates);
                }
                if (geometry.type === 'MultiPolygon') {
                    return (geometry.coordinates || []).reduce((sum, polygonCoords) => sum + polygonArea(polygonCoords), 0);
                }
                if (geometry.type === 'GeometryCollection') {
                    return (geometry.geometries || []).reduce((sum, child) => sum + (PassViewer.calculateGeometryAreaSqMeters(child) || 0), 0);
                }
                return null;
            }

    PassViewer.buildObjectPopup = function buildObjectPopup(properties, fallbackRootid = '-', fallbackName = '-') {
                const rootid = properties?.rootid ?? fallbackRootid;
                const name = properties?.name ?? fallbackName;
                const requestId = properties?.request_id ?? '-';
                const ownerLegalPersonId = properties?.owner_legal_person_id ?? '-';
                const ownerLegalPersonName = properties?.owner_legal_person_name ?? '-';
                const customerLegalPersonId = properties?.customer_legal_person_id ?? '-';
                const departmentLegalPersonId = properties?.department_legal_person_id ?? '-';
                const customerLegalPersonName = properties?.customer_legal_person_name ?? '-';
                const departmentLegalPersonName = properties?.department_legal_person_name ?? '-';
                const rootidText = String(rootid ?? '').trim().toLowerCase();
                const requestIdText = String(requestId ?? '').trim().toLowerCase();
                const isMissingRootid = !rootidText || rootidText === 'null' || rootidText === 'none' || rootidText === '-';
                const hasRequestId = !!requestIdText && requestIdText !== 'null' && requestIdText !== 'none' && requestIdText !== '-';
                const ownerText = String(ownerLegalPersonId ?? '').trim();
                const customerText = String(customerLegalPersonId ?? '').trim();
                const departmentText = String(departmentLegalPersonId ?? '').trim();
                const ownerNameText = String(ownerLegalPersonName ?? '').trim();
                const customerNameText = String(customerLegalPersonName ?? '').trim();
                const departmentNameText = String(departmentLegalPersonName ?? '').trim();
                const hasOwner = !!ownerText && !['null', 'none', '-'].includes(ownerText.toLowerCase());
                const hasCustomer = !!customerText && !['null', 'none', '-'].includes(customerText.toLowerCase());
                const hasDepartment = !!departmentText && !['null', 'none', '-'].includes(departmentText.toLowerCase());
                const hasOwnerName = !!ownerNameText && !['null', 'none', '-'].includes(ownerNameText.toLowerCase());
                const hasCustomerName = !!customerNameText && !['null', 'none', '-'].includes(customerNameText.toLowerCase());
                const hasDepartmentName = !!departmentNameText && !['null', 'none', '-'].includes(departmentNameText.toLowerCase());
                const ownerDisplay = hasOwnerName
                    ? String(ownerLegalPersonName || '-')
                    : String(ownerLegalPersonId || '-');
                const customerDisplay = hasCustomerName
                    ? String(customerLegalPersonName || '-')
                    : String(customerLegalPersonId || '-');
                const departmentDisplay = hasDepartmentName
                    ? String(departmentLegalPersonName || '-')
                    : String(departmentLegalPersonId || '-');
                const ownerLines =
                    ((hasOwner || hasCustomer)
                        ? ('<div style="margin-top: 6px;"><strong>Балансодержатель:</strong> ' + PassViewer.escapeHtml(hasOwner ? ownerDisplay : customerDisplay) + '</div>')
                        : '') +
                    (hasDepartment ? ('<div style="margin-top: 6px;"><strong>Отраслевой ОИВ:</strong> ' + PassViewer.escapeHtml(departmentDisplay) + '</div>') : '');
                if (isMissingRootid && hasRequestId) {
                    return (
                        '<div style="min-width: 220px;">' +
                        '<div><strong>ДТ</strong></div>' +
                        '<div><strong>№ Заявки:</strong> ' + PassViewer.escapeHtml(requestId || '-') + '</div>' +
                        '<div style="margin-top: 6px;"><strong>Название:</strong> ' + PassViewer.escapeHtml(name || '-') + '</div>' +
                        ownerLines +
                        PassViewer.buildPopupMetaFieldsHtml(properties) +
                        '</div>'
                    );
                }
                return (
                    '<div style="min-width: 220px;">' +
                    '<div><strong>ДТ</strong></div>' +
                    '<div><strong>№ Паспорта:</strong> ' + PassViewer.escapeHtml(rootid || '-') + '</div>' +
                    '<div style="margin-top: 6px;"><strong>Название:</strong> ' + PassViewer.escapeHtml(name || '-') + '</div>' +
                    ownerLines +
                    PassViewer.buildPopupMetaFieldsHtml(properties) +
                    '</div>'
                );
            }

    PassViewer.buildPdfIntersectionPopupHtml = function buildPdfIntersectionPopupHtml(properties) {
                const src = String(properties?.source ?? '').trim();
                if (src === 'ДГИ') {
                    const descr = properties?.descr ?? '-';
                    const address = properties?.address ?? '-';
                    const vri = properties?.vri ?? '-';
                    const sobstvRr = properties?.sobstv_rr ?? '-';
                    const descrText = String(descr ?? '').trim();
                    const addressText = String(address ?? '').trim();
                    const vriText = String(vri ?? '').trim();
                    const sobstvRrText = String(sobstvRr ?? '').trim();
                    return (
                        '<div style="min-width: 220px;">' +
                        '<div><strong>ДГИ</strong></div>' +
                        (!descrText || ['null', 'none', '-'].includes(descrText.toLowerCase())
                            ? ''
                            : '<div style="margin-top: 6px;"><strong>Кадастровый номер:</strong> ' + PassViewer.escapeHtml(descr) + '</div>') +
                        (!addressText || ['null', 'none', '-'].includes(addressText.toLowerCase())
                            ? ''
                            : '<div style="margin-top: 6px;"><strong>Адрес:</strong> ' + PassViewer.escapeHtml(address) + '</div>') +
                        (!vriText || ['null', 'none', '-'].includes(vriText.toLowerCase())
                            ? ''
                            : '<div style="margin-top: 6px;"><strong>Назначение:</strong> ' + PassViewer.escapeHtml(vri) + '</div>') +
                        (!sobstvRrText || ['null', 'none', '-'].includes(sobstvRrText.toLowerCase())
                            ? ''
                            : '<div style="margin-top: 6px;"><strong>Собственник:</strong> ' + PassViewer.escapeHtml(sobstvRr) + '</div>') +
                        '</div>'
                    );
                }
                if (src === 'ОДХ' || src === 'ОЗН') {
                    const rootid = properties?.rootid ?? '-';
                    const name = properties?.name ?? '-';
                    const customerLegalPersonId = properties?.customer_legal_person_id ?? '-';
                    const departmentLegalPersonId = properties?.department_legal_person_id ?? '-';
                    const ownerLegalPersonId = properties?.owner_legal_person_id ?? '-';
                    const customerLegalPersonName = properties?.customer_legal_person_name ?? '-';
                    const departmentLegalPersonName = properties?.department_legal_person_name ?? '-';
                    const ownerLegalPersonName = properties?.owner_legal_person_name ?? '-';
                    const customerText = String(customerLegalPersonId ?? '').trim();
                    const departmentText = String(departmentLegalPersonId ?? '').trim();
                    const ownerText = String(ownerLegalPersonId ?? '').trim();
                    const customerNameText = String(customerLegalPersonName ?? '').trim();
                    const departmentNameText = String(departmentLegalPersonName ?? '').trim();
                    const ownerNameText = String(ownerLegalPersonName ?? '').trim();
                    const rootidText = String(rootid ?? '').trim();
                    const nameText = String(name ?? '').trim();
                    const hasCustomer = !!customerText && !['null', 'none', '-'].includes(customerText.toLowerCase());
                    const hasDepartment = !!departmentText && !['null', 'none', '-'].includes(departmentText.toLowerCase());
                    const hasOwner = !!ownerText && !['null', 'none', '-'].includes(ownerText.toLowerCase());
                    const hasCustomerName =
                        !!customerNameText && !['null', 'none', '-'].includes(customerNameText.toLowerCase());
                    const hasDepartmentName =
                        !!departmentNameText && !['null', 'none', '-'].includes(departmentNameText.toLowerCase());
                    const hasOwnerName =
                        !!ownerNameText && !['null', 'none', '-'].includes(ownerNameText.toLowerCase());
                    const customerDisplay = hasCustomerName
                        ? String(customerLegalPersonName || '-')
                        : String(customerLegalPersonId || '-');
                    const departmentDisplay = hasDepartmentName
                        ? String(departmentLegalPersonName || '-')
                        : String(departmentLegalPersonId || '-');
                    const ownerDisplay = hasOwnerName
                        ? String(ownerLegalPersonName || '-')
                        : String(ownerLegalPersonId || '-');
                    return (
                        '<div style="min-width: 220px;">' +
                        '<div><strong>' + (src === 'ОЗН' ? 'ОО' : 'ОДХ') + '</strong></div>' +
                        (!rootidText || ['null', 'none', '-'].includes(rootidText.toLowerCase())
                            ? ''
                            : '<div style="margin-top: 6px;"><strong>Паспорт №:</strong> ' + PassViewer.escapeHtml(rootid) + '</div>') +
                        (!nameText || ['null', 'none', '-'].includes(nameText.toLowerCase())
                            ? ''
                            : '<div style="margin-top: 6px;"><strong>Название:</strong> ' + PassViewer.escapeHtml(name) + '</div>') +
                        ((src === 'ОЗН')
                            ? (hasOwner
                                ? '<div style="margin-top: 6px;"><strong>Балансодержатель:</strong> ' + PassViewer.escapeHtml(ownerDisplay) + '</div>'
                                : '')
                            : (hasCustomer
                                ? '<div style="margin-top: 6px;"><strong>Балансодержатель:</strong> ' + PassViewer.escapeHtml(customerDisplay) + '</div>'
                                : '')) +
                        (hasDepartment
                            ? '<div style="margin-top: 6px;"><strong>Отраслевой ОИВ:</strong> ' + PassViewer.escapeHtml(departmentDisplay) + '</div>'
                            : '') +
                        PassViewer.buildPopupMetaFieldsHtml(properties) +
                        '</div>'
                    );
                }
                return PassViewer.buildObjectPopup(properties);
            }

})(typeof window !== 'undefined' ? window : global);

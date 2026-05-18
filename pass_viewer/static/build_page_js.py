#!/usr/bin/env python3
"""
Regenerate pass_viewer page JS from templates/pass_viewer/_extracted snapshots.

After editing inline JS in templates, re-extract with:
  python3 -c "..."  # see git history or run extract step in CI

Then: python3 pass_viewer/static/build_page_js.py
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent / 'pass_viewer' / 'js'
EXTRACTED = ROOT / '_extracted'

UTIL_FUNCS = [
    'getCookie',
    'parseGeometryData',
    'normalizeGeoJson',
    'toEditableFeatureCollection',
    'mergeAdjacentDtPassportsGeoJson',
    'escapeHtml',
]
POPUP_FUNCS = [
    'pickPopupProperty',
    'formatPopupDateToDay',
    'buildPopupMetaFieldsHtml',
    'calculateGeometryAreaSqMeters',
    'buildObjectPopup',
    'buildPdfIntersectionPopupHtml',
]

PAGE_MAP = {
    'add_object': 'add-object.js',
    'main': 'main.js',
    'home': 'home.js',
    'add_recap': 'add-recap.js',
    'split_object': 'split-object.js',
}


def remove_function_block(src: str, name: str) -> str:
    pat = re.compile(rf'function\s+{re.escape(name)}\s*\(', re.M)
    m = pat.search(src)
    if not m:
        return src
    i = m.start()
    j = src.find('{', m.end())
    depth = 1
    j += 1
    while j < len(src) and depth:
        if src[j] == '{':
            depth += 1
        elif src[j] == '}':
            depth -= 1
        j += 1
    while j < len(src) and src[j] in ' \t\r\n':
        if src[j] == '\n':
            j += 1
            break
        j += 1
    return src[:i] + src[j:]


def strip_draw_i18n(src: str) -> str:
    pat = re.compile(r'if\s*\(\s*L\s*&&\s*L\.drawLocal\s*\)', re.M)
    m = pat.search(src)
    if not m:
        return src
    i = m.start()
    j = src.find('{', m.end())
    depth = 1
    j += 1
    while j < len(src) and depth:
        if src[j] == '{':
            depth += 1
        elif src[j] == '}':
            depth -= 1
        j += 1
    while j < len(src) and src[j] in ' \t\r\n':
        if src[j] == '\n':
            j += 1
            break
        j += 1
    return src[:i] + src[j:]


def strip_shared(src: str) -> str:
    src = strip_draw_i18n(src)
    for fn in UTIL_FUNCS + POPUP_FUNCS:
        prev = None
        while prev != src:
            prev = src
            src = remove_function_block(src, fn)
    return src


REPLACEMENTS = [
    (r"'\{% url \"list_comment_points\" %\}'", 'cfg.urls.listCommentPoints'),
    (r"'\{% url \"save_comment_point\" %\}'", 'cfg.urls.saveCommentPoint'),
    (r"'\{% url \"delete_comment_point\" %\}'", 'cfg.urls.deleteCommentPoint'),
    (r'"\{% url \'check_new_object_relations\' %\}"', 'cfg.urls.checkRelations'),
    (r'"\{% url \'check_dgi_intersections\' %\}"', 'cfg.urls.checkDgi'),
    (r'"\{% url \'auto_remove_intersections\' %\}"', 'cfg.urls.autoRemove'),
    (r'"\{% url \'cut_edited_geometry\' %\}"', 'cfg.urls.cutGeometry'),
    (r'"\{% url \'save_new_object\' %\}"', 'cfg.urls.saveNewObject'),
    (r'"\{% url \'export_new_object_geometry\' %\}"', 'cfg.urls.exportGeometry'),
    (r'"\{% url \'save_recap_object\' %\}"', 'cfg.urls.saveRecap'),
    (r"'\{% url \"cancel_pending_entry\" %\}'", 'cfg.urls.cancelPending'),
    (r"'\{% url \"add_recap\" %\}'", 'cfg.urls.addRecap'),
    (r'"\{\{ selected_rootid\|default:\'\'\|escapejs \}\}"', 'cfg.selectedRootid || ""'),
    (r'"\{\{ selected_name\|default:\'\'\|escapejs \}\}"', 'cfg.selectedName || ""'),
    (r'"\{\{ selected_request_id\|default:\'\'\|escapejs \}\}"', 'cfg.selectedRequestId || ""'),
    (r'"\{\{ selected_ctid\|default:\'\'\|escapejs \}\}"', 'cfg.selectedRowCtid || ""'),
    (r'"\{\{ effective_request_id\|default:\'\'\|escapejs \}\}"', 'cfg.effectiveRequestId || ""'),
    (
        r'"\{\{ selected_customer_legal_person_id\|default:\'\'\|escapejs \}\}"',
        'cfg.selectedCustomerLegalPersonId || ""',
    ),
    (
        r'"\{\{ selected_department_legal_person_id\|default:\'\'\|escapejs \}\}"',
        'cfg.selectedDepartmentLegalPersonId || ""',
    ),
    (
        r'"\{\{ selected_customer_legal_person_name\|default:\'\'\|escapejs \}\}"',
        'cfg.selectedCustomerLegalPersonName || ""',
    ),
    (
        r'"\{\{ selected_department_legal_person_name\|default:\'\'\|escapejs \}\}"',
        'cfg.selectedDepartmentLegalPersonName || ""',
    ),
    (r'"\{\{ selected_startdate\|default:\'\'\|escapejs \}\}"', 'cfg.selectedStartdate || ""'),
    (r'"\{\{ selected_datesurvey\|default:\'\'\|escapejs \}\}"', 'cfg.selectedDatesurvey || ""'),
    (r'"\{\{ selected_createtype\|default:\'\'\|escapejs \}\}"', 'cfg.selectedCreatetype || ""'),
    (r'"\{\{ selected_source_label\|default:\'ДТ\'\|escapejs \}\}"', 'cfg.selectedSourceLabel || "ДТ"'),
    (r'"\{\{ request_id\|default:\'\'\|escapejs \}\}"', 'cfg.requestId || ""'),
    (r'"\{\{ name\|default:\'\'\|escapejs \}\}"', 'cfg.objectName || ""'),
    (r"'\{\{ initial_recap_id\|default:\"\"\|escapejs \}\}'", 'cfg.initialRecapId || ""'),
]

HEADER = """(function () {
    'use strict';
    const PV = window.PassViewer;
    PV.localizeLeafletDraw();
    const cfg = PV.getPageConfig();
    const getCookie = PV.getCookie.bind(PV);
    const parseGeometryData = PV.parseGeometryData.bind(PV);
    const normalizeGeoJson = PV.normalizeGeoJson.bind(PV);
    const toEditableFeatureCollection = PV.toEditableFeatureCollection.bind(PV);
    const mergeAdjacentDtPassportsGeoJson = PV.mergeAdjacentDtPassportsGeoJson.bind(PV);
    const escapeHtml = PV.escapeHtml.bind(PV);
    const pickPopupProperty = PV.pickPopupProperty.bind(PV);
    const formatPopupDateToDay = PV.formatPopupDateToDay.bind(PV);
    const buildPopupMetaFieldsHtml = PV.buildPopupMetaFieldsHtml.bind(PV);
    const calculateGeometryAreaSqMeters = PV.calculateGeometryAreaSqMeters.bind(PV);
    const buildObjectPopup = PV.buildObjectPopup.bind(PV);
    const buildPdfIntersectionPopupHtml = PV.buildPdfIntersectionPopupHtml.bind(PV);

"""

FOOTER = '\n})();\n'


def main() -> None:
    if not EXTRACTED.is_dir():
        raise SystemExit(f'Missing {EXTRACTED}; run extraction from templates first.')

    for src_name, out_name in PAGE_MAP.items():
        raw = (EXTRACTED / f'{src_name}.js').read_text(encoding='utf-8')
        body = strip_shared(raw)
        for pat, repl in REPLACEMENTS:
            body = re.sub(pat, repl, body)
        lines = body.splitlines()
        if lines and lines[0].startswith('        '):
            lines = [ln[8:] if ln.startswith('        ') else ln for ln in lines]
        body = '\n'.join(lines).strip() + '\n'
        for fn in UTIL_FUNCS + POPUP_FUNCS:
            body = remove_function_block(body, fn)
        out = HEADER + body + FOOTER
        (ROOT / out_name).write_text(out, encoding='utf-8')
        print(f'wrote {out_name} ({len(out.splitlines())} lines)')


if __name__ == '__main__':
    main()

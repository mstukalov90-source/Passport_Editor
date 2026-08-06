#!/usr/bin/env python3
"""
Regenerate pass_viewer page JS from _extracted snapshots.

Edit _extracted/*.js, then:
  python3 pass_viewer/static/build_page_js.py --page home
  python3 pass_viewer/static/build_page_js.py --all

Verify before commit / in CI:
  python3 pass_viewer/static/build_page_js.py --check
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent / "pass_viewer" / "js"
EXTRACTED = ROOT / "_extracted"

UTIL_FUNCS = [
    "getCookie",
    "parseGeometryData",
    "normalizeGeoJson",
    "toEditableFeatureCollection",
    "mergeAdjacentDtPassportsGeoJson",
    "filterPassportOnlyGeoJson",
    "escapeHtml",
]
POPUP_FUNCS = [
    "pickPopupProperty",
    "formatPopupDateToDay",
    "buildPopupMetaFieldsHtml",
    "calculateGeometryAreaSqMeters",
    "buildObjectPopup",
    "buildPdfIntersectionPopupHtml",
]

PAGE_MAP = {
    "add_object": "add-object.js",
    "main": "main.js",
    "home": "home.js",
    "add_recap": "add-recap.js",
    # split_object: maintained manually under pass_viewer/js/split/ (not generated from _extracted)
}

_HEADER_PREFIX = """(function () {
    'use strict';
    const PV = window.PassViewer;
    PV.localizeLeafletDraw();
    const cfg = PV.getPageConfig();
    const getCookie = PV.getCookie.bind(PV);
    const parseGeometryData = PV.parseGeometryData.bind(PV);
    const normalizeGeoJson = PV.normalizeGeoJson.bind(PV);
    const toEditableFeatureCollection = PV.toEditableFeatureCollection.bind(PV);
    const mergeAdjacentDtPassportsGeoJson = PV.mergeAdjacentDtPassportsGeoJson.bind(PV);
"""

_HEADER_SUFFIX_COMMON = """    const escapeHtml = PV.escapeHtml.bind(PV);
    const pickPopupProperty = PV.pickPopupProperty.bind(PV);
    const formatPopupDateToDay = PV.formatPopupDateToDay.bind(PV);
    const buildPopupMetaFieldsHtml = PV.buildPopupMetaFieldsHtml.bind(PV);
    const calculateGeometryAreaSqMeters = PV.calculateGeometryAreaSqMeters.bind(PV);
    const buildObjectPopup = PV.buildObjectPopup.bind(PV);
    const buildPdfIntersectionPopupHtml = PV.buildPdfIntersectionPopupHtml.bind(PV);
"""

PAGE_HEADERS: dict[str, str] = {
    "home": _HEADER_PREFIX + _HEADER_SUFFIX_COMMON + "\n",
    "main": (
        _HEADER_PREFIX
        + "    const filterPassportOnlyGeoJson = PV.filterPassportOnlyGeoJson.bind(PV);\n"
        + _HEADER_SUFFIX_COMMON
        + "    const PdfExport = PV.PdfExport;\n"
        + "    const formatAdjacentRelationsSearchStatus = PV.formatAdjacentRelationsSearchStatus.bind(PV);\n"
        + "    const parseJsonResponse = PV.parseJsonResponse.bind(PV);\n"
        + "    const mergeMapLayerPayload = PV.mergeMapLayerPayload.bind(PV);\n"
        + "    const viewOnly = !!(cfg.features && cfg.features.viewOnly);\n\n"
    ),
    "add_object": (
        _HEADER_PREFIX
        + "    const filterPassportOnlyGeoJson = PV.filterPassportOnlyGeoJson.bind(PV);\n"
        + _HEADER_SUFFIX_COMMON
        + "    const formatAdjacentRelationsSearchStatus = PV.formatAdjacentRelationsSearchStatus.bind(PV);\n"
        + "    const PdfExport = PV.PdfExport;\n\n"
    ),
    "add_recap": (
        _HEADER_PREFIX
        + _HEADER_SUFFIX_COMMON
        + "    const formatAdjacentRelationsSearchStatus = PV.formatAdjacentRelationsSearchStatus.bind(PV);\n"
        + "    const filterPassportOnlyGeoJson = PV.filterPassportOnlyGeoJson.bind(PV);\n"
        + "    const PdfExport = PV.PdfExport;\n"
        + "    const mps = PV.multipolygonSave || {};\n\n"
    ),
}

FOOTER = "\n})();\n"

# (_extracted literal, built literal) — use str.replace, not regex patterns.
LITERAL_REPLACEMENTS: list[tuple[str, str]] = [
    ("'{% url \"list_comment_points\" %}'", "cfg.urls.listCommentPoints"),
    ("'{% url \"save_comment_point\" %}'", "cfg.urls.saveCommentPoint"),
    ("'{% url \"delete_comment_point\" %}'", "cfg.urls.deleteCommentPoint"),
    ('"{% url \'check_new_object_relations\' %}"', "cfg.urls.checkRelations"),
    ('"{% url \'check_dgi_intersections\' %}"', "cfg.urls.checkDgi"),
    ('"{% url \'auto_remove_intersections\' %}"', "cfg.urls.autoRemove"),
    ('"{% url \'cut_edited_geometry\' %}"', "cfg.urls.cutGeometry"),
    ('"{% url \'save_new_object\' %}"', "cfg.urls.saveNewObject"),
    ('"{% url \'export_new_object_geometry\' %}"', "cfg.urls.exportGeometry"),
    ('"{% url \'save_recap_object\' %}"', "cfg.urls.saveRecap"),
    ("'{% url \"cancel_pending_entry\" %}'", "cfg.urls.cancelPending"),
    ("'{% url \"add_recap\" %}'", "cfg.urls.addRecap"),
    ("'{% url \"list_owned_recaps\" %}'", "cfg.urls.listOwnedRecaps"),
    ("'{% url \"export_recap_geometry\" %}'", "cfg.urls.exportRecap"),
    ("'{% url \"delete_recap_object\" %}'", "cfg.urls.deleteRecap"),
    ('"{{ selected_rootid|default:\'\'|escapejs }}"', 'cfg.selectedRootid || ""'),
    ('"{{ selected_name|default:\'\'|escapejs }}"', 'cfg.selectedName || ""'),
    ('"{{ selected_request_id|default:\'\'|escapejs }}"', 'cfg.selectedRequestId || ""'),
    ('"{{ selected_ctid|default:\'\'|escapejs }}"', 'cfg.selectedRowCtid || ""'),
    ('"{{ effective_request_id|default:\'\'|escapejs }}"', 'cfg.effectiveRequestId || ""'),
    (
        '"{{ selected_customer_legal_person_id|default:\'\'|escapejs }}"',
        'cfg.selectedCustomerLegalPersonId || ""',
    ),
    (
        '"{{ selected_department_legal_person_id|default:\'\'|escapejs }}"',
        'cfg.selectedDepartmentLegalPersonId || ""',
    ),
    (
        '"{{ selected_customer_legal_person_name|default:\'\'|escapejs }}"',
        'cfg.selectedCustomerLegalPersonName || ""',
    ),
    (
        '"{{ selected_department_legal_person_name|default:\'\'|escapejs }}"',
        'cfg.selectedDepartmentLegalPersonName || ""',
    ),
    ('"{{ selected_startdate|default:\'\'|escapejs }}"', 'cfg.selectedStartdate || ""'),
    ('"{{ selected_datesurvey|default:\'\'|escapejs }}"', 'cfg.selectedDatesurvey || ""'),
    ('"{{ selected_createtype|default:\'\'|escapejs }}"', 'cfg.selectedCreatetype || ""'),
    ('"{{ selected_source_label|default:\'ДТ\'|escapejs }}"', 'cfg.selectedSourceLabel || "ДТ"'),
    ('"{{ request_id|default:\'\'|escapejs }}"', 'cfg.requestId || ""'),
    ('"{{ name|default:\'\'|escapejs }}"', 'cfg.objectName || ""'),
    ("'{{ initial_recap_id|default:\"\"|escapejs }}'", 'cfg.initialRecapId || ""'),
    ("page: 'add_recap'", 'page: cfg.page || "add_recap"'),
]


def apply_forward_replacements(body: str) -> str:
    for src, dst in LITERAL_REPLACEMENTS:
        body = body.replace(src, dst)
    return body


def apply_reverse_replacements(body: str) -> str:
    for src, dst in reversed(LITERAL_REPLACEMENTS):
        body = body.replace(dst, src)
    return body


def remove_function_block(src: str, name: str) -> str:
    pat = re.compile(rf"function\s+{re.escape(name)}\s*\(", re.M)
    m = pat.search(src)
    if not m:
        return src
    i = m.start()
    j = src.find("{", m.end())
    depth = 1
    j += 1
    while j < len(src) and depth:
        if src[j] == "{":
            depth += 1
        elif src[j] == "}":
            depth -= 1
        j += 1
    while j < len(src) and src[j] in " \t\r\n":
        if src[j] == "\n":
            j += 1
            break
        j += 1
    return src[:i] + src[j:]


def strip_draw_i18n(src: str) -> str:
    pat = re.compile(r"if\s*\(\s*L\s*&&\s*L\.drawLocal\s*\)", re.M)
    m = pat.search(src)
    if not m:
        return src
    i = m.start()
    j = src.find("{", m.end())
    depth = 1
    j += 1
    while j < len(src) and depth:
        if src[j] == "{":
            depth += 1
        elif src[j] == "}":
            depth -= 1
        j += 1
    while j < len(src) and src[j] in " \t\r\n":
        if src[j] == "\n":
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


def build_page_content(src_name: str) -> str:
    raw = (EXTRACTED / f"{src_name}.js").read_text(encoding="utf-8")
    body = strip_shared(raw)
    body = apply_forward_replacements(body)
    lines = body.splitlines()
    if lines and lines[0].startswith("        "):
        lines = [ln[8:] if ln.startswith("        ") else ln for ln in lines]
    body = "\n".join(lines).strip() + "\n"
    for fn in UTIL_FUNCS + POPUP_FUNCS:
        body = remove_function_block(body, fn)
    header = PAGE_HEADERS[src_name]
    return header + body + FOOTER


def build_page(src_name: str, out_name: str, *, dest: Path | None = None) -> str:
    content = build_page_content(src_name)
    target = dest if dest is not None else (ROOT / out_name)
    target.write_text(content, encoding="utf-8")
    if dest is None:
        print(f"wrote {out_name} ({len(content.splitlines())} lines)")
    return content


def check_all_pages() -> list[str]:
    mismatches: list[str] = []
    for src_name, out_name in PAGE_MAP.items():
        built = build_page_content(src_name)
        committed = (ROOT / out_name).read_text(encoding="utf-8")
        if built != committed:
            mismatches.append(out_name)
    return mismatches


def build_all_pages() -> None:
    for src_name, out_name in PAGE_MAP.items():
        build_page(src_name, out_name)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Regenerate pass_viewer page JS from _extracted snapshots.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--page",
        choices=sorted(PAGE_MAP.keys()),
        help="Rebuild a single page (e.g. home).",
    )
    group.add_argument(
        "--all",
        action="store_true",
        help="Rebuild all pages from _extracted/*.js.",
    )
    group.add_argument(
        "--check",
        action="store_true",
        help="Verify committed JS matches _extracted (exit 1 on drift).",
    )
    args = parser.parse_args()

    if not EXTRACTED.is_dir():
        raise SystemExit(f"Missing {EXTRACTED}; run import_extracted_from_built.py first.")

    if args.check:
        mismatches = check_all_pages()
        if mismatches:
            print("Page JS is out of sync with _extracted/:", ", ".join(mismatches), file=sys.stderr)
            print("Run: python3 pass_viewer/static/build_page_js.py --all", file=sys.stderr)
            raise SystemExit(1)
        print("OK: all page JS files match _extracted/")
        return

    if args.page:
        build_page(args.page, PAGE_MAP[args.page])
        return

    if args.all:
        build_all_pages()
        return

    parser.print_help()
    print(
        "\nSpecify --page <name>, --all, or --check.",
        file=sys.stderr,
    )
    raise SystemExit(2)


if __name__ == "__main__":
    main()

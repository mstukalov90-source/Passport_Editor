"""Smoke tests for add_recap page bootstrap (script include + init order)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADD_RECAP_JS = ROOT / "pass_viewer/static/pass_viewer/js/add-recap.js"
ADD_RECAP_HTML = ROOT / "templates/pass_viewer/add_recap.html"
MAP_EDITOR_SCRIPTS = ROOT / "templates/pass_viewer/includes/map_editor_scripts.html"


def test_add_recap_html_uses_editor_scripts_with_dgi_gate() -> None:
    html = ADD_RECAP_HTML.read_text(encoding="utf-8")
    assert "map_editor_scripts.html" in html
    editor_scripts = MAP_EDITOR_SCRIPTS.read_text(encoding="utf-8")
    assert "dgi-export-gate.js" in editor_scripts


def test_add_recap_js_registers_buttons_before_initial_layer_render() -> None:
    source = ADD_RECAP_JS.read_text(encoding="utf-8")
    button_hook = source.index("addDossierButton.addEventListener")
    initial_render = source.index("renderRelationLayers({")
    assert button_hook < initial_render, (
        "toolbar handlers must bind before initial renderRelationLayers call"
    )


def test_add_recap_js_has_safe_geometry_parse_and_dgi_gate_guard() -> None:
    source = ADD_RECAP_JS.read_text(encoding="utf-8")
    required = [
        "parseGeometryData('selected-geometry-data')",
        "parseGeometryData('intersects-geometry-data')",
        "typeof PV.initDgiExportGateFlow === 'function'",
        "failed to render initial map layers",
    ]
    missing = [symbol for symbol in required if symbol not in source]
    assert not missing, f"add-recap.js is missing: {missing}"


def test_add_recap_js_supports_dossier_intersection_workflow() -> None:
    source = ADD_RECAP_JS.read_text(encoding="utf-8")
    required = [
        "let editToolbar = null",
        "function finishDossierPolygon",
        "function updateDossierToolbarState",
        "function getDossierGeometryForExport",
        "await checkRelations()",
        "L.Draw.Event.EDITED",
    ]
    missing = [symbol for symbol in required if symbol not in source]
    assert not missing, f"add-recap.js is missing dossier workflow: {missing}"

    build_current = source.split("function buildCurrentGeometry()", 1)[1]
    assert "return selectedGeometry" not in build_current.split("function ", 1)[0], (
        "buildCurrentGeometry must not fall back to selectedGeometry"
    )


def test_add_recap_js_auto_remove_uses_recap_page_without_selected_exclusion() -> None:
    source = ADD_RECAP_JS.read_text(encoding="utf-8")
    auto_remove_block = source.split("async function autoRemoveIntersections()", 1)[1]
    auto_remove_block = auto_remove_block.split("autoRemoveIntersectionsButton.addEventListener", 1)[0]
    assert 'page: cfg.page || "add_recap"' in auto_remove_block
    assert "selected_geometry:" not in auto_remove_block
    assert "selected_request_id:" not in auto_remove_block


def test_add_recap_js_supports_pdf_export_for_dossier() -> None:
    source = ADD_RECAP_JS.read_text(encoding="utf-8")
    required = [
        "const PdfExport = PV.PdfExport",
        'data-export-pdf-link="1"',
        "async function runPdfExportDownload",
        "function bindPdfExportLink",
        "async function fetchPdfExportData",
        "async function captureMapCanvasForPdf",
        "lastPdfExportContext",
    ]
    missing = [symbol for symbol in required if symbol not in source]
    assert not missing, f"add-recap.js is missing PDF export: {missing}"

    save_block = source.split("async function saveDossier()", 1)[1]
    save_block = save_block.split("saveModalCancel.addEventListener", 1)[0]
    assert 'data-export-pdf-link="1"' in save_block
    assert "bindPdfExportLink()" in save_block
    assert "passportNo: selectedRootid" in save_block

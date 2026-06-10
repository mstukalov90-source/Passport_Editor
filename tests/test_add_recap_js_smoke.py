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

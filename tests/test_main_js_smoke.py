"""Smoke tests for main.js deferred layers and auto-remove visibility."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN_JS = ROOT / "pass_viewer/static/pass_viewer/js/main.js"

REQUIRED_SYMBOLS = [
    "const parseJsonResponse = PV.parseJsonResponse.bind(PV)",
    "const mergeMapLayerPayload = PV.mergeMapLayerPayload.bind(PV)",
    "autoRemoveNoLayersEl",
    "autoRemoveNoLayersMessage",
    "mergeMapLayerPayload(mergedLayers, partial)",
    "PV.attachBasemapControl(map)",
    "cfg.urls?.loadMapLayer",
    "mergeAdjacentDtPassportsGeoJson",
    "filterPassportOnlyGeoJson",
]


def test_main_js_contains_required_symbols() -> None:
    source = MAIN_JS.read_text(encoding="utf-8")
    missing = [symbol for symbol in REQUIRED_SYMBOLS if symbol not in source]
    assert not missing, f"main.js is missing required symbols: {missing}"

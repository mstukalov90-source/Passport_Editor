"""Smoke tests for restored home.js functionality after fed06e5 refactor."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME_JS = ROOT / "pass_viewer/static/pass_viewer/js/home.js"

REQUIRED_SYMBOLS = [
    "function getMergeCheckboxPayload",
    "merge_item_object_key",
    "mergeTargetTopRadio",
    "function initRequestStatusFilter",
    "function openUserGuideModal",
    "function closeUserGuideModal",
    "function applyHomeWorkflowOdsSyncNotifications",
    "function getHomeOdsSyncStorageKey",
    "ResizeObserver",
    "source === 'ТОП' || source === 'TOP'",
    "sourceLabel === 'ТОП' || sourceLabel === 'TOP'",
    "PV.attachBasemapControl",
    "function openOwnedRecapsModal",
    "cfg.urls.listOwnedRecaps",
    "cfg.urls.exportRecap",
    "cfg.urls.deleteRecap",
    ".owned-recaps-open-btn",
]


def test_home_js_contains_restored_symbols() -> None:
    source = HOME_JS.read_text(encoding="utf-8")
    missing = [symbol for symbol in REQUIRED_SYMBOLS if symbol not in source]
    assert not missing, f"home.js is missing restored symbols: {missing}"

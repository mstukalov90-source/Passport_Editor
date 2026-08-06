"""Smoke tests for restored home.js functionality after fed06e5 refactor."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME_JS = ROOT / "pass_viewer/static/pass_viewer/js/home.js"
HOME_HTML = ROOT / "templates/pass_viewer/home.html"

REQUIRED_SYMBOLS = [
    "function getMergeCheckboxPayload",
    "merge_item_object_key",
    "mergeTargetTopRadio",
    "function initRequestStatusFilter",
    "function openUserGuideModal",
    "function closeUserGuideModal",
    "function applyHomeWorkflowOdsSyncNotifications",
    "function getHomeOdsSyncStorageKey",
    "function getHomeOdsRequestIdsStorageKey",
    "function getHomeNotificationsSeenStorageKey",
    "home_notifications_seen:",
    "function buildOdsNewMessages",
    "function markNotificationSeen",
    "home-notification-events",
    "dataset.username",
    "ResizeObserver",
    "source === 'ТОП' || source === 'TOP'",
    "sourceLabel === 'ТОП' || sourceLabel === 'TOP'",
    "PV.attachBasemapControl",
    "function openOwnedRecapsModal",
    "cfg.urls.listOwnedRecaps",
    "cfg.urls.exportRecap",
    "cfg.urls.deleteRecap",
    "cfg.urls.listDgiIntersections",
    "function loadDgiIntersectionsTable",
    "function openDgiIntersectionDetail",
    "dgi-intersections-table-btn",
    "check-dgi-view-object-btn",
    "setCheckDgiViewObjectProps",
    ".owned-recaps-open-btn",
]


def test_home_js_contains_restored_symbols() -> None:
    source = HOME_JS.read_text(encoding="utf-8")
    missing = [symbol for symbol in REQUIRED_SYMBOLS if symbol not in source]
    assert not missing, f"home.js is missing restored symbols: {missing}"


def test_home_html_ods_recap_buttons_require_geometry() -> None:
    html = HOME_HTML.read_text(encoding="utf-8")
    idx = html.find("item.ods_uses_gis_geometry")
    assert idx != -1
    snippet = html[idx : idx + 2500]
    assert "add-recap-entry-btn" in snippet
    assert "owned-recaps-open-btn" in snippet

"""Smoke tests for restored home.js functionality after fed06e5 refactor."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME_JS = ROOT / "pass_viewer/static/pass_viewer/js/home.js"
NOTIFICATIONS_JS = ROOT / "pass_viewer/static/pass_viewer/js/notifications.js"
OWNED_HOME_LISTS_HTML = ROOT / "templates/pass_viewer/includes/owned_home_lists.html"

REQUIRED_SYMBOLS = [
    "function getMergeCheckboxPayload",
    "merge_item_object_key",
    "mergeTargetTopRadio",
    "function initRequestStatusFilter",
    "function openUserGuideModal",
    "function closeUserGuideModal",
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
    "function bindOwnedCheckDgiButton",
    "function bindOwnedAsuOdsButton",
    "function bindOwnedListIconActions",
    "focus({ preventScroll: true })",
    "function kindFilterSkipsOdsRequestModal",
    "!kinds.has('actualization') && !kinds.has('drawn')",
    "closeOwnedListsModal();",
    "openEntryRequestModal('add-object')",
    "<strong>ID паспорта:</strong>",
    "<strong>Площадь:</strong>",
    "<strong>Статус:</strong>",
    "owned-popup-actions",
    "owned-list-icon-btn",
    "owned-asu-ods-btn",
    "cfg.urls.resolveAsuOdsUrl",
    'title="Проверка пересечений"',
    "<span>Просмотр объекта</span>",
    "<span>Проверка пересечений</span>",
    "<span>АСУ ОДС</span>",
    "function openDgiIntersectionDetail",
    "dgi-intersections-table-btn",
    "check-dgi-view-object-btn",
    "setCheckDgiViewObjectProps",
    ".owned-recaps-open-btn",
    "function syncViewObjectHeaderActions",
    "function submitViewObjectOpen",
    "owned-view-object-split-btn",
    "owned-view-object-aktualize-btn",
]

NOTIFICATIONS_SYMBOLS = [
    "function applyHomeWorkflowOdsSyncNotifications",
    "function getHomeOdsSyncStorageKey",
    "function getHomeOdsRequestIdsStorageKey",
    "function getHomeNotificationsSeenStorageKey",
    "home_notifications_seen:",
    "function buildOdsNewMessages",
    "function markNotificationSeen",
    "home-notification-events",
    "approval-notifications-feed",
]


def test_home_js_contains_restored_symbols() -> None:
    source = HOME_JS.read_text(encoding="utf-8")
    missing = [symbol for symbol in REQUIRED_SYMBOLS if symbol not in source]
    assert not missing, f"home.js is missing restored symbols: {missing}"


def test_home_popup_actions_order_asu_dgi_view() -> None:
    source = HOME_JS.read_text(encoding="utf-8")
    start = source.find('popupHtml += \'<div class="owned-popup-actions">\'')
    assert start != -1
    snippet = source[start : start + 1800]
    asu = snippet.find("owned-asu-ods-btn")
    dgi = snippet.find("owned-check-dgi-btn")
    view = snippet.find("owned-view-object-btn")
    assert asu != -1 and dgi != -1 and view != -1
    assert asu < dgi < view


def test_home_js_closes_lists_modal_for_add_object_and_merge() -> None:
    source = HOME_JS.read_text(encoding="utf-8")
    add_idx = source.find("addObjectEntryBtn.addEventListener")
    assert add_idx != -1
    add_snip = source[add_idx : add_idx + 350]
    assert "closeOwnedListsModal()" in add_snip
    assert "openEntryRequestModal('add-object')" in add_snip
    merge_idx = source.find("mergePassportsBtn.addEventListener")
    assert merge_idx != -1
    merge_snip = source[merge_idx : merge_idx + 500]
    assert "closeOwnedListsModal()" in merge_snip
    assert "setOwnedListTab('passports')" in merge_snip
    assert "owned-lists-home-slot" in source
    assert "home--merge-passports" in source


def test_notifications_js_contains_feed_symbols() -> None:
    source = NOTIFICATIONS_JS.read_text(encoding="utf-8")
    missing = [symbol for symbol in NOTIFICATIONS_SYMBOLS if symbol not in source]
    assert not missing, f"notifications.js is missing symbols: {missing}"


def test_home_html_ods_recap_buttons_require_geometry() -> None:
    html = OWNED_HOME_LISTS_HTML.read_text(encoding="utf-8")
    idx = html.find("item.ods_uses_gis_geometry")
    assert idx != -1
    snippet = html[idx : idx + 2500]
    assert "add-recap-entry-btn" in snippet
    assert "owned-recaps-open-btn" in snippet

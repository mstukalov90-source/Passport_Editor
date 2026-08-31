from pathlib import Path

from django.contrib.auth.models import AnonymousUser
from django.template.loader import render_to_string
from django.test import RequestFactory
from django.urls import reverse

ROOT = Path(__file__).resolve().parents[1]


def test_redesign_routes_and_templates_are_wired() -> None:
    assert reverse("personal_account") == "/personal/"
    assert reverse("statistics") == "/statistics/"
    base = (ROOT / "templates/base.html").read_text(encoding="utf-8")
    header = (ROOT / "templates/includes/site_header.html").read_text(encoding="utf-8")
    personal = (ROOT / "templates/pass_viewer/personal_account.html").read_text(encoding="utf-8")
    statistics = (ROOT / "templates/pass_viewer/statistics.html").read_text(encoding="utf-8")
    assert "includes/site_header.html" in base
    assert "site-header.js" in base
    assert "notifications.js" in base
    assert "approval_notifications_modal.html" in base
    assert "approval-notifications-btn" in header
    assert "site-header__icon-label" in header
    assert ">Уведомления</span>" in header
    assert 'href="{% url \'home\' %}" aria-label="Уведомления"' not in header
    assert 'data-header-open-list="requests"' in header
    assert 'data-header-open-list="approvals"' in header
    assert "owned_lists_partial" in header
    assert "open_list=requests" in header
    assert "open_list=approvals" in header
    assert "{% url 'home' %}?open_list" not in header
    assert "{% url 'add_object' %}" not in header
    assert "approval:landing" not in header
    assert "add_object' or route_name == 'main' or route_name == 'add_recap'" in header
    assert "personal_account' or route_name == 'home' %} is-active" in header
    assert "Статистика" in header
    assert "{% url 'statistics' %}" in header
    assert "split_object" not in header
    assert "personal-metrics" not in personal
    assert "personal-metrics" in statistics
    assert "personal-stat-table" in statistics
    assert "Статистика" in statistics
    home = (ROOT / "templates/pass_viewer/home.html").read_text(encoding="utf-8")
    partial = (ROOT / "templates/pass_viewer/owned_lists_partial.html").read_text(encoding="utf-8")
    assert 'id="owned-lists-home-slot"' in home
    assert "owned_home_lists.html" in home
    assert "owned_home_footer.html" in home
    assert "owned_lists_modal.html" in base
    modal_include = (ROOT / "templates/pass_viewer/includes/owned_lists_modal.html").read_text(encoding="utf-8")
    assert 'id="owned-lists-modal"' in modal_include
    assert "owned-lists.js" in base
    assert "owned-lists.css" in base
    assert "lists_embed" not in base
    assert "owned-lists-remote" not in base
    assert "owned-lists-modal__frame" not in base
    assert "owned-home-lists-stack" in partial
    assert "owned_home_footer.html" in partial
    assert "owned-home-workspace" not in partial
    assert "owned-passports-map" not in partial
    home_js = (ROOT / "pass_viewer/static/pass_viewer/js/home.js").read_text(encoding="utf-8")
    assert "openOwnedListsModal" in home_js
    assert "window.openOwnedListsModal" in home_js
    assert "lists-embed" not in home_js
    header_js = (ROOT / "pass_viewer/static/pass_viewer/js/site-header.js").read_text(encoding="utf-8")
    assert "openRemoteListsModal" not in header_js
    assert "openOwnedListsModal" in header_js
    owned_lists_js = (ROOT / "pass_viewer/static/pass_viewer/js/owned-lists.js").read_text(encoding="utf-8")
    assert "fetchFragment" in owned_lists_js
    assert "getModalListPanels" in owned_lists_js
    assert owned_lists_js.index("const modal =") < owned_lists_js.index("const PARTIAL_URL")
    assert "filterApprovalsByMine" in owned_lists_js
    assert "!filterApprovalsByMine" in owned_lists_js
    assert reverse("owned_lists_partial") == "/owned/lists-partial/"
    request = RequestFactory().get("/owned/lists-partial/")
    request.user = AnonymousUser()
    partial_html = render_to_string(
        "pass_viewer/owned_lists_partial.html",
        {
            "owned_objects": [],
            "approval_items": [],
            "owned_objects_error": "",
            "show_passports_tab": True,
            "can_write": False,
            "ods_user_brids": [],
        },
        request=request,
    )
    assert 'id="owned-lists-fragment"' in partial_html
    assert "owned-home-lists-stack" in partial_html
    assert "owned-home-footer" in partial_html
    assert "owned-home-workspace" not in partial_html
    assert 'id="owned-passports-map"' not in partial_html
    assert "site-header" not in partial_html
    assert "personal-account" in personal
    assert "personal_notifications_panel.html" not in personal
    assert "personal-notifications-panel" not in personal
    assert "personal-account-layout" in personal
    assert "№ Заявки" in personal
    assert 'class="personal-row-num-col">№</th>' in personal
    assert "personal-row-num" in personal
    assert 'data-filter-col="1"' in personal
    assert 'colspan="12"' in personal
    assert "Вид паспортизации" in personal
    assert "personal_table_items" in personal
    assert "personal-kind-filter-btn" in personal
    assert 'data-kind-filter="all"' in personal
    assert 'data-kind-filter="actualization"' in personal
    assert 'data-kind-filter="primary"' in personal
    assert 'data-kind-filter="approval"' in personal
    assert "personal-kind-filter-count" in personal
    assert "Все паспорта и заявки на паспортизацию" in personal
    assert "Заявки на актуализацию" in personal
    assert "Заявки на первичную паспортизацию" in personal
    assert "Список объектов" not in personal
    assert "|default:item.area" not in personal
    assert "personal-asu-ods-open" in personal
    assert "personal-table-btn__icon" in personal
    assert "moscow-gerb.svg" in personal
    assert "intersect-polygons.svg" in personal
    assert "search-loupe.svg" in personal
    assert "Проверить пересечения" in personal
    assert "personal-dgi-check" in personal
    assert "check-dgi-modal" in personal
    assert "personal-dgi-choose-modal" in personal
    assert "personal-detail-map" in personal
    assert "personal-detail-object-toggle" in personal
    assert "personal-detail-mode-passport" in personal
    assert "personal-detail-mode-request" in personal
    assert "Год паспортизации" in personal
    js = (ROOT / "pass_viewer/static/pass_viewer/js/personal-account.js").read_text(encoding="utf-8")
    assert "createBasemapLayers" in js
    assert "attachBasemapControl" not in js
    assert "openOwnedObjectForView" in js
    assert "view_only" in js
    assert "applyPersonalTableFilters" in js
    assert "renumberVisiblePersonalRows" in js
    assert "updateKindFilterCounts" in js
    assert "data-kind-filter" in js
    assert "setKindFilterPressed(allKindBtn, false)" in js
    assert "setKindFilterPressed(item, item === btn)" in js
    assert "applyDetailMode" in js
    assert "personal-detail-object-toggle" in js
    assert "runPersonalDgiCheck" in js
    assert "personal-dgi-check" in js
    assert "owned-view-object-modal" in personal


def test_personal_account_renders_owned_object_without_area() -> None:
    request = RequestFactory().get("/personal/")
    request.user = AnonymousUser()
    html = render_to_string(
        "pass_viewer/personal_account.html",
        {
            "personal_table_items": [
                {
                    "row_kind": "passport",
                    "display_rootid": "924695948",
                    "display_request_id": "",
                    "name": "1-й Щипковский пер.",
                    "source_label": "ОЗН",
                    "area_label": "7 617 м²",
                    "passportization_year": "—",
                    "passportization_kind": "",
                    "display_status": "—",
                    "asu_ods_rootid": "924695948",
                    "asu_ods_source": "ОЗН",
                    "asu_ods_enabled": True,
                    "request_id": "",
                    "recap_count": 0,
                },
                {
                    "row_kind": "request",
                    "display_rootid": "",
                    "display_request_id": "78467",
                    "name": "Валовая ул. 10",
                    "source_label": "ДТ",
                    "area_label": "",
                    "passportization_year": "—",
                    "passportization_kind": "Первичная",
                    "display_status": "Включена в график",
                    "asu_ods_rootid": "",
                    "asu_ods_source": "ДТ",
                    "asu_ods_enabled": False,
                    "request_id": "78467",
                    "recap_count": 0,
                },
                {
                    "row_kind": "approval",
                    "display_rootid": "",
                    "display_request_id": "",
                    "name": "Согласование заявки из графика паспортизации 46998",
                    "source_label": "ДТ",
                    "area_label": "",
                    "passportization_year": "—",
                    "passportization_kind": "",
                    "display_status": "В работе",
                    "approve_id": "approve-1",
                    "asu_ods_rootid": "",
                    "asu_ods_source": "ДТ",
                    "asu_ods_enabled": False,
                },
            ],
            "owned_objects_error": "",
            "personal_metrics": {
                "passport_count": 1,
                "total_area_label": "7 717 м²",
                "request_count": 0,
                "approval_count": 0,
            },
            "personal_kind_counts": {
                "all": 2,
                "actualization": 0,
                "primary": 1,
                "approval": 1,
            },
            "page_config": {
                "page": "personal",
                "urls": {
                    "resolveAsuOdsUrl": "/owned/resolve-asu-ods-url/",
                    "personalObjectDetails": "/personal/object-details/",
                },
            },
        },
        request=request,
    )
    assert "1-й Щипковский пер." in html
    assert "ОЗН" in html
    assert "7 617 м²" in html
    assert "personal-badge" in html
    assert "personal-asu-ods-open" in html
    assert "personal-table-btn__icon" in html
    assert "moscow-gerb.svg" in html
    assert "intersect-polygons.svg" in html
    assert "search-loupe.svg" in html
    assert "personal-dgi-check" in html
    assert "Проверить пересечения" in html
    assert "check-dgi-modal" in html
    assert "personal-detail-map" in html
    assert "page-config" in html
    assert "owned-view-object-modal" in html
    assert "owned-view-object-frame" in html
    assert "personal-notifications-panel" not in html
    assert "personal-account-layout" in html
    assert "№ Заявки" in html
    assert 'class="personal-row-num">' in html
    assert "Вид паспортизации" in html
    assert "78467" in html
    assert "Первичная" in html
    assert "Согласование заявки из графика паспортизации 46998" in html
    assert "В работе" in html
    assert 'data-row-kind="passport"' in html
    assert 'data-row-kind="request"' in html
    assert 'data-row-kind="approval"' in html
    assert 'data-kind-filter="all"' in html
    assert "Все паспорта и заявки на паспортизацию" in html
    assert "personal-kind-filter-count" in html
    assert ">2</span>" in html
    assert ">1</span>" in html
    assert "personal-metrics" not in html


def test_statistics_page_renders_metrics_and_tables() -> None:
    request = RequestFactory().get("/statistics/")
    request.user = AnonymousUser()
    html = render_to_string(
        "pass_viewer/statistics.html",
        {
            "owned_objects_error": "",
            "personal_metrics": {
                "passport_count": 2,
                "request_count": 1,
                "approval_count": 3,
                "total_area_label": "7 717 м²",
            },
            "personal_statistics": {
                "passportization_kinds": [
                    {"label": "Актуализация", "count": 1},
                    {"label": "Первичная", "count": 1},
                    {"label": "Ожидает подтверждение", "count": 0},
                    {"label": "Не определено", "count": 0},
                    {"label": "без вида", "count": 2},
                ],
                "ogh_types": [
                    {"label": "ДТ", "count": 1},
                    {"label": "ОДХ", "count": 0},
                    {"label": "ОО", "count": 1},
                    {"label": "ТОП", "count": 0},
                    {"label": "прочие", "count": 0},
                ],
                "years": [{"label": "2026", "count": 2}, {"label": "—", "count": 2}],
                "statuses": [{"label": "Утверждён", "count": 2}, {"label": "В работе", "count": 1}],
                "links": [
                    {"label": "Связь с АСУ ОДС", "count": 1},
                    {"label": "Приклеенная заявка", "count": 0},
                ],
            },
        },
        request=request,
    )
    assert "Статистика" in html
    assert "personal-metrics" in html
    assert "Количество утверждённых паспортов" in html
    assert "7 717 м²" in html
    assert "personal-stat-table" in html
    assert "Вид паспортизации" in html
    assert "Тип ОГХ" in html
    assert "Год паспортизации" in html
    assert "Связь с АСУ ОДС" in html
    assert "Приклеенная заявка" in html
    assert "Актуализация" in html
    assert "Утверждён" in html


def test_view_only_main_hides_site_header() -> None:
    request = RequestFactory().get("/main/?view_only=1")
    request.user = AnonymousUser()
    html = render_to_string(
        "pass_viewer/main.html",
        {
            "view_only": True,
            "entry_point": {},
            "map_layers": {"selected": None},
            "page_config": {"page": "main", "viewOnly": True},
            "query_error": "",
        },
        request=request,
    )
    assert 'class="site-header"' not in html
    assert "site-header.js" not in html
    assert "has-site-header" not in html
    assert "view-only-embed" in html
    assert "map-stage--view-only" in html
    assert 'class="page-header-card" style="display:none;"' in html
    assert "owned-view-object" not in html


def test_editor_dom_contracts_are_preserved() -> None:
    required_ids = {
        "main.html": {"map", "edit-geometry-btn", "save-geometry-btn", "layer-management-panel"},
        "add_object.html": {"map", "edit-geometry-btn", "clear-map-btn", "layer-management-panel"},
        "add_recap.html": {"map", "add-dossier-btn", "save-dossier-btn", "layer-management-panel"},
    }
    for filename, ids in required_ids.items():
        source = (ROOT / "templates/pass_viewer" / filename).read_text(encoding="utf-8")
        missing = [element_id for element_id in ids if f'id="{element_id}"' not in source]
        assert not missing, f"{filename} lost DOM ids: {missing}"

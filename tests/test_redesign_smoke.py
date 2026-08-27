from pathlib import Path

from django.contrib.auth.models import AnonymousUser
from django.template.loader import render_to_string
from django.test import RequestFactory
from django.urls import reverse

ROOT = Path(__file__).resolve().parents[1]


def test_redesign_routes_and_templates_are_wired() -> None:
    assert reverse("personal_account") == "/personal/"
    base = (ROOT / "templates/base.html").read_text(encoding="utf-8")
    header = (ROOT / "templates/includes/site_header.html").read_text(encoding="utf-8")
    personal = (ROOT / "templates/pass_viewer/personal_account.html").read_text(encoding="utf-8")
    assert "includes/site_header.html" in base
    assert "site-header.js" in base
    assert "notifications.js" in base
    assert "approval_notifications_modal.html" in base
    assert "approval-notifications-btn" in header
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
    assert "split_object" not in header
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
    assert "personal_notifications_panel.html" in personal
    assert "personal-account-layout" in personal
    assert "|default:item.area" not in personal
    assert "personal-asu-ods-open" in personal
    assert "personal-detail-map" in personal
    assert "Год паспортизации" in personal
    js = (ROOT / "pass_viewer/static/pass_viewer/js/personal-account.js").read_text(encoding="utf-8")
    assert "createBasemapLayers" in js
    assert "attachBasemapControl" not in js
    assert "openOwnedObjectForView" in js
    assert "view_only" in js
    assert "owned-view-object-modal" in personal


def test_personal_account_renders_owned_object_without_area() -> None:
    request = RequestFactory().get("/personal/")
    request.user = AnonymousUser()
    html = render_to_string(
        "pass_viewer/personal_account.html",
        {
            "owned_objects": [
                {
                    "rootid": "924695948",
                    "name": "1-й Щипковский пер.",
                    "source_label": "ОЗН",
                    "request_id": "",
                    "area_label": "0,7617 га",
                }
            ],
            "owned_objects_error": "",
            "personal_metrics": {
                "passport_count": 1,
                "total_area_label": "7 717 м²",
                "request_count": 0,
                "approval_count": 0,
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
    assert "0,7617 га" in html
    assert "7 717 м²" in html
    assert "personal-badge" in html
    assert "personal-asu-ods-open" in html
    assert "personal-detail-map" in html
    assert 'disabled>Открыть' not in html
    assert "page-config" in html
    assert "owned-view-object-modal" in html
    assert "owned-view-object-frame" in html
    assert "personal-notifications-panel" in html
    assert "personal-account-layout" in html


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

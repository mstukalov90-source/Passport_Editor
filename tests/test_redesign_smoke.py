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
    assert "approval-notifications-btn" in header
    assert "personal-account" in personal
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

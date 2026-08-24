from pathlib import Path

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

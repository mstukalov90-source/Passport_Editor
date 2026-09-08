from pathlib import Path

import pytest
from django.urls import reverse

ROOT = Path(__file__).resolve().parents[1]
TEMPLATES = ROOT / "templates/pass_viewer"
JS = ROOT / "pass_viewer/static/pass_viewer/js"


def test_four_editors_use_add_object_shell() -> None:
    for name in ("main.html", "add_object.html", "add_recap.html", "split_object.html"):
        html = (TEMPLATES / name).read_text(encoding="utf-8")
        assert "add-object-shell" in html
        assert "add-object-panel--map" in html
        assert 'id="save-geometry-btn"' in html
        assert 'id="save-geometry-btn" style="display:none"' not in html
        assert "editor_request_panels.html" in html
        assert "container--add-object" in html


def test_layer_panel_labels_and_signal_tape_opacity() -> None:
    source = (JS / "layer-panel.js").read_text(encoding="utf-8")
    assert "Полигон " in source
    assert "Объект " not in source
    assert "props.descr" in source
    assert "_passViewerRestoreDgiDom" in source
    assert "data-layer-opacity-group" in (TEMPLATES / "includes/editor_layer_panel.html").read_text(
        encoding="utf-8"
    )
    assert "pv-layer-opacity" in source
    assert "STORAGE_KEY + '-'" in source
    comments = (TEMPLATES / "includes/editor_request_panels.html").read_text(encoding="utf-8")
    assert 'id="db-comments-section"' in comments
    assert "add-object-tools__db-comments is-collapsed" in comments
    assert 'aria-expanded="false"' in comments


def test_layer_pages_include_panel_and_opacity_slider() -> None:
    for name in ("main.html", "add_object.html", "add_recap.html"):
        html = (TEMPLATES / name).read_text(encoding="utf-8")
        assert "editor_layer_panel.html" in html
    panel = (TEMPLATES / "includes/editor_layer_panel.html").read_text(encoding="utf-8")
    assert 'id="layer-opacity-slider"' in panel
    assert 'data-layer-opacity-group="municipal"' in panel
    assert 'data-layer-opacity-group="requests"' in panel
    assert 'data-layer-opacity-group="dgi"' in panel
    assert 'data-layer-opacity-group="external"' in panel
    assert "layer-panel-row__expand" in panel
    scripts = (TEMPLATES / "includes/map_editor_scripts.html").read_text(encoding="utf-8")
    assert "layer-panel.js" in scripts
    assert "editor-request-side.js" in scripts
    side = (JS / "editor-request-side.js").read_text(encoding="utf-8")
    assert "add-object-approval__steps" in side
    assert "add-object-approval__step--rejected" in side
    assert "odsInRegistry" in side


def test_split_has_no_layer_tree_but_loads_request_side() -> None:
    html = (TEMPLATES / "split_object.html").read_text(encoding="utf-8")
    assert "add-object-workspace--no-layers" in html
    assert "editor_layer_panel.html" not in html
    assert "editor-request-side.js" in html


def test_built_js_keeps_export_visible_and_hooks_layer_panel() -> None:
    main_js = (JS / "main.js").read_text(encoding="utf-8")
    add_object_js = (JS / "add-object.js").read_text(encoding="utf-8")
    add_recap_js = (JS / "add-recap.js").read_text(encoding="utf-8")
    split = (JS / "split/map-controller.js").read_text(encoding="utf-8")
    assert "PV.LayerPanel.init" in main_js
    assert "PV.LayerPanel.init" in add_object_js
    assert "PV.LayerPanel.init" in add_recap_js
    assert "saveButton.style.display = enabled" not in main_js
    assert "saveButton.style.display = enabled" not in add_object_js
    assert "saveButton.style.display = enabled" not in split
    assert "selectedGeo || selectedGeometry" in main_js
    assert "getElementById('save-geometry-btn')" in add_recap_js
    assert "PV.setMapToolbarLabel" in main_js
    assert "PV.setMapToolbarLabel" in add_object_js
    assert "keepExportLinks" in split
    assert "setEditMode(false)" in main_js
    main_html = (TEMPLATES / "main.html").read_text(encoding="utf-8")
    assert "map-toolbar-btn__label" in main_html
    assert "toolbar_icon.html" in main_html


@pytest.mark.django_db
def test_add_object_page_renders_redesign_shell(client, e2e_credentials) -> None:
    assert client.login(
        username=e2e_credentials["username"],
        password=e2e_credentials["password"],
    )
    response = client.get(reverse("add_object"))
    assert response.status_code == 200
    content = response.content.decode("utf-8")
    assert "add-object-workspace" in content
    assert "add-object-panel--map" in content
    assert 'id="layer-opacity-slider"' in content
    assert 'id="ods-request-status-section"' in content
    assert "Выгрузить объекты" in content
    assert "odsRequestStatus" in content
    assert "bidComments" in content
    assert "uploadAttachment" in content

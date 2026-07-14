"""Tests for QML style manifest builder."""

from __future__ import annotations

from pathlib import Path

import pytest
from approval.qml_style_builder import (
    build_manifest,
    build_svg_index,
    parse_filter,
    parse_qgis_color,
    parse_qml_file,
    resolve_qml_path,
    sync_svg_static_tree,
)
from django.conf import settings


@pytest.fixture(autouse=True)
def _configure_style_paths(settings):
    base = Path(settings.BASE_DIR)
    settings.APPROVAL_LAYER_STYLES_QML_DIR = base / "approval" / "layer_styles" / "qml"
    settings.APPROVAL_LAYER_STYLES_SQL = base / "approval" / "layer_styles" / "create_work.sql"
    settings.APPROVAL_LAYER_STYLES_SVG_SOURCE = base / "approval" / "layer_styles" / "svg"
    settings.APPROVAL_LAYER_STYLES_MANIFEST = base / "approval" / "static" / "approval" / "work_layer_styles.json"
    settings.APPROVAL_LAYER_STYLES_SVG_STATIC = base / "approval" / "static" / "approval" / "icons" / "svg"
    settings.APPROVAL_LAYER_STYLES_SVG_INDEX = base / "approval" / "static" / "approval" / "svg_index.json"


def test_parse_qgis_color_rgb():
    parsed = parse_qgis_color("84,176,74,255,rgb:0.3294118,0.6901961,0.2901961,1")
    assert parsed == {"color": "#54b04a", "opacity": 1.0}


def test_parse_filter_eq_and_null():
    assert parse_filter('"AbutmentType" = \'fence_road_stone\'') == {
        "type": "eq",
        "field": "AbutmentType",
        "value": "fence_road_stone",
    }
    assert parse_filter('"AbutmentType" is null') == {"type": "null", "field": "AbutmentType"}


def test_resolve_qml_path_planar_structure_alias():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    path = resolve_qml_path("PlanarStructurePoly", qml_dir)
    assert path is not None
    assert path.name == "WorkLayers_PlanarStructure.qml"


def test_parse_abutment_line_rules():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    path = qml_dir / "WorkLayers_AbutmentLine.qml"
    parsed = parse_qml_file(path)
    assert parsed["geometry"] == "line"
    assert "AbutmentType" in parsed["fields"]
    assert len(parsed["rules"]) >= 5
    assert parsed["rules"][-1]["label"] == "Нет данных"


def test_build_manifest_includes_labels():
    manifest = build_manifest(tables=["DtsPoly", "LawnPoly"])
    assert manifest["tables"]["DtsPoly"]["label"] == "Дорожно-тропиночная сеть"
    assert manifest["tables"]["LawnPoly"]["label"] == "Газоны"


def test_parse_photo_fix_point_single_symbol():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    path = qml_dir / "WorkLayers_PhotoFixPoint.qml"
    parsed = parse_qml_file(path)
    assert parsed["geometry"] == "point"
    assert len(parsed["rules"]) == 1
    assert parsed["rules"][0]["style"]["svg"] == "Фотофиксация.svg"


def test_parse_functionality_point_mapunit_icon_size():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    path = qml_dir / "WorkLayers_FunctionalityPoint.qml"
    parsed = parse_qml_file(path)
    assert parsed["geometry"] == "point"
    assert parsed["rules"]
    svg_styles = [
        rule["style"]
        for rule in parsed["rules"]
        if rule.get("style", {}).get("svgField") or rule.get("style", {}).get("svg")
    ]
    assert svg_styles
    for style in svg_styles:
        if style.get("iconSize") and style.get("iconSize") >= 7:
            assert style["sizeUnit"] == "MapUnit"
            assert style["iconSize"] in {7.0, 14.0}
            assert style["iconSize"] < 50  # not the old *4 pixel conversion


def test_parse_little_form_point_mapunit_icon_size():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    path = qml_dir / "WorkLayers_LittleFormPoint.qml"
    parsed = parse_qml_file(path)
    assert parsed["geometry"] == "point"
    assert parsed["rules"]
    style = parsed["rules"][0]["style"]
    assert style["sizeUnit"] == "MapUnit"
    assert style.get("iconSizeUnit") == "MapUnit"
    assert style["iconSize"] == 14.0
    assert style.get("iconAnchorX") == "center"
    assert style.get("iconAnchorY") == "bottom"


def test_sync_svg_static_tree_preserves_subfolders(tmp_path, settings):
    source = tmp_path / "svg"
    nested = source / "Дорожные знаки ОДХ" / "1. Предупреждающие знаки"
    nested.mkdir(parents=True)
    nested_file = nested / "1.1.svg"
    nested_file.write_text("<svg></svg>", encoding="utf-8")

    settings.APPROVAL_LAYER_STYLES_SVG_SOURCE = source
    settings.APPROVAL_LAYER_STYLES_SVG_STATIC = tmp_path / "static" / "icons" / "svg"
    settings.APPROVAL_LAYER_STYLES_SVG_INDEX = tmp_path / "static" / "svg_index.json"

    copied = sync_svg_static_tree(clean=True)
    assert copied == ["Дорожные знаки ОДХ/1. Предупреждающие знаки/1.1.svg"]
    assert (settings.APPROVAL_LAYER_STYLES_SVG_STATIC / copied[0]).is_file()


def test_build_svg_index_includes_cyrillic_basename(tmp_path, settings):
    source = tmp_path / "svg"
    source.mkdir()
    filename = "Емкости и павильоны_Площадка для выкатных контейнеров.svg"
    (source / filename).write_text("<svg></svg>", encoding="utf-8")

    settings.APPROVAL_LAYER_STYLES_SVG_SOURCE = source
    index = build_svg_index([filename])

    assert index[filename] == filename
    assert index[Path(filename).name] == filename

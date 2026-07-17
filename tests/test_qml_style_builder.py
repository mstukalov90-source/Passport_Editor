"""Tests for QML style manifest builder."""

from __future__ import annotations

from pathlib import Path

import pytest
from approval.qml_style_builder import (
    build_manifest,
    build_svg_index,
    collect_table_names,
    merge_parsed_qml_tables,
    parse_filter,
    parse_qgis_color,
    parse_qml_file,
    resolve_qml_path,
    resolve_qml_paths,
    sync_svg_static_tree,
)
from django.conf import settings


@pytest.fixture(autouse=True)
def _configure_style_paths(settings):
    from approval.work_layer_labels import load_work_layer_labels

    base = Path(settings.BASE_DIR)
    settings.APPROVAL_LAYER_STYLES_QML_DIR = base / "approval" / "layer_styles" / "qml"
    settings.APPROVAL_LAYER_STYLES_SQL = base / "approval" / "layer_styles" / "create_work.sql"
    settings.APPROVAL_LAYER_STYLES_SVG_SOURCE = base / "approval" / "layer_styles" / "svg"
    settings.APPROVAL_LAYER_STYLES_MANIFEST = base / "approval" / "static" / "approval" / "work_layer_styles.json"
    settings.APPROVAL_LAYER_STYLES_SVG_STATIC = base / "approval" / "static" / "approval" / "icons" / "svg"
    settings.APPROVAL_LAYER_STYLES_SVG_INDEX = base / "approval" / "static" / "approval" / "svg_index.json"
    load_work_layer_labels.cache_clear()


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


def test_parse_filter_topography_compound_expressions():
    parsed = parse_filter("layer = 'Level 2' and olinetype != 'UP line'")
    assert parsed == {
        "type": "and",
        "children": [
            {"type": "eq", "field": "layer", "value": "Level 2"},
            {"type": "ne", "field": "olinetype", "value": "UP line"},
        ],
    }
    parsed_in = parse_filter("layer in ('Level 3', 'Level 5') and olinetype != 'UP line'")
    assert parsed_in["type"] == "and"
    assert parsed_in["children"][0] == {
        "type": "in",
        "field": "layer",
        "values": ["Level 3", "Level 5"],
    }
    parsed_like = parse_filter(
        "(layer like 'Тротуар%' or layer like 'Борт тротуара%' or layer = 'Понижение борта')"
    )
    assert parsed_like["type"] == "or"
    assert parsed_like["children"][0] == {
        "type": "like",
        "field": "layer",
        "pattern": "Тротуар%",
    }
    assert parse_filter("ELSE") == {"type": "else"}


def test_resolve_qml_path_topography_tables():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    assert resolve_qml_path("topolines", qml_dir).name == "TopographyLayers_polylines.qml"
    assert resolve_qml_path("topopoint", qml_dir).name == "TopographyLayers_inserts.qml"
    assert resolve_qml_path("topotext", qml_dir).name == "TopographyLayers_texts.qml"


def test_resolve_qml_paths_topolines_merges_both_files():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    paths = resolve_qml_paths("topolines", qml_dir)
    assert [p.name for p in paths] == [
        "TopographyLayers_polylines.qml",
        "TopographyLayers_lines.qml",
    ]
    assert resolve_qml_paths("topotext", qml_dir)[0].name == "TopographyLayers_texts.qml"


def test_build_manifest_includes_topography_tables():
    from approval.work_layer_labels import load_work_layer_labels

    load_work_layer_labels.cache_clear()
    manifest = build_manifest(tables=["topolines", "topopoint", "topotext"])
    topolines = manifest["tables"]["topolines"]
    assert topolines["label"] == "Линии топоосновы"
    assert topolines["geometry"] == "line"
    assert len(topolines["rules"]) >= 50
    assert "TopographyLayers_polylines.qml" in topolines["qmlFile"]
    assert "TopographyLayers_lines.qml" in topolines["qmlFile"]
    assert "layer" in topolines["fields"]
    assert "olinetype" in topolines["fields"]
    hydro = next(r for r in topolines["rules"] if r.get("label") == "Гидрография")
    assert hydro["style"]["color"] == "#007fff"
    assert hydro["style"]["color"] != "#232323"
    assert any(r.get("label") == "Борта" for r in topolines["rules"])
    assert manifest["tables"]["topopoint"]["label"] == "Точки топоосновы"
    assert manifest["tables"]["topopoint"]["geometry"] == "point"
    topotext = manifest["tables"]["topotext"]
    assert topotext["label"] == "Тексты топоосновы"
    assert topotext["qmlFile"] == "TopographyLayers_texts.qml"
    assert "text" in topotext["fields"]
    assert topotext["labeling"]["field"] == "text"
    assert topotext["labeling"]["rotationField"] == "angle"


def test_merge_parsed_qml_tables_orders_rules_and_keeps_one_else():
    merged = merge_parsed_qml_tables(
        [
            {
                "geometry": "line",
                "rules": [
                    {"label": "A", "style": {"kind": "line", "color": "#00ff00"}, "filter": {"type": "eq", "field": "layer", "value": "a"}},
                    {"label": "ELSE poly", "style": {"kind": "line", "color": "#ff0000"}, "filter": {"type": "else"}},
                ],
                "fields": ["layer"],
                "qmlFile": "poly.qml",
            },
            {
                "geometry": "line",
                "rules": [
                    {"label": "B", "style": {"kind": "line", "color": "#232323"}, "filter": {"type": "eq", "field": "layer", "value": "b"}},
                    {"label": "ELSE lines", "style": {"kind": "line", "color": "#000000"}, "filter": {"type": "else"}},
                ],
                "fields": ["olinetype"],
                "qmlFile": "lines.qml",
            },
        ]
    )
    assert [r["label"] for r in merged["rules"]] == ["A", "B", "ELSE lines"]
    assert merged["qmlFile"] == "poly.qml+lines.qml"
    assert merged["fields"] == ["layer", "olinetype"]
    assert merged["defaultRule"] == 2


def test_parse_topography_texts_labeling():
    qml_dir = Path(settings.APPROVAL_LAYER_STYLES_QML_DIR)
    parsed = parse_qml_file(qml_dir / "TopographyLayers_texts.qml")
    labeling = parsed["labeling"]
    assert labeling["field"] == "text"
    assert labeling["fontSizeUnit"] == "MapUnit"
    assert labeling["fontSize"] == 1.0
    assert labeling["color"] == "#000000"
    assert labeling["rotationField"] == "angle"
    assert labeling["rotationMode"] == "complement"
    assert "text" in parsed["fields"]
    assert "angle" in parsed["fields"]
    assert any(rule.get("label") == "Текст" for rule in parsed["rules"])


def test_collect_table_names_includes_topography_tables():
    names = collect_table_names()
    assert "topolines" in names
    assert "topopoint" in names
    assert "topotext" in names


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


def test_collect_table_names_includes_qml_only_tables():
    names = collect_table_names()
    assert "TopPoly" in names
    assert "CarriagewayPolyAxis" in names
    assert not any(".mobile" in name.lower() for name in names)


def test_build_manifest_includes_toppoly():
    manifest = build_manifest()
    assert "TopPoly" in manifest["tables"]
    assert manifest["tables"]["TopPoly"]["rules"]

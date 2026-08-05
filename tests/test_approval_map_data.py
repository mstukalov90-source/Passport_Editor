"""Tests for approval map data loading."""

from __future__ import annotations

import uuid
from unittest.mock import MagicMock, patch

import pytest
from approval.access import get_accessible_approves, get_owner_id_for_username
from approval.models import Approve
from approval.views import landing
from approval.page_config import landing_page_config
from approval.work_layers import (
    batch_lookup_task_poly_meta,
    build_layer_groups,
    count_features_by_table,
    format_survey_page_title,
    geom_to_wgs84_sql,
    layer_stack_order,
    lookup_task_poly_meta,
    lookup_task_survey_fields,
    resolve_task_survey_name,
    resolve_task_survey_title,
    wgs84_to_work_sql,
    work_source_proj4_sql,
    work_source_srid,
)
from django.http import HttpResponse
from django.test import RequestFactory
from django.urls import reverse
from pass_viewer.models import ExternalUser


@pytest.mark.django_db
def test_get_owner_id_for_username():
    ExternalUser.objects.create(login="owner_user", password="x", owner_legal_person_id="10233594")
    assert get_owner_id_for_username("owner_user") == "10233594"
    assert get_owner_id_for_username("missing") is None


@pytest.mark.django_db
def test_get_accessible_approves_filters_by_owner():
    guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    approve = Approve.objects.create(incoming_guid=guid, owners=["10233594"])
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["10233594"]
    primary.save(update_fields=["owners", "updated_at"])
    Approve.objects.create(incoming_guid=uuid.uuid4(), owners=["99999999"])

    qs = get_accessible_approves("10233594")
    assert qs.count() == 1
    assert qs.first().incoming_guid == guid


def test_build_layer_groups_skips_zero_counts():
    groups = build_layer_groups({"DtsPoly": 12, "OznPoly": 0})
    assert len(groups) == 1
    assert groups[0]["key"] == "work"
    assert [layer["key"] for layer in groups[0]["layers"]] == ["DtsPoly"]


def test_build_layer_groups_uses_russian_labels_and_geometry():
    groups = build_layer_groups({"DtsPoly": 3})
    layer = groups[0]["layers"][0]
    assert layer["name"] == "Дорожно-тропиночная сеть"
    assert layer["geometry"] == "polygon"
    assert groups[0]["title"] == "Объект согласования"


def test_build_layer_groups_tracks_geometry_for_line_layers():
    groups = build_layer_groups({"AbutmentLine": 2})
    layer = groups[0]["layers"][0]
    assert layer["geometry"] == "line"


def test_build_layer_groups_excludes_task_and_basepoly_hides_yardpoly():
    groups = build_layer_groups({"task": 2, "BasePoly": 3, "YardPoly": 4, "DtsPoly": 1})
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert "task" not in layers
    assert "BasePoly" not in layers
    assert layers["YardPoly"]["checked"] is False
    assert layers["DtsPoly"]["checked"] is True


def test_build_layer_groups_empty():
    assert build_layer_groups({}) == []


def test_build_layer_groups_orders_by_geometry():
    groups = build_layer_groups(
        {
            "DtsPoly": 1,
            "AbutmentLine": 2,
            "PhotoFixPoint": 3,
            "OdhPoly": 4,
            "YardPoly": 5,
            "OznPoly": 6,
        }
    )
    keys = [layer["key"] for layer in groups[0]["layers"]]
    assert keys.index("PhotoFixPoint") < keys.index("AbutmentLine")
    assert keys.index("AbutmentLine") < keys.index("DtsPoly")
    assert keys.index("DtsPoly") < keys.index("OdhPoly")
    assert keys.index("DtsPoly") < keys.index("OznPoly")
    assert keys.index("DtsPoly") < keys.index("YardPoly")


def test_layer_stack_order_places_points_on_top():
    groups = build_layer_groups(
        {
            "DtsPoly": 1,
            "AbutmentLine": 2,
            "PhotoFixPoint": 3,
            "OdhPoly": 4,
        }
    )
    stack = layer_stack_order(groups)
    assert stack.index("OdhPoly") < stack.index("DtsPoly")
    assert stack.index("DtsPoly") < stack.index("AbutmentLine")
    assert stack.index("AbutmentLine") < stack.index("PhotoFixPoint")


def test_landing_page_config_includes_focus_task_guid():
    guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    groups = build_layer_groups({"DtsPoly": 1})
    config = landing_page_config(layer_groups=groups, focus_task_guid=guid)
    assert config["focusTaskGuid"] == str(guid)
    assert config["layerStackOrder"] == ["DtsPoly"]


@patch("approval.work_layers.connections")
def test_count_features_by_table(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    with patch(
        "approval.work_layers.list_work_layer_tables",
        return_value=["DtsPoly", "OznPoly"],
    ):
        cursor.fetchone.side_effect = [(3,), (0,)]
        counts = count_features_by_table(["2e333940-831b-48f5-9751-acd0c2880974"])

    assert counts == {"DtsPoly": 3}


@pytest.mark.django_db
def test_landing_without_owner_shows_message():
    ExternalUser.objects.create(login="no_owner", password="x", owner_legal_person_id=None)
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="no_owner")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    assert "Нет доступных согласований" in context["map_message"]
    assert context["map_geojson"]["type"] == "FeatureCollection"


@pytest.mark.django_db
def test_landing_inspector_without_owner_id_loads_approves():
    ExternalUser.objects.create(login="inspector_only", password="x", owner_legal_person_id=None)
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
        user="inspector_only",
    )
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="inspector_only")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    assert context["map_message"] is None or "OwnerLegalPersonId" not in context["map_message"]


@pytest.mark.django_db
def test_landing_with_approve_and_mock_qgis_layers():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="approval_map_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(incoming_guid=incoming_guid, owners=[owner_id])
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    with patch("approval.views.count_features_by_table", return_value={"DtsPoly": 1}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={"marker.svg": "marker.svg"}):
                        with patch(
                            "approval.views.resolve_task_survey_title",
                            return_value="Согласование",
                        ):
                            with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                                request = RequestFactory().get("/approval/")
                                request.user = MagicMock(is_authenticated=True, username="approval_map_user")
                                response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    layer_names = [layer["name"] for group in context["layer_groups"] for layer in group["layers"]]
    assert "Дорожно-тропиночная сеть" in layer_names
    assert context["map_geojson"]["features"] == []
    page_config = context["page_config"]
    assert page_config["mapLayerLoadOrder"][0]["key"] == "work:DtsPoly"
    assert any(spec["key"] == "dgi" for spec in page_config["mapLayerLoadOrder"])


@pytest.mark.django_db
def test_landing_without_matching_approve_shows_empty_message():
    ExternalUser.objects.create(login="other_owner", password="pass", owner_legal_person_id="11111111")
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
    )

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        request = RequestFactory().get("/approval/")
                        request.user = MagicMock(is_authenticated=True, username="other_owner")
                        response = landing(request)

    assert response.status_code == 200
    assert "Нет доступных согласований" in mock_render.call_args[0][2]["map_message"]


def test_build_topopassport_layer_groups_uses_prefixed_keys():
    from approval.work_layers import build_topopassport_layer_groups

    groups = build_topopassport_layer_groups({"DtsPoly": 2})
    assert groups[0]["key"] == "topopassport"
    assert groups[0]["layers"][0]["key"] == "topo:DtsPoly"


def test_build_topopassport_hides_topopoint_by_default():
    from approval.work_layers import build_topopassport_layer_groups

    groups = build_topopassport_layer_groups(
        {"topolines": 10, "topopoint": 5, "topotext": 3}
    )
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert layers["topo:topolines"]["checked"] is True
    assert layers["topo:topopoint"]["checked"] is False
    assert layers["topo:topotext"]["checked"] is True


def test_build_map_layer_load_order():
    from approval.map_load import build_map_layer_load_order

    specs = build_map_layer_load_order(
        work_counts={"DtsPoly": 1},
        topo_counts={"YardPoly": 2},
        has_adjacent=True,
        include_reference=True,
    )
    keys = [item["key"] for item in specs]
    assert keys[0] == "work:DtsPoly"
    assert "topo:YardPoly" in keys
    assert "adjacent" in keys
    assert keys.index("work:DtsPoly") < keys.index("topo:YardPoly")
    assert keys.index("topo:YardPoly") < keys.index("adjacent")
    assert keys[-4:] == ["dgi", "oozt", "renew", "rzd"]


def test_build_map_layer_load_order_skips_excluded_work_tables():
    from approval.map_load import build_map_layer_load_order

    specs = build_map_layer_load_order(
        work_counts={"task": 2, "BasePoly": 3, "DtsPoly": 1},
        topo_counts={},
        has_adjacent=False,
        include_reference=False,
    )
    keys = [item["key"] for item in specs]
    assert keys == ["work:DtsPoly"]
    assert "work:task" not in keys
    assert "work:BasePoly" not in keys


def test_schema_taskguid_column_uses_guid_for_topopassport():
    from approval.work_layers import schema_taskguid_column

    assert schema_taskguid_column("work") == "TaskGUID"
    assert schema_taskguid_column("topopassport") == "guid"


def test_work_source_srid_transform_helpers_use_980077():
    assert work_source_srid() == 980077
    assert "spatial_ref_sys WHERE srid = 980077" in work_source_proj4_sql()
    to_wgs = geom_to_wgs84_sql('t."Geometry"')
    assert to_wgs.startswith('ST_Transform(t."Geometry",')
    assert "proj4text FROM public.spatial_ref_sys WHERE srid = 980077" in to_wgs
    assert "+proj=longlat +datum=WGS84 +no_defs" in to_wgs
    assert "ST_SetSRID" not in to_wgs
    from_wgs = wgs84_to_work_sql()
    assert "ST_GeomFromGeoJSON(%s)" in from_wgs
    assert "proj4text FROM public.spatial_ref_sys WHERE srid = 980077" in from_wgs
    # Outer ST_SetSRID tags proj4-transform result (otherwise SRID 0) for ST_Intersects.
    assert from_wgs.startswith("ST_SetSRID(")
    assert from_wgs.endswith("980077)")


def test_topopassport_feature_select_sql_uses_guid_column():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    sql = _feature_select_sql(
        "SomePoly",
        [],
        cursor,
        schema="topopassport",
        layer_key="topo:SomePoly",
    )
    assert '"topopassport"."SomePoly"' in sql
    assert '"guid"' in sql
    assert "TaskGUID" not in sql
    assert "proj4text FROM public.spatial_ref_sys WHERE srid = 980077" in sql
    assert 'ST_Transform(t."Geometry"' in sql


def test_topotext_feature_select_sql_clips_to_work_boundary():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    sql = _feature_select_sql(
        "topotext",
        ["text", "angle"],
        cursor,
        schema="topopassport",
        layer_key="topo:topotext",
        clip_to_work_boundary=True,
    )
    assert "ST_Intersects" in sql
    assert "ST_GeomFromGeoJSON(%s)" in sql
    assert "ANY(%s::uuid[])" in sql
    # Guids placeholder comes before boundary GeoJSON.
    assert sql.index("ANY(%s::uuid[])") < sql.index("ST_GeomFromGeoJSON(%s)")
    assert "proj4text FROM public.spatial_ref_sys WHERE srid = 980077" in sql
    assert "ST_SetSRID(" in sql
    assert "980077)" in sql
    assert "ST_SRID(" not in sql


def test_topolines_feature_select_sql_excludes_order_boundary_layer():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql
    from approval.work_layers import TOPOLINES_EXCLUDED_LAYER

    cursor = MagicMock()
    cursor.fetchone.return_value = (1,)
    sql = _feature_select_sql(
        "topolines",
        [],
        cursor,
        schema="topopassport",
        layer_key="topo:topolines",
    )
    assert f"COALESCE(t.\"layer\", '') <> '{TOPOLINES_EXCLUDED_LAYER}'" in sql


def test_topopoint_feature_select_sql_does_not_exclude_order_boundary_layer():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql
    from approval.work_layers import TOPOLINES_EXCLUDED_LAYER

    cursor = MagicMock()
    cursor.fetchone.return_value = (1,)
    sql = _feature_select_sql(
        "topopoint",
        [],
        cursor,
        schema="topopassport",
        layer_key="topo:topopoint",
    )
    assert TOPOLINES_EXCLUDED_LAYER not in sql
    assert 't."layer"' not in sql


@patch("approval.work_layers.connections")
def test_count_features_by_table_keeps_prior_counts_on_table_error(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    def execute_side_effect(sql, params=None):
        if "topotext" in sql:
            raise RuntimeError("mixed SRID")
        return None

    cursor.execute.side_effect = execute_side_effect
    cursor.fetchone.side_effect = [(10,), (5,)]

    with patch("approval.work_layers._TOPO_CLIP_TO_WORK_TABLES", frozenset()):
        counts = count_features_by_table(
            ["2e333940-831b-48f5-9751-acd0c2880974"],
            schema="topopassport",
            tables=["topolines", "topopoint", "topotext"],
        )

    assert counts == {"topolines": 10, "topopoint": 5}

def test_should_clip_only_topotext_in_topopassport():
    from approval.work_geojson import _should_clip_table_to_work

    assert _should_clip_table_to_work("topopassport", "topotext") is True
    assert _should_clip_table_to_work("topopassport", "topolines") is False
    assert _should_clip_table_to_work("work", "topotext") is False


@patch("approval.work_geojson.load_work_anchor_geometry")
@patch("approval.work_geojson.connections")
def test_build_topopassport_skips_topotext_outside_work_boundary(
    mock_connections, mock_anchor
):
    from approval.work_geojson import build_topopassport_feature_collection

    mock_anchor.return_value = {
        "type": "Polygon",
        "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]],
    }
    cursor = mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value
    cursor.fetchone.return_value = None  # style column lookups may call fetchone
    # One feature returned by SELECT
    cursor.fetchall.return_value = [
        (
            {
                "type": "Feature",
                "geometry": {"type": "Point", "coordinates": [0.5, 0.5]},
                "properties": {"sourceTable": "topotext", "text": "inside"},
            },
        )
    ]

    collection, error = build_topopassport_feature_collection(
        ["11111111-1111-1111-1111-111111111111"],
        tables=["topotext"],
    )
    assert error is None
    assert len(collection["features"]) == 1
    sql = cursor.execute.call_args[0][0]
    params = cursor.execute.call_args[0][1]
    assert "ST_Intersects" in sql
    assert "ST_GeomFromGeoJSON" in sql
    assert params[0] == ["11111111-1111-1111-1111-111111111111"]
    assert '"type": "Polygon"' in params[1] or '"type":"Polygon"' in params[1].replace(" ", "")


@patch("approval.work_geojson.load_work_anchor_geometry", return_value=None)
@patch("approval.work_geojson.connections")
def test_build_topopassport_omits_topotext_when_no_work_boundary(
    mock_connections, _mock_anchor
):
    from approval.work_geojson import build_topopassport_feature_collection

    collection, error = build_topopassport_feature_collection(
        ["11111111-1111-1111-1111-111111111111"],
        tables=["topotext"],
    )
    assert error is None
    assert collection["features"] == []
    mock_connections.__getitem__.return_value.cursor.assert_called()
    cursor = mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value
    # No feature SELECT when boundary is missing.
    assert cursor.execute.call_count == 0


def test_work_feature_select_sql_still_uses_taskguid():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    sql = _feature_select_sql(
        "DtsPoly",
        [],
        cursor,
        schema="work",
        layer_key="DtsPoly",
    )
    assert '"work"."DtsPoly"' in sql
    assert '"TaskGUID"' in sql


def test_feature_select_sql_resolves_style_columns_case_insensitively():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    cursor.fetchone.return_value = ("dtstype",)

    sql = _feature_select_sql(
        "DtsPoly",
        ["DtsType"],
        cursor,
        schema="topopassport",
        layer_key="topo:DtsPoly",
    )

    assert "'DtsType', t.\"dtstype\"::text" in sql
    query = cursor.execute.call_args[0][0]
    params = cursor.execute.call_args[0][1]
    assert "lower(column_name)" in query
    assert params == ["topopassport", "DtsPoly", "DtsType"]


def test_build_reference_layer_groups_unchecked_by_default():
    from approval.work_layers import build_reference_layer_groups

    groups = build_reference_layer_groups()
    assert len(groups) == 1
    assert groups[0]["key"] == "reference"
    assert groups[0]["checked"] is False
    assert all(layer["checked"] is False for layer in groups[0]["layers"])
    assert [layer["key"] for layer in groups[0]["layers"]] == ["dgi", "oozt", "renew", "rzd"]
    assert [layer["name"] for layer in groups[0]["layers"]] == [
        "Земельные участки",
        "ООЗТ/ООПТ",
        "Реновация",
        "Полосы отвода ЖД",
    ]


@patch("approval.reference_layers.load_work_anchor_geometry")
@patch("pass_viewer.views._sql_dgi_layer_filter")
@patch("pass_viewer.views._get_reference_layer_geojson")
@patch("pass_viewer.views._geojson_layer_for_response")
@patch("django.db.connection.cursor")
def test_build_reference_layer_features_dgi_tags_subkeys(
    mock_cursor_cm,
    mock_geojson_response,
    mock_get_geojson,
    mock_dgi_filter,
    mock_anchor,
):
    from pass_viewer.dgi_layers import DGI_LAYER_KEYS
    from approval.reference_layers import build_reference_layer_features

    mock_cursor_cm.return_value.__enter__.return_value = MagicMock()
    mock_anchor.return_value = {
        "type": "Polygon",
        "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 0]]],
    }
    mock_dgi_filter.side_effect = lambda *_a, **_k: " AND TRUE"

    payloads = []
    for idx, _sub_key in enumerate(DGI_LAYER_KEYS):
        payloads.append(
            {
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "geometry": {
                            "type": "Polygon",
                            "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 0]]],
                        },
                        "properties": {"descr": f"plot-{idx}"},
                    }
                ],
            }
        )

    mock_get_geojson.side_effect = payloads
    mock_geojson_response.side_effect = lambda payload: payload

    features, error = build_reference_layer_features(
        "dgi", "11111111-1111-1111-1111-111111111111"
    )

    assert error is None
    assert len(features) == len(DGI_LAYER_KEYS)
    assert [f["properties"]["dgiSubKey"] for f in features] == list(DGI_LAYER_KEYS)
    assert all(f["properties"]["layerKey"] == "dgi" for f in features)
    assert mock_get_geojson.call_count == len(DGI_LAYER_KEYS)


@patch("approval.reference_layers.load_work_anchor_geometry")
@patch("pass_viewer.views._get_signal_tape_layer_geojson")
@patch("pass_viewer.views._geojson_layer_for_response")
def test_build_reference_layer_features_oozt_has_no_dgi_subkey(
    mock_geojson_response,
    mock_signal,
    mock_anchor,
):
    from approval.reference_layers import build_reference_layer_features

    mock_anchor.return_value = {"type": "Polygon", "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 0]]]}
    mock_signal.return_value = {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "geometry": {"type": "LineString", "coordinates": [[0, 0], [1, 1]]},
                "properties": {},
            }
        ],
    }
    mock_geojson_response.side_effect = lambda payload: payload

    features, error = build_reference_layer_features("oozt", "11111111-1111-1111-1111-111111111111")

    assert error is None
    assert len(features) == 1
    assert features[0]["properties"]["layerKey"] == "oozt"
    assert "dgiSubKey" not in features[0]["properties"]


@patch("approval.work_layers.connections")
def test_list_topopassport_tables_looks_for_guid_column(mock_connections):
    from approval.work_layers import list_schema_layer_tables

    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    cursor.fetchall.return_value = [("TopoPoly",)]

    tables = list_schema_layer_tables("topopassport", force_refresh=True)

    assert tables == ["TopoPoly"]
    sql = cursor.execute.call_args[0][0]
    params = cursor.execute.call_args[0][1]
    assert params[0] == "topopassport"
    assert params[1] == "guid"


def test_format_survey_page_title_full_and_fallback():
    assert (
        format_survey_page_title("Павла Андреева ул. 28", "46998")
        == "Согласование границ ОГХ Павла Андреева ул. 28 по заявке 46998."
    )
    assert format_survey_page_title("", "46998") == "Согласование границ ОГХ"
    assert format_survey_page_title("Street", "") == "Согласование границ ОГХ"
    assert format_survey_page_title(None, None) == "Согласование границ ОГХ"
    assert format_survey_page_title("  ", "  ") == "Согласование границ ОГХ"


@patch("approval.work_layers.connections")
def test_resolve_task_survey_title_uses_first_matching_table(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    # column_exists checks (3 per table until hit) then SELECT
    exists_then_row = [
        (1,),  # YardPoly TaskGUID
        (1,),  # YardPoly Name
        (1,),  # YardPoly PassBrId
        ("Шаболовка ул. 23", "24976"),
    ]
    cursor.fetchone.side_effect = exists_then_row

    title = resolve_task_survey_title("23f956bf-f000-4668-91f2-45274c453122")

    assert title == "Согласование границ ОГХ Шаболовка ул. 23 по заявке 24976."
    select_calls = [
        call_args
        for call_args in cursor.execute.call_args_list
        if "SELECT t." in call_args[0][0]
    ]
    assert len(select_calls) == 1
    assert '"YardPoly"' in select_calls[0][0][0]
    assert select_calls[0][0][1] == ["23f956bf-f000-4668-91f2-45274c453122"]


@patch("approval.work_layers.connections")
def test_resolve_task_survey_title_falls_back_when_empty(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    # All three tables: TaskGUID / Name / PassBrId exist, SELECT returns None
    cursor.fetchone.side_effect = [
        (1,),
        (1,),
        (1,),
        None,  # YardPoly row
        (1,),
        (1,),
        (1,),
        None,  # OznPoly row
        (1,),
        (1,),
        (1,),
        None,  # OdhPoly row
    ]

    assert resolve_task_survey_title("00000000-0000-0000-0000-000000000001") == "Согласование границ ОГХ"
    assert resolve_task_survey_title("") == "Согласование границ ОГХ"


@patch("approval.work_layers.connections")
def test_resolve_task_survey_name_returns_name(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    cursor.fetchone.side_effect = [
        (1,),  # YardPoly TaskGUID
        (1,),  # YardPoly Name
        (1,),  # YardPoly PassBrId
        ("Шаболовка ул. 23", "24976"),
    ]

    assert resolve_task_survey_name("23f956bf-f000-4668-91f2-45274c453122") == "Шаболовка ул. 23"


@patch("approval.work_layers.connections")
def test_lookup_task_survey_fields_returns_name_and_brid(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    cursor.fetchone.side_effect = [
        (1,),
        (1,),
        (1,),
        ("Шаболовка ул. 23", "24976"),
    ]

    assert lookup_task_survey_fields("23f956bf-f000-4668-91f2-45274c453122") == (
        "Шаболовка ул. 23",
        "24976",
    )


@patch("approval.work_layers.connections")
def test_lookup_task_poly_meta_yardpoly_is_dt(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    cursor.fetchone.side_effect = [
        (1,),  # YardPoly TaskGUID
        (1,),  # YardPoly Name
        ("Шаболовка ул. 23",),
    ]

    meta = lookup_task_poly_meta("23f956bf-f000-4668-91f2-45274c453122")
    assert meta == {
        "source_label": "ДТ",
        "object_name": "Шаболовка ул. 23",
        "table": "YardPoly",
    }


@patch("approval.work_layers.connections")
def test_lookup_task_poly_meta_improvement_object_is_top(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    # YardPoly / OdhPoly / OznPoly: columns exist, no row; ImprovementObjectPoly hits.
    cursor.fetchone.side_effect = [
        (1,),
        (1,),
        None,  # YardPoly SELECT
        (1,),
        (1,),
        None,  # OdhPoly SELECT
        (1,),
        (1,),
        None,  # OznPoly SELECT
        (1,),
        (1,),
        ("Сквер у метро",),  # ImprovementObjectPoly SELECT
    ]

    meta = lookup_task_poly_meta("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
    assert meta == {
        "source_label": "ТОП",
        "object_name": "Сквер у метро",
        "table": "ImprovementObjectPoly",
    }
    select_sqls = [
        call_args[0][0]
        for call_args in cursor.execute.call_args_list
        if "SELECT t." in call_args[0][0] and "PassBrId" not in call_args[0][0]
    ]
    assert any('"ImprovementObjectPoly"' in sql for sql in select_sqls)


@patch("approval.work_layers.connections")
def test_lookup_task_poly_meta_empty_guid(mock_connections):
    assert lookup_task_poly_meta("") == {
        "source_label": "",
        "object_name": "",
        "table": "",
    }
    mock_connections.__getitem__.assert_not_called()


@patch("approval.work_layers.connections")
def test_batch_lookup_task_poly_meta_assigns_first_table(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    guid_dt = "11111111-1111-1111-1111-111111111111"
    guid_odh = "22222222-2222-2222-2222-222222222222"

    cursor.fetchone.side_effect = [
        (1,),
        (1,),  # YardPoly columns
        (1,),
        (1,),  # OdhPoly columns
    ]
    cursor.fetchall.side_effect = [
        [(guid_dt, "ДТ объект")],  # YardPoly ANY
        [(guid_odh, "ОДХ объект")],  # OdhPoly ANY
    ]

    metas = batch_lookup_task_poly_meta([guid_dt, guid_odh, guid_dt])
    assert metas[guid_dt] == {
        "source_label": "ДТ",
        "object_name": "ДТ объект",
        "table": "YardPoly",
    }
    assert metas[guid_odh] == {
        "source_label": "ОДХ",
        "object_name": "ОДХ объект",
        "table": "OdhPoly",
    }
    assert batch_lookup_task_poly_meta([]) == {}


@patch("approval.work_adjacent.connections")
def test_resolve_root_object_names_batch_and_fallback_schema(mock_connections):
    from approval.work_adjacent import resolve_root_object_names

    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    # work/YardPoly finds first root; master/YardPoly finds second.
    cursor.fetchall.side_effect = [
        [("930062866", "ул. Шаболовка, вл. 19А")],  # work YardPoly
        [],  # work OdhPoly
        [],  # work OznPoly
        [("10001260", "Павла Андреева ул. 28")],  # master YardPoly
    ]

    with patch("approval.work_adjacent.adjacent_poly_tables", return_value=["YardPoly", "OdhPoly", "OznPoly"]):
        with patch("approval.work_adjacent.adjacent_primary_schema_name", return_value="work"):
            with patch("approval.work_adjacent.adjacent_schema_name", return_value="master"):
                with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
                    with patch("approval.work_adjacent._column_exists", return_value=True):
                        names = resolve_root_object_names(["930062866", "10001260"])

    assert names == {
        "930062866": "ул. Шаболовка, вл. 19А",
        "10001260": "Павла Андреева ул. 28",
    }
    assert resolve_root_object_names([]) == {}
    assert resolve_root_object_names(None) == {}


@pytest.mark.django_db
def test_landing_passes_resolved_page_title():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("956c45bb-dc44-46a7-9944-9d1996fec147")
    ExternalUser.objects.create(login="title_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(incoming_guid=incoming_guid, owners=[owner_id])
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    expected = "Согласование границ ОГХ Павла Андреева ул. 28 к.6, 28 к.7 по заявке 46998."

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                with patch("approval.views.collect_adjacent_roots", return_value=([], [])):
                    with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                        with patch("approval.views.load_svg_index", return_value={}):
                            with patch(
                                "approval.views.resolve_task_survey_title",
                                return_value=expected,
                            ) as mock_title:
                                with patch(
                                    "approval.views.render",
                                    return_value=HttpResponse("ok"),
                                ) as mock_render:
                                    request = RequestFactory().get(
                                        f"/approval/?approve={approve.id}"
                                    )
                                    request.user = MagicMock(
                                        is_authenticated=True, username="title_user"
                                    )
                                    response = landing(request)

    assert response.status_code == 200
    mock_title.assert_called_once_with(incoming_guid)
    context = mock_render.call_args[0][2]
    assert context["page_title"] == expected

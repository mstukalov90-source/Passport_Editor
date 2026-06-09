"""Tests for adjacent DT passport spatial SQL (within-radius logic)."""

from pass_viewer.views import (
    MAP_DEFERRED_LAYER_KEYS,
    _adjacent_layers_for_json_response,
    _build_map_adjacent_dt_combined_sql,
    _build_map_request_layer_branch,
    _build_map_requests_sql,
    _build_map_requests_sql_for_source,
    _build_new_object_request_layer_branch,
    _build_new_object_request_objects_sql,
    _defer_map_context_layers,
    _geojson_layer_for_response,
    _get_signal_tape_layer_geojson,
    _signal_tape_layer_tuning,
    _sql_reference_layer_proximity_where,
    _sql_signal_tape_simplified_geom_expr,
    _sql_within_meters_where,
)
from pass_viewer.page_config import map_deferred_layer_specs


def _sample_request_source():
    return {
        "table": "pass_objects",
        "geom": "geom",
        "rootid": "rootid",
        "name": "name",
        "request_id": "request_id",
        "source_label": "ДТ",
        "hood_ha": "",
        "meta": "NULL::text AS startdate, NULL::text AS datesurvey, NULL::text AS createtype",
        "owner_select": "NULL::text AS owner_legal_person_id",
        "owner_name_select": "NULL::text AS owner_legal_person_name",
        "customer_select": "NULL::text AS customer_legal_person_id",
        "department_select": "NULL::text AS department_legal_person_id",
        "customer_name_select": "NULL::text AS customer_legal_person_name",
        "department_name_select": "NULL::text AS department_legal_person_name",
    }


def test_within_meters_where_uses_dwithin_only():
    sql = _sql_within_meters_where("t.geom", "i.geom", "25")
    assert "ST_DWithin" in sql
    assert "&&" in sql
    assert "ST_Intersects" not in sql
    assert "ST_Touches" not in sql
    assert "ST_Boundary" not in sql


def test_map_request_layer_branch_uses_within_meters():
    sql = _build_map_request_layer_branch(_sample_request_source(), "", nearby_meters=25)
    assert "ST_DWithin" in sql
    assert "NOT ST_Intersects" not in sql
    assert "NOT ST_Touches" not in sql


def test_map_requests_sql_has_single_rel_cte():
    sql, _ = _build_map_requests_sql(
        "WITH selected AS (SELECT geom FROM pass_objects LIMIT 1), ",
        [_sample_request_source()],
        "",
        "pass_objects",
    )
    assert "tg AS (" not in sql
    assert "ix AS (" not in sql
    assert "nr AS (" not in sql
    assert "rel AS (" in sql


def test_new_object_request_layer_branch_uses_within_meters():
    sql = _build_new_object_request_layer_branch(_sample_request_source(), nearby_meters=25)
    assert "ST_DWithin" in sql
    assert "NOT ST_Intersects" not in sql


def test_new_object_request_objects_sql_has_single_rel_cte():
    sql = _build_new_object_request_objects_sql("WITH ", [_sample_request_source()])
    assert "tg AS (" not in sql
    assert "ix AS (" not in sql
    assert "nr AS (" not in sql
    assert "rel AS (" in sql


def test_map_adjacent_dt_combined_sql_uses_single_within_branch():
    sql = _build_map_adjacent_dt_combined_sql(
        "WITH selected AS (SELECT geom FROM pass_objects LIMIT 1), ",
        "pass_objects",
        "geom",
        "rootid",
        "name",
        "request_id",
        "NULL::text AS customer_legal_person_id",
        "NULL::text AS department_legal_person_id",
        "NULL::text AS owner_legal_person_id",
        "NULL::text AS customer_legal_person_name",
        "NULL::text AS department_legal_person_name",
        "NULL::text AS owner_legal_person_name",
        "NULL::text AS startdate, NULL::text AS datesurvey, NULL::text AS createtype",
        "NULL::text",
        "NULL::text",
        "NULL::text",
        "NULL::text",
        "NULL::text",
        "NULL::text",
        "t.ctid <> s.ctid AND ",
        25,
        "",
        "",
    )
    assert "UNION ALL" not in sql
    assert "ST_DWithin" in sql
    assert "NOT ST_Touches" not in sql
    assert "NOT ST_Intersects" not in sql


def test_defer_map_context_layers_defaults_to_true():
    assert _defer_map_context_layers() is True


def test_geojson_layer_for_response_parses_text():
    parsed = _geojson_layer_for_response('{"type":"FeatureCollection","features":[]}')
    assert parsed == {"type": "FeatureCollection", "features": []}


def test_geojson_layer_for_response_keeps_dict():
    value = {"type": "FeatureCollection", "features": []}
    assert _geojson_layer_for_response(value) is value


def test_map_requests_sql_for_source_targets_single_table():
    sql, params = _build_map_requests_sql_for_source(
        "WITH selected AS (SELECT geom FROM pass_objects LIMIT 1), ",
        _sample_request_source(),
        "",
        "pass_objects",
    )
    assert "pass_objects" in sql and "selected s" in sql
    assert params == ["pass_objects", "pass_objects"]


def test_map_deferred_layer_specs_match_allowed_keys():
    spec_keys = {item["key"] for item in map_deferred_layer_specs()}
    assert spec_keys == set(MAP_DEFERRED_LAYER_KEYS)


def test_adjacent_layers_for_json_response_parses_all_keys():
    layers = _adjacent_layers_for_json_response(
        {
            "intersects": '{"type":"FeatureCollection","features":[]}',
            "touches": None,
            "nearby": None,
            "request_objects": None,
        }
    )
    assert layers["intersects"]["type"] == "FeatureCollection"
    assert layers["touches"] is None


def test_reference_layer_proximity_where_delegates_to_within_meters():
    sql = _sql_reference_layer_proximity_where("t.geom", "t.geom")
    assert "ST_DWithin" in sql
    assert "ST_Intersects" not in sql


def test_signal_tape_layer_without_geometry_returns_empty_collection():
    payload = _get_signal_tape_layer_geojson("oozt", "ООЗТ", geometry=None)
    assert '"features":[]' in payload


def test_rzd_signal_tape_tuning_is_more_aggressive_than_oozt():
    rzd = _signal_tape_layer_tuning("РЖД")
    oozt = _signal_tape_layer_tuning("ООЗТ")
    assert rzd["simplify_meters"] > oozt["simplify_meters"]
    assert rzd["geojson_decimals"] <= oozt["geojson_decimals"]


def test_signal_tape_simplify_uses_web_mercator():
    sql = _sql_signal_tape_simplified_geom_expr("clip.clipped", 5.0)
    assert "ST_SimplifyPreserveTopology" in sql
    assert "3857" in sql

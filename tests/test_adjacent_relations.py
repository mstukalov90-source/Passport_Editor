"""Tests for adjacent DT passport spatial SQL (touches optimization)."""

from pass_viewer.views import (
    _build_map_adjacent_dt_combined_sql,
    _build_map_request_layer_branch,
    _build_map_requests_sql,
    _build_new_object_request_layer_branch,
    _build_new_object_request_objects_sql,
    _defer_map_context_layers,
)


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


def test_map_request_nearby_branch_excludes_touches_but_not_intersects_only():
    sql = _build_map_request_layer_branch("nr", _sample_request_source(), "", nearby_meters=100)
    assert "ST_DWithin" in sql
    assert "NOT ST_Intersects" in sql
    assert "ST_Touches" not in sql


def test_map_request_intersects_branch_keeps_not_touches():
    sql = _build_map_request_layer_branch("ix", _sample_request_source(), "", nearby_meters=100)
    assert "ST_Intersects" in sql
    assert "NOT ST_Touches" in sql


def test_map_requests_sql_has_no_tg_cte():
    sql, _ = _build_map_requests_sql(
        "WITH selected AS (SELECT geom FROM pass_objects LIMIT 1), ",
        [_sample_request_source()],
        "",
        "pass_objects",
    )
    assert "tg AS (" not in sql
    assert "FROM tg" not in sql
    assert "ix AS (" in sql
    assert "nr AS (" in sql


def test_new_object_request_nearby_branch_excludes_touches():
    sql = _build_new_object_request_layer_branch("nr", _sample_request_source(), nearby_meters=50)
    assert "ST_DWithin" in sql
    assert "NOT ST_Intersects" in sql
    assert "ST_Touches" not in sql


def test_new_object_request_objects_sql_has_no_tg_cte():
    sql = _build_new_object_request_objects_sql("WITH ", [_sample_request_source()])
    assert "tg AS (" not in sql
    assert "FROM tg" not in sql


def test_map_adjacent_dt_combined_sql_uses_union_all_and_bbox_prefilter():
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
        100,
        "",
        "",
    )
    assert "UNION ALL" in sql
    assert "&& s.geom" in sql
    assert "ST_DWithin" in sql
    assert "NOT ST_Touches" in sql
    nearby_part = sql.split("UNION ALL", 1)[1]
    assert "ST_Touches" not in nearby_part


def test_defer_map_context_layers_defaults_to_true():
    assert _defer_map_context_layers() is True

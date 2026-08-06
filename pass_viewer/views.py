import json
import logging
import re
import uuid
import zipfile
from datetime import timedelta
from pathlib import Path

from approval.access import get_accessible_approves
from approval.events_service import build_home_notification_events, serialize_approve_options
from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.db import connection, connections
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from django.views.decorators.http import require_GET, require_POST
from osgeo import gdal, ogr, osr

from .dgi_layers import (
    DGI_LAYER_KEYS,
    DGI_LAYER_SPECS,
    build_dgi_ownership_extra_sql,
    build_dgi_rent_extra_sql,
    finalize_dgi_aprove_record,
    normalize_dgi_aprove_payload,
)
from .forms import EntryPointForm
from .hood_scope import (
    geometry_intersects_allowed_hood,
    get_hood_allowed_districts_geojson,
    get_hood_cte_prefix_sql,
    get_hood_intersects_ha_sql,
    get_hood_intersects_sql_suffix,
    list_hood_districts,
    resolve_and_bind_hood_scope,
    resolve_hood_wkt_for_gid,
)
from .models import ExternalUser
from .page_config import (
    add_object_page_config,
    add_recap_page_config,
    home_page_config,
    main_page_config,
    split_object_page_config,
)
from .roles import (
    FILTER_DEPARTMENT,
    FILTER_NONE,
    FILTER_OWNER,
    FILTER_OWNER_MULTI,
    ROLE_DEP_PLUS,
    ROLE_MGGT,
    ROLE_SUP,
    SUP_HOOD_SESSION_GID,
    SUP_HOOD_SESSION_LABEL,
    resolve_user_scope,
)
from .user_guide import load_user_guide_html

logger = logging.getLogger(__name__)


def _hood_strip_with_keyword(hood_full_prefix: str) -> str:
    """``WITH ha AS (...), `` → ``ha AS (...), `` для склейки после ``WITH ``."""
    if not hood_full_prefix:
        return ""
    if hood_full_prefix.upper().startswith("WITH "):
        return hood_full_prefix[5:]
    return hood_full_prefix


gdal.UseExceptions()


def _sql_geojson_param_as_valid_geom2d(placeholder: str = "%s") -> str:
    """
    GeoJSON text (%s) → валидная 2D-геометрия для предикатов PostGIS/GEOS.
    Иначе при самопересечениях / «бантиках» после редактирования возможен
    TopologyException: side location conflict в ST_Intersects и т.п.
    """
    return f"ST_UnaryUnion(ST_MakeValid(ST_SetSRID(ST_GeomFromGeoJSON({placeholder}), 4326)))"


_MULTIPOLYGON_SAVE_AREA_MIN_M2 = 1.0
_MULTIPOLYGON_SAVE_ERROR = (
    "Для сохранения в ДТ/ОДХ нужен полигон с ненулевой площадью. "
    "Проверьте контур: минимум 3 различные вершины, без схлопнутых линий."
)


def _sql_geojson_param_as_multipolygon2d(placeholder: str = "%s") -> str:
    """GeoJSON → MultiPolygon для колонок geometry(MultiPolygon, 4326)."""
    inner = _sql_geojson_param_as_valid_geom2d(placeholder)
    return f"ST_Multi(ST_CollectionExtract({inner}, 3))"


def _top_source_label():
    return getattr(settings, "GIS_TOP_SOURCE_LABEL", "ТОП")


def _gis_municipal_table_specs():
    owner_dt = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    odh_customer = getattr(settings, "GIS_ODH_CUSTOMER_FIELD", "CustomerLegalPersonId")
    ozn_owner = getattr(settings, "GIS_OZN_OWNER_FIELD", "ownerlegalpersonalid")
    top_label = _top_source_label()
    return [
        ("ДТ", settings.GIS_OBJECT_TABLE, [owner_dt]),
        ("ОДХ", getattr(settings, "GIS_ODH_TABLE", "odh"), [odh_customer, owner_dt]),
        ("ОЗН", getattr(settings, "GIS_OZN_TABLE", "ozn"), [ozn_owner, owner_dt]),
        (top_label, getattr(settings, "GIS_TOP_TABLE", "top"), [owner_dt]),
    ]


def _owner_field_pref_for_source(normalized_source):
    if normalized_source == "ОДХ":
        return getattr(settings, "GIS_ODH_CUSTOMER_FIELD", "CustomerLegalPersonId")
    if normalized_source == "ОЗН":
        return getattr(settings, "GIS_OZN_OWNER_FIELD", "ownerlegalpersonalid")
    return getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")


def _table_requires_multipolygon_geom(table_name: str) -> bool:
    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, "GIS_ODH_TABLE", "odh")
    top_table = getattr(settings, "GIS_TOP_TABLE", "top")
    return table_name in (dt_table, odh_table, top_table)


def _geojson_geom_sql_for_table(table_name: str) -> str:
    if _table_requires_multipolygon_geom(table_name):
        return _sql_geojson_param_as_multipolygon2d()
    return _sql_geojson_param_as_valid_geom2d()


def _validate_multipolygon_geometry_for_storage(cursor, geometry_json: str) -> None:
    """Проверка перед INSERT/UPDATE в pass_objects / odh (колонка MultiPolygon)."""
    cursor.execute(
        f"""
        WITH g AS (
            SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom
        )
        SELECT
            ST_GeometryType(geom) AS gt,
            COALESCE(ST_IsEmpty(geom), TRUE) AS is_empty,
            COALESCE(ST_Area(geom::geography), 0) AS area_m2
        FROM g
        """,
        [geometry_json],
    )
    row = cursor.fetchone()
    if not row:
        raise ValueError(_MULTIPOLYGON_SAVE_ERROR)
    gt, is_empty, area_m2 = row[0], bool(row[1]), float(row[2] or 0)
    if gt not in ("ST_Polygon", "ST_MultiPolygon") or is_empty or area_m2 < _MULTIPOLYGON_SAVE_AREA_MIN_M2:
        raise ValueError(_MULTIPOLYGON_SAVE_ERROR)


_MULTIPOLYGON_ISSUE_MESSAGES = {
    "line_or_point": (
        "Контур превратился в линию или точку — автоматически не исправить. "
        "Дорисуйте полигон на карте (минимум 3 разные вершины)."
    ),
    "zero_area": "Площадь полигона слишком мала — увеличьте контур на карте.",
    "too_few_vertices": "Недостаточно вершин — добавьте точки, чтобы получился замкнутый полигон.",
    "self_intersection": "Обнаружено самопересечение контура.",
}


def _sql_repair_multipolygon_from_geojson(placeholder: str = "%s", buffer_amount=None) -> str:
    raw = f"ST_SetSRID(ST_GeomFromGeoJSON({placeholder}), 4326)"
    if buffer_amount is not None:
        raw = f"ST_Buffer({raw}, {buffer_amount})"
    inner = f"ST_UnaryUnion(ST_MakeValid({raw}))"
    return f"ST_Multi(ST_CollectionExtract({inner}, 3))"


def _diagnose_multipolygon_geometry(cursor, geometry_json: str) -> list:
    issues = []
    cursor.execute(
        "SELECT NOT ST_IsValid(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))",
        [geometry_json],
    )
    if cursor.fetchone()[0]:
        issues.append("self_intersection")

    cursor.execute(
        f"""
        WITH g AS (
            SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom
        )
        SELECT
            ST_GeometryType(geom) AS gt,
            COALESCE(ST_IsEmpty(geom), TRUE) AS is_empty,
            COALESCE(ST_Area(geom::geography), 0) AS area_m2,
            COALESCE(ST_NPoints(geom), 0) AS npoints
        FROM g
        """,
        [geometry_json],
    )
    row = cursor.fetchone()
    if not row:
        return issues or ["zero_area"]
    gt, is_empty, area_m2, npoints = row[0], bool(row[1]), float(row[2] or 0), int(row[3] or 0)
    if gt in ("ST_LineString", "ST_MultiLineString", "ST_Point", "ST_MultiPoint"):
        if "line_or_point" not in issues:
            issues.append("line_or_point")
    if is_empty or area_m2 < _MULTIPOLYGON_SAVE_AREA_MIN_M2:
        if "zero_area" not in issues:
            issues.append("zero_area")
    if npoints < 4:
        if "too_few_vertices" not in issues:
            issues.append("too_few_vertices")
    return issues


def _validate_repaired_multipolygon_sql(cursor, repair_sql: str, geometry_json: str) -> None:
    cursor.execute(
        f"""
        WITH g AS (
            SELECT {repair_sql} AS geom
        )
        SELECT
            ST_GeometryType(geom) AS gt,
            COALESCE(ST_IsEmpty(geom), TRUE) AS is_empty,
            COALESCE(ST_Area(geom::geography), 0) AS area_m2
        FROM g
        """,
        [geometry_json],
    )
    row = cursor.fetchone()
    if not row:
        raise ValueError(_MULTIPOLYGON_SAVE_ERROR)
    gt, is_empty, area_m2 = row[0], bool(row[1]), float(row[2] or 0)
    if gt not in ("ST_Polygon", "ST_MultiPolygon") or is_empty or area_m2 < _MULTIPOLYGON_SAVE_AREA_MIN_M2:
        raise ValueError(_MULTIPOLYGON_SAVE_ERROR)


def _repair_error_message_for_issues(issues: list) -> str:
    for key in ("line_or_point", "too_few_vertices", "zero_area", "self_intersection"):
        if key in issues:
            return _MULTIPOLYGON_ISSUE_MESSAGES[key]
    return _MULTIPOLYGON_SAVE_ERROR


def _repair_multipolygon_geometry_json(cursor, geometry_json: str) -> dict:
    issues_before = _diagnose_multipolygon_geometry(cursor, geometry_json)
    repair_steps = [
        _sql_repair_multipolygon_from_geojson(),
        _sql_repair_multipolygon_from_geojson(buffer_amount="0"),
        _sql_repair_multipolygon_from_geojson(buffer_amount="0.00001"),
    ]
    for repair_sql in repair_steps:
        try:
            _validate_repaired_multipolygon_sql(cursor, repair_sql, geometry_json)
        except ValueError:
            continue
        cursor.execute(
            f"""
            WITH repaired AS (
                SELECT {repair_sql} AS geom
            )
            SELECT ST_AsGeoJSON(geom)::json AS geometry
            FROM repaired
            """,
            [geometry_json],
        )
        row = cursor.fetchone()
        if not row or not row[0]:
            continue
        geometry = row[0]
        if isinstance(geometry, str):
            geometry = json.loads(geometry)
        return {
            "geometry": geometry,
            "issues_before": issues_before,
            "fixed": True,
        }
    issues_after = _diagnose_multipolygon_geometry(cursor, geometry_json)
    return {
        "geometry": None,
        "issues_before": issues_before,
        "issues": issues_after or issues_before,
        "fixed": False,
    }


def _sql_table_geom_valid_expr(qualified_geom_expr: str) -> str:
    """ST_MakeValid только для невалидных строк; иначе сырая геометрия (без раздувания)."""
    return (
        f"CASE WHEN ST_IsValid({qualified_geom_expr}) "
        f"THEN {qualified_geom_expr} "
        f"ELSE ST_MakeValid({qualified_geom_expr}) END"
    )


def _sql_table_geom_drawable_clause(qualified_geom_expr: str) -> str:
    """SQL `` AND ...`` — только строки с непустой геометрией (для reference GeoJSON)."""
    return (
        f" AND {qualified_geom_expr} IS NOT NULL"
        f" AND NOT ST_IsEmpty({qualified_geom_expr})"
    )


def _quote_ident(identifier):
    return '"' + str(identifier).replace('"', '""') + '"'


def _resolve_column_name(cursor, table_name, preferred_name):
    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [table_name, preferred_name],
    )
    row = cursor.fetchone()
    return row[0] if row else preferred_name


def _column_exists(cursor, table_name, column_name):
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [table_name, column_name],
    )
    return cursor.fetchone() is not None


def _optional_column_text_sql(cursor, table_name, name_candidates):
    for preferred in name_candidates:
        if not _column_exists(cursor, table_name, preferred):
            continue
        resolved = _resolve_column_name(cursor, table_name, preferred)
        return f"{_quote_ident(resolved)}::text"
    return "NULL::text"


def _gis_object_meta_sql_fragment(cursor, table_name, table_alias=None):
    """
    SQL fragment: expr AS startdate, expr AS datesurvey, expr AS createtype
    for pass_objects / odh / ozn (optional columns).
    """
    prefix = f"{table_alias}." if table_alias else ""
    parts = []
    for candidates, out_alias in (
        (("startdate", "StartDate"), "startdate"),
        (("datesurvey", "DateSurvey"), "datesurvey"),
        (("createtype", "CreateType"), "createtype"),
    ):
        expr = "NULL::text"
        for preferred in candidates:
            if not _column_exists(cursor, table_name, preferred):
                continue
            resolved = _resolve_column_name(cursor, table_name, preferred)
            expr = f"{prefix}{_quote_ident(resolved)}::text"
            break
        parts.append(f"{expr} AS {out_alias}")
    return ", ".join(parts)


def _table_exists(cursor, table_name):
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = %s
        LIMIT 1
        """,
        [table_name],
    )
    return cursor.fetchone() is not None


def _request_layer_source_ready(cursor, table_name, geom_field, request_id_field):
    return (
        _table_exists(cursor, table_name)
        and _column_exists(cursor, table_name, geom_field)
        and _column_exists(cursor, table_name, request_id_field)
    )


def _adjacent_nearby_meters():
    try:
        return float(getattr(settings, "GIS_ADJACENT_NEARBY_METERS", 25))
    except (TypeError, ValueError):
        return 25.0


def _defer_map_context_layers():
    return str(getattr(settings, "GIS_DEFER_MAP_CONTEXT_LAYERS", "1")).lower() not in (
        "0",
        "false",
        "no",
    )


def _geojson_layer_for_response(value):
    if value is None:
        return None
    if isinstance(value, dict):
        return value
    if isinstance(value, str):
        text = value.strip()
        if not text or text.lower() == "null":
            return None
        try:
            parsed = json.loads(text)
        except json.JSONDecodeError:
            logger.warning("GeoJSON layer text is not valid JSON")
            return None
        return parsed if isinstance(parsed, dict) else None
    return None


def _adjacent_layers_for_json_response(layers):
    if not layers:
        return {}
    return {
        "intersects": _geojson_layer_for_response(layers.get("intersects")),
        "touches": _geojson_layer_for_response(layers.get("touches")),
        "nearby": _geojson_layer_for_response(layers.get("nearby")),
        "request_objects": _geojson_layer_for_response(layers.get("request_objects")),
    }


def _reference_layers_for_json_response(reference_layers):
    if not reference_layers:
        return {}
    return {
        key: _geojson_layer_for_response(value) for key, value in reference_layers.items()
    }


def _relation_layers_for_json_response(layers):
    if not layers:
        return {}
    return {key: _geojson_layer_for_response(value) for key, value in layers.items()}


def _build_map_adjacent_dt_combined_sql(
    map_layers_cte_open,
    dt_table,
    adjacent_geom_field,
    adjacent_rootid_field,
    adjacent_name_field,
    adjacent_request_id_field,
    adjacent_customer_select_expr,
    adjacent_department_select_expr,
    adjacent_owner_select_expr,
    adjacent_customer_name_select_expr,
    adjacent_department_name_select_expr,
    adjacent_owner_name_select_expr,
    gis_meta_dt_fragment,
    adjacent_customer_prop_expr,
    adjacent_department_prop_expr,
    adjacent_owner_prop_expr,
    adjacent_customer_name_prop_expr,
    adjacent_department_name_prop_expr,
    adjacent_owner_name_prop_expr,
    neighbor_excl,
    nearby_meters,
    passport_only_dt_sql,
    hood_ha_adj,
):
    geom_q = _quote_ident(adjacent_geom_field)
    geom_ref = f"t.{geom_q}"
    select_core = (
        f" SELECT {geom_ref} AS geom, t.{_quote_ident(adjacent_rootid_field)} AS rootid,"
        f" t.{_quote_ident(adjacent_name_field)} AS name, t.{_quote_ident(adjacent_request_id_field)} AS request_id,"
        f" {adjacent_customer_select_expr}, {adjacent_department_select_expr}, {adjacent_owner_select_expr},"
        f" {adjacent_customer_name_select_expr}, {adjacent_department_name_select_expr},"
        f" {adjacent_owner_name_select_expr}, {gis_meta_dt_fragment}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
    )
    proximity_branch = (
        select_core
        + f" WHERE {neighbor_excl}"
        + _sql_within_meters_where(geom_ref, "s.geom", str(nearby_meters))
        + f"{passport_only_dt_sql}{hood_ha_adj}"
    )
    return (
        map_layers_cte_open
        + "rel AS ("
        + proximity_branch
        + ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object("
        "       'rootid', rootid::text,"
        "       'name', name::text,"
        "       'request_id', request_id::text,"
        f"      'customer_legal_person_id', {adjacent_customer_prop_expr},"
        f"      'department_legal_person_id', {adjacent_department_prop_expr},"
        f"      'owner_legal_person_id', {adjacent_owner_prop_expr},"
        f"      'customer_legal_person_name', {adjacent_customer_name_prop_expr},"
        f"      'department_legal_person_name', {adjacent_department_name_prop_expr},"
        f"      'owner_legal_person_name', {adjacent_owner_name_prop_expr},"
        "       'startdate', startdate::text,"
        "       'datesurvey', datesurvey::text,"
        "       'createtype', createtype::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )


def _sql_gis_passport_only_clause(cursor, table_name, table_alias="t"):
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    if not _column_exists(cursor, table_name, request_id_field_pref):
        return ""
    request_id_col = _resolve_column_name(cursor, table_name, request_id_field_pref)
    col_ref = f"{table_alias}.{_quote_ident(request_id_col)}"
    return f" AND ({col_ref} IS NULL OR BTRIM({col_ref}::text) = '')"


def _sql_gis_request_only_clause(cursor, table_name, table_alias="t"):
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    if not _column_exists(cursor, table_name, request_id_field_pref):
        return ""
    request_id_col = _resolve_column_name(cursor, table_name, request_id_field_pref)
    col_ref = f"{table_alias}.{_quote_ident(request_id_col)}"
    return f" AND {col_ref} IS NOT NULL AND BTRIM({col_ref}::text) <> ''"


def _sql_source_label_literal(source_label):
    escaped = str(source_label or "").replace("'", "''")
    return f"'{escaped}'::text AS source_label"


def _resolve_request_layer_columns(cursor, table_name, geom_field, rootid_field, name_field, request_id_field):
    if not _request_layer_source_ready(cursor, table_name, geom_field, request_id_field):
        return None
    resolved = {
        "geom": _resolve_column_name(cursor, table_name, geom_field),
        "request_id": _resolve_column_name(cursor, table_name, request_id_field),
    }
    if _column_exists(cursor, table_name, rootid_field):
        resolved["rootid"] = _resolve_column_name(cursor, table_name, rootid_field)
    if _column_exists(cursor, table_name, name_field):
        resolved["name"] = _resolve_column_name(cursor, table_name, name_field)
    return resolved


def _request_layer_col_ref(columns, key):
    if columns.get(key):
        return f"t.{_quote_ident(columns[key])}::text"
    return "NULL::text"


def _request_layer_request_id_refs(source):
    request_id_col = f"t.{_quote_ident(source['request_id'])}"
    return request_id_col, f"{request_id_col}::text"


def _build_map_request_layer_branch(source, req_self_excl_sql, nearby_meters=None):
    if nearby_meters is None:
        nearby_meters = _adjacent_nearby_meters()
    geom_ref = f"t.{_quote_ident(source['geom'])}"
    rootid_ref = _request_layer_col_ref(source, "rootid")
    name_ref = _request_layer_col_ref(source, "name")
    request_id_where, request_id_select = _request_layer_request_id_refs(source)
    source_label_sql = _sql_source_label_literal(source.get("source_label") or "")
    select_sql = (
        f" SELECT t.ctid::text AS row_tid, {geom_ref} AS geom, {rootid_ref} AS rootid, {name_ref} AS name,"
        f" {request_id_select} AS request_id, {source_label_sql}, {source['owner_select']}, {source['owner_name_select']},"
        f" {source['customer_select']}, {source['department_select']},"
        f" {source['customer_name_select']}, {source['department_name_select']}, {source['meta']}"
        f" FROM {_quote_ident(source['table'])} t, selected s"
    )
    where_sql = (
        " WHERE"
        + _sql_within_meters_where(geom_ref, "s.geom", str(nearby_meters))
        + f"   AND {request_id_where} IS NOT NULL"
    )
    return select_sql + where_sql + source["hood_ha"] + req_self_excl_sql


def _build_new_object_request_layer_branch(source, nearby_meters=None):
    if nearby_meters is None:
        nearby_meters = _adjacent_nearby_meters()
    geom_ref = f"t.{_quote_ident(source['geom'])}"
    rootid_ref = _request_layer_col_ref(source, "rootid")
    name_ref = _request_layer_col_ref(source, "name")
    request_id_where, request_id_select = _request_layer_request_id_refs(source)
    input_excl_sql = (
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals({geom_ref}, p.geom)"
        "   )"
    )
    source_label_sql = _sql_source_label_literal(source.get("source_label") or "")
    select_sql = (
        f" SELECT t.ctid::text AS row_tid, {geom_ref} AS geom, {rootid_ref} AS rootid, {name_ref} AS name,"
        f" {request_id_select} AS request_id, {source_label_sql}, {source['owner_select']}, {source['owner_name_select']},"
        f" {source['customer_select']}, {source['department_select']},"
        f" {source['customer_name_select']}, {source['department_name_select']}, {source['meta']}"
        f" FROM {_quote_ident(source['table'])} t, input i"
    )
    where_sql = (
        " WHERE"
        + _sql_within_meters_where(geom_ref, "i.geom", str(nearby_meters))
        + f"{input_excl_sql}"
        + f"   AND {request_id_where} IS NOT NULL"
    )
    return select_sql + where_sql + source["hood_ha"]


def _union_request_layer_branches(branches):
    if not branches:
        return " SELECT NULL::text AS row_tid, NULL::geometry AS geom, NULL::text AS rootid, NULL::text AS name,"
        " NULL::text AS request_id, NULL::text AS source_label, NULL::text AS owner_legal_person_id, NULL::text AS owner_legal_person_name,"
        " NULL::text AS customer_legal_person_id, NULL::text AS department_legal_person_id,"
        " NULL::text AS customer_legal_person_name, NULL::text AS department_legal_person_name,"
        " NULL::text AS startdate, NULL::text AS datesurvey, NULL::text AS createtype"
        " WHERE FALSE"
    return " UNION ALL ".join(branches)


def _build_map_requests_sql(map_layers_cte_open, request_sources, req_self_excl_sql, source_table):
    req_self_excl_params = []
    branches = []
    for src in request_sources:
        branches.append(_build_map_request_layer_branch(src, req_self_excl_sql))
        req_self_excl_params.extend([source_table, src["table"]])

    return (
        map_layers_cte_open
        + "rel AS ("
        + _union_request_layer_branches(branches)
        + ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object("
        "       'source', source_label::text,"
        "       'rootid', rootid::text,"
        "       'name', name::text,"
        "       'request_id', request_id::text,"
        "      'owner_legal_person_id', owner_legal_person_id::text,"
        "      'owner_legal_person_name', owner_legal_person_name::text,"
        "      'customer_legal_person_id', customer_legal_person_id::text,"
        "      'department_legal_person_id', department_legal_person_id::text,"
        "      'customer_legal_person_name', customer_legal_person_name::text,"
        "      'department_legal_person_name', department_legal_person_name::text,"
        "      'startdate', startdate::text,"
        "      'datesurvey', datesurvey::text,"
        "      'createtype', createtype::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    ), req_self_excl_params


def _build_map_requests_sql_for_source(map_layers_cte_open, source, req_self_excl_sql, source_table):
    req_self_excl_params = [source_table, source["table"]]
    body = _build_map_request_layer_branch(source, req_self_excl_sql)
    return (
        map_layers_cte_open
        + "rel AS ("
        + body
        + ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object("
        "       'source', source_label::text,"
        "       'rootid', rootid::text,"
        "       'name', name::text,"
        "       'request_id', request_id::text,"
        "      'owner_legal_person_id', owner_legal_person_id::text,"
        "      'owner_legal_person_name', owner_legal_person_name::text,"
        "      'customer_legal_person_id', customer_legal_person_id::text,"
        "      'department_legal_person_id', department_legal_person_id::text,"
        "      'customer_legal_person_name', customer_legal_person_name::text,"
        "      'department_legal_person_name', department_legal_person_name::text,"
        "      'startdate', startdate::text,"
        "      'datesurvey', datesurvey::text,"
        "      'createtype', createtype::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    ), req_self_excl_params


MAP_DEFERRED_LAYER_KEYS = frozenset(
    {
        "adjacent_dt",
        "request_objects_dt",
        "request_objects_odh",
        "request_objects_ozn",
        "request_objects_top",
        "dgi_moscow_rent",
        "dgi_moscow_no_rent",
        "dgi_private_rent",
        "dgi_private_no_rent",
        "odh",
        "ozn",
        "renew",
        "recaps",
        "oozt",
        "rzd",
        "top",
    }
)


def _get_single_reference_layer(layer_key, geometry, distance_meters=None, request_id_filter=None):
    if distance_meters is None:
        distance_meters = _adjacent_nearby_meters()
    dgi_table = getattr(settings, "GIS_DGI_TABLE", "dgi")
    if layer_key in DGI_LAYER_SPECS:
        with connection.cursor() as cursor:
            extra_where = _sql_dgi_layer_filter(cursor, dgi_table, layer_key)
        value = _get_reference_layer_geojson(
            dgi_table,
            "ДГИ",
            geometry=geometry,
            distance_meters=distance_meters,
            extra_where_sql=extra_where,
        )
        return {layer_key: value}
    if layer_key == "odh":
        return {
            "odh": _get_reference_layer_geojson(
                getattr(settings, "GIS_ODH_TABLE", "odh"),
                "ОДХ",
                geometry=geometry,
                distance_meters=distance_meters,
            )
        }
    if layer_key == "ozn":
        return {
            "ozn": _get_reference_layer_geojson(
                getattr(settings, "GIS_OZN_TABLE", "ozn"),
                "ОЗН",
                geometry=geometry,
                distance_meters=distance_meters,
            )
        }
    if layer_key == "renew":
        return {
            "renew": _get_reference_layer_geojson(
                getattr(settings, "GIS_RENEW_TABLE", "renew"),
                "Реновация",
                geometry=geometry,
                distance_meters=distance_meters,
            )
        }
    if layer_key == "recaps":
        return {
            "recaps": _get_recaps_layer_geojson(
                geometry=geometry,
                distance_meters=distance_meters,
                request_id_filter=request_id_filter,
            )
        }
    if layer_key == "oozt":
        return {
            "oozt": _get_signal_tape_layer_geojson(
                getattr(settings, "GIS_OOZT_TABLE", "oozt"),
                "ООЗТ",
                geometry=geometry,
                distance_meters=distance_meters,
            )
        }
    if layer_key == "rzd":
        return {
            "rzd": _get_signal_tape_layer_geojson(
                getattr(settings, "GIS_RZD_TABLE", "rzd"),
                "РЖД",
                geometry=geometry,
                distance_meters=distance_meters,
            )
        }
    if layer_key == "top":
        return {
            "top": _get_reference_layer_geojson(
                getattr(settings, "GIS_TOP_TABLE", "top"),
                _top_source_label(),
                geometry=geometry,
                distance_meters=distance_meters,
            )
        }
    return None


def _execute_map_only_layer(
    cursor,
    layer_key,
    *,
    map_layers_cte_open,
    map_exec_params,
    adjacent_dt_sql,
    request_sources_by_key,
    req_self_excl,
    source_table,
):
    if layer_key == "adjacent_dt":
        cursor.execute(adjacent_dt_sql, map_exec_params)
        row = cursor.fetchone()
        return {
            "intersects": row[0] if row else None,
            "touches": None,
            "nearby": None,
        }
    if layer_key.startswith("request_objects_"):
        source_key = layer_key.removeprefix("request_objects_")
        source = request_sources_by_key.get(source_key)
        if not source:
            return {"request_objects": None}
        requests_sql, requests_self_excl_params = _build_map_requests_sql_for_source(
            map_layers_cte_open,
            source,
            req_self_excl,
            source_table,
        )
        cursor.execute(requests_sql, map_exec_params + requests_self_excl_params)
        row = cursor.fetchone()
        return {"request_objects": row[0] if row else None}
    return None


def _build_new_object_request_objects_sql(new_obj_with_open, request_sources):
    branches = [_build_new_object_request_layer_branch(src) for src in request_sources]

    return (
        new_obj_with_open + f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        + _union_request_layer_branches(branches)
        + ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object("
        "       'source', source_label::text,"
        "       'rootid', rootid::text,"
        "       'name', name::text,"
        "       'request_id', request_id::text,"
        "      'owner_legal_person_id', owner_legal_person_id::text,"
        "      'owner_legal_person_name', owner_legal_person_name::text,"
        "      'customer_legal_person_id', customer_legal_person_id::text,"
        "      'department_legal_person_id', department_legal_person_id::text,"
        "      'customer_legal_person_name', customer_legal_person_name::text,"
        "      'department_legal_person_name', department_legal_person_name::text,"
        "      'startdate', startdate::text,"
        "      'datesurvey', datesurvey::text,"
        "      'createtype', createtype::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )


def _get_current_user_owner_id(username):
    user = ExternalUser.objects.filter(login=username).only("owner_legal_person_id").first()
    return user.owner_legal_person_id if user else None


def _load_home_objects_for_scope(scope, *, has_sup_hood: bool):
    """Return (owned_objects, ods_user_brids) for home based on user role scope."""
    ods_user_brids = []
    owned_objects = []

    if scope.role == ROLE_MGGT:
        owned_objects = _get_owned_objects(
            None,
            filter_mode=FILTER_NONE,
            site_requests_only=True,
            apply_hood=False,
            row_limit=1000,
        )
        return owned_objects, ods_user_brids

    if scope.role == ROLE_SUP:
        if not has_sup_hood:
            return [], []
        passports = _get_owned_objects(
            None,
            filter_mode=FILTER_NONE,
            passports_only=True,
            apply_hood=True,
            row_limit=500,
        )
        requests = _get_owned_objects(
            None,
            filter_mode=FILTER_NONE,
            site_requests_only=True,
            apply_hood=False,
            row_limit=1000,
        )
        owned_objects = passports + requests
        return owned_objects, ods_user_brids

    if scope.role == ROLE_DEP_PLUS:
        if not scope.owner_ids:
            return [], []
        # Multi-owner lists are much larger than a single BD; default 500/table truncates.
        owned_objects = _get_owned_objects(
            None,
            filter_mode=FILTER_OWNER_MULTI,
            legal_person_ids=list(scope.owner_ids),
            row_limit=10000,
        )
        if scope.include_ods:
            for oid in scope.owner_ids:
                ods_user_brids.extend(_get_owned_ods_brids(oid))
                owned_objects = _merge_owned_ods_requests(owned_objects, oid)
            ods_user_brids = list(dict.fromkeys(ods_user_brids))
            owned_objects = _annotate_and_filter_ods_registry_against_gis(owned_objects)
            owned_objects = _enrich_ods_interaction_and_geometry(owned_objects)
        return owned_objects, ods_user_brids

    if not scope.owner_id:
        return [], []

    filter_mode = FILTER_DEPARTMENT if scope.filter_field == FILTER_DEPARTMENT else FILTER_OWNER
    owned_objects = _get_owned_objects(scope.owner_id, filter_mode=filter_mode)
    if scope.include_ods:
        ods_user_brids = _get_owned_ods_brids(scope.owner_id)
        owned_objects = _merge_owned_ods_requests(owned_objects, scope.owner_id)
        owned_objects = _annotate_and_filter_ods_registry_against_gis(owned_objects)
        owned_objects = _enrich_ods_interaction_and_geometry(owned_objects)
    return owned_objects, ods_user_brids


def _comment_points_table_name():
    return getattr(settings, "GIS_COMMENT_POINTS_TABLE", "pass_comment_points")


def _get_id_names_lookup_context(cursor):
    table = getattr(settings, "GIS_ID_NAMES_TABLE", "id_names")
    if not _table_exists(cursor, table):
        return None

    id_candidates = [
        "OwnerLegalPersonId",
        "CustomerLegalPersonId",
        "DepartmentLegalPersonId",
        "LegalPersonId",
        "id",
    ]
    name_candidates = ["name", "Name", "title", "Title", "full_name", "short_name"]

    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = %s
        """,
        [table],
    )
    columns = {row[0] for row in cursor.fetchall()}
    lowered = {column.lower(): column for column in columns}

    id_field = None
    for candidate in id_candidates:
        key = candidate.lower()
        if key in lowered:
            id_field = lowered[key]
            break
    if not id_field:
        id_like = [column for column in columns if column.lower().endswith("id")]
        id_field = id_like[0] if id_like else None
    if not id_field:
        return None

    name_field = None
    for candidate in name_candidates:
        key = candidate.lower()
        if key in lowered:
            name_field = lowered[key]
            break
    if not name_field:
        name_like = [column for column in columns if "name" in column.lower()]
        name_field = name_like[0] if name_like else None
    if not name_field:
        return None

    return {
        "table": table,
        "id_field": id_field,
        "name_field": name_field,
    }


def _build_id_name_lookup_expr(id_value_expr, lookup_context):
    if not lookup_context:
        return "NULL::text"
    return (
        f"(SELECT n.{_quote_ident(lookup_context['name_field'])}::text "
        f"FROM {_quote_ident(lookup_context['table'])} n "
        f"WHERE n.{_quote_ident(lookup_context['id_field'])}::text = ({id_value_expr})::text "
        "LIMIT 1)"
    )


def _get_id_name_lookup_value(legal_person_id):
    if legal_person_id is None:
        return None

    with connection.cursor() as cursor:
        lookup_context = _get_id_names_lookup_context(cursor)
        if not lookup_context:
            return None

        query = (
            f"SELECT {_quote_ident(lookup_context['name_field'])}::text "
            f"FROM {_quote_ident(lookup_context['table'])} "
            f"WHERE {_quote_ident(lookup_context['id_field'])}::text = %s "
            f"LIMIT 1"
        )
        cursor.execute(query, [str(legal_person_id)])
        row = cursor.fetchone()
        return row[0] if row and row[0] else None


def _get_owned_objects(
    legal_person_id=None,
    *,
    filter_mode="owner",
    legal_person_ids=None,
    site_requests_only=False,
    passports_only=False,
    apply_hood=True,
    row_limit=500,
):
    """
    Load GIS objects for the home list.

    filter_mode:
      - ``owner``: match OwnerLegalPersonId (or source-specific owner candidates)
      - ``owner_multi``: OwnerLegalPersonId = ANY(ids)
      - ``department``: match DepartmentLegalPersonId
      - ``none``: no legal-person filter (MGGT/SUP)
    site_requests_only: rows with non-empty request_id and empty rootid (site заявки)
    passports_only: rows with non-empty rootid
    """
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    department_field_pref = getattr(settings, "GIS_OBJECT_DEPARTMENT_FIELD", "DepartmentLegalPersonId")

    multi_ids = [str(x).strip() for x in (legal_person_ids or []) if str(x).strip()]
    if filter_mode == FILTER_OWNER_MULTI:
        if not multi_ids:
            return []
    elif filter_mode in ("owner", "department") and not legal_person_id:
        return []

    owned_items = []
    seen_keys = set()
    seen_tables = set()
    with connection.cursor() as cursor:
        for source_label, table, owner_field_candidates in _gis_municipal_table_specs():
            if table in seen_tables:
                continue
            seen_tables.add(table)

            filter_field = None
            filter_params: list = []
            filter_is_any = False
            if filter_mode in ("owner", FILTER_OWNER_MULTI):
                for candidate in owner_field_candidates:
                    if _column_exists(cursor, table, candidate):
                        filter_field = _resolve_column_name(cursor, table, candidate)
                        break
                if not filter_field:
                    continue
                if filter_mode == FILTER_OWNER_MULTI:
                    filter_params = [multi_ids]
                    filter_is_any = True
                else:
                    filter_params = [legal_person_id]
            elif filter_mode == "department":
                if not _column_exists(cursor, table, department_field_pref):
                    continue
                filter_field = _resolve_column_name(cursor, table, department_field_pref)
                filter_params = [legal_person_id]
            # filter_mode == "none": no legal-person WHERE

            if not _column_exists(cursor, table, rootid_field) or not _column_exists(cursor, table, name_field):
                continue
            rootid_col = _resolve_column_name(cursor, table, rootid_field)
            name_col = _resolve_column_name(cursor, table, name_field)

            request_id_expr = "''::text AS request_id"
            request_id_col = None
            if _column_exists(cursor, table, request_id_field_pref):
                request_id_col = _resolve_column_name(cursor, table, request_id_field_pref)
                request_id_expr = f"{_quote_ident(request_id_col)}::text AS request_id"

            if site_requests_only:
                if not request_id_col:
                    continue
            if passports_only and site_requests_only:
                continue

            geom_expr = "NULL::text AS geom_json"
            try:
                geom_field = _resolve_column_name(cursor, table, settings.GIS_OBJECT_GEOM_FIELD)
            except Exception:
                geom_field = None
            if geom_field:
                geom_expr = f"ST_AsGeoJSON(ST_Force2D({_quote_ident(geom_field)}))::text AS geom_json"

            start_sql = _optional_column_text_sql(cursor, table, ("startdate", "StartDate"))
            survey_sql = _optional_column_text_sql(cursor, table, ("datesurvey", "DateSurvey"))
            createtype_sql = _optional_column_text_sql(cursor, table, ("createtype", "CreateType"))
            created_at_sql = "NULL::timestamptz AS created_at"
            if _column_exists(cursor, table, "created_at"):
                created_col = _resolve_column_name(cursor, table, "created_at")
                created_at_sql = f"{_quote_ident(created_col)} AS created_at"

            where_parts = []
            params: list = []
            if filter_field:
                if filter_is_any:
                    where_parts.append(f"{_quote_ident(filter_field)}::text = ANY(%s)")
                else:
                    where_parts.append(f"{_quote_ident(filter_field)} = %s")
                params.extend(filter_params)

            if site_requests_only:
                where_parts.append(
                    f"{_quote_ident(request_id_col)} IS NOT NULL "
                    f"AND BTRIM({_quote_ident(request_id_col)}::text) <> ''"
                )
                where_parts.append(
                    f"({_quote_ident(rootid_col)} IS NULL OR BTRIM({_quote_ident(rootid_col)}::text) = '')"
                )
            elif passports_only:
                where_parts.append(
                    f"{_quote_ident(rootid_col)} IS NOT NULL "
                    f"AND BTRIM({_quote_ident(rootid_col)}::text) <> ''"
                )

            where_sql = (" WHERE " + " AND ".join(where_parts)) if where_parts else ""

            if apply_hood and geom_field:
                hood_suf, hood_suf_params = get_hood_intersects_sql_suffix(_quote_ident(geom_field))
            else:
                hood_suf, hood_suf_params = "", []

            query = (
                f"SELECT ctid::text, {_quote_ident(rootid_col)}::text, {_quote_ident(name_col)}::text, "
                f"{request_id_expr}, {geom_expr}, "
                f"{start_sql}, {survey_sql}, {createtype_sql}, {created_at_sql} "
                f"FROM {_quote_ident(table)}"
                f"{where_sql}"
            )
            query = (
                query.rstrip()
                + hood_suf
                + f" ORDER BY {_quote_ident(name_col)} ASC NULLS LAST, {_quote_ident(rootid_col)} ASC "
                f"LIMIT {int(row_limit)}"
            )
            cursor.execute(query, params + hood_suf_params)
            rows = cursor.fetchall()

            for row in rows:
                item = {
                    "object_key": row[0],
                    "rootid": row[1],
                    "name": row[2] or "",
                    "request_id": row[3] or "",
                    "source_label": source_label,
                    "geom_json": row[4] or "",
                    "startdate": row[5] or "",
                    "datesurvey": row[6] or "",
                    "createtype": row[7] or "",
                    "created_at": row[8] if len(row) > 8 else None,
                }
                key = (
                    (item["rootid"] or "").strip().lower(),
                    (item["name"] or "").strip().lower(),
                    (item["request_id"] or "").strip().lower(),
                )
                if key in seen_keys:
                    continue
                seen_keys.add(key)
                owned_items.append(item)

    return sorted(
        owned_items,
        key=lambda item: (
            (item.get("name") or "").lower(),
            (item.get("rootid") or "").lower(),
            (item.get("request_id") or "").lower(),
        ),
    )


def _owned_item_dedup_key(item):
    """Ключ дедупликации: учитывает источник, чтобы строки ods_request не скрывались при совпадении с GIS."""
    src = (item.get("source_label") or "").strip().upper()
    if src in {"ОЗН", "ОО"}:
        src = "ОЗН"
    if src in {_top_source_label().upper(), "TOP"}:
        src = _top_source_label().upper()
    return (
        (item.get("rootid") or "").strip().lower(),
        (item.get("name") or "").strip().lower(),
        (item.get("request_id") or "").strip().lower(),
        src,
    )


def _get_owned_ods_requests(owner_legal_person_id):
    """
    Строки из ods_request для ownerid. Геометрии нет; фильтр hood к этим строкам не применяется (фаза 1).

    ShortObjectRootId в ods_request соответствует rootid в pass_objects / odh / ozn (не ShortObjectId).
    """
    if not owner_legal_person_id:
        return []

    table = getattr(settings, "GIS_ODS_REQUEST_TABLE", "ods_request")
    source_label = getattr(settings, "GIS_ODS_REQUEST_SOURCE_LABEL", "ОДС")
    out = []
    with connection.cursor() as cursor:
        if not _table_exists(cursor, table) or not _column_exists(cursor, table, "ownerid"):
            return []
        owner_col = _resolve_column_name(cursor, table, "ownerid")
        id_col = "id"
        if not _column_exists(cursor, table, id_col):
            return []

        id_resolved = _resolve_column_name(cursor, table, id_col)
        brid_expr = "NULL::text"
        if _column_exists(cursor, table, "BrId"):
            bc = _resolve_column_name(cursor, table, "BrId")
            brid_expr = f"COALESCE({_quote_ident(bc)}::text, ''::text)"
        name_expr = "NULL::text"
        if _column_exists(cursor, table, "ObjectName"):
            nc = _resolve_column_name(cursor, table, "ObjectName")
            name_expr = f"COALESCE({_quote_ident(nc)}::text, ''::text)"
        rootid_plan_expr = "NULL::text"
        if _column_exists(cursor, table, "ShortObjectRootId"):
            rc = _resolve_column_name(cursor, table, "ShortObjectRootId")
            rootid_plan_expr = f"COALESCE({_quote_ident(rc)}::text, ''::text)"
        ptype_expr = "NULL::text"
        if _column_exists(cursor, table, "PassportizationTypeName"):
            pc = _resolve_column_name(cursor, table, "PassportizationTypeName")
            ptype_expr = f"COALESCE({_quote_ident(pc)}::text, ''::text)"
        reason_expr = "NULL::text"
        if _column_exists(cursor, table, "ReasonName"):
            rnc = _resolve_column_name(cursor, table, "ReasonName")
            reason_expr = f"COALESCE({_quote_ident(rnc)}::text, ''::text)"
        status_expr = "NULL::text"
        if _column_exists(cursor, table, "BrStatusName"):
            sc = _resolve_column_name(cursor, table, "BrStatusName")
            status_expr = f"COALESCE({_quote_ident(sc)}::text, ''::text)"

        order_parts = []
        if _column_exists(cursor, table, "ObjectName"):
            order_parts.append(f"{_quote_ident(_resolve_column_name(cursor, table, 'ObjectName'))} ASC NULLS LAST")
        if _column_exists(cursor, table, "BrId"):
            order_parts.append(f"{_quote_ident(_resolve_column_name(cursor, table, 'BrId'))} ASC NULLS LAST")
        order_parts.append(f"{_quote_ident(id_resolved)} ASC")
        order_sql = ", ".join(order_parts)

        query = (
            f"SELECT {_quote_ident(id_resolved)}::text, {brid_expr}, {name_expr}, {rootid_plan_expr}, "
            f"{ptype_expr}, {reason_expr}, {status_expr} "
            f"FROM {_quote_ident(table)} "
            f"WHERE {_quote_ident(owner_col)}::text = %s "
            f"ORDER BY {order_sql} "
            f"LIMIT 500"
        )
        cursor.execute(query, [str(owner_legal_person_id)])
        rows = cursor.fetchall()

        for row in rows:
            pk = row[0] or ""
            brid = row[1] or ""
            oname = row[2] or ""
            short_root_id = row[3] or ""
            ptype = row[4] or ""
            rname = row[5] or ""
            br_status = row[6] or "" if len(row) > 6 else ""
            out.append(
                {
                    "object_key": f"ods_request:{pk}",
                    "rootid": "",
                    "name": oname,
                    "request_id": brid,
                    "source_label": source_label,
                    "geom_json": "",
                    "startdate": "",
                    "datesurvey": "",
                    "createtype": "",
                    "is_ods_request": True,
                    "short_object_root_id": short_root_id,
                    "passportization_type_name": ptype,
                    "reason_name": rname,
                    "br_status_name": br_status,
                }
            )

    return out


ODS_REQUEST_OBJECT_KEY_PREFIX = "ods_request:"


def _parse_ods_request_object_key(object_key):
    key = str(object_key or "").strip()
    if not key.startswith(ODS_REQUEST_OBJECT_KEY_PREFIX):
        return None
    pk = key[len(ODS_REQUEST_OBJECT_KEY_PREFIX) :].strip()
    return pk if pk.isdigit() else None


def _find_gis_geometry_for_ods_short_root(owner_legal_person_id, short_object_root_id):
    sr = _norm_registry_id(short_object_root_id)
    if not sr:
        return None
    for item in _get_owned_objects(owner_legal_person_id):
        if _norm_registry_id(item.get("rootid")) != sr:
            continue
        geom = (item.get("geom_json") or "").strip()
        if geom:
            return geom
    return None


def _get_owned_ods_request_for_recap(owner_legal_person_id, object_key):
    pk = _parse_ods_request_object_key(object_key)
    if not pk or not owner_legal_person_id:
        return None

    table = getattr(settings, "GIS_ODS_REQUEST_TABLE", "ods_request")
    source_label = getattr(settings, "GIS_ODS_REQUEST_SOURCE_LABEL", "ОДС")

    with connection.cursor() as cursor:
        if not _table_exists(cursor, table) or not _column_exists(cursor, table, "ownerid"):
            return None
        if not _column_exists(cursor, table, "id"):
            return None

        owner_col = _resolve_column_name(cursor, table, "ownerid")
        id_col = _resolve_column_name(cursor, table, "id")

        brid_expr = "NULL::text"
        if _column_exists(cursor, table, "BrId"):
            bc = _resolve_column_name(cursor, table, "BrId")
            brid_expr = f"COALESCE({_quote_ident(bc)}::text, ''::text)"
        name_expr = "NULL::text"
        if _column_exists(cursor, table, "ObjectName"):
            nc = _resolve_column_name(cursor, table, "ObjectName")
            name_expr = f"COALESCE({_quote_ident(nc)}::text, ''::text)"
        rootid_expr = "NULL::text"
        if _column_exists(cursor, table, "ShortObjectRootId"):
            rc = _resolve_column_name(cursor, table, "ShortObjectRootId")
            rootid_expr = f"COALESCE({_quote_ident(rc)}::text, ''::text)"

        query = (
            f"SELECT {brid_expr}, {name_expr}, {rootid_expr} "
            f"FROM {_quote_ident(table)} "
            f"WHERE {_quote_ident(id_col)}::text = %s "
            f"AND {_quote_ident(owner_col)}::text = %s "
            f"LIMIT 1"
        )
        cursor.execute(query, [pk, str(owner_legal_person_id)])
        row = cursor.fetchone()

    if not row:
        return None

    brid = (row[0] or "").strip()
    if not brid or not brid.isdigit():
        return None

    name = row[1] or ""
    short_root = row[2] or ""
    geometry_json = _find_gis_geometry_for_ods_short_root(owner_legal_person_id, short_root)

    return {
        "object_key": object_key,
        "rootid": "",
        "name": name,
        "request_id": brid,
        "geometry_json": geometry_json,
        "source_label": source_label,
    }


def _get_owned_ods_brids(owner_legal_person_id):
    """Уникальные BrId из ods_request для пользователя (подсказки в модалке номера заявки)."""
    if not owner_legal_person_id:
        return []
    table = getattr(settings, "GIS_ODS_REQUEST_TABLE", "ods_request")
    with connection.cursor() as cursor:
        if not _table_exists(cursor, table) or not _column_exists(cursor, table, "ownerid"):
            return []
        if not _column_exists(cursor, table, "BrId"):
            return []
        owner_col = _resolve_column_name(cursor, table, "ownerid")
        brid_col = _resolve_column_name(cursor, table, "BrId")
        cursor.execute(
            f"SELECT DISTINCT {_quote_ident(brid_col)}::text "
            f"FROM {_quote_ident(table)} "
            f"WHERE {_quote_ident(owner_col)}::text = %s "
            f"AND TRIM(COALESCE({_quote_ident(brid_col)}::text, '')) <> '' "
            f"ORDER BY 1 ASC NULLS LAST "
            f"LIMIT 1000",
            [str(owner_legal_person_id)],
        )
        rows = cursor.fetchall()
    out = []
    seen = set()
    for row in rows:
        brid = (row[0] if row else "") or ""
        brid = str(brid).strip()
        if not brid or brid in seen:
            continue
        seen.add(brid)
        out.append(brid)
    return out


def _merge_owned_ods_requests(owned_objects, owner_legal_person_id):
    """Добавляет строки ods_request; дедуп с существующим списком по (rootid, name, request_id, source)."""
    merged = list(owned_objects)
    seen = {_owned_item_dedup_key(it) for it in merged}
    for item in _get_owned_ods_requests(owner_legal_person_id):
        key = _owned_item_dedup_key(item)
        if key in seen:
            continue
        seen.add(key)
        merged.append(item)
    return sorted(
        merged,
        key=lambda item: (
            (item.get("name") or "").lower(),
            (item.get("rootid") or "").lower(),
            (item.get("request_id") or "").lower(),
            (item.get("source_label") or "").lower(),
        ),
    )


def _norm_registry_id(value):
    return (str(value) if value is not None else "").strip().lower()


def _ods_brid_within_validation_window(created_at, *, hours=24):
    """True, если с created_at прошло меньше hours часов (окно валидации BrId в АСУ ОДС)."""
    if created_at is None:
        return False
    if isinstance(created_at, str):
        created_at = parse_datetime(created_at.strip()) if created_at.strip() else None
    if created_at is None:
        return False
    if timezone.is_naive(created_at):
        created_at = timezone.make_aware(created_at, timezone.get_current_timezone())
    return (timezone.now() - created_at) < timedelta(hours=hours)


def _classify_ods_click_scenario(passportization_type_name, reason_name, short_object_root_id):
    """
    1 — первичное обследование (add_object), 2 — актуализация (main), 3 — split, 4 — merge.
    Приоритет: сначала особые ReasonName, затем тип паспортизации.
    """
    r = (reason_name or "").strip().lower()
    p = (passportization_type_name or "").strip().lower()
    sr = _norm_registry_id(short_object_root_id)
    if "объединение объектов" in r:
        return 4
    if "выделение" in r and "из другого объекта" in r:
        return 3
    if p == "первичное обследование" and not sr:
        return 1
    if p in {"актуализация", "первичное обследование"} and sr:
        return 2
    return 0


def _enrich_ods_interaction_and_geometry(owned_objects):
    """
    Для строк ODS: сценарий клика, готовность GIS (2–4), копия геометрии с совпавшего паспорта, map_row_key для карты.
    """
    gis_passports = [g for g in owned_objects if not g.get("is_ods_request") and _norm_registry_id(g.get("rootid"))]
    by_root = {}
    for g in gis_passports:
        k = _norm_registry_id(g.get("rootid"))
        if k and k not in by_root:
            by_root[k] = g

    for item in owned_objects:
        if not item.get("is_ods_request"):
            continue
        ptn = item.get("passportization_type_name") or ""
        rn = item.get("reason_name") or ""
        scenario = _classify_ods_click_scenario(ptn, rn, item.get("short_object_root_id"))
        item["ods_click_scenario"] = scenario

        sr = _norm_registry_id(item.get("short_object_root_id"))
        match = by_root.get(sr) if sr else None
        item["ods_matched_rootid"] = (match.get("rootid") or "").strip() if match else ""
        item["ods_matched_name"] = (match.get("name") or "").strip() if match else ""
        item["ods_matched_source_label"] = (match.get("source_label") or "ДТ") if match else ""

        if match and match.get("geom_json"):
            item["geom_json"] = match.get("geom_json") or ""
            item["ods_uses_gis_geometry"] = True
        else:
            item["ods_uses_gis_geometry"] = False

        ok = bool(match and sr)
        if scenario == 1:
            item["ods_gis_ready"] = True
        elif scenario in (2, 3, 4):
            item["ods_gis_ready"] = ok
        else:
            item["ods_gis_ready"] = False

        pk = (item.get("object_key") or "").replace("ods_request:", "").strip()
        item["map_row_key"] = f"odsrow:{pk}" if pk else f"odsrow:{(item.get('object_key') or 'x').lower()}"

    return owned_objects


def _annotate_and_filter_ods_registry_against_gis(owned_objects):
    """
    Сверка GIS с реестром ods_request: индикаторы на заявках/паспортах.

    Строка ODS скрывается из списка только если её BrId (request_id у ODS-элемента)
    совпадает с request_id какой-либо GIS-заявки (строка без rootid). Иначе ODS
    остаётся в списке, даже если ShortObjectRootId совпадает с rootid паспорта.
    """
    ods_items = [x for x in owned_objects if x.get("is_ods_request")]
    gis_items = [x for x in owned_objects if not x.get("is_ods_request")]

    ods_br_ids = {_norm_registry_id(o.get("request_id")) for o in ods_items if _norm_registry_id(o.get("request_id"))}
    ods_br_status_by_id = {}
    for o in ods_items:
        brid = _norm_registry_id(o.get("request_id"))
        if brid and brid not in ods_br_status_by_id:
            ods_br_status_by_id[brid] = (o.get("br_status_name") or "").strip()
    ods_root_ids = {
        _norm_registry_id(o.get("short_object_root_id"))
        for o in ods_items
        if _norm_registry_id(o.get("short_object_root_id"))
    }

    gis_request_ids = set()
    for g in gis_items:
        root = _norm_registry_id(g.get("rootid"))
        if not root:
            req = _norm_registry_id(g.get("request_id"))
            if req:
                gis_request_ids.add(req)

    has_ods = bool(ods_items)

    for g in gis_items:
        root = _norm_registry_id(g.get("rootid"))
        req = _norm_registry_id(g.get("request_id"))
        g.pop("ods_registry_brid_match", None)
        g.pop("ods_registry_brid_labeled", None)
        g.pop("ods_registry_brid_pending", None)
        g.pop("ods_registry_root_match", None)
        g.pop("ods_registry_br_status_name", None)
        if root:
            g["ods_registry_root_match"] = root in ods_root_ids
        elif has_ods and req:
            g["ods_registry_brid_labeled"] = True
            brid_match = req in ods_br_ids
            g["ods_registry_brid_match"] = brid_match
            if brid_match:
                g["ods_registry_br_status_name"] = ods_br_status_by_id.get(req, "")
            else:
                g["ods_registry_brid_pending"] = _ods_brid_within_validation_window(g.get("created_at"))

    out = []
    for x in owned_objects:
        if not x.get("is_ods_request"):
            out.append(x)
            continue
        brid = _norm_registry_id(x.get("request_id"))
        if brid and brid in gis_request_ids:
            continue
        out.append(x)

    return out


def _build_owned_passports_geojson(owned_objects):
    features = []
    for item in owned_objects:
        rootid = (item.get("rootid") or "").strip()
        request_id = (item.get("request_id") or "").strip()
        geom_json = item.get("geom_json") or ""
        if not geom_json:
            continue
        try:
            geometry = json.loads(geom_json)
        except Exception:
            continue
        if not geometry:
            continue
        if item.get("is_ods_request"):
            rootid = (item.get("ods_matched_rootid") or rootid or "").strip()
            ods_source = item.get("source_label") or getattr(settings, "GIS_ODS_REQUEST_SOURCE_LABEL", "ОДС")
            matched_source = item.get("ods_matched_source_label") or ""
            props = {
                "rootid": rootid,
                "name": item.get("name") or "",
                "source_label": ods_source,
                "matched_source_label": matched_source,
                "request_id": request_id,
                "is_request_object": bool(request_id and not rootid),
                "startdate": item.get("startdate") or "",
                "datesurvey": item.get("datesurvey") or "",
                "createtype": item.get("createtype") or "",
                "from_ods_registry": True,
                "map_row_key": (item.get("map_row_key") or "").strip(),
                "brid": request_id,
            }
        else:
            props = {
                "rootid": rootid,
                "name": item.get("name") or "",
                "source_label": item.get("source_label") or "ДТ",
                "request_id": request_id,
                "is_request_object": bool(request_id and not rootid),
                "startdate": item.get("startdate") or "",
                "datesurvey": item.get("datesurvey") or "",
                "createtype": item.get("createtype") or "",
            }
        features.append(
            {
                "type": "Feature",
                "geometry": geometry,
                "properties": props,
            }
        )
    return {"type": "FeatureCollection", "features": features}


def _normalize_source_label(value):
    source = str(value or "").strip().upper()
    top_label = _top_source_label().upper()
    if source == "ОДХ":
        return "ОДХ"
    if source in {"ОЗН", "ОО"}:
        return "ОЗН"
    if source in {top_label, "TOP"}:
        return _top_source_label()
    return "ДТ"


def _get_source_table(source_label):
    normalized_source = _normalize_source_label(source_label)
    if normalized_source == "ОДХ":
        return getattr(settings, "GIS_ODH_TABLE", "odh")
    if normalized_source == "ОЗН":
        return getattr(settings, "GIS_OZN_TABLE", "ozn")
    if normalized_source == _top_source_label():
        return getattr(settings, "GIS_TOP_TABLE", "top")
    return settings.GIS_OBJECT_TABLE


def _recaps_owner_scope_columns(cursor, table_alias="t"):
    table = "recaps"
    owner_field_pref = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field = _resolve_column_name(cursor, table, owner_field_pref)
    request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
    name_field = _resolve_column_name(cursor, table, name_field_pref)
    geom_field = _resolve_column_name(cursor, table, geom_field_pref)
    hood_suf, hood_prm = get_hood_intersects_sql_suffix(f"{table_alias}.{_quote_ident(geom_field)}")
    return owner_field, request_id_field, name_field, geom_field, hood_suf, hood_prm


def _get_recap_counts_by_request_ids(owner_legal_person_id, request_ids):
    normalized_ids = [str(value).strip() for value in request_ids if str(value).strip()]
    if not normalized_ids or not owner_legal_person_id:
        return {}

    with connection.cursor() as cursor:
        owner_field, request_id_field, _name_field, _geom_field, hood_suf, hood_prm = _recaps_owner_scope_columns(
            cursor
        )
        query = (
            f"SELECT {_quote_ident(request_id_field)}::text AS request_id, COUNT(*)::int AS recap_count "
            "FROM recaps t "
            f"WHERE {_quote_ident(owner_field)} = %s "
            f"AND {_quote_ident(request_id_field)}::text = ANY(%s)"
            f"{hood_suf} "
            f"GROUP BY {_quote_ident(request_id_field)}::text"
        )
        cursor.execute(query, [owner_legal_person_id, normalized_ids] + hood_prm)
        rows = cursor.fetchall()

    return {row[0]: row[1] for row in rows}


def _get_owned_recaps_for_request(owner_legal_person_id, request_id):
    request_id_text = str(request_id or "").strip()
    if not owner_legal_person_id or not request_id_text:
        return []

    with connection.cursor() as cursor:
        owner_field, request_id_field, name_field, _geom_field, hood_suf, hood_prm = _recaps_owner_scope_columns(
            cursor
        )
        query = (
            f"SELECT t.recap_id::text, {_quote_ident(request_id_field)}::text, "
            f"{_quote_ident(name_field)}::text "
            "FROM recaps t "
            f"WHERE {_quote_ident(owner_field)} = %s "
            f"AND {_quote_ident(request_id_field)}::text = %s"
            f"{hood_suf} "
            "ORDER BY t.recap_id ASC"
        )
        cursor.execute(query, [owner_legal_person_id, request_id_text] + hood_prm)
        rows = cursor.fetchall()

    return [
        {
            "recap_id": row[0] or "",
            "request_id": row[1] or "",
            "name": row[2] or "",
        }
        for row in rows
    ]


def _get_owned_recap_row(owner_legal_person_id, recap_id):
    recap_id_text = str(recap_id or "").strip()
    if not owner_legal_person_id or not recap_id_text or not recap_id_text.isdigit():
        return None

    with connection.cursor() as cursor:
        owner_field, request_id_field, name_field, geom_field, hood_suf, hood_prm = _recaps_owner_scope_columns(cursor)
        query = (
            f"SELECT t.recap_id::text, {_quote_ident(request_id_field)}::text, "
            f"{_quote_ident(name_field)}::text, ST_AsGeoJSON({_quote_ident(geom_field)})::text "
            "FROM recaps t "
            "WHERE t.recap_id = %s "
            f"AND {_quote_ident(owner_field)} = %s"
            f"{hood_suf} "
            "LIMIT 1"
        )
        cursor.execute(query, [recap_id_text, owner_legal_person_id] + hood_prm)
        row = cursor.fetchone()

    if not row:
        return None

    return {
        "recap_id": row[0] or "",
        "request_id": row[1] or "",
        "name": row[2] or "",
        "geometry_json": row[3] or "",
    }


def _get_owned_request_object(owner_legal_person_id, object_key, source_label="ДТ", *, filter_mode="owner"):
    if not owner_legal_person_id or not object_key:
        return None

    normalized_source = _normalize_source_label(source_label)
    table = _get_source_table(normalized_source)
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    department_field_pref = getattr(settings, "GIS_OBJECT_DEPARTMENT_FIELD", "DepartmentLegalPersonId")
    if filter_mode == FILTER_DEPARTMENT:
        owner_field_pref = department_field_pref
    else:
        owner_field_pref = _owner_field_pref_for_source(normalized_source)
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")

    with connection.cursor() as cursor:
        if filter_mode == FILTER_DEPARTMENT and not _column_exists(cursor, table, department_field_pref):
            return None
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_select_expr = "''::text"
        if _column_exists(cursor, table, request_id_field_pref):
            request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
            request_id_select_expr = f"{_quote_ident(request_id_field)}::text"
        query = (
            f"SELECT ctid::text, {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, "
            f"{request_id_select_expr}, ST_AsGeoJSON({_quote_ident(geom_field)}) "
            f"FROM {_quote_ident(table)} "
            f"WHERE ctid = %s::tid "
            f"  AND {_quote_ident(owner_field)} = %s "
        )
        hood_suf, hood_suf_params = get_hood_intersects_sql_suffix(_quote_ident(geom_field))
        query = query.rstrip() + hood_suf + "LIMIT 1"
        cursor.execute(query, [object_key, owner_legal_person_id] + hood_suf_params)
        row = cursor.fetchone()

    if not row:
        return None

    return {
        "object_key": row[0],
        "rootid": row[1],
        "name": row[2] or "",
        "request_id": row[3] or "",
        "geometry_json": row[4],
        "source_label": normalized_source,
    }


def _build_where_clause(entry_point, rootid_field, name_field, request_id_field=None):
    raw_rootid = (entry_point.get("rootid") or "").strip()
    if raw_rootid.lower() in {"none", "null"}:
        raw_rootid = ""
    raw_request_id = (entry_point.get("request_id") or "").strip()

    if raw_rootid:
        # Compare as text so rootid can be safely passed from UI.
        return f"{rootid_field}::text = %s", [raw_rootid]
    if request_id_field and raw_request_id:
        return f"{request_id_field}::text = %s", [raw_request_id]
    return f"{name_field} ILIKE %s", [(entry_point.get("name") or "").strip()]


def _find_manual_entry_point(rootid="", name=""):
    rootid = (rootid or "").strip()
    name = (name or "").strip()
    if not rootid and not name:
        return None

    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")

    seen_tables = set()
    with connection.cursor() as cursor:
        for source_label, table, _owner_candidates in _gis_municipal_table_specs():
            if table in seen_tables:
                continue
            seen_tables.add(table)

            if not _column_exists(cursor, table, rootid_field_pref) or not _column_exists(
                cursor, table, name_field_pref
            ):
                continue

            rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
            name_field = _resolve_column_name(cursor, table, name_field_pref)
            request_id_select_expr = "NULL::text AS request_id"
            if _column_exists(cursor, table, request_id_field_pref):
                request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
                request_id_select_expr = f"{_quote_ident(request_id_field)}::text AS request_id"

            hood_suf, hp = "", []
            if _column_exists(cursor, table, settings.GIS_OBJECT_GEOM_FIELD):
                gf = _resolve_column_name(cursor, table, settings.GIS_OBJECT_GEOM_FIELD)
                hood_suf, hp = get_hood_intersects_sql_suffix(_quote_ident(gf))

            if rootid:
                query = (
                    f"SELECT {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, {request_id_select_expr} "
                    f"FROM {_quote_ident(table)} "
                    f"WHERE {_quote_ident(rootid_field)}::text = %s "
                    f"{hood_suf} "
                    "LIMIT 1"
                )
                cursor.execute(query, [rootid] + hp)
            else:
                query = (
                    f"SELECT {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, {request_id_select_expr} "
                    f"FROM {_quote_ident(table)} "
                    f"WHERE {_quote_ident(name_field)} ILIKE %s "
                    f"{hood_suf} "
                    "LIMIT 1"
                )
                cursor.execute(query, [name] + hp)

            row = cursor.fetchone()
            if not row:
                continue

            found_rootid = (row[0] or "").strip()
            found_name = (row[1] or "").strip()
            found_request_id = (row[2] or "").strip()
            return {
                "rootid": found_rootid,
                "name": found_name,
                "request_id": found_request_id,
                "source_label": source_label,
            }
    return None


def _dedupe_merge_items(merge_items):
    """Убирает дубли по (rootid, source) или (object_key, source)."""
    seen = set()
    out = []
    for it in merge_items or []:
        sl = _normalize_source_label(it.get("source_label"))
        rid = (it.get("rootid") or "").strip()
        ok = (it.get("object_key") or "").strip()
        if rid:
            key = ("r", rid.lower(), sl)
        elif ok:
            key = ("o", ok, sl)
        else:
            continue
        if key in seen:
            continue
        seen.add(key)
        out.append(
            {
                "rootid": rid,
                "object_key": ok,
                "source_label": sl,
            }
        )
    return out


def _normalize_merge_items(entry_point):
    """Список словарей {rootid, object_key, source_label} для объединения (≥2)."""
    raw = entry_point.get("merge_items")
    out = []
    if isinstance(raw, list):
        for x in raw:
            if not isinstance(x, dict):
                continue
            rid = (x.get("rootid") or "").strip()
            ok = (x.get("object_key") or "").strip()
            if rid or ok:
                out.append(
                    {
                        "rootid": rid,
                        "object_key": ok,
                        "source_label": _normalize_source_label(x.get("source_label")),
                    }
                )
    out = _dedupe_merge_items(out)
    if len(out) >= 2:
        return out
    rootids_raw = entry_point.get("merge_rootids")
    if isinstance(rootids_raw, (list, tuple)) and len(rootids_raw) >= 2:
        sl = _normalize_source_label(entry_point.get("source_label"))
        legacy = [
            {"rootid": str(r).strip(), "object_key": "", "source_label": sl} for r in rootids_raw if str(r).strip()
        ]
        return _dedupe_merge_items(legacy)
    return []


def _build_merge_allowed_sets(owned_objects):
    """Множества допустимых (rootid, source), (object_key, source) и ODS matched rootid."""
    passport_pairs = set()
    request_keys = set()
    ods_root_pairs = set()
    for item in owned_objects or []:
        sl = _normalize_source_label(item.get("source_label"))
        if item.get("is_ods_request"):
            if item.get("ods_gis_ready"):
                mr = (item.get("ods_matched_rootid") or "").strip()
                ms = _normalize_source_label(item.get("ods_matched_source_label") or "ДТ")
                if mr:
                    ods_root_pairs.add((mr, ms))
            continue
        rid = (item.get("rootid") or "").strip()
        ok = (item.get("object_key") or "").strip()
        if rid:
            passport_pairs.add((rid, sl))
        elif ok:
            request_keys.add((ok, sl))
    return passport_pairs, request_keys, ods_root_pairs


def _merge_item_is_allowed(merge_item, passport_pairs, request_keys, ods_root_pairs):
    sl = _normalize_source_label(merge_item.get("source_label"))
    rid = (merge_item.get("rootid") or "").strip()
    ok = (merge_item.get("object_key") or "").strip()
    if ok:
        return (ok, sl) in request_keys
    if rid:
        if (rid, sl) in passport_pairs:
            return True
        if (rid, sl) in ods_root_pairs:
            return True
    return False


def _merge_group_ids_by_source(merge_items):
    top_label = _top_source_label()
    res = {
        "ДТ": {"rootids": [], "object_keys": []},
        "ОДХ": {"rootids": [], "object_keys": []},
        "ОЗН": {"rootids": [], "object_keys": []},
        top_label: {"rootids": [], "object_keys": []},
    }
    for it in merge_items or []:
        sl = _normalize_source_label(it.get("source_label"))
        bucket = res.get(sl, res["ДТ"])
        rid = (it.get("rootid") or "").strip()
        ok = (it.get("object_key") or "").strip()
        if rid:
            bucket["rootids"].append(rid)
        elif ok:
            bucket["object_keys"].append(ok)
    return res


def _append_merge_table_select_parts(cursor, parts, params, tbl, group):
    rootid_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_pref = settings.GIS_OBJECT_GEOM_FIELD
    req_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    rootids = group.get("rootids") or []
    object_keys = group.get("object_keys") or []
    if not rootids and not object_keys:
        return
    if not _column_exists(cursor, tbl, rootid_pref) or not _column_exists(cursor, tbl, geom_pref):
        return
    rf = _resolve_column_name(cursor, tbl, rootid_pref)
    nf = _resolve_column_name(cursor, tbl, name_pref)
    gf = _resolve_column_name(cursor, tbl, geom_pref)
    if _column_exists(cursor, tbl, req_pref):
        rqf = _resolve_column_name(cursor, tbl, req_pref)
        rq_expr = f"{_quote_ident(rqf)}::text AS request_id"
    else:
        rq_expr = "NULL::text AS request_id"
    meta_frag = _gis_object_meta_sql_fragment(cursor, tbl)
    hood_geom_and = get_hood_intersects_ha_sql(_quote_ident(gf))
    select_cols = (
        f"SELECT ctid, {_quote_ident(rf)}::text AS rootid, COALESCE({_quote_ident(nf)}::text, '') AS name, "
        f"{rq_expr}, NULL::text AS customer_legal_person_id, NULL::text AS department_legal_person_id, "
        f"NULL::text AS customer_legal_person_name, NULL::text AS department_legal_person_name, "
        f"{meta_frag}, "
        f"{_quote_ident(gf)} AS geom FROM {_quote_ident(tbl)} "
    )
    if rootids:
        parts.append(select_cols + f"WHERE {_quote_ident(rf)}::text = ANY(%s){hood_geom_and}")
        params.append(rootids)
    if object_keys:
        parts.append(select_cols + f"WHERE ctid = ANY(%s::tid[]){hood_geom_and}")
        params.append(object_keys)


def _build_merge_matched_body_sql(cursor, merge_items):
    """
    SQL-тело для CTE matched: UNION ALL выборок из таблиц ДТ/ОДХ/ОЗН.
    Возвращает (sql_fragment, list_of_params) или (None, None).
    """
    by = _merge_group_ids_by_source(merge_items)

    parts = []
    params = []
    for label, tbl, _candidates in _gis_municipal_table_specs():
        _append_merge_table_select_parts(cursor, parts, params, tbl, by[label])
    if not parts:
        return None, None
    return " UNION ALL ".join(parts), params


def _get_map_layers(entry_point, *, include_adjacent_layers=True, only_layer=None):
    source_label = _normalize_source_label(entry_point.get("source_label"))
    table = _get_source_table(source_label)
    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, "GIS_ODH_TABLE", "odh")
    ozn_table = getattr(settings, "GIS_OZN_TABLE", "ozn")
    top_table = getattr(settings, "GIS_TOP_TABLE", "top")
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    geom_field = settings.GIS_OBJECT_GEOM_FIELD
    request_id_field = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    customer_field_pref = getattr(settings, "GIS_OBJECT_CUSTOMER_FIELD", "CustomerLegalPersonId")
    department_field_pref = getattr(settings, "GIS_OBJECT_DEPARTMENT_FIELD", "DepartmentLegalPersonId")
    owner_field_pref_dt = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    owner_field_pref_odh = getattr(settings, "GIS_ODH_CUSTOMER_FIELD", "CustomerLegalPersonId")
    owner_field_pref_ozn = getattr(settings, "GIS_OZN_OWNER_FIELD", "ownerlegalpersonalid")
    owner_field_pref_top = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")

    customer_select_expr = "NULL::text AS customer_legal_person_id"
    department_select_expr = "NULL::text AS department_legal_person_id"
    customer_name_select_expr = "NULL::text AS customer_legal_person_name"
    department_name_select_expr = "NULL::text AS department_legal_person_name"
    customer_name_select_expr_selected = "NULL::text AS customer_legal_person_name"
    department_name_select_expr_selected = "NULL::text AS department_legal_person_name"
    customer_prop_expr = "NULL::text"
    department_prop_expr = "NULL::text"
    customer_name_prop_expr = "NULL::text"
    department_name_prop_expr = "NULL::text"
    request_owner_dt_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_dt_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_odh_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_odh_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_ozn_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_ozn_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_top_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_top_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_customer_dt_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_dt_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_dt_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_dt_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_odh_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_odh_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_odh_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_odh_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_ozn_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_ozn_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_ozn_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_ozn_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_top_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_top_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_top_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_top_name_select_expr = "NULL::text AS department_legal_person_name"
    adjacent_customer_select_expr = "NULL::text AS customer_legal_person_id"
    adjacent_department_select_expr = "NULL::text AS department_legal_person_id"
    adjacent_customer_name_select_expr = "NULL::text AS customer_legal_person_name"
    adjacent_department_name_select_expr = "NULL::text AS department_legal_person_name"
    adjacent_customer_prop_expr = "NULL::text"
    adjacent_department_prop_expr = "NULL::text"
    adjacent_customer_name_prop_expr = "NULL::text"
    adjacent_department_name_prop_expr = "NULL::text"
    adjacent_owner_select_expr = "NULL::text AS owner_legal_person_id"
    adjacent_owner_name_select_expr = "NULL::text AS owner_legal_person_name"
    adjacent_owner_prop_expr = "NULL::text"
    adjacent_owner_name_prop_expr = "NULL::text"
    adjacent_rootid_field = rootid_field
    adjacent_name_field = name_field
    adjacent_geom_field = geom_field
    adjacent_request_id_field = request_id_field
    with connection.cursor() as cursor:
        lookup_context = _get_id_names_lookup_context(cursor)
        if _column_exists(cursor, table, customer_field_pref):
            customer_field = _resolve_column_name(cursor, table, customer_field_pref)
            customer_select_expr = f"{_quote_ident(customer_field)}::text AS customer_legal_person_id"
            customer_prop_expr = "customer_legal_person_id::text"
            customer_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
            customer_name_select_expr_selected = (
                f"{_build_id_name_lookup_expr(_quote_ident(customer_field), lookup_context)} "
                "AS customer_legal_person_name"
            )
            customer_name_prop_expr = "customer_legal_person_name::text"
        if _column_exists(cursor, table, department_field_pref):
            department_field = _resolve_column_name(cursor, table, department_field_pref)
            department_select_expr = f"{_quote_ident(department_field)}::text AS department_legal_person_id"
            department_prop_expr = "department_legal_person_id::text"
            department_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
            department_name_select_expr_selected = (
                f"{_build_id_name_lookup_expr(_quote_ident(department_field), lookup_context)} "
                "AS department_legal_person_name"
            )
            department_name_prop_expr = "department_legal_person_name::text"
        if _column_exists(cursor, dt_table, owner_field_pref_dt):
            dt_owner_field = _resolve_column_name(cursor, dt_table, owner_field_pref_dt)
            request_owner_dt_select_expr = f"t.{_quote_ident(dt_owner_field)}::text AS owner_legal_person_id"
            request_owner_dt_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, odh_table, owner_field_pref_odh):
            odh_owner_field = _resolve_column_name(cursor, odh_table, owner_field_pref_odh)
            request_owner_odh_select_expr = f"t.{_quote_ident(odh_owner_field)}::text AS owner_legal_person_id"
            request_owner_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, ozn_table, owner_field_pref_ozn):
            ozn_owner_field = _resolve_column_name(cursor, ozn_table, owner_field_pref_ozn)
            request_owner_ozn_select_expr = f"t.{_quote_ident(ozn_owner_field)}::text AS owner_legal_person_id"
            request_owner_ozn_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(ozn_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, top_table, owner_field_pref_top):
            top_owner_field = _resolve_column_name(cursor, top_table, owner_field_pref_top)
            request_owner_top_select_expr = f"t.{_quote_ident(top_owner_field)}::text AS owner_legal_person_id"
            request_owner_top_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(top_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, dt_table, customer_field_pref):
            dt_customer_field = _resolve_column_name(cursor, dt_table, customer_field_pref)
            adjacent_customer_select_expr = f"t.{_quote_ident(dt_customer_field)}::text AS customer_legal_person_id"
            adjacent_customer_prop_expr = "customer_legal_person_id::text"
            adjacent_customer_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
            adjacent_customer_name_prop_expr = "customer_legal_person_name::text"
            request_customer_dt_select_expr = f"t.{_quote_ident(dt_customer_field)}::text AS customer_legal_person_id"
            request_customer_dt_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, dt_table, department_field_pref):
            dt_department_field = _resolve_column_name(cursor, dt_table, department_field_pref)
            adjacent_department_select_expr = (
                f"t.{_quote_ident(dt_department_field)}::text AS department_legal_person_id"
            )
            adjacent_department_prop_expr = "department_legal_person_id::text"
            adjacent_department_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
            adjacent_department_name_prop_expr = "department_legal_person_name::text"
            request_department_dt_select_expr = (
                f"t.{_quote_ident(dt_department_field)}::text AS department_legal_person_id"
            )
            request_department_dt_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
        if _column_exists(cursor, odh_table, customer_field_pref):
            odh_customer_field = _resolve_column_name(cursor, odh_table, customer_field_pref)
            request_customer_odh_select_expr = f"t.{_quote_ident(odh_customer_field)}::text AS customer_legal_person_id"
            request_customer_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, odh_table, department_field_pref):
            odh_department_field = _resolve_column_name(cursor, odh_table, department_field_pref)
            request_department_odh_select_expr = (
                f"t.{_quote_ident(odh_department_field)}::text AS department_legal_person_id"
            )
            request_department_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
        if _column_exists(cursor, top_table, customer_field_pref):
            top_customer_field = _resolve_column_name(cursor, top_table, customer_field_pref)
            request_customer_top_select_expr = f"t.{_quote_ident(top_customer_field)}::text AS customer_legal_person_id"
            request_customer_top_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(top_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, top_table, department_field_pref):
            top_department_field = _resolve_column_name(cursor, top_table, department_field_pref)
            request_department_top_select_expr = (
                f"t.{_quote_ident(top_department_field)}::text AS department_legal_person_id"
            )
            request_department_top_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(top_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
        if _column_exists(cursor, dt_table, rootid_field):
            adjacent_rootid_field = _resolve_column_name(cursor, dt_table, rootid_field)
        if _column_exists(cursor, dt_table, name_field):
            adjacent_name_field = _resolve_column_name(cursor, dt_table, name_field)
        if _column_exists(cursor, dt_table, geom_field):
            adjacent_geom_field = _resolve_column_name(cursor, dt_table, geom_field)
        if _column_exists(cursor, dt_table, request_id_field):
            adjacent_request_id_field = _resolve_column_name(cursor, dt_table, request_id_field)
        if _column_exists(cursor, dt_table, owner_field_pref_dt):
            adjacent_owner_field = _resolve_column_name(cursor, dt_table, owner_field_pref_dt)
            adjacent_owner_select_expr = f"t.{_quote_ident(adjacent_owner_field)}::text AS owner_legal_person_id"
            adjacent_owner_prop_expr = "owner_legal_person_id::text"
            adjacent_owner_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(adjacent_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
            adjacent_owner_name_prop_expr = "owner_legal_person_name::text"

        gis_meta_selected_fragment = _gis_object_meta_sql_fragment(cursor, table)
        gis_meta_dt_fragment = _gis_object_meta_sql_fragment(cursor, dt_table, "t")
        gis_meta_odh_fragment = _gis_object_meta_sql_fragment(cursor, odh_table, "t")
        gis_meta_ozn_fragment = _gis_object_meta_sql_fragment(cursor, ozn_table, "t")
        gis_meta_top_fragment = _gis_object_meta_sql_fragment(cursor, top_table, "t")
        if _column_exists(cursor, odh_table, geom_field):
            odh_geom_for_req = _resolve_column_name(cursor, odh_table, geom_field)
        else:
            odh_geom_for_req = adjacent_geom_field
        if _column_exists(cursor, ozn_table, geom_field):
            ozn_geom_for_req = _resolve_column_name(cursor, ozn_table, geom_field)
        else:
            ozn_geom_for_req = adjacent_geom_field
        if _column_exists(cursor, top_table, geom_field):
            top_geom_for_req = _resolve_column_name(cursor, top_table, geom_field)
        else:
            top_geom_for_req = adjacent_geom_field

        req_layer_cols_dt = _resolve_request_layer_columns(
            cursor, dt_table, geom_field, rootid_field, name_field, request_id_field
        )
        req_layer_cols_odh = _resolve_request_layer_columns(
            cursor, odh_table, geom_field, rootid_field, name_field, request_id_field
        )
        req_layer_cols_ozn = _resolve_request_layer_columns(
            cursor, ozn_table, geom_field, rootid_field, name_field, request_id_field
        )
        req_layer_cols_top = _resolve_request_layer_columns(
            cursor, top_table, geom_field, rootid_field, name_field, request_id_field
        )
        passport_only_dt_sql = _sql_gis_passport_only_clause(cursor, dt_table, "t")

    hood_full_pfx, hood_params = get_hood_cte_prefix_sql()
    nearby_meters = _adjacent_nearby_meters()
    hood_inner = _hood_strip_with_keyword(hood_full_pfx)
    map_with_lead = "WITH " + hood_inner
    hood_ha_adj = get_hood_intersects_ha_sql(f"t.{_quote_ident(adjacent_geom_field)}")
    hood_ha_req_dt = get_hood_intersects_ha_sql(f"t.{_quote_ident(adjacent_geom_field)}")
    hood_ha_req_odh = get_hood_intersects_ha_sql(f"t.{_quote_ident(odh_geom_for_req)}")
    hood_ha_req_ozn = get_hood_intersects_ha_sql(f"t.{_quote_ident(ozn_geom_for_req)}")
    hood_ha_req_top = get_hood_intersects_ha_sql(f"t.{_quote_ident(top_geom_for_req)}")
    hood_sel_and = get_hood_intersects_ha_sql(_quote_ident(geom_field))

    request_layer_sources = []
    request_sources_by_key = {}
    if req_layer_cols_dt:
        dt_source = {
            **req_layer_cols_dt,
            "table": dt_table,
            "source_label": "ДТ",
            "hood_ha": hood_ha_req_dt,
            "meta": gis_meta_dt_fragment,
            "owner_select": request_owner_dt_select_expr,
            "owner_name_select": request_owner_dt_name_select_expr,
            "customer_select": request_customer_dt_select_expr,
            "department_select": request_department_dt_select_expr,
            "customer_name_select": request_customer_dt_name_select_expr,
            "department_name_select": request_department_dt_name_select_expr,
        }
        request_layer_sources.append(dt_source)
        request_sources_by_key["dt"] = dt_source
    if req_layer_cols_odh:
        odh_source = {
            **req_layer_cols_odh,
            "table": odh_table,
            "source_label": "ОДХ",
            "hood_ha": hood_ha_req_odh,
            "meta": gis_meta_odh_fragment,
            "owner_select": request_owner_odh_select_expr,
            "owner_name_select": request_owner_odh_name_select_expr,
            "customer_select": request_customer_odh_select_expr,
            "department_select": request_department_odh_select_expr,
            "customer_name_select": request_customer_odh_name_select_expr,
            "department_name_select": request_department_odh_name_select_expr,
        }
        request_layer_sources.append(odh_source)
        request_sources_by_key["odh"] = odh_source
    if req_layer_cols_ozn:
        ozn_source = {
            **req_layer_cols_ozn,
            "table": ozn_table,
            "source_label": "ОЗН",
            "hood_ha": hood_ha_req_ozn,
            "meta": gis_meta_ozn_fragment,
            "owner_select": request_owner_ozn_select_expr,
            "owner_name_select": request_owner_ozn_name_select_expr,
            "customer_select": request_customer_ozn_select_expr,
            "department_select": request_department_ozn_select_expr,
            "customer_name_select": request_customer_ozn_name_select_expr,
            "department_name_select": request_department_ozn_name_select_expr,
        }
        request_layer_sources.append(ozn_source)
        request_sources_by_key["ozn"] = ozn_source
    if req_layer_cols_top:
        top_source = {
            **req_layer_cols_top,
            "table": top_table,
            "source_label": _top_source_label(),
            "hood_ha": hood_ha_req_top,
            "meta": gis_meta_top_fragment,
            "owner_select": request_owner_top_select_expr,
            "owner_name_select": request_owner_top_name_select_expr,
            "customer_select": request_customer_top_select_expr,
            "department_select": request_department_top_select_expr,
            "customer_name_select": request_customer_top_name_select_expr,
            "department_name_select": request_department_top_name_select_expr,
        }
        request_layer_sources.append(top_source)
        request_sources_by_key["top"] = top_source

    merge_items = _normalize_merge_items(entry_point)
    use_merge = len(merge_items) >= 2
    merge_matched_body = None
    merge_matched_params = None
    if use_merge:
        with connection.cursor() as merge_cur:
            merge_matched_body, merge_matched_params = _build_merge_matched_body_sql(merge_cur, merge_items)
        if not merge_matched_body or not merge_matched_params:
            use_merge = False

    if not use_merge:
        where_clause, where_params = _build_where_clause(entry_point, rootid_field, name_field, request_id_field)

    if use_merge:
        where_params = merge_matched_params
        selected_sql = (
            map_with_lead + "matched AS (" + merge_matched_body + "), selected AS ("
            " SELECT (SELECT ctid FROM matched ORDER BY rootid NULLS LAST LIMIT 1) AS ctid, "
            " (SELECT string_agg(rootid::text, ', ' ORDER BY rootid) FROM matched) AS rootid, "
            " (SELECT string_agg(name::text, ' + ' ORDER BY name NULLS LAST) FROM matched) AS name, "
            " NULL::text AS request_id, "
            " (SELECT customer_legal_person_id FROM matched ORDER BY ctid LIMIT 1) AS customer_legal_person_id, "
            " (SELECT department_legal_person_id FROM matched ORDER BY ctid LIMIT 1) AS department_legal_person_id, "
            " (SELECT customer_legal_person_name FROM matched ORDER BY ctid LIMIT 1) AS customer_legal_person_name, "
            " (SELECT department_legal_person_name FROM matched ORDER BY ctid LIMIT 1) AS department_legal_person_name, "
            " (SELECT startdate FROM matched ORDER BY ctid LIMIT 1) AS startdate, "
            " (SELECT datesurvey FROM matched ORDER BY ctid LIMIT 1) AS datesurvey, "
            " (SELECT createtype FROM matched ORDER BY ctid LIMIT 1) AS createtype, "
            " (SELECT ST_UnaryUnion(ST_Collect(geom)) FROM matched) AS geom "
            ") "
            "SELECT ST_AsGeoJSON(geom), ctid::text, rootid::text, name::text, request_id::text, "
            "customer_legal_person_id::text, department_legal_person_id::text, "
            "customer_legal_person_name::text, department_legal_person_name::text, "
            "startdate::text, datesurvey::text, createtype::text "
            "FROM selected"
        )
        map_layers_cte_open = (
            map_with_lead
            + "matched AS ("
            + merge_matched_body
            + "), selected AS ( SELECT (SELECT ctid FROM matched ORDER BY rootid NULLS LAST LIMIT 1) AS ctid, "
            " (SELECT ST_UnaryUnion(ST_Collect(geom)) FROM matched) AS geom ), "
        )
        neighbor_excl = "t.ctid NOT IN (SELECT ctid FROM matched) AND "
        req_self_excl = "AND NOT (%s = %s AND t.ctid IN (SELECT ctid FROM matched))"
    else:
        selected_sql = (
            map_with_lead + "selected AS ("
            f" SELECT ctid, {rootid_field} AS rootid, {name_field} AS name, {request_id_field} AS request_id, "
            f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr_selected}, {department_name_select_expr_selected}, "
            f"{gis_meta_selected_fragment}, {geom_field} AS geom FROM {table}"
            f" WHERE {where_clause}{hood_sel_and} LIMIT 1"
            ") "
            "SELECT ST_AsGeoJSON(geom), ctid::text, rootid::text, name::text, request_id::text, "
            "customer_legal_person_id::text, department_legal_person_id::text, "
            "customer_legal_person_name::text, department_legal_person_name::text, "
            "startdate::text, datesurvey::text, createtype::text "
            "FROM selected"
        )
        map_layers_cte_open = (
            map_with_lead + "selected AS ("
            f" SELECT ctid, {geom_field} AS geom FROM {table}"
            f" WHERE {where_clause}{hood_sel_and} LIMIT 1"
            "), "
        )
        neighbor_excl = "t.ctid <> s.ctid AND "
        req_self_excl = "AND NOT (%s = %s AND t.ctid = s.ctid)"

    adjacent_dt_sql = _build_map_adjacent_dt_combined_sql(
        map_layers_cte_open,
        dt_table,
        adjacent_geom_field,
        adjacent_rootid_field,
        adjacent_name_field,
        adjacent_request_id_field,
        adjacent_customer_select_expr,
        adjacent_department_select_expr,
        adjacent_owner_select_expr,
        adjacent_customer_name_select_expr,
        adjacent_department_name_select_expr,
        adjacent_owner_name_select_expr,
        gis_meta_dt_fragment,
        adjacent_customer_prop_expr,
        adjacent_department_prop_expr,
        adjacent_owner_prop_expr,
        adjacent_customer_name_prop_expr,
        adjacent_department_name_prop_expr,
        adjacent_owner_name_prop_expr,
        neighbor_excl,
        nearby_meters,
        passport_only_dt_sql,
        hood_ha_adj,
    )
    requests_sql, requests_self_excl_params = _build_map_requests_sql(
        map_layers_cte_open,
        request_layer_sources,
        req_self_excl,
        table,
    )

    map_exec_params = list(hood_params) + list(where_params)

    if only_layer:
        with connection.cursor() as cursor:
            layer_partial = _execute_map_only_layer(
                cursor,
                only_layer,
                map_layers_cte_open=map_layers_cte_open,
                map_exec_params=map_exec_params,
                adjacent_dt_sql=adjacent_dt_sql,
                request_sources_by_key=request_sources_by_key,
                req_self_excl=req_self_excl,
                source_table=table,
            )
        return layer_partial

    with connection.cursor() as cursor:
        cursor.execute(selected_sql, map_exec_params)
        selected_row = cursor.fetchone()
        selected_geometry = selected_row[0] if selected_row else None
        selected_ctid = selected_row[1] if selected_row else None
        selected_rootid = selected_row[2] if selected_row else None
        selected_name = selected_row[3] if selected_row else None
        selected_request_id = selected_row[4] if selected_row else None
        selected_customer_legal_person_id = selected_row[5] if selected_row else None
        selected_department_legal_person_id = selected_row[6] if selected_row else None
        selected_customer_legal_person_name = selected_row[7] if selected_row else None
        selected_department_legal_person_name = selected_row[8] if selected_row else None
        selected_startdate = selected_row[9] if selected_row and len(selected_row) > 9 else None
        selected_datesurvey = selected_row[10] if selected_row and len(selected_row) > 10 else None
        selected_createtype = selected_row[11] if selected_row and len(selected_row) > 11 else None
        if not selected_geometry:
            return None

        if not include_adjacent_layers:
            return {
                "selected": selected_geometry,
                "selected_ctid": selected_ctid,
                "selected_rootid": selected_rootid,
                "selected_name": selected_name,
                "selected_request_id": selected_request_id,
                "selected_customer_legal_person_id": selected_customer_legal_person_id,
                "selected_department_legal_person_id": selected_department_legal_person_id,
                "selected_customer_legal_person_name": selected_customer_legal_person_name,
                "selected_department_legal_person_name": selected_department_legal_person_name,
                "selected_startdate": selected_startdate,
                "selected_datesurvey": selected_datesurvey,
                "selected_createtype": selected_createtype,
                "selected_source_label": source_label,
                "intersects": None,
                "touches": None,
                "nearby": None,
                "request_objects": None,
            }

        cursor.execute(adjacent_dt_sql, map_exec_params)
        adjacent_dt_row = cursor.fetchone()

        requests_row = None
        try:
            requests_params = map_exec_params + requests_self_excl_params
            cursor.execute(requests_sql, requests_params)
            requests_row = cursor.fetchone()
        except Exception:
            logger.exception("_get_map_layers: request_objects layer query failed")

    return {
        "selected": selected_geometry,
        "selected_ctid": selected_ctid,
        "selected_rootid": selected_rootid,
        "selected_name": selected_name,
        "selected_request_id": selected_request_id,
        "selected_customer_legal_person_id": selected_customer_legal_person_id,
        "selected_department_legal_person_id": selected_department_legal_person_id,
        "selected_customer_legal_person_name": selected_customer_legal_person_name,
        "selected_department_legal_person_name": selected_department_legal_person_name,
        "selected_startdate": selected_startdate,
        "selected_datesurvey": selected_datesurvey,
        "selected_createtype": selected_createtype,
        "selected_source_label": source_label,
        "intersects": adjacent_dt_row[0] if adjacent_dt_row else None,
        "touches": None,
        "nearby": None,
        "request_objects": requests_row[0] if requests_row else None,
    }


def _export_geometry_files(geometry, properties=None):
    properties = properties or {}
    export_properties = {
        "name": (properties.get("name") or ""),
        "OwnerLegalPersonId": (
            None if properties.get("OwnerLegalPersonId") is None else str(properties.get("OwnerLegalPersonId"))
        ),
        "request_id": (properties.get("request_id") or ""),
        "recap_id": (properties.get("recap_id") or ""),
    }

    export_root = Path(settings.MEDIA_ROOT) / "exports"
    export_root.mkdir(parents=True, exist_ok=True)
    export_id = uuid.uuid4().hex
    export_dir = export_root / export_id
    export_dir.mkdir(parents=True, exist_ok=True)

    request_id_raw = str(export_properties.get("request_id") or "").strip()
    recap_id_raw = str(export_properties.get("recap_id") or "").strip()
    name_raw = str(export_properties.get("name") or "").strip()
    request_id_safe = re.sub(r"[^\w.-]+", "_", request_id_raw, flags=re.UNICODE).strip("._-")
    recap_id_safe = re.sub(r"[^\w.-]+", "_", recap_id_raw, flags=re.UNICODE).strip("._-")
    name_safe = re.sub(r"[^\w.-]+", "_", name_raw, flags=re.UNICODE).strip("._-")
    if not request_id_safe:
        request_id_safe = "request"
    if not name_safe:
        name_safe = "object"
    request_id_safe = request_id_safe[:80]
    recap_id_safe = recap_id_safe[:80]
    name_safe = name_safe[:120]
    if recap_id_safe:
        base_filename = f"{request_id_safe}_{recap_id_safe}_{name_safe}"
    else:
        base_filename = f"{request_id_safe}_{name_safe}"

    feature = {"type": "Feature", "properties": export_properties, "geometry": geometry}
    feature_collection = {"type": "FeatureCollection", "features": [feature]}
    geojson_path = export_dir / f"{base_filename}.geojson"
    geojson_path.write_text(json.dumps(feature_collection, ensure_ascii=False), encoding="utf-8")

    shp_path = export_dir / f"{base_filename}.shp"
    gdal.SetConfigOption("SHAPE_ENCODING", "UTF-8")
    driver = ogr.GetDriverByName("ESRI Shapefile")
    datasource = driver.CreateDataSource(str(shp_path))
    spatial_ref = osr.SpatialReference()
    spatial_ref.ImportFromEPSG(4326)
    layer = datasource.CreateLayer(
        base_filename[:30],
        spatial_ref,
        ogr.wkbUnknown,
        options=["ENCODING=UTF-8"],
    )
    layer.CreateField(ogr.FieldDefn("id", ogr.OFTInteger))
    layer.CreateField(ogr.FieldDefn("name", ogr.OFTString))
    layer.CreateField(ogr.FieldDefn("owner_id", ogr.OFTString))
    layer.CreateField(ogr.FieldDefn("request_id", ogr.OFTString))
    definition = layer.GetLayerDefn()
    ogr_feature = ogr.Feature(definition)
    ogr_feature.SetField("id", 1)
    ogr_feature.SetField("name", export_properties.get("name") or "")
    ogr_feature.SetField("owner_id", export_properties.get("OwnerLegalPersonId") or "")
    ogr_feature.SetField("request_id", export_properties.get("request_id") or "")
    ogr_geometry = ogr.CreateGeometryFromJson(json.dumps(geometry))
    ogr_feature.SetGeometry(ogr_geometry)
    layer.CreateFeature(ogr_feature)
    ogr_feature = None
    datasource = None

    zip_path = export_dir / f"{base_filename}_shp.zip"
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for ext in ("shp", "shx", "dbf", "prj", "cpg"):
            part = export_dir / f"{base_filename}.{ext}"
            if part.exists():
                archive.write(part, arcname=part.name)

    base_url = settings.MEDIA_URL.rstrip("/")
    geojson_url = f"{base_url}/exports/{export_id}/{base_filename}.geojson"
    shapefile_url = f"{base_url}/exports/{export_id}/{base_filename}_shp.zip"
    return geojson_url, shapefile_url


def _get_new_object_relations(geometry, source_label="ДТ", request_id_filter=None):
    geometry_norm = _to_intersection_geometry(geometry)
    if not geometry_norm:
        raise ValueError("Unsupported geometry payload for relation checks.")
    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, "GIS_ODH_TABLE", "odh")
    ozn_table = getattr(settings, "GIS_OZN_TABLE", "ozn")
    top_table = getattr(settings, "GIS_TOP_TABLE", "top")
    geom_field = settings.GIS_OBJECT_GEOM_FIELD
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    request_id_field = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    customer_field_pref = getattr(settings, "GIS_OBJECT_CUSTOMER_FIELD", "CustomerLegalPersonId")
    department_field_pref = getattr(settings, "GIS_OBJECT_DEPARTMENT_FIELD", "DepartmentLegalPersonId")
    owner_field_pref_dt = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    owner_field_pref_odh = getattr(settings, "GIS_ODH_CUSTOMER_FIELD", "CustomerLegalPersonId")
    owner_field_pref_ozn = getattr(settings, "GIS_OZN_OWNER_FIELD", "ownerlegalpersonalid")
    owner_field_pref_top = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    geometry_json = json.dumps(geometry_norm)

    customer_select_expr = "NULL::text AS customer_legal_person_id"
    department_select_expr = "NULL::text AS department_legal_person_id"
    owner_select_expr = "NULL::text AS owner_legal_person_id"
    customer_name_select_expr = "NULL::text AS customer_legal_person_name"
    department_name_select_expr = "NULL::text AS department_legal_person_name"
    owner_name_select_expr = "NULL::text AS owner_legal_person_name"
    customer_prop_expr = "customer_legal_person_id::text"
    department_prop_expr = "department_legal_person_id::text"
    owner_prop_expr = "owner_legal_person_id::text"
    customer_name_prop_expr = "customer_legal_person_name::text"
    department_name_prop_expr = "department_legal_person_name::text"
    owner_name_prop_expr = "owner_legal_person_name::text"
    request_owner_dt_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_dt_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_odh_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_odh_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_ozn_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_ozn_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_top_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_top_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_customer_dt_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_dt_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_dt_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_dt_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_odh_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_odh_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_odh_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_odh_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_ozn_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_ozn_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_ozn_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_ozn_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_top_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_top_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_top_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_top_name_select_expr = "NULL::text AS department_legal_person_name"
    with connection.cursor() as cursor:
        lookup_context = _get_id_names_lookup_context(cursor)
        if _column_exists(cursor, dt_table, customer_field_pref):
            customer_field = _resolve_column_name(cursor, dt_table, customer_field_pref)
            customer_select_expr = f"t.{_quote_ident(customer_field)}::text AS customer_legal_person_id"
            customer_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, dt_table, department_field_pref):
            department_field = _resolve_column_name(cursor, dt_table, department_field_pref)
            department_select_expr = f"t.{_quote_ident(department_field)}::text AS department_legal_person_id"
            department_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
            request_department_dt_select_expr = (
                f"t.{_quote_ident(department_field)}::text AS department_legal_person_id"
            )
            request_department_dt_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
        if _column_exists(cursor, dt_table, customer_field_pref):
            dt_customer_field = _resolve_column_name(cursor, dt_table, customer_field_pref)
            request_customer_dt_select_expr = f"t.{_quote_ident(dt_customer_field)}::text AS customer_legal_person_id"
            request_customer_dt_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, dt_table, owner_field_pref_dt):
            owner_field = _resolve_column_name(cursor, dt_table, owner_field_pref_dt)
            owner_select_expr = f"t.{_quote_ident(owner_field)}::text AS owner_legal_person_id"
            owner_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, dt_table, owner_field_pref_dt):
            dt_owner_field = _resolve_column_name(cursor, dt_table, owner_field_pref_dt)
            request_owner_dt_select_expr = f"t.{_quote_ident(dt_owner_field)}::text AS owner_legal_person_id"
            request_owner_dt_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, odh_table, owner_field_pref_odh):
            odh_owner_field = _resolve_column_name(cursor, odh_table, owner_field_pref_odh)
            request_owner_odh_select_expr = f"t.{_quote_ident(odh_owner_field)}::text AS owner_legal_person_id"
            request_owner_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, ozn_table, owner_field_pref_ozn):
            ozn_owner_field = _resolve_column_name(cursor, ozn_table, owner_field_pref_ozn)
            request_owner_ozn_select_expr = f"t.{_quote_ident(ozn_owner_field)}::text AS owner_legal_person_id"
            request_owner_ozn_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(ozn_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, top_table, owner_field_pref_top):
            top_owner_field = _resolve_column_name(cursor, top_table, owner_field_pref_top)
            request_owner_top_select_expr = f"t.{_quote_ident(top_owner_field)}::text AS owner_legal_person_id"
            request_owner_top_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(top_owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if _column_exists(cursor, odh_table, customer_field_pref):
            odh_customer_field = _resolve_column_name(cursor, odh_table, customer_field_pref)
            request_customer_odh_select_expr = f"t.{_quote_ident(odh_customer_field)}::text AS customer_legal_person_id"
            request_customer_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, odh_table, department_field_pref):
            odh_department_field = _resolve_column_name(cursor, odh_table, department_field_pref)
            request_department_odh_select_expr = (
                f"t.{_quote_ident(odh_department_field)}::text AS department_legal_person_id"
            )
            request_department_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
        if _column_exists(cursor, top_table, customer_field_pref):
            top_customer_field = _resolve_column_name(cursor, top_table, customer_field_pref)
            request_customer_top_select_expr = f"t.{_quote_ident(top_customer_field)}::text AS customer_legal_person_id"
            request_customer_top_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(top_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, top_table, department_field_pref):
            top_department_field = _resolve_column_name(cursor, top_table, department_field_pref)
            request_department_top_select_expr = (
                f"t.{_quote_ident(top_department_field)}::text AS department_legal_person_id"
            )
            request_department_top_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(top_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )

        dt_meta_fragment = _gis_object_meta_sql_fragment(cursor, dt_table, "t")
        odh_meta_fragment = _gis_object_meta_sql_fragment(cursor, odh_table, "t")
        ozn_meta_fragment = _gis_object_meta_sql_fragment(cursor, ozn_table, "t")
        top_meta_fragment = _gis_object_meta_sql_fragment(cursor, top_table, "t")
        dt_geom_relation = (
            _resolve_column_name(cursor, dt_table, geom_field)
            if _column_exists(cursor, dt_table, geom_field)
            else geom_field
        )
        odh_geom_relation = (
            _resolve_column_name(cursor, odh_table, geom_field)
            if _column_exists(cursor, odh_table, geom_field)
            else dt_geom_relation
        )
        ozn_geom_relation = (
            _resolve_column_name(cursor, ozn_table, geom_field)
            if _column_exists(cursor, ozn_table, geom_field)
            else dt_geom_relation
        )
        top_geom_relation = (
            _resolve_column_name(cursor, top_table, geom_field)
            if _column_exists(cursor, top_table, geom_field)
            else dt_geom_relation
        )

        new_obj_req_cols_dt = _resolve_request_layer_columns(
            cursor, dt_table, geom_field, rootid_field, name_field, request_id_field
        )
        new_obj_req_cols_odh = _resolve_request_layer_columns(
            cursor, odh_table, geom_field, rootid_field, name_field, request_id_field
        )
        new_obj_req_cols_ozn = _resolve_request_layer_columns(
            cursor, ozn_table, geom_field, rootid_field, name_field, request_id_field
        )
        new_obj_req_cols_top = _resolve_request_layer_columns(
            cursor, top_table, geom_field, rootid_field, name_field, request_id_field
        )
        passport_only_dt_sql = _sql_gis_passport_only_clause(cursor, dt_table, "t")

    hood_full_pfx, hood_prm = get_hood_cte_prefix_sql()
    new_obj_with_open = (hood_full_pfx + "input AS (") if hood_full_pfx else "WITH input AS ("
    nearby_meters = _adjacent_nearby_meters()
    hood_ha_new = get_hood_intersects_ha_sql(f"t.{_quote_ident(dt_geom_relation)}")
    hood_ha_odh_new = get_hood_intersects_ha_sql(f"t.{_quote_ident(odh_geom_relation)}")
    hood_ha_ozn_new = get_hood_intersects_ha_sql(f"t.{_quote_ident(ozn_geom_relation)}")
    hood_ha_top_new = get_hood_intersects_ha_sql(f"t.{_quote_ident(top_geom_relation)}")

    new_object_request_sources = []
    if new_obj_req_cols_dt:
        new_object_request_sources.append(
            {
                **new_obj_req_cols_dt,
                "table": dt_table,
                "source_label": "ДТ",
                "hood_ha": hood_ha_new,
                "meta": dt_meta_fragment,
                "owner_select": request_owner_dt_select_expr,
                "owner_name_select": request_owner_dt_name_select_expr,
                "customer_select": request_customer_dt_select_expr,
                "department_select": request_department_dt_select_expr,
                "customer_name_select": request_customer_dt_name_select_expr,
                "department_name_select": request_department_dt_name_select_expr,
            }
        )
    if new_obj_req_cols_odh:
        new_object_request_sources.append(
            {
                **new_obj_req_cols_odh,
                "table": odh_table,
                "source_label": "ОДХ",
                "hood_ha": hood_ha_odh_new,
                "meta": odh_meta_fragment,
                "owner_select": request_owner_odh_select_expr,
                "owner_name_select": request_owner_odh_name_select_expr,
                "customer_select": request_customer_odh_select_expr,
                "department_select": request_department_odh_select_expr,
                "customer_name_select": request_customer_odh_name_select_expr,
                "department_name_select": request_department_odh_name_select_expr,
            }
        )
    if new_obj_req_cols_ozn:
        new_object_request_sources.append(
            {
                **new_obj_req_cols_ozn,
                "table": ozn_table,
                "source_label": "ОЗН",
                "hood_ha": hood_ha_ozn_new,
                "meta": ozn_meta_fragment,
                "owner_select": request_owner_ozn_select_expr,
                "owner_name_select": request_owner_ozn_name_select_expr,
                "customer_select": request_customer_ozn_select_expr,
                "department_select": request_department_ozn_select_expr,
                "customer_name_select": request_customer_ozn_name_select_expr,
                "department_name_select": request_department_ozn_name_select_expr,
            }
        )
    if new_obj_req_cols_top:
        new_object_request_sources.append(
            {
                **new_obj_req_cols_top,
                "table": top_table,
                "source_label": _top_source_label(),
                "hood_ha": hood_ha_top_new,
                "meta": top_meta_fragment,
                "owner_select": request_owner_top_select_expr,
                "owner_name_select": request_owner_top_name_select_expr,
                "customer_select": request_customer_top_select_expr,
                "department_select": request_department_top_select_expr,
                "customer_name_select": request_customer_top_name_select_expr,
                "department_name_select": request_department_top_name_select_expr,
            }
        )

    dt_geom_ref = f"t.{geom_field}"
    adjacent_dt_sql = (
        new_obj_with_open + f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr}, {dt_meta_fragment} "
        f"FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE"
        + _sql_within_meters_where(dt_geom_ref, "i.geom", str(nearby_meters))
        + "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"{passport_only_dt_sql}"
        f"{hood_ha_new}"
        ") "
        "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', jsonb_build_object("
        "       'rootid', rootid::text,"
        "       'name', name::text,"
        "       'request_id', request_id::text,"
        f"      'customer_legal_person_id', {customer_prop_expr},"
        f"      'department_legal_person_id', {department_prop_expr},"
        f"      'owner_legal_person_id', {owner_prop_expr},"
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr},"
        f"      'owner_legal_person_name', {owner_name_prop_expr},"
        "       'startdate', startdate::text,"
        "       'datesurvey', datesurvey::text,"
        "       'createtype', createtype::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    request_objects_sql = _build_new_object_request_objects_sql(
        new_obj_with_open,
        new_object_request_sources,
    )

    new_obj_exec_params = list(hood_prm) + [geometry_json]

    with connection.cursor() as cursor:
        cursor.execute(adjacent_dt_sql, new_obj_exec_params)
        intersects_row = cursor.fetchone()
        nearby_row = None
        request_objects_row = None
        try:
            cursor.execute(request_objects_sql, new_obj_exec_params)
            request_objects_row = cursor.fetchone()
        except Exception:
            logger.exception("_get_new_object_relations: request_objects layer query failed")
    ref_layers = _get_reference_layers(
        geometry=geometry_norm,
        request_id_filter=request_id_filter,
    )

    dgi_intersects = None
    odh_intersects = None
    dgi_table_name = getattr(settings, "GIS_DGI_TABLE", "dgi")
    odh_table_name = getattr(settings, "GIS_ODH_TABLE", "odh")
    try:
        with connection.cursor() as cursor:
            dgi_table_ok = _table_exists(cursor, dgi_table_name)
        if dgi_table_ok:
            dgi_intersects = _get_reference_layer_geojson(
                dgi_table_name, "ДГИ", geometry=geometry_norm, intersects_only=True
            )
    except Exception:
        logger.exception("_get_new_object_relations: dgi_intersects failed")
        dgi_intersects = None
    try:
        with connection.cursor() as cursor:
            odh_table_ok = _table_exists(cursor, odh_table_name)
        if odh_table_ok:
            odh_intersects = _get_reference_layer_geojson(
                odh_table_name, "ОДХ", geometry=geometry_norm, intersects_only=True
            )
    except Exception:
        logger.exception("_get_new_object_relations: odh_intersects failed")
        odh_intersects = None

    return {
        "intersects": intersects_row[0] if intersects_row else None,
        "touches": None,
        "nearby": nearby_row[0] if nearby_row else None,
        "request_objects": request_objects_row[0] if request_objects_row else None,
        "dgi_moscow_rent": ref_layers["dgi_moscow_rent"],
        "dgi_moscow_no_rent": ref_layers["dgi_moscow_no_rent"],
        "dgi_private_rent": ref_layers["dgi_private_rent"],
        "dgi_private_no_rent": ref_layers["dgi_private_no_rent"],
        "odh": ref_layers["odh"],
        "ozn": ref_layers["ozn"],
        "renew": ref_layers["renew"],
        "recaps": ref_layers["recaps"],
        "oozt": ref_layers["oozt"],
        "rzd": ref_layers["rzd"],
        "top": ref_layers["top"],
        "dgi_intersects": dgi_intersects,
        "odh_intersects": odh_intersects,
    }


def _get_layer_intersection_percent(geometry, table_name, extra_where_sql: str = "", *, table_alias: str = "d"):
    """Overlap percent of ``geometry`` with rows from ``table_name`` (optional SQL AND-filter)."""
    geometry_norm = _to_intersection_geometry(geometry)
    if not geometry_norm or not table_name:
        return 0.0
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    geometry_json = json.dumps(geometry_norm)
    alias = table_alias or "d"
    try:
        with connection.cursor() as cursor:
            if not _table_exists(cursor, table_name):
                return 0.0
            if not _column_exists(cursor, table_name, geom_field_pref):
                return 0.0
            geom_field = _resolve_column_name(cursor, table_name, geom_field_pref)
            raw_geom = f"{alias}.{_quote_ident(geom_field)}"
            # Invalid source rows (esp. rzd) raise TopologyException on ST_Intersects
            # unless repaired; bbox prefilter stays on the raw column for index use.
            geom_expr = f"ST_MakeValid({raw_geom})"
            hood_suf, hood_params = get_hood_intersects_sql_suffix(geom_expr)
            query = (
                "WITH input AS ("
                f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                "), input_area AS ("
                " SELECT ST_Area(geom::geography) AS total_area FROM input"
                "), layer_intersections AS ("
                f" SELECT ST_CollectionExtract(ST_MakeValid(ST_Intersection({geom_expr}, i.geom)), 3) AS geom"
                f" FROM {_quote_ident(table_name)} {alias}, input i"
                f" WHERE {raw_geom} && i.geom"
                f" AND ST_Intersects({geom_expr}, i.geom)"
                f"{hood_suf}"
                f"{extra_where_sql}"
                "), overlap AS ("
                " SELECT ST_Area(COALESCE(ST_UnaryUnion(ST_Collect(geom)), ST_GeomFromText('POLYGON EMPTY', 4326))::geography) AS overlap_area"
                " FROM layer_intersections"
                " WHERE geom IS NOT NULL AND NOT ST_IsEmpty(geom)"
                ") "
                "SELECT CASE "
                "  WHEN ia.total_area IS NULL OR ia.total_area = 0 THEN 0 "
                "  ELSE LEAST(100.0, (COALESCE(o.overlap_area, 0) * 100.0) / ia.total_area) "
                "END AS overlap_percent "
                "FROM input_area ia CROSS JOIN overlap o"
            )
            cursor.execute(query, [geometry_json] + hood_params)
            row = cursor.fetchone()
            return float(row[0]) if row and row[0] is not None else 0.0
    except Exception:
        logger.exception(
            "_get_layer_intersection_percent failed for table=%s",
            table_name,
        )
        return 0.0


def _get_dgi_intersection_percent(geometry, extra_where_sql: str = ""):
    return _get_layer_intersection_percent(
        geometry,
        getattr(settings, "GIS_DGI_TABLE", "dgi"),
        extra_where_sql,
        table_alias="d",
    )


def _get_dgi_intersection_percents_split(geometry):
    geometry_norm = _to_intersection_geometry(geometry)
    if not geometry_norm:
        raise ValueError("Unsupported geometry payload for DGI intersection percent.")
    dgi_table = getattr(settings, "GIS_DGI_TABLE", "dgi")
    renew_table = getattr(settings, "GIS_RENEW_TABLE", "renew")
    oozt_table = getattr(settings, "GIS_OOZT_TABLE", "oozt")
    rzd_table = getattr(settings, "GIS_RZD_TABLE", "rzd")
    with connection.cursor() as cursor:
        moscow_where = _sql_dgi_ownership_filter(cursor, dgi_table, "moscow", table_alias="d")
        private_where = _sql_dgi_ownership_filter(cursor, dgi_table, "private", table_alias="d")
        layer_filters = {
            layer_key: _sql_dgi_layer_filter(cursor, dgi_table, layer_key, table_alias="d")
            for layer_key in DGI_LAYER_KEYS
        }
    result = {
        "moscow": _get_layer_intersection_percent(geometry_norm, dgi_table, moscow_where),
        "private": _get_layer_intersection_percent(geometry_norm, dgi_table, private_where),
        "renew": _get_layer_intersection_percent(geometry_norm, renew_table),
        "oozt": _get_layer_intersection_percent(geometry_norm, oozt_table),
        "rzd": _get_layer_intersection_percent(geometry_norm, rzd_table),
    }
    for layer_key, extra_where in layer_filters.items():
        result[layer_key] = _get_layer_intersection_percent(geometry_norm, dgi_table, extra_where)
    return result


def _is_meaningful_gis_rootid(rootid):
    text = str(rootid or "").strip()
    return bool(text) and text.lower() not in {"-", "none", "null"}


def _municipal_request_mask_tables():
    return (
        (settings.GIS_OBJECT_TABLE, "ДТ"),
        (getattr(settings, "GIS_ODH_TABLE", "odh"), "ОДХ"),
        (getattr(settings, "GIS_OZN_TABLE", "ozn"), "ОЗН"),
        (getattr(settings, "GIS_TOP_TABLE", "top"), _top_source_label()),
    )


def _token_to_municipal_source_label(token):
    return {
        "dt": "ДТ",
        "odh": "ОДХ",
        "ozn": "ОЗН",
        "top": _top_source_label(),
    }.get(token)


def _append_intersection_mask_union_part(
    cursor,
    table_name,
    union_parts,
    query_params,
    *,
    table_source_label,
    normalized_source,
    selected_geometry_json,
    selected_row_ctid_text,
    selected_rootid_text,
    selected_request_id_text,
    extra_where_sql="",
    page_type=None,
):
    if not table_name or not _table_exists(cursor, table_name):
        return
    geom_field = _resolve_column_name(cursor, table_name, settings.GIS_OBJECT_GEOM_FIELD)
    geom_q = _quote_ident(geom_field)
    raw_geom = f"t.{geom_q}"
    geom_v = _sql_table_geom_valid_expr(raw_geom)
    exclude_selected_clause = ""
    exclude_selected_params = []
    skip_selected_exclusion = _normalize_auto_remove_page_type(page_type) == "add_recap"
    if table_source_label and normalized_source == table_source_label and not skip_selected_exclusion:
        exclude_conditions = []
        if selected_row_ctid_text:
            exclude_conditions.append("t.ctid::text = %s")
            exclude_selected_params.append(selected_row_ctid_text)
        elif _is_meaningful_gis_rootid(selected_rootid_text):
            rootid_field = _resolve_column_name(cursor, table_name, settings.GIS_OBJECT_ROOTID_FIELD)
            exclude_conditions.append(f"t.{_quote_ident(rootid_field)}::text = %s")
            exclude_selected_params.append(selected_rootid_text)
        elif selected_request_id_text:
            request_id_field = _resolve_column_name(
                cursor,
                table_name,
                getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id"),
            )
            exclude_conditions.append(f"t.{_quote_ident(request_id_field)}::text = %s")
            exclude_selected_params.append(selected_request_id_text)
        if selected_geometry_json:
            exclude_conditions.append(f"(s.geom IS NOT NULL AND ST_Equals({geom_v}, s.geom))")
        if exclude_conditions:
            exclude_selected_clause = " AND NOT (" + " OR ".join(exclude_conditions) + ")"
    hood_m_suf, hood_m_prm = get_hood_intersects_sql_suffix(geom_v)
    union_parts.append(
        f"SELECT ST_CollectionExtract({geom_v}, 3) AS geom "
        f"FROM {_quote_ident(table_name)} t, input i"
        f"{' LEFT JOIN selected s ON TRUE' if selected_geometry_json else ''} "
        f"WHERE {raw_geom} && i.geom"
        f" AND ST_Intersects({geom_v}, i.geom)"
        f" AND ST_Area(ST_Intersection({geom_v}, i.geom)) > 1e-10"
        f"{extra_where_sql}"
        f"{exclude_selected_clause}"
        f"{hood_m_suf}"
    )
    query_params.extend(exclude_selected_params)
    query_params.extend(hood_m_prm)


def _remove_intersections_from_geometry(
    geometry,
    selected_sources,
    source_label="ДТ",
    selected_geometry=None,
    selected_rootid="",
    selected_request_id="",
    selected_row_ctid="",
    page_type=None,
):
    geometry_norm = _to_intersection_geometry(geometry)
    if not geometry_norm:
        return None, 0.0

    source_tokens = {str(value).strip().lower() for value in (selected_sources or []) if str(value).strip()}
    allowed_tokens = {
        "dt",
        "odh",
        "ozn",
        "top",
        "requests",
        "dgi_moscow_rent",
        "dgi_moscow_no_rent",
        "dgi_private_rent",
        "dgi_private_no_rent",
        "renew",
        "oozt",
        "rzd",
    }
    requested_tokens = [
        token
        for token in (
            "dt",
            "odh",
            "ozn",
            "top",
            "requests",
            "dgi_moscow_rent",
            "dgi_moscow_no_rent",
            "dgi_private_rent",
            "dgi_private_no_rent",
            "renew",
            "oozt",
            "rzd",
        )
        if token in source_tokens and token in allowed_tokens
    ]
    if not requested_tokens:
        return geometry_norm, 0.0

    selected_geometry_norm = _to_intersection_geometry(selected_geometry)
    selected_rootid_text = str(selected_rootid or "").strip()
    selected_request_id_text = str(selected_request_id or "").strip()
    selected_row_ctid_text = str(selected_row_ctid or "").strip()
    geometry_json = json.dumps(geometry_norm)
    selected_geometry_json = json.dumps(selected_geometry_norm) if selected_geometry_norm else None
    normalized_source = _normalize_source_label(source_label)

    token_to_table = {
        "dt": settings.GIS_OBJECT_TABLE,
        "odh": getattr(settings, "GIS_ODH_TABLE", "odh"),
        "ozn": getattr(settings, "GIS_OZN_TABLE", "ozn"),
        "dgi_moscow_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "dgi_moscow_no_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "dgi_private_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "dgi_private_no_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "renew": getattr(settings, "GIS_RENEW_TABLE", "renew"),
        "oozt": getattr(settings, "GIS_OOZT_TABLE", "oozt"),
        "rzd": getattr(settings, "GIS_RZD_TABLE", "rzd"),
        "top": getattr(settings, "GIS_TOP_TABLE", "top"),
    }

    union_parts = []
    query_params = [geometry_json]
    if selected_geometry_json:
        query_params.append(selected_geometry_json)

    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    page_type_norm = _normalize_auto_remove_page_type(page_type)
    mask_context = {
        "normalized_source": normalized_source,
        "selected_geometry_json": selected_geometry_json,
        "selected_row_ctid_text": selected_row_ctid_text,
        "selected_rootid_text": selected_rootid_text,
        "selected_request_id_text": selected_request_id_text,
        "page_type": page_type_norm,
    }

    with connection.cursor() as cursor:
        for token in requested_tokens:
            if token == "requests":
                for table_name, table_source_label in _municipal_request_mask_tables():
                    if not _request_layer_source_ready(cursor, table_name, geom_field_pref, request_id_field_pref):
                        continue
                    _append_intersection_mask_union_part(
                        cursor,
                        table_name,
                        union_parts,
                        query_params,
                        table_source_label=table_source_label,
                        extra_where_sql=_sql_gis_request_only_clause(cursor, table_name, "t"),
                        **mask_context,
                    )
                continue
            table_name = token_to_table.get(token)
            table_source_label = _token_to_municipal_source_label(token)
            extra_where = ""
            if token in DGI_LAYER_SPECS:
                extra_where = _sql_dgi_layer_filter(cursor, table_name, token)
            _append_intersection_mask_union_part(
                cursor,
                table_name,
                union_parts,
                query_params,
                table_source_label=table_source_label,
                extra_where_sql=extra_where,
                **mask_context,
            )

        if not union_parts:
            return geometry_norm, 0.0

        query = (
            "WITH input AS ("
            f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
            ")"
            + (
                f", selected AS ( SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom)"
                if selected_geometry_json
                else ""
            )
            + ", mask_parts AS ("
            + " UNION ALL ".join(union_parts)
            + "), mask_union AS ("
            " SELECT ST_UnaryUnion(ST_Collect(geom)) AS geom FROM mask_parts WHERE geom IS NOT NULL"
            "), result AS ("
            " SELECT CASE "
            "   WHEN mu.geom IS NULL OR ST_IsEmpty(mu.geom) THEN i.geom "
            "   ELSE ST_CollectionExtract(ST_MakeValid(ST_Difference(i.geom, mu.geom)), 3) "
            " END AS geom "
            " FROM input i CROSS JOIN mask_union mu"
            ") "
            "SELECT CASE "
            " WHEN r.geom IS NULL OR ST_IsEmpty(r.geom) THEN NULL "
            " ELSE ST_AsGeoJSON(r.geom)::text "
            "END, "
            "ROUND("
            " GREATEST("
            "   COALESCE(ST_Area(i.geom::geography), 0) - COALESCE(ST_Area(r.geom::geography), 0),"
            "   0"
            " )::numeric, 1) "
            "FROM result r "
            "CROSS JOIN input i"
        )
        cursor.execute(query, query_params)
        row = cursor.fetchone()

    if not row or not row[0]:
        return None, 0.0
    try:
        summ_m2 = float(row[1]) if row[1] is not None else 0.0
        return json.loads(row[0]), summ_m2
    except (TypeError, json.JSONDecodeError, ValueError):
        return None, 0.0


_AUTO_REMOVE_SQUARE_M2_DECIMALS = 1
_AUTO_REMOVE_PAGE_TYPES = frozenset({"add_object", "main", "add_recap"})


def _auto_remove_square_table_name():
    return getattr(settings, "GIS_AUTO_REMOVE_SQUARE_TABLE", "auto_remove_square")


def _float_area_m2(value):
    if value is None:
        return 0.0
    return float(value)


def _normalize_auto_remove_page_type(value):
    page_type = str(value or "").strip().lower()
    if page_type in _AUTO_REMOVE_PAGE_TYPES:
        return page_type
    return None


def _auto_remove_source_tokens(selected_sources):
    source_tokens = {str(value).strip().lower() for value in (selected_sources or []) if str(value).strip()}
    allowed_tokens = {
        "dt",
        "odh",
        "ozn",
        "top",
        "requests",
        "dgi_moscow_rent",
        "dgi_moscow_no_rent",
        "dgi_private_rent",
        "dgi_private_no_rent",
        "renew",
        "oozt",
        "rzd",
    }
    return [
        token
        for token in (
            "dt",
            "odh",
            "ozn",
            "top",
            "requests",
            "dgi_moscow_rent",
            "dgi_moscow_no_rent",
            "dgi_private_rent",
            "dgi_private_no_rent",
            "renew",
            "oozt",
            "rzd",
        )
        if token in source_tokens and token in allowed_tokens
    ]


def _auto_remove_mask_context(
    source_label,
    selected_geometry,
    selected_rootid,
    selected_request_id,
    selected_row_ctid,
    page_type=None,
):
    selected_geometry_norm = _to_intersection_geometry(selected_geometry)
    selected_geometry_json = json.dumps(selected_geometry_norm) if selected_geometry_norm else None
    return {
        "normalized_source": _normalize_source_label(source_label),
        "selected_geometry_json": selected_geometry_json,
        "selected_row_ctid_text": str(selected_row_ctid or "").strip(),
        "selected_rootid_text": str(selected_rootid or "").strip(),
        "selected_request_id_text": str(selected_request_id or "").strip(),
        "page_type": _normalize_auto_remove_page_type(page_type),
    }


def _append_auto_remove_mask_parts(
    cursor,
    requested_tokens,
    union_parts,
    query_params,
    mask_context,
    *,
    allowed_tokens=None,
    requests_table_names=None,
):
    if not requested_tokens:
        return

    token_filter = set(allowed_tokens) if allowed_tokens is not None else None
    requests_tables_filter = set(requests_table_names) if requests_table_names is not None else None

    token_to_table = {
        "dt": settings.GIS_OBJECT_TABLE,
        "odh": getattr(settings, "GIS_ODH_TABLE", "odh"),
        "ozn": getattr(settings, "GIS_OZN_TABLE", "ozn"),
        "dgi_moscow_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "dgi_moscow_no_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "dgi_private_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "dgi_private_no_rent": getattr(settings, "GIS_DGI_TABLE", "dgi"),
        "renew": getattr(settings, "GIS_RENEW_TABLE", "renew"),
        "oozt": getattr(settings, "GIS_OOZT_TABLE", "oozt"),
        "rzd": getattr(settings, "GIS_RZD_TABLE", "rzd"),
        "top": getattr(settings, "GIS_TOP_TABLE", "top"),
    }
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")

    for token in requested_tokens:
        if token_filter is not None and token not in token_filter:
            continue
        if token == "requests":
            for table_name, table_source_label in _municipal_request_mask_tables():
                if requests_tables_filter is not None and table_name not in requests_tables_filter:
                    continue
                if not _request_layer_source_ready(cursor, table_name, geom_field_pref, request_id_field_pref):
                    continue
                _append_intersection_mask_union_part(
                    cursor,
                    table_name,
                    union_parts,
                    query_params,
                    table_source_label=table_source_label,
                    extra_where_sql=_sql_gis_request_only_clause(cursor, table_name, "t"),
                    **mask_context,
                )
            continue
        table_name = token_to_table.get(token)
        table_source_label = _token_to_municipal_source_label(token)
        extra_where = ""
        if token in DGI_LAYER_SPECS:
            extra_where = _sql_dgi_layer_filter(cursor, table_name, token)
        _append_intersection_mask_union_part(
            cursor,
            table_name,
            union_parts,
            query_params,
            table_source_label=table_source_label,
            extra_where_sql=extra_where,
            **mask_context,
        )


def _measure_mask_overlap_m2(cursor, union_parts, query_params, selected_geometry_json):
    if not union_parts:
        return 0.0
    decimals = _AUTO_REMOVE_SQUARE_M2_DECIMALS
    query = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        ")"
        + (
            f", selected AS ( SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom)"
            if selected_geometry_json
            else ""
        )
        + ", mask_parts AS ("
        + " UNION ALL ".join(union_parts)
        + "), overlap_parts AS ("
        " SELECT ST_CollectionExtract(ST_Intersection(i.geom, mp.geom), 3) AS geom "
        " FROM mask_parts mp "
        " CROSS JOIN input i "
        " WHERE mp.geom IS NOT NULL "
        "   AND NOT ST_IsEmpty(mp.geom) "
        "   AND ST_Intersects(i.geom, mp.geom)"
        + "), overlap_union AS ("
        " SELECT ST_UnaryUnion(ST_Collect(geom)) AS geom "
        " FROM overlap_parts "
        " WHERE geom IS NOT NULL AND NOT ST_IsEmpty(geom)"
        ") "
        "SELECT ROUND("
        " COALESCE(ST_Area(geom::geography), 0)::numeric,"
        f" {decimals}"
        ") "
        "FROM overlap_union "
        "WHERE geom IS NOT NULL AND NOT ST_IsEmpty(geom)"
    )
    cursor.execute(query, query_params)
    row = cursor.fetchone()
    return _float_area_m2(row[0] if row else None)


def _measure_summ_m2(cursor, geometry_json, cleaned_geometry_json):
    decimals = _AUTO_REMOVE_SQUARE_M2_DECIMALS
    query = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), result AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), removed AS ("
        " SELECT ST_CollectionExtract("
        "   ST_MakeValid(ST_Difference(i.geom, r.geom)),"
        "   3"
        " ) AS geom "
        " FROM input i "
        " CROSS JOIN result r"
        ") "
        "SELECT ROUND("
        " COALESCE(ST_Area(geom::geography), 0)::numeric,"
        f" {decimals}"
        ") "
        "FROM removed "
        "WHERE geom IS NOT NULL AND NOT ST_IsEmpty(geom)"
    )
    cursor.execute(query, [geometry_json, cleaned_geometry_json])
    row = cursor.fetchone()
    if row and row[0] is not None:
        return _float_area_m2(row[0])
    query_fallback = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), result AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        ") "
        "SELECT ROUND("
        " GREATEST("
        "   COALESCE(ST_Area(i.geom::geography), 0) - COALESCE(ST_Area(r.geom::geography), 0),"
        "   0"
        " )::numeric,"
        f" {decimals}"
        ") "
        "FROM input i CROSS JOIN result r"
    )
    cursor.execute(query_fallback, [geometry_json, cleaned_geometry_json])
    row = cursor.fetchone()
    return _float_area_m2(row[0] if row else None)


def _measure_auto_remove_squares_m2(
    geometry,
    cleaned_geometry,
    selected_sources,
    source_label="ДТ",
    selected_geometry=None,
    selected_rootid="",
    selected_request_id="",
    selected_row_ctid="",
    summ_m2=None,
    page_type=None,
):
    geometry_norm = _to_intersection_geometry(geometry)
    cleaned_norm = _to_intersection_geometry(cleaned_geometry)
    if not geometry_norm or not cleaned_norm:
        return {
            "dt": 0.0,
            "odh": 0.0,
            "ozn": 0.0,
            "top": 0.0,
            "oozt": 0.0,
            "dgi": 0.0,
            "renew": 0.0,
            "rzd": 0.0,
            "summ": 0.0,
        }

    requested_tokens = _auto_remove_source_tokens(selected_sources)
    if not requested_tokens:
        return {
            "dt": 0.0,
            "odh": 0.0,
            "ozn": 0.0,
            "top": 0.0,
            "oozt": 0.0,
            "dgi": 0.0,
            "renew": 0.0,
            "rzd": 0.0,
            "summ": 0.0,
        }

    geometry_json = json.dumps(geometry_norm)
    cleaned_geometry_json = json.dumps(cleaned_norm)
    mask_context = _auto_remove_mask_context(
        source_label,
        selected_geometry,
        selected_rootid,
        selected_request_id,
        selected_row_ctid,
        page_type=page_type,
    )
    selected_geometry_json = mask_context["selected_geometry_json"]

    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, "GIS_ODH_TABLE", "odh")
    ozn_table = getattr(settings, "GIS_OZN_TABLE", "ozn")
    top_table = getattr(settings, "GIS_TOP_TABLE", "top")

    column_specs = {
        "dt": ({"dt", "requests"}, {dt_table}),
        "odh": ({"odh", "requests"}, {odh_table}),
        "ozn": ({"ozn", "requests"}, {ozn_table}),
        "top": ({"top", "requests"}, {top_table}),
        "oozt": ({"oozt"}, None),
        "dgi": (set(DGI_LAYER_KEYS), None),
        "renew": ({"renew"}, None),
        "rzd": ({"rzd"}, None),
    }

    areas = {key: 0.0 for key in ("dt", "odh", "ozn", "top", "oozt", "dgi", "renew", "rzd", "summ")}

    with connection.cursor() as cursor:
        if summ_m2 is not None:
            areas["summ"] = _float_area_m2(summ_m2)
        else:
            areas["summ"] = _measure_summ_m2(cursor, geometry_json, cleaned_geometry_json)

        for column_key, (allowed, requests_tables) in column_specs.items():
            union_parts = []
            query_params = [geometry_json]
            if selected_geometry_json:
                query_params.append(selected_geometry_json)
            _append_auto_remove_mask_parts(
                cursor,
                requested_tokens,
                union_parts,
                query_params,
                mask_context,
                allowed_tokens=allowed,
                requests_table_names=requests_tables,
            )
            areas[column_key] = _measure_mask_overlap_m2(
                cursor, union_parts, query_params, selected_geometry_json
            )

    return areas


def _insert_auto_remove_square(username, owner_legal_person_id, areas, page_type=None):
    table = _auto_remove_square_table_name()
    with connection.cursor() as cursor:
        if not _table_exists(cursor, table):
            logger.warning("_insert_auto_remove_square: table %s not found", table)
            return False
        t = _quote_ident(table)
        cursor.execute(
            f"""
            INSERT INTO {t} (
                "user", ownerlegalpersonalid, "type",
                dt, odh, ozn, top, oozt, dgi, renew, rzd, summ
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            [
                username,
                str(owner_legal_person_id) if owner_legal_person_id is not None else None,
                page_type,
                areas.get("dt", 0.0),
                areas.get("odh", 0.0),
                areas.get("ozn", 0.0),
                areas.get("top", 0.0),
                areas.get("oozt", 0.0),
                areas.get("dgi", 0.0),
                areas.get("renew", 0.0),
                areas.get("rzd", 0.0),
                areas.get("summ", 0.0),
            ],
        )
    return True


def _to_geojson_geometry(geometry):
    if not isinstance(geometry, dict):
        return None
    geo_type = geometry.get("type")
    if geo_type == "Feature":
        feature_geom = geometry.get("geometry")
        return feature_geom if isinstance(feature_geom, dict) else None
    if geo_type == "FeatureCollection":
        geometries = []
        for feature in geometry.get("features") or []:
            feature_geom = (feature or {}).get("geometry")
            if isinstance(feature_geom, dict):
                geometries.append(feature_geom)
        if not geometries:
            return None
        if len(geometries) == 1:
            return geometries[0]
        return {"type": "GeometryCollection", "geometries": geometries}
    if geo_type in {"Polygon", "MultiPolygon", "GeometryCollection", "LineString", "MultiLineString"}:
        return geometry
    return None


def _cut_geometry_with_shape(base_geometry, cutter_geometry, cutter_type="polygon"):
    base_geometry_norm = _to_intersection_geometry(base_geometry)
    cutter_geometry_norm = _to_geojson_geometry(cutter_geometry)
    if not base_geometry_norm or not cutter_geometry_norm:
        return None

    cutter_type_norm = str(cutter_type or "").strip().lower()
    base_geometry_json = json.dumps(base_geometry_norm)
    cutter_geometry_json = json.dumps(cutter_geometry_norm)

    with connection.cursor() as cursor:
        if cutter_type_norm == "line":
            query = (
                "WITH base AS ("
                f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                "), cutter_raw AS ("
                " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
                "), cutter_line AS ("
                " SELECT ST_LineMerge(ST_CollectionExtract(ST_MakeValid(geom), 2)) AS geom FROM cutter_raw"
                "), result AS ("
                " SELECT ST_CollectionExtract(ST_MakeValid(ST_Split(b.geom, cl.geom)), 3) AS geom "
                " FROM base b CROSS JOIN cutter_line cl"
                " WHERE cl.geom IS NOT NULL AND NOT ST_IsEmpty(cl.geom)"
                ") "
                "SELECT CASE "
                " WHEN r.geom IS NULL OR ST_IsEmpty(r.geom) THEN ST_AsGeoJSON((SELECT geom FROM base))::text "
                " ELSE ST_AsGeoJSON(r.geom)::text "
                "END "
                "FROM result r "
                "UNION ALL "
                "SELECT ST_AsGeoJSON((SELECT geom FROM base))::text "
                "WHERE NOT EXISTS (SELECT 1 FROM result) "
                "LIMIT 1"
            )
            cursor.execute(query, [base_geometry_json, cutter_geometry_json])
        else:
            query = (
                "WITH base AS ("
                f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                "), cutter_raw AS ("
                f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                "), result AS ("
                " SELECT ST_CollectionExtract(ST_MakeValid(ST_Difference(b.geom, c.geom)), 3) AS geom "
                " FROM base b CROSS JOIN cutter_raw c"
                ") "
                "SELECT CASE "
                " WHEN r.geom IS NULL OR ST_IsEmpty(r.geom) THEN NULL "
                " ELSE ST_AsGeoJSON(r.geom)::text "
                "END "
                "FROM result r"
            )
            cursor.execute(query, [base_geometry_json, cutter_geometry_json])
        row = cursor.fetchone()
    if not row or not row[0]:
        return None
    try:
        return json.loads(row[0])
    except (TypeError, json.JSONDecodeError):
        return None


def _to_intersection_geometry(geometry):
    if not isinstance(geometry, dict):
        return None
    geo_type = geometry.get("type")
    if geo_type == "Feature":
        feature_geom = geometry.get("geometry")
        return feature_geom if isinstance(feature_geom, dict) else None
    if geo_type == "FeatureCollection":
        geometries = []
        for feature in geometry.get("features") or []:
            feature_geom = (feature or {}).get("geometry")
            if isinstance(feature_geom, dict):
                geometries.append(feature_geom)
        if not geometries:
            return None
        if len(geometries) == 1:
            return geometries[0]
        return {"type": "GeometryCollection", "geometries": geometries}
    if geo_type in {"Polygon", "MultiPolygon", "GeometryCollection"}:
        return geometry
    return None


def _simplify_geojson_for_editing(geojson_text, tolerance_meters=0.75):
    if not geojson_text:
        return None
    try:
        payload = json.loads(geojson_text) if isinstance(geojson_text, str) else geojson_text
    except (TypeError, json.JSONDecodeError):
        return None
    if not isinstance(payload, dict):
        return None

    def _simplify_single_geometry(geometry):
        if not isinstance(geometry, dict):
            return geometry
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT ST_AsGeoJSON(
                    ST_Transform(
                        ST_SimplifyPreserveTopology(
                            ST_Transform(
                                ST_UnaryUnion(ST_MakeValid(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))),
                                3857
                            ),
                            %s
                        ),
                        4326
                    )
                )::text
                """,
                [json.dumps(geometry), float(tolerance_meters)],
            )
            row = cursor.fetchone()
        if not row or not row[0]:
            return geometry
        try:
            return json.loads(row[0])
        except (TypeError, json.JSONDecodeError):
            return geometry

    if payload.get("type") == "FeatureCollection":
        features = payload.get("features") or []
        if not isinstance(features, list):
            return payload
        simplified_features = []
        for feature in features:
            if not isinstance(feature, dict):
                continue
            simplified_feature = dict(feature)
            simplified_feature["geometry"] = _simplify_single_geometry(feature.get("geometry"))
            simplified_features.append(simplified_feature)
        result = dict(payload)
        result["features"] = simplified_features
        return result

    if payload.get("type") in {"Feature", "Polygon", "MultiPolygon", "GeometryCollection"}:
        if payload.get("type") == "Feature":
            result = dict(payload)
            result["geometry"] = _simplify_single_geometry(payload.get("geometry"))
            return result
        return _simplify_single_geometry(payload)

    return payload


def _geometries_intersect(geometry_a, geometry_b):
    geometry_a_norm = _to_intersection_geometry(geometry_a)
    geometry_b_norm = _to_intersection_geometry(geometry_b)
    if not geometry_a_norm or not geometry_b_norm:
        return False
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT ST_Intersects(
                {_sql_geojson_param_as_valid_geom2d()},
                {_sql_geojson_param_as_valid_geom2d()}
            )
            """,
            [json.dumps(geometry_a_norm), json.dumps(geometry_b_norm)],
        )
        row = cursor.fetchone()
    return bool(row[0]) if row else False


def _ensure_request_id_column(cursor, table_name, request_id_field):
    cursor.execute(
        f"ALTER TABLE {_quote_ident(table_name)} ADD COLUMN IF NOT EXISTS {_quote_ident(request_id_field)} text"
    )


DGI_APROVE_COLUMN = "dgi_aprove"


def _dgi_aprove_column_exists(cursor, table_name):
    return _column_exists(cursor, table_name, DGI_APROVE_COLUMN)


def _create_new_object(
    username,
    geometry,
    name,
    request_id,
    source_label="ДТ",
    replace_row_ctid=None,
    dgi_aprove=None,
):
    owner_id = _get_current_user_owner_id(username)
    if owner_id is None:
        raise ValueError("Не найден OwnerLegalPersonId пользователя в таблице users.")

    normalized_source = _normalize_source_label(source_label)
    table = _get_source_table(normalized_source)
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field_pref = _owner_field_pref_for_source(normalized_source)
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    replace_tid = str(replace_row_ctid or "").strip()
    request_id_norm = str(request_id or "").strip()

    geom_for_hood = _to_intersection_geometry(geometry)
    if geom_for_hood and not geometry_intersects_allowed_hood(geom_for_hood):
        raise ValueError("Геометрия вне территории, определённой по вашим существующим объектам (район hood).")

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)

        _ensure_request_id_column(cursor, table, request_id_field)

        geometry_json = json.dumps(geometry)
        if _table_requires_multipolygon_geom(table):
            _validate_multipolygon_geometry_for_storage(cursor, geometry_json)
        geom_sql = _geojson_geom_sql_for_table(table)
        dgi_aprove_json = json.dumps(dgi_aprove) if dgi_aprove else None
        write_dgi_aprove = bool(dgi_aprove_json and _dgi_aprove_column_exists(cursor, table))
        dgi_aprove_set_sql = (
            f", {_quote_ident(DGI_APROVE_COLUMN)} = %s::jsonb" if write_dgi_aprove else ""
        )

        if replace_tid and request_id_norm:
            cursor.execute(
                f"SELECT {_quote_ident(request_id_field)}::text FROM {_quote_ident(table)} "
                f"WHERE ctid = %s::tid AND {_quote_ident(owner_field)} = %s LIMIT 1",
                [replace_tid, owner_id],
            )
            rid_row = cursor.fetchone()
            stored_rid = str(rid_row[0] or "").strip() if rid_row else ""
            if rid_row is not None and stored_rid and stored_rid == request_id_norm:
                update_params = [name, geometry_json]
                if write_dgi_aprove:
                    update_params.append(dgi_aprove_json)
                update_params.extend([replace_tid, owner_id])
                cursor.execute(
                    f"UPDATE {_quote_ident(table)} SET "
                    f"{_quote_ident(name_field)} = %s, "
                    f"{_quote_ident(geom_field)} = {geom_sql}"
                    f"{dgi_aprove_set_sql} "
                    f"WHERE ctid = %s::tid AND {_quote_ident(owner_field)} = %s",
                    update_params,
                )
                if cursor.rowcount < 1:
                    raise ValueError("Не удалось обновить строку: нет доступа или запись не найдена.")
                return owner_id

        if request_id_norm:
            update_params = [name, geometry_json]
            if write_dgi_aprove:
                update_params.append(dgi_aprove_json)
            update_params.extend([request_id_norm, owner_id])
            cursor.execute(
                f"UPDATE {_quote_ident(table)} SET "
                f"{_quote_ident(name_field)} = %s, "
                f"{_quote_ident(geom_field)} = {geom_sql}"
                f"{dgi_aprove_set_sql} "
                f"WHERE {_quote_ident(request_id_field)}::text = %s "
                f"  AND {_quote_ident(owner_field)} = %s",
                update_params,
            )
            if cursor.rowcount > 0:
                return owner_id

        insert_cols = [
            rootid_field,
            name_field,
            owner_field,
            request_id_field,
            geom_field,
        ]
        insert_vals = ["%s", "%s", "%s", "%s", geom_sql]
        insert_params = [None, name, owner_id, request_id, geometry_json]
        if write_dgi_aprove:
            insert_cols.append(DGI_APROVE_COLUMN)
            insert_vals.append("%s::jsonb")
            insert_params.append(dgi_aprove_json)
        insert_query = (
            f"INSERT INTO {_quote_ident(table)} ("
            + ", ".join(_quote_ident(c) for c in insert_cols)
            + ") VALUES ("
            + ", ".join(insert_vals)
            + ")"
        )
        cursor.execute(insert_query, insert_params)
    return owner_id


def _create_recap_object(username, geometry, name, request_id, recap_id, dgi_aprove=None):
    owner_id = _get_current_user_owner_id(username)
    if owner_id is None:
        raise ValueError("Не найден OwnerLegalPersonId пользователя в таблице users.")

    table = "recaps"
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field_pref = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")

    geom_for_hood = _to_intersection_geometry(geometry)
    if geom_for_hood and not geometry_intersects_allowed_hood(geom_for_hood):
        raise ValueError("Геометрия вне территории, определённой по вашим существующим объектам (район hood).")

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)

        _ensure_request_id_column(cursor, table, request_id_field)

        dgi_aprove_json = json.dumps(dgi_aprove) if dgi_aprove else None
        write_dgi_aprove = bool(dgi_aprove_json and _dgi_aprove_column_exists(cursor, table))
        insert_cols = [
            "recap_id",
            rootid_field,
            name_field,
            owner_field,
            request_id_field,
            geom_field,
        ]
        insert_vals = ["%s", "%s", "%s", "%s", "%s", _sql_geojson_param_as_valid_geom2d()]
        insert_params = [recap_id, None, name, owner_id, request_id, json.dumps(geometry)]
        if write_dgi_aprove:
            insert_cols.append(DGI_APROVE_COLUMN)
            insert_vals.append("%s::jsonb")
            insert_params.append(dgi_aprove_json)
        insert_query = (
            f"INSERT INTO {_quote_ident(table)} ("
            + ", ".join(_quote_ident(c) for c in insert_cols)
            + ") VALUES ("
            + ", ".join(insert_vals)
            + ")"
        )
        cursor.execute(insert_query, insert_params)
    return owner_id


def _check_recap_uniqueness(recap_id):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT 1 FROM recaps WHERE recap_id = %s LIMIT 1",
            [recap_id],
        )
        recap_exists = cursor.fetchone() is not None
    return recap_exists


def _sql_dgi_ownership_filter(cursor, table_name: str, ownership: str, *, table_alias: str = "t") -> str:
    """``ownership``: ``moscow`` | ``private`` — filter on short_sobstv_rr for table ``dgi``."""
    if not _column_exists(cursor, table_name, "short_sobstv_rr"):
        return " AND FALSE" if ownership == "moscow" else ""
    col_name = _resolve_column_name(cursor, table_name, "short_sobstv_rr")
    col_expr = f"{table_alias}.{_quote_ident(col_name)}"
    return build_dgi_ownership_extra_sql(col_expr, ownership)


def _sql_dgi_rent_filter(cursor, table_name: str, with_rent: bool, *, table_alias: str = "t") -> str:
    """Filter on ``rent``: True → rent IS TRUE; False → rent IS NOT TRUE."""
    if not _column_exists(cursor, table_name, "rent"):
        return " AND FALSE" if with_rent else ""
    col_name = _resolve_column_name(cursor, table_name, "rent")
    col_expr = f"{table_alias}.{_quote_ident(col_name)}"
    return build_dgi_rent_extra_sql(col_expr, with_rent)


def _sql_dgi_layer_filter(cursor, table_name: str, layer_key: str, *, table_alias: str = "t") -> str:
    """Combined ownership + rent filter for a DGI panel layer key."""
    spec = DGI_LAYER_SPECS.get(layer_key)
    if not spec:
        return " AND FALSE"
    return (
        _sql_dgi_ownership_filter(cursor, table_name, spec["ownership"], table_alias=table_alias)
        + _sql_dgi_rent_filter(cursor, table_name, spec["with_rent"], table_alias=table_alias)
    )


def _sql_within_meters_where(
    raw_geom: str,
    context_geom_ref: str,
    meters_expr: str,
    *,
    bbox_geom_ref: str | None = None,
    leading_and: bool = False,
) -> str:
    """
    All features within ``meters_expr`` of ``context_geom_ref`` (intersecting, touching, or nearby).
    GIST bbox prefilter + ST_DWithin on geography.
    """
    bbox = bbox_geom_ref or (
        f"ST_Envelope(ST_Buffer({context_geom_ref}::geography, {meters_expr})::geometry)"
    )
    prefix = " AND" if leading_and else ""
    return (
        f"{prefix} {raw_geom} && {bbox}"
        f" AND ST_DWithin({raw_geom}::geography, {context_geom_ref}::geography, {meters_expr})"
    )


def _sql_reference_layer_proximity_where(
    raw_geom: str,
    geom_v: str,
    *,
    context_geom_ref: str = "i.geom",
    bbox_geom_ref: str | None = None,
) -> str:
    del geom_v  # kept for call-site compatibility
    return _sql_within_meters_where(
        raw_geom,
        context_geom_ref,
        "%s",
        bbox_geom_ref=bbox_geom_ref,
    )


def _signal_tape_layer_tuning(source_label_norm: str) -> dict:
    if source_label_norm == "РЖД":
        return {
            "simplify_meters": float(getattr(settings, "GIS_RZD_SIGNAL_SIMPLIFY_METERS", 5.0)),
            "geojson_decimals": int(getattr(settings, "GIS_RZD_SIGNAL_GEOJSON_DECIMALS", 5)),
        }
    return {
        "simplify_meters": float(getattr(settings, "GIS_OOZT_SIGNAL_SIMPLIFY_METERS", 2.0)),
        "geojson_decimals": int(getattr(settings, "GIS_SIGNAL_TAPE_GEOJSON_DECIMALS", 6)),
    }


def _sql_signal_tape_clipped_geom_lateral(raw_geom: str, zone_ref: str = "c.zone") -> str:
    clipped = f"ST_Intersection({raw_geom}, {zone_ref})"
    return (
        f"CASE WHEN NOT ST_IsEmpty({clipped}) THEN {clipped} ELSE {raw_geom} END"
    )


def _sql_signal_tape_simplified_geom_expr(clipped_sql: str, simplify_meters: float) -> str:
    meters = max(0.0, float(simplify_meters))
    if meters <= 0:
        return clipped_sql
    return (
        "ST_Transform(ST_SimplifyPreserveTopology("
        f"ST_Transform(({clipped_sql}), 3857), {meters}::double precision), 4326)"
    )


def _get_signal_tape_layer_geojson(
    table_name,
    source_label,
    geometry=None,
    distance_meters=None,
):
    """Lightweight loader for ООЗТ/РЖД: popup fields only, clipped geom for smaller GeoJSON."""
    if distance_meters is None:
        distance_meters = _adjacent_nearby_meters()
    source_label_norm = str(source_label or "").strip().upper()
    if geometry is None:
        return '{"type":"FeatureCollection","features":[]}'

    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    with connection.cursor() as cursor:
        geom_field = _resolve_column_name(cursor, table_name, geom_field_pref)
        geom_q = _quote_ident(geom_field)
        raw_geom = f"t.{geom_q}"
        drawable_geom_sql = _sql_table_geom_drawable_clause(raw_geom)
        passport_only_ref_sql = _sql_gis_passport_only_clause(cursor, table_name, "t")

        name_select_expr = "NULL::text AS name"
        if _column_exists(cursor, table_name, settings.GIS_OBJECT_NAME_FIELD):
            name_field = _resolve_column_name(cursor, table_name, settings.GIS_OBJECT_NAME_FIELD)
            name_select_expr = f"t.{_quote_ident(name_field)}::text AS name"

        type_select_expr = "NULL::text AS type"
        comment_select_expr = "NULL::text AS comment"
        nomer1_select_expr = "NULL::text AS nomer1"
        comment_underscore_select_expr = "NULL::text AS comment_"
        if source_label_norm == "ООЗТ":
            if _column_exists(cursor, table_name, "type"):
                type_field = _resolve_column_name(cursor, table_name, "type")
                type_select_expr = f"t.{_quote_ident(type_field)}::text AS type"
            if _column_exists(cursor, table_name, "comment"):
                comment_field = _resolve_column_name(cursor, table_name, "comment")
                comment_select_expr = f"t.{_quote_ident(comment_field)}::text AS comment"
            if _column_exists(cursor, table_name, "nomer1"):
                nomer1_field = _resolve_column_name(cursor, table_name, "nomer1")
                nomer1_select_expr = f"t.{_quote_ident(nomer1_field)}::text AS nomer1"
            props_json = (
                "'source', %s, 'type', type::text, 'comment', comment::text, 'nomer1', nomer1::text"
            )
            select_suffix = f", {type_select_expr}, {comment_select_expr}, {nomer1_select_expr}"
        elif source_label_norm == "РЖД":
            if _column_exists(cursor, table_name, "comment_"):
                comment_field = _resolve_column_name(cursor, table_name, "comment_")
                comment_underscore_select_expr = f"t.{_quote_ident(comment_field)}::text AS comment_"
            props_json = "'source', %s, 'comment_', comment_::text"
            select_suffix = f", {comment_underscore_select_expr}"
            name_select_expr = ""
        else:
            return _get_reference_layer_geojson(
                table_name,
                source_label,
                geometry=geometry,
                distance_meters=distance_meters,
            )

        tuning = _signal_tape_layer_tuning(source_label_norm)
        clipped_lateral = _sql_signal_tape_clipped_geom_lateral(raw_geom)
        output_geom = _sql_signal_tape_simplified_geom_expr("clip.clipped", tuning["simplify_meters"])
        geojson_decimals = tuning["geojson_decimals"]
        hood_ref_pfx, hood_ref_prm = get_hood_cte_prefix_sql()
        hood_ref_t = get_hood_intersects_ha_sql(raw_geom)
        ref_with_input = (hood_ref_pfx + "input AS (") if hood_ref_pfx else "WITH input AS ("
        proximity_where = _sql_within_meters_where(
            raw_geom,
            "c.geom",
            "%s",
            bbox_geom_ref="c.zone",
        )
        geometry_json = geometry if isinstance(geometry, str) else json.dumps(geometry)
        name_prefix = f"{name_select_expr}, " if name_select_expr else ""
        query = (
            ref_with_input
            + f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
            "), ctx AS ("
            " SELECT i.geom AS geom, ST_Buffer(i.geom::geography, %s)::geometry AS zone FROM input i"
            "), rel AS ("
            f" SELECT {output_geom} AS geom, {name_prefix}{select_suffix.lstrip(', ')}"
            f" FROM {_quote_ident(table_name)} t"
            " CROSS JOIN ctx c"
            " CROSS JOIN LATERAL ("
            f" SELECT {clipped_lateral} AS clipped"
            ") clip"
            f" WHERE{proximity_where}"
            "   AND NOT ST_IsEmpty(clip.clipped)"
            f"{drawable_geom_sql}{passport_only_ref_sql}{hood_ref_t}"
            ") SELECT jsonb_build_object("
            " 'type', 'FeatureCollection',"
            " 'features', COALESCE(jsonb_agg(jsonb_build_object("
            "   'type', 'Feature',"
            f"   'geometry', ST_AsGeoJSON(geom, {geojson_decimals})::jsonb,"
            "   'properties', jsonb_build_object("
            f"      {props_json}"
            "   )"
            " )), '[]'::jsonb)"
            ")::text FROM rel"
        )
        cursor.execute(
            query,
            hood_ref_prm + [geometry_json, distance_meters, distance_meters, source_label],
        )
        row = cursor.fetchone()
        return row[0] if row else None


def _get_reference_layer_geojson(
    table_name,
    source_label,
    geometry=None,
    distance_meters=None,
    intersects_only=False,
    extra_where_sql: str = "",
):
    if distance_meters is None:
        distance_meters = _adjacent_nearby_meters()
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    customer_field_pref = getattr(settings, "GIS_OBJECT_CUSTOMER_FIELD", "CustomerLegalPersonId")
    department_field_pref = getattr(settings, "GIS_OBJECT_DEPARTMENT_FIELD", "DepartmentLegalPersonId")
    owner_field_pref = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    source_label_norm = str(source_label or "").strip().upper()
    is_dgi = source_label_norm == "ДГИ"
    department_field_candidates = [department_field_pref]
    if source_label_norm == "ОДХ":
        department_field_candidates.insert(0, getattr(settings, "GIS_ODH_GRBS_FIELD", "grbslegalpersonid"))
    owner_field_candidates = [owner_field_pref]
    if source_label_norm == "ОЗН":
        owner_field_candidates.insert(0, getattr(settings, "GIS_OZN_OWNER_FIELD", "ownerlegalpersonalid"))
    with connection.cursor() as cursor:
        geom_field = _resolve_column_name(cursor, table_name, geom_field_pref)
        geom_q = _quote_ident(geom_field)
        raw_geom = f"t.{geom_q}"
        geom_v = _sql_table_geom_valid_expr(raw_geom)
        rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
        name_field_pref = settings.GIS_OBJECT_NAME_FIELD
        descr_field_pref = "descr"
        address_field_pref = "address"
        vri_field_pref = "vri"
        sobstv_rr_field_pref = "sobstv_rr"
        short_sobstv_rr_field_pref = "short_sobstv_rr"
        rootid_select_expr = "NULL::text AS rootid"
        name_select_expr = "NULL::text AS name"
        descr_select_expr = "NULL::text AS descr"
        address_select_expr = "NULL::text AS address"
        vri_select_expr = "NULL::text AS vri"
        sobstv_rr_select_expr = "NULL::text AS sobstv_rr"
        short_sobstv_rr_select_expr = "NULL::text AS short_sobstv_rr"
        rootid_prop_expr = "rootid::text"
        name_prop_expr = "name::text"
        descr_prop_expr = "descr::text"
        address_prop_expr = "address::text"
        vri_prop_expr = "vri::text"
        sobstv_rr_prop_expr = "sobstv_rr::text"
        short_sobstv_rr_prop_expr = "short_sobstv_rr::text"
        customer_select_expr = "NULL::text AS customer_legal_person_id"
        department_select_expr = "NULL::text AS department_legal_person_id"
        owner_select_expr = "NULL::text AS owner_legal_person_id"
        customer_name_select_expr = "NULL::text AS customer_legal_person_name"
        department_name_select_expr = "NULL::text AS department_legal_person_name"
        owner_name_select_expr = "NULL::text AS owner_legal_person_name"
        customer_prop_expr = "customer_legal_person_id::text"
        department_prop_expr = "department_legal_person_id::text"
        owner_prop_expr = "owner_legal_person_id::text"
        customer_name_prop_expr = "customer_legal_person_name::text"
        department_name_prop_expr = "department_legal_person_name::text"
        owner_name_prop_expr = "owner_legal_person_name::text"
        lookup_context = _get_id_names_lookup_context(cursor)
        if _column_exists(cursor, table_name, rootid_field_pref):
            rootid_field = _resolve_column_name(cursor, table_name, rootid_field_pref)
            rootid_select_expr = f"t.{_quote_ident(rootid_field)}::text AS rootid"
        if _column_exists(cursor, table_name, name_field_pref):
            name_field = _resolve_column_name(cursor, table_name, name_field_pref)
            name_select_expr = f"t.{_quote_ident(name_field)}::text AS name"
        if _column_exists(cursor, table_name, descr_field_pref):
            descr_field = _resolve_column_name(cursor, table_name, descr_field_pref)
            descr_select_expr = f"t.{_quote_ident(descr_field)}::text AS descr"
        if _column_exists(cursor, table_name, address_field_pref):
            address_field = _resolve_column_name(cursor, table_name, address_field_pref)
            address_select_expr = f"t.{_quote_ident(address_field)}::text AS address"
        if _column_exists(cursor, table_name, vri_field_pref):
            vri_field = _resolve_column_name(cursor, table_name, vri_field_pref)
            vri_select_expr = f"t.{_quote_ident(vri_field)}::text AS vri"
        if not is_dgi and _column_exists(cursor, table_name, sobstv_rr_field_pref):
            sobstv_rr_field = _resolve_column_name(cursor, table_name, sobstv_rr_field_pref)
            sobstv_rr_select_expr = f"t.{_quote_ident(sobstv_rr_field)}::text AS sobstv_rr"
        if is_dgi and _column_exists(cursor, table_name, short_sobstv_rr_field_pref):
            short_sobstv_rr_field = _resolve_column_name(cursor, table_name, short_sobstv_rr_field_pref)
            short_sobstv_rr_select_expr = (
                f"t.{_quote_ident(short_sobstv_rr_field)}::text AS short_sobstv_rr"
            )
        if is_dgi:
            sobstv_owner_select_suffix = f", {short_sobstv_rr_select_expr}"
            sobstv_owner_json_frag = f", 'short_sobstv_rr', {short_sobstv_rr_prop_expr}"
        else:
            sobstv_owner_select_suffix = f", {sobstv_rr_select_expr}"
            sobstv_owner_json_frag = f", 'sobstv_rr', {sobstv_rr_prop_expr}"
        if _column_exists(cursor, table_name, customer_field_pref):
            customer_field = _resolve_column_name(cursor, table_name, customer_field_pref)
            customer_select_expr = f"t.{_quote_ident(customer_field)}::text AS customer_legal_person_id"
            customer_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        for department_field_pref_candidate in department_field_candidates:
            if _column_exists(cursor, table_name, department_field_pref_candidate):
                department_field = _resolve_column_name(cursor, table_name, department_field_pref_candidate)
                department_select_expr = f"t.{_quote_ident(department_field)}::text AS department_legal_person_id"
                department_name_select_expr = (
                    f"{_build_id_name_lookup_expr(f't.{_quote_ident(department_field)}', lookup_context)} "
                    "AS department_legal_person_name"
                )
                break
        for owner_field_pref_candidate in owner_field_candidates:
            if _column_exists(cursor, table_name, owner_field_pref_candidate):
                owner_field = _resolve_column_name(cursor, table_name, owner_field_pref_candidate)
                owner_select_expr = f"t.{_quote_ident(owner_field)}::text AS owner_legal_person_id"
                owner_name_select_expr = (
                    f"{_build_id_name_lookup_expr(f't.{_quote_ident(owner_field)}', lookup_context)} "
                    "AS owner_legal_person_name"
                )
                break
        extra_select_suffix = ""
        extra_json_frag = ""
        if source_label_norm == "ООЗТ":
            type_select_expr = "NULL::text AS type"
            comment_select_expr = "NULL::text AS comment"
            nomer1_select_expr = "NULL::text AS nomer1"
            if _column_exists(cursor, table_name, "type"):
                type_field = _resolve_column_name(cursor, table_name, "type")
                type_select_expr = f"t.{_quote_ident(type_field)}::text AS type"
            if _column_exists(cursor, table_name, "comment"):
                comment_field = _resolve_column_name(cursor, table_name, "comment")
                comment_select_expr = f"t.{_quote_ident(comment_field)}::text AS comment"
            if _column_exists(cursor, table_name, "nomer1"):
                nomer1_field = _resolve_column_name(cursor, table_name, "nomer1")
                nomer1_select_expr = f"t.{_quote_ident(nomer1_field)}::text AS nomer1"
            extra_select_suffix = f", {type_select_expr}, {comment_select_expr}, {nomer1_select_expr}"
            extra_json_frag = ", 'type', type::text, 'comment', comment::text, 'nomer1', nomer1::text"
        elif source_label_norm == "РЖД":
            comment_select_expr = "NULL::text AS comment_"
            if _column_exists(cursor, table_name, "comment_"):
                comment_field = _resolve_column_name(cursor, table_name, "comment_")
                comment_select_expr = f"t.{_quote_ident(comment_field)}::text AS comment_"
            extra_select_suffix = f", {comment_select_expr}"
            extra_json_frag = ", 'comment_', comment_::text"
        include_gis_meta = source_label_norm in ("ОДХ", "ОЗН", _top_source_label().upper())
        meta_sql_fragment = _gis_object_meta_sql_fragment(cursor, table_name, "t") if include_gis_meta else ""
        meta_select_suffix = (f", {meta_sql_fragment}" if meta_sql_fragment else "") + extra_select_suffix
        meta_json_frag = (
            ", 'startdate', startdate::text, 'datesurvey', datesurvey::text, 'createtype', createtype::text"
            if include_gis_meta
            else ""
        ) + extra_json_frag
        hood_ref_pfx, hood_ref_prm = get_hood_cte_prefix_sql()
        ref_with_input = (hood_ref_pfx + "input AS (") if hood_ref_pfx else "WITH input AS ("
        hood_ref_t = get_hood_intersects_ha_sql(f"t.{_quote_ident(geom_field)}")
        hood_ref_none_suf, hood_ref_none_prm = get_hood_intersects_sql_suffix(f"t.{_quote_ident(geom_field)}")
        passport_only_ref_sql = _sql_gis_passport_only_clause(cursor, table_name, "t")
        drawable_geom_sql = _sql_table_geom_drawable_clause(raw_geom)
        if geometry is None:
            query = (
                "SELECT jsonb_build_object("
                " 'type', 'FeatureCollection',"
                " 'features', COALESCE(jsonb_agg(jsonb_build_object("
                "   'type', 'Feature',"
                "   'geometry', ST_AsGeoJSON("
                f"     {_quote_ident(geom_field)}"
                "   )::jsonb,"
                "   'properties', jsonb_build_object("
                "       'source', %s,"
                f"      'rootid', {rootid_prop_expr},"
                f"      'name', {name_prop_expr},"
                f"      'descr', {descr_prop_expr},"
                f"      'address', {address_prop_expr},"
                f"      'vri', {vri_prop_expr}{sobstv_owner_json_frag},"
                f"      'customer_legal_person_id', {customer_prop_expr},"
                f"      'department_legal_person_id', {department_prop_expr},"
                f"      'owner_legal_person_id', {owner_prop_expr},"
                f"      'customer_legal_person_name', {customer_name_prop_expr},"
                f"      'department_legal_person_name', {department_name_prop_expr},"
                f"      'owner_legal_person_name', {owner_name_prop_expr}{meta_json_frag}"
                "   )"
                " )), '[]'::jsonb)"
                ")::text "
                f"FROM (SELECT t.{_quote_ident(geom_field)} AS {_quote_ident(geom_field)}, "
                f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}{sobstv_owner_select_suffix}, {customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr}{meta_select_suffix} "
                f"FROM {_quote_ident(table_name)} t WHERE TRUE{drawable_geom_sql}{passport_only_ref_sql}{hood_ref_none_suf}{extra_where_sql}) rel"
            )
            cursor.execute(query, hood_ref_none_prm + [source_label])
        else:
            geometry_json = geometry if isinstance(geometry, str) else json.dumps(geometry)
            select_json_tail = (
                "SELECT jsonb_build_object("
                " 'type', 'FeatureCollection',"
                " 'features', COALESCE(jsonb_agg(jsonb_build_object("
                "   'type', 'Feature',"
                "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
                "   'properties', jsonb_build_object("
                "       'source', %s,"
                f"      'rootid', {rootid_prop_expr},"
                f"      'name', {name_prop_expr},"
                f"      'descr', {descr_prop_expr},"
                f"      'address', {address_prop_expr},"
                f"      'vri', {vri_prop_expr}{sobstv_owner_json_frag},"
                f"      'customer_legal_person_id', {customer_prop_expr},"
                f"      'department_legal_person_id', {department_prop_expr},"
                f"      'owner_legal_person_id', {owner_prop_expr},"
                f"      'customer_legal_person_name', {customer_name_prop_expr},"
                f"      'department_legal_person_name', {department_name_prop_expr},"
                f"      'owner_legal_person_name', {owner_name_prop_expr}{meta_json_frag}"
                "   )"
                " )), '[]'::jsonb)"
                ")::text FROM rel"
            )
            if intersects_only:
                query = (
                    ref_with_input + f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), input_parts AS ("
                    " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
                    "), rel AS ("
                    f" SELECT t.{_quote_ident(geom_field)} AS geom, "
                    f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}{sobstv_owner_select_suffix}, {customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr}{meta_select_suffix} "
                    f"FROM {_quote_ident(table_name)} t, input i"
                    f" WHERE {raw_geom} && i.geom"
                    f" AND ST_Intersects({geom_v}, i.geom)"
                    "   AND NOT EXISTS ("
                    "       SELECT 1 FROM input_parts p"
                    f"       WHERE ST_Equals({geom_v}, p.geom)"
                    "   )"
                    f"{drawable_geom_sql}"
                    f"{passport_only_ref_sql}"
                    f"{extra_where_sql}"
                    f"{hood_ref_t}"
                    ") " + select_json_tail
                )
                cursor.execute(query, hood_ref_prm + [geometry_json, source_label])
            else:
                proximity_where = _sql_reference_layer_proximity_where(raw_geom, geom_v)
                query = (
                    ref_with_input + f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), rel AS ("
                    f" SELECT t.{_quote_ident(geom_field)} AS geom, "
                    f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}{sobstv_owner_select_suffix}, {customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr}{meta_select_suffix} "
                    f"FROM {_quote_ident(table_name)} t, input i"
                    f" WHERE{proximity_where}"
                    f"{drawable_geom_sql}{passport_only_ref_sql}{extra_where_sql}{hood_ref_t}"
                    ") " + select_json_tail
                )
                cursor.execute(
                    query,
                    hood_ref_prm + [geometry_json, distance_meters, distance_meters, source_label],
                )
        row = cursor.fetchone()
        return row[0] if row else None


def _get_recaps_layer_geojson(geometry=None, distance_meters=None, request_id_filter=None):
    if distance_meters is None:
        distance_meters = _adjacent_nearby_meters()
    request_id_text = str(request_id_filter or "").strip()
    has_request_id = bool(request_id_text)
    with connection.cursor() as cursor:
        name_field_pref = settings.GIS_OBJECT_NAME_FIELD
        owner_field_pref = settings.GIS_OBJECT_OWNER_FIELD
        request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
        name_select_expr = "NULL::text AS name"
        owner_select_expr = "NULL::text AS owner_legal_person_id"
        owner_name_select_expr = "NULL::text AS owner_legal_person_name"
        owner_name_prop_expr = "owner_legal_person_name::text"
        lookup_context = _get_id_names_lookup_context(cursor)
        request_id_col = "request_id"
        if _column_exists(cursor, "recaps", request_id_field_pref):
            request_id_col = _resolve_column_name(cursor, "recaps", request_id_field_pref)
        if _column_exists(cursor, "recaps", name_field_pref):
            name_field = _resolve_column_name(cursor, "recaps", name_field_pref)
            name_select_expr = f"t.{_quote_ident(name_field)}::text AS name"
        if _column_exists(cursor, "recaps", owner_field_pref):
            owner_field = _resolve_column_name(cursor, "recaps", owner_field_pref)
            owner_select_expr = f"t.{_quote_ident(owner_field)}::text AS owner_legal_person_id"
            owner_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        recap_select_core = (
            f"t.geom AS geom, t.recap_id AS recap_id, t.{_quote_ident(request_id_col)} AS request_id, "
            f"{name_select_expr}, {owner_select_expr}, {owner_name_select_expr}"
        )
        rh_full, rh_prm = get_hood_cte_prefix_sql()
        recap_with_lead = "WITH " + _hood_strip_with_keyword(rh_full)
        recap_ha_geom = get_hood_intersects_ha_sql("t.geom")
        recap_hood_flat_suf, recap_hood_flat_prm = get_hood_intersects_sql_suffix("t.geom")
        json_agg_select = (
            "SELECT jsonb_build_object("
            " 'type', 'FeatureCollection',"
            " 'features', COALESCE(jsonb_agg(jsonb_build_object("
            "   'type', 'Feature',"
            "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
            "   'properties', jsonb_build_object("
            "       'recap_id', recap_id::text,"
            "       'request_id', request_id::text,"
            "       'name', name::text,"
            "       'owner_legal_person_id', owner_legal_person_id::text,"
            f"      'owner_legal_person_name', {owner_name_prop_expr}"
            "   )"
            " )), '[]'::jsonb)"
            ")::text "
            "FROM rel"
        )
        if geometry is None:
            if has_request_id:
                query = (
                    recap_with_lead + "rel AS ("
                    f" SELECT {recap_select_core} "
                    " FROM recaps t"
                    f" WHERE t.{_quote_ident(request_id_col)}::text = %s"
                    f"{recap_ha_geom}"
                    ") " + json_agg_select
                )
                cursor.execute(query, list(rh_prm) + [request_id_text])
            else:
                query = (
                    "SELECT jsonb_build_object("
                    " 'type', 'FeatureCollection',"
                    " 'features', COALESCE(jsonb_agg(jsonb_build_object("
                    "   'type', 'Feature',"
                    "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
                    "   'properties', jsonb_build_object("
                    "       'recap_id', recap_id::text,"
                    "       'request_id', request_id::text,"
                    "       'name', name::text,"
                    "       'owner_legal_person_id', owner_legal_person_id::text,"
                    f"      'owner_legal_person_name', {owner_name_prop_expr}"
                    "   )"
                    " )), '[]'::jsonb)"
                    ")::text "
                    f"FROM (SELECT {recap_select_core} FROM recaps t WHERE TRUE{recap_hood_flat_suf}) rel"
                )
                cursor.execute(query, list(recap_hood_flat_prm))
        else:
            geometry_json = geometry if isinstance(geometry, str) else json.dumps(geometry)
            if has_request_id:
                query = (
                    recap_with_lead + "input AS ("
                    f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), spatial_rel AS ("
                    f" SELECT {recap_select_core}"
                    " FROM recaps t, input i"
                    " WHERE"
                    + _sql_within_meters_where("t.geom", "i.geom", "%s")
                    + f"{recap_ha_geom}"
                    "), request_rel AS ("
                    f" SELECT {recap_select_core}"
                    " FROM recaps t"
                    f" WHERE t.{_quote_ident(request_id_col)}::text = %s"
                    f"{recap_ha_geom}"
                    "), rel AS ("
                    " SELECT * FROM spatial_rel"
                    " UNION"
                    " SELECT * FROM request_rel"
                    ") " + json_agg_select
                )
                cursor.execute(
                    query,
                    list(rh_prm) + [geometry_json, distance_meters, distance_meters, request_id_text],
                )
            else:
                query = (
                    recap_with_lead + "input AS ("
                    f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), rel AS ("
                    f" SELECT {recap_select_core}"
                    " FROM recaps t, input i"
                    " WHERE"
                    + _sql_within_meters_where("t.geom", "i.geom", "%s")
                    + f"{recap_ha_geom}"
                    ") " + json_agg_select
                )
                cursor.execute(query, list(rh_prm) + [geometry_json, distance_meters, distance_meters])
        row = cursor.fetchone()
        return row[0] if row else None


def _get_reference_layers(geometry=None, distance_meters=None, request_id_filter=None):
    if distance_meters is None:
        distance_meters = _adjacent_nearby_meters()
    dgi_table = getattr(settings, "GIS_DGI_TABLE", "dgi")
    layers = {
        "dgi_moscow_rent": None,
        "dgi_moscow_no_rent": None,
        "dgi_private_rent": None,
        "dgi_private_no_rent": None,
        "odh": None,
        "ozn": None,
        "renew": None,
        "recaps": None,
        "oozt": None,
        "rzd": None,
        "top": None,
    }
    try:
        layer_filters = {}
        with connection.cursor() as cursor:
            for layer_key in DGI_LAYER_KEYS:
                layer_filters[layer_key] = _sql_dgi_layer_filter(cursor, dgi_table, layer_key)
        for layer_key in DGI_LAYER_KEYS:
            layers[layer_key] = _get_reference_layer_geojson(
                dgi_table,
                "ДГИ",
                geometry=geometry,
                distance_meters=distance_meters,
                extra_where_sql=layer_filters[layer_key],
            )
    except Exception:
        logger.exception("Failed to load DGI reference layers (%s)", ", ".join(DGI_LAYER_KEYS))
        for layer_key in DGI_LAYER_KEYS:
            layers[layer_key] = None
    try:
        layers["odh"] = _get_reference_layer_geojson("odh", "ОДХ", geometry=geometry, distance_meters=distance_meters)
    except Exception:
        layers["odh"] = None
    try:
        layers["ozn"] = _get_reference_layer_geojson(
            getattr(settings, "GIS_OZN_TABLE", "ozn"),
            "ОЗН",
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers["ozn"] = None
    try:
        layers["renew"] = _get_reference_layer_geojson(
            getattr(settings, "GIS_RENEW_TABLE", "renew"),
            "Реновация",
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers["renew"] = None
    try:
        layers["recaps"] = _get_recaps_layer_geojson(
            geometry=geometry,
            distance_meters=distance_meters,
            request_id_filter=request_id_filter,
        )
    except Exception:
        layers["recaps"] = None
    try:
        layers["oozt"] = _get_signal_tape_layer_geojson(
            getattr(settings, "GIS_OOZT_TABLE", "oozt"),
            "ООЗТ",
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers["oozt"] = None
    try:
        layers["rzd"] = _get_signal_tape_layer_geojson(
            getattr(settings, "GIS_RZD_TABLE", "rzd"),
            "РЖД",
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers["rzd"] = None
    try:
        layers["top"] = _get_reference_layer_geojson(
            getattr(settings, "GIS_TOP_TABLE", "top"),
            _top_source_label(),
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers["top"] = None
    return layers


def _entry_point_needs_request_id(entry_point):
    if not entry_point:
        return True
    return not (str(entry_point.get("request_id") or "").strip())


@login_required
def home(request):
    if request.method == "POST":
        form = EntryPointForm(request.POST)
        if form.is_valid():
            rootid = form.cleaned_data.get("rootid", "")
            name = form.cleaned_data.get("name", "")
            try:
                entry_point = _find_manual_entry_point(rootid=rootid, name=name)
            except Exception:
                form.add_error(None, "Не удалось выполнить поиск. Проверьте доступ к базе данных.")
            else:
                if entry_point:
                    if _entry_point_needs_request_id(entry_point):
                        request.session["pending_entry_point"] = entry_point
                    else:
                        request.session["entry_point"] = entry_point
                        return redirect("main")
                else:
                    form.add_error(None, "Объект не найден. Проверьте № Паспорта или Название.")
    else:
        form = EntryPointForm()

    scope = resolve_user_scope(request.user.username)
    owner_id = scope.owner_id
    owner_name = None
    owned_objects = []
    owned_passports_geojson = {"type": "FeatureCollection", "features": []}
    hood_work_area_geojson = {"type": "FeatureCollection", "features": []}
    owned_objects_error = None
    ods_user_brids = []
    approval_items = []
    home_notification_events = []
    pending_approval_count = 0
    hood_districts = []
    need_sup_hood_modal = False
    sup_hood_gid = (request.session.get(SUP_HOOD_SESSION_GID) or "").strip()
    sup_hood_label = (request.session.get(SUP_HOOD_SESSION_LABEL) or "").strip()
    has_sup_hood = bool(sup_hood_gid)

    if scope.role == ROLE_SUP and not has_sup_hood:
        need_sup_hood_modal = True
        try:
            hood_districts = list_hood_districts()
        except Exception:
            hood_districts = []

    try:
        if owner_id is not None:
            owner_name = _get_id_name_lookup_value(owner_id)

        if not need_sup_hood_modal:
            owned_objects, ods_user_brids = _load_home_objects_for_scope(scope, has_sup_hood=has_sup_hood)
            recap_owner = owner_id
            recap_counts = _get_recap_counts_by_request_ids(
                recap_owner,
                (item["request_id"] for item in owned_objects),
            )
            for item in owned_objects:
                request_id = (item.get("request_id") or "").strip()
                item["recap_count"] = recap_counts.get(request_id, 0)
            owned_passports_geojson = _build_owned_passports_geojson(owned_objects)
            if scope.role == ROLE_SUP and has_sup_hood:
                try:
                    with connection.cursor() as hood_cur:
                        scope_row = resolve_hood_wkt_for_gid(hood_cur, sup_hood_gid)
                        if scope_row.get("mode") == "active" and scope_row.get("wkt"):
                            hood_cur.execute(
                                """
                                SELECT ST_AsGeoJSON(ST_MakeValid(ST_SetSRID(ST_GeomFromText(%s), 4326)))::text
                                """,
                                [scope_row["wkt"]],
                            )
                            geo_row = hood_cur.fetchone()
                            if geo_row and geo_row[0]:
                                geom = json.loads(geo_row[0])
                                hood_work_area_geojson = {
                                    "type": "FeatureCollection",
                                    "features": [
                                        {
                                            "type": "Feature",
                                            "properties": {
                                                "gid": sup_hood_gid,
                                                "label": sup_hood_label,
                                            },
                                            "geometry": geom,
                                        }
                                    ],
                                }
                except Exception:
                    hood_work_area_geojson = {"type": "FeatureCollection", "features": []}
            elif owner_id is not None:
                try:
                    with connection.cursor() as hood_cur:
                        hood_work_area_geojson = get_hood_allowed_districts_geojson(hood_cur, owner_id)
                except Exception:
                    hood_work_area_geojson = {"type": "FeatureCollection", "features": []}

        accessible_approves = get_accessible_approves(owner_id, username=request.user.username)
        approval_items = serialize_approve_options(
            accessible_approves,
            username=request.user.username,
        )
        home_notification_events = build_home_notification_events(
            owner_id=owner_id,
            username=request.user.username,
        )
        # Badge is computed client-side from unseen localStorage ids.
        pending_approval_count = 0
    except Exception:
        owned_objects_error = (
            "Не удалось получить список объектов пользователя. Проверьте поле OwnerLegalPersonId в таблице users."
        )

    need_entry_request_id = bool(request.session.get("pending_entry_point"))

    return render(
        request,
        "pass_viewer/home.html",
        {
            "form": form,
            "owner_id": owner_id,
            "owner_name": owner_name,
            "owned_objects": owned_objects,
            "owned_passports_geojson": owned_passports_geojson,
            "hood_work_area_geojson": hood_work_area_geojson,
            "owned_objects_error": owned_objects_error,
            "need_entry_request_id": need_entry_request_id,
            "ods_request_source_label": getattr(settings, "GIS_ODS_REQUEST_SOURCE_LABEL", "ОДС"),
            "ods_user_brids": ods_user_brids,
            "approval_items": approval_items,
            "home_notification_events": home_notification_events,
            "pending_approval_count": pending_approval_count,
            "user_role": scope.role,
            "display_name": scope.display_name,
            "can_write": scope.can_write,
            "show_passports_tab": scope.role != ROLE_MGGT,
            "show_approvals_mine_all_filter": scope.role == ROLE_MGGT,
            "need_sup_hood_modal": need_sup_hood_modal,
            "hood_districts": hood_districts,
            "sup_hood_gid": sup_hood_gid,
            "sup_hood_label": sup_hood_label,
            "page_config": home_page_config(
                need_entry_request_id=need_entry_request_id,
                ods_source_label=getattr(settings, "GIS_ODS_REQUEST_SOURCE_LABEL", "ОДС"),
                owner_id=owner_id,
                user_role=scope.role,
                can_write=scope.can_write,
                show_passports_tab=scope.role != ROLE_MGGT,
                show_approvals_mine_all_filter=scope.role == ROLE_MGGT,
                need_sup_hood_modal=need_sup_hood_modal,
                sup_hood_gid=sup_hood_gid,
                sup_hood_label=sup_hood_label,
            ),
            "user_guide_html": load_user_guide_html(),
        },
    )


@login_required
@require_POST
def select_sup_hood(request):
    scope = resolve_user_scope(request.user.username)
    if scope.role != ROLE_SUP:
        return redirect("home")

    gid = (request.POST.get("hood_gid") or "").strip()
    if not gid:
        return redirect("home")

    label = ""
    try:
        districts = list_hood_districts()
        match = next((d for d in districts if str(d.get("gid")) == gid), None)
        if match is None:
            return redirect("home")
        rayon = (match.get("rayon") or "").strip()
        okrug = (match.get("okrug") or "").strip()
        label = rayon or okrug or gid
        if rayon and okrug:
            label = f"{rayon} ({okrug})"
    except Exception:
        return redirect("home")

    request.session[SUP_HOOD_SESSION_GID] = gid
    request.session[SUP_HOOD_SESSION_LABEL] = label
    request.session.pop("hood_access_scope", None)
    request.session.modified = True
    resolve_and_bind_hood_scope(request)
    return redirect("home")


@login_required
@require_POST
def clear_sup_hood(request):
    scope = resolve_user_scope(request.user.username)
    if scope.role != ROLE_SUP:
        return redirect("home")
    request.session.pop(SUP_HOOD_SESSION_GID, None)
    request.session.pop(SUP_HOOD_SESSION_LABEL, None)
    request.session.pop("hood_access_scope", None)
    request.session.modified = True
    return redirect("home")


@login_required
def main(request):
    entry_point = request.session.get("entry_point")
    if not entry_point:
        return redirect("home")

    view_only = str(request.GET.get("view_only") or "").strip().lower() in {"1", "true", "yes"}
    layers = None
    query_error = None

    # View-only iframe: always defer context layers so the shell + selected object paint first.
    defer_context_layers = True if view_only else _defer_map_context_layers()
    try:
        layers = _get_map_layers(entry_point, include_adjacent_layers=not defer_context_layers)
    except Exception:
        logger.exception("main: _get_map_layers failed")
        query_error = "Не удалось получить геометрию из PostGIS. Проверьте настройки таблицы/полей в settings.py."

    selected_request_id = (layers.get("selected_request_id") or "").strip() if layers else ""
    ep_request_id = (entry_point.get("request_id") or "").strip()
    effective_request_id = selected_request_id or ep_request_id
    selected_geometry_for_editing = layers["selected"] if layers else None
    geometry_detail_mode = str(entry_point.get("geometry_detail_mode") or "").strip().lower()
    use_full_geometry = geometry_detail_mode == "full"
    has_merge = len(_normalize_merge_items(entry_point)) >= 2
    should_simplify_selected = (
        bool(layers)
        and layers.get("selected")
        and not use_full_geometry
        and (
            (
                entry_point.get("entry_source") == "owned_passport_list"
                and bool((layers.get("selected_rootid") or "").strip())
            )
            or has_merge
        )
    )
    if should_simplify_selected:
        try:
            simplify_tolerance_m = float(getattr(settings, "GIS_EDIT_SIMPLIFY_TOLERANCE_METERS", 0.75))
            selected_geom_simplified = _simplify_geojson_for_editing(
                layers["selected"],
                tolerance_meters=max(0.0, simplify_tolerance_m),
            )
            if selected_geom_simplified:
                selected_geometry_for_editing = json.dumps(selected_geom_simplified, ensure_ascii=False)
        except Exception:
            logger.exception("main: failed to simplify selected geometry for editing")

    reference_layers = (
        {
            "dgi_moscow_rent": None,
            "dgi_moscow_no_rent": None,
            "dgi_private_rent": None,
            "dgi_private_no_rent": None,
            "odh": None,
            "ozn": None,
            "renew": None,
            "recaps": None,
            "oozt": None,
            "rzd": None,
            "top": None,
        }
        if defer_context_layers
        else _get_reference_layers(
            geometry=layers["selected"] if layers else None,
            request_id_filter=effective_request_id or None,
        )
    )

    return render(
        request,
        "pass_viewer/main.html",
        {
            "entry_point": entry_point,
            "map_layers": layers,
            "selected_geometry_json": layers["selected"] if layers else None,
            "selected_geometry_for_editing_json": selected_geometry_for_editing,
            "selected_rootid": layers["selected_rootid"] if layers else None,
            "selected_name": layers["selected_name"] if layers else None,
            "selected_request_id": layers["selected_request_id"] if layers else None,
            "selected_ctid": layers.get("selected_ctid") if layers else None,
            "effective_request_id": effective_request_id,
            "selected_customer_legal_person_id": layers["selected_customer_legal_person_id"] if layers else None,
            "selected_department_legal_person_id": layers["selected_department_legal_person_id"] if layers else None,
            "selected_customer_legal_person_name": layers["selected_customer_legal_person_name"] if layers else None,
            "selected_department_legal_person_name": layers["selected_department_legal_person_name"]
            if layers
            else None,
            "selected_startdate": layers.get("selected_startdate") if layers else None,
            "selected_datesurvey": layers.get("selected_datesurvey") if layers else None,
            "selected_createtype": layers.get("selected_createtype") if layers else None,
            "selected_source_label": layers["selected_source_label"]
            if layers
            else _normalize_source_label(entry_point.get("source_label")),
            "intersects_geometry_json": layers["intersects"] if layers else None,
            "touches_geometry_json": layers["touches"] if layers else None,
            "nearby_geometry_json": layers["nearby"] if layers else None,
            "request_objects_geometry_json": layers["request_objects"] if layers else None,
            "dgi_moscow_rent_geometry_json": reference_layers["dgi_moscow_rent"],
            "dgi_moscow_no_rent_geometry_json": reference_layers["dgi_moscow_no_rent"],
            "dgi_private_rent_geometry_json": reference_layers["dgi_private_rent"],
            "dgi_private_no_rent_geometry_json": reference_layers["dgi_private_no_rent"],
            "odh_geometry_json": reference_layers["odh"],
            "ozn_geometry_json": reference_layers["ozn"],
            "renew_geometry_json": reference_layers["renew"],
            "recaps_geometry_json": reference_layers["recaps"],
            "oozt_geometry_json": reference_layers["oozt"],
            "rzd_geometry_json": reference_layers["rzd"],
            "top_geometry_json": reference_layers["top"],
            "query_error": query_error,
            "view_only": view_only,
            "page_config": main_page_config(
                selected_rootid=layers["selected_rootid"] if layers else "",
                selected_name=layers["selected_name"] if layers else "",
                selected_request_id=layers["selected_request_id"] if layers else "",
                selected_ctid=layers.get("selected_ctid") if layers else "",
                effective_request_id=effective_request_id,
                selected_customer_legal_person_id=(layers["selected_customer_legal_person_id"] if layers else ""),
                selected_department_legal_person_id=(layers["selected_department_legal_person_id"] if layers else ""),
                selected_customer_legal_person_name=(layers["selected_customer_legal_person_name"] if layers else ""),
                selected_department_legal_person_name=(
                    layers["selected_department_legal_person_name"] if layers else ""
                ),
                selected_startdate=layers.get("selected_startdate") if layers else "",
                selected_datesurvey=layers.get("selected_datesurvey") if layers else "",
                selected_createtype=layers.get("selected_createtype") if layers else "",
                selected_source_label=(
                    layers["selected_source_label"]
                    if layers
                    else _normalize_source_label(entry_point.get("source_label"))
                ),
                view_only=view_only,
            ),
        },
    )


@login_required
def split_object(request):
    entry_point = request.session.get("entry_point")
    if not entry_point:
        return redirect("home")

    layers = None
    query_error = None

    try:
        layers = _get_map_layers(entry_point, include_adjacent_layers=False)
    except Exception:
        logger.exception("split_object: _get_map_layers failed")
        query_error = "Не удалось получить геометрию из PostGIS. Проверьте настройки таблицы/полей в settings.py."

    # For split workflow we always use full geometry.
    selected_geometry_for_editing = layers["selected"] if layers else None

    return render(
        request,
        "pass_viewer/split_object.html",
        {
            "entry_point": entry_point,
            "map_layers": layers,
            "selected_geometry_json": layers["selected"] if layers else None,
            "selected_geometry_for_editing_json": selected_geometry_for_editing,
            "selected_rootid": layers["selected_rootid"] if layers else None,
            "selected_name": layers["selected_name"] if layers else None,
            "selected_request_id": layers["selected_request_id"] if layers else None,
            "selected_source_label": (
                layers["selected_source_label"] if layers else _normalize_source_label(entry_point.get("source_label"))
            ),
            "query_error": query_error,
            "page_config": split_object_page_config(
                selected_name=layers["selected_name"] if layers else "",
                selected_request_id=layers["selected_request_id"] if layers else "",
                selected_source_label=(
                    layers["selected_source_label"]
                    if layers
                    else _normalize_source_label(entry_point.get("source_label"))
                ),
            ),
        },
    )


@login_required
@require_POST
def export_geometry(request):
    entry_point = request.session.get("entry_point")
    if not entry_point:
        return JsonResponse({"ok": False, "error": "Сначала выберите объект."}, status=400)

    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = payload.get("geometry")
    if not isinstance(geometry, dict):
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    try:
        geojson_url, shapefile_url = _export_geometry_files(geometry)
    except Exception:
        return JsonResponse(
            {"ok": False, "error": "Ошибка формирования файлов экспорта."},
            status=500,
        )

    return JsonResponse({"ok": True, "geojson_url": geojson_url, "shapefile_url": shapefile_url})


@login_required
@require_POST
def export_new_object_geometry(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = payload.get("geometry")
    if not isinstance(geometry, dict):
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)
    properties = payload.get("properties") or {}
    if not isinstance(properties, dict):
        properties = {}

    try:
        geojson_url, shapefile_url = _export_geometry_files(geometry, properties=properties)
    except Exception:
        return JsonResponse(
            {"ok": False, "error": "Ошибка формирования файлов экспорта."},
            status=500,
        )

    return JsonResponse({"ok": True, "geojson_url": geojson_url, "shapefile_url": shapefile_url})


@login_required
@require_POST
def repair_save_geometry(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = payload.get("geometry")
    if not isinstance(geometry, dict):
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    geometry_json = json.dumps(geometry, ensure_ascii=False)
    try:
        with connection.cursor() as cursor:
            result = _repair_multipolygon_geometry_json(cursor, geometry_json)
    except Exception as exc:
        logger.exception("repair_save_geometry failed")
        response_payload = {"ok": False, "error": "Не удалось исправить геометрию полигона."}
        if settings.DEBUG:
            response_payload["detail"] = str(exc)
        return JsonResponse(response_payload, status=500)

    if result.get("fixed") and result.get("geometry"):
        return JsonResponse(
            {
                "ok": True,
                "geometry": result["geometry"],
                "issues_before": result.get("issues_before") or [],
                "fixed": True,
            }
        )

    issues = result.get("issues") or result.get("issues_before") or []
    return JsonResponse(
        {
            "ok": False,
            "error": _repair_error_message_for_issues(issues),
            "issues": issues,
            "fixable": False,
        },
        status=400,
    )


@login_required
@require_POST
def save_new_object(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = payload.get("geometry")
    if not isinstance(geometry, dict):
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    name = (payload.get("name") or "").strip()
    request_id = (payload.get("request_id") or "").strip()
    source_label = _normalize_source_label(payload.get("source_label"))
    replace_row_ctid = (payload.get("replace_row_ctid") or payload.get("replaceRowCtid") or "").strip()
    if not request_id:
        return JsonResponse({"ok": False, "error": "Укажите номер заявки (request_id)."}, status=400)
    if not request_id.isdigit():
        return JsonResponse(
            {"ok": False, "error": "Номер заявки (request_id) должен содержать только цифры."}, status=400
        )

    dgi_aprove = finalize_dgi_aprove_record(
        normalize_dgi_aprove_payload(payload.get("dgi_aprove"), request.user.username),
        request.user.username,
    )

    try:
        owner_id = _create_new_object(
            username=request.user.username,
            geometry=geometry,
            name=name,
            request_id=request_id,
            source_label=source_label,
            replace_row_ctid=replace_row_ctid or None,
            dgi_aprove=dgi_aprove,
        )
    except ValueError as exc:
        return JsonResponse({"ok": False, "error": str(exc)}, status=400)
    except Exception as exc:
        logger.exception("save_new_object failed")
        payload = {"ok": False, "error": "Не удалось сохранить объект в geodb."}
        if settings.DEBUG:
            payload["detail"] = str(exc)
        return JsonResponse(payload, status=500)

    return JsonResponse({"ok": True, "owner_id": owner_id})


@login_required
@require_POST
def save_recap_object(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = payload.get("geometry")
    if not isinstance(geometry, dict):
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    name = (payload.get("name") or "").strip()
    request_id = (payload.get("request_id") or "").strip()
    recap_id = (payload.get("recap_id") or "").strip()

    if not recap_id:
        return JsonResponse({"ok": False, "error": "Укажите номер досъёма (recap_id)."}, status=400)
    if not recap_id.isdigit():
        return JsonResponse(
            {"ok": False, "error": "Номер досъёма (recap_id) должен содержать только цифры."}, status=400
        )
    if not request_id:
        return JsonResponse({"ok": False, "error": "Укажите номер заявки (request_id)."}, status=400)
    if not request_id.isdigit():
        return JsonResponse(
            {"ok": False, "error": "Номер заявки (request_id) должен содержать только цифры."}, status=400
        )

    recap_exists = _check_recap_uniqueness(recap_id=recap_id)
    if recap_exists:
        return JsonResponse({"ok": False, "error": "Номер досъёма (recap_id) уже существует."}, status=400)

    dgi_aprove = finalize_dgi_aprove_record(
        normalize_dgi_aprove_payload(payload.get("dgi_aprove"), request.user.username),
        request.user.username,
    )

    try:
        owner_id = _create_recap_object(
            username=request.user.username,
            geometry=geometry,
            name=name,
            request_id=request_id,
            recap_id=recap_id,
            dgi_aprove=dgi_aprove,
        )
    except ValueError as exc:
        return JsonResponse({"ok": False, "error": str(exc)}, status=400)
    except Exception as exc:
        logger.exception("save_recap_object failed")
        payload = {"ok": False, "error": "Не удалось сохранить досъём в recaps."}
        if settings.DEBUG:
            payload["detail"] = str(exc)
        return JsonResponse(payload, status=500)

    return JsonResponse({"ok": True, "owner_id": owner_id, "recap_id": recap_id})


@login_required
@require_GET
def list_owned_recaps(request):
    request_id = (request.GET.get("request_id") or "").strip()
    if not request_id:
        return JsonResponse({"ok": False, "error": "Укажите номер заявки (request_id)."}, status=400)
    if not request_id.isdigit():
        return JsonResponse(
            {"ok": False, "error": "Номер заявки (request_id) должен содержать только цифры."},
            status=400,
        )

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {"ok": False, "error": "Не найден OwnerLegalPersonId для пользователя в таблице users."},
            status=400,
        )

    try:
        recaps = _get_owned_recaps_for_request(owner_id, request_id)
    except Exception:
        logger.exception("list_owned_recaps failed")
        return JsonResponse({"ok": False, "error": "Не удалось получить список досъёмов."}, status=500)

    return JsonResponse({"ok": True, "request_id": request_id, "recaps": recaps})


@login_required
@require_POST
def export_recap_geometry(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    recap_id = str(payload.get("recap_id") or "").strip()
    if not recap_id:
        return JsonResponse({"ok": False, "error": "Укажите номер досъёма (recap_id)."}, status=400)
    if not recap_id.isdigit():
        return JsonResponse(
            {"ok": False, "error": "Номер досъёма (recap_id) должен содержать только цифры."},
            status=400,
        )

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {"ok": False, "error": "Не найден OwnerLegalPersonId для пользователя в таблице users."},
            status=400,
        )

    try:
        row = _get_owned_recap_row(owner_id, recap_id)
    except Exception:
        logger.exception("export_recap_geometry: lookup failed")
        return JsonResponse({"ok": False, "error": "Не удалось загрузить досъём."}, status=500)

    if not row:
        return JsonResponse(
            {"ok": False, "error": "Досъём не найден или нет прав на скачивание."},
            status=404,
        )

    try:
        geometry = json.loads(row["geometry_json"])
    except (TypeError, json.JSONDecodeError):
        return JsonResponse({"ok": False, "error": "Некорректная геометрия досъёма."}, status=500)

    if not isinstance(geometry, dict):
        return JsonResponse({"ok": False, "error": "Некорректная геометрия досъёма."}, status=500)

    try:
        geojson_url, shapefile_url = _export_geometry_files(
            geometry,
            properties={
                "name": row["name"],
                "OwnerLegalPersonId": owner_id,
                "request_id": row["request_id"],
                "recap_id": row["recap_id"],
            },
        )
    except Exception:
        logger.exception("export_recap_geometry: export failed")
        return JsonResponse(
            {"ok": False, "error": "Ошибка формирования файлов экспорта."},
            status=500,
        )

    return JsonResponse({"ok": True, "geojson_url": geojson_url, "shapefile_url": shapefile_url})


@login_required
@require_POST
def delete_recap_object(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    recap_id = str(payload.get("recap_id") or "").strip()
    if not recap_id:
        return JsonResponse({"ok": False, "error": "Укажите номер досъёма (recap_id)."}, status=400)
    if not recap_id.isdigit():
        return JsonResponse(
            {"ok": False, "error": "Номер досъёма (recap_id) должен содержать только цифры."},
            status=400,
        )

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {"ok": False, "error": "Не найден OwnerLegalPersonId для пользователя в таблице users."},
            status=400,
        )

    if not _get_owned_recap_row(owner_id, recap_id):
        return JsonResponse(
            {"ok": False, "error": "Досъём не найден или нет прав на удаление."},
            status=404,
        )

    try:
        with connection.cursor() as cursor:
            owner_field, _request_id_field, _name_field, _geom_field, _hood_suf, _hood_prm = (
                _recaps_owner_scope_columns(cursor)
            )
            cursor.execute(
                f"DELETE FROM recaps WHERE recap_id = %s AND {_quote_ident(owner_field)} = %s RETURNING recap_id",
                [recap_id, owner_id],
            )
            row = cursor.fetchone()
    except Exception:
        logger.exception("delete_recap_object failed")
        return JsonResponse({"ok": False, "error": "Не удалось удалить досъём."}, status=500)

    if not row:
        return JsonResponse(
            {"ok": False, "error": "Досъём не найден или нет прав на удаление."},
            status=404,
        )

    return JsonResponse({"ok": True, "recap_id": str(row[0])})


def _request_wants_json(request):
    accept = request.headers.get("Accept", "")
    if "application/json" in accept:
        return True
    if request.headers.get("X-Requested-With") == "XMLHttpRequest":
        return True
    if str(request.POST.get("format") or request.GET.get("format") or "").strip().lower() == "json":
        return True
    return False


@login_required
@require_POST
def open_owned_object(request):
    rootid = (request.POST.get("rootid") or "").strip()
    name = (request.POST.get("name") or "").strip()
    request_id = (request.POST.get("request_id") or "").strip()
    if rootid.lower() in {"none", "null"}:
        rootid = ""
    if not rootid and not name and not request_id:
        if _request_wants_json(request):
            return JsonResponse({"ok": False, "error": "Не указан объект."}, status=400)
        return redirect("home")

    geometry_detail_mode = str(request.POST.get("geometry_detail_mode") or "").strip().lower()
    if geometry_detail_mode not in {"simplified", "full"}:
        geometry_detail_mode = "simplified" if rootid else "full"
    request.session["entry_point"] = {
        "rootid": rootid,
        "request_id": request_id,
        "name": "" if rootid else name,
        "source_label": _normalize_source_label(request.POST.get("source_label")),
        "entry_source": "owned_passport_list" if rootid else "owned_request_list",
        "geometry_detail_mode": geometry_detail_mode,
    }
    redirect_to = str(request.POST.get("redirect_to") or "").strip().lower()
    if redirect_to == "split_object" and rootid:
        return redirect("split_object")
    view_only = str(request.POST.get("view_only") or "").strip().lower() in {"1", "true", "yes"}
    main_url = reverse("main") + ("?view_only=1" if view_only else "")
    if view_only and _request_wants_json(request):
        return JsonResponse({"ok": True, "url": main_url})
    return redirect(main_url)


@login_required
@require_POST
def open_merged_passports(request):
    request_id = (request.POST.get("request_id") or "").strip()
    target_source_label = _normalize_source_label(request.POST.get("target_source_label"))
    rootid_values = [r.strip() for r in request.POST.getlist("merge_item_rootid")]
    sources = [_normalize_source_label(s) for s in request.POST.getlist("merge_item_source")]
    object_key_values = [k.strip() for k in request.POST.getlist("merge_item_object_key")]
    if len(sources) < 2 or not request_id.isdigit():
        return redirect("home")

    while len(rootid_values) < len(sources):
        rootid_values.append("")
    while len(object_key_values) < len(sources):
        object_key_values.append("")

    merge_items = []
    for rid, sl, ok in zip(rootid_values, sources, object_key_values):
        if rid or ok:
            merge_items.append({"rootid": rid, "object_key": ok, "source_label": sl})
    merge_items = _dedupe_merge_items(merge_items)
    if len(merge_items) < 2:
        return redirect("home")

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return redirect("home")

    scope = resolve_user_scope(request.user.username)
    if not scope.can_write:
        return redirect("home")

    filter_mode = FILTER_DEPARTMENT if scope.filter_field == FILTER_DEPARTMENT else FILTER_OWNER
    owned = _get_owned_objects(owner_id, filter_mode=filter_mode)
    if scope.include_ods:
        owned = _merge_owned_ods_requests(owned, owner_id)
        owned = _enrich_ods_interaction_and_geometry(owned)
    passport_pairs, request_keys, ods_root_pairs = _build_merge_allowed_sets(owned)
    if not all(_merge_item_is_allowed(it, passport_pairs, request_keys, ods_root_pairs) for it in merge_items):
        return redirect("home")

    geometry_detail_mode = str(request.POST.get("geometry_detail_mode") or "").strip().lower()
    if geometry_detail_mode not in {"simplified", "full"}:
        geometry_detail_mode = "simplified"
    request.session["entry_point"] = {
        "rootid": "",
        "request_id": request_id,
        "name": f"Объединение {len(merge_items)} объектов (→ {target_source_label})",
        "source_label": target_source_label,
        "merge_items": merge_items,
        "geometry_detail_mode": geometry_detail_mode,
        "entry_source": "owned_passport_list",
    }
    return redirect("main")


@login_required
def cancel_pending_entry(request):
    request.session.pop("pending_entry_point", None)
    return redirect("home")


@login_required
@require_POST
def confirm_entry_request_id(request):
    request_id = (request.POST.get("request_id") or "").strip()
    if not request_id or not request_id.isdigit():
        return redirect("home")
    pending = request.session.get("pending_entry_point")
    if not pending:
        return redirect("home")
    del request.session["pending_entry_point"]
    pending = dict(pending)
    pending["request_id"] = request_id
    geometry_detail_mode = str(request.POST.get("geometry_detail_mode") or "").strip().lower()
    if geometry_detail_mode not in {"simplified", "full"}:
        geometry_detail_mode = "simplified" if (pending.get("rootid") or "").strip() else "full"
    pending["geometry_detail_mode"] = geometry_detail_mode
    request.session["entry_point"] = pending
    return redirect("main")


@login_required
@require_POST
def prepare_add_object(request):
    scope = resolve_user_scope(request.user.username)
    if not scope.can_write:
        return redirect("home")
    request_id = (request.POST.get("request_id") or "").strip()
    if not request_id or not request_id.isdigit():
        return redirect("home")
    request.session["entry_point"] = {
        "rootid": "",
        "name": "",
        "request_id": request_id,
        "source_label": _normalize_source_label(request.POST.get("source_label")),
    }
    return redirect("add_object")


@login_required
@require_POST
def delete_owned_object(request):
    object_key = (request.POST.get("object_key") or "").strip()
    source_label = _normalize_source_label(request.POST.get("source_label"))
    if not object_key:
        return redirect("home")

    scope = resolve_user_scope(request.user.username)
    if not scope.can_write:
        return redirect("home")

    owner_id = scope.owner_id
    if owner_id is None:
        return redirect("home")

    table = _get_source_table(source_label)
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    department_field_pref = getattr(settings, "GIS_OBJECT_DEPARTMENT_FIELD", "DepartmentLegalPersonId")
    if scope.filter_field == FILTER_DEPARTMENT:
        owner_field_pref = department_field_pref
    else:
        owner_field_pref = _owner_field_pref_for_source(source_label)
    request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")

    with connection.cursor() as cursor:
        if scope.filter_field == FILTER_DEPARTMENT and not _column_exists(cursor, table, department_field_pref):
            return redirect("home")
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_exists = _column_exists(cursor, table, request_id_field_pref)
        where_parts = [
            "ctid = %s::tid",
            f"{_quote_ident(owner_field)} = %s",
        ]
        params = [object_key, owner_id]
        target_request_id = None

        # Keep old protection for DT request objects, but allow ODH objects with rootid.
        if source_label not in ("ОДХ", _top_source_label()):
            rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
            where_parts.append(f"{_quote_ident(rootid_field)} IS NULL")
        if request_id_exists:
            request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
            where_parts.append(f"{_quote_ident(request_id_field)} IS NOT NULL")
            select_request_id_query = (
                f"SELECT {_quote_ident(request_id_field)}::text "
                f"FROM {_quote_ident(table)} "
                f"WHERE {' AND '.join(where_parts)} "
                "LIMIT 1"
            )
            cursor.execute(select_request_id_query, params)
            request_id_row = cursor.fetchone()
            target_request_id = (request_id_row[0] or "").strip() if request_id_row else None

        delete_query = f"DELETE FROM {_quote_ident(table)} WHERE {' AND '.join(where_parts)}"
        cursor.execute(delete_query, params)

        if target_request_id and _column_exists(cursor, "recaps", request_id_field_pref):
            recaps_request_id_field = _resolve_column_name(cursor, "recaps", request_id_field_pref)
            cursor.execute(
                f"DELETE FROM recaps WHERE {_quote_ident(recaps_request_id_field)}::text = %s",
                [target_request_id],
            )

    return redirect("home")


@login_required
def add_object(request):
    entry_point = request.session.get("entry_point") or {}
    effective_request_id = (entry_point.get("request_id") or "").strip()
    return render(
        request,
        "pass_viewer/add_object.html",
        {
            "dgi_moscow_rent_geometry_json": None,
            "dgi_moscow_no_rent_geometry_json": None,
            "dgi_private_rent_geometry_json": None,
            "dgi_private_no_rent_geometry_json": None,
            "odh_geometry_json": None,
            "ozn_geometry_json": None,
            "renew_geometry_json": None,
            "recaps_geometry_json": None,
            "oozt_geometry_json": None,
            "rzd_geometry_json": None,
            "top_geometry_json": None,
            "request_objects_geometry_json": None,
            "selected_rootid": (entry_point.get("rootid") or "").strip(),
            "selected_source_label": _normalize_source_label(entry_point.get("source_label")),
            "effective_request_id": effective_request_id,
            "page_config": add_object_page_config(
                effective_request_id=effective_request_id,
                selected_rootid=(entry_point.get("rootid") or "").strip(),
                selected_source_label=_normalize_source_label(entry_point.get("source_label")),
            ),
        },
    )


@login_required
def add_recap(request):
    request_id = (request.GET.get("request_id") or "").strip()
    name = (request.GET.get("name") or "").strip()
    object_key = (request.GET.get("object_key") or "").strip()
    source_label = _normalize_source_label(request.GET.get("source_label"))
    recap_id_param = (request.GET.get("recap_id") or "").strip()
    initial_recap_id = recap_id_param if recap_id_param.isdigit() else ""
    owner_id = _get_current_user_owner_id(request.user.username)
    scope = resolve_user_scope(request.user.username)
    if not scope.can_write:
        return redirect("home")
    ods_pk = _parse_ods_request_object_key(object_key)
    filter_mode = FILTER_DEPARTMENT if scope.filter_field == FILTER_DEPARTMENT else FILTER_OWNER
    if ods_pk:
        selected_object = _get_owned_ods_request_for_recap(owner_id, object_key)
    else:
        selected_object = _get_owned_request_object(
            owner_id, object_key, source_label=source_label, filter_mode=filter_mode
        )
    if not selected_object:
        return redirect("home")
    if ods_pk and not selected_object.get("geometry_json"):
        return redirect("home")

    selected_geometry = None
    try:
        selected_geometry = json.loads(selected_object["geometry_json"])
    except (TypeError, json.JSONDecodeError):
        selected_geometry = None

    recap_request_id = str(selected_object.get("request_id") or request_id or "").strip()
    reference_layers = _get_reference_layers(
        geometry=selected_object["geometry_json"],
        request_id_filter=recap_request_id or None,
    )
    initial_relations = {"intersects": None, "touches": None, "nearby": None, "request_objects": None}
    if selected_geometry:
        try:
            initial_relations = _get_new_object_relations(
                selected_geometry,
                source_label=selected_object.get("source_label") or source_label,
                request_id_filter=recap_request_id or None,
            )
        except Exception:
            initial_relations = {"intersects": None, "touches": None, "nearby": None, "request_objects": None}

    return render(
        request,
        "pass_viewer/add_recap.html",
        {
            "request_id": selected_object["request_id"] or request_id,
            "name": selected_object["name"] or name,
            "object_key": selected_object["object_key"] or object_key,
            "selected_rootid": selected_object["rootid"] or "",
            "selected_source_label": selected_object.get("source_label") or source_label,
            "selected_geometry_json": selected_object["geometry_json"],
            "intersects_geometry_json": initial_relations.get("intersects"),
            "touches_geometry_json": initial_relations.get("touches"),
            "nearby_geometry_json": initial_relations.get("nearby"),
            "request_objects_geometry_json": initial_relations.get("request_objects"),
            "dgi_moscow_rent_geometry_json": reference_layers["dgi_moscow_rent"],
            "dgi_moscow_no_rent_geometry_json": reference_layers["dgi_moscow_no_rent"],
            "dgi_private_rent_geometry_json": reference_layers["dgi_private_rent"],
            "dgi_private_no_rent_geometry_json": reference_layers["dgi_private_no_rent"],
            "odh_geometry_json": reference_layers["odh"],
            "ozn_geometry_json": reference_layers["ozn"],
            "renew_geometry_json": reference_layers["renew"],
            "recaps_geometry_json": reference_layers["recaps"],
            "oozt_geometry_json": reference_layers["oozt"],
            "rzd_geometry_json": reference_layers["rzd"],
            "top_geometry_json": reference_layers["top"],
            "initial_recap_id": initial_recap_id,
            "page_config": add_recap_page_config(
                request_id=selected_object["request_id"] or request_id,
                name=selected_object["name"] or name,
                selected_source_label=selected_object.get("source_label") or source_label,
                selected_rootid=selected_object["rootid"] or "",
                selected_row_ctid=selected_object["object_key"] or object_key,
                initial_recap_id=initial_recap_id,
            ),
        },
    )


@login_required
@require_POST
def load_map_layer(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    layer_key = str(payload.get("layer") or "").strip()
    if layer_key not in MAP_DEFERRED_LAYER_KEYS:
        return JsonResponse({"ok": False, "error": "Неизвестный слой."}, status=400)

    entry_point = request.session.get("entry_point")
    request_id = str(
        payload.get("request_id")
        or payload.get("request_id_filter")
        or (entry_point or {}).get("request_id")
        or ""
    ).strip() or None

    try:
        if layer_key == "adjacent_dt" or layer_key.startswith("request_objects_"):
            if not entry_point:
                return JsonResponse({"ok": False, "error": "Сначала выберите объект."}, status=400)
            layer_partial = _get_map_layers(entry_point, include_adjacent_layers=True, only_layer=layer_key)
            if layer_partial is None:
                return JsonResponse({"ok": False, "error": "Объект не найден в PostGIS."}, status=404)
        else:
            geometry = _to_intersection_geometry(payload.get("geometry"))
            if not geometry:
                return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)
            layer_partial = _get_single_reference_layer(
                layer_key,
                geometry,
                request_id_filter=request_id,
            )
            if layer_partial is None:
                return JsonResponse({"ok": False, "error": "Неизвестный слой."}, status=400)
    except Exception:
        logger.exception("load_map_layer failed for layer=%s", layer_key)
        return JsonResponse(
            {"ok": False, "error": f"Не удалось загрузить слой ({layer_key})."},
            status=500,
        )

    return JsonResponse(
        {
            "ok": True,
            "layer": layer_key,
            "layers": _relation_layers_for_json_response(layer_partial),
        }
    )


@login_required
@require_POST
def load_map_adjacent_layers(request):
    entry_point = request.session.get("entry_point")
    if not entry_point:
        return JsonResponse({"ok": False, "error": "Сначала выберите объект."}, status=400)

    try:
        layers = _get_map_layers(entry_point, include_adjacent_layers=True)
    except Exception:
        logger.exception("load_map_adjacent_layers: _get_map_layers failed")
        return JsonResponse(
            {"ok": False, "error": "Не удалось получить смежные объекты из PostGIS."},
            status=500,
        )

    if not layers:
        return JsonResponse({"ok": False, "error": "Объект не найден в PostGIS."}, status=404)

    return JsonResponse({"ok": True, "layers": _adjacent_layers_for_json_response(layers)})


@login_required
@require_POST
def load_map_reference_layers(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    entry_point = request.session.get("entry_point")
    geometry = payload.get("geometry")
    if not geometry:
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    request_id = str(
        payload.get("request_id")
        or payload.get("request_id_filter")
        or (entry_point or {}).get("request_id")
        or ""
    ).strip() or None

    try:
        reference_layers = _get_reference_layers(
            geometry=geometry,
            request_id_filter=request_id,
        )
    except Exception:
        logger.exception("load_map_reference_layers failed")
        return JsonResponse(
            {"ok": False, "error": "Не удалось получить справочные слои из PostGIS."},
            status=500,
        )

    return JsonResponse({"ok": True, "layers": _reference_layers_for_json_response(reference_layers)})


@login_required
@require_POST
def load_map_context_layers(request):
    """Legacy single-call loader; prefer load_map_adjacent_layers + load_map_reference_layers."""
    entry_point = request.session.get("entry_point")
    if not entry_point:
        return JsonResponse({"ok": False, "error": "Сначала выберите объект."}, status=400)

    try:
        layers = _get_map_layers(entry_point, include_adjacent_layers=True)
    except Exception:
        logger.exception("load_map_context_layers: _get_map_layers failed")
        return JsonResponse(
            {"ok": False, "error": "Не удалось получить смежные объекты из PostGIS."},
            status=500,
        )

    if not layers:
        return JsonResponse({"ok": False, "error": "Объект не найден в PostGIS."}, status=404)

    request_id = (layers.get("selected_request_id") or entry_point.get("request_id") or "").strip()
    try:
        reference_layers = _get_reference_layers(
            geometry=layers["selected"],
            request_id_filter=request_id or None,
        )
    except Exception:
        logger.exception("load_map_context_layers: reference layers failed")
        reference_layers = {}

    return JsonResponse(
        {
            "ok": True,
            "layers": {
                **_adjacent_layers_for_json_response(layers),
                **_reference_layers_for_json_response(reference_layers),
            },
        }
    )


@login_required
@require_POST
def check_new_object_relations(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry_raw = payload.get("geometry")
    geometry = _to_intersection_geometry(geometry_raw)
    if not geometry:
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)
    selected_geometry = _to_intersection_geometry(payload.get("selected_geometry"))
    geometry_for_selected_check = _to_intersection_geometry(payload.get("geometry_for_selected_check"))
    has_selected_geometry = bool(selected_geometry)
    source_label = _normalize_source_label(payload.get("source_label"))
    request_id_filter = str(payload.get("request_id") or payload.get("request_id_filter") or "").strip() or None

    try:
        layers = _get_new_object_relations(geometry, source_label=source_label, request_id_filter=request_id_filter)
    except Exception:
        logger.exception("check_new_object_relations: failed loading relation layers from PostGIS")
        return JsonResponse({"ok": False, "error": "Не удалось получить связанные объекты из PostGIS."}, status=500)

    intersects_selected = False
    if has_selected_geometry:
        try:
            intersects_input = geometry_for_selected_check or geometry
            intersects_selected = _geometries_intersect(intersects_input, selected_geometry)
        except Exception:
            logger.exception("check_new_object_relations: intersect-with-selected check failed")
            intersects_selected = False

    return JsonResponse(
        {
            "ok": True,
            "layers": _relation_layers_for_json_response(layers),
            "intersects_selected": intersects_selected,
        }
    )


_ASU_ODS_LINK_PREFIX = "https://reestr-ogh.mos.ru/ogh/"
_ASU_ODS_SUFFIX_BY_SOURCE = {
    "ДТ": "38",
    "ОДХ": "01",
    "ОЗН": "40",
}


def _resolve_asu_ods_object_id_geodb(table_name, rootid):
    rootid_text = str(rootid or "").strip()
    if not rootid_text or not table_name:
        return None
    rootid_field = getattr(settings, "GIS_OBJECT_ROOTID_FIELD", "rootid")
    with connection.cursor() as cursor:
        if not _table_exists(cursor, table_name):
            return None
        rootid_col = _resolve_column_name(cursor, table_name, rootid_field)
        objectid_col = _resolve_column_name(cursor, table_name, "objectid")
        if not _column_exists(cursor, table_name, objectid_col):
            return None
        cursor.execute(
            (
                f"SELECT t.{_quote_ident(objectid_col)} "
                f"FROM {_quote_ident(table_name)} t "
                f"WHERE lower(t.{_quote_ident(rootid_col)}::text) = lower(%s) "
                f"AND t.{_quote_ident(objectid_col)} IS NOT NULL "
                f"LIMIT 1"
            ),
            [rootid_text],
        )
        row = cursor.fetchone()
    if not row or row[0] is None:
        return None
    try:
        return int(row[0])
    except (TypeError, ValueError):
        return None


def _resolve_asu_ods_object_id_ozn(rootid):
    rootid_text = str(rootid or "").strip()
    if not rootid_text:
        return None
    schema = getattr(settings, "APPROVAL_ADJACENT_SCHEMA", "master")
    table_name = "OznPoly"
    rootid_col = getattr(settings, "APPROVAL_WORK_ROOTID_COLUMN", "RootId")
    try:
        with connections["qgis"].cursor() as cursor:
            cursor.execute(
                (
                    f"SELECT t.{_quote_ident('ObjectId')} "
                    f"FROM {_quote_ident(schema)}.{_quote_ident(table_name)} t "
                    f"WHERE lower(t.{_quote_ident(rootid_col)}::text) = lower(%s) "
                    f"AND t.{_quote_ident('ObjectId')} IS NOT NULL "
                    f"LIMIT 1"
                ),
                [rootid_text],
            )
            row = cursor.fetchone()
    except Exception:
        logger.exception(
            "asu_ods_url: failed to resolve ObjectId from %s.%s for rootid=%s",
            schema,
            table_name,
            rootid_text,
        )
        return None
    if not row or row[0] is None:
        return None
    try:
        return int(row[0])
    except (TypeError, ValueError):
        return None


def _resolve_asu_ods_object_id(source_label, rootid):
    normalized = _normalize_source_label(source_label)
    if normalized == "ОЗН":
        return _resolve_asu_ods_object_id_ozn(rootid)
    if normalized == "ОДХ":
        return _resolve_asu_ods_object_id_geodb(
            getattr(settings, "GIS_ODH_TABLE", "odh"),
            rootid,
        )
    if normalized == "ДТ":
        return _resolve_asu_ods_object_id_geodb(settings.GIS_OBJECT_TABLE, rootid)
    return None


def _build_asu_ods_url(source_label, rootid):
    raw = str(source_label or "").strip().upper()
    ods_label = str(getattr(settings, "GIS_ODS_REQUEST_SOURCE_LABEL", "ОДС") or "ОДС").strip().upper()
    top_label = _top_source_label().upper()
    if raw in {ods_label, "ОДС"} or raw in {top_label, "TOP"}:
        return None
    normalized = _normalize_source_label(source_label)
    suffix = _ASU_ODS_SUFFIX_BY_SOURCE.get(normalized)
    if not suffix:
        return None
    object_id = _resolve_asu_ods_object_id(normalized, rootid)
    if object_id is None:
        return None
    return f"{_ASU_ODS_LINK_PREFIX}{object_id}000{suffix}"


@login_required
@require_POST
def resolve_asu_ods_url(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    rootid = (payload.get("rootid") or "").strip()
    source_label = payload.get("source_label")
    if not rootid:
        return JsonResponse({"ok": False, "error": "Не передан rootid."}, status=400)

    asu_ods_url = _build_asu_ods_url(source_label, rootid)
    response = {"ok": True}
    if asu_ods_url:
        response["asu_ods_url"] = asu_ods_url
    return JsonResponse(response)


@login_required
@require_POST
def check_dgi_intersections(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = _to_intersection_geometry(payload.get("geometry"))
    if not geometry:
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    for_export = bool(payload.get("for_export"))

    try:
        percents = _get_dgi_intersection_percents_split(geometry)
    except Exception:
        logger.exception("check_dgi_intersections: percent calculation failed")
        if for_export:
            return JsonResponse({"ok": True, "available": False})
        return JsonResponse(
            {"ok": False, "error": "Не удалось вычислить пересечение с объектами ДГИ."},
            status=500,
        )

    percent_moscow = round(float(percents.get("moscow") or 0), 2)
    percent_private = round(float(percents.get("private") or 0), 2)
    percent_moscow_rent = round(float(percents.get("dgi_moscow_rent") or 0), 2)
    percent_moscow_no_rent = round(float(percents.get("dgi_moscow_no_rent") or 0), 2)
    percent_private_rent = round(float(percents.get("dgi_private_rent") or 0), 2)
    percent_private_no_rent = round(float(percents.get("dgi_private_no_rent") or 0), 2)
    percent_renew = round(float(percents.get("renew") or 0), 2)
    percent_oozt = round(float(percents.get("oozt") or 0), 2)
    percent_rzd = round(float(percents.get("rzd") or 0), 2)
    intersects_moscow = percent_moscow > 0
    intersects_private = percent_private > 0
    intersects_info = percent_renew > 0 or percent_oozt > 0 or percent_rzd > 0
    response = {
        "ok": True,
        "intersects": intersects_moscow or intersects_private or intersects_info,
        "percent_moscow": percent_moscow,
        "percent_private": percent_private,
        "percent_moscow_rent": percent_moscow_rent,
        "percent_moscow_no_rent": percent_moscow_no_rent,
        "percent_private_rent": percent_private_rent,
        "percent_private_no_rent": percent_private_no_rent,
        "percent_renew": percent_renew,
        "percent_oozt": percent_oozt,
        "percent_rzd": percent_rzd,
        "intersects_moscow": intersects_moscow,
        "intersects_private": intersects_private,
    }
    if for_export:
        response["available"] = True
    else:
        asu_ods_url = _build_asu_ods_url(
            payload.get("source_label"),
            payload.get("rootid"),
        )
        if asu_ods_url:
            response["asu_ods_url"] = asu_ods_url
    return JsonResponse(response)


@login_required
@require_POST
def auto_remove_intersections(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = _to_intersection_geometry(payload.get("geometry"))
    if not geometry:
        return JsonResponse({"ok": False, "error": "Геометрия не передана."}, status=400)

    selected_sources = payload.get("selected_sources") or []
    if not isinstance(selected_sources, list):
        return JsonResponse({"ok": False, "error": "Некорректный список источников."}, status=400)

    source_label = _normalize_source_label(payload.get("source_label"))
    selected_geometry = _to_intersection_geometry(payload.get("selected_geometry"))
    selected_rootid = (payload.get("selected_rootid") or "").strip()
    selected_request_id = (payload.get("selected_request_id") or "").strip()
    selected_row_ctid = (payload.get("selected_row_ctid") or "").strip()
    page_type = _normalize_auto_remove_page_type(payload.get("type") or payload.get("page"))

    try:
        cleaned_geometry, summ_m2 = _remove_intersections_from_geometry(
            geometry,
            selected_sources=selected_sources,
            source_label=source_label,
            selected_geometry=selected_geometry,
            selected_rootid=selected_rootid,
            selected_request_id=selected_request_id,
            selected_row_ctid=selected_row_ctid,
            page_type=page_type,
        )
    except Exception:
        logger.exception("auto_remove_intersections: failed subtracting intersections")
        return JsonResponse(
            {"ok": False, "error": "Не удалось выполнить автоматическое удаление пересечений."}, status=500
        )

    if cleaned_geometry is not None:
        try:
            areas = _measure_auto_remove_squares_m2(
                geometry,
                cleaned_geometry,
                selected_sources=selected_sources,
                source_label=source_label,
                selected_geometry=selected_geometry,
                selected_rootid=selected_rootid,
                selected_request_id=selected_request_id,
                selected_row_ctid=selected_row_ctid,
                summ_m2=summ_m2,
                page_type=page_type,
            )
            owner_id = _get_current_user_owner_id(request.user.username)
            _insert_auto_remove_square(request.user.username, owner_id, areas, page_type=page_type)
        except Exception:
            logger.exception("auto_remove_intersections: failed recording removed areas")

    return JsonResponse({"ok": True, "geometry": cleaned_geometry})


@login_required
@require_POST
def cut_edited_geometry(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    geometry = _to_intersection_geometry(payload.get("geometry"))
    if not geometry:
        return JsonResponse({"ok": False, "error": "Геометрия редактируемого объекта не передана."}, status=400)

    cutter_geometry = _to_geojson_geometry(payload.get("cutter_geometry"))
    if not cutter_geometry:
        return JsonResponse({"ok": False, "error": "Геометрия обрезки не передана."}, status=400)

    cutter_type = str(payload.get("cutter_type") or "polygon").strip().lower()
    if cutter_type not in {"polygon", "line"}:
        cutter_type = "polygon"

    try:
        result_geometry = _cut_geometry_with_shape(
            geometry,
            cutter_geometry,
            cutter_type=cutter_type,
        )
    except Exception:
        logger.exception("cut_edited_geometry: failed cutting edited geometry")
        return JsonResponse({"ok": False, "error": "Не удалось обрезать геометрию."}, status=500)

    return JsonResponse({"ok": True, "geometry": result_geometry})


@login_required
@require_GET
def list_comment_points(request):
    request_id = (request.GET.get("request_id") or "").strip()
    if not request_id:
        return JsonResponse({"ok": False, "error": "Укажите request_id."}, status=400)

    table = _comment_points_table_name()
    with connection.cursor() as cursor:
        if not _table_exists(cursor, table):
            return JsonResponse({"ok": True, "geojson": {"type": "FeatureCollection", "features": []}})
        t = _quote_ident(table)
        hood_suf, hood_prm = get_hood_intersects_sql_suffix("p.geom")
        cursor.execute(
            f"""
            SELECT p.id, ST_AsGeoJSON(p.geom)::text, p.request_id::text, p.comment, p.owner_legal_person_id::text,
                   to_char(p.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
            FROM {t} p
            WHERE p.request_id::text = %s
            {hood_suf}
            ORDER BY p.id
            """,
            [request_id] + hood_prm,
        )
        rows = cursor.fetchall()

    features = []
    for row in rows:
        id_, geom_json, rid, cmt, oid, created = row
        try:
            geometry = json.loads(geom_json)
        except (TypeError, json.JSONDecodeError):
            continue
        features.append(
            {
                "type": "Feature",
                "id": id_,
                "geometry": geometry,
                "properties": {
                    "id": id_,
                    "request_id": rid,
                    "comment": cmt,
                    "owner_legal_person_id": oid,
                    "created_at": created or "",
                },
            }
        )

    return JsonResponse(
        {
            "ok": True,
            "geojson": {"type": "FeatureCollection", "features": features},
        }
    )


@login_required
@require_POST
def save_comment_point(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    request_id = (payload.get("request_id") or "").strip()
    comment = (payload.get("comment") or "").strip()
    try:
        lng = float(payload.get("lng"))
        lat = float(payload.get("lat"))
    except (TypeError, ValueError):
        return JsonResponse({"ok": False, "error": "Укажите координаты точки (lng, lat)."}, status=400)

    if not request_id or not request_id.isdigit():
        return JsonResponse({"ok": False, "error": "Некорректный или пустой request_id."}, status=400)
    if not comment:
        return JsonResponse({"ok": False, "error": "Введите комментарий."}, status=400)
    if len(comment) > 4000:
        return JsonResponse({"ok": False, "error": "Комментарий слишком длинный (макс. 4000 символов)."}, status=400)
    if not (-180.0 <= lng <= 180.0) or not (-90.0 <= lat <= 90.0):
        return JsonResponse({"ok": False, "error": "Координаты вне допустимого диапазона."}, status=400)

    pt_geom = {"type": "Point", "coordinates": [lng, lat]}
    if not geometry_intersects_allowed_hood(pt_geom):
        return JsonResponse({"ok": False, "error": "Точка вне разрешённой территории."}, status=400)

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {"ok": False, "error": "Не найден OwnerLegalPersonId для пользователя в таблице users."},
            status=400,
        )

    table = _comment_points_table_name()
    try:
        with connection.cursor() as cursor:
            if not _table_exists(cursor, table):
                return JsonResponse(
                    {"ok": False, "error": "Таблица точек комментариев не найдена в базе."},
                    status=500,
                )
            t = _quote_ident(table)
            cursor.execute(
                f"""
                INSERT INTO {t} (request_id, owner_legal_person_id, comment, geom)
                VALUES (%s, %s, %s, ST_SetSRID(ST_MakePoint(%s, %s), 4326))
                RETURNING id,
                    ST_AsGeoJSON(geom)::text,
                    request_id::text,
                    comment,
                    owner_legal_person_id::text,
                    to_char(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                """,
                [request_id, str(owner_id), comment, lng, lat],
            )
            row = cursor.fetchone()
    except Exception:
        logger.exception("save_comment_point: insert failed")
        return JsonResponse({"ok": False, "error": "Не удалось сохранить точку комментария."}, status=500)

    if not row:
        return JsonResponse({"ok": False, "error": "Не удалось сохранить точку комментария."}, status=500)

    id_, geom_json, rid, cmt, oid, created = row
    try:
        geometry = json.loads(geom_json)
    except (TypeError, json.JSONDecodeError):
        geometry = None
    feature = {
        "type": "Feature",
        "id": id_,
        "geometry": geometry,
        "properties": {
            "id": id_,
            "request_id": rid,
            "comment": cmt,
            "owner_legal_person_id": oid,
            "created_at": created or "",
        },
    }
    return JsonResponse({"ok": True, "feature": feature})


@login_required
@require_POST
def delete_comment_point(request):
    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)
    try:
        point_id = int(payload.get("id"))
    except (TypeError, ValueError):
        return JsonResponse({"ok": False, "error": "Некорректный id точки."}, status=400)

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {"ok": False, "error": "Не найден OwnerLegalPersonId для пользователя в таблице users."},
            status=400,
        )

    table = _comment_points_table_name()
    try:
        with connection.cursor() as cursor:
            if not _table_exists(cursor, table):
                return JsonResponse({"ok": False, "error": "Таблица точек комментариев не найдена в базе."}, status=500)
            t = _quote_ident(table)
            cursor.execute(
                f"DELETE FROM {t} WHERE id = %s AND owner_legal_person_id::text = %s RETURNING id",
                [point_id, str(owner_id)],
            )
            row = cursor.fetchone()
    except Exception:
        logger.exception("delete_comment_point: delete failed")
        return JsonResponse({"ok": False, "error": "Не удалось удалить точку комментария."}, status=500)

    if not row:
        return JsonResponse(
            {"ok": False, "error": "Точка не найдена или нет прав на удаление."},
            status=404,
        )
    return JsonResponse({"ok": True, "id": point_id})

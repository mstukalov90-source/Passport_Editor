"""GeoJSON-слои и списки отрисованных заявок и досъёмов для QGIS API (только чтение).

Данные лежат в raw PostGIS-таблицах geodb (pass_objects/odh/ozn/top, recaps),
без ORM-моделей. Отрисованная заявка — строка с непустым request_id и пустым
rootid. Выдача не ограничена по владельцу и hood: доступ только сотрудников
(MGGT/SUP) проверяется на уровне view.
"""

from __future__ import annotations

import json

from django.conf import settings
from django.db import connection

from .views import (
    _build_id_name_lookup_expr,
    _column_exists,
    _get_id_names_lookup_context,
    _gis_municipal_table_specs,
    _gis_object_meta_sql_fragment,
    _normalize_source_label,
    _quote_ident,
    _resolve_column_name,
    _resolve_request_layer_columns,
    _sql_gis_request_only_clause,
    _table_exists,
)

_CUSTOMER_FIELD = "CustomerLegalPersonId"
_DEPARTMENT_FIELD = "DepartmentLegalPersonId"

_REQUEST_PROPERTIES_JSONB = (
    "jsonb_build_object("
    "       'source', source_label::text,"
    "       'request_id', request_id::text,"
    "       'rootid', rootid::text,"
    "       'name', name::text,"
    "       'owner_legal_person_id', owner_legal_person_id::text,"
    "       'owner_legal_person_name', owner_legal_person_name::text,"
    "       'customer_legal_person_id', customer_legal_person_id::text,"
    "       'customer_legal_person_name', customer_legal_person_name::text,"
    "       'department_legal_person_id', department_legal_person_id::text,"
    "       'department_legal_person_name', department_legal_person_name::text,"
    "       'startdate', startdate::text,"
    "       'datesurvey', datesurvey::text,"
    "       'createtype', createtype::text"
    ")"
)

_RECAP_PROPERTIES_JSONB = (
    "jsonb_build_object("
    "       'recap_id', recap_id::text,"
    "       'request_id', request_id::text,"
    "       'name', name::text,"
    "       'owner_legal_person_id', owner_legal_person_id::text,"
    "       'owner_legal_person_name', owner_legal_person_name::text"
    ")"
)


def _empty_collection():
    return {"type": "FeatureCollection", "features": []}


def _fetch_json(cursor) -> list | dict | None:
    row = cursor.fetchone()
    if not row or not row[0]:
        return None
    return json.loads(row[0])


def _optional_legal_person_selects(cursor, table, field_name, id_alias, name_alias, lookup_context):
    """(id_expr, name_expr) с явными snake_case-алиасами для опциональной колонки."""
    if not _column_exists(cursor, table, field_name):
        return f"NULL::text AS {id_alias}", f"NULL::text AS {name_alias}"
    col = f"t.{_quote_ident(_resolve_column_name(cursor, table, field_name))}"
    id_select = f"{col}::text AS {id_alias}"
    name_select = f"{_build_id_name_lookup_expr(col, lookup_context)} AS {name_alias}"
    return id_select, name_select


def _build_request_layer_branch(cursor, spec, lookup_context):
    """(SQL-ветка, ref колонки request_id) одного источника (ДТ/ОДХ/ОЗН/ТОП).

    None, если источник не готов (нет таблицы/колонок).
    """
    source_label, table, owner_candidates = spec
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    geom_field = settings.GIS_OBJECT_GEOM_FIELD
    request_id_field = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")

    columns = _resolve_request_layer_columns(
        cursor, table, geom_field, rootid_field, name_field, request_id_field
    )
    if not columns:
        return None

    geom_ref = f"t.{_quote_ident(columns['geom'])}"
    request_id_ref = f"t.{_quote_ident(columns['request_id'])}"
    rootid_ref = (
        f"t.{_quote_ident(columns['rootid'])}::text" if columns.get("rootid") else "NULL::text"
    )
    name_ref = f"t.{_quote_ident(columns['name'])}::text" if columns.get("name") else "NULL::text"

    owner_col = ""
    for candidate in owner_candidates:
        if _column_exists(cursor, table, candidate):
            owner_col = f"t.{_quote_ident(_resolve_column_name(cursor, table, candidate))}"
            break
    if owner_col:
        owner_id_select = f"{owner_col}::text AS owner_legal_person_id"
        owner_name_select = (
            f"{_build_id_name_lookup_expr(owner_col, lookup_context)} "
            "AS owner_legal_person_name"
        )
    else:
        owner_id_select = "NULL::text AS owner_legal_person_id"
        owner_name_select = "NULL::text AS owner_legal_person_name"

    customer_id_select, customer_name_select = _optional_legal_person_selects(
        cursor, table, _CUSTOMER_FIELD,
        "customer_legal_person_id", "customer_legal_person_name", lookup_context,
    )
    department_id_select, department_name_select = _optional_legal_person_selects(
        cursor, table, _DEPARTMENT_FIELD,
        "department_legal_person_id", "department_legal_person_name", lookup_context,
    )
    meta_fragment = _gis_object_meta_sql_fragment(cursor, table, "t")

    select_sql = (
        f" SELECT {geom_ref} AS geom, {rootid_ref} AS rootid, {name_ref} AS name,"
        f" {request_id_ref}::text AS request_id,"
        f" '{source_label}'::text AS source_label,"
        f" {owner_id_select}, {owner_name_select},"
        f" {customer_id_select}, {customer_name_select},"
        f" {department_id_select}, {department_name_select},"
        f" {meta_fragment}"
        f" FROM {_quote_ident(table)} t"
        " WHERE TRUE"
        + _sql_gis_request_only_clause(cursor, table, "t")
    )
    return select_sql, request_id_ref


def _requests_rel_cte(*, request_id=None, source=None):
    """("WITH rel AS (…)", params) — объединение источников заявок.

    None, если ни один источник не готов.
    """
    request_id_text = str(request_id or "").strip()
    source_norm = _normalize_source_label(source) if source else ""

    with connection.cursor() as cursor:
        lookup_context = _get_id_names_lookup_context(cursor)
        branches = []
        params = []
        for spec in _gis_municipal_table_specs():
            if source_norm and spec[0] != source_norm:
                continue
            built = _build_request_layer_branch(cursor, spec, lookup_context)
            if built is None:
                continue
            branch_sql, request_id_ref = built
            if request_id_text:
                branch_sql += f" AND {request_id_ref}::text = %s"
                params.append(request_id_text)
            branches.append(branch_sql)

    if not branches:
        return None, None
    return "WITH rel AS (" + " UNION ALL ".join(branches) + ") ", params


def _recaps_rel_cte(*, request_id=None, recap_id=None):
    """("WITH rel AS (…)", params) — выборка досъёмов из recaps."""
    request_id_text = str(request_id or "").strip()
    recap_id_text = str(recap_id or "").strip()

    with connection.cursor() as cursor:
        if not _table_exists(cursor, "recaps"):
            return None, None

        name_field_pref = settings.GIS_OBJECT_NAME_FIELD
        owner_field_pref = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
        request_id_field_pref = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
        lookup_context = _get_id_names_lookup_context(cursor)

        name_select_expr = "NULL::text AS name"
        owner_select_expr = "NULL::text AS owner_legal_person_id"
        owner_name_select_expr = "NULL::text AS owner_legal_person_name"
        if _column_exists(cursor, "recaps", name_field_pref):
            name_field = _resolve_column_name(cursor, "recaps", name_field_pref)
            name_select_expr = f"t.{_quote_ident(name_field)}::text AS name"
        if _column_exists(cursor, "recaps", owner_field_pref):
            owner_field = _resolve_column_name(cursor, "recaps", owner_field_pref)
            owner_ref = f"t.{_quote_ident(owner_field)}"
            owner_select_expr = f"{owner_ref}::text AS owner_legal_person_id"
            owner_name_select_expr = (
                f"{_build_id_name_lookup_expr(owner_ref, lookup_context)} "
                "AS owner_legal_person_name"
            )
        request_id_col = _resolve_column_name(cursor, "recaps", request_id_field_pref)
        request_id_ref = f"t.{_quote_ident(request_id_col)}"

        conditions = []
        params = []
        if request_id_text:
            conditions.append(f"{request_id_ref}::text = %s")
            params.append(request_id_text)
        if recap_id_text:
            conditions.append("t.recap_id::text = %s")
            params.append(recap_id_text)
        where_sql = (" WHERE " + " AND ".join(conditions)) if conditions else ""

        rel_sql = (
            "WITH rel AS ("
            f" SELECT t.geom AS geom, t.recap_id::text AS recap_id,"
            f" {request_id_ref}::text AS request_id,"
            f" {name_select_expr}, {owner_select_expr}, {owner_name_select_expr}"
            " FROM recaps t"
            f"{where_sql}"
            " ORDER BY t.recap_id"
            ") "
        )
    return rel_sql, params


def build_requests_layer_geojson(*, request_id=None, source=None):
    """FeatureCollection отрисованных заявок по всем источникам (ДТ/ОДХ/ОЗН/ТОП).

    source — нормализованная метка источника (фильтр по одному источнику).
    """
    rel_sql, params = _requests_rel_cte(request_id=request_id, source=source)
    if rel_sql is None:
        return _empty_collection()

    query = (
        rel_sql
        + "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', " + _REQUEST_PROPERTIES_JSONB +
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        result = _fetch_json(cursor)
    if not result:
        return _empty_collection()
    return result


def build_requests_list(*, request_id=None, source=None):
    """Список отрисованных заявок (properties без геометрии)."""
    rel_sql, params = _requests_rel_cte(request_id=request_id, source=source)
    if rel_sql is None:
        return []

    query = (
        rel_sql
        + "SELECT COALESCE(jsonb_agg(" + _REQUEST_PROPERTIES_JSONB + "), '[]'::jsonb)::text"
        " FROM rel"
    )
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        result = _fetch_json(cursor)
    return result or []


def build_recaps_layer_geojson(*, request_id=None, recap_id=None):
    """FeatureCollection досъёмов из таблицы recaps (все владельцы)."""
    rel_sql, params = _recaps_rel_cte(request_id=request_id, recap_id=recap_id)
    if rel_sql is None:
        return _empty_collection()

    query = (
        rel_sql
        + "SELECT jsonb_build_object("
        " 'type', 'FeatureCollection',"
        " 'features', COALESCE(jsonb_agg(jsonb_build_object("
        "   'type', 'Feature',"
        "   'geometry', ST_AsGeoJSON(geom)::jsonb,"
        "   'properties', " + _RECAP_PROPERTIES_JSONB +
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        result = _fetch_json(cursor)
    if not result:
        return _empty_collection()
    return result


def build_recaps_list(*, request_id=None, recap_id=None):
    """Список досъёмов (properties без геометрии), упорядочен по recap_id."""
    rel_sql, params = _recaps_rel_cte(request_id=request_id, recap_id=recap_id)
    if rel_sql is None:
        return []

    query = (
        rel_sql
        + "SELECT COALESCE(jsonb_agg(" + _RECAP_PROPERTIES_JSONB + "), '[]'::jsonb)::text"
        " FROM rel"
    )
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        result = _fetch_json(cursor)
    return result or []

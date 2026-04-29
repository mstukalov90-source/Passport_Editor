import json
import re
import uuid
import zipfile
from datetime import date
from pathlib import Path

from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.db import connection
from django.views.decorators.http import require_POST
from osgeo import gdal, ogr, osr

from .forms import EntryPointForm
from .models import ExternalUser

gdal.UseExceptions()


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


def _get_current_user_owner_id(username):
    user = ExternalUser.objects.filter(login=username).only('owner_legal_person_id').first()
    return user.owner_legal_person_id if user else None


def _get_id_names_lookup_context(cursor):
    table = getattr(settings, 'GIS_ID_NAMES_TABLE', 'id_names')
    if not _table_exists(cursor, table):
        return None

    id_candidates = [
        'OwnerLegalPersonId',
        'CustomerLegalPersonId',
        'DepartmentLegalPersonId',
        'LegalPersonId',
        'id',
    ]
    name_candidates = ['name', 'Name', 'title', 'Title', 'full_name', 'short_name']

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
        id_like = [column for column in columns if column.lower().endswith('id')]
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
        name_like = [column for column in columns if 'name' in column.lower()]
        name_field = name_like[0] if name_like else None
    if not name_field:
        return None

    return {
        'table': table,
        'id_field': id_field,
        'name_field': name_field,
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


def _get_owned_objects(owner_legal_person_id):
    primary_table = settings.GIS_OBJECT_TABLE
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    odh_customer_field_pref = getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')
    tables_to_query = [primary_table, 'odh']

    owned_items = []
    seen_keys = set()
    seen_tables = set()
    with connection.cursor() as cursor:
        for table in tables_to_query:
            if table in seen_tables:
                continue
            seen_tables.add(table)
            source_label = 'ОДХ' if table.lower() == 'odh' else 'ДТ'
            owner_field_candidates = (
                [odh_customer_field_pref, owner_field_pref]
                if table.lower() == 'odh'
                else [owner_field_pref]
            )
            owner_field = None
            for candidate in owner_field_candidates:
                if _column_exists(cursor, table, candidate):
                    owner_field = _resolve_column_name(cursor, table, candidate)
                    break
            if not owner_field:
                continue
            request_id_expr = "''::text AS request_id"
            if _column_exists(cursor, table, request_id_field_pref):
                request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
                request_id_expr = f"{_quote_ident(request_id_field)}::text AS request_id"

            query = (
                f"SELECT ctid::text, {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, "
                f"{request_id_expr} "
                f"FROM {_quote_ident(table)} "
                f"WHERE {_quote_ident(owner_field)} = %s "
                f"ORDER BY {_quote_ident(name_field)} ASC NULLS LAST, {_quote_ident(rootid_field)} ASC "
                f"LIMIT 500"
            )
            cursor.execute(query, [owner_legal_person_id])
            rows = cursor.fetchall()

            for row in rows:
                item = {
                    'object_key': row[0],
                    'rootid': row[1],
                    'name': row[2] or '',
                    'request_id': row[3] or '',
                    'source_label': source_label,
                }
                key = (
                    (item['rootid'] or '').strip().lower(),
                    (item['name'] or '').strip().lower(),
                    (item['request_id'] or '').strip().lower(),
                )
                if key in seen_keys:
                    continue
                seen_keys.add(key)
                owned_items.append(item)

    return sorted(
        owned_items,
        key=lambda item: (
            (item.get('name') or '').lower(),
            (item.get('rootid') or '').lower(),
            (item.get('request_id') or '').lower(),
        ),
    )


def _normalize_source_label(value):
    source = str(value or '').strip().upper()
    return 'ОДХ' if source == 'ОДХ' else 'ДТ'


def _get_source_table(source_label):
    return getattr(settings, 'GIS_ODH_TABLE', 'odh') if _normalize_source_label(source_label) == 'ОДХ' else settings.GIS_OBJECT_TABLE


def _get_recap_counts_by_request_ids(request_ids):
    normalized_ids = [str(value).strip() for value in request_ids if str(value).strip()]
    if not normalized_ids:
        return {}

    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT "request_id"::text AS request_id, COUNT(*)::int AS recap_count
            FROM recaps
            WHERE "request_id"::text = ANY(%s)
            GROUP BY "request_id"::text
            """,
            [normalized_ids],
        )
        rows = cursor.fetchall()

    return {row[0]: row[1] for row in rows}


def _get_owned_request_object(owner_legal_person_id, object_key, source_label='ДТ'):
    if not owner_legal_person_id or not object_key:
        return None

    normalized_source = _normalize_source_label(source_label)
    table = _get_source_table(normalized_source)
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field_pref = (
        getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
        if normalized_source == 'ОДХ'
        else getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    )
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
        query = (
            f"SELECT ctid::text, {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, "
            f"{_quote_ident(request_id_field)}::text, ST_AsGeoJSON({_quote_ident(geom_field)}) "
            f"FROM {_quote_ident(table)} "
            f"WHERE ctid = %s::tid "
            f"  AND {_quote_ident(owner_field)} = %s "
            f"  AND {_quote_ident(request_id_field)} IS NOT NULL "
            f"LIMIT 1"
        )
        cursor.execute(query, [object_key, owner_legal_person_id])
        row = cursor.fetchone()

    if not row:
        return None

    return {
        'object_key': row[0],
        'rootid': row[1],
        'name': row[2] or '',
        'request_id': row[3] or '',
        'geometry_json': row[4],
        'source_label': normalized_source,
    }


def _build_where_clause(entry_point, rootid_field, name_field, request_id_field=None):
    raw_rootid = (entry_point.get('rootid') or '').strip()
    if raw_rootid.lower() in {'none', 'null'}:
        raw_rootid = ''
    raw_request_id = (entry_point.get('request_id') or '').strip()

    if raw_rootid:
        # Compare as text so rootid can be safely passed from UI.
        return f"{rootid_field}::text = %s", [raw_rootid]
    if request_id_field and raw_request_id:
        return f"{request_id_field}::text = %s", [raw_request_id]
    return f"{name_field} ILIKE %s", [(entry_point.get('name') or '').strip()]


def _find_manual_entry_point(rootid='', name=''):
    rootid = (rootid or '').strip()
    name = (name or '').strip()
    if not rootid and not name:
        return None

    primary_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    seen_tables = set()
    with connection.cursor() as cursor:
        for table in [primary_table, odh_table]:
            if table in seen_tables:
                continue
            seen_tables.add(table)

            if not _column_exists(cursor, table, rootid_field_pref) or not _column_exists(cursor, table, name_field_pref):
                continue

            rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
            name_field = _resolve_column_name(cursor, table, name_field_pref)
            request_id_select_expr = "NULL::text AS request_id"
            if _column_exists(cursor, table, request_id_field_pref):
                request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)
                request_id_select_expr = f"{_quote_ident(request_id_field)}::text AS request_id"

            if rootid:
                query = (
                    f"SELECT {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, {request_id_select_expr} "
                    f"FROM {_quote_ident(table)} "
                    f"WHERE {_quote_ident(rootid_field)}::text = %s "
                    "LIMIT 1"
                )
                cursor.execute(query, [rootid])
            else:
                query = (
                    f"SELECT {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, {request_id_select_expr} "
                    f"FROM {_quote_ident(table)} "
                    f"WHERE {_quote_ident(name_field)} ILIKE %s "
                    "LIMIT 1"
                )
                cursor.execute(query, [name])

            row = cursor.fetchone()
            if not row:
                continue

            found_rootid = (row[0] or '').strip()
            found_name = (row[1] or '').strip()
            found_request_id = (row[2] or '').strip()
            source_label = 'ОДХ' if table.lower() == odh_table.lower() else 'ДТ'
            return {
                'rootid': found_rootid,
                'name': found_name,
                'request_id': found_request_id if not found_rootid else '',
                'source_label': source_label,
            }
    return None


def _get_map_layers(entry_point):
    source_label = _normalize_source_label(entry_point.get('source_label'))
    table = _get_source_table(source_label)
    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    geom_field = settings.GIS_OBJECT_GEOM_FIELD
    request_id_field = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')
    customer_field_pref = getattr(settings, 'GIS_OBJECT_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    department_field_pref = getattr(settings, 'GIS_OBJECT_DEPARTMENT_FIELD', 'DepartmentLegalPersonId')
    owner_field_pref_dt = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    owner_field_pref_odh = getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')

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

    where_clause, where_params = _build_where_clause(entry_point, rootid_field, name_field, request_id_field)
    selected_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {rootid_field} AS rootid, {name_field} AS name, {request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr_selected}, {department_name_select_expr_selected}, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        ") "
        "SELECT ST_AsGeoJSON(geom), rootid::text, name::text, request_id::text, "
        "customer_legal_person_id::text, department_legal_person_id::text, "
        "customer_legal_person_name::text, department_legal_person_name::text "
        "FROM selected"
    )
    intersects_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
        f"FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_Intersects("
        f"   t.{geom_field},"
        "   s.geom"
        " ) AND NOT ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
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
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    touches_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), neighbors AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
        f"FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
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
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM neighbors"
    )
    nearby_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), nearby AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
        f"FROM {table} t, selected s"
        " WHERE t.ctid <> s.ctid AND ST_DWithin("
        f"   t.{geom_field}::geography,"
        "   s.geom::geography, 10"
        " ) AND NOT ST_Touches("
        f"   t.{geom_field},"
        "   s.geom"
        " ) AND NOT ST_Intersects("
        f"   t.{geom_field},"
        "   s.geom"
        " )"
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
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM nearby"
    )
    requests_sql = (
        "WITH selected AS ("
        f" SELECT ctid, {geom_field} AS geom FROM {table}"
        f" WHERE {where_clause} LIMIT 1"
        "), ix AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
        " WHERE ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   AND NOT (%s = %s AND t.ctid = s.ctid)"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, selected s"
        " WHERE ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   AND NOT (%s = %s AND t.ctid = s.ctid)"
        "), tg AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
        " WHERE ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   AND NOT (%s = %s AND t.ctid = s.ctid)"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, selected s"
        " WHERE ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   AND NOT (%s = %s AND t.ctid = s.ctid)"
        "), nr AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
        " WHERE ST_DWithin(t.{geom_field}::geography, s.geom::geography, 10)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   AND NOT (%s = %s AND t.ctid = s.ctid)"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, selected s"
        " WHERE ST_DWithin(t.{geom_field}::geography, s.geom::geography, 10)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   AND NOT (%s = %s AND t.ctid = s.ctid)"
        "), rel AS ("
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name FROM ix"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name FROM tg"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name FROM nr"
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
        "      'owner_legal_person_id', owner_legal_person_id::text,"
        "      'owner_legal_person_name', owner_legal_person_name::text,"
        "      'customer_legal_person_id', NULL::text,"
        "      'department_legal_person_id', NULL::text,"
        "      'customer_legal_person_name', NULL::text,"
        "      'department_legal_person_name', NULL::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )

    with connection.cursor() as cursor:
        cursor.execute(selected_sql, where_params)
        selected_row = cursor.fetchone()
        selected_geometry = selected_row[0] if selected_row else None
        selected_rootid = selected_row[1] if selected_row else None
        selected_name = selected_row[2] if selected_row else None
        selected_request_id = selected_row[3] if selected_row else None
        selected_customer_legal_person_id = selected_row[4] if selected_row else None
        selected_department_legal_person_id = selected_row[5] if selected_row else None
        selected_customer_legal_person_name = selected_row[6] if selected_row else None
        selected_department_legal_person_name = selected_row[7] if selected_row else None
        if not selected_geometry:
            return None

        cursor.execute(intersects_sql, where_params)
        intersects_row = cursor.fetchone()

        cursor.execute(touches_sql, where_params)
        touches_row = cursor.fetchone()

        cursor.execute(nearby_sql, where_params)
        nearby_row = cursor.fetchone()

        requests_params = where_params + [
            table, dt_table,
            table, odh_table,
            table, dt_table,
            table, odh_table,
            table, dt_table,
            table, odh_table,
        ]
        cursor.execute(requests_sql, requests_params)
        requests_row = cursor.fetchone()

    return {
        'selected': selected_geometry,
        'selected_rootid': selected_rootid,
        'selected_name': selected_name,
        'selected_request_id': selected_request_id,
        'selected_customer_legal_person_id': selected_customer_legal_person_id,
        'selected_department_legal_person_id': selected_department_legal_person_id,
        'selected_customer_legal_person_name': selected_customer_legal_person_name,
        'selected_department_legal_person_name': selected_department_legal_person_name,
        'selected_source_label': source_label,
        'intersects': intersects_row[0] if intersects_row else None,
        'touches': touches_row[0] if touches_row else None,
        'nearby': nearby_row[0] if nearby_row else None,
        'request_objects': requests_row[0] if requests_row else None,
    }


def _export_geometry_files(geometry, properties=None):
    properties = properties or {}
    export_properties = {
        'name': (properties.get('name') or ''),
        'OwnerLegalPersonId': (
            None if properties.get('OwnerLegalPersonId') is None else str(properties.get('OwnerLegalPersonId'))
        ),
        'request_id': (properties.get('request_id') or ''),
    }

    export_root = Path(settings.MEDIA_ROOT) / 'exports'
    export_root.mkdir(parents=True, exist_ok=True)
    export_id = uuid.uuid4().hex
    export_dir = export_root / export_id
    export_dir.mkdir(parents=True, exist_ok=True)

    request_id_raw = str(export_properties.get('request_id') or '').strip()
    request_id_safe = re.sub(r'[^A-Za-z0-9._-]+', '_', request_id_raw).strip('._-')
    if not request_id_safe:
        request_id_safe = 'request'
    request_id_safe = request_id_safe[:80]
    export_date = date.today().strftime('%Y%m%d')
    base_filename = f"{request_id_safe}_{export_date}"

    feature = {'type': 'Feature', 'properties': export_properties, 'geometry': geometry}
    feature_collection = {'type': 'FeatureCollection', 'features': [feature]}
    geojson_path = export_dir / f'{base_filename}.geojson'
    geojson_path.write_text(json.dumps(feature_collection, ensure_ascii=False), encoding='utf-8')

    shp_path = export_dir / f'{base_filename}.shp'
    gdal.SetConfigOption('SHAPE_ENCODING', 'UTF-8')
    driver = ogr.GetDriverByName('ESRI Shapefile')
    datasource = driver.CreateDataSource(str(shp_path))
    spatial_ref = osr.SpatialReference()
    spatial_ref.ImportFromEPSG(4326)
    layer = datasource.CreateLayer(
        base_filename[:30],
        spatial_ref,
        ogr.wkbUnknown,
        options=['ENCODING=UTF-8'],
    )
    layer.CreateField(ogr.FieldDefn('id', ogr.OFTInteger))
    layer.CreateField(ogr.FieldDefn('name', ogr.OFTString))
    layer.CreateField(ogr.FieldDefn('owner_id', ogr.OFTString))
    layer.CreateField(ogr.FieldDefn('request_id', ogr.OFTString))
    definition = layer.GetLayerDefn()
    ogr_feature = ogr.Feature(definition)
    ogr_feature.SetField('id', 1)
    ogr_feature.SetField('name', export_properties.get('name') or '')
    ogr_feature.SetField('owner_id', export_properties.get('OwnerLegalPersonId') or '')
    ogr_feature.SetField('request_id', export_properties.get('request_id') or '')
    ogr_geometry = ogr.CreateGeometryFromJson(json.dumps(geometry))
    ogr_feature.SetGeometry(ogr_geometry)
    layer.CreateFeature(ogr_feature)
    ogr_feature = None
    datasource = None

    zip_path = export_dir / f'{base_filename}_shp.zip'
    with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
        for ext in ('shp', 'shx', 'dbf', 'prj', 'cpg'):
            part = export_dir / f'{base_filename}.{ext}'
            if part.exists():
                archive.write(part, arcname=part.name)

    base_url = settings.MEDIA_URL.rstrip('/')
    geojson_url = f"{base_url}/exports/{export_id}/{base_filename}.geojson"
    shapefile_url = f"{base_url}/exports/{export_id}/{base_filename}_shp.zip"
    return geojson_url, shapefile_url


def _get_new_object_relations(geometry, source_label='ДТ'):
    table = _get_source_table(source_label)
    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    geom_field = settings.GIS_OBJECT_GEOM_FIELD
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    request_id_field = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')
    customer_field_pref = getattr(settings, 'GIS_OBJECT_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    department_field_pref = getattr(settings, 'GIS_OBJECT_DEPARTMENT_FIELD', 'DepartmentLegalPersonId')
    owner_field_pref_dt = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    owner_field_pref_odh = getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    geometry_json = json.dumps(geometry)

    customer_select_expr = "NULL::text AS customer_legal_person_id"
    department_select_expr = "NULL::text AS department_legal_person_id"
    customer_name_select_expr = "NULL::text AS customer_legal_person_name"
    department_name_select_expr = "NULL::text AS department_legal_person_name"
    customer_prop_expr = "customer_legal_person_id::text"
    department_prop_expr = "department_legal_person_id::text"
    customer_name_prop_expr = "customer_legal_person_name::text"
    department_name_prop_expr = "department_legal_person_name::text"
    request_owner_dt_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_dt_name_select_expr = "NULL::text AS owner_legal_person_name"
    request_owner_odh_select_expr = "NULL::text AS owner_legal_person_id"
    request_owner_odh_name_select_expr = "NULL::text AS owner_legal_person_name"
    with connection.cursor() as cursor:
        lookup_context = _get_id_names_lookup_context(cursor)
        if _column_exists(cursor, table, customer_field_pref):
            customer_field = _resolve_column_name(cursor, table, customer_field_pref)
            customer_select_expr = f"{_quote_ident(customer_field)}::text AS customer_legal_person_id"
            customer_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, table, department_field_pref):
            department_field = _resolve_column_name(cursor, table, department_field_pref)
            department_select_expr = f"{_quote_ident(department_field)}::text AS department_legal_person_id"
            department_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(department_field)}', lookup_context)} "
                "AS department_legal_person_name"
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

    intersects_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
        f"FROM {table} t, input i"
        f" WHERE ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
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
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    touches_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
        f"FROM {table} t, input i"
        f" WHERE ST_Touches(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
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
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    nearby_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
        f"FROM {table} t, input i"
        f" WHERE ST_DWithin(t.{geom_field}::geography, i.geom::geography, 10)"
        f"   AND NOT ST_Touches(t.{geom_field}, i.geom)"
        f"   AND NOT ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
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
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    request_objects_sql = (
        "WITH input AS ("
        " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), ix AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, input i"
        f" WHERE ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        "), tg AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE ST_Touches(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, input i"
        f" WHERE ST_Touches(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        "), nr AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE ST_DWithin(t.{geom_field}::geography, i.geom::geography, 10)"
        f"   AND NOT ST_Touches(t.{geom_field}, i.geom)"
        f"   AND NOT ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, input i"
        f" WHERE ST_DWithin(t.{geom_field}::geography, i.geom::geography, 10)"
        f"   AND NOT ST_Touches(t.{geom_field}, i.geom)"
        f"   AND NOT ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        "), rel AS ("
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name FROM ix"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name FROM tg"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name FROM nr"
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
        "      'owner_legal_person_id', owner_legal_person_id::text,"
        "      'owner_legal_person_name', owner_legal_person_name::text,"
        "      'customer_legal_person_id', NULL::text,"
        "      'department_legal_person_id', NULL::text,"
        "      'customer_legal_person_name', NULL::text,"
        "      'department_legal_person_name', NULL::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )

    with connection.cursor() as cursor:
        cursor.execute(intersects_sql, [geometry_json])
        intersects_row = cursor.fetchone()
        cursor.execute(touches_sql, [geometry_json])
        touches_row = cursor.fetchone()
        cursor.execute(nearby_sql, [geometry_json])
        nearby_row = cursor.fetchone()
        cursor.execute(request_objects_sql, [geometry_json])
        request_objects_row = cursor.fetchone()
    ref_layers = _get_reference_layers(geometry=geometry, distance_meters=100)

    return {
        'intersects': intersects_row[0] if intersects_row else None,
        'touches': touches_row[0] if touches_row else None,
        'nearby': nearby_row[0] if nearby_row else None,
        'request_objects': request_objects_row[0] if request_objects_row else None,
        'dgi': ref_layers['dgi'],
        'odh': ref_layers['odh'],
        'recaps': ref_layers['recaps'],
    }


def _get_dgi_intersection_percent(geometry):
    dgi_table = getattr(settings, 'GIS_DGI_TABLE', 'dgi')
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    geometry_json = json.dumps(geometry)
    with connection.cursor() as cursor:
        geom_field = _resolve_column_name(cursor, dgi_table, geom_field_pref)
        query = (
            "WITH input AS ("
            " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
            "), input_area AS ("
            " SELECT ST_Area(geom::geography) AS total_area FROM input"
            "), dgi_intersections AS ("
            f" SELECT ST_Intersection(d.{_quote_ident(geom_field)}, i.geom) AS geom"
            f" FROM {_quote_ident(dgi_table)} d, input i"
            f" WHERE ST_Intersects(d.{_quote_ident(geom_field)}, i.geom)"
            "), overlap AS ("
            " SELECT ST_Area(COALESCE(ST_UnaryUnion(ST_Collect(geom)), ST_GeomFromText('POLYGON EMPTY', 4326))::geography) AS overlap_area"
            " FROM dgi_intersections"
            ") "
            "SELECT CASE "
            "  WHEN ia.total_area IS NULL OR ia.total_area = 0 THEN 0 "
            "  ELSE LEAST(100.0, (COALESCE(o.overlap_area, 0) * 100.0) / ia.total_area) "
            "END AS overlap_percent "
            "FROM input_area ia CROSS JOIN overlap o"
        )
        cursor.execute(query, [geometry_json])
        row = cursor.fetchone()
        return float(row[0]) if row and row[0] is not None else 0.0


def _ensure_request_id_column(cursor, table_name, request_id_field):
    cursor.execute(
        f"ALTER TABLE {_quote_ident(table_name)} "
        f"ADD COLUMN IF NOT EXISTS {_quote_ident(request_id_field)} text"
    )


def _create_new_object(username, geometry, name, request_id, source_label='ДТ'):
    owner_id = _get_current_user_owner_id(username)
    if owner_id is None:
        raise ValueError('Не найден OwnerLegalPersonId пользователя в таблице users.')

    normalized_source = _normalize_source_label(source_label)
    table = _get_source_table(normalized_source)
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field_pref = (
        getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
        if normalized_source == 'ОДХ'
        else getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    )
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)

        _ensure_request_id_column(cursor, table, request_id_field)

        insert_query = (
            f"INSERT INTO {_quote_ident(table)} ("
            f"{_quote_ident(rootid_field)}, "
            f"{_quote_ident(name_field)}, "
            f"{_quote_ident(owner_field)}, "
            f"{_quote_ident(request_id_field)}, "
            f"{_quote_ident(geom_field)}"
            ") VALUES (%s, %s, %s, %s, ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))"
        )
        cursor.execute(insert_query, [None, name, owner_id, request_id, json.dumps(geometry)])
    return owner_id


def _create_recap_object(username, geometry, name, request_id, recap_id):
    owner_id = _get_current_user_owner_id(username)
    if owner_id is None:
        raise ValueError('Не найден OwnerLegalPersonId пользователя в таблице users.')

    table = 'recaps'
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)

        _ensure_request_id_column(cursor, table, request_id_field)

        insert_query = (
            f"INSERT INTO {_quote_ident(table)} ("
            f"{_quote_ident('recap_id')}, "
            f"{_quote_ident(rootid_field)}, "
            f"{_quote_ident(name_field)}, "
            f"{_quote_ident(owner_field)}, "
            f"{_quote_ident(request_id_field)}, "
            f"{_quote_ident(geom_field)}"
            ") VALUES (%s, %s, %s, %s, %s, ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))"
        )
        cursor.execute(insert_query, [recap_id, None, name, owner_id, request_id, json.dumps(geometry)])
    return owner_id


def _check_recap_uniqueness(recap_id):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT 1 FROM recaps WHERE recap_id = %s LIMIT 1",
            [recap_id],
        )
        recap_exists = cursor.fetchone() is not None
    return recap_exists


def _get_reference_layer_geojson(table_name, source_label, geometry=None, distance_meters=100):
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    customer_field_pref = getattr(settings, 'GIS_OBJECT_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    department_field_pref = getattr(settings, 'GIS_OBJECT_DEPARTMENT_FIELD', 'DepartmentLegalPersonId')
    with connection.cursor() as cursor:
        geom_field = _resolve_column_name(cursor, table_name, geom_field_pref)
        rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
        name_field_pref = settings.GIS_OBJECT_NAME_FIELD
        descr_field_pref = 'descr'
        address_field_pref = 'address'
        vri_field_pref = 'vri'
        sobstv_rr_field_pref = 'sobstv_rr'
        rootid_select_expr = "NULL::text AS rootid"
        name_select_expr = "NULL::text AS name"
        descr_select_expr = "NULL::text AS descr"
        address_select_expr = "NULL::text AS address"
        vri_select_expr = "NULL::text AS vri"
        sobstv_rr_select_expr = "NULL::text AS sobstv_rr"
        rootid_prop_expr = "rootid::text"
        name_prop_expr = "name::text"
        descr_prop_expr = "descr::text"
        address_prop_expr = "address::text"
        vri_prop_expr = "vri::text"
        sobstv_rr_prop_expr = "sobstv_rr::text"
        customer_select_expr = "NULL::text AS customer_legal_person_id"
        department_select_expr = "NULL::text AS department_legal_person_id"
        customer_name_select_expr = "NULL::text AS customer_legal_person_name"
        department_name_select_expr = "NULL::text AS department_legal_person_name"
        customer_prop_expr = "customer_legal_person_id::text"
        department_prop_expr = "department_legal_person_id::text"
        customer_name_prop_expr = "customer_legal_person_name::text"
        department_name_prop_expr = "department_legal_person_name::text"
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
        if _column_exists(cursor, table_name, sobstv_rr_field_pref):
            sobstv_rr_field = _resolve_column_name(cursor, table_name, sobstv_rr_field_pref)
            sobstv_rr_select_expr = f"t.{_quote_ident(sobstv_rr_field)}::text AS sobstv_rr"
        if _column_exists(cursor, table_name, customer_field_pref):
            customer_field = _resolve_column_name(cursor, table_name, customer_field_pref)
            customer_select_expr = f"t.{_quote_ident(customer_field)}::text AS customer_legal_person_id"
            customer_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, table_name, department_field_pref):
            department_field = _resolve_column_name(cursor, table_name, department_field_pref)
            department_select_expr = f"t.{_quote_ident(department_field)}::text AS department_legal_person_id"
            department_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
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
                f"      'vri', {vri_prop_expr},"
                f"      'sobstv_rr', {sobstv_rr_prop_expr},"
                f"      'customer_legal_person_id', {customer_prop_expr},"
                f"      'department_legal_person_id', {department_prop_expr},"
                f"      'customer_legal_person_name', {customer_name_prop_expr},"
                f"      'department_legal_person_name', {department_name_prop_expr}"
                "   )"
                " )), '[]'::jsonb)"
                ")::text "
                f"FROM (SELECT t.{_quote_ident(geom_field)} AS {_quote_ident(geom_field)}, "
                f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}, {sobstv_rr_select_expr}, {customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
                f"FROM {_quote_ident(table_name)} t) rel"
            )
            cursor.execute(query, [source_label])
        else:
            geometry_json = geometry if isinstance(geometry, str) else json.dumps(geometry)
            query = (
                "WITH input AS ("
                " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
                "), rel AS ("
                f" SELECT t.{_quote_ident(geom_field)} AS geom, "
                f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}, {sobstv_rr_select_expr}, {customer_select_expr}, {department_select_expr}, {customer_name_select_expr}, {department_name_select_expr} "
                f"FROM {_quote_ident(table_name)} t, input i"
                " WHERE ST_DWithin("
                f"   t.{_quote_ident(geom_field)}::geography,"
                "   ST_Boundary(i.geom)::geography,"
                "   %s"
                " ) OR ST_Intersects("
                f"   t.{_quote_ident(geom_field)},"
                "   i.geom"
                " )"
                ") "
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
                f"      'vri', {vri_prop_expr},"
                f"      'sobstv_rr', {sobstv_rr_prop_expr},"
                f"      'customer_legal_person_id', {customer_prop_expr},"
                f"      'department_legal_person_id', {department_prop_expr},"
                f"      'customer_legal_person_name', {customer_name_prop_expr},"
                f"      'department_legal_person_name', {department_name_prop_expr}"
                "   )"
                " )), '[]'::jsonb)"
                ")::text FROM rel"
            )
            cursor.execute(query, [geometry_json, distance_meters, source_label])
        row = cursor.fetchone()
        return row[0] if row else None


def _get_recaps_layer_geojson(geometry=None, distance_meters=100):
    with connection.cursor() as cursor:
        name_field_pref = settings.GIS_OBJECT_NAME_FIELD
        owner_field_pref = settings.GIS_OBJECT_OWNER_FIELD
        name_select_expr = "NULL::text AS name"
        owner_select_expr = "NULL::text AS owner_legal_person_id"
        owner_name_select_expr = "NULL::text AS owner_legal_person_name"
        owner_name_prop_expr = "owner_legal_person_name::text"
        lookup_context = _get_id_names_lookup_context(cursor)
        if _column_exists(cursor, 'recaps', name_field_pref):
            name_field = _resolve_column_name(cursor, 'recaps', name_field_pref)
            name_select_expr = f"t.{_quote_ident(name_field)}::text AS name"
        if _column_exists(cursor, 'recaps', owner_field_pref):
            owner_field = _resolve_column_name(cursor, 'recaps', owner_field_pref)
            owner_select_expr = f"t.{_quote_ident(owner_field)}::text AS owner_legal_person_id"
            owner_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(owner_field)}', lookup_context)} "
                "AS owner_legal_person_name"
            )
        if geometry is None:
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
                f"FROM (SELECT t.geom, t.recap_id, t.request_id, {name_select_expr}, {owner_select_expr}, {owner_name_select_expr} FROM recaps t) rel"
            )
            cursor.execute(query)
        else:
            geometry_json = geometry if isinstance(geometry, str) else json.dumps(geometry)
            query = (
                "WITH input AS ("
                " SELECT ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326) AS geom"
                "), rel AS ("
                f" SELECT t.geom AS geom, t.recap_id AS recap_id, t.request_id AS request_id, {name_select_expr}, {owner_select_expr}, {owner_name_select_expr}"
                " FROM recaps t, input i"
                " WHERE ST_DWithin(t.geom::geography, ST_Boundary(i.geom)::geography, %s)"
                "    OR ST_Intersects(t.geom, i.geom)"
                ") "
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
            cursor.execute(query, [geometry_json, distance_meters])
        row = cursor.fetchone()
        return row[0] if row else None


def _get_reference_layers(geometry=None, distance_meters=100):
    layers = {'dgi': None, 'odh': None, 'recaps': None}
    try:
        layers['dgi'] = _get_reference_layer_geojson('dgi', 'ДГИ', geometry=geometry, distance_meters=distance_meters)
    except Exception:
        layers['dgi'] = None
    try:
        layers['odh'] = _get_reference_layer_geojson('odh', 'ОДХ', geometry=geometry, distance_meters=distance_meters)
    except Exception:
        layers['odh'] = None
    try:
        layers['recaps'] = _get_recaps_layer_geojson(geometry=geometry, distance_meters=distance_meters)
    except Exception:
        layers['recaps'] = None
    return layers


@login_required
def home(request):
    if request.method == 'POST':
        form = EntryPointForm(request.POST)
        if form.is_valid():
            rootid = form.cleaned_data.get('rootid', '')
            name = form.cleaned_data.get('name', '')
            try:
                entry_point = _find_manual_entry_point(rootid=rootid, name=name)
            except Exception:
                form.add_error(None, 'Не удалось выполнить поиск. Проверьте доступ к базе данных.')
            else:
                if entry_point:
                    request.session['entry_point'] = entry_point
                    return redirect('main')
                form.add_error(None, 'Объект не найден. Проверьте № Паспорта или Название.')
    else:
        form = EntryPointForm()

    owner_id = None
    owner_name = None
    owned_objects = []
    owned_objects_error = None
    try:
        owner_id = _get_current_user_owner_id(request.user.username)
        if owner_id is not None:
            owner_name = _get_id_name_lookup_value(owner_id)
            owned_objects = _get_owned_objects(owner_id)
            recap_counts = _get_recap_counts_by_request_ids(item['request_id'] for item in owned_objects)
            for item in owned_objects:
                request_id = (item.get('request_id') or '').strip()
                item['recap_count'] = recap_counts.get(request_id, 0)
    except Exception:
        owned_objects_error = (
            'Не удалось получить список объектов пользователя. '
            'Проверьте поле OwnerLegalPersonId в таблице users.'
        )

    return render(
        request,
        'pass_viewer/home.html',
        {
            'form': form,
            'owner_id': owner_id,
            'owner_name': owner_name,
            'owned_objects': owned_objects,
            'owned_objects_error': owned_objects_error,
        },
    )


@login_required
def main(request):
    entry_point = request.session.get('entry_point')
    if not entry_point:
        return redirect('home')

    layers = None
    query_error = None

    try:
        layers = _get_map_layers(entry_point)
    except Exception:
        query_error = (
            'Не удалось получить геометрию из PostGIS. '
            'Проверьте настройки таблицы/полей в settings.py.'
        )

    reference_layers = _get_reference_layers(
        geometry=layers['selected'] if layers else None,
        distance_meters=100,
    )

    return render(
        request,
        'pass_viewer/main.html',
        {
            'entry_point': entry_point,
            'map_layers': layers,
            'selected_geometry_json': layers['selected'] if layers else None,
            'selected_rootid': layers['selected_rootid'] if layers else None,
            'selected_name': layers['selected_name'] if layers else None,
            'selected_request_id': layers['selected_request_id'] if layers else None,
            'selected_customer_legal_person_id': layers['selected_customer_legal_person_id'] if layers else None,
            'selected_department_legal_person_id': layers['selected_department_legal_person_id'] if layers else None,
            'selected_customer_legal_person_name': layers['selected_customer_legal_person_name'] if layers else None,
            'selected_department_legal_person_name': layers['selected_department_legal_person_name'] if layers else None,
            'selected_source_label': layers['selected_source_label'] if layers else _normalize_source_label(entry_point.get('source_label')),
            'intersects_geometry_json': layers['intersects'] if layers else None,
            'touches_geometry_json': layers['touches'] if layers else None,
            'nearby_geometry_json': layers['nearby'] if layers else None,
            'request_objects_geometry_json': layers['request_objects'] if layers else None,
            'dgi_geometry_json': reference_layers['dgi'],
            'odh_geometry_json': reference_layers['odh'],
            'recaps_geometry_json': reference_layers['recaps'],
            'query_error': query_error,
        },
    )


@login_required
@require_POST
def export_geometry(request):
    entry_point = request.session.get('entry_point')
    if not entry_point:
        return JsonResponse({'ok': False, 'error': 'Сначала выберите объект.'}, status=400)

    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    try:
        geojson_url, shapefile_url = _export_geometry_files(geometry)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Ошибка формирования файлов экспорта.'},
            status=500,
        )

    return JsonResponse({'ok': True, 'geojson_url': geojson_url, 'shapefile_url': shapefile_url})


@login_required
@require_POST
def export_new_object_geometry(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)
    properties = payload.get('properties') or {}
    if not isinstance(properties, dict):
        properties = {}

    try:
        geojson_url, shapefile_url = _export_geometry_files(geometry, properties=properties)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Ошибка формирования файлов экспорта.'},
            status=500,
        )

    return JsonResponse({'ok': True, 'geojson_url': geojson_url, 'shapefile_url': shapefile_url})


@login_required
@require_POST
def save_new_object(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    name = (payload.get('name') or '').strip()
    request_id = (payload.get('request_id') or '').strip()
    source_label = _normalize_source_label(payload.get('source_label'))
    if not request_id:
        return JsonResponse({'ok': False, 'error': 'Укажите номер заявки (request_id).'}, status=400)
    if not request_id.isdigit():
        return JsonResponse({'ok': False, 'error': 'Номер заявки (request_id) должен содержать только цифры.'}, status=400)

    try:
        owner_id = _create_new_object(
            username=request.user.username,
            geometry=geometry,
            name=name,
            request_id=request_id,
            source_label=source_label,
        )
    except ValueError as exc:
        return JsonResponse({'ok': False, 'error': str(exc)}, status=400)
    except Exception:
        return JsonResponse({'ok': False, 'error': 'Не удалось сохранить объект в geodb.'}, status=500)

    return JsonResponse({'ok': True, 'owner_id': owner_id})


@login_required
@require_POST
def save_recap_object(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    name = (payload.get('name') or '').strip()
    request_id = (payload.get('request_id') or '').strip()
    recap_id = (payload.get('recap_id') or '').strip()

    if not recap_id:
        return JsonResponse({'ok': False, 'error': 'Укажите номер досьё (recap_id).'}, status=400)
    if not recap_id.isdigit():
        return JsonResponse({'ok': False, 'error': 'Номер досьё (recap_id) должен содержать только цифры.'}, status=400)
    if not request_id:
        return JsonResponse({'ok': False, 'error': 'Укажите номер заявки (request_id).'}, status=400)
    if not request_id.isdigit():
        return JsonResponse({'ok': False, 'error': 'Номер заявки (request_id) должен содержать только цифры.'}, status=400)

    recap_exists = _check_recap_uniqueness(recap_id=recap_id)
    if recap_exists:
        return JsonResponse({'ok': False, 'error': 'Номер досьё (recap_id) уже существует.'}, status=400)

    try:
        owner_id = _create_recap_object(
            username=request.user.username,
            geometry=geometry,
            name=name,
            request_id=request_id,
            recap_id=recap_id,
        )
    except ValueError as exc:
        return JsonResponse({'ok': False, 'error': str(exc)}, status=400)
    except Exception:
        return JsonResponse({'ok': False, 'error': 'Не удалось сохранить досьё в recaps.'}, status=500)

    return JsonResponse({'ok': True, 'owner_id': owner_id, 'recap_id': recap_id})


@login_required
@require_POST
def open_owned_object(request):
    rootid = (request.POST.get('rootid') or '').strip()
    name = (request.POST.get('name') or '').strip()
    request_id = (request.POST.get('request_id') or '').strip()
    if rootid.lower() in {'none', 'null'}:
        rootid = ''
    if not rootid and not name and not request_id:
        return redirect('home')

    request.session['entry_point'] = {
        'rootid': rootid,
        'request_id': request_id if not rootid else '',
        'name': '' if rootid else name,
        'source_label': _normalize_source_label(request.POST.get('source_label')),
    }
    return redirect('main')


@login_required
@require_POST
def delete_owned_object(request):
    object_key = (request.POST.get('object_key') or '').strip()
    source_label = _normalize_source_label(request.POST.get('source_label'))
    if not object_key:
        return redirect('home')

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return redirect('home')

    table = _get_source_table(source_label)
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    owner_field_pref = (
        getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
        if source_label == 'ОДХ'
        else getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    )
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_exists = _column_exists(cursor, table, request_id_field_pref)
        where_parts = [
            "ctid = %s::tid",
            f"{_quote_ident(owner_field)} = %s",
        ]
        params = [object_key, owner_id]
        target_request_id = None

        # Keep old protection for DT request objects, but allow ODH objects with rootid.
        if source_label != 'ОДХ':
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
            target_request_id = (request_id_row[0] or '').strip() if request_id_row else None

        delete_query = (
            f"DELETE FROM {_quote_ident(table)} "
            f"WHERE {' AND '.join(where_parts)}"
        )
        cursor.execute(delete_query, params)

        if target_request_id and _column_exists(cursor, 'recaps', request_id_field_pref):
            recaps_request_id_field = _resolve_column_name(cursor, 'recaps', request_id_field_pref)
            cursor.execute(
                f"DELETE FROM recaps WHERE {_quote_ident(recaps_request_id_field)}::text = %s",
                [target_request_id],
            )

    return redirect('home')


@login_required
def add_object(request):
    entry_point = request.session.get('entry_point') or {}
    return render(
        request,
        'pass_viewer/add_object.html',
        {
            'dgi_geometry_json': None,
            'odh_geometry_json': None,
            'recaps_geometry_json': None,
            'request_objects_geometry_json': None,
            'selected_source_label': _normalize_source_label(entry_point.get('source_label')),
        },
    )


@login_required
def add_recap(request):
    request_id = (request.GET.get('request_id') or '').strip()
    name = (request.GET.get('name') or '').strip()
    object_key = (request.GET.get('object_key') or '').strip()
    source_label = _normalize_source_label(request.GET.get('source_label'))
    owner_id = _get_current_user_owner_id(request.user.username)
    selected_object = _get_owned_request_object(owner_id, object_key, source_label=source_label)
    if not selected_object:
        return redirect('home')

    selected_geometry = None
    try:
        selected_geometry = json.loads(selected_object['geometry_json'])
    except (TypeError, json.JSONDecodeError):
        selected_geometry = None

    reference_layers = _get_reference_layers(
        geometry=selected_object['geometry_json'],
        distance_meters=100,
    )
    initial_relations = {'intersects': None, 'touches': None, 'nearby': None, 'request_objects': None}
    if selected_geometry:
        try:
            initial_relations = _get_new_object_relations(
                selected_geometry,
                source_label=selected_object.get('source_label') or source_label,
            )
        except Exception:
            initial_relations = {'intersects': None, 'touches': None, 'nearby': None, 'request_objects': None}

    return render(
        request,
        'pass_viewer/add_recap.html',
        {
            'request_id': selected_object['request_id'] or request_id,
            'name': selected_object['name'] or name,
            'object_key': selected_object['object_key'] or object_key,
            'selected_source_label': selected_object.get('source_label') or source_label,
            'selected_geometry_json': selected_object['geometry_json'],
            'intersects_geometry_json': initial_relations.get('intersects'),
            'touches_geometry_json': initial_relations.get('touches'),
            'nearby_geometry_json': initial_relations.get('nearby'),
            'request_objects_geometry_json': initial_relations.get('request_objects'),
            'dgi_geometry_json': reference_layers['dgi'],
            'odh_geometry_json': reference_layers['odh'],
            'recaps_geometry_json': reference_layers['recaps'],
        },
    )


@login_required
@require_POST
def check_new_object_relations(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)
    source_label = _normalize_source_label(payload.get('source_label'))

    try:
        layers = _get_new_object_relations(geometry, source_label=source_label)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Не удалось получить связанные объекты из PostGIS.'},
            status=500,
        )

    return JsonResponse({'ok': True, 'layers': layers})


@login_required
@require_POST
def check_dgi_intersections(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = payload.get('geometry')
    if not isinstance(geometry, dict):
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    try:
        percent = _get_dgi_intersection_percent(geometry)
    except Exception:
        return JsonResponse(
            {'ok': False, 'error': 'Не удалось вычислить пересечение с объектами ДГИ.'},
            status=500,
        )

    percent_rounded = round(percent, 2)
    return JsonResponse(
        {
            'ok': True,
            'intersects': percent_rounded > 0,
            'percent': percent_rounded,
        }
    )

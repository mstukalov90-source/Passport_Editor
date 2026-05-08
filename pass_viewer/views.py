import json
import logging
import re
import uuid
import zipfile
from pathlib import Path

from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.db import connection
from django.views.decorators.http import require_GET, require_POST
from osgeo import gdal, ogr, osr

from .forms import EntryPointForm
from .models import ExternalUser

logger = logging.getLogger(__name__)

gdal.UseExceptions()


def _sql_geojson_param_as_valid_geom2d(placeholder: str = '%s') -> str:
    """
    GeoJSON text (%s) → валидная 2D-геометрия для предикатов PostGIS/GEOS.
    Иначе при самопересечениях / «бантиках» после редактирования возможен
    TopologyException: side location conflict в ST_Intersects и т.п.
    """
    return (
        f'ST_UnaryUnion(ST_MakeValid(ST_SetSRID(ST_GeomFromGeoJSON({placeholder}), 4326)))'
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


def _comment_points_table_name():
    return getattr(settings, 'GIS_COMMENT_POINTS_TABLE', 'pass_comment_points')


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
    odh_table = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    ozn_table = getattr(settings, 'GIS_OZN_TABLE', 'ozn')
    rootid_field = settings.GIS_OBJECT_ROOTID_FIELD
    name_field = settings.GIS_OBJECT_NAME_FIELD
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    odh_customer_field_pref = getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    ozn_owner_field_pref = getattr(settings, 'GIS_OZN_OWNER_FIELD', 'ownerlegalpersonalid')
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')
    tables_to_query = [primary_table, odh_table, ozn_table]

    owned_items = []
    seen_keys = set()
    seen_tables = set()
    with connection.cursor() as cursor:
        for table in tables_to_query:
            if table in seen_tables:
                continue
            seen_tables.add(table)
            table_norm = table.lower()
            odh_table_norm = odh_table.lower()
            ozn_table_norm = ozn_table.lower()
            if table_norm == odh_table_norm:
                source_label = 'ОДХ'
            elif table_norm == ozn_table_norm:
                source_label = 'ОЗН'
            else:
                source_label = 'ДТ'
            owner_field_candidates = (
                [odh_customer_field_pref, owner_field_pref]
                if table_norm == odh_table_norm
                else [ozn_owner_field_pref, owner_field_pref]
                if table_norm == ozn_table_norm
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
            geom_expr = "NULL::text AS geom_json"
            try:
                geom_field = _resolve_column_name(cursor, table, settings.GIS_OBJECT_GEOM_FIELD)
            except Exception:
                geom_field = None
            if geom_field:
                geom_expr = f"ST_AsGeoJSON(ST_Force2D({_quote_ident(geom_field)}))::text AS geom_json"

            query = (
                f"SELECT ctid::text, {_quote_ident(rootid_field)}::text, {_quote_ident(name_field)}::text, "
                f"{request_id_expr}, {geom_expr} "
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
                    'geom_json': row[4] or '',
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


def _build_owned_passports_geojson(owned_objects):
    features = []
    for item in owned_objects:
        rootid = (item.get('rootid') or '').strip()
        request_id = (item.get('request_id') or '').strip()
        geom_json = item.get('geom_json') or ''
        if not geom_json:
            continue
        try:
            geometry = json.loads(geom_json)
        except Exception:
            continue
        if not geometry:
            continue
        features.append(
            {
                'type': 'Feature',
                'geometry': geometry,
                'properties': {
                    'rootid': rootid,
                    'name': item.get('name') or '',
                    'source_label': item.get('source_label') or 'ДТ',
                    'request_id': request_id,
                    'is_request_object': bool(request_id and not rootid),
                },
            }
        )
    return {'type': 'FeatureCollection', 'features': features}


def _normalize_source_label(value):
    source = str(value or '').strip().upper()
    if source == 'ОДХ':
        return 'ОДХ'
    if source in {'ОЗН', 'ОО'}:
        return 'ОЗН'
    return 'ДТ'


def _get_source_table(source_label):
    normalized_source = _normalize_source_label(source_label)
    if normalized_source == 'ОДХ':
        return getattr(settings, 'GIS_ODH_TABLE', 'odh')
    if normalized_source == 'ОЗН':
        return getattr(settings, 'GIS_OZN_TABLE', 'ozn')
    return settings.GIS_OBJECT_TABLE


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
        else getattr(settings, 'GIS_OZN_OWNER_FIELD', 'ownerlegalpersonalid')
        if normalized_source == 'ОЗН'
        else getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    )
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    with connection.cursor() as cursor:
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
    ozn_table = getattr(settings, 'GIS_OZN_TABLE', 'ozn')
    rootid_field_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_field_pref = settings.GIS_OBJECT_NAME_FIELD
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    seen_tables = set()
    with connection.cursor() as cursor:
        for table in [primary_table, odh_table, ozn_table]:
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
            if table.lower() == odh_table.lower():
                source_label = 'ОДХ'
            elif table.lower() == ozn_table.lower():
                source_label = 'ОЗН'
            else:
                source_label = 'ДТ'
            return {
                'rootid': found_rootid,
                'name': found_name,
                'request_id': found_request_id,
                'source_label': source_label,
            }
    return None


def _normalize_merge_items(entry_point):
    """Список словарей {rootid, source_label} для объединения паспортов (≥2)."""
    raw = entry_point.get('merge_items')
    out = []
    if isinstance(raw, list):
        for x in raw:
            if isinstance(x, dict):
                rid = (x.get('rootid') or '').strip()
                if rid:
                    out.append(
                        {
                            'rootid': rid,
                            'source_label': _normalize_source_label(x.get('source_label')),
                        }
                    )
    if len(out) >= 2:
        return out
    rootids_raw = entry_point.get('merge_rootids')
    if isinstance(rootids_raw, (list, tuple)) and len(rootids_raw) >= 2:
        sl = _normalize_source_label(entry_point.get('source_label'))
        return [{'rootid': str(r).strip(), 'source_label': sl} for r in rootids_raw if str(r).strip()]
    return []


def _merge_group_ids_by_source(merge_items):
    res = {'ДТ': [], 'ОДХ': [], 'ОЗН': []}
    for it in merge_items or []:
        rid = (it.get('rootid') or '').strip()
        if not rid:
            continue
        sl = _normalize_source_label(it.get('source_label'))
        if sl == 'ОДХ':
            res['ОДХ'].append(rid)
        elif sl == 'ОЗН':
            res['ОЗН'].append(rid)
        else:
            res['ДТ'].append(rid)
    return res


def _build_merge_matched_body_sql(cursor, merge_items):
    """
    SQL-тело для CTE matched: UNION ALL выборок из таблиц ДТ/ОДХ/ОЗН.
    Возвращает (sql_fragment, list_of_params) или (None, None).
    """
    by = _merge_group_ids_by_source(merge_items)
    dt_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    ozn_table = getattr(settings, 'GIS_OZN_TABLE', 'ozn')
    rootid_pref = settings.GIS_OBJECT_ROOTID_FIELD
    name_pref = settings.GIS_OBJECT_NAME_FIELD
    geom_pref = settings.GIS_OBJECT_GEOM_FIELD
    req_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')

    parts = []
    params = []
    for ids, tbl in ((by['ДТ'], dt_table), (by['ОДХ'], odh_table), (by['ОЗН'], ozn_table)):
        if not ids:
            continue
        if not _column_exists(cursor, tbl, rootid_pref) or not _column_exists(cursor, tbl, geom_pref):
            continue
        rf = _resolve_column_name(cursor, tbl, rootid_pref)
        nf = _resolve_column_name(cursor, tbl, name_pref)
        gf = _resolve_column_name(cursor, tbl, geom_pref)
        if _column_exists(cursor, tbl, req_pref):
            rqf = _resolve_column_name(cursor, tbl, req_pref)
            rq_expr = f'{_quote_ident(rqf)}::text AS request_id'
        else:
            rq_expr = 'NULL::text AS request_id'
        parts.append(
            f'SELECT ctid, {_quote_ident(rf)}::text AS rootid, COALESCE({_quote_ident(nf)}::text, \'\') AS name, '
            f'{rq_expr}, NULL::text AS customer_legal_person_id, NULL::text AS department_legal_person_id, '
            f'NULL::text AS customer_legal_person_name, NULL::text AS department_legal_person_name, '
            f'{_quote_ident(gf)} AS geom FROM {_quote_ident(tbl)} WHERE {_quote_ident(rf)}::text = ANY(%s)'
        )
        params.append(ids)
    if not parts:
        return None, None
    return ' UNION ALL '.join(parts), params


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
    request_customer_dt_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_dt_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_dt_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_dt_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_odh_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_odh_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_odh_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_odh_name_select_expr = "NULL::text AS department_legal_person_name"
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
            adjacent_department_select_expr = f"t.{_quote_ident(dt_department_field)}::text AS department_legal_person_id"
            adjacent_department_prop_expr = "department_legal_person_id::text"
            adjacent_department_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(dt_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )
            adjacent_department_name_prop_expr = "department_legal_person_name::text"
            request_department_dt_select_expr = f"t.{_quote_ident(dt_department_field)}::text AS department_legal_person_id"
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
            request_department_odh_select_expr = f"t.{_quote_ident(odh_department_field)}::text AS department_legal_person_id"
            request_department_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_department_field)}', lookup_context)} "
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
            "WITH matched AS ("
            + merge_matched_body
            + "), selected AS ("
            " SELECT (SELECT ctid FROM matched ORDER BY rootid NULLS LAST LIMIT 1) AS ctid, "
            " (SELECT string_agg(rootid::text, ', ' ORDER BY rootid) FROM matched) AS rootid, "
            " (SELECT string_agg(name::text, ' + ' ORDER BY name NULLS LAST) FROM matched) AS name, "
            " NULL::text AS request_id, "
            " (SELECT customer_legal_person_id FROM matched ORDER BY ctid LIMIT 1) AS customer_legal_person_id, "
            " (SELECT department_legal_person_id FROM matched ORDER BY ctid LIMIT 1) AS department_legal_person_id, "
            " (SELECT customer_legal_person_name FROM matched ORDER BY ctid LIMIT 1) AS customer_legal_person_name, "
            " (SELECT department_legal_person_name FROM matched ORDER BY ctid LIMIT 1) AS department_legal_person_name, "
            " (SELECT ST_UnaryUnion(ST_Collect(geom)) FROM matched) AS geom "
            ") "
            "SELECT ST_AsGeoJSON(geom), ctid::text, rootid::text, name::text, request_id::text, "
            "customer_legal_person_id::text, department_legal_person_id::text, "
            "customer_legal_person_name::text, department_legal_person_name::text "
            "FROM selected"
        )
        map_layers_cte_open = (
            "WITH matched AS ("
            + merge_matched_body
            + "), selected AS ( SELECT (SELECT ctid FROM matched ORDER BY rootid NULLS LAST LIMIT 1) AS ctid, "
            " (SELECT ST_UnaryUnion(ST_Collect(geom)) FROM matched) AS geom ), "
        )
        neighbor_excl = "t.ctid NOT IN (SELECT ctid FROM matched) AND "
        req_self_excl = "AND NOT (%s = %s AND t.ctid IN (SELECT ctid FROM matched))"
    else:
        selected_sql = (
            "WITH selected AS ("
            f" SELECT ctid, {rootid_field} AS rootid, {name_field} AS name, {request_id_field} AS request_id, "
            f"{customer_select_expr}, {department_select_expr}, {customer_name_select_expr_selected}, {department_name_select_expr_selected}, {geom_field} AS geom FROM {table}"
            f" WHERE {where_clause} LIMIT 1"
            ") "
            "SELECT ST_AsGeoJSON(geom), ctid::text, rootid::text, name::text, request_id::text, "
            "customer_legal_person_id::text, department_legal_person_id::text, "
            "customer_legal_person_name::text, department_legal_person_name::text "
            "FROM selected"
        )
        map_layers_cte_open = (
            "WITH selected AS ("
            f" SELECT ctid, {geom_field} AS geom FROM {table}"
            f" WHERE {where_clause} LIMIT 1"
            "), "
        )
        neighbor_excl = "t.ctid <> s.ctid AND "
        req_self_excl = "AND NOT (%s = %s AND t.ctid = s.ctid)"

    intersects_sql = (
        map_layers_cte_open
        + "rel AS ("
        f" SELECT t.{_quote_ident(adjacent_geom_field)} AS geom, t.{_quote_ident(adjacent_rootid_field)} AS rootid, t.{_quote_ident(adjacent_name_field)} AS name, t.{_quote_ident(adjacent_request_id_field)} AS request_id, "
        f"{adjacent_customer_select_expr}, {adjacent_department_select_expr}, {adjacent_owner_select_expr}, {adjacent_customer_name_select_expr}, {adjacent_department_name_select_expr}, {adjacent_owner_name_select_expr} "
        f"FROM {_quote_ident(dt_table)} t, selected s"
        f" WHERE {neighbor_excl}ST_Intersects("
        f"   t.{_quote_ident(adjacent_geom_field)},"
        "   s.geom"
        " ) AND NOT ST_Touches("
        f"   t.{_quote_ident(adjacent_geom_field)},"
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
        f"      'customer_legal_person_id', {adjacent_customer_prop_expr},"
        f"      'department_legal_person_id', {adjacent_department_prop_expr},"
        f"      'owner_legal_person_id', {adjacent_owner_prop_expr},"
        f"      'customer_legal_person_name', {adjacent_customer_name_prop_expr},"
        f"      'department_legal_person_name', {adjacent_department_name_prop_expr},"
        f"      'owner_legal_person_name', {adjacent_owner_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    touches_sql = (
        map_layers_cte_open
        + "neighbors AS ("
        f" SELECT t.{_quote_ident(adjacent_geom_field)} AS geom, t.{_quote_ident(adjacent_rootid_field)} AS rootid, t.{_quote_ident(adjacent_name_field)} AS name, t.{_quote_ident(adjacent_request_id_field)} AS request_id, "
        f"{adjacent_customer_select_expr}, {adjacent_department_select_expr}, {adjacent_owner_select_expr}, {adjacent_customer_name_select_expr}, {adjacent_department_name_select_expr}, {adjacent_owner_name_select_expr} "
        f"FROM {_quote_ident(dt_table)} t, selected s"
        f" WHERE {neighbor_excl}ST_Touches("
        f"   t.{_quote_ident(adjacent_geom_field)},"
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
        f"      'customer_legal_person_id', {adjacent_customer_prop_expr},"
        f"      'department_legal_person_id', {adjacent_department_prop_expr},"
        f"      'owner_legal_person_id', {adjacent_owner_prop_expr},"
        f"      'customer_legal_person_name', {adjacent_customer_name_prop_expr},"
        f"      'department_legal_person_name', {adjacent_department_name_prop_expr},"
        f"      'owner_legal_person_name', {adjacent_owner_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM neighbors"
    )
    nearby_sql = (
        map_layers_cte_open
        + "nearby AS ("
        f" SELECT t.{_quote_ident(adjacent_geom_field)} AS geom, t.{_quote_ident(adjacent_rootid_field)} AS rootid, t.{_quote_ident(adjacent_name_field)} AS name, t.{_quote_ident(adjacent_request_id_field)} AS request_id, "
        f"{adjacent_customer_select_expr}, {adjacent_department_select_expr}, {adjacent_owner_select_expr}, {adjacent_customer_name_select_expr}, {adjacent_department_name_select_expr}, {adjacent_owner_name_select_expr} "
        f"FROM {_quote_ident(dt_table)} t, selected s"
        f" WHERE {neighbor_excl}t.{_quote_ident(adjacent_geom_field)} && ST_Envelope(ST_Buffer(s.geom::geography, 100)::geometry)"
        "   AND ST_DWithin("
        f"   t.{_quote_ident(adjacent_geom_field)}::geography,"
        "   s.geom::geography, 100"
        " ) AND NOT ST_Touches("
        f"   t.{_quote_ident(adjacent_geom_field)},"
        "   s.geom"
        " ) AND NOT ST_Intersects("
        f"   t.{_quote_ident(adjacent_geom_field)},"
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
        f"      'customer_legal_person_id', {adjacent_customer_prop_expr},"
        f"      'department_legal_person_id', {adjacent_department_prop_expr},"
        f"      'owner_legal_person_id', {adjacent_owner_prop_expr},"
        f"      'customer_legal_person_name', {adjacent_customer_name_prop_expr},"
        f"      'department_legal_person_name', {adjacent_department_name_prop_expr},"
        f"      'owner_legal_person_name', {adjacent_owner_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM nearby"
    )
    requests_sql = (
        map_layers_cte_open
        + "ix AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}, {request_customer_dt_select_expr}, {request_department_dt_select_expr}, {request_customer_dt_name_select_expr}, {request_department_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
        " WHERE ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   {req_self_excl}"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}, {request_customer_odh_select_expr}, {request_department_odh_select_expr}, {request_customer_odh_name_select_expr}, {request_department_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, selected s"
        " WHERE ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   {req_self_excl}"
        "), tg AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}, {request_customer_dt_select_expr}, {request_department_dt_select_expr}, {request_customer_dt_name_select_expr}, {request_department_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
        " WHERE ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   {req_self_excl}"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}, {request_customer_odh_select_expr}, {request_department_odh_select_expr}, {request_customer_odh_name_select_expr}, {request_department_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, selected s"
        " WHERE ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   {req_self_excl}"
        "), nr AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}, {request_customer_dt_select_expr}, {request_department_dt_select_expr}, {request_customer_dt_name_select_expr}, {request_department_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, selected s"
        " WHERE t.{geom_field} && ST_Envelope(ST_Buffer(s.geom::geography, 10)::geometry)".replace("{geom_field}", geom_field) +
        "   AND ST_DWithin(t.{geom_field}::geography, s.geom::geography, 10)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   {req_self_excl}"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}, {request_customer_odh_select_expr}, {request_department_odh_select_expr}, {request_customer_odh_name_select_expr}, {request_department_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, selected s"
        " WHERE t.{geom_field} && ST_Envelope(ST_Buffer(s.geom::geography, 10)::geometry)".replace("{geom_field}", geom_field) +
        "   AND ST_DWithin(t.{geom_field}::geography, s.geom::geography, 10)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Touches(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        "   AND NOT ST_Intersects(t.{geom_field}, s.geom)".replace("{geom_field}", geom_field) +
        f"   AND t.{request_id_field} IS NOT NULL"
        f"   {req_self_excl}"
        "), rel AS ("
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name, customer_legal_person_id, department_legal_person_id, customer_legal_person_name, department_legal_person_name FROM ix"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name, customer_legal_person_id, department_legal_person_id, customer_legal_person_name, department_legal_person_name FROM tg"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name, customer_legal_person_id, department_legal_person_id, customer_legal_person_name, department_legal_person_name FROM nr"
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
        "      'customer_legal_person_id', customer_legal_person_id::text,"
        "      'department_legal_person_id', department_legal_person_id::text,"
        "      'customer_legal_person_name', customer_legal_person_name::text,"
        "      'department_legal_person_name', department_legal_person_name::text"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )

    with connection.cursor() as cursor:
        cursor.execute(selected_sql, where_params)
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
        'selected_ctid': selected_ctid,
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
        'recap_id': (properties.get('recap_id') or ''),
    }

    export_root = Path(settings.MEDIA_ROOT) / 'exports'
    export_root.mkdir(parents=True, exist_ok=True)
    export_id = uuid.uuid4().hex
    export_dir = export_root / export_id
    export_dir.mkdir(parents=True, exist_ok=True)

    request_id_raw = str(export_properties.get('request_id') or '').strip()
    recap_id_raw = str(export_properties.get('recap_id') or '').strip()
    name_raw = str(export_properties.get('name') or '').strip()
    request_id_safe = re.sub(r'[^\w.-]+', '_', request_id_raw, flags=re.UNICODE).strip('._-')
    recap_id_safe = re.sub(r'[^\w.-]+', '_', recap_id_raw, flags=re.UNICODE).strip('._-')
    name_safe = re.sub(r'[^\w.-]+', '_', name_raw, flags=re.UNICODE).strip('._-')
    if not request_id_safe:
        request_id_safe = 'request'
    if not name_safe:
        name_safe = 'object'
    request_id_safe = request_id_safe[:80]
    recap_id_safe = recap_id_safe[:80]
    name_safe = name_safe[:120]
    if recap_id_safe:
        base_filename = f"{request_id_safe}_{recap_id_safe}_{name_safe}"
    else:
        base_filename = f"{request_id_safe}_{name_safe}"

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


def _get_new_object_relations(geometry, source_label='ДТ', request_id_filter=None):
    geometry_norm = _to_intersection_geometry(geometry)
    if not geometry_norm:
        raise ValueError('Unsupported geometry payload for relation checks.')
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
    request_customer_dt_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_dt_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_dt_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_dt_name_select_expr = "NULL::text AS department_legal_person_name"
    request_customer_odh_select_expr = "NULL::text AS customer_legal_person_id"
    request_department_odh_select_expr = "NULL::text AS department_legal_person_id"
    request_customer_odh_name_select_expr = "NULL::text AS customer_legal_person_name"
    request_department_odh_name_select_expr = "NULL::text AS department_legal_person_name"
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
            request_department_dt_select_expr = f"t.{_quote_ident(department_field)}::text AS department_legal_person_id"
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
        if _column_exists(cursor, odh_table, customer_field_pref):
            odh_customer_field = _resolve_column_name(cursor, odh_table, customer_field_pref)
            request_customer_odh_select_expr = f"t.{_quote_ident(odh_customer_field)}::text AS customer_legal_person_id"
            request_customer_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_customer_field)}', lookup_context)} "
                "AS customer_legal_person_name"
            )
        if _column_exists(cursor, odh_table, department_field_pref):
            odh_department_field = _resolve_column_name(cursor, odh_table, department_field_pref)
            request_department_odh_select_expr = f"t.{_quote_ident(odh_department_field)}::text AS department_legal_person_id"
            request_department_odh_name_select_expr = (
                f"{_build_id_name_lookup_expr(f't.{_quote_ident(odh_department_field)}', lookup_context)} "
                "AS department_legal_person_name"
            )

    intersects_sql = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr} "
        f"FROM {_quote_ident(dt_table)} t, input i"
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
        f"      'owner_legal_person_id', {owner_prop_expr},"
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr},"
        f"      'owner_legal_person_name', {owner_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    touches_sql = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr} "
        f"FROM {_quote_ident(dt_table)} t, input i"
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
        f"      'owner_legal_person_id', {owner_prop_expr},"
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr},"
        f"      'owner_legal_person_name', {owner_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    nearby_sql = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), rel AS ("
        f" SELECT t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, "
        f"{customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr} "
        f"FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE t.{geom_field} && ST_Envelope(ST_Buffer(i.geom::geography, 100)::geometry)"
        f"   AND ST_DWithin(t.{geom_field}::geography, i.geom::geography, 100)"
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
        f"      'owner_legal_person_id', {owner_prop_expr},"
        f"      'customer_legal_person_name', {customer_name_prop_expr},"
        f"      'department_legal_person_name', {department_name_prop_expr},"
        f"      'owner_legal_person_name', {owner_name_prop_expr}"
        "   )"
        " )), '[]'::jsonb)"
        ")::text FROM rel"
    )
    request_objects_sql = (
        "WITH input AS ("
        f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
        "), input_parts AS ("
        " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
        "), ix AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}, {request_customer_dt_select_expr}, {request_department_dt_select_expr}, {request_customer_dt_name_select_expr}, {request_department_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}, {request_customer_odh_select_expr}, {request_department_odh_select_expr}, {request_customer_odh_name_select_expr}, {request_department_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, input i"
        f" WHERE ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        "), tg AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}, {request_customer_dt_select_expr}, {request_department_dt_select_expr}, {request_customer_dt_name_select_expr}, {request_department_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE ST_Touches(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}, {request_customer_odh_select_expr}, {request_department_odh_select_expr}, {request_customer_odh_name_select_expr}, {request_department_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, input i"
        f" WHERE ST_Touches(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        "), nr AS ("
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_dt_select_expr}, {request_owner_dt_name_select_expr}, {request_customer_dt_select_expr}, {request_department_dt_select_expr}, {request_customer_dt_name_select_expr}, {request_department_dt_name_select_expr}"
        f" FROM {_quote_ident(dt_table)} t, input i"
        f" WHERE t.{geom_field} && ST_Envelope(ST_Buffer(i.geom::geography, 10)::geometry)"
        f"   AND ST_DWithin(t.{geom_field}::geography, i.geom::geography, 10)"
        f"   AND NOT ST_Touches(t.{geom_field}, i.geom)"
        f"   AND NOT ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        " UNION ALL "
        f" SELECT t.ctid::text AS row_tid, t.{geom_field} AS geom, t.{rootid_field} AS rootid, t.{name_field} AS name, t.{request_id_field} AS request_id, {request_owner_odh_select_expr}, {request_owner_odh_name_select_expr}, {request_customer_odh_select_expr}, {request_department_odh_select_expr}, {request_customer_odh_name_select_expr}, {request_department_odh_name_select_expr}"
        f" FROM {_quote_ident(odh_table)} t, input i"
        f" WHERE t.{geom_field} && ST_Envelope(ST_Buffer(i.geom::geography, 10)::geometry)"
        f"   AND ST_DWithin(t.{geom_field}::geography, i.geom::geography, 10)"
        f"   AND NOT ST_Touches(t.{geom_field}, i.geom)"
        f"   AND NOT ST_Intersects(t.{geom_field}, i.geom)"
        "   AND NOT EXISTS ("
        "       SELECT 1 FROM input_parts p"
        f"       WHERE ST_Equals(t.{geom_field}, p.geom)"
        "   )"
        f"   AND t.{request_id_field} IS NOT NULL"
        "), rel AS ("
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name, customer_legal_person_id, department_legal_person_id, customer_legal_person_name, department_legal_person_name FROM ix"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name, customer_legal_person_id, department_legal_person_id, customer_legal_person_name, department_legal_person_name FROM tg"
        " UNION"
        " SELECT row_tid, geom, rootid, name, request_id, owner_legal_person_id, owner_legal_person_name, customer_legal_person_id, department_legal_person_id, customer_legal_person_name, department_legal_person_name FROM nr"
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
        "      'customer_legal_person_id', customer_legal_person_id::text,"
        "      'department_legal_person_id', department_legal_person_id::text,"
        "      'customer_legal_person_name', customer_legal_person_name::text,"
        "      'department_legal_person_name', department_legal_person_name::text"
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
    ref_layers = _get_reference_layers(
        geometry=geometry_norm,
        distance_meters=100,
        request_id_filter=request_id_filter,
    )

    dgi_intersects = None
    odh_intersects = None
    dgi_table_name = getattr(settings, 'GIS_DGI_TABLE', 'dgi')
    odh_table_name = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    try:
        with connection.cursor() as cursor:
            dgi_table_ok = _table_exists(cursor, dgi_table_name)
        if dgi_table_ok:
            dgi_intersects = _get_reference_layer_geojson(
                dgi_table_name, 'ДГИ', geometry=geometry_norm, intersects_only=True
            )
    except Exception:
        logger.exception('_get_new_object_relations: dgi_intersects failed')
        dgi_intersects = None
    try:
        with connection.cursor() as cursor:
            odh_table_ok = _table_exists(cursor, odh_table_name)
        if odh_table_ok:
            odh_intersects = _get_reference_layer_geojson(
                odh_table_name, 'ОДХ', geometry=geometry_norm, intersects_only=True
            )
    except Exception:
        logger.exception('_get_new_object_relations: odh_intersects failed')
        odh_intersects = None

    return {
        'intersects': intersects_row[0] if intersects_row else None,
        'touches': touches_row[0] if touches_row else None,
        'nearby': nearby_row[0] if nearby_row else None,
        'request_objects': request_objects_row[0] if request_objects_row else None,
        'dgi': ref_layers['dgi'],
        'odh': ref_layers['odh'],
        'ozn': ref_layers['ozn'],
        'renew': ref_layers['renew'],
        'recaps': ref_layers['recaps'],
        'dgi_intersects': dgi_intersects,
        'odh_intersects': odh_intersects,
    }


def _get_dgi_intersection_percent(geometry):
    dgi_table = getattr(settings, 'GIS_DGI_TABLE', 'dgi')
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    geometry_json = json.dumps(geometry)
    with connection.cursor() as cursor:
        geom_field = _resolve_column_name(cursor, dgi_table, geom_field_pref)
        query = (
            "WITH input AS ("
            f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
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


def _remove_intersections_from_geometry(
    geometry,
    selected_sources,
    source_label='ДТ',
    selected_geometry=None,
    selected_rootid='',
    selected_request_id='',
):
    geometry_norm = _to_intersection_geometry(geometry)
    if not geometry_norm:
        return None

    source_tokens = {str(value).strip().lower() for value in (selected_sources or []) if str(value).strip()}
    allowed_tokens = {'dt', 'odh', 'ozn', 'dgi'}
    requested_tokens = [token for token in ('dt', 'odh', 'ozn', 'dgi') if token in source_tokens and token in allowed_tokens]
    if not requested_tokens:
        return geometry_norm

    selected_geometry_norm = _to_intersection_geometry(selected_geometry)
    selected_rootid_text = str(selected_rootid or '').strip()
    selected_request_id_text = str(selected_request_id or '').strip()
    geometry_json = json.dumps(geometry_norm)
    selected_geometry_json = json.dumps(selected_geometry_norm) if selected_geometry_norm else None
    normalized_source = _normalize_source_label(source_label)

    token_to_table = {
        'dt': settings.GIS_OBJECT_TABLE,
        'odh': getattr(settings, 'GIS_ODH_TABLE', 'odh'),
        'ozn': getattr(settings, 'GIS_OZN_TABLE', 'ozn'),
        'dgi': getattr(settings, 'GIS_DGI_TABLE', 'dgi'),
    }

    union_parts = []
    query_params = [geometry_json]
    if selected_geometry_json:
        query_params.append(selected_geometry_json)

    with connection.cursor() as cursor:
        for token in requested_tokens:
            table_name = token_to_table.get(token)
            if not table_name or not _table_exists(cursor, table_name):
                continue
            geom_field = _resolve_column_name(cursor, table_name, settings.GIS_OBJECT_GEOM_FIELD)
            exclude_selected_clause = ""
            exclude_selected_params = []
            if (
                (token == 'dt' and normalized_source == 'ДТ')
                or (token == 'odh' and normalized_source == 'ОДХ')
                or (token == 'ozn' and normalized_source == 'ОЗН')
            ):
                exclude_conditions = []
                if selected_rootid_text:
                    rootid_field = _resolve_column_name(cursor, table_name, settings.GIS_OBJECT_ROOTID_FIELD)
                    exclude_conditions.append(f"t.{_quote_ident(rootid_field)}::text = %s")
                    exclude_selected_params.append(selected_rootid_text)
                if selected_request_id_text:
                    request_id_field = _resolve_column_name(
                        cursor,
                        table_name,
                        getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id'),
                    )
                    exclude_conditions.append(f"t.{_quote_ident(request_id_field)}::text = %s")
                    exclude_selected_params.append(selected_request_id_text)
                if selected_geometry_json:
                    exclude_conditions.append(f"(s.geom IS NOT NULL AND ST_Equals(t.{_quote_ident(geom_field)}, s.geom))")
                if exclude_conditions:
                    exclude_selected_clause = " AND NOT (" + " OR ".join(exclude_conditions) + ")"
            union_parts.append(
                f"SELECT ST_CollectionExtract(ST_MakeValid(t.{_quote_ident(geom_field)}), 3) AS geom "
                f"FROM {_quote_ident(table_name)} t, input i"
                f"{' LEFT JOIN selected s ON TRUE' if selected_geometry_json else ''} "
                f"WHERE ST_Intersects(t.{_quote_ident(geom_field)}, i.geom)"
                f"{exclude_selected_clause}"
            )
            query_params.extend(exclude_selected_params)

        if not union_parts:
            return geometry_norm

        query = (
            "WITH input AS ("
            f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
            ")"
            + (
                ", selected AS ("
                f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                ")"
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
            "END "
            "FROM result r"
        )
        cursor.execute(query, query_params)
        row = cursor.fetchone()

    if not row or not row[0]:
        return None
    try:
        return json.loads(row[0])
    except (TypeError, json.JSONDecodeError):
        return None


def _to_geojson_geometry(geometry):
    if not isinstance(geometry, dict):
        return None
    geo_type = geometry.get('type')
    if geo_type == 'Feature':
        feature_geom = geometry.get('geometry')
        return feature_geom if isinstance(feature_geom, dict) else None
    if geo_type == 'FeatureCollection':
        geometries = []
        for feature in geometry.get('features') or []:
            feature_geom = (feature or {}).get('geometry')
            if isinstance(feature_geom, dict):
                geometries.append(feature_geom)
        if not geometries:
            return None
        if len(geometries) == 1:
            return geometries[0]
        return {'type': 'GeometryCollection', 'geometries': geometries}
    if geo_type in {'Polygon', 'MultiPolygon', 'GeometryCollection', 'LineString', 'MultiLineString'}:
        return geometry
    return None


def _cut_geometry_with_shape(base_geometry, cutter_geometry, cutter_type='polygon'):
    base_geometry_norm = _to_intersection_geometry(base_geometry)
    cutter_geometry_norm = _to_geojson_geometry(cutter_geometry)
    if not base_geometry_norm or not cutter_geometry_norm:
        return None

    cutter_type_norm = str(cutter_type or '').strip().lower()
    base_geometry_json = json.dumps(base_geometry_norm)
    cutter_geometry_json = json.dumps(cutter_geometry_norm)

    with connection.cursor() as cursor:
        if cutter_type_norm == 'line':
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
    geo_type = geometry.get('type')
    if geo_type == 'Feature':
        feature_geom = geometry.get('geometry')
        return feature_geom if isinstance(feature_geom, dict) else None
    if geo_type == 'FeatureCollection':
        geometries = []
        for feature in geometry.get('features') or []:
            feature_geom = (feature or {}).get('geometry')
            if isinstance(feature_geom, dict):
                geometries.append(feature_geom)
        if not geometries:
            return None
        if len(geometries) == 1:
            return geometries[0]
        return {'type': 'GeometryCollection', 'geometries': geometries}
    if geo_type in {'Polygon', 'MultiPolygon', 'GeometryCollection'}:
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

    if payload.get('type') == 'FeatureCollection':
        features = payload.get('features') or []
        if not isinstance(features, list):
            return payload
        simplified_features = []
        for feature in features:
            if not isinstance(feature, dict):
                continue
            simplified_feature = dict(feature)
            simplified_feature['geometry'] = _simplify_single_geometry(feature.get('geometry'))
            simplified_features.append(simplified_feature)
        result = dict(payload)
        result['features'] = simplified_features
        return result

    if payload.get('type') in {'Feature', 'Polygon', 'MultiPolygon', 'GeometryCollection'}:
        if payload.get('type') == 'Feature':
            result = dict(payload)
            result['geometry'] = _simplify_single_geometry(payload.get('geometry'))
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
        f"ALTER TABLE {_quote_ident(table_name)} "
        f"ADD COLUMN IF NOT EXISTS {_quote_ident(request_id_field)} text"
    )


def _create_new_object(username, geometry, name, request_id, source_label='ДТ', replace_row_ctid=None):
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
        else getattr(settings, 'GIS_OZN_OWNER_FIELD', 'ownerlegalpersonalid')
        if normalized_source == 'ОЗН'
        else getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    )
    request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')
    replace_tid = str(replace_row_ctid or '').strip()
    request_id_norm = str(request_id or '').strip()

    with connection.cursor() as cursor:
        rootid_field = _resolve_column_name(cursor, table, rootid_field_pref)
        name_field = _resolve_column_name(cursor, table, name_field_pref)
        geom_field = _resolve_column_name(cursor, table, geom_field_pref)
        owner_field = _resolve_column_name(cursor, table, owner_field_pref)
        request_id_field = _resolve_column_name(cursor, table, request_id_field_pref)

        _ensure_request_id_column(cursor, table, request_id_field)

        if replace_tid and request_id_norm:
            cursor.execute(
                f"SELECT {_quote_ident(request_id_field)}::text FROM {_quote_ident(table)} "
                f"WHERE ctid = %s::tid AND {_quote_ident(owner_field)} = %s LIMIT 1",
                [replace_tid, owner_id],
            )
            rid_row = cursor.fetchone()
            stored_rid = str(rid_row[0] or '').strip() if rid_row else ''
            if rid_row is not None and stored_rid and stored_rid == request_id_norm:
                geom_sql = _sql_geojson_param_as_valid_geom2d()
                cursor.execute(
                    f"UPDATE {_quote_ident(table)} SET "
                    f"{_quote_ident(name_field)} = %s, "
                    f"{_quote_ident(geom_field)} = {geom_sql} "
                    f"WHERE ctid = %s::tid AND {_quote_ident(owner_field)} = %s",
                    [name, json.dumps(geometry), replace_tid, owner_id],
                )
                if cursor.rowcount < 1:
                    raise ValueError('Не удалось обновить строку: нет доступа или запись не найдена.')
                return owner_id

        if request_id_norm:
            geom_sql = _sql_geojson_param_as_valid_geom2d()
            cursor.execute(
                f"UPDATE {_quote_ident(table)} SET "
                f"{_quote_ident(name_field)} = %s, "
                f"{_quote_ident(geom_field)} = {geom_sql} "
                f"WHERE {_quote_ident(request_id_field)}::text = %s "
                f"  AND {_quote_ident(owner_field)} = %s",
                [name, json.dumps(geometry), request_id_norm, owner_id],
            )
            if cursor.rowcount > 0:
                return owner_id

        insert_query = (
            f"INSERT INTO {_quote_ident(table)} ("
            f"{_quote_ident(rootid_field)}, "
            f"{_quote_ident(name_field)}, "
            f"{_quote_ident(owner_field)}, "
            f"{_quote_ident(request_id_field)}, "
            f"{_quote_ident(geom_field)}"
            f") VALUES (%s, %s, %s, %s, {_sql_geojson_param_as_valid_geom2d()})"
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
            f") VALUES (%s, %s, %s, %s, %s, {_sql_geojson_param_as_valid_geom2d()})"
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


def _get_reference_layer_geojson(
    table_name, source_label, geometry=None, distance_meters=100, intersects_only=False
):
    geom_field_pref = settings.GIS_OBJECT_GEOM_FIELD
    customer_field_pref = getattr(settings, 'GIS_OBJECT_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    department_field_pref = getattr(settings, 'GIS_OBJECT_DEPARTMENT_FIELD', 'DepartmentLegalPersonId')
    owner_field_pref = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    source_label_norm = str(source_label or '').strip().upper()
    department_field_candidates = [department_field_pref]
    if source_label_norm == 'ОДХ':
        department_field_candidates.insert(0, getattr(settings, 'GIS_ODH_GRBS_FIELD', 'grbslegalpersonid'))
    owner_field_candidates = [owner_field_pref]
    if source_label_norm == 'ОЗН':
        owner_field_candidates.insert(0, getattr(settings, 'GIS_OZN_OWNER_FIELD', 'ownerlegalpersonalid'))
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
                f"      'owner_legal_person_id', {owner_prop_expr},"
                f"      'customer_legal_person_name', {customer_name_prop_expr},"
                f"      'department_legal_person_name', {department_name_prop_expr},"
                f"      'owner_legal_person_name', {owner_name_prop_expr}"
                "   )"
                " )), '[]'::jsonb)"
                ")::text "
                f"FROM (SELECT t.{_quote_ident(geom_field)} AS {_quote_ident(geom_field)}, "
                f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}, {sobstv_rr_select_expr}, {customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr} "
                f"FROM {_quote_ident(table_name)} t) rel"
            )
            cursor.execute(query, [source_label])
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
                f"      'vri', {vri_prop_expr},"
                f"      'sobstv_rr', {sobstv_rr_prop_expr},"
                f"      'customer_legal_person_id', {customer_prop_expr},"
                f"      'department_legal_person_id', {department_prop_expr},"
                f"      'owner_legal_person_id', {owner_prop_expr},"
                f"      'customer_legal_person_name', {customer_name_prop_expr},"
                f"      'department_legal_person_name', {department_name_prop_expr},"
                f"      'owner_legal_person_name', {owner_name_prop_expr}"
                "   )"
                " )), '[]'::jsonb)"
                ")::text FROM rel"
            )
            if intersects_only:
                query = (
                    "WITH input AS ("
                    f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), input_parts AS ("
                    " SELECT (ST_Dump(ST_CollectionExtract(geom, 3))).geom AS geom FROM input"
                    "), rel AS ("
                    f" SELECT t.{_quote_ident(geom_field)} AS geom, "
                    f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}, {sobstv_rr_select_expr}, {customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr} "
                    f"FROM {_quote_ident(table_name)} t, input i"
                    f" WHERE ST_Intersects(t.{_quote_ident(geom_field)}, i.geom)"
                    "   AND NOT EXISTS ("
                    "       SELECT 1 FROM input_parts p"
                    f"       WHERE ST_Equals(t.{_quote_ident(geom_field)}, p.geom)"
                    "   )"
                    ") "
                    + select_json_tail
                )
                cursor.execute(query, [geometry_json, source_label])
            else:
                query = (
                    "WITH input AS ("
                    f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), rel AS ("
                    f" SELECT t.{_quote_ident(geom_field)} AS geom, "
                    f"{rootid_select_expr}, {name_select_expr}, {descr_select_expr}, {address_select_expr}, {vri_select_expr}, {sobstv_rr_select_expr}, {customer_select_expr}, {department_select_expr}, {owner_select_expr}, {customer_name_select_expr}, {department_name_select_expr}, {owner_name_select_expr} "
                    f"FROM {_quote_ident(table_name)} t, input i"
                    f" WHERE t.{_quote_ident(geom_field)} && ST_Envelope(ST_Buffer(i.geom::geography, %s)::geometry)"
                    "   AND (ST_DWithin("
                    f"   t.{_quote_ident(geom_field)}::geography,"
                    "   ST_Boundary(i.geom)::geography,"
                    "   %s"
                    " ) OR ST_Intersects("
                    f"   t.{_quote_ident(geom_field)},"
                    "   i.geom"
                    " ))"
                    ") "
                    + select_json_tail
                )
                cursor.execute(query, [geometry_json, distance_meters, distance_meters, source_label])
        row = cursor.fetchone()
        return row[0] if row else None


def _get_recaps_layer_geojson(geometry=None, distance_meters=100, request_id_filter=None):
    request_id_text = str(request_id_filter or '').strip()
    has_request_id = bool(request_id_text)
    with connection.cursor() as cursor:
        name_field_pref = settings.GIS_OBJECT_NAME_FIELD
        owner_field_pref = settings.GIS_OBJECT_OWNER_FIELD
        request_id_field_pref = getattr(settings, 'GIS_OBJECT_REQUEST_ID_FIELD', 'request_id')
        name_select_expr = "NULL::text AS name"
        owner_select_expr = "NULL::text AS owner_legal_person_id"
        owner_name_select_expr = "NULL::text AS owner_legal_person_name"
        owner_name_prop_expr = "owner_legal_person_name::text"
        lookup_context = _get_id_names_lookup_context(cursor)
        request_id_col = 'request_id'
        if _column_exists(cursor, 'recaps', request_id_field_pref):
            request_id_col = _resolve_column_name(cursor, 'recaps', request_id_field_pref)
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
        recap_select_core = (
            f"t.geom AS geom, t.recap_id AS recap_id, t.{_quote_ident(request_id_col)} AS request_id, "
            f"{name_select_expr}, {owner_select_expr}, {owner_name_select_expr}"
        )
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
                    "WITH rel AS ("
                    f" SELECT {recap_select_core} "
                    " FROM recaps t"
                    f" WHERE t.{_quote_ident(request_id_col)}::text = %s"
                    ") "
                    + json_agg_select
                )
                cursor.execute(query, [request_id_text])
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
                    f"FROM (SELECT {recap_select_core} FROM recaps t) rel"
                )
                cursor.execute(query)
        else:
            geometry_json = geometry if isinstance(geometry, str) else json.dumps(geometry)
            if has_request_id:
                query = (
                    "WITH input AS ("
                    f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), spatial_rel AS ("
                    f" SELECT {recap_select_core}"
                    " FROM recaps t, input i"
                    " WHERE t.geom && ST_Envelope(ST_Buffer(i.geom::geography, %s)::geometry)"
                    "   AND (ST_DWithin(t.geom::geography, ST_Boundary(i.geom)::geography, %s)"
                    "    OR ST_Intersects(t.geom, i.geom))"
                    "), request_rel AS ("
                    f" SELECT {recap_select_core}"
                    " FROM recaps t"
                    f" WHERE t.{_quote_ident(request_id_col)}::text = %s"
                    "), rel AS ("
                    " SELECT * FROM spatial_rel"
                    " UNION"
                    " SELECT * FROM request_rel"
                    ") "
                    + json_agg_select
                )
                cursor.execute(query, [geometry_json, distance_meters, distance_meters, request_id_text])
            else:
                query = (
                    "WITH input AS ("
                    f" SELECT {_sql_geojson_param_as_valid_geom2d()} AS geom"
                    "), rel AS ("
                    f" SELECT {recap_select_core}"
                    " FROM recaps t, input i"
                    " WHERE t.geom && ST_Envelope(ST_Buffer(i.geom::geography, %s)::geometry)"
                    "   AND (ST_DWithin(t.geom::geography, ST_Boundary(i.geom)::geography, %s)"
                    "    OR ST_Intersects(t.geom, i.geom))"
                    ") "
                    + json_agg_select
                )
                cursor.execute(query, [geometry_json, distance_meters, distance_meters])
        row = cursor.fetchone()
        return row[0] if row else None


def _get_reference_layers(geometry=None, distance_meters=100, request_id_filter=None):
    layers = {'dgi': None, 'odh': None, 'ozn': None, 'renew': None, 'recaps': None}
    try:
        layers['dgi'] = _get_reference_layer_geojson('dgi', 'ДГИ', geometry=geometry, distance_meters=distance_meters)
    except Exception:
        layers['dgi'] = None
    try:
        layers['odh'] = _get_reference_layer_geojson('odh', 'ОДХ', geometry=geometry, distance_meters=distance_meters)
    except Exception:
        layers['odh'] = None
    try:
        layers['ozn'] = _get_reference_layer_geojson(
            getattr(settings, 'GIS_OZN_TABLE', 'ozn'),
            'ОЗН',
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers['ozn'] = None
    try:
        layers['renew'] = _get_reference_layer_geojson(
            getattr(settings, 'GIS_RENEW_TABLE', 'renew'),
            'Реновация',
            geometry=geometry,
            distance_meters=distance_meters,
        )
    except Exception:
        layers['renew'] = None
    try:
        layers['recaps'] = _get_recaps_layer_geojson(
            geometry=geometry,
            distance_meters=distance_meters,
            request_id_filter=request_id_filter,
        )
    except Exception:
        layers['recaps'] = None
    return layers


def _entry_point_needs_request_id(entry_point):
    if not entry_point:
        return True
    return not (str(entry_point.get('request_id') or '').strip())


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
                    if _entry_point_needs_request_id(entry_point):
                        request.session['pending_entry_point'] = entry_point
                    else:
                        request.session['entry_point'] = entry_point
                        return redirect('main')
                else:
                    form.add_error(None, 'Объект не найден. Проверьте № Паспорта или Название.')
    else:
        form = EntryPointForm()

    owner_id = None
    owner_name = None
    owned_objects = []
    owned_passports_geojson = {'type': 'FeatureCollection', 'features': []}
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
            owned_passports_geojson = _build_owned_passports_geojson(owned_objects)
    except Exception:
        owned_objects_error = (
            'Не удалось получить список объектов пользователя. '
            'Проверьте поле OwnerLegalPersonId в таблице users.'
        )

    need_entry_request_id = bool(request.session.get('pending_entry_point'))

    return render(
        request,
        'pass_viewer/home.html',
        {
            'form': form,
            'owner_id': owner_id,
            'owner_name': owner_name,
            'owned_objects': owned_objects,
            'owned_passports_geojson': owned_passports_geojson,
            'owned_objects_error': owned_objects_error,
            'need_entry_request_id': need_entry_request_id,
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

    selected_request_id = (layers.get('selected_request_id') or '').strip() if layers else ''
    ep_request_id = (entry_point.get('request_id') or '').strip()
    effective_request_id = selected_request_id or ep_request_id
    selected_geometry_for_editing = layers['selected'] if layers else None
    geometry_detail_mode = str(entry_point.get('geometry_detail_mode') or '').strip().lower()
    use_full_geometry = geometry_detail_mode == 'full'
    should_simplify_selected = (
        bool(layers)
        and (entry_point.get('entry_source') == 'owned_passport_list')
        and bool((layers.get('selected_rootid') or '').strip())
        and not use_full_geometry
    )
    if should_simplify_selected:
        try:
            simplify_tolerance_m = float(getattr(settings, 'GIS_EDIT_SIMPLIFY_TOLERANCE_METERS', 0.75))
            selected_geom_simplified = _simplify_geojson_for_editing(
                layers['selected'],
                tolerance_meters=max(0.0, simplify_tolerance_m),
            )
            if selected_geom_simplified:
                selected_geometry_for_editing = json.dumps(selected_geom_simplified, ensure_ascii=False)
        except Exception:
            logger.exception('main: failed to simplify selected geometry for editing')

    reference_layers = _get_reference_layers(
        geometry=layers['selected'] if layers else None,
        distance_meters=100,
        request_id_filter=effective_request_id or None,
    )

    return render(
        request,
        'pass_viewer/main.html',
        {
            'entry_point': entry_point,
            'map_layers': layers,
            'selected_geometry_json': layers['selected'] if layers else None,
            'selected_geometry_for_editing_json': selected_geometry_for_editing,
            'selected_rootid': layers['selected_rootid'] if layers else None,
            'selected_name': layers['selected_name'] if layers else None,
            'selected_request_id': layers['selected_request_id'] if layers else None,
            'selected_ctid': layers.get('selected_ctid') if layers else None,
            'effective_request_id': effective_request_id,
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
            'ozn_geometry_json': reference_layers['ozn'],
            'renew_geometry_json': reference_layers['renew'],
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
    replace_row_ctid = (payload.get('replace_row_ctid') or payload.get('replaceRowCtid') or '').strip()
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
            replace_row_ctid=replace_row_ctid or None,
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
        return JsonResponse({'ok': False, 'error': 'Укажите номер досъёма (recap_id).'}, status=400)
    if not recap_id.isdigit():
        return JsonResponse({'ok': False, 'error': 'Номер досъёма (recap_id) должен содержать только цифры.'}, status=400)
    if not request_id:
        return JsonResponse({'ok': False, 'error': 'Укажите номер заявки (request_id).'}, status=400)
    if not request_id.isdigit():
        return JsonResponse({'ok': False, 'error': 'Номер заявки (request_id) должен содержать только цифры.'}, status=400)

    recap_exists = _check_recap_uniqueness(recap_id=recap_id)
    if recap_exists:
        return JsonResponse({'ok': False, 'error': 'Номер досъёма (recap_id) уже существует.'}, status=400)

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
        return JsonResponse({'ok': False, 'error': 'Не удалось сохранить досъём в recaps.'}, status=500)

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

    geometry_detail_mode = str(request.POST.get('geometry_detail_mode') or '').strip().lower()
    if geometry_detail_mode not in {'simplified', 'full'}:
        geometry_detail_mode = 'simplified' if rootid else 'full'
    request.session['entry_point'] = {
        'rootid': rootid,
        'request_id': request_id,
        'name': '' if rootid else name,
        'source_label': _normalize_source_label(request.POST.get('source_label')),
        'entry_source': 'owned_passport_list' if rootid else 'owned_request_list',
        'geometry_detail_mode': geometry_detail_mode,
    }
    return redirect('main')


@login_required
@require_POST
def open_merged_passports(request):
    request_id = (request.POST.get('request_id') or '').strip()
    target_source_label = _normalize_source_label(request.POST.get('target_source_label'))
    rootids = [r.strip() for r in request.POST.getlist('merge_item_rootid') if r.strip()]
    sources = [_normalize_source_label(s) for s in request.POST.getlist('merge_item_source')]
    if len(rootids) < 2 or len(rootids) != len(sources) or not request_id.isdigit():
        return redirect('home')

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return redirect('home')

    owned = _get_owned_objects(owner_id)
    allowed_pairs = {
        ((item.get('rootid') or '').strip(), _normalize_source_label(item.get('source_label')))
        for item in owned
        if (item.get('rootid') or '').strip()
    }
    merge_items = [{'rootid': rid, 'source_label': sl} for rid, sl in zip(rootids, sources)]
    if not all(((it['rootid'], it['source_label']) in allowed_pairs) for it in merge_items):
        return redirect('home')

    request.session['entry_point'] = {
        'rootid': '',
        'request_id': request_id,
        'name': f'Объединение {len(merge_items)} паспортов (→ {target_source_label})',
        'source_label': target_source_label,
        'merge_items': merge_items,
    }
    return redirect('main')


@login_required
def cancel_pending_entry(request):
    request.session.pop('pending_entry_point', None)
    return redirect('home')


@login_required
@require_POST
def confirm_entry_request_id(request):
    request_id = (request.POST.get('request_id') or '').strip()
    if not request_id or not request_id.isdigit():
        return redirect('home')
    pending = request.session.get('pending_entry_point')
    if not pending:
        return redirect('home')
    del request.session['pending_entry_point']
    pending = dict(pending)
    pending['request_id'] = request_id
    request.session['entry_point'] = pending
    return redirect('main')


@login_required
@require_POST
def prepare_add_object(request):
    request_id = (request.POST.get('request_id') or '').strip()
    if not request_id or not request_id.isdigit():
        return redirect('home')
    request.session['entry_point'] = {
        'rootid': '',
        'name': '',
        'request_id': request_id,
        'source_label': _normalize_source_label(request.POST.get('source_label')),
    }
    return redirect('add_object')


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
        else getattr(settings, 'GIS_OZN_OWNER_FIELD', 'ownerlegalpersonalid')
        if source_label == 'ОЗН'
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
    effective_request_id = (entry_point.get('request_id') or '').strip()
    return render(
        request,
        'pass_viewer/add_object.html',
        {
            'dgi_geometry_json': None,
            'odh_geometry_json': None,
            'ozn_geometry_json': None,
            'renew_geometry_json': None,
            'recaps_geometry_json': None,
            'request_objects_geometry_json': None,
            'selected_rootid': (entry_point.get('rootid') or '').strip(),
            'selected_source_label': _normalize_source_label(entry_point.get('source_label')),
            'effective_request_id': effective_request_id,
        },
    )


@login_required
def add_recap(request):
    request_id = (request.GET.get('request_id') or '').strip()
    name = (request.GET.get('name') or '').strip()
    object_key = (request.GET.get('object_key') or '').strip()
    source_label = _normalize_source_label(request.GET.get('source_label'))
    recap_id_param = (request.GET.get('recap_id') or '').strip()
    initial_recap_id = recap_id_param if recap_id_param.isdigit() else ''
    owner_id = _get_current_user_owner_id(request.user.username)
    selected_object = _get_owned_request_object(owner_id, object_key, source_label=source_label)
    if not selected_object:
        return redirect('home')

    selected_geometry = None
    try:
        selected_geometry = json.loads(selected_object['geometry_json'])
    except (TypeError, json.JSONDecodeError):
        selected_geometry = None

    recap_request_id = str(selected_object.get('request_id') or request_id or '').strip()
    reference_layers = _get_reference_layers(
        geometry=selected_object['geometry_json'],
        distance_meters=100,
        request_id_filter=recap_request_id or None,
    )
    initial_relations = {'intersects': None, 'touches': None, 'nearby': None, 'request_objects': None}
    if selected_geometry:
        try:
            initial_relations = _get_new_object_relations(
                selected_geometry,
                source_label=selected_object.get('source_label') or source_label,
                request_id_filter=recap_request_id or None,
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
            'selected_rootid': selected_object['rootid'] or '',
            'selected_source_label': selected_object.get('source_label') or source_label,
            'selected_geometry_json': selected_object['geometry_json'],
            'intersects_geometry_json': initial_relations.get('intersects'),
            'touches_geometry_json': initial_relations.get('touches'),
            'nearby_geometry_json': initial_relations.get('nearby'),
            'request_objects_geometry_json': initial_relations.get('request_objects'),
            'dgi_geometry_json': reference_layers['dgi'],
            'odh_geometry_json': reference_layers['odh'],
            'ozn_geometry_json': reference_layers['ozn'],
            'renew_geometry_json': reference_layers['renew'],
            'recaps_geometry_json': reference_layers['recaps'],
            'initial_recap_id': initial_recap_id,
        },
    )


@login_required
@require_POST
def check_new_object_relations(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry_raw = payload.get('geometry')
    geometry = _to_intersection_geometry(geometry_raw)
    if not geometry:
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)
    selected_geometry = _to_intersection_geometry(payload.get('selected_geometry'))
    geometry_for_selected_check = _to_intersection_geometry(payload.get('geometry_for_selected_check'))
    has_selected_geometry = bool(selected_geometry)
    source_label = _normalize_source_label(payload.get('source_label'))
    request_id_filter = str(payload.get('request_id') or payload.get('request_id_filter') or '').strip() or None

    try:
        layers = _get_new_object_relations(geometry, source_label=source_label, request_id_filter=request_id_filter)
    except Exception:
        logger.exception('check_new_object_relations: failed loading relation layers from PostGIS')
        return JsonResponse(
            {'ok': False, 'error': 'Не удалось получить связанные объекты из PostGIS.'},
            status=500
        )

    intersects_selected = False
    if has_selected_geometry:
        try:
            intersects_input = geometry_for_selected_check or geometry
            intersects_selected = _geometries_intersect(intersects_input, selected_geometry)
        except Exception:
            logger.exception('check_new_object_relations: intersect-with-selected check failed')
            intersects_selected = False

    return JsonResponse(
        {
            'ok': True,
            'layers': layers,
            'intersects_selected': intersects_selected,
        }
    )


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


@login_required
@require_POST
def auto_remove_intersections(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = _to_intersection_geometry(payload.get('geometry'))
    if not geometry:
        return JsonResponse({'ok': False, 'error': 'Геометрия не передана.'}, status=400)

    selected_sources = payload.get('selected_sources') or []
    if not isinstance(selected_sources, list):
        return JsonResponse({'ok': False, 'error': 'Некорректный список источников.'}, status=400)

    source_label = _normalize_source_label(payload.get('source_label'))
    selected_geometry = _to_intersection_geometry(payload.get('selected_geometry'))
    selected_rootid = (payload.get('selected_rootid') or '').strip()
    selected_request_id = (payload.get('selected_request_id') or '').strip()

    try:
        cleaned_geometry = _remove_intersections_from_geometry(
            geometry,
            selected_sources=selected_sources,
            source_label=source_label,
            selected_geometry=selected_geometry,
            selected_rootid=selected_rootid,
            selected_request_id=selected_request_id,
        )
    except Exception:
        logger.exception('auto_remove_intersections: failed subtracting intersections')
        return JsonResponse(
            {'ok': False, 'error': 'Не удалось выполнить автоматическое удаление пересечений.'},
            status=500
        )

    return JsonResponse({'ok': True, 'geometry': cleaned_geometry})


@login_required
@require_POST
def cut_edited_geometry(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    geometry = _to_intersection_geometry(payload.get('geometry'))
    if not geometry:
        return JsonResponse({'ok': False, 'error': 'Геометрия редактируемого объекта не передана.'}, status=400)

    cutter_geometry = _to_geojson_geometry(payload.get('cutter_geometry'))
    if not cutter_geometry:
        return JsonResponse({'ok': False, 'error': 'Геометрия обрезки не передана.'}, status=400)

    cutter_type = str(payload.get('cutter_type') or 'polygon').strip().lower()
    if cutter_type not in {'polygon', 'line'}:
        cutter_type = 'polygon'

    try:
        result_geometry = _cut_geometry_with_shape(
            geometry,
            cutter_geometry,
            cutter_type=cutter_type,
        )
    except Exception:
        logger.exception('cut_edited_geometry: failed cutting edited geometry')
        return JsonResponse({'ok': False, 'error': 'Не удалось обрезать геометрию.'}, status=500)

    return JsonResponse({'ok': True, 'geometry': result_geometry})


@login_required
@require_GET
def list_comment_points(request):
    request_id = (request.GET.get('request_id') or '').strip()
    if not request_id:
        return JsonResponse({'ok': False, 'error': 'Укажите request_id.'}, status=400)

    table = _comment_points_table_name()
    with connection.cursor() as cursor:
        if not _table_exists(cursor, table):
            return JsonResponse(
                {'ok': True, 'geojson': {'type': 'FeatureCollection', 'features': []}}
            )
        t = _quote_ident(table)
        cursor.execute(
            f"""
            SELECT p.id, ST_AsGeoJSON(p.geom)::text, p.request_id::text, p.comment, p.owner_legal_person_id::text,
                   to_char(p.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
            FROM {t} p
            WHERE p.request_id::text = %s
            ORDER BY p.id
            """,
            [request_id],
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
                'type': 'Feature',
                'id': id_,
                'geometry': geometry,
                'properties': {
                    'id': id_,
                    'request_id': rid,
                    'comment': cmt,
                    'owner_legal_person_id': oid,
                    'created_at': created or '',
                },
            }
        )

    return JsonResponse(
        {
            'ok': True,
            'geojson': {'type': 'FeatureCollection', 'features': features},
        }
    )


@login_required
@require_POST
def save_comment_point(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)

    request_id = (payload.get('request_id') or '').strip()
    comment = (payload.get('comment') or '').strip()
    try:
        lng = float(payload.get('lng'))
        lat = float(payload.get('lat'))
    except (TypeError, ValueError):
        return JsonResponse({'ok': False, 'error': 'Укажите координаты точки (lng, lat).'}, status=400)

    if not request_id or not request_id.isdigit():
        return JsonResponse({'ok': False, 'error': 'Некорректный или пустой request_id.'}, status=400)
    if not comment:
        return JsonResponse({'ok': False, 'error': 'Введите комментарий.'}, status=400)
    if len(comment) > 4000:
        return JsonResponse({'ok': False, 'error': 'Комментарий слишком длинный (макс. 4000 символов).'}, status=400)
    if not (-180.0 <= lng <= 180.0) or not (-90.0 <= lat <= 90.0):
        return JsonResponse({'ok': False, 'error': 'Координаты вне допустимого диапазона.'}, status=400)

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {'ok': False, 'error': 'Не найден OwnerLegalPersonId для пользователя в таблице users.'},
            status=400,
        )

    table = _comment_points_table_name()
    try:
        with connection.cursor() as cursor:
            if not _table_exists(cursor, table):
                return JsonResponse(
                    {'ok': False, 'error': 'Таблица точек комментариев не найдена в базе.'},
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
        logger.exception('save_comment_point: insert failed')
        return JsonResponse({'ok': False, 'error': 'Не удалось сохранить точку комментария.'}, status=500)

    if not row:
        return JsonResponse({'ok': False, 'error': 'Не удалось сохранить точку комментария.'}, status=500)

    id_, geom_json, rid, cmt, oid, created = row
    try:
        geometry = json.loads(geom_json)
    except (TypeError, json.JSONDecodeError):
        geometry = None
    feature = {
        'type': 'Feature',
        'id': id_,
        'geometry': geometry,
        'properties': {
            'id': id_,
            'request_id': rid,
            'comment': cmt,
            'owner_legal_person_id': oid,
            'created_at': created or '',
        },
    }
    return JsonResponse({'ok': True, 'feature': feature})


@login_required
@require_POST
def delete_comment_point(request):
    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'ok': False, 'error': 'Некорректный JSON.'}, status=400)
    try:
        point_id = int(payload.get('id'))
    except (TypeError, ValueError):
        return JsonResponse({'ok': False, 'error': 'Некорректный id точки.'}, status=400)

    owner_id = _get_current_user_owner_id(request.user.username)
    if owner_id is None:
        return JsonResponse(
            {'ok': False, 'error': 'Не найден OwnerLegalPersonId для пользователя в таблице users.'},
            status=400,
        )

    table = _comment_points_table_name()
    try:
        with connection.cursor() as cursor:
            if not _table_exists(cursor, table):
                return JsonResponse({'ok': False, 'error': 'Таблица точек комментариев не найдена в базе.'}, status=500)
            t = _quote_ident(table)
            cursor.execute(
                f"DELETE FROM {t} WHERE id = %s AND owner_legal_person_id::text = %s RETURNING id",
                [point_id, str(owner_id)],
            )
            row = cursor.fetchone()
    except Exception:
        logger.exception('delete_comment_point: delete failed')
        return JsonResponse({'ok': False, 'error': 'Не удалось удалить точку комментария.'}, status=500)

    if not row:
        return JsonResponse(
            {'ok': False, 'error': 'Точка не найдена или нет прав на удаление.'},
            status=404,
        )
    return JsonResponse({'ok': True, 'id': point_id})

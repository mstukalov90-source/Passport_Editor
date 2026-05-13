"""
Spatial access scope based on public.hood polygons.

For an authenticated user, collect hood rows whose overlap with the union of all
geometries owned by the user (pass_objects / odh / ozn, same owner-field rules)
meets ``GIS_HOOD_MIN_OVERLAP_RATIO`` (share of owner union area in m² via geography).
Tiny boundary slivers into a neighboring district stay excluded. When the ratio
is 0, any ``ST_Intersects`` match counts (legacy behavior).

The union of those hood geometries is the allowed region; all GIS reads should
intersect it. If the hood table is missing, scope is disabled (backward compatible).

When ``GIS_HOOD_APPLY_SPATIAL_SCOPE`` is false (default), no hood resolution runs and
no spatial hood AND clauses are applied (scope mode ``skip``); code paths stay in place
for later re-enabling.
"""
import json
import threading
from typing import Any, List, Optional, Tuple

from django.conf import settings
from django.db import connection

_local = threading.local()

# Increment when hood scope SQL semantics change so session-cached WKT is refreshed.
HOOD_SCOPE_SESSION_VERSION = 3


def _hood_spatial_scope_active() -> bool:
    """Heavy hood district resolution and SQL filters; both toggles must be on."""
    if not getattr(settings, 'GIS_HOOD_ACCESS_ENABLED', True):
        return False
    if not getattr(settings, 'GIS_HOOD_APPLY_SPATIAL_SCOPE', False):
        return False
    return True


def _hq_quote_ident(identifier: str) -> str:
    return '"' + str(identifier).replace('"', '""') + '"'


def _hq_table_exists(cursor, table_name: str) -> bool:
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


def _hq_column_exists(cursor, table_name: str, column_name: str) -> bool:
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


def _hq_resolve_column_name(cursor, table_name: str, preferred_name: str) -> str:
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


def _hood_owner_geom_union_sql_and_params(cursor, owner_legal_person_id) -> Tuple[Optional[str], List[Any]]:
    """
    SQL fragment ``(sub) UNION ALL (sub) …`` of all geometries owned by ``owner_legal_person_id``,
    plus bound params. Returns (None, []) when hood access is off, hood table missing, or no owner geoms.
    """
    if not _hood_spatial_scope_active():
        return None, []
    if not owner_legal_person_id:
        return None, []

    hood_table = getattr(settings, 'GIS_HOOD_TABLE', 'hood')
    if not _hq_table_exists(cursor, hood_table):
        return None, []

    primary_table = settings.GIS_OBJECT_TABLE
    odh_table = getattr(settings, 'GIS_ODH_TABLE', 'odh')
    ozn_table = getattr(settings, 'GIS_OZN_TABLE', 'ozn')
    geom_pref = settings.GIS_OBJECT_GEOM_FIELD
    owner_dt = getattr(settings, 'GIS_OBJECT_OWNER_FIELD', 'OwnerLegalPersonId')
    odh_customer = getattr(settings, 'GIS_ODH_CUSTOMER_FIELD', 'CustomerLegalPersonId')
    ozn_owner = getattr(settings, 'GIS_OZN_OWNER_FIELD', 'ownerlegalpersonalid')

    subqueries: List[str] = []
    params: List[Any] = []
    owner_text = str(owner_legal_person_id)

    for tbl, candidates in (
        (primary_table, [owner_dt]),
        (odh_table, [odh_customer, owner_dt]),
        (ozn_table, [ozn_owner, owner_dt]),
    ):
        if not _hq_table_exists(cursor, tbl):
            continue
        if not _hq_column_exists(cursor, tbl, geom_pref):
            continue
        gf = _hq_resolve_column_name(cursor, tbl, geom_pref)
        owner_col = None
        for cand in candidates:
            if _hq_column_exists(cursor, tbl, cand):
                owner_col = _hq_resolve_column_name(cursor, tbl, cand)
                break
        if not owner_col:
            continue
        subqueries.append(
            f"SELECT {_hq_quote_ident(gf)} AS geom FROM {_hq_quote_ident(tbl)} "
            f"WHERE {_hq_quote_ident(owner_col)}::text = %s::text "
            f"AND {_hq_quote_ident(gf)} IS NOT NULL"
        )
        params.append(owner_text)

    if not subqueries:
        return None, []
    return ' UNION ALL '.join(f'({s})' for s in subqueries), params


def _hood_min_overlap_ratio() -> float:
    try:
        r = float(getattr(settings, 'GIS_HOOD_MIN_OVERLAP_RATIO', 0.05))
    except (TypeError, ValueError):
        return 0.05
    return max(0.0, r)


def _hood_owner_union_cte_sql(union_sql: str) -> str:
    """WITH body: owner_parts → single union geom + total area (geography, m²)."""
    return (
        'owner_parts AS ( '
        f'{union_sql} '
        '), owner_u AS ( '
        'SELECT ST_MakeValid(ST_UnaryUnion(ST_Collect(geom))) AS g '
        'FROM owner_parts WHERE geom IS NOT NULL AND NOT ST_IsEmpty(geom) '
        '), owner_area AS ( '
        'SELECT NULLIF(ST_Area(g::geography), 0) AS total_m2 FROM owner_u '
        ') '
    )


def get_hood_allowed_districts_geojson(cursor, owner_legal_person_id) -> dict:
    """
    GeoJSON FeatureCollection: hood polygons included in the user's spatial scope
    (same rules as :func:`resolve_hood_scope_for_owner`). Empty collection when access is off or no rows.
    """
    if not _hood_spatial_scope_active():
        return {'type': 'FeatureCollection', 'features': []}
    union_sql, params = _hood_owner_geom_union_sql_and_params(cursor, owner_legal_person_id)
    if not union_sql:
        return {'type': 'FeatureCollection', 'features': []}

    hood_table = getattr(settings, 'GIS_HOOD_TABLE', 'hood')
    if not _hq_column_exists(cursor, hood_table, 'geom'):
        return {'type': 'FeatureCollection', 'features': []}
    geom_f = _hq_resolve_column_name(cursor, hood_table, 'geom')
    hg = _hq_quote_ident(geom_f)
    ratio = _hood_min_overlap_ratio()

    prop_parts: List[str] = []
    if _hq_column_exists(cursor, hood_table, 'gid'):
        gid_c = _hq_resolve_column_name(cursor, hood_table, 'gid')
        prop_parts.append(f"'gid', h.{_hq_quote_ident(gid_c)}")
    for label in ('rayon', 'okrug', 'okrug_shor', 'area'):
        if not _hq_column_exists(cursor, hood_table, label):
            continue
        col = _hq_resolve_column_name(cursor, hood_table, label)
        if label == 'area':
            prop_parts.append(f"'{label}', h.{_hq_quote_ident(col)}")
        else:
            prop_parts.append(f"'{label}', COALESCE(h.{_hq_quote_ident(col)}::text, '')")
    if not prop_parts:
        prop_parts.append("'layer', 'hood_district'")
    props_sql = ', '.join(prop_parts)

    order_clause = ''
    if _hq_column_exists(cursor, hood_table, 'gid'):
        gid_c = _hq_resolve_column_name(cursor, hood_table, 'gid')
        order_clause = f' ORDER BY h.{_hq_quote_ident(gid_c)}'

    if ratio <= 0:
        sql = (
            "SELECT jsonb_build_object("
            "'type', 'FeatureCollection', "
            "'features', COALESCE(jsonb_agg("
            f"jsonb_build_object("
            f"'type', 'Feature', "
            f"'geometry', ST_AsGeoJSON(ST_Force2D(h.{hg}))::jsonb, "
            f"'properties', jsonb_build_object({props_sql})"
            f"){order_clause}), '[]'::jsonb)"
            ")::text "
            f"FROM {_hq_quote_ident(hood_table)} h "
            f"WHERE EXISTS (SELECT 1 FROM ({union_sql}) u "
            f"WHERE u.geom IS NOT NULL AND ST_Intersects(h.{hg}, u.geom))"
        )
        exec_params: List[Any] = list(params)
    else:
        sql = (
            'WITH '
            + _hood_owner_union_cte_sql(union_sql)
            + 'SELECT jsonb_build_object('
            "'type', 'FeatureCollection', "
            "'features', COALESCE(jsonb_agg("
            f"jsonb_build_object("
            f"'type', 'Feature', "
            f"'geometry', ST_AsGeoJSON(ST_Force2D(h.{hg}))::jsonb, "
            f"'properties', jsonb_build_object({props_sql})"
            f"){order_clause}), '[]'::jsonb)"
            ")::text "
            f"FROM {_hq_quote_ident(hood_table)} h "
            'CROSS JOIN owner_u ou CROSS JOIN owner_area oa '
            f'WHERE ou.g IS NOT NULL AND NOT ST_IsEmpty(ou.g) '
            f'AND ST_Intersects(h.{hg}, ou.g) '
            f'AND (oa.total_m2 IS NULL OR oa.total_m2 = 0 OR '
            f'ST_Area(ST_Intersection(ou.g, ST_MakeValid(h.{hg}))::geography) / oa.total_m2 >= %s) '
        )
        exec_params = list(params) + [ratio]
    cursor.execute(sql, exec_params)
    row = cursor.fetchone()
    if not row or not row[0]:
        return {'type': 'FeatureCollection', 'features': []}
    try:
        return json.loads(row[0])
    except (TypeError, json.JSONDecodeError):
        return {'type': 'FeatureCollection', 'features': []}


def resolve_hood_scope_for_owner(cursor, owner_legal_person_id) -> dict:
    """
    Returns dict:
      mode: 'skip' | 'empty' | 'active'
      wkt: WKT string when active, else None
    """
    if not _hood_spatial_scope_active():
        return {'mode': 'skip', 'wkt': None}
    if not owner_legal_person_id:
        return {'mode': 'skip', 'wkt': None}

    hood_table = getattr(settings, 'GIS_HOOD_TABLE', 'hood')
    if not _hq_table_exists(cursor, hood_table):
        return {'mode': 'skip', 'wkt': None}
    if not _hq_column_exists(cursor, hood_table, 'geom'):
        return {'mode': 'skip', 'wkt': None}

    union_sql, params = _hood_owner_geom_union_sql_and_params(cursor, owner_legal_person_id)
    if not union_sql:
        return {'mode': 'skip', 'wkt': None}

    geom_f = _hq_resolve_column_name(cursor, hood_table, 'geom')
    hg = _hq_quote_ident(geom_f)
    ratio = _hood_min_overlap_ratio()

    if ratio <= 0:
        sql = (
            f"SELECT ST_AsText(ST_UnaryUnion(ST_Collect(h.{hg}))) "
            f"FROM {_hq_quote_ident(hood_table)} h "
            f"WHERE EXISTS ("
            f"  SELECT 1 FROM ({union_sql}) u "
            f"  WHERE u.geom IS NOT NULL AND ST_Intersects(h.{hg}, u.geom)"
            f")"
        )
        cursor.execute(sql, params)
    else:
        sql = (
            'WITH '
            + _hood_owner_union_cte_sql(union_sql)
            + f"SELECT ST_AsText(ST_UnaryUnion(ST_Collect(h.{hg}))) "
            f"FROM {_hq_quote_ident(hood_table)} h "
            'CROSS JOIN owner_u ou CROSS JOIN owner_area oa '
            f'WHERE ou.g IS NOT NULL AND NOT ST_IsEmpty(ou.g) '
            f'AND ST_Intersects(h.{hg}, ou.g) '
            f'AND (oa.total_m2 IS NULL OR oa.total_m2 = 0 OR '
            f'ST_Area(ST_Intersection(ou.g, ST_MakeValid(h.{hg}))::geography) / oa.total_m2 >= %s) '
        )
        cursor.execute(sql, params + [ratio])
    row = cursor.fetchone()
    wkt = row[0] if row else None
    if not wkt:
        return {'mode': 'empty', 'wkt': None}
    return {'mode': 'active', 'wkt': wkt}


def clear_hood_scope():
    _local.mode = 'skip'
    _local.wkt = None
    _local.bound = False


def bind_hood_scope(mode: str, wkt: Optional[str]):
    _local.mode = mode or 'skip'
    _local.wkt = wkt
    _local.bound = True


def resolve_and_bind_hood_scope(request):
    clear_hood_scope()
    user = getattr(request, 'user', None)
    if user is None or not user.is_authenticated:
        return
    try:
        from pass_viewer.models import ExternalUser
    except Exception:
        return
    row = ExternalUser.objects.filter(login=user.username).only('owner_legal_person_id').first()
    owner_id = row.owner_legal_person_id if row else None
    if owner_id is None:
        return

    if not _hood_spatial_scope_active():
        cache = request.session.get('hood_access_scope') or {}
        if (
            cache.get('owner') == str(owner_id)
            and cache.get('mode') == 'skip'
            and cache.get('v') == HOOD_SCOPE_SESSION_VERSION
        ):
            bind_hood_scope('skip', None)
            return
        bind_hood_scope('skip', None)
        request.session['hood_access_scope'] = {
            'owner': str(owner_id),
            'mode': 'skip',
            'wkt': None,
            'v': HOOD_SCOPE_SESSION_VERSION,
        }
        request.session.modified = True
        return

    cache = request.session.get('hood_access_scope') or {}
    if (
        cache.get('owner') == str(owner_id)
        and cache.get('mode')
        and cache.get('v') == HOOD_SCOPE_SESSION_VERSION
    ):
        bind_hood_scope(cache['mode'], cache.get('wkt'))
        return

    with connection.cursor() as cursor:
        scope = resolve_hood_scope_for_owner(cursor, owner_id)
    request.session['hood_access_scope'] = {
        'owner': str(owner_id),
        'mode': scope['mode'],
        'wkt': scope.get('wkt'),
        'v': HOOD_SCOPE_SESSION_VERSION,
    }
    request.session.modified = True
    bind_hood_scope(scope['mode'], scope.get('wkt'))


def get_hood_intersects_sql_suffix(qualified_geom_expr: str) -> Tuple[str, List[str]]:
    """
    Returns (sql_suffix, [params]) to AND into a WHERE clause, e.g.
      AND ST_Intersects(ST_SetSRID(ST_GeomFromText(%s), 4326), t.geom)
    """
    if not getattr(_local, 'bound', False):
        return '', []
    mode = getattr(_local, 'mode', 'skip')
    if mode == 'skip':
        return '', []
    if mode == 'empty':
        return ' AND FALSE', []
    wkt = getattr(_local, 'wkt', None)
    if not wkt:
        return ' AND FALSE', []
    return (
        f' AND ST_Intersects(ST_SetSRID(ST_GeomFromText(%s), 4326), {qualified_geom_expr})',
        [wkt],
    )


def get_hood_cte_prefix_sql() -> Tuple[str, List[str]]:
    """Leading ``WITH ha AS (...), `` fragment (comma included) and its params."""
    if not getattr(_local, 'bound', False):
        return '', []
    mode = getattr(_local, 'mode', 'skip')
    if mode == 'skip':
        return '', []
    if mode == 'empty':
        return (
            "WITH ha AS (SELECT ST_SetSRID(ST_GeomFromText('POLYGON EMPTY', 4326), 4326) AS g), ",
            [],
        )
    wkt = getattr(_local, 'wkt', None)
    if not wkt:
        return (
            "WITH ha AS (SELECT ST_SetSRID(ST_GeomFromText('POLYGON EMPTY', 4326), 4326) AS g), ",
            [],
        )
    return (
        'WITH ha AS (SELECT ST_MakeValid(ST_SetSRID(ST_GeomFromText(%s), 4326)) AS g), ',
        [wkt],
    )


def get_hood_intersects_ha_sql(qualified_geom_expr: str) -> str:
    """``AND ST_Intersects((SELECT g FROM ha), ...)`` when scope active/empty; empty string if skip."""
    if not getattr(_local, 'bound', False):
        return ''
    mode = getattr(_local, 'mode', 'skip')
    if mode == 'skip':
        return ''
    return f' AND ST_Intersects((SELECT g FROM ha), {qualified_geom_expr})'


def get_hood_cte_prefix_and_intersects_clause(qualified_geom_expr: str) -> Tuple[str, str, List[str]]:
    """
    Prefer this for complex queries: one CTE ``ha`` (allowed union) and one spatial AND.

    Returns (cte_prefix, intersects_and_sql, cte_params)
    - cte_prefix is '' or 'WITH ha AS (...), ' (includes trailing comma+space)
    - intersects_and_sql is '' or ' AND ST_Intersects((SELECT g FROM ha), <geom>)'
    - cte_params is [] or [wkt] for active mode
    """
    if not getattr(_local, 'bound', False):
        return '', '', []
    mode = getattr(_local, 'mode', 'skip')
    if mode == 'skip':
        return '', '', []
    if mode == 'empty':
        return (
            "WITH ha AS (SELECT ST_SetSRID(ST_GeomFromText('POLYGON EMPTY', 4326), 4326) AS g), ",
            f' AND ST_Intersects((SELECT g FROM ha), {qualified_geom_expr})',
            [],
        )
    wkt = getattr(_local, 'wkt', None)
    if not wkt:
        return (
            "WITH ha AS (SELECT ST_SetSRID(ST_GeomFromText('POLYGON EMPTY', 4326), 4326) AS g), ",
            f' AND ST_Intersects((SELECT g FROM ha), {qualified_geom_expr})',
            [],
        )
    return (
        'WITH ha AS (SELECT ST_MakeValid(ST_SetSRID(ST_GeomFromText(%s), 4326)) AS g), ',
        f' AND ST_Intersects((SELECT g FROM ha), {qualified_geom_expr})',
        [wkt],
    )


def geometry_intersects_allowed_hood(geometry_norm: dict) -> bool:
    """geometry_norm: GeoJSON geometry dict (not Feature/FC)."""
    if not getattr(_local, 'bound', False):
        return True
    mode = getattr(_local, 'mode', 'skip')
    if mode == 'skip':
        return True
    if mode == 'empty':
        return False
    wkt = getattr(_local, 'wkt', None)
    if not wkt:
        return False

    gj = json.dumps(geometry_norm, ensure_ascii=False)
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT ST_Intersects(
                ST_SetSRID(ST_GeomFromText(%s), 4326),
                ST_UnaryUnion(ST_MakeValid(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326)))
            )
            """,
            [wkt, gj],
        )
        row = cursor.fetchone()
    return bool(row and row[0])

"""
Import GeoJSON FeatureCollection into an existing table using PostgreSQL catalog introspection.

Feature properties keys should match column names (case-insensitive). The single geometry
column is detected via typname = geometry.
"""

from __future__ import annotations

import json
from typing import Any, Dict, List, Tuple

from django.db import connection, transaction


def import_geojson_dynamic(
    table_name: str,
    payload: dict,
    *,
    target_srid: int = 4326,
    append: bool = False,
    dry_run: bool = False,
) -> Tuple[int, int]:
    """
    Returns (imported_count, skipped_count).
    """
    features = payload.get('features')
    if payload.get('type') != 'FeatureCollection' or not isinstance(features, list):
        raise ValueError('GeoJSON must be a FeatureCollection with "features" array.')

    with connection.cursor() as cursor:
        cols = _fetch_columns(cursor, table_name)

    geom_cols = [c for c in cols if c['typname'] == 'geometry']
    if len(geom_cols) != 1:
        raise ValueError(
            f'Table "{table_name}" must have exactly one geometry column for dynamic import; '
            f'found {[c["name"] for c in geom_cols] or "none"}'
        )
    geom_col = geom_cols[0]['name']

    attr_cols = [c for c in cols if c['typname'] != 'geometry' and not c['skip_insert']]
    quoted_table = _quote_ident(table_name)
    quoted_attr = ', '.join(_quote_ident(c['name']) for c in attr_cols)
    quoted_geom = _quote_ident(geom_col)
    placeholders = ', '.join(['%s'] * len(attr_cols))
    geom_expr = f'ST_SetSRID(ST_GeomFromGeoJSON(%s::text), {target_srid})'

    if attr_cols:
        insert_sql = (
            f'INSERT INTO {quoted_table} ({quoted_attr}, {quoted_geom}) '
            f'VALUES ({placeholders}, {geom_expr})'
        )
    else:
        insert_sql = f'INSERT INTO {quoted_table} ({quoted_geom}) VALUES ({geom_expr})'

    imported = 0
    skipped = 0

    if dry_run:
        return len(features), 0

    with transaction.atomic():
        with connection.cursor() as cursor:
            if not append:
                cursor.execute(f'TRUNCATE TABLE {quoted_table} RESTART IDENTITY')

            for feature in features:
                if not isinstance(feature, dict):
                    skipped += 1
                    continue
                geometry = feature.get('geometry')
                if not isinstance(geometry, dict):
                    skipped += 1
                    continue
                props = feature.get('properties') or {}
                if not isinstance(props, dict):
                    props = {}

                row_vals = [_coerce_value(_match_property(props, c['name'])) for c in attr_cols]
                geom_json = json.dumps(geometry, ensure_ascii=False)
                if attr_cols:
                    cursor.execute(insert_sql, row_vals + [geom_json])
                else:
                    cursor.execute(insert_sql, [geom_json])
                imported += 1

    return imported, skipped


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def _fetch_columns(cursor, table_name: str) -> List[Dict[str, Any]]:
    cursor.execute(
        """
        SELECT
            a.attname AS name,
            t.typname AS typname,
            a.attgenerated AS generated,
            a.attidentity AS identity
        FROM pg_attribute a
        JOIN pg_class c ON a.attrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        JOIN pg_type t ON a.atttypid = t.oid
        WHERE n.nspname = 'public'
          AND c.relname = %s
          AND a.attnum > 0
          AND NOT a.attisdropped
        ORDER BY a.attnum
        """,
        [table_name],
    )
    rows = cursor.fetchall()
    result = []
    for name, typname, generated, identity in rows:
        skip = (generated or '') == 's'
        if (identity or '') == 'a':
            skip = True
        result.append({'name': name, 'typname': typname, 'skip_insert': skip})
    return result


def _match_property(props: Dict[str, Any], column_name: str) -> Any:
    if column_name in props:
        return props[column_name]
    lower_props = {str(k).lower(): k for k in props}
    key = column_name.lower()
    if key in lower_props:
        return props[lower_props[key]]
    return None


def _coerce_value(value: Any) -> Any:
    if value is None:
        return None
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    return value

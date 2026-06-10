"""
Import GeoJSON FeatureCollection into an existing table using PostgreSQL catalog introspection.

Feature properties keys should match column names (case-insensitive). The single geometry
column is detected via typname = geometry.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from django.db import connection, transaction
from psycopg2.extras import execute_values

from pass_viewer.data_import.geojson_property_aliases import match_geojson_property
from pass_viewer.data_import.geojson_stream import iter_geojson_features


def import_geojson_dynamic(
    table_name: str,
    payload: dict,
    *,
    target_srid: int = 4326,
    append: bool = False,
    dry_run: bool = False,
) -> tuple[int, int]:
    """
    Returns (imported_count, skipped_count).
    """
    features = payload.get("features")
    if payload.get("type") != "FeatureCollection" or not isinstance(features, list):
        raise ValueError('GeoJSON must be a FeatureCollection with "features" array.')

    plan = _build_import_plan(table_name, target_srid=target_srid)

    if dry_run:
        imported = skipped = 0
        for feature in features:
            if _feature_to_row(feature, plan) is None:
                skipped += 1
            else:
                imported += 1
        return imported, skipped

    with transaction.atomic():
        with connection.cursor() as cursor:
            if not append:
                cursor.execute(f"TRUNCATE TABLE {plan.quoted_table} RESTART IDENTITY")
            imported, skipped = _import_feature_rows(cursor, plan, features)

    return imported, skipped


def import_geojson_dynamic_from_path(
    table_name: str,
    path: str | Path,
    *,
    target_srid: int = 4326,
    append: bool = False,
    batch_size: int = 1000,
    dry_run: bool = False,
) -> tuple[int, int]:
    """
    Stream-import a GeoJSON file (ijson + batched INSERT).

    Returns (imported_count, skipped_count).
    """
    path = Path(path)
    plan = _build_import_plan(table_name, target_srid=target_srid)

    imported = 0
    skipped = 0
    batch: list[tuple[Any, ...]] = []

    def flush_batch(cursor) -> None:
        nonlocal batch, imported
        if not batch:
            return
        raw_cursor = getattr(cursor, "cursor", cursor)
        execute_values(
            raw_cursor,
            plan.insert_sql,
            batch,
            template=plan.row_template,
            page_size=len(batch),
        )
        imported += len(batch)
        batch = []

    if dry_run:
        for feature in iter_geojson_features(str(path)):
            if _feature_to_row(feature, plan) is None:
                skipped += 1
            else:
                imported += 1
        return imported, skipped

    with transaction.atomic():
        with connection.cursor() as cursor:
            if not append:
                cursor.execute(f"TRUNCATE TABLE {plan.quoted_table} RESTART IDENTITY")

            for feature in iter_geojson_features(str(path)):
                row = _feature_to_row(feature, plan)
                if row is None:
                    skipped += 1
                    continue
                batch.append(row)
                if len(batch) >= batch_size:
                    flush_batch(cursor)

            flush_batch(cursor)

    return imported, skipped


class _ImportPlan:
    __slots__ = (
        "table_name",
        "attr_cols",
        "quoted_table",
        "insert_sql",
        "row_template",
    )

    def __init__(
        self,
        *,
        table_name: str,
        attr_cols: list[dict[str, Any]],
        quoted_table: str,
        insert_sql: str,
        row_template: str,
    ) -> None:
        self.table_name = table_name
        self.attr_cols = attr_cols
        self.quoted_table = quoted_table
        self.insert_sql = insert_sql
        self.row_template = row_template


def _build_import_plan(table_name: str, *, target_srid: int) -> _ImportPlan:
    with connection.cursor() as cursor:
        cols = _fetch_columns(cursor, table_name)

    geom_cols = [c for c in cols if c["typname"] == "geometry"]
    if len(geom_cols) != 1:
        raise ValueError(
            f'Table "{table_name}" must have exactly one geometry column for dynamic import; '
            f"found {[c['name'] for c in geom_cols] or 'none'}"
        )
    geom_col = geom_cols[0]["name"]

    attr_cols = [c for c in cols if c["typname"] != "geometry" and not c["skip_insert"]]
    quoted_table = _quote_ident(table_name)
    quoted_attr = ", ".join(_quote_ident(c["name"]) for c in attr_cols)
    quoted_geom = _quote_ident(geom_col)
    geom_expr = f"ST_SetSRID(ST_GeomFromGeoJSON(%s::text), {target_srid})"

    if attr_cols:
        row_template = "(" + ", ".join(["%s"] * len(attr_cols) + [geom_expr]) + ")"
        insert_sql = f"INSERT INTO {quoted_table} ({quoted_attr}, {quoted_geom}) VALUES %s"
    else:
        row_template = f"({geom_expr})"
        insert_sql = f"INSERT INTO {quoted_table} ({quoted_geom}) VALUES %s"

    return _ImportPlan(
        table_name=table_name,
        attr_cols=attr_cols,
        quoted_table=quoted_table,
        insert_sql=insert_sql,
        row_template=row_template,
    )


def _feature_to_row(feature: dict, plan: _ImportPlan) -> tuple[Any, ...] | None:
    if not isinstance(feature, dict):
        return None
    geometry = feature.get("geometry")
    if not isinstance(geometry, dict):
        return None
    props = feature.get("properties") or {}
    if not isinstance(props, dict):
        props = {}

    row_vals = [_value_for_column(props, c, plan.table_name) for c in plan.attr_cols]
    geom_json = json.dumps(geometry, ensure_ascii=False)
    if plan.attr_cols:
        return tuple(row_vals + [geom_json])
    return (geom_json,)


def _import_feature_rows(cursor, plan: _ImportPlan, features) -> tuple[int, int]:
    imported = 0
    skipped = 0
    for feature in features:
        row = _feature_to_row(feature, plan)
        if row is None:
            skipped += 1
            continue
        raw_cursor = getattr(cursor, "cursor", cursor)
        execute_values(
            raw_cursor,
            plan.insert_sql,
            [row],
            template=plan.row_template,
            page_size=1,
        )
        imported += 1
    return imported, skipped


def _quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def _fetch_columns(cursor, table_name: str) -> list[dict[str, Any]]:
    cursor.execute(
        """
        SELECT
            a.attname AS name,
            t.typname AS typname,
            a.attgenerated AS generated,
            a.attidentity AS identity,
            pg_get_expr(d.adbin, d.adrelid) AS default_expr
        FROM pg_attribute a
        JOIN pg_class c ON a.attrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        JOIN pg_type t ON a.atttypid = t.oid
        LEFT JOIN pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
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
    for name, typname, generated, identity, default_expr in rows:
        skip = (generated or "") == "s"
        # 'a' = GENERATED ALWAYS, 'd' = GENERATED BY DEFAULT AS IDENTITY (e.g. ozn.id)
        if (identity or "") in ("a", "d"):
            skip = True
        # Serial / sequence-backed PK (e.g. pass_objects.ogc_fid).
        if default_expr and "nextval(" in default_expr:
            skip = True
        result.append({"name": name, "typname": typname, "skip_insert": skip})
    return result


def _value_for_column(props: dict[str, Any], col: dict[str, Any], table_name: str) -> Any:
    raw = match_geojson_property(props, col["name"], table_name=table_name)
    if raw is None and col["typname"] == "jsonb" and col["name"].lower() == "properties":
        # ozn (and similar): store the full Feature properties object in jsonb.
        return json.dumps(props, ensure_ascii=False)
    if raw is None and col["typname"] == "jsonb":
        return "{}"
    return _coerce_value(raw)


def _coerce_value(value: Any) -> Any:
    if value is None:
        return None
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    return value

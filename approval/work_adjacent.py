"""Load adjacent passport polygons for the approval map (YardPoly, OznPoly, OdhPoly)."""

from __future__ import annotations

import json
import logging

from django.conf import settings
from django.db import connections

from .qml_style_builder import load_manifest
from .work_geojson import _column_exists, _max_features, _style_fields_for_table
from .work_layers import (
    _quote_ident,
    work_geom_column,
    work_schema_name,
)

logger = logging.getLogger(__name__)

LAYER_KEY_APPROVAL = "adjacent_approval"
LAYER_KEY_OBJECTS = "adjacent_objects"


def adjacent_poly_tables() -> list[str]:
    tables = getattr(settings, "APPROVAL_ADJACENT_POLY_TABLES", None)
    if tables:
        return list(tables)
    return ["YardPoly", "OznPoly", "OdhPoly"]


def work_rootid_column() -> str:
    return getattr(settings, "APPROVAL_WORK_ROOTID_COLUMN", "RootId")


def adjacent_root_ids(
    n_root: list[str] | str | None,
    v_root: list[str] | None,
) -> tuple[list[str], list[str]]:
    n_values: list[str] = []
    if isinstance(n_root, str):
        normalized = n_root.strip()
        if normalized:
            n_values.append(normalized)
    else:
        for item in n_root or []:
            text = str(item).strip()
            if text and text not in n_values:
                n_values.append(text)

    v_values: list[str] = []
    n_set = set(n_values)
    for item in v_root or []:
        text = str(item).strip()
        if not text or text in n_set:
            continue
        if text not in v_values:
            v_values.append(text)

    return n_values, v_values


def _resolve_rootid_column(cursor, schema: str, table_name: str) -> str | None:
    preferred = work_rootid_column()
    if _column_exists(cursor, schema, table_name, preferred):
        return preferred
    for candidate in ("RootId", "rootid", "Rootid"):
        if candidate != preferred and _column_exists(cursor, schema, table_name, candidate):
            return candidate
    return None


def _adjacent_property_pairs(
    cursor,
    schema: str,
    table_name: str,
    layer_key: str,
    style_fields: list[str],
    rootid_col: str,
) -> list[str]:
    pairs = [
        f"'layerKey', '{layer_key}'",
        f"'sourceTable', '{table_name}'",
        "'fid', t.fid",
        f"'RootId', t.{_quote_ident(rootid_col)}::text",
    ]
    if _column_exists(cursor, schema, table_name, "Name"):
        pairs.append(f"'Name', t.{_quote_ident('Name')}::text")
    for field in style_fields:
        if field in {"fid", "RootId", "Name"}:
            continue
        if not _column_exists(cursor, schema, table_name, field):
            continue
        pairs.append(f"'{field}', t.{_quote_ident(field)}::text")
    return pairs


def _adjacent_select_sql(
    table_name: str,
    layer_key: str,
    style_fields: list[str],
    cursor,
    *,
    single_root: bool,
) -> str | None:
    schema = work_schema_name()
    geom_col = work_geom_column()
    rootid_col = _resolve_rootid_column(cursor, schema, table_name)
    if not rootid_col:
        return None

    quoted_table = _quote_ident(table_name)
    quoted_schema = _quote_ident(schema)
    quoted_geom = _quote_ident(geom_col)
    quoted_rootid = _quote_ident(rootid_col)
    props_sql = ", ".join(
        _adjacent_property_pairs(cursor, schema, table_name, layer_key, style_fields, rootid_col)
    )

    if single_root:
        root_filter = f"t.{quoted_rootid}::text = %s"
    else:
        root_filter = f"t.{quoted_rootid}::text = ANY(%s::text[])"

    return f"""
        SELECT json_build_object(
            'type', 'Feature',
            'geometry', ST_AsGeoJSON(ST_Transform(t.{quoted_geom}, 4326))::json,
            'properties', json_build_object(
                {props_sql}
            )
        )
        FROM {quoted_schema}.{quoted_table} t
        WHERE {root_filter}
          AND t.{quoted_geom} IS NOT NULL
          AND NOT ST_IsEmpty(t.{quoted_geom})
    """


def _count_adjacent_in_table(
    cursor,
    table_name: str,
    root_ids: list[str],
    *,
    single_root: bool,
) -> int:
    if not root_ids:
        return 0

    schema = work_schema_name()
    geom_col = work_geom_column()
    rootid_col = _resolve_rootid_column(cursor, schema, table_name)
    if not rootid_col:
        return 0

    quoted_table = _quote_ident(table_name)
    quoted_schema = _quote_ident(schema)
    quoted_geom = _quote_ident(geom_col)
    quoted_rootid = _quote_ident(rootid_col)

    if single_root:
        root_filter = f"t.{quoted_rootid}::text = %s"
        params: list = [root_ids[0]]
    else:
        root_filter = f"t.{quoted_rootid}::text = ANY(%s::text[])"
        params = [root_ids]

    cursor.execute(
        f"""
        SELECT COUNT(*)
        FROM {quoted_schema}.{quoted_table} t
        WHERE {root_filter}
          AND t.{quoted_geom} IS NOT NULL
          AND NOT ST_IsEmpty(t.{quoted_geom})
        """,
        params,
    )
    return int(cursor.fetchone()[0] or 0)


def count_adjacent_features(n_root: list[str] | str | None, v_root: list[str] | None) -> tuple[int, int]:
    n_values, v_values = adjacent_root_ids(n_root, v_root)
    if not n_values and not v_values:
        return 0, 0

    n_count = 0
    v_count = 0
    tables = adjacent_poly_tables()

    try:
        with connections["qgis"].cursor() as cursor:
            if n_values:
                for table_name in tables:
                    n_count += _count_adjacent_in_table(cursor, table_name, n_values, single_root=False)
            if v_values:
                for table_name in tables:
                    v_count += _count_adjacent_in_table(cursor, table_name, v_values, single_root=False)
    except Exception:
        logger.exception("count_adjacent_features: qgis query failed")
        return 0, 0

    return n_count, v_count


def _append_features(
    cursor,
    features: list[dict],
    table_name: str,
    layer_key: str,
    root_ids: list[str],
    *,
    single_root: bool,
    manifest: dict,
    max_features: int,
) -> None:
    if not root_ids or len(features) >= max_features:
        return

    style_fields = _style_fields_for_table(table_name, manifest)
    sql = _adjacent_select_sql(
        table_name,
        layer_key,
        style_fields,
        cursor,
        single_root=single_root,
    )
    if not sql:
        return

    params = [root_ids[0]] if single_root else [root_ids]
    cursor.execute(sql, params)
    for row in cursor.fetchall():
        if not row or not row[0]:
            continue
        payload = row[0]
        if isinstance(payload, str):
            payload = json.loads(payload)
        if isinstance(payload, dict):
            features.append(payload)
        if len(features) >= max_features:
            break


def build_adjacent_features(
    n_root: list[str] | str | None,
    v_root: list[str] | None,
) -> list[dict]:
    n_values, v_values = adjacent_root_ids(n_root, v_root)
    if not n_values and not v_values:
        return []

    max_features = _max_features()
    features: list[dict] = []
    manifest = load_manifest()
    tables = adjacent_poly_tables()

    try:
        with connections["qgis"].cursor() as cursor:
            for table_name in tables:
                if len(features) >= max_features:
                    break
                if n_values:
                    _append_features(
                        cursor,
                        features,
                        table_name,
                        LAYER_KEY_APPROVAL,
                        n_values,
                        single_root=False,
                        manifest=manifest,
                        max_features=max_features,
                    )
                if len(features) >= max_features:
                    break
                if v_values:
                    _append_features(
                        cursor,
                        features,
                        table_name,
                        LAYER_KEY_OBJECTS,
                        v_values,
                        single_root=False,
                        manifest=manifest,
                        max_features=max_features,
                    )
    except Exception:
        logger.exception("build_adjacent_features: qgis query failed")
        return []

    return features[:max_features]

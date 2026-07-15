"""Load adjacent passport polygons for the approval map (YardPoly, OznPoly, OdhPoly)."""

from __future__ import annotations

import json
import logging
from typing import TYPE_CHECKING

from django.conf import settings
from django.db import connections

from .qml_style_builder import load_manifest
from .work_geojson import _column_exists, _max_features, _style_fields_for_table
from .work_layers import (
    _quote_ident,
    work_geom_column,
    work_schema_name,
)

if TYPE_CHECKING:
    from .models import Approve

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


def adjacent_schema_name() -> str:
    """Fallback schema for roots not found in work (default: master)."""
    return getattr(settings, "APPROVAL_ADJACENT_SCHEMA", "master")


def adjacent_primary_schema_name() -> str:
    """Preferred schema for adjacent root polygons."""
    return work_schema_name()


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


def collect_adjacent_roots(approve: Approve) -> tuple[list[str], list[str]]:
    """Merge n_root from approve and event cases; derive v_roots excluding n_roots."""
    from .models import Case

    n_values: list[str] = []
    for item in approve.n_root or []:
        text = str(item).strip()
        if text and text not in n_values:
            n_values.append(text)

    case_roots = (
        Case.objects.filter(approve=approve, is_primary=False)
        .exclude(n_root__isnull=True)
        .exclude(n_root="")
        .values_list("n_root", flat=True)
    )
    for item in case_roots:
        text = str(item).strip()
        if text and text not in n_values:
            n_values.append(text)

    return adjacent_root_ids(n_values, approve.v_root)


def _adjacent_layer_for_root(
    root_id: str,
    *,
    kind: str,
    active_n_root: str | None = None,
) -> str:
    active = (active_n_root or "").strip()
    if not active:
        if kind == "n":
            return LAYER_KEY_APPROVAL
        return LAYER_KEY_OBJECTS
    if root_id == active:
        return LAYER_KEY_APPROVAL
    return LAYER_KEY_OBJECTS


def _finalize_adjacent_feature(
    feature: dict,
    n_set: set[str],
    *,
    active_n_root: str | None = None,
    source_schema: str | None = None,
) -> dict:
    props = feature.setdefault("properties", {})
    root_id = str(props.get("RootId", "")).strip()
    kind = "n" if root_id in n_set else "v"
    props["adjacentRootKind"] = kind
    props["layerKey"] = _adjacent_layer_for_root(root_id, kind=kind, active_n_root=active_n_root)
    if source_schema:
        props["sourceSchema"] = source_schema
    return feature


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
        f"'sourceSchema', '{schema}'",
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
    schema: str | None = None,
) -> str | None:
    schema_name = schema or adjacent_schema_name()
    geom_col = work_geom_column()
    rootid_col = _resolve_rootid_column(cursor, schema_name, table_name)
    if not rootid_col:
        return None

    quoted_table = _quote_ident(table_name)
    quoted_schema = _quote_ident(schema_name)
    quoted_geom = _quote_ident(geom_col)
    quoted_rootid = _quote_ident(rootid_col)
    props_sql = ", ".join(
        _adjacent_property_pairs(cursor, schema_name, table_name, layer_key, style_fields, rootid_col)
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
    schema: str,
) -> int:
    if not root_ids:
        return 0

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


def _found_root_ids_in_schema(
    cursor,
    schema: str,
    root_ids: list[str],
    tables: list[str],
) -> set[str]:
    found: set[str] = set()
    if not root_ids:
        return found

    geom_col = work_geom_column()
    quoted_geom = _quote_ident(geom_col)
    quoted_schema = _quote_ident(schema)

    for table_name in tables:
        rootid_col = _resolve_rootid_column(cursor, schema, table_name)
        if not rootid_col:
            continue
        quoted_table = _quote_ident(table_name)
        quoted_rootid = _quote_ident(rootid_col)
        cursor.execute(
            f"""
            SELECT DISTINCT t.{quoted_rootid}::text
            FROM {quoted_schema}.{quoted_table} t
            WHERE t.{quoted_rootid}::text = ANY(%s::text[])
              AND t.{quoted_geom} IS NOT NULL
              AND NOT ST_IsEmpty(t.{quoted_geom})
            """,
            [root_ids],
        )
        for row in cursor.fetchall():
            if row and row[0]:
                found.add(str(row[0]).strip())
    return found


def count_adjacent_features(n_root: list[str] | str | None, v_root: list[str] | None) -> tuple[int, int]:
    n_values, v_values = adjacent_root_ids(n_root, v_root)
    if not n_values and not v_values:
        return 0, 0

    n_count = 0
    v_count = 0
    tables = adjacent_poly_tables()
    primary_schema = adjacent_primary_schema_name()
    fallback_schema = adjacent_schema_name()

    try:
        with connections["qgis"].cursor() as cursor:
            all_roots = list(dict.fromkeys([*n_values, *v_values]))
            found_in_work = _found_root_ids_in_schema(cursor, primary_schema, all_roots, tables)
            missing = [root for root in all_roots if root not in found_in_work]

            if n_values:
                n_work = [root for root in n_values if root in found_in_work]
                n_master = [root for root in n_values if root in missing]
                for table_name in tables:
                    if n_work:
                        n_count += _count_adjacent_in_table(
                            cursor, table_name, n_work, single_root=False, schema=primary_schema
                        )
                    if n_master:
                        n_count += _count_adjacent_in_table(
                            cursor, table_name, n_master, single_root=False, schema=fallback_schema
                        )
            if v_values:
                v_work = [root for root in v_values if root in found_in_work]
                v_master = [root for root in v_values if root in missing]
                for table_name in tables:
                    if v_work:
                        v_count += _count_adjacent_in_table(
                            cursor, table_name, v_work, single_root=False, schema=primary_schema
                        )
                    if v_master:
                        v_count += _count_adjacent_in_table(
                            cursor, table_name, v_master, single_root=False, schema=fallback_schema
                        )
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
    schema: str,
    n_set: set[str] | None = None,
    active_n_root: str | None = None,
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
        schema=schema,
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
            if n_set is not None:
                _finalize_adjacent_feature(
                    payload,
                    n_set,
                    active_n_root=active_n_root,
                    source_schema=schema,
                )
            features.append(payload)
        if len(features) >= max_features:
            break


def format_adjacent_roots_message(n_roots: list[str], v_roots: list[str]) -> str:
    roots: list[str] = []
    for root_id in [*n_roots, *v_roots]:
        if root_id not in roots:
            roots.append(root_id)
    roots_text = ", ".join(roots) if roots else "—"
    return (
        "Смежные паспорта не найдены в work/master (YardPoly/OznPoly/OdhPoly) "
        f"для RootId: {roots_text}."
    )


def build_adjacent_features(
    n_root: list[str] | str | None,
    v_root: list[str] | None,
    *,
    active_n_root: str | None = None,
) -> tuple[list[dict], str | None]:
    n_values, v_values = adjacent_root_ids(n_root, v_root)
    if not n_values and not v_values:
        return [], None

    all_roots: list[str] = []
    for root_id in [*n_values, *v_values]:
        if root_id not in all_roots:
            all_roots.append(root_id)

    max_features = _max_features()
    features: list[dict] = []
    manifest = load_manifest()
    tables = adjacent_poly_tables()
    n_set = set(n_values)
    primary_schema = adjacent_primary_schema_name()
    fallback_schema = adjacent_schema_name()

    try:
        with connections["qgis"].cursor() as cursor:
            found_in_work = _found_root_ids_in_schema(cursor, primary_schema, all_roots, tables)
            work_roots = [root for root in all_roots if root in found_in_work]
            master_roots = [root for root in all_roots if root not in found_in_work]

            for table_name in tables:
                if len(features) >= max_features:
                    break
                if work_roots:
                    _append_features(
                        cursor,
                        features,
                        table_name,
                        LAYER_KEY_OBJECTS,
                        work_roots,
                        single_root=False,
                        manifest=manifest,
                        max_features=max_features,
                        schema=primary_schema,
                        n_set=n_set,
                        active_n_root=active_n_root,
                    )
            for table_name in tables:
                if len(features) >= max_features:
                    break
                if master_roots:
                    _append_features(
                        cursor,
                        features,
                        table_name,
                        LAYER_KEY_OBJECTS,
                        master_roots,
                        single_root=False,
                        manifest=manifest,
                        max_features=max_features,
                        schema=fallback_schema,
                        n_set=n_set,
                        active_n_root=active_n_root,
                    )
    except Exception:
        logger.exception("build_adjacent_features: qgis query failed")
        return [], "Не удалось загрузить смежные паспорта из mggt_asu."

    return features[:max_features], None

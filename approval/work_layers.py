"""Registry of mggt_asu.work tables usable as approval map layers."""

from __future__ import annotations

import logging

from django.conf import settings
from django.db import connections

from .qml_style_builder import default_swatch_style, load_manifest
from .work_layer_labels import work_layer_label

logger = logging.getLogger(__name__)

_WORK_TABLES_CACHE: list[str] | None = None
_DEFAULT_HIDDEN_LAYERS = frozenset({"task", "YardPoly"})


def _quote_ident(identifier: str) -> str:
    return '"' + str(identifier).replace('"', '""') + '"'


def work_schema_name() -> str:
    return getattr(settings, "APPROVAL_WORK_SCHEMA", "work")


def work_geom_column() -> str:
    return getattr(settings, "APPROVAL_WORK_GEOM_COLUMN", "Geometry")


def work_taskguid_column() -> str:
    return getattr(settings, "APPROVAL_WORK_TASKGUID_COLUMN", "TaskGUID")


def work_source_srid() -> int:
    return int(getattr(settings, "APPROVAL_WORK_SOURCE_SRID", 980077))


def list_work_layer_tables(*, force_refresh: bool = False) -> list[str]:
    global _WORK_TABLES_CACHE
    if _WORK_TABLES_CACHE is not None and not force_refresh:
        return list(_WORK_TABLES_CACHE)

    schema = work_schema_name()
    geom_col = work_geom_column()
    task_col = work_taskguid_column()

    try:
        with connections["qgis"].cursor() as cursor:
            cursor.execute(
                """
                SELECT t.table_name
                FROM information_schema.tables t
                WHERE t.table_schema = %s
                  AND t.table_type = 'BASE TABLE'
                  AND EXISTS (
                      SELECT 1
                      FROM information_schema.columns c
                      WHERE c.table_schema = t.table_schema
                        AND c.table_name = t.table_name
                        AND c.column_name = %s
                  )
                  AND EXISTS (
                      SELECT 1
                      FROM geometry_columns g
                      WHERE g.f_table_schema = t.table_schema
                        AND g.f_table_name = t.table_name
                        AND g.f_geometry_column = %s
                  )
                ORDER BY t.table_name
                """,
                [schema, task_col, geom_col],
            )
            tables = [row[0] for row in cursor.fetchall()]
    except Exception:
        logger.exception("list_work_layer_tables: failed to introspect qgis work schema")
        return []

    _WORK_TABLES_CACHE = tables
    return list(tables)


def count_features_by_table(task_guids: list[str]) -> dict[str, int]:
    if not task_guids:
        return {}

    schema = work_schema_name()
    task_col = work_taskguid_column()
    geom_col = work_geom_column()
    counts: dict[str, int] = {}

    try:
        with connections["qgis"].cursor() as cursor:
            for table in list_work_layer_tables():
                cursor.execute(
                    f"""
                    SELECT COUNT(*)
                    FROM {_quote_ident(schema)}.{_quote_ident(table)} t
                    WHERE t.{_quote_ident(task_col)} = ANY(%s::uuid[])
                      AND t.{_quote_ident(geom_col)} IS NOT NULL
                      AND NOT ST_IsEmpty(t.{_quote_ident(geom_col)})
                    """,
                    [task_guids],
                )
                count = int(cursor.fetchone()[0] or 0)
                if count:
                    counts[table] = count
    except Exception:
        logger.exception("count_features_by_table: qgis query failed")
        return {}

    return counts


def build_layer_groups(feature_counts_by_table: dict[str, int]) -> list[dict]:
    manifest = load_manifest()
    layers = []
    for table_name in sorted(feature_counts_by_table):
        count = feature_counts_by_table[table_name]
        if count <= 0:
            continue
        swatch_style = default_swatch_style(table_name, manifest)
        layers.append(
            {
                "key": table_name,
                "name": work_layer_label(table_name),
                "count": count,
                "swatch": "work",
                "swatch_style": swatch_style,
                "checked": table_name not in _DEFAULT_HIDDEN_LAYERS,
            }
        )

    if not layers:
        return []

    return [
        {
            "key": "work",
            "title": "Объекты съёмки (work)",
            "checked": True,
            "layers": layers,
        }
    ]

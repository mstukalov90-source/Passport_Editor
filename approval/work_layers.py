"""Registry of mggt_asu.work tables usable as approval map layers."""

from __future__ import annotations

import logging

from django.conf import settings
from django.db import connections

from .qml_style_builder import load_manifest
from .work_layer_labels import work_layer_label

logger = logging.getLogger(__name__)

_WORK_TABLES_CACHE: list[str] | None = None
_DEFAULT_HIDDEN_LAYERS = frozenset({"task", "YardPoly"})
_GEOMETRY_TIER = {"point": 0, "line": 1, "polygon": 2}
_BOTTOM_POLYGON_TABLES = frozenset({"OdhPoly", "OznPoly", "YardPoly"})


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


def work_owner_column() -> str:
    return getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")


_OWNER_LOOKUP_PRIORITY_TABLES = ("YardPoly", "OznPoly", "OdhPoly")


def _column_exists(cursor, schema: str, table_name: str, column_name: str) -> bool:
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND column_name = %s
        LIMIT 1
        """,
        [schema, table_name, column_name],
    )
    return cursor.fetchone() is not None


def _owner_lookup_table_order() -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for table in _OWNER_LOOKUP_PRIORITY_TABLES:
        if table not in seen:
            seen.add(table)
            ordered.append(table)
    for table in list_work_layer_tables():
        if table not in seen:
            seen.add(table)
            ordered.append(table)
    return ordered


def resolve_task_owner_legal_person_id(task_guid: str) -> str:
    """Return OwnerLegalPersonId for a work-layer object with the given TaskGUID."""
    task_guid_text = str(task_guid).strip()
    if not task_guid_text:
        raise ValueError("Некорректный TaskGUID для поиска балансодержателя.")

    schema = work_schema_name()
    task_col = work_taskguid_column()
    owner_col = work_owner_column()

    try:
        with connections["qgis"].cursor() as cursor:
            for table in _owner_lookup_table_order():
                if not _column_exists(cursor, schema, table, task_col):
                    continue
                if not _column_exists(cursor, schema, table, owner_col):
                    continue
                cursor.execute(
                    f"""
                    SELECT DISTINCT t.{_quote_ident(owner_col)}::text
                    FROM {_quote_ident(schema)}.{_quote_ident(table)} t
                    WHERE t.{_quote_ident(task_col)} = %s::uuid
                      AND t.{_quote_ident(owner_col)} IS NOT NULL
                    LIMIT 1
                    """,
                    [task_guid_text],
                )
                row = cursor.fetchone()
                if row and row[0]:
                    return str(row[0]).strip()
    except ValueError:
        raise
    except Exception as exc:
        logger.exception("resolve_task_owner_legal_person_id: qgis query failed")
        raise ValueError("Не удалось определить балансодержателя по TaskGUID.") from exc

    raise ValueError(
        f"Не найден OwnerLegalPersonId для TaskGUID {task_guid_text} в mggt_asu (схема {schema})."
    )


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


def _layer_panel_sort_key(layer: dict) -> tuple:
    geometry = layer.get("geometry", "polygon")
    tier = _GEOMETRY_TIER.get(geometry, 2)
    bottom = 1 if layer.get("key") in _BOTTOM_POLYGON_TABLES else 0
    return (tier, bottom, layer.get("name", ""))


def _layer_stack_sort_key(layer: dict) -> tuple:
    """Sort key for map draw order (bottom → top)."""
    geometry = layer.get("geometry", "polygon")
    if geometry == "polygon":
        bottom = 0 if layer.get("key") in _BOTTOM_POLYGON_TABLES else 1
        return (0, bottom, layer.get("name", ""))
    if geometry == "line":
        return (1, 0, layer.get("name", ""))
    if geometry == "point":
        return (2, 0, layer.get("name", ""))
    return (0, 1, layer.get("name", ""))


def layer_stack_order(layer_groups: list[dict]) -> list[str]:
    layers: list[dict] = []
    for group in layer_groups:
        layers.extend(group.get("layers", []))
    layers.sort(key=_layer_stack_sort_key)
    return [layer["key"] for layer in layers]


def build_layer_groups(feature_counts_by_table: dict[str, int]) -> list[dict]:
    manifest = load_manifest()
    layers = []
    for table_name in sorted(feature_counts_by_table):
        count = feature_counts_by_table[table_name]
        if count <= 0:
            continue
        table_def = manifest.get("tables", {}).get(table_name, {})
        geometry = table_def.get("geometry", "polygon")
        layers.append(
            {
                "key": table_name,
                "name": work_layer_label(table_name),
                "count": count,
                "geometry": geometry,
                "checked": table_name not in _DEFAULT_HIDDEN_LAYERS,
            }
        )

    if not layers:
        return []

    layers.sort(key=_layer_panel_sort_key)

    return [
        {
            "key": "work",
            "title": "Объект согласования",
            "checked": True,
            "layers": layers,
        }
    ]


def build_adjacent_layer_groups(n_count: int, v_count: int) -> list[dict]:
    layers = []
    if n_count > 0:
        layers.append(
            {
                "key": "adjacent_approval",
                "name": "Смежный объект для согласования",
                "count": n_count,
                "geometry": "polygon",
                "checked": True,
            }
        )
    if v_count > 0:
        layers.append(
            {
                "key": "adjacent_objects",
                "name": "Смежные объекты",
                "count": v_count,
                "geometry": "polygon",
                "checked": True,
            }
        )
    if not layers:
        return []
    return [
        {
            "key": "adjacent",
            "title": "Смежные паспорта",
            "checked": True,
            "layers": layers,
        }
    ]

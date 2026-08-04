"""Registry of mggt_asu.work / topopassport tables usable as approval map layers."""

from __future__ import annotations

import json
import logging

from django.conf import settings
from django.db import connections

from .qml_style_builder import load_manifest
from .work_layer_labels import work_layer_label

logger = logging.getLogger(__name__)

_SCHEMA_TABLES_CACHE: dict[str, list[str]] = {}
_DEFAULT_HIDDEN_LAYERS = frozenset({"YardPoly", "topopoint"})
PANEL_EXCLUDED_LAYERS = frozenset({"task", "BasePoly"})
_GEOMETRY_TIER = {"point": 0, "line": 1, "polygon": 2}
_BOTTOM_POLYGON_TABLES = frozenset({"OdhPoly", "OznPoly", "YardPoly"})
TOPO_LAYER_KEY_PREFIX = "topo:"
# Keep in sync with approval.work_geojson._TOPO_CLIP_TO_WORK_TABLES
_TOPO_CLIP_TO_WORK_TABLES = frozenset({"topotext"})
TOPOLINES_TABLE = "topolines"
TOPOLINES_EXCLUDED_LAYER = "Границы заказа"


def _quote_ident(identifier: str) -> str:
    return '"' + str(identifier).replace('"', '""') + '"'


def work_schema_name() -> str:
    return getattr(settings, "APPROVAL_WORK_SCHEMA", "work")


def topopassport_schema_name() -> str:
    return getattr(settings, "APPROVAL_TOPOPASSPORT_SCHEMA", "topopassport")


def work_geom_column() -> str:
    return getattr(settings, "APPROVAL_WORK_GEOM_COLUMN", "Geometry")


def work_taskguid_column() -> str:
    return getattr(settings, "APPROVAL_WORK_TASKGUID_COLUMN", "TaskGUID")


def topopassport_guid_column() -> str:
    return getattr(settings, "APPROVAL_TOPOPASSPORT_GUID_COLUMN", "guid")


def schema_taskguid_column(schema: str) -> str:
    """GUID column for a mggt_asu map schema (work uses TaskGUID; topopassport uses guid)."""
    if str(schema or "").strip() == topopassport_schema_name():
        return topopassport_guid_column()
    return work_taskguid_column()


def work_source_srid() -> int:
    return int(getattr(settings, "APPROVAL_WORK_SOURCE_SRID", 980077))


def work_source_proj4_sql() -> str:
    """
    SQL expression returning proj4text for APPROVAL_WORK_SOURCE_SRID.

    PostGIS 3 / PROJ 6+ prefers spatial_ref_sys.srtext over proj4text when
    transforming by SRID. For 980077 those disagree (~5 m). QGIS uses proj4,
    so we force the same definition via an explicit proj4 pipeline.
    """
    srid = work_source_srid()
    return f"(SELECT proj4text FROM public.spatial_ref_sys WHERE srid = {int(srid)})"


_WGS84_PROJ4 = "+proj=longlat +datum=WGS84 +no_defs"


def geom_to_wgs84_sql(geom_expr: str) -> str:
    """Reproject MSC-77 geometry to WGS-84 using spatial_ref_sys.proj4text for source SRID."""
    return (
        f"ST_Transform({geom_expr}, {work_source_proj4_sql()}, '{_WGS84_PROJ4}')"
    )


def wgs84_to_work_sql(geojson_param: str = "%s") -> str:
    """Reproject WGS-84 GeoJSON param to work MSC-77 via spatial_ref_sys.proj4text.

    ST_Transform with explicit proj4 strings leaves SRID 0; tag the result with
    work_source_srid() so ST_Intersects matches layer geometries (980077).
    """
    return (
        f"ST_SetSRID("
        f"ST_Transform("
        f"ST_SetSRID(ST_GeomFromGeoJSON({geojson_param}), 4326), "
        f"'{_WGS84_PROJ4}', "
        f"{work_source_proj4_sql()}"
        f"), "
        f"{work_source_srid()})"
    )


def work_owner_column() -> str:
    return getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")


def topo_layer_key(table_name: str) -> str:
    return f"{TOPO_LAYER_KEY_PREFIX}{table_name}"


def table_name_from_topo_layer_key(layer_key: str) -> str | None:
    key = str(layer_key or "")
    if not key.startswith(TOPO_LAYER_KEY_PREFIX):
        return None
    return key[len(TOPO_LAYER_KEY_PREFIX) :] or None


def style_table_name_for_layer_key(layer_key: str) -> str:
    topo_table = table_name_from_topo_layer_key(layer_key)
    return topo_table if topo_table else str(layer_key or "")


_OWNER_LOOKUP_PRIORITY_TABLES = ("YardPoly", "OznPoly", "OdhPoly")
_SURVEY_TITLE_TABLES = ("YardPoly", "OznPoly", "OdhPoly")
_DEFAULT_SURVEY_TITLE = "Согласование границ ОГХ"
_SURVEY_NAME_COLUMN = "Name"
_SURVEY_BRID_COLUMN = "PassBrId"


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


def topolines_excluded_layer_sql(
    cursor,
    schema: str,
    table_name: str,
    *,
    alias: str = "t",
) -> str:
    """Exclude order-boundary lines from topolines map load and counts."""
    if str(table_name or "") != TOPOLINES_TABLE:
        return ""
    if not _column_exists(cursor, schema, table_name, "layer"):
        return ""
    excluded = TOPOLINES_EXCLUDED_LAYER.replace("'", "''")
    return (
        f" AND COALESCE({alias}.{_quote_ident('layer')}, '') <> '{excluded}'"
    )


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


def format_survey_page_title(name: str | None, brid: str | None) -> str:
    """Build approval page title from work-layer Name and PassBrId."""
    name_text = str(name or "").strip()
    brid_text = str(brid or "").strip()
    if name_text and brid_text:
        return f"{_DEFAULT_SURVEY_TITLE} {name_text} по заявке {brid_text}."
    return _DEFAULT_SURVEY_TITLE


def lookup_task_survey_fields(task_guid: str) -> tuple[str, str]:
    """
    Return (Name, PassBrId) from work YardPoly → OznPoly → OdhPoly for TaskGUID.

    Either value may be empty when no matching row is found or the query fails.
    Prefers the first table row that has a non-empty Name (and uses its PassBrId).
    """
    task_guid_text = str(task_guid or "").strip()
    if not task_guid_text:
        return "", ""

    schema = work_schema_name()
    task_col = work_taskguid_column()
    name_col = _SURVEY_NAME_COLUMN
    brid_col = _SURVEY_BRID_COLUMN

    try:
        with connections["qgis"].cursor() as cursor:
            for table in _SURVEY_TITLE_TABLES:
                if not _column_exists(cursor, schema, table, task_col):
                    continue
                if not _column_exists(cursor, schema, table, name_col):
                    continue
                if not _column_exists(cursor, schema, table, brid_col):
                    continue
                cursor.execute(
                    f"""
                    SELECT t.{_quote_ident(name_col)}::text,
                           t.{_quote_ident(brid_col)}::text
                    FROM {_quote_ident(schema)}.{_quote_ident(table)} t
                    WHERE t.{_quote_ident(task_col)} = %s::uuid
                    LIMIT 1
                    """,
                    [task_guid_text],
                )
                row = cursor.fetchone()
                if not row:
                    continue
                name_text = str(row[0] or "").strip()
                brid_text = str(row[1] or "").strip()
                if name_text and brid_text:
                    return name_text, brid_text
                if name_text or brid_text:
                    return name_text, brid_text
    except Exception:
        logger.exception("lookup_task_survey_fields: qgis query failed")
        return "", ""

    return "", ""


def resolve_task_survey_name(task_guid: str) -> str:
    """Return work-layer Name for TaskGUID, or empty string when not found."""
    return lookup_task_survey_fields(task_guid)[0]


def resolve_task_survey_title(task_guid: str) -> str:
    """
    Return landing page title from work YardPoly → OznPoly → OdhPoly for TaskGUID.

    Uses the first table that has a matching row with both Name and PassBrId.
    Falls back to «Согласование границ ОГХ» when nothing is found or the query fails.
    """
    name_text, brid_text = lookup_task_survey_fields(task_guid)
    return format_survey_page_title(name_text, brid_text)


def list_schema_layer_tables(schema: str, *, force_refresh: bool = False) -> list[str]:
    schema_name = str(schema or "").strip()
    if not schema_name:
        return []

    if schema_name in _SCHEMA_TABLES_CACHE and not force_refresh:
        return list(_SCHEMA_TABLES_CACHE[schema_name])

    geom_col = work_geom_column()
    task_col = schema_taskguid_column(schema_name)

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
                [schema_name, task_col, geom_col],
            )
            tables = [row[0] for row in cursor.fetchall()]
    except Exception:
        logger.exception(
            "list_schema_layer_tables: failed to introspect qgis schema %s",
            schema_name,
        )
        return []

    _SCHEMA_TABLES_CACHE[schema_name] = tables
    return list(tables)


def list_work_layer_tables(*, force_refresh: bool = False) -> list[str]:
    return list_schema_layer_tables(work_schema_name(), force_refresh=force_refresh)


def list_topopassport_layer_tables(*, force_refresh: bool = False) -> list[str]:
    return list_schema_layer_tables(topopassport_schema_name(), force_refresh=force_refresh)


# topotext labels clipped to survey polygon (same rule as work_geojson).
def count_features_by_table(
    task_guids: list[str],
    *,
    schema: str | None = None,
    tables: list[str] | None = None,
) -> dict[str, int]:
    if not task_guids:
        return {}

    schema_name = schema or work_schema_name()
    task_col = schema_taskguid_column(schema_name)
    geom_col = work_geom_column()
    if tables is not None:
        target_tables = tables
    elif schema_name == work_schema_name():
        target_tables = list_work_layer_tables()
    elif schema_name == topopassport_schema_name():
        target_tables = list_topopassport_layer_tables()
    else:
        target_tables = list_schema_layer_tables(schema_name)
    counts: dict[str, int] = {}

    clip_geojson = None
    if schema_name == topopassport_schema_name() and any(
        table in _TOPO_CLIP_TO_WORK_TABLES for table in target_tables
    ):
        from .reference_layers import load_work_anchor_geometry

        for guid in task_guids:
            geom = load_work_anchor_geometry(str(guid))
            if geom:
                clip_geojson = json.dumps(geom, ensure_ascii=False)
                break

    try:
        with connections["qgis"].cursor() as cursor:
            for table in target_tables:
                clip_table = (
                    schema_name == topopassport_schema_name()
                    and table in _TOPO_CLIP_TO_WORK_TABLES
                )
                if clip_table and not clip_geojson:
                    continue
                clip_sql = ""
                params: list = [task_guids]
                if clip_table:
                    clip_sql = f"""
                      AND ST_Intersects(
                        t.{_quote_ident(geom_col)},
                        {wgs84_to_work_sql()}
                      )
                    """
                    params.append(clip_geojson)
                exclude_sql = topolines_excluded_layer_sql(
                    cursor, schema_name, table
                )
                try:
                    cursor.execute(
                        f"""
                        SELECT COUNT(*)
                        FROM {_quote_ident(schema_name)}.{_quote_ident(table)} t
                        WHERE t.{_quote_ident(task_col)} = ANY(%s::uuid[])
                          AND t.{_quote_ident(geom_col)} IS NOT NULL
                          AND NOT ST_IsEmpty(t.{_quote_ident(geom_col)})
                          {clip_sql}
                          {exclude_sql}
                        """,
                        params,
                    )
                    count = int(cursor.fetchone()[0] or 0)
                    if count:
                        counts[table] = count
                except Exception:
                    logger.exception(
                        "count_features_by_table: qgis query failed schema=%s table=%s",
                        schema_name,
                        table,
                    )
    except Exception:
        logger.exception("count_features_by_table: qgis query failed schema=%s", schema_name)
        return counts

    return counts


def count_topopassport_features_by_table(task_guids: list[str]) -> dict[str, int]:
    return count_features_by_table(
        task_guids,
        schema=topopassport_schema_name(),
        tables=list_topopassport_layer_tables(),
    )


def _is_bottom_polygon_key(layer_key: str) -> bool:
    style_table = style_table_name_for_layer_key(layer_key)
    return style_table in _BOTTOM_POLYGON_TABLES


def _layer_panel_sort_key(layer: dict) -> tuple:
    geometry = layer.get("geometry", "polygon")
    tier = _GEOMETRY_TIER.get(geometry, 2)
    bottom = 1 if _is_bottom_polygon_key(str(layer.get("key") or "")) else 0
    return (tier, bottom, layer.get("name", ""))


def _layer_stack_sort_key(layer: dict) -> tuple:
    """Sort key for map draw order (bottom → top)."""
    geometry = layer.get("geometry", "polygon")
    if geometry == "polygon":
        bottom = 0 if _is_bottom_polygon_key(str(layer.get("key") or "")) else 1
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
        if table_name in PANEL_EXCLUDED_LAYERS:
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


def build_topopassport_layer_groups(feature_counts_by_table: dict[str, int]) -> list[dict]:
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
                "key": topo_layer_key(table_name),
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
            "key": "topopassport",
            "title": "Топография",
            "checked": True,
            "layers": layers,
        }
    ]


REFERENCE_LAYER_SPECS = (
    {"key": "dgi", "name": "Земельные участки", "geometry": "polygon"},
    {"key": "oozt", "name": "ООЗТ/ООПТ", "geometry": "line"},
    {"key": "renew", "name": "Реновация", "geometry": "polygon"},
    {"key": "rzd", "name": "Полосы отвода ЖД", "geometry": "line"},
)

# Same 4 З/У buckets as pass_viewer layer panel (ownership × rent).
DGI_SUBLAYER_SPECS = (
    {"key": "dgi_moscow_rent", "name": "З/У г. Москва с арендой"},
    {"key": "dgi_moscow_no_rent", "name": "З/У г. Москва без аренды"},
    {
        "key": "dgi_private_rent",
        "name": "З/У Частная или федеральная собственность с арендой",
    },
    {
        "key": "dgi_private_no_rent",
        "name": "З/У Частная или федеральная собственность без аренды",
    },
)


def build_reference_layer_groups(*, include_keys: set[str] | None = None) -> list[dict]:
    """Panel group for dgi/oozt/renew/rzd. Counts filled after progressive load if unknown."""
    layers = []
    for spec in REFERENCE_LAYER_SPECS:
        if include_keys is not None and spec["key"] not in include_keys:
            continue
        layers.append(
            {
                "key": spec["key"],
                "name": spec["name"],
                "count": 0,
                "geometry": spec["geometry"],
                "checked": False,
            }
        )
    if not layers:
        return []
    return [
        {
            "key": "reference",
            "title": "Справочные слои",
            "checked": False,
            "layers": layers,
        }
    ]


def build_adjacent_layer_groups(counts_by_source: dict[str, dict[str, int]]) -> list[dict]:
    """Build panel rows split by source table (ДТ/ОДХ/ОО) for approval and objects."""
    from .work_adjacent import (
        ADJACENT_SOURCE_ORDER,
        LAYER_KEY_APPROVAL,
        LAYER_KEY_OBJECTS,
        adjacent_layer_key,
        adjacent_poly_tables,
        adjacent_source_label,
    )

    tables = [t for t in ADJACENT_SOURCE_ORDER if t in set(adjacent_poly_tables())]
    # Include any configured tables not in the default order at the end.
    for table_name in adjacent_poly_tables():
        if table_name not in tables:
            tables.append(table_name)

    layers: list[dict] = []
    for table_name in tables:
        bucket = counts_by_source.get(table_name) or {}
        n_count = int(bucket.get("n", 0) or 0)
        if n_count > 0:
            label = adjacent_source_label(table_name)
            layers.append(
                {
                    "key": adjacent_layer_key(LAYER_KEY_APPROVAL, table_name),
                    "name": f"Смежный объект для согласования · {label}",
                    "count": n_count,
                    "geometry": "polygon",
                    "checked": True,
                }
            )
    for table_name in tables:
        bucket = counts_by_source.get(table_name) or {}
        v_count = int(bucket.get("v", 0) or 0)
        if v_count > 0:
            label = adjacent_source_label(table_name)
            layers.append(
                {
                    "key": adjacent_layer_key(LAYER_KEY_OBJECTS, table_name),
                    "name": f"Смежные объекты · {label}",
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

"""Load approval map features from mggt_asu.work / topopassport schemas."""

from __future__ import annotations

import json
import logging

from django.conf import settings
from django.db import connections

from .qml_style_builder import load_manifest
from .reference_layers import load_work_anchor_geometry
from .work_layers import (
    _quote_ident,
    list_schema_layer_tables,
    list_topopassport_layer_tables,
    list_work_layer_tables,
    schema_taskguid_column,
    topo_layer_key,
    topopassport_schema_name,
    work_geom_column,
    work_schema_name,
)

logger = logging.getLogger(__name__)

_POINT_STYLE_FIELDS = ("Svg", "SvgMarkerPath", "SvgMarkerAngle")
# topotext often covers a wide CAD extent — keep only labels inside the survey object.
_TOPO_CLIP_TO_WORK_TABLES = frozenset({"topotext"})


def _max_features() -> int:
    try:
        return int(getattr(settings, "APPROVAL_WORK_MAX_FEATURES", 5000))
    except (TypeError, ValueError):
        return 5000


def _resolve_column_name(
    cursor, schema: str, table_name: str, preferred_name: str
) -> str | None:
    """Return actual column name matching preferred_name case-insensitively, or None."""
    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [schema, table_name, preferred_name],
    )
    row = cursor.fetchone()
    return row[0] if row else None


def _column_exists(cursor, schema: str, table_name: str, column_name: str) -> bool:
    return _resolve_column_name(cursor, schema, table_name, column_name) is not None


def _style_fields_for_table(table_name: str, manifest: dict | None = None) -> list[str]:
    data = manifest or load_manifest()
    table = data.get("tables", {}).get(table_name, {})
    fields = list(table.get("fields") or [])
    geometry = table.get("geometry")
    if geometry == "point":
        for field in _POINT_STYLE_FIELDS:
            if field not in fields:
                fields.append(field)
    return fields


def _should_clip_table_to_work(schema: str, table_name: str) -> bool:
    return (
        str(schema or "").strip() == topopassport_schema_name()
        and str(table_name or "") in _TOPO_CLIP_TO_WORK_TABLES
    )


def _work_boundary_geojson_for_guids(task_guids: list[str]) -> str | None:
    """GeoJSON polygon (EPSG:4326) of the survey object for the first matching guid."""
    for guid in task_guids:
        geom = load_work_anchor_geometry(str(guid))
        if geom:
            return json.dumps(geom, ensure_ascii=False)
    return None


def _feature_select_sql(
    table_name: str,
    style_fields: list[str],
    cursor,
    *,
    schema: str,
    layer_key: str,
    clip_to_work_boundary: bool = False,
) -> str:
    geom_col = work_geom_column()
    task_col = schema_taskguid_column(schema)
    quoted_table = _quote_ident(table_name)
    quoted_schema = _quote_ident(schema)
    quoted_geom = _quote_ident(geom_col)
    quoted_task = _quote_ident(task_col)

    property_pairs = [
        f"'layerKey', '{layer_key}'",
        f"'sourceTable', '{table_name}'",
        f"'sourceSchema', '{schema}'",
        f"'taskGuid', t.{quoted_task}::text",
        "'fid', t.fid",
    ]
    for field in style_fields:
        resolved = _resolve_column_name(cursor, schema, table_name, field)
        if not resolved:
            continue
        # Keep QML/canonical property name so client filter matching stays stable.
        quoted_field = _quote_ident(resolved)
        property_pairs.append(f"'{field}', t.{quoted_field}::text")

    props_sql = ", ".join(property_pairs)
    clip_sql = ""
    if clip_to_work_boundary:
        # Boundary GeoJSON is EPSG:4326 (see load_work_anchor_geometry); reproject to layer SRID.
        # Param order: guids first (ANY), then boundary GeoJSON.
        clip_sql = f"""
          AND ST_Intersects(
            t.{quoted_geom},
            ST_Transform(
              ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326),
              ST_SRID(t.{quoted_geom})
            )
          )
        """

    return f"""
        SELECT json_build_object(
            'type', 'Feature',
            'geometry', ST_AsGeoJSON(ST_Transform(t.{quoted_geom}, 4326))::json,
            'properties', json_build_object(
                {props_sql}
            )
        )
        FROM {quoted_schema}.{quoted_table} t
        WHERE t.{quoted_task} = ANY(%s::uuid[])
          AND t.{quoted_geom} IS NOT NULL
          AND NOT ST_IsEmpty(t.{quoted_geom})
          {clip_sql}
    """


def build_schema_feature_collection(
    task_guids: list[str],
    *,
    schema: str,
    tables: list[str] | None = None,
    layer_key_for_table=None,
) -> tuple[dict, str | None]:
    if not task_guids:
        return {"type": "FeatureCollection", "features": []}, None

    normalized_guids = [str(guid) for guid in task_guids if guid]
    if not normalized_guids:
        return {"type": "FeatureCollection", "features": []}, None

    schema_name = str(schema or "").strip()
    if not schema_name:
        return {"type": "FeatureCollection", "features": []}, "Не указана схема."

    target_tables = tables if tables is not None else list_schema_layer_tables(schema_name)
    if not target_tables:
        return (
            {"type": "FeatureCollection", "features": []},
            f"Не удалось получить список таблиц {schema_name}.",
        )

    max_features = _max_features()
    features: list[dict] = []
    manifest = load_manifest()
    key_fn = layer_key_for_table or (lambda table: table)
    needs_clip = any(_should_clip_table_to_work(schema_name, name) for name in target_tables)
    clip_geojson = _work_boundary_geojson_for_guids(normalized_guids) if needs_clip else None

    try:
        with connections["qgis"].cursor() as cursor:
            for table_name in target_tables:
                if len(features) >= max_features:
                    break
                clip_table = _should_clip_table_to_work(schema_name, table_name)
                if clip_table and not clip_geojson:
                    # No survey polygon → nothing inside the object boundary.
                    continue
                style_fields = _style_fields_for_table(table_name, manifest)
                layer_key = key_fn(table_name)
                sql = _feature_select_sql(
                    table_name,
                    style_fields,
                    cursor,
                    schema=schema_name,
                    layer_key=layer_key,
                    clip_to_work_boundary=clip_table,
                )
                # SQL placeholders: ANY(%s) first, then optional GeomFromGeoJSON(%s).
                params: list = [normalized_guids]
                if clip_table:
                    params.append(clip_geojson)
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
    except Exception:
        logger.exception(
            "build_schema_feature_collection: qgis query failed schema=%s",
            schema_name,
        )
        return (
            {"type": "FeatureCollection", "features": []},
            f"Не удалось загрузить объекты из mggt_asu.{schema_name}.",
        )

    if len(features) >= max_features:
        return (
            {"type": "FeatureCollection", "features": features[:max_features]},
            f"Показаны первые {max_features} объектов (лимит безопасности).",
        )

    return {"type": "FeatureCollection", "features": features}, None


def build_work_feature_collection(
    task_guids: list[str],
    *,
    tables: list[str] | None = None,
) -> tuple[dict, str | None]:
    return build_schema_feature_collection(
        task_guids,
        schema=work_schema_name(),
        tables=tables if tables is not None else list_work_layer_tables(),
        layer_key_for_table=lambda table: table,
    )


def build_topopassport_feature_collection(
    task_guids: list[str],
    *,
    tables: list[str] | None = None,
) -> tuple[dict, str | None]:
    return build_schema_feature_collection(
        task_guids,
        schema=topopassport_schema_name(),
        tables=tables if tables is not None else list_topopassport_layer_tables(),
        layer_key_for_table=topo_layer_key,
    )

"""Load approval map features from mggt_asu.work schema."""

from __future__ import annotations

import json
import logging

from django.conf import settings
from django.db import connections

from .qml_style_builder import load_manifest
from .work_layers import (
    _quote_ident,
    list_work_layer_tables,
    work_geom_column,
    work_schema_name,
    work_taskguid_column,
)

logger = logging.getLogger(__name__)

_POINT_STYLE_FIELDS = ("Svg", "SvgMarkerPath", "SvgMarkerAngle")


def _max_features() -> int:
    try:
        return int(getattr(settings, "APPROVAL_WORK_MAX_FEATURES", 5000))
    except (TypeError, ValueError):
        return 5000


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


def _feature_select_sql(table_name: str, style_fields: list[str], cursor) -> str:
    schema = work_schema_name()
    geom_col = work_geom_column()
    task_col = work_taskguid_column()
    quoted_table = _quote_ident(table_name)
    quoted_schema = _quote_ident(schema)
    quoted_geom = _quote_ident(geom_col)
    quoted_task = _quote_ident(task_col)

    property_pairs = [
        f"'layerKey', '{table_name}'",
        f"'sourceTable', '{table_name}'",
        f"'taskGuid', t.{quoted_task}::text",
        "'fid', t.fid",
    ]
    for field in style_fields:
        if not _column_exists(cursor, schema, table_name, field):
            continue
        quoted_field = _quote_ident(field)
        property_pairs.append(f"'{field}', t.{quoted_field}::text")

    props_sql = ", ".join(property_pairs)
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
    """


def build_work_feature_collection(
    task_guids: list[str],
    *,
    tables: list[str] | None = None,
) -> tuple[dict, str | None]:
    if not task_guids:
        return {"type": "FeatureCollection", "features": []}, None

    normalized_guids = [str(guid) for guid in task_guids if guid]
    if not normalized_guids:
        return {"type": "FeatureCollection", "features": []}, None

    target_tables = tables or list_work_layer_tables()
    if not target_tables:
        return {"type": "FeatureCollection", "features": []}, "Не удалось получить список таблиц work."

    max_features = _max_features()
    features: list[dict] = []
    manifest = load_manifest()

    try:
        with connections["qgis"].cursor() as cursor:
            for table_name in target_tables:
                if len(features) >= max_features:
                    break
                style_fields = _style_fields_for_table(table_name, manifest)
                cursor.execute(_feature_select_sql(table_name, style_fields, cursor), [normalized_guids])
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
        logger.exception("build_work_feature_collection: qgis query failed")
        return {"type": "FeatureCollection", "features": []}, "Не удалось загрузить объекты съёмки из mggt_asu."

    if len(features) >= max_features:
        return (
            {"type": "FeatureCollection", "features": features[:max_features]},
            f"Показаны первые {max_features} объектов (лимит безопасности).",
        )

    return {"type": "FeatureCollection", "features": features}, None

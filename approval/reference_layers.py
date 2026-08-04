"""Reference map layers (dgi/oozt/renew/rzd) near the approval survey object."""

from __future__ import annotations

import json
import logging

from django.conf import settings
from django.db import connections

from .work_layers import (
    _quote_ident,
    geom_to_wgs84_sql,
    work_geom_column,
    work_schema_name,
    work_taskguid_column,
)

logger = logging.getLogger(__name__)

_ANCHOR_TABLES = ("YardPoly", "OznPoly", "OdhPoly")


def reference_buffer_meters() -> float:
    try:
        return float(getattr(settings, "APPROVAL_REFERENCE_BUFFER_METERS", 100))
    except (TypeError, ValueError):
        return 100.0


def load_work_anchor_geometry(task_guid: str) -> dict | None:
    """
    Return survey polygon GeoJSON (dict) for TaskGUID from work YardPoly → OznPoly → OdhPoly.
    Uses the first table that has non-empty geometry (union of rows in that table).
    """
    task_guid_text = str(task_guid or "").strip()
    if not task_guid_text:
        return None

    schema = work_schema_name()
    geom_col = work_geom_column()
    task_col = work_taskguid_column()
    quoted_schema = _quote_ident(schema)
    quoted_geom = _quote_ident(geom_col)
    quoted_task = _quote_ident(task_col)

    try:
        with connections["qgis"].cursor() as cursor:
            for table_name in _ANCHOR_TABLES:
                quoted_table = _quote_ident(table_name)
                cursor.execute(
                    f"""
                    SELECT ST_AsGeoJSON(
                        {geom_to_wgs84_sql(f'ST_UnaryUnion(ST_Collect(t.{quoted_geom}))')}
                    )::text
                    FROM {quoted_schema}.{quoted_table} t
                    WHERE t.{quoted_task} = %s::uuid
                      AND t.{quoted_geom} IS NOT NULL
                      AND NOT ST_IsEmpty(t.{quoted_geom})
                    """,
                    [task_guid_text],
                )
                row = cursor.fetchone()
                if not row or not row[0]:
                    continue
                try:
                    geom = json.loads(row[0])
                except (TypeError, json.JSONDecodeError):
                    continue
                if isinstance(geom, dict) and geom.get("type"):
                    return geom
    except Exception:
        logger.exception("load_work_anchor_geometry: qgis query failed")
        return None

    return None


def _features_from_geojson_payload(payload, *, layer_key: str) -> list[dict]:
    from pass_viewer.views import _geojson_layer_for_response

    parsed = _geojson_layer_for_response(payload)
    if not isinstance(parsed, dict):
        return []
    features = parsed.get("features")
    if not isinstance(features, list):
        return []
    out: list[dict] = []
    for feature in features:
        if not isinstance(feature, dict):
            continue
        props = feature.get("properties")
        if not isinstance(props, dict):
            props = {}
            feature = {**feature, "properties": props}
        else:
            feature = {**feature, "properties": dict(props)}
        feature["properties"]["layerKey"] = layer_key
        feature["properties"].setdefault("sourceTable", layer_key)
        out.append(feature)
    return out


def _build_dgi_split_features(geometry: dict, meters: float) -> list[dict]:
    """Load ДГИ as four ownership×rent buckets; tag each feature with dgiSubKey."""
    from django.db import connection

    from pass_viewer.dgi_layers import DGI_LAYER_KEYS
    from pass_viewer.views import _get_reference_layer_geojson, _sql_dgi_layer_filter

    dgi_table = getattr(settings, "GIS_DGI_TABLE", "dgi")
    layer_filters: dict[str, str] = {}
    with connection.cursor() as cursor:
        for sub_key in DGI_LAYER_KEYS:
            layer_filters[sub_key] = _sql_dgi_layer_filter(cursor, dgi_table, sub_key)

    features: list[dict] = []
    for sub_key in DGI_LAYER_KEYS:
        payload = _get_reference_layer_geojson(
            dgi_table,
            "ДГИ",
            geometry=geometry,
            distance_meters=meters,
            extra_where_sql=layer_filters[sub_key],
        )
        for feature in _features_from_geojson_payload(payload, layer_key="dgi"):
            feature["properties"]["dgiSubKey"] = sub_key
            features.append(feature)
    return features


def build_reference_layer_features(layer_key: str, task_guid: str) -> tuple[list[dict], str | None]:
    """
    Load dgi / oozt / renew / rzd features within APPROVAL_REFERENCE_BUFFER_METERS
    of the work survey geometry for task_guid.
    """
    key = str(layer_key or "").strip().lower()
    if key not in {"dgi", "oozt", "renew", "rzd"}:
        return [], "Неизвестный справочный слой."

    geometry = load_work_anchor_geometry(task_guid)
    if not geometry:
        return [], None

    meters = reference_buffer_meters()

    try:
        from pass_viewer.views import (
            _get_reference_layer_geojson,
            _get_signal_tape_layer_geojson,
        )

        if key == "dgi":
            return _build_dgi_split_features(geometry, meters), None
        if key == "renew":
            payload = _get_reference_layer_geojson(
                getattr(settings, "GIS_RENEW_TABLE", "renew"),
                "Реновация",
                geometry=geometry,
                distance_meters=meters,
            )
        elif key == "oozt":
            payload = _get_signal_tape_layer_geojson(
                getattr(settings, "GIS_OOZT_TABLE", "oozt"),
                "ООЗТ",
                geometry=geometry,
                distance_meters=meters,
            )
        else:
            payload = _get_signal_tape_layer_geojson(
                getattr(settings, "GIS_RZD_TABLE", "rzd"),
                "РЖД",
                geometry=geometry,
                distance_meters=meters,
            )
    except Exception:
        logger.exception("build_reference_layer_features: failed for layer=%s", key)
        return [], f"Не удалось загрузить слой {key}."

    return _features_from_geojson_payload(payload, layer_key=key), None

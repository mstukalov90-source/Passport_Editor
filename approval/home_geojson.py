"""Home-map GeoJSON for approval objects (mggt_asu work + adjacent by n_root)."""

from __future__ import annotations

import json
import logging
from typing import Iterable
from uuid import UUID

from django.db import connections

from .work_adjacent import build_adjacent_features, collect_adjacent_roots
from .work_layers import (
    _TASK_POLY_SOURCE_TABLES,
    _column_exists,
    _quote_ident,
    geom_to_wgs84_sql,
    work_geom_column,
    work_schema_name,
    work_taskguid_column,
)

logger = logging.getLogger(__name__)

FILTER_TASK = "СОГЛ"
FILTER_ADJACENT = "СМЕЖ"


def _empty_collection() -> dict:
    return {"type": "FeatureCollection", "features": []}


def _normalize_guid(value) -> str:
    text = str(value or "").strip()
    if not text:
        return ""
    try:
        return str(UUID(text))
    except (TypeError, ValueError, AttributeError):
        return ""


def _batch_load_work_anchor_geometries(task_guids: list[str]) -> dict[str, dict]:
    """Load survey polygons for many TaskGUIDs. First matching poly table wins."""
    normalized: list[str] = []
    seen: set[str] = set()
    for raw in task_guids:
        guid = _normalize_guid(raw)
        if not guid or guid in seen:
            continue
        seen.add(guid)
        normalized.append(guid)

    result: dict[str, dict] = {}
    if not normalized:
        return result

    schema = work_schema_name()
    geom_col = work_geom_column()
    task_col = work_taskguid_column()
    quoted_schema = _quote_ident(schema)
    quoted_geom = _quote_ident(geom_col)
    quoted_task = _quote_ident(task_col)
    unresolved = set(normalized)

    try:
        with connections["qgis"].cursor() as cursor:
            for table_name, _source_label in _TASK_POLY_SOURCE_TABLES:
                if not unresolved:
                    break
                if not _column_exists(cursor, schema, table_name, task_col):
                    continue
                if not _column_exists(cursor, schema, table_name, geom_col):
                    continue
                quoted_table = _quote_ident(table_name)
                try:
                    cursor.execute(
                        f"""
                        SELECT t.{quoted_task}::text,
                               ST_AsGeoJSON(
                                   {geom_to_wgs84_sql(f'ST_UnaryUnion(ST_Collect(t.{quoted_geom}))')}
                               )::text
                        FROM {quoted_schema}.{quoted_table} t
                        WHERE t.{quoted_task} = ANY(%s::uuid[])
                          AND t.{quoted_geom} IS NOT NULL
                          AND NOT ST_IsEmpty(t.{quoted_geom})
                        GROUP BY t.{quoted_task}
                        """,
                        [list(unresolved)],
                    )
                except Exception:
                    logger.exception(
                        "home_geojson: anchor query failed for table %s", table_name
                    )
                    continue
                for guid_text, geojson_text in cursor.fetchall():
                    guid = _normalize_guid(guid_text)
                    if not guid or guid not in unresolved or not geojson_text:
                        continue
                    try:
                        geom = json.loads(geojson_text)
                    except (TypeError, json.JSONDecodeError):
                        continue
                    if not isinstance(geom, dict) or not geom.get("type"):
                        continue
                    result[guid] = geom
                    unresolved.discard(guid)
    except Exception:
        logger.exception("home_geojson: qgis batch anchor load failed")
        return result

    return result


def _approve_label(approve) -> str:
    name = str(getattr(approve, "name", "") or "").strip()
    if name:
        return name
    guid = _normalize_guid(getattr(approve, "incoming_guid", ""))
    if guid:
        return f"Согласование {guid[:8]}…"
    return "Согласование"


def build_home_approval_feature_collection(approves: Iterable) -> dict:
    """FeatureCollection of approval objects for the home map.

    TaskGUID hits become filterKind СОГЛ; n_root hits become СМЕЖ.
    """
    approve_list = [item for item in (approves or []) if item is not None]
    if not approve_list:
        return _empty_collection()

    guid_to_approves: dict[str, list] = {}
    root_to_approves: dict[str, list] = {}
    all_n_roots: list[str] = []

    for approve in approve_list:
        guid = _normalize_guid(getattr(approve, "incoming_guid", ""))
        if guid:
            guid_to_approves.setdefault(guid, []).append(approve)
        try:
            n_roots, _v_roots = collect_adjacent_roots(approve)
        except Exception:
            logger.exception("home_geojson: collect_adjacent_roots failed")
            n_roots = []
        for root_id in n_roots:
            text = str(root_id or "").strip()
            if not text:
                continue
            if text not in root_to_approves:
                all_n_roots.append(text)
            root_to_approves.setdefault(text, []).append(approve)

    features: list[dict] = []

    try:
        anchors = _batch_load_work_anchor_geometries(list(guid_to_approves.keys()))
    except Exception:
        logger.exception("home_geojson: failed to load taskguid anchors")
        anchors = {}

    for guid, geometry in anchors.items():
        for approve in guid_to_approves.get(guid, []):
            approve_id = str(getattr(approve, "id", "") or "")
            features.append(
                {
                    "type": "Feature",
                    "geometry": geometry,
                    "properties": {
                        "filterKind": FILTER_TASK,
                        "approve_id": approve_id,
                        "incoming_guid": guid,
                        "name": _approve_label(approve),
                        "lookup": "taskguid",
                        "map_row_key": f"approve:{approve_id}:task",
                    },
                }
            )

    if all_n_roots:
        try:
            adjacent_features, _error = build_adjacent_features(all_n_roots, [])
        except Exception:
            logger.exception("home_geojson: failed to load n_root polygons")
            adjacent_features = []
        for feature in adjacent_features or []:
            props = dict(feature.get("properties") or {})
            geometry = feature.get("geometry")
            if not geometry:
                continue
            root_id = str(props.get("RootId") or "").strip()
            for approve in root_to_approves.get(root_id, []):
                approve_id = str(getattr(approve, "id", "") or "")
                cloned_props = {
                    **props,
                    "filterKind": FILTER_ADJACENT,
                    "approve_id": approve_id,
                    "incoming_guid": _normalize_guid(getattr(approve, "incoming_guid", "")),
                    "name": _approve_label(approve),
                    "lookup": "n_root",
                    "map_row_key": f"approve:{approve_id}:adj:{root_id}",
                }
                features.append(
                    {
                        "type": "Feature",
                        "geometry": geometry,
                        "properties": cloned_props,
                    }
                )

    return {"type": "FeatureCollection", "features": features}

"""Home-map GeoJSON for recheck (ЦГ) objects."""

from __future__ import annotations

import logging
from typing import Iterable

from approval.home_geojson import (
    _batch_load_work_anchor_geometries,
    _empty_collection,
    _normalize_guid,
)

logger = logging.getLogger(__name__)

FILTER_RECHECK = "ЦГ"


def _recheck_label(event) -> str:
    approve = getattr(event, "source_approve", None)
    name = str(getattr(approve, "name", "") or "").strip()
    if name:
        return name
    title = str(getattr(event, "title", "") or "").strip()
    if title:
        return title
    guid = _normalize_guid(getattr(event, "task_guid", ""))
    if guid:
        return f"Согласование ЦГ {guid[:8]}…"
    return "Согласование ЦГ"


def build_home_recheck_feature_collection(events: Iterable) -> dict:
    """FeatureCollection of recheck objects for the home map (filterKind ЦГ)."""
    event_list = [item for item in (events or []) if item is not None]
    if not event_list:
        return _empty_collection()

    guid_to_events: dict[str, list] = {}
    for event in event_list:
        guid = _normalize_guid(getattr(event, "task_guid", ""))
        if not guid:
            approve = getattr(event, "source_approve", None)
            guid = _normalize_guid(getattr(approve, "incoming_guid", ""))
        if guid:
            guid_to_events.setdefault(guid, []).append(event)

    try:
        anchors = _batch_load_work_anchor_geometries(list(guid_to_events.keys()))
    except Exception:
        logger.exception("recheck home_geojson: failed to load taskguid anchors")
        anchors = {}

    features: list[dict] = []
    for guid, geometry in anchors.items():
        for event in guid_to_events.get(guid, []):
            event_id = str(getattr(event, "id", "") or "")
            features.append(
                {
                    "type": "Feature",
                    "geometry": geometry,
                    "properties": {
                        "filterKind": FILTER_RECHECK,
                        "recheck_id": event_id,
                        "incoming_guid": guid,
                        "name": _recheck_label(event),
                        "lookup": "taskguid",
                        "map_row_key": f"recheck:{event_id}",
                        "row_kind": "recheck",
                    },
                }
            )

    return {"type": "FeatureCollection", "features": features}

"""Progressive map layer loading for the approval landing page."""

from __future__ import annotations

import logging
from typing import TYPE_CHECKING

from .reference_layers import build_reference_layer_features
from .work_adjacent import (
    build_adjacent_features,
    collect_adjacent_roots,
)
from .work_geojson import (
    build_topopassport_feature_collection,
    build_work_feature_collection,
)
from .work_layer_labels import work_layer_label
from .work_layers import PANEL_EXCLUDED_LAYERS, REFERENCE_LAYER_SPECS

if TYPE_CHECKING:
    from .models import Approve

logger = logging.getLogger(__name__)

REFERENCE_LAYER_KEYS = frozenset(spec["key"] for spec in REFERENCE_LAYER_SPECS)


def build_map_layer_load_order(
    *,
    work_counts: dict[str, int],
    topo_counts: dict[str, int],
    has_adjacent: bool,
    include_reference: bool = True,
) -> list[dict]:
    """Ordered specs for sequential client-side loading."""
    specs: list[dict] = []

    for table_name in sorted(work_counts):
        if work_counts[table_name] <= 0:
            continue
        if table_name in PANEL_EXCLUDED_LAYERS:
            continue
        specs.append(
            {
                "key": f"work:{table_name}",
                "label": work_layer_label(table_name),
            }
        )

    for table_name in sorted(topo_counts):
        if topo_counts[table_name] <= 0:
            continue
        specs.append(
            {
                "key": f"topo:{table_name}",
                "label": f"Топопаспорт: {work_layer_label(table_name)}",
            }
        )

    if has_adjacent:
        specs.append({"key": "adjacent", "label": "Смежные паспорта"})

    if include_reference:
        for spec in REFERENCE_LAYER_SPECS:
            specs.append({"key": spec["key"], "label": spec["name"]})

    return specs


def resolve_map_layer_features(approve: Approve, layer_key: str) -> tuple[list[dict], str | None]:
    """Return GeoJSON features for one progressive load chunk."""
    key = str(layer_key or "").strip()
    if not key:
        return [], "Не указан слой."

    task_guid = str(approve.incoming_guid)

    if key.startswith("work:"):
        table_name = key[len("work:") :].strip()
        if not table_name:
            return [], "Некорректный слой work."
        collection, error = build_work_feature_collection([task_guid], tables=[table_name])
        return list(collection.get("features") or []), error

    if key.startswith("topo:"):
        table_name = key[len("topo:") :].strip()
        if not table_name:
            return [], "Некорректный слой topopassport."
        collection, error = build_topopassport_feature_collection([task_guid], tables=[table_name])
        return list(collection.get("features") or []), error

    if key == "adjacent":
        n_roots, v_roots = collect_adjacent_roots(approve)
        return build_adjacent_features(n_roots, v_roots)

    if key in REFERENCE_LAYER_KEYS:
        return build_reference_layer_features(key, task_guid)

    return [], "Неизвестный слой."

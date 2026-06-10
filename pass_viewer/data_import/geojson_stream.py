"""Stream features from large GeoJSON FeatureCollection files via ijson."""

from __future__ import annotations

from collections.abc import Iterator

import ijson


def iter_geojson_features(path: str) -> Iterator[dict]:
    with open(path, "rb") as f:
        for feature in ijson.items(f, "features.item", use_float=True):
            if isinstance(feature, dict):
                yield feature

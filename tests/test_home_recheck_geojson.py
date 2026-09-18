"""Tests for home-map GeoJSON of recheck (ЦГ) objects."""

from __future__ import annotations

import uuid
from types import SimpleNamespace
from unittest.mock import patch

from recheck.home_geojson import FILTER_RECHECK, build_home_recheck_feature_collection

SQUARE = {
    "type": "Polygon",
    "coordinates": [
        [
            [37.0, 55.0],
            [37.1, 55.0],
            [37.1, 55.1],
            [37.0, 55.1],
            [37.0, 55.0],
        ]
    ],
}

GUID = "2e333940-831b-48f5-9751-acd0c2880974"


def _event(*, task_guid=GUID, name="Заявка ЦГ", event_id=None):
    return SimpleNamespace(
        id=event_id or uuid.UUID("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
        task_guid=task_guid,
        title="Проверка геоподосновы",
        source_approve=SimpleNamespace(name=name, incoming_guid=task_guid),
    )


def test_empty_rechecks_returns_empty_collection():
    result = build_home_recheck_feature_collection([])
    assert result == {"type": "FeatureCollection", "features": []}
    assert build_home_recheck_feature_collection(None) == {
        "type": "FeatureCollection",
        "features": [],
    }


@patch("recheck.home_geojson._batch_load_work_anchor_geometries")
def test_taskguid_anchor_becomes_cg(batch_load):
    event = _event()
    batch_load.return_value = {GUID: SQUARE}

    result = build_home_recheck_feature_collection([event])

    assert len(result["features"]) == 1
    feature = result["features"][0]
    assert feature["geometry"] == SQUARE
    props = feature["properties"]
    assert props["filterKind"] == FILTER_RECHECK
    assert props["lookup"] == "taskguid"
    assert props["recheck_id"] == str(event.id)
    assert props["incoming_guid"] == GUID
    assert props["name"] == "Заявка ЦГ"
    assert props["map_row_key"] == f"recheck:{event.id}"
    assert props["row_kind"] == "recheck"

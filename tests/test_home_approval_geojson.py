"""Tests for home-map GeoJSON of approval objects."""

from __future__ import annotations

import json
import uuid
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from approval.home_geojson import (
    FILTER_ADJACENT,
    FILTER_TASK,
    _batch_load_work_anchor_geometries,
    build_home_approval_feature_collection,
)

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


def _approve(*, incoming_guid=GUID, name="Заявка А", approve_id=None):
    return SimpleNamespace(
        id=approve_id or uuid.UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
        incoming_guid=incoming_guid,
        name=name,
    )


def test_empty_approves_returns_empty_collection():
    result = build_home_approval_feature_collection([])
    assert result == {"type": "FeatureCollection", "features": []}
    assert build_home_approval_feature_collection(None) == {
        "type": "FeatureCollection",
        "features": [],
    }


@patch("approval.home_geojson.build_adjacent_features")
@patch("approval.home_geojson.collect_adjacent_roots", return_value=([], []))
@patch("approval.home_geojson._batch_load_work_anchor_geometries")
def test_taskguid_anchor_becomes_sogl(batch_load, _collect_roots, build_adjacent):
    approve = _approve()
    batch_load.return_value = {GUID: SQUARE}
    build_adjacent.return_value = ([], None)

    result = build_home_approval_feature_collection([approve])

    assert len(result["features"]) == 1
    feature = result["features"][0]
    assert feature["geometry"] == SQUARE
    props = feature["properties"]
    assert props["filterKind"] == FILTER_TASK
    assert props["lookup"] == "taskguid"
    assert props["approve_id"] == str(approve.id)
    assert props["incoming_guid"] == GUID
    assert props["name"] == "Заявка А"
    assert props["map_row_key"] == f"approve:{approve.id}:task"
    build_adjacent.assert_not_called()


@patch("approval.home_geojson.build_adjacent_features")
@patch("approval.home_geojson.collect_adjacent_roots", return_value=(["09811"], ["10482"]))
@patch("approval.home_geojson._batch_load_work_anchor_geometries", return_value={})
def test_n_root_becomes_smezh(batch_load, collect_roots, build_adjacent):
    approve = _approve()
    build_adjacent.return_value = (
        [
            {
                "type": "Feature",
                "geometry": SQUARE,
                "properties": {"RootId": "09811", "sourceTable": "YardPoly"},
            }
        ],
        None,
    )

    result = build_home_approval_feature_collection([approve])

    assert len(result["features"]) == 1
    props = result["features"][0]["properties"]
    assert props["filterKind"] == FILTER_ADJACENT
    assert props["lookup"] == "n_root"
    assert props["approve_id"] == str(approve.id)
    assert props["RootId"] == "09811"
    assert props["map_row_key"] == f"approve:{approve.id}:adj:09811"
    collect_roots.assert_called_once_with(approve)
    build_adjacent.assert_called_once_with(["09811"], [])
    batch_load.assert_called_once()


@patch("approval.home_geojson.build_adjacent_features")
@patch("approval.home_geojson.collect_adjacent_roots")
@patch("approval.home_geojson._batch_load_work_anchor_geometries", return_value={})
def test_shared_n_root_duplicates_feature_per_approve(
    _batch_load, collect_roots, build_adjacent
):
    first = _approve(name="A", approve_id=uuid.UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"))
    second = _approve(
        incoming_guid=uuid.uuid4(),
        name="B",
        approve_id=uuid.UUID("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
    )
    collect_roots.return_value = (["09811"], [])
    build_adjacent.return_value = (
        [
            {
                "type": "Feature",
                "geometry": SQUARE,
                "properties": {"RootId": "09811"},
            }
        ],
        None,
    )

    result = build_home_approval_feature_collection([first, second])

    ids = {feature["properties"]["approve_id"] for feature in result["features"]}
    assert ids == {str(first.id), str(second.id)}
    assert all(f["properties"]["filterKind"] == FILTER_ADJACENT for f in result["features"])
    build_adjacent.assert_called_once_with(["09811"], [])


@patch("approval.home_geojson._column_exists", return_value=True)
@patch("approval.home_geojson.connections")
def test_batch_load_uses_any_uuid_and_group_by(mock_connections, _column_exists):
    cursor = MagicMock()
    cursor.fetchall.return_value = [(GUID, json.dumps(SQUARE))]
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = (
        cursor
    )

    result = _batch_load_work_anchor_geometries([GUID, GUID, "not-a-uuid"])

    assert result == {GUID: SQUARE}
    sql = cursor.execute.call_args[0][0]
    params = cursor.execute.call_args[0][1]
    assert "ANY(%s::uuid[])" in sql
    assert "GROUP BY" in sql
    assert params == [[GUID]]
    assert cursor.execute.call_count == 1


@patch("approval.home_geojson.connections")
def test_batch_load_swallows_qgis_errors(mock_connections):
    mock_connections.__getitem__.side_effect = RuntimeError("qgis unavailable")
    assert _batch_load_work_anchor_geometries([GUID]) == {}


@patch("approval.home_geojson.build_adjacent_features", side_effect=RuntimeError("qgis"))
@patch("approval.home_geojson.collect_adjacent_roots", return_value=(["09811"], []))
@patch(
    "approval.home_geojson._batch_load_work_anchor_geometries",
    side_effect=RuntimeError("qgis"),
)
def test_build_collection_swallows_qgis_errors(_batch_load, _collect, _adjacent):
    result = build_home_approval_feature_collection([_approve()])
    assert result == {"type": "FeatureCollection", "features": []}

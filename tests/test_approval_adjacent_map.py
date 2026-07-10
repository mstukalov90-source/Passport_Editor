"""Tests for adjacent passport layers on the approval map."""

from __future__ import annotations

import uuid
from unittest.mock import MagicMock, patch

import pytest
from approval.models import Approve
from approval.views import landing
from approval.work_adjacent import (
    LAYER_KEY_APPROVAL,
    LAYER_KEY_OBJECTS,
    adjacent_root_ids,
    build_adjacent_features,
    count_adjacent_features,
)
from approval.work_layers import build_adjacent_layer_groups
from django.http import HttpResponse
from django.test import RequestFactory
from pass_viewer.models import ExternalUser


def test_adjacent_root_ids_excludes_n_root_from_v_root():
    n_values, v_values = adjacent_root_ids(["09811"], ["10482", "09811"])
    assert n_values == ["09811"]
    assert v_values == ["10482"]


def test_adjacent_root_ids_accepts_string_legacy():
    n_values, v_values = adjacent_root_ids("09811", ["10482", "09811"])
    assert n_values == ["09811"]
    assert v_values == ["10482"]


def test_adjacent_root_ids_empty_when_no_values():
    assert adjacent_root_ids(None, None) == ([], [])
    assert adjacent_root_ids("  ", ["", "  "]) == ([], [])


def test_build_adjacent_layer_groups_names_and_counts():
    groups = build_adjacent_layer_groups(2, 3)
    assert len(groups) == 1
    assert groups[0]["key"] == "adjacent"
    assert groups[0]["title"] == "Смежные паспорта"
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert layers["adjacent_approval"]["name"] == "Смежный объект для согласования"
    assert layers["adjacent_approval"]["count"] == 2
    assert layers["adjacent_objects"]["name"] == "Смежные объекты"
    assert layers["adjacent_objects"]["count"] == 3


def test_build_adjacent_layer_groups_skips_zero_counts():
    assert build_adjacent_layer_groups(0, 0) == []
    groups = build_adjacent_layer_groups(1, 0)
    assert len(groups[0]["layers"]) == 1
    assert groups[0]["layers"][0]["key"] == "adjacent_approval"


@patch("approval.work_adjacent.connections")
def test_count_adjacent_features(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    cursor.fetchone.side_effect = [(1,), (2,), (0,), (1,), (0,), (0,)]

    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        n_count, v_count = count_adjacent_features("09811", ["10482", "09811"])

    assert n_count == 3
    assert v_count == 1


@patch("approval.work_adjacent.connections")
def test_build_adjacent_features_assigns_layer_keys(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    feature_n = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_APPROVAL,
            "sourceTable": "YardPoly",
            "fid": 1,
            "RootId": "09811",
        },
    }
    feature_v = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "OdhPoly",
            "fid": 2,
            "RootId": "10482",
        },
    }
    cursor.fetchall.side_effect = [[(feature_n,)], [(feature_v,)], [], [], [], []]

    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        with patch("approval.work_adjacent._adjacent_select_sql", return_value="SELECT 1"):
            with patch("approval.work_adjacent._style_fields_for_table", return_value=[]):
                features = build_adjacent_features(["09811"], ["10482", "09811"])

    assert len(features) == 2
    assert features[0]["properties"]["layerKey"] == LAYER_KEY_APPROVAL
    assert features[1]["properties"]["layerKey"] == LAYER_KEY_OBJECTS


@pytest.mark.django_db
def test_landing_with_adjacent_layers():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="adjacent_map_user", password="pass", owner_legal_person_id=owner_id)
    Approve.objects.create(
        incoming_guid=incoming_guid,
        owners=[owner_id],
        n_root=["09811"],
        v_root=["10482", "09811"],
    )

    adjacent_feature = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": [[[37.6, 55.75], [37.61, 55.75], [37.61, 55.76], [37.6, 55.76], [37.6, 55.75]]]},
        "properties": {
            "layerKey": LAYER_KEY_APPROVAL,
            "sourceTable": "YardPoly",
            "fid": 1,
            "RootId": "09811",
        },
    }

    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="adjacent_map_user")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch(
            "approval.views.build_work_feature_collection",
            return_value=({"type": "FeatureCollection", "features": []}, None),
        ):
            with patch("approval.views.count_adjacent_features", return_value=(1, 1)):
                with patch("approval.views.build_adjacent_features", return_value=[adjacent_feature]):
                    with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                        with patch("approval.views.load_svg_index", return_value={}):
                            with patch("approval.views.landing_page_config", return_value={}):
                                with patch(
                                    "approval.views.render",
                                    return_value=HttpResponse("ok"),
                                ) as mock_render:
                                    response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    layer_groups = context["layer_groups"]
    assert any(
        layer["name"] == "Смежный объект для согласования"
        for group in layer_groups
        for layer in group["layers"]
    )
    assert any(
        layer["name"] == "Смежные объекты"
        for group in layer_groups
        for layer in group["layers"]
    )
    assert any(feature["properties"]["layerKey"] == LAYER_KEY_APPROVAL for feature in context["map_geojson"]["features"])


@pytest.mark.django_db
def test_landing_without_owner_shows_message_unchanged():
    ExternalUser.objects.create(login="no_owner_adjacent", password="x", owner_legal_person_id=None)
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="no_owner_adjacent")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch(
            "approval.views.build_work_feature_collection",
            return_value=({"type": "FeatureCollection", "features": []}, None),
        ):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.build_adjacent_features", return_value=[]):
                    with patch("approval.views.landing_page_config", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            response = landing(request)

    assert response.status_code == 200
    assert "Не найден OwnerLegalPersonId" in mock_render.call_args[0][2]["map_message"]

"""Tests for approval map data loading."""

from __future__ import annotations

import uuid
from unittest.mock import MagicMock, patch

import pytest
from approval.access import get_accessible_approves, get_owner_id_for_username
from approval.models import Approve
from approval.views import landing
from approval.work_layers import build_layer_groups, count_features_by_table
from django.http import HttpResponse
from django.test import RequestFactory
from django.urls import reverse
from pass_viewer.models import ExternalUser


@pytest.mark.django_db
def test_get_owner_id_for_username():
    ExternalUser.objects.create(login="owner_user", password="x", owner_legal_person_id="10233594")
    assert get_owner_id_for_username("owner_user") == "10233594"
    assert get_owner_id_for_username("missing") is None


@pytest.mark.django_db
def test_get_accessible_approves_filters_by_owner():
    guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    Approve.objects.create(incoming_guid=guid, owners=["10233594"])
    Approve.objects.create(incoming_guid=uuid.uuid4(), owners=["99999999"])

    qs = get_accessible_approves("10233594")
    assert qs.count() == 1
    assert qs.first().incoming_guid == guid


def test_build_layer_groups_skips_zero_counts():
    groups = build_layer_groups({"DtsPoly": 12, "OznPoly": 0})
    assert len(groups) == 1
    assert groups[0]["key"] == "work"
    assert [layer["key"] for layer in groups[0]["layers"]] == ["DtsPoly"]


def test_build_layer_groups_uses_russian_labels_and_swatch():
    groups = build_layer_groups({"DtsPoly": 3})
    layer = groups[0]["layers"][0]
    assert layer["name"] == "Дорожно-тропиночная сеть"
    assert layer["geometry"] == "polygon"
    assert layer["show_swatch"] is True
    assert "borderColor" in layer["swatch_style"]
    assert "background" in layer["swatch_style"]
    assert groups[0]["title"] == "Объект согласования"


def test_build_layer_groups_hides_swatch_for_non_polygon_layers():
    groups = build_layer_groups({"AbutmentLine": 2})
    layer = groups[0]["layers"][0]
    assert layer["geometry"] == "line"
    assert layer["show_swatch"] is False
    assert layer["swatch_style"] == {}


def test_build_layer_groups_hides_task_and_yardpoly_by_default():
    groups = build_layer_groups({"task": 2, "YardPoly": 4, "DtsPoly": 1})
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert layers["task"]["checked"] is False
    assert layers["YardPoly"]["checked"] is False
    assert layers["DtsPoly"]["checked"] is True


def test_build_layer_groups_empty():
    assert build_layer_groups({}) == []


@patch("approval.work_layers.connections")
def test_count_features_by_table(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    with patch(
        "approval.work_layers.list_work_layer_tables",
        return_value=["DtsPoly", "OznPoly"],
    ):
        cursor.fetchone.side_effect = [(3,), (0,)]
        counts = count_features_by_table(["2e333940-831b-48f5-9751-acd0c2880974"])

    assert counts == {"DtsPoly": 3}


@pytest.mark.django_db
def test_landing_without_owner_shows_message():
    ExternalUser.objects.create(login="no_owner", password="x", owner_legal_person_id=None)
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="no_owner")

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
    context = mock_render.call_args[0][2]
    assert "Не найден OwnerLegalPersonId" in context["map_message"]
    assert context["map_geojson"]["type"] == "FeatureCollection"


@pytest.mark.django_db
def test_landing_with_approve_and_mock_qgis_layers():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="approval_map_user", password="pass", owner_legal_person_id=owner_id)
    Approve.objects.create(incoming_guid=incoming_guid, owners=[owner_id])

    feature = {
        "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [37.6, 55.75]},
        "properties": {
            "layerKey": "DtsPoly",
            "sourceTable": "DtsPoly",
            "taskGuid": str(incoming_guid),
            "fid": 1,
        },
    }
    with patch("approval.views.count_features_by_table", return_value={"DtsPoly": 1}):
        with patch(
            "approval.views.build_work_feature_collection",
            return_value=({"type": "FeatureCollection", "features": [feature]}, None),
        ):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.build_adjacent_features", return_value=[]):
                    with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                        with patch("approval.views.load_svg_index", return_value={"marker.svg": "marker.svg"}):
                            with patch("approval.views.landing_page_config", return_value={}):
                                with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                                    request = RequestFactory().get("/approval/")
                                    request.user = MagicMock(is_authenticated=True, username="approval_map_user")
                                    response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    layer_names = [layer["name"] for group in context["layer_groups"] for layer in group["layers"]]
    assert "Дорожно-тропиночная сеть" in layer_names
    assert context["map_geojson"]["features"][0]["properties"]["layerKey"] == "DtsPoly"


@pytest.mark.django_db
def test_landing_without_matching_approve_shows_empty_message():
    ExternalUser.objects.create(login="other_owner", password="pass", owner_legal_person_id="11111111")
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
    )

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch(
            "approval.views.build_work_feature_collection",
            return_value=({"type": "FeatureCollection", "features": []}, None),
        ):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.build_adjacent_features", return_value=[]):
                    with patch("approval.views.landing_page_config", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            request = RequestFactory().get("/approval/")
                            request.user = MagicMock(is_authenticated=True, username="other_owner")
                            response = landing(request)

    assert response.status_code == 200
    assert "Нет доступных согласований" in mock_render.call_args[0][2]["map_message"]

"""Tests for progressive approval map-layer API."""

from __future__ import annotations

import json
import uuid
from unittest.mock import MagicMock, patch

import pytest
from approval.models import Approve
from django.test import Client
from pass_viewer.models import ExternalUser


@pytest.mark.django_db
def test_api_map_layer_unknown_layer_returns_400():
    owner_id = "10233594"
    ExternalUser.objects.create(login="map_api_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(incoming_guid=uuid.uuid4(), owners=[owner_id])
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    client = Client()
    session = client.session
    session["_auth_user_id"] = "1"
    session.save()

    user = MagicMock(is_authenticated=True, username="map_api_user", pk=1)
    with patch("django.contrib.auth.middleware.get_user", return_value=user):
        with patch("approval.views.get_owner_id_for_username", return_value=owner_id):
            with patch("approval.views.get_accessible_approve", return_value=approve):
                response = client.post(
                    "/approval/api/map-layer/",
                    data=json.dumps({"approve_id": str(approve.id), "layer": "unknown"}),
                    content_type="application/json",
                )

    assert response.status_code == 400
    payload = response.json()
    assert payload["ok"] is False


@pytest.mark.django_db
def test_api_map_layer_work_chunk_returns_features():
    owner_id = "10233594"
    ExternalUser.objects.create(login="map_api_work", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(incoming_guid=uuid.uuid4(), owners=[owner_id])
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    feature = {
        "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [37.6, 55.75]},
        "properties": {"layerKey": "DtsPoly", "sourceTable": "DtsPoly", "fid": 1},
    }
    client = Client()
    user = MagicMock(is_authenticated=True, username="map_api_work", pk=1)
    with patch("django.contrib.auth.middleware.get_user", return_value=user):
        with patch("approval.views.get_owner_id_for_username", return_value=owner_id):
            with patch("approval.views.get_accessible_approve", return_value=approve):
                with patch(
                    "approval.map_load.build_work_feature_collection",
                    return_value=({"type": "FeatureCollection", "features": [feature]}, None),
                ):
                    response = client.post(
                        "/approval/api/map-layer/",
                        data=json.dumps({"approve_id": str(approve.id), "layer": "work:DtsPoly"}),
                        content_type="application/json",
                    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["layer"] == "work:DtsPoly"
    assert len(payload["features"]) == 1
    assert payload["features"][0]["properties"]["layerKey"] == "DtsPoly"


@pytest.mark.django_db
def test_api_map_layer_missing_approve_returns_404():
    ExternalUser.objects.create(login="map_api_404", password="pass", owner_legal_person_id="10233594")
    client = Client()
    user = MagicMock(is_authenticated=True, username="map_api_404", pk=1)
    with patch("django.contrib.auth.middleware.get_user", return_value=user):
        with patch("approval.views.get_owner_id_for_username", return_value="10233594"):
            with patch("approval.views.get_accessible_approve", return_value=None):
                response = client.post(
                    "/approval/api/map-layer/",
                    data=json.dumps({"approve_id": str(uuid.uuid4()), "layer": "dgi"}),
                    content_type="application/json",
                )

    assert response.status_code == 404

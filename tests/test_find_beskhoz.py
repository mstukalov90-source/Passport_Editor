"""Tests for ownerless-gap (beskhoz) search API."""

from __future__ import annotations

import json
from unittest.mock import patch

import pytest
from django.contrib.auth.models import User
from django.urls import reverse


@pytest.mark.django_db
def test_find_beskhoz_requires_login(client):
    response = client.post(
        reverse("find_beskhoz"),
        data=json.dumps({}),
        content_type="application/json",
    )
    assert response.status_code in (302, 401)


@pytest.mark.django_db
def test_find_beskhoz_requires_geometry(client):
    user = User.objects.create_user(username="beskhoz_user", password="pass")
    client.force_login(user)
    response = client.post(
        reverse("find_beskhoz"),
        data=json.dumps({}),
        content_type="application/json",
    )
    assert response.status_code == 400
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_find_beskhoz_ok(client):
    user = User.objects.create_user(username="beskhoz_user2", password="pass")
    client.force_login(user)
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.7]]],
    }
    gap = {
        "type": "Polygon",
        "coordinates": [[[37.61, 55.7], [37.62, 55.7], [37.62, 55.71], [37.61, 55.7]]],
    }
    fake_features = [{"geometry": gap, "area_m2": 120.0, "pct": 2.5}]
    with patch("pass_viewer.views._find_beskhoz_features", return_value=fake_features):
        response = client.post(
            reverse("find_beskhoz"),
            data=json.dumps({"geometry": geometry}),
            content_type="application/json",
        )
    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert len(data["features"]) == 1
    assert data["features"][0]["pct"] == 2.5
    assert data["features"][0]["geometry"]["type"] == "Polygon"

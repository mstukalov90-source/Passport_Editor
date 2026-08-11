"""Tests for DGI export gate (hidden check before file export)."""

from unittest.mock import patch

import pytest
from django.contrib.auth.models import User
from django.test import Client

from pass_viewer.dgi_layers import finalize_dgi_aprove_record, normalize_dgi_aprove_payload


def test_normalize_dgi_aprove_accepts_private_over_10():
    raw = {
        "approved_at": "2026-06-04T10:00:00+00:00",
        "percent": 12.5,
        "ownership": "private",
    }
    parsed = normalize_dgi_aprove_payload(raw, "tester")
    assert parsed is not None
    assert parsed["percent"] == 12.5
    assert parsed["ownership"] == "private"
    final = finalize_dgi_aprove_record(parsed, "tester")
    assert final["user"] == "tester"
    assert "approved_at" in final


def test_normalize_dgi_aprove_rejects_at_or_below_10():
    assert normalize_dgi_aprove_payload({"percent": 10, "ownership": "private"}, "u") is None
    assert normalize_dgi_aprove_payload({"percent": 5, "ownership": "private"}, "u") is None


def test_normalize_dgi_aprove_rejects_non_private():
    assert normalize_dgi_aprove_payload({"percent": 15, "ownership": "moscow"}, "u") is None


@pytest.mark.django_db
def test_check_dgi_intersections_for_export_unavailable(client):
    user = User.objects.create_user(username="dgi_export_user", password="pass")
    client.force_login(user)
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.71], [37.6, 55.7]]],
    }
    with patch(
        "pass_viewer.views._get_dgi_intersection_percents_split",
        side_effect=RuntimeError("db down"),
    ):
        response = client.post(
            "/add-object/check-dgi-intersections/",
            data='{"geometry": ' + __import__("json").dumps(geometry) + ', "for_export": true}',
            content_type="application/json",
        )
    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data.get("available") is False


@pytest.mark.django_db
def test_check_dgi_intersections_for_export_success(client):
    user = User.objects.create_user(username="dgi_export_user2", password="pass")
    client.force_login(user)
    geometry = {"type": "Polygon", "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 0]]]}
    with patch(
        "pass_viewer.views._get_dgi_intersection_percents_split",
        return_value={
            "moscow": 0.0,
            "private": 12.34,
            "dgi_moscow_rent": 0.0,
            "dgi_moscow_no_rent": 0.0,
            "dgi_private_rent": 0.0,
            "dgi_private_no_rent": 12.34,
            "dgi_renovation": 0.0,
            "renew": 0.0,
            "oozt": 0.0,
            "rzd": 0.0,
        },
    ):
        response = client.post(
            "/add-object/check-dgi-intersections/",
            data=__import__("json").dumps({"geometry": geometry, "for_export": True}),
            content_type="application/json",
        )
    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["available"] is True
    assert data["percent_private"] == 12.34

"""Tests for spatial intersection analysis page and data API."""

from __future__ import annotations

import json
from unittest.mock import patch

import pytest
from django.contrib.auth.models import User
from django.urls import reverse


@pytest.mark.django_db
def test_intersecs_analiz_page_requires_login(client):
    response = client.get(reverse("intersecs_analiz"))
    assert response.status_code in (302, 401)


@pytest.mark.django_db
def test_intersecs_analiz_page_ok(client):
    user = User.objects.create_user(username="analiz_user", password="pass")
    client.force_login(user)
    response = client.get(reverse("intersecs_analiz"))
    assert response.status_code == 200
    html = response.content.decode("utf-8")
    assert "Пространственный анализ пересечений" in html
    assert "intersecs-analiz-map" in html
    assert "intersecsAnalizData" in html


@pytest.mark.django_db
def test_intersecs_analiz_data_requires_geometry(client):
    user = User.objects.create_user(username="analiz_user2", password="pass")
    client.force_login(user)
    response = client.post(
        reverse("intersecs_analiz_data"),
        data=json.dumps({}),
        content_type="application/json",
    )
    assert response.status_code == 400
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_intersecs_analiz_data_ok(client):
    user = User.objects.create_user(username="analiz_user3", password="pass")
    client.force_login(user)
    geometry = {"type": "Polygon", "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.7]]]}
    percents = {
        "moscow": 0.0,
        "private": 4.5,
        "dgi_moscow_rent": 0.0,
        "dgi_moscow_no_rent": 0.0,
        "dgi_private_rent": 0.0,
        "dgi_private_no_rent": 4.5,
        "dgi_renovation": 0.0,
        "renew": 0.0,
        "oozt": 0.0,
        "rzd": 0.0,
    }
    fake_layers = [
        {
            "key": "dgi_private_no_rent",
            "label": "З/У Частная или федеральная собственность без аренды",
            "percent": 4.5,
            "objects": [
                {
                    "id": 0,
                    "descr": "77:01:0000000:1",
                    "address": "тест",
                    "vri": "",
                    "name": "",
                    "owner": "",
                    "pct": 4.5,
                    "intersection_area_m2": 12.0,
                    "geometry": geometry,
                    "intersection_geometry": geometry,
                }
            ],
        }
    ]
    with patch(
        "pass_viewer.views._get_dgi_intersection_percents_split",
        return_value=percents,
    ), patch(
        "pass_viewer.views._analiz_layers_for_geometry",
        return_value=fake_layers,
    ):
        response = client.post(
            reverse("intersecs_analiz_data"),
            data=json.dumps({"geometry": geometry}),
            content_type="application/json",
        )
    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["percent_private_no_rent"] == 4.5
    assert data["selected_geometry"]["type"] == "Polygon"
    assert data["layers"][0]["objects"][0]["descr"] == "77:01:0000000:1"

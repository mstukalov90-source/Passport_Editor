"""Tests for spatial intersection analysis page and data API."""

from __future__ import annotations

import json
from unittest.mock import patch

import pytest
from django.contrib.auth.models import User
from django.urls import reverse

from pass_viewer.views import _balance_holder_display, _ogx_analiz_layers_for_geometry


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
    assert "owned-map-legend" in html
    assert "Область пересечения" in html
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
    fake_ogx_layers = [
        {
            "key": "ogx_dt",
            "label": "ДТ",
            "percent": 12.0,
            "objects": [
                {
                    "id": 0,
                    "descr": "77:01:0000000:2",
                    "address": "тест ОГХ",
                    "vri": "",
                    "name": "Зацепа ул. 32",
                    "owner": "",
                    "balance_holder": "Жилищник Замоскворечье",
                    "pct": 12.0,
                    "intersection_area_m2": 120.0,
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
    ), patch(
        "pass_viewer.views._get_ogx_intersection_percents",
        return_value={"dt": 12.0, "odh": 5.0, "oo": 0.0, "top": 0.0},
    ) as ogx_percents_mock, patch(
        "pass_viewer.views._ogx_analiz_layers_for_geometry",
        return_value=fake_ogx_layers,
    ):
        response = client.post(
            reverse("intersecs_analiz_data"),
            data=json.dumps({"geometry": geometry, "rootid": "77-001"}),
            content_type="application/json",
        )
    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["percent_private_no_rent"] == 4.5
    assert data["selected_geometry"]["type"] == "Polygon"
    assert data["layers"][0]["objects"][0]["descr"] == "77:01:0000000:1"
    assert data["ogx"]["percent_dt"] == 12.0
    assert data["ogx"]["percent_odh"] == 5.0
    assert data["ogx"]["intersects"] is True
    assert data["ogx_layers"][0]["key"] == "ogx_dt"
    assert data["ogx_layers"][0]["objects"][0]["descr"] == "77:01:0000000:2"
    assert data["ogx_layers"][0]["objects"][0]["balance_holder"] == "Жилищник Замоскворечье"
    ogx_call = ogx_percents_mock.call_args
    assert ogx_call.args[0]["type"] == "Polygon"
    assert ogx_call.kwargs.get("rootid") == "77-001"
    assert ogx_call.kwargs.get("request_id") == ""


def test_balance_holder_display_prefers_owner_then_customer():
    # Как в попапе редактора: владелец (имя, иначе id), иначе заказчик (имя, иначе id).
    assert _balance_holder_display("77:001", "Жилищник Замоскворечье", "55:002", "Заказчик") == (
        "Жилищник Замоскворечье"
    )
    assert _balance_holder_display("77:001", None, "55:002", "Заказчик") == "77:001"
    assert _balance_holder_display(None, None, "55:002", "ГУЖ района") == "ГУЖ района"
    assert _balance_holder_display(None, None, "55:002", "") == "55:002"
    assert _balance_holder_display(None, None, None, None) == ""
    assert _balance_holder_display("-", "null", "none", "") == ""


@pytest.mark.django_db
def test_ogx_analiz_layers_for_geometry_builds_four_layers():
    geometry = {"type": "Polygon", "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.7]]]}
    percents = {"dt": 12.0, "odh": 5.0, "oo": 0.0, "top": 0.34}

    def fake_features(geometry_arg, table_name, extra_where_sql="", *, table_alias="d", extra_where_params=()):
        return [
            {
                "id": 0,
                "table": table_name,
                "extra_where": extra_where_sql,
                "extra_params": list(extra_where_params),
            }
        ]

    with patch(
        "pass_viewer.views._ogx_self_exclude_sql",
        return_value=(' AND NOT (d."RootId"::text = %s)', ["77-001"]),
    ) as exclude_mock, patch(
        "pass_viewer.views._list_layer_intersection_features",
        side_effect=fake_features,
    ) as features_mock:
        layers = _ogx_analiz_layers_for_geometry(geometry, percents, rootid="77-001", request_id="")

    assert [layer["key"] for layer in layers] == ["ogx_dt", "ogx_odh", "ogx_oo", "ogx_top"]
    assert [layer["label"] for layer in layers] == ["ДТ", "ОДХ", "ОО", "ТОП"]
    assert [layer["percent"] for layer in layers] == [12.0, 5.0, 0.0, 0.34]
    assert exclude_mock.call_count == 4
    assert exclude_mock.call_args.kwargs.get("table_alias") == "d"
    assert all(layer["objects"][0]["extra_params"] == ["77-001"] for layer in layers)
    assert all(layer["objects"][0]["extra_where"] for layer in layers)
    assert features_mock.call_count == 4

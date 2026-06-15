"""Tests for owned recap list/export/delete API."""

from __future__ import annotations

import json
from unittest.mock import MagicMock, patch

import pytest
from django.contrib.auth.models import User
from django.test import RequestFactory
from django.urls import reverse

from pass_viewer.models import ExternalUser
from pass_viewer.views import _get_recap_counts_by_request_ids, delete_recap_object


@pytest.mark.django_db
def test_list_owned_recaps_requires_login(client):
    response = client.get(reverse("list_owned_recaps"), {"request_id": "123"})
    assert response.status_code == 302
    assert "/accounts/login/" in response.url


@pytest.mark.django_db
def test_list_owned_recaps_success(client):
    user = User.objects.create_user(username="recap_list_user", password="pass")
    ExternalUser.objects.create(login="recap_list_user", password="pass", owner_legal_person_id="OWNER_A")
    client.force_login(user)

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_recaps_for_request",
        return_value=[
            {"recap_id": "101", "request_id": "123", "name": "Test recap"},
        ],
    ):
        response = client.get(reverse("list_owned_recaps"), {"request_id": "123"})

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["request_id"] == "123"
    assert data["recaps"] == [{"recap_id": "101", "request_id": "123", "name": "Test recap"}]


@pytest.mark.django_db
def test_list_owned_recaps_rejects_invalid_request_id(client):
    user = User.objects.create_user(username="recap_list_user2", password="pass")
    client.force_login(user)

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"):
        response = client.get(reverse("list_owned_recaps"), {"request_id": "abc"})

    assert response.status_code == 400
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_export_recap_geometry_success(client):
    user = User.objects.create_user(username="recap_export_user", password="pass")
    client.force_login(user)
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.71], [37.6, 55.7]]],
    }
    recap_row = {
        "recap_id": "55",
        "request_id": "9001",
        "name": "Recap object",
        "geometry_json": json.dumps(geometry),
    }

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_recap_row",
        return_value=recap_row,
    ), patch(
        "pass_viewer.views._export_geometry_files",
        return_value=("/media/exports/a/file.geojson", "/media/exports/a/file_shp.zip"),
    ):
        response = client.post(
            reverse("export_recap_geometry"),
            data=json.dumps({"recap_id": "55"}),
            content_type="application/json",
        )

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["geojson_url"].endswith(".geojson")
    assert data["shapefile_url"].endswith("_shp.zip")


@pytest.mark.django_db
def test_export_recap_geometry_not_found(client):
    user = User.objects.create_user(username="recap_export_user2", password="pass")
    client.force_login(user)

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_recap_row",
        return_value=None,
    ):
        response = client.post(
            reverse("export_recap_geometry"),
            data=json.dumps({"recap_id": "999"}),
            content_type="application/json",
        )

    assert response.status_code == 404
    assert response.json()["ok"] is False


def test_delete_recap_object_success():
    request = RequestFactory().post(
        "/owned/recaps/delete/",
        data=json.dumps({"recap_id": "77"}),
        content_type="application/json",
    )
    request.user = MagicMock(is_authenticated=True, username="recap_delete_user")

    cursor = MagicMock()
    cursor.fetchone.return_value = ("77",)

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_recap_row",
        return_value={"recap_id": "77", "request_id": "1", "name": "x", "geometry_json": "{}"},
    ), patch("pass_viewer.views.connection.cursor") as cursor_ctx, patch(
        "pass_viewer.views._recaps_owner_scope_columns",
        return_value=("OwnerLegalPersonId", "request_id", "name", "geom", "", []),
    ):
        cursor_ctx.return_value.__enter__.return_value = cursor
        response = delete_recap_object(request)

    assert response.status_code == 200
    assert json.loads(response.content) == {"ok": True, "recap_id": "77"}
    cursor.execute.assert_called_once()


@pytest.mark.django_db
def test_delete_recap_object_not_found(client):
    user = User.objects.create_user(username="recap_delete_user2", password="pass")
    client.force_login(user)

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_recap_row",
        return_value=None,
    ):
        response = client.post(
            reverse("delete_recap_object"),
            data=json.dumps({"recap_id": "404"}),
            content_type="application/json",
        )

    assert response.status_code == 404
    assert response.json()["ok"] is False


def test_get_recap_counts_by_request_ids_includes_owner_filter():
    cursor = MagicMock()
    cursor.fetchall.return_value = [("100", 2)]
    cursor_ctx = MagicMock()
    cursor_ctx.__enter__.return_value = cursor

    with patch("pass_viewer.views.connection.cursor", return_value=cursor_ctx), patch(
        "pass_viewer.views._recaps_owner_scope_columns",
        return_value=("OwnerLegalPersonId", "request_id", "name", "geom", " AND hood_ok", ["hood"]),
    ):
        result = _get_recap_counts_by_request_ids("OWNER_A", ["100", "200"])

    assert result == {"100": 2}
    query, params = cursor.execute.call_args[0]
    assert "OwnerLegalPersonId" in query
    assert "GROUP BY" in query
    assert params == ["OWNER_A", ["100", "200"], "hood"]

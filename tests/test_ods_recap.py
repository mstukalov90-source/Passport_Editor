"""Tests for ODS request recap entry (add_recap from ods_request rows)."""

from __future__ import annotations

from unittest.mock import patch

import pytest
from django.contrib.auth.models import User
from django.urls import reverse

from pass_viewer.models import ExternalUser
from pass_viewer.views import (
    _get_owned_ods_request_for_recap,
    _parse_ods_request_object_key,
)


def test_parse_ods_request_object_key():
    assert _parse_ods_request_object_key("ods_request:42") == "42"
    assert _parse_ods_request_object_key("ods_request:0") == "0"
    assert _parse_ods_request_object_key("ctid:123") is None
    assert _parse_ods_request_object_key("ods_request:abc") is None
    assert _parse_ods_request_object_key("") is None
    assert _parse_ods_request_object_key(None) is None


def test_get_owned_ods_request_for_recap_success():
    geom = '{"type":"Polygon","coordinates":[]}'
    with patch("pass_viewer.views.connection") as mock_conn, patch(
        "pass_viewer.views._table_exists", return_value=True
    ), patch("pass_viewer.views._column_exists", return_value=True), patch(
        "pass_viewer.views._resolve_column_name", side_effect=lambda _c, _t, name: name
    ), patch("pass_viewer.views._find_gis_geometry_for_ods_short_root", return_value=geom):
        cursor = mock_conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = ("9001", "ODS object", "ROOT1")

        result = _get_owned_ods_request_for_recap("OWNER_A", "ods_request:7")

    assert result == {
        "object_key": "ods_request:7",
        "rootid": "",
        "name": "ODS object",
        "request_id": "9001",
        "geometry_json": geom,
        "source_label": "ОДС",
    }


def test_get_owned_ods_request_for_recap_no_geometry():
    with patch("pass_viewer.views.connection") as mock_conn, patch(
        "pass_viewer.views._table_exists", return_value=True
    ), patch("pass_viewer.views._column_exists", return_value=True), patch(
        "pass_viewer.views._resolve_column_name", side_effect=lambda _c, _t, name: name
    ), patch(
        "pass_viewer.views._find_gis_geometry_for_ods_short_root", return_value=None
    ):
        cursor = mock_conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = ("9001", "ODS object", "ROOT1")

        result = _get_owned_ods_request_for_recap("OWNER_A", "ods_request:7")

    assert result is not None
    assert result["request_id"] == "9001"
    assert result["geometry_json"] is None


def test_get_owned_ods_request_for_recap_wrong_owner():
    with patch("pass_viewer.views.connection") as mock_conn, patch(
        "pass_viewer.views._table_exists", return_value=True
    ), patch("pass_viewer.views._column_exists", return_value=True), patch(
        "pass_viewer.views._resolve_column_name", side_effect=lambda _c, _t, name: name
    ):
        cursor = mock_conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = None

        result = _get_owned_ods_request_for_recap("OWNER_A", "ods_request:7")

    assert result is None


@pytest.mark.django_db
def test_add_recap_ods_with_geometry(client):
    user = User.objects.create_user(username="ods_recap_user", password="pass")
    ExternalUser.objects.create(login="ods_recap_user", password="pass", owner_legal_person_id="OWNER_A")
    client.force_login(user)

    selected = {
        "object_key": "ods_request:1",
        "rootid": "",
        "name": "ODS test",
        "request_id": "5555",
        "geometry_json": '{"type":"Polygon","coordinates":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}',
        "source_label": "ОДС",
    }
    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_ods_request_for_recap", return_value=selected
    ), patch("pass_viewer.views._get_reference_layers", return_value={
        "dgi_moscow_rent": None,
        "dgi_moscow_no_rent": None,
        "dgi_private_rent": None,
        "dgi_private_no_rent": None,
        "dgi_renovation": None,
        "odh": None,
        "ozn": None,
        "renew": None,
        "recaps": None,
        "oozt": None,
        "rzd": None,
        "top": None,
    }), patch(
        "pass_viewer.views._get_new_object_relations",
        return_value={"intersects": None, "touches": None, "nearby": None, "request_objects": None},
    ):
        response = client.get(
            reverse("add_recap"),
            {
                "object_key": "ods_request:1",
                "source_label": "ОДС",
                "request_id": "5555",
                "name": "ODS test",
            },
        )

    assert response.status_code == 200
    assert "Добавление досъёма" in response.content.decode()


@pytest.mark.django_db
def test_add_recap_ods_without_geometry_redirects(client):
    user = User.objects.create_user(username="ods_recap_user2", password="pass")
    ExternalUser.objects.create(login="ods_recap_user2", password="pass", owner_legal_person_id="OWNER_A")
    client.force_login(user)

    selected = {
        "object_key": "ods_request:1",
        "rootid": "",
        "name": "ODS test",
        "request_id": "5555",
        "geometry_json": None,
        "source_label": "ОДС",
    }
    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_ods_request_for_recap", return_value=selected
    ):
        response = client.get(
            reverse("add_recap"),
            {"object_key": "ods_request:1", "source_label": "ОДС"},
        )

    assert response.status_code == 302
    assert response.url == reverse("home")


@pytest.mark.django_db
def test_add_recap_ods_wrong_owner_redirects(client):
    user = User.objects.create_user(username="ods_recap_user3", password="pass")
    ExternalUser.objects.create(login="ods_recap_user3", password="pass", owner_legal_person_id="OWNER_A")
    client.force_login(user)

    with patch("pass_viewer.views._get_current_user_owner_id", return_value="OWNER_A"), patch(
        "pass_viewer.views._get_owned_ods_request_for_recap", return_value=None
    ):
        response = client.get(
            reverse("add_recap"),
            {"object_key": "ods_request:99", "source_label": "ОДС"},
        )

    assert response.status_code == 302
    assert response.url == reverse("home")

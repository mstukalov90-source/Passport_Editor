"""Tests for QGIS read-only layers API (drawn site requests and recaps)."""

from __future__ import annotations

import json
from contextlib import ExitStack
from unittest.mock import MagicMock, patch

import pytest
from django.urls import reverse
from pass_viewer.models import ExternalUser
from pass_viewer.qgis_layers import (
    build_recaps_layer_geojson,
    build_recaps_list,
    build_requests_layer_geojson,
    build_requests_list,
)

HOST_OK = "172.21.197.77"

FEATURE_COLLECTION = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.7]]],
            },
            "properties": {"request_id": "141564"},
        }
    ],
}

RECAPS_COLLECTION = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.7]]],
            },
            "properties": {"recap_id": "77", "request_id": "141564"},
        }
    ],
}


@pytest.fixture(autouse=True)
def qgis_test_hosts(settings):
    settings.ALLOWED_HOSTS = [HOST_OK, "testserver"]


def _get(url_name, **params):
    from django.test import Client

    return Client().get(reverse(url_name), params, HTTP_HOST=HOST_OK)


def _make_staff(login, role):
    ExternalUser.objects.create(login=login, password="pass", role=role)


# --- доступ ---------------------------------------------------------------


@pytest.mark.django_db
def test_requests_layer_host_forbidden(settings):
    settings.APPROVAL_QGIS_ALLOWED_HOSTS = ["other.example"]
    response = _get("api_qgis_requests_layer", user="someuser")
    assert response.status_code == 403
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_recaps_layer_host_forbidden(settings):
    settings.APPROVAL_QGIS_ALLOWED_HOSTS = ["other.example"]
    response = _get("api_qgis_recaps_layer", user="someuser")
    assert response.status_code == 403
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_requests_layer_requires_user():
    response = _get("api_qgis_requests_layer")
    assert response.status_code == 400
    assert "user" in response.json()["error"]


@pytest.mark.django_db
def test_recaps_layer_requires_user():
    response = _get("api_qgis_recaps_layer")
    assert response.status_code == 400


@pytest.mark.django_db
def test_requests_layer_denies_non_staff():
    _make_staff("owner_user", "BD")
    response = _get("api_qgis_requests_layer", user="owner_user")
    assert response.status_code == 403
    assert response.json()["ok"] is False


@pytest.mark.django_db
@pytest.mark.parametrize("role", ["DEP", "DEP+"])
def test_requests_layer_denies_external_roles(role):
    _make_staff("dep_user", role)
    response = _get("api_qgis_requests_layer", user="dep_user")
    assert response.status_code == 403


@pytest.mark.django_db
def test_requests_layer_denies_unknown_login():
    response = _get("api_qgis_requests_layer", user="ghost")
    assert response.status_code == 403


# --- слой заявок -----------------------------------------------------------


@pytest.mark.django_db
@pytest.mark.parametrize("role", ["MGGT", "SUP"])
def test_requests_layer_success(role):
    _make_staff("staff_user", role)
    with patch(
        "pass_viewer.qgis_api_views.build_requests_layer_geojson",
        return_value=dict(FEATURE_COLLECTION),
    ) as builder:
        response = _get("api_qgis_requests_layer", user="staff_user")

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["current_user"] == "staff_user"
    assert data["type"] == "FeatureCollection"
    assert data["features"][0]["properties"]["request_id"] == "141564"
    builder.assert_called_once_with(request_id=None, source=None)


@pytest.mark.django_db
def test_requests_layer_passes_filters():
    _make_staff("staff_user", "MGGT")
    with patch(
        "pass_viewer.qgis_api_views.build_requests_layer_geojson",
        return_value=dict(FEATURE_COLLECTION),
    ) as builder:
        response = _get(
            "api_qgis_requests_layer",
            user="staff_user",
            request_id="141564",
            source="ДТ",
        )

    assert response.status_code == 200
    builder.assert_called_once_with(request_id="141564", source="ДТ")


@pytest.mark.django_db
def test_requests_layer_normalizes_source_alias():
    _make_staff("staff_user", "MGGT")
    with patch(
        "pass_viewer.qgis_api_views.build_requests_layer_geojson",
        return_value=dict(FEATURE_COLLECTION),
    ) as builder:
        response = _get("api_qgis_requests_layer", user="staff_user", source="top")

    assert response.status_code == 200
    builder.assert_called_once_with(request_id=None, source="ТОП")


@pytest.mark.django_db
def test_requests_layer_rejects_bad_request_id():
    _make_staff("staff_user", "MGGT")
    response = _get("api_qgis_requests_layer", user="staff_user", request_id="14a564")
    assert response.status_code == 400


@pytest.mark.django_db
def test_requests_layer_rejects_unknown_source():
    _make_staff("staff_user", "MGGT")
    response = _get("api_qgis_requests_layer", user="staff_user", source="XXX")
    assert response.status_code == 400
    assert "source" in response.json()["error"]


@pytest.mark.django_db
def test_requests_layer_db_error_returns_500():
    _make_staff("staff_user", "MGGT")
    with patch(
        "pass_viewer.qgis_api_views.build_requests_layer_geojson",
        side_effect=RuntimeError("boom"),
    ):
        response = _get("api_qgis_requests_layer", user="staff_user")
    assert response.status_code == 500
    assert response.json()["ok"] is False


# --- слой досъёмов ---------------------------------------------------------


@pytest.mark.django_db
def test_recaps_layer_success():
    _make_staff("staff_user", "SUP")
    with patch(
        "pass_viewer.qgis_api_views.build_recaps_layer_geojson",
        return_value=dict(RECAPS_COLLECTION),
    ) as builder:
        response = _get(
            "api_qgis_recaps_layer", user="staff_user", request_id="141564", recap_id="77"
        )

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["current_user"] == "staff_user"
    assert data["features"][0]["properties"]["recap_id"] == "77"
    builder.assert_called_once_with(request_id="141564", recap_id="77")


@pytest.mark.django_db
def test_recaps_layer_rejects_bad_recap_id():
    _make_staff("staff_user", "MGGT")
    response = _get("api_qgis_recaps_layer", user="staff_user", recap_id="7a7")
    assert response.status_code == 400


@pytest.mark.django_db
def test_recaps_layer_db_error_returns_500():
    _make_staff("staff_user", "MGGT")
    with patch(
        "pass_viewer.qgis_api_views.build_recaps_layer_geojson",
        side_effect=RuntimeError("boom"),
    ):
        response = _get("api_qgis_recaps_layer", user="staff_user")
    assert response.status_code == 500



# --- билдеры слоёв (mocked SQL) ---------------------------------------------


def _mock_cursor(fetch_row):
    cursor = MagicMock()
    cursor.fetchone.return_value = fetch_row
    return cursor


def _patched_request_sql(conn, cursor, specs, *, request_only_sql=""):
    conn.cursor.return_value.__enter__.return_value = cursor
    patches = [
        patch("pass_viewer.qgis_layers.connection", conn),
        patch("pass_viewer.qgis_layers._gis_municipal_table_specs", return_value=specs),
        patch(
            "pass_viewer.qgis_layers._resolve_request_layer_columns",
            return_value={
                "geom": "geom", "request_id": "request_id", "rootid": "rootid", "name": "name"
            },
        ),
        patch("pass_viewer.qgis_layers._sql_gis_request_only_clause", return_value=request_only_sql),
        patch(
            "pass_viewer.qgis_layers._gis_object_meta_sql_fragment",
            return_value="NULL::text AS startdate, NULL::text AS datesurvey, NULL::text AS createtype",
        ),
        patch("pass_viewer.qgis_layers._get_id_names_lookup_context", return_value=None),
        patch("pass_viewer.qgis_layers._column_exists", return_value=True),
        patch("pass_viewer.qgis_layers._resolve_column_name", side_effect=lambda c, t, p: p),
    ]
    return patches


def test_build_requests_layer_geojson_sql_and_params():
    cursor = _mock_cursor((json.dumps(FEATURE_COLLECTION),))
    specs = [("ДТ", "pass_objects", ["OwnerLegalPersonId"])]
    conn = MagicMock()
    with ExitStack() as stack:
        for item in _patched_request_sql(conn, cursor, specs, request_only_sql=" AND t.request_id IS NOT NULL"):
            stack.enter_context(item)
        result = build_requests_layer_geojson(request_id="141564", source=None)

    assert result["type"] == "FeatureCollection"
    assert result["features"][0]["properties"]["request_id"] == "141564"

    last_call = cursor.execute.call_args_list[-1]
    sql, execute_params = last_call.args
    assert 'FROM "pass_objects" t' in sql
    assert "UNION ALL" not in sql
    assert 'AND t."request_id"::text = %s' in sql
    assert "ST_AsGeoJSON(geom)::jsonb" in sql
    assert execute_params == ["141564"]


def test_build_requests_layer_geojson_filters_source():
    cursor = _mock_cursor((json.dumps(FEATURE_COLLECTION),))
    specs = [
        ("ДТ", "pass_objects", ["OwnerLegalPersonId"]),
        ("ТОП", "top", ["OwnerLegalPersonId"]),
    ]
    conn = MagicMock()
    with ExitStack() as stack:
        for item in _patched_request_sql(conn, cursor, specs):
            stack.enter_context(item)
        build_requests_layer_geojson(source="ТОП")

    sql = cursor.execute.call_args_list[-1].args[0]
    assert 'FROM "top" t' in sql
    assert "pass_objects" not in sql


def test_build_requests_layer_geojson_unions_all_sources():
    cursor = _mock_cursor((json.dumps(FEATURE_COLLECTION),))
    specs = [
        ("ДТ", "pass_objects", ["OwnerLegalPersonId"]),
        ("ОДХ", "odh", ["CustomerLegalPersonId", "OwnerLegalPersonId"]),
    ]
    conn = MagicMock()
    with ExitStack() as stack:
        for item in _patched_request_sql(conn, cursor, specs):
            stack.enter_context(item)
        build_requests_layer_geojson()

    sql = cursor.execute.call_args_list[-1].args[0]
    assert 'FROM "pass_objects" t' in sql
    assert 'FROM "odh" t' in sql
    assert "UNION ALL" in sql


@pytest.mark.django_db
def test_build_requests_layer_geojson_no_sources_ready():
    with patch("pass_viewer.qgis_layers._gis_municipal_table_specs", return_value=[]):
        result = build_requests_layer_geojson()

    assert result == {"type": "FeatureCollection", "features": []}


def test_build_recaps_layer_geojson_sql_and_params():
    cursor = _mock_cursor((json.dumps(RECAPS_COLLECTION),))
    conn = MagicMock()
    with patch("pass_viewer.qgis_layers.connection", conn), patch(
        "pass_viewer.qgis_layers._table_exists", return_value=True
    ), patch(
        "pass_viewer.qgis_layers._column_exists", return_value=True
    ), patch(
        "pass_viewer.qgis_layers._resolve_column_name", side_effect=lambda c, t, p: p
    ), patch(
        "pass_viewer.qgis_layers._get_id_names_lookup_context", return_value=None
    ):
        conn.cursor.return_value.__enter__.return_value = cursor
        result = build_recaps_layer_geojson(request_id="141564", recap_id="77")

    assert result["features"][0]["properties"]["recap_id"] == "77"

    last_call = cursor.execute.call_args_list[-1]
    sql, execute_params = last_call.args
    assert "FROM recaps t" in sql
    assert 't."request_id"::text = %s' in sql
    assert "t.recap_id::text = %s" in sql
    assert execute_params == ["141564", "77"]


def test_build_recaps_layer_geojson_without_filters():
    cursor = _mock_cursor((json.dumps(RECAPS_COLLECTION),))
    conn = MagicMock()
    with patch("pass_viewer.qgis_layers.connection", conn), patch(
        "pass_viewer.qgis_layers._table_exists", return_value=True
    ), patch(
        "pass_viewer.qgis_layers._column_exists", return_value=True
    ), patch(
        "pass_viewer.qgis_layers._resolve_column_name", side_effect=lambda c, t, p: p
    ), patch(
        "pass_viewer.qgis_layers._get_id_names_lookup_context", return_value=None
    ):
        conn.cursor.return_value.__enter__.return_value = cursor
        result = build_recaps_layer_geojson()

    last_call = cursor.execute.call_args_list[-1]
    sql, execute_params = last_call.args
    assert execute_params == []
    assert "WHERE" not in sql


def test_build_recaps_layer_geojson_without_table():
    conn = MagicMock()
    with patch("pass_viewer.qgis_layers.connection", conn), patch(
        "pass_viewer.qgis_layers._table_exists", return_value=False
    ):
        result = build_recaps_layer_geojson()

    assert result == {"type": "FeatureCollection", "features": []}
    conn.cursor.return_value.__enter__.return_value.execute.assert_not_called()


# --- списки (без геометрии) ---------------------------------------------------


REQUEST_ITEMS = [
    {
        "source": "ДТ",
        "request_id": "141564",
        "rootid": None,
        "name": "Заявка 141564",
        "owner_legal_person_id": "9000022",
        "owner_legal_person_name": "ООО Пример",
        "customer_legal_person_id": None,
        "customer_legal_person_name": None,
        "department_legal_person_id": None,
        "department_legal_person_name": None,
        "startdate": None,
        "datesurvey": None,
        "createtype": None,
    },
    {
        "source": "ТОП",
        "request_id": "005",
        "rootid": None,
        "name": "Заявка 005",
        "owner_legal_person_id": "9000031",
        "owner_legal_person_name": "ООО Другая",
        "customer_legal_person_id": None,
        "customer_legal_person_name": None,
        "department_legal_person_id": None,
        "department_legal_person_name": None,
        "startdate": None,
        "datesurvey": None,
        "createtype": None,
    },
]

RECAP_ITEMS = [
    {"recap_id": "77", "request_id": "141564", "name": "Досъём 77", "owner_legal_person_id": "9000022", "owner_legal_person_name": "ООО Пример"},
    {"recap_id": "78", "request_id": "141564", "name": "Досъём 78", "owner_legal_person_id": "9000022", "owner_legal_person_name": "ООО Пример"},
]


@pytest.mark.django_db
def test_requests_list_success():
    _make_staff("staff_user", "MGGT")
    with patch(
        "pass_viewer.qgis_api_views.build_requests_list",
        return_value=[dict(item) for item in REQUEST_ITEMS],
    ) as builder:
        response = _get("api_qgis_requests_list", user="staff_user")

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["current_user"] == "staff_user"
    assert data["count"] == 2
    assert data["requests"][0]["request_id"] == "141564"
    assert data["requests"][1]["source"] == "ТОП"
    builder.assert_called_once_with(request_id=None, source=None)


@pytest.mark.django_db
def test_requests_list_passes_filters():
    _make_staff("staff_user", "SUP")
    with patch(
        "pass_viewer.qgis_api_views.build_requests_list",
        return_value=[dict(REQUEST_ITEMS[0])],
    ) as builder:
        response = _get(
            "api_qgis_requests_list", user="staff_user", request_id="141564", source="top"
        )

    assert response.status_code == 200
    builder.assert_called_once_with(request_id="141564", source="ТОП")


@pytest.mark.django_db
def test_requests_list_denies_non_staff():
    _make_staff("owner_user", "BD")
    response = _get("api_qgis_requests_list", user="owner_user")
    assert response.status_code == 403


@pytest.mark.django_db
def test_requests_list_rejects_bad_request_id():
    _make_staff("staff_user", "MGGT")
    response = _get("api_qgis_requests_list", user="staff_user", request_id="14x")
    assert response.status_code == 400


@pytest.mark.django_db
def test_requests_list_rejects_unknown_source():
    _make_staff("staff_user", "MGGT")
    response = _get("api_qgis_requests_list", user="staff_user", source="XXX")
    assert response.status_code == 400


@pytest.mark.django_db
def test_requests_list_db_error_returns_500():
    _make_staff("staff_user", "MGGT")
    with patch(
        "pass_viewer.qgis_api_views.build_requests_list",
        side_effect=RuntimeError("boom"),
    ):
        response = _get("api_qgis_requests_list", user="staff_user")
    assert response.status_code == 500
    assert response.json()["ok"] is False


@pytest.mark.django_db
def test_recaps_list_success():
    _make_staff("staff_user", "SUP")
    with patch(
        "pass_viewer.qgis_api_views.build_recaps_list",
        return_value=[dict(item) for item in RECAP_ITEMS],
    ) as builder:
        response = _get("api_qgis_recaps_list", user="staff_user", request_id="141564")

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["count"] == 2
    assert data["recaps"][0]["recap_id"] == "77"
    assert data["current_user"] == "staff_user"
    builder.assert_called_once_with(request_id="141564", recap_id=None)


@pytest.mark.django_db
def test_recaps_list_rejects_bad_recap_id():
    _make_staff("staff_user", "MGGT")
    response = _get("api_qgis_recaps_list", user="staff_user", recap_id="7x")
    assert response.status_code == 400


def test_build_requests_list_sql_has_no_geometry():
    cursor = _mock_cursor((json.dumps(REQUEST_ITEMS),))
    specs = [("ДТ", "pass_objects", ["OwnerLegalPersonId"])]
    conn = MagicMock()
    with ExitStack() as stack:
        for item in _patched_request_sql(
            conn, cursor, specs, request_only_sql=" AND t.request_id IS NOT NULL"
        ):
            stack.enter_context(item)
        result = build_requests_list(request_id="141564")

    assert result == REQUEST_ITEMS
    last_call = cursor.execute.call_args_list[-1]
    sql, execute_params = last_call.args
    assert "ST_AsGeoJSON" not in sql
    assert "jsonb_agg" in sql
    assert execute_params == ["141564"]


@pytest.mark.django_db
def test_build_requests_list_no_sources_ready():
    with patch("pass_viewer.qgis_layers._gis_municipal_table_specs", return_value=[]):
        assert build_requests_list() == []


def test_build_recaps_list_sql_and_params():
    cursor = _mock_cursor((json.dumps(RECAP_ITEMS),))
    conn = MagicMock()
    with patch("pass_viewer.qgis_layers.connection", conn), patch(
        "pass_viewer.qgis_layers._table_exists", return_value=True
    ), patch(
        "pass_viewer.qgis_layers._column_exists", return_value=True
    ), patch(
        "pass_viewer.qgis_layers._resolve_column_name", side_effect=lambda c, t, p: p
    ), patch(
        "pass_viewer.qgis_layers._get_id_names_lookup_context", return_value=None
    ):
        conn.cursor.return_value.__enter__.return_value = cursor
        result = build_recaps_list(request_id="141564", recap_id="77")

    assert result == RECAP_ITEMS
    last_call = cursor.execute.call_args_list[-1]
    sql, execute_params = last_call.args
    assert "ST_AsGeoJSON" not in sql
    assert "FROM recaps t" in sql
    assert execute_params == ["141564", "77"]


def test_build_recaps_list_without_table():
    conn = MagicMock()
    with patch("pass_viewer.qgis_layers.connection", conn), patch(
        "pass_viewer.qgis_layers._table_exists", return_value=False
    ):
        assert build_recaps_list() == []

"""Personal-account object details and ASU ODS helpers."""

from __future__ import annotations

import json
from datetime import date, datetime
from unittest.mock import MagicMock, patch

import pytest
from django.contrib.auth.models import User
from django.urls import reverse

from pass_viewer.models import ExternalUser
from pass_viewer.page_config import personal_page_config
from pass_viewer.views import (
    _annotate_personal_ogh_statuses,
    _annotate_personal_total_areas,
    _build_personal_account_metrics,
    _fetch_personal_master_details,
    _format_personal_area,
    _format_personal_area_hectares,
    _format_personal_date,
    _format_personal_ogh_status,
    _format_personal_passportization_year,
    _personal_rootid_any_match_sql,
    _personal_rootid_values_are_int,
)


def test_personal_object_details_url() -> None:
    assert reverse("personal_object_details") == "/personal/object-details/"


def test_personal_page_config_has_open_owned() -> None:
    config = personal_page_config()
    assert config["urls"]["openOwned"] == reverse("open_owned_object")
    assert config["urls"]["personalObjectDetails"] == reverse("personal_object_details")


def test_format_personal_date_and_area() -> None:
    assert _format_personal_date(datetime(2024, 3, 5, 12, 0, 0)) == "05.03.2024"
    assert _format_personal_date(date(2024, 3, 5)) == "05.03.2024"
    assert _format_personal_date("2024-03-05") == "05.03.2024"
    assert _format_personal_date(None) == ""
    assert _format_personal_area(1234.6) == "1 235 м²"
    assert _format_personal_area(0) == ""
    assert _format_personal_area(None) == ""
    assert _format_personal_area_hectares(7617) == "0,7617 га"
    assert _format_personal_area_hectares(10000) == "1 га"
    assert _format_personal_area_hectares(123456) == "12,3456 га"
    assert _format_personal_area_hectares(0) == ""
    assert _format_personal_area_hectares(None) == ""


def test_personal_rootid_match_sql_uses_bigint_without_lower() -> None:
    assert _personal_rootid_values_are_int(["924695948", "111"])
    assert not _personal_rootid_values_are_int(["abc"])
    sql, params = _personal_rootid_any_match_sql(["924695948", "111"])
    assert "lower(" not in sql
    assert "ANY(%s::bigint[])" in sql
    assert params == [[924695948, 111]]
    text_sql, text_params = _personal_rootid_any_match_sql(["AB-1"])
    assert "lower(" not in text_sql
    assert "::text = ANY(%s)" in text_sql
    assert text_params == [["AB-1"]]


def test_annotate_personal_total_areas_converts_to_hectares() -> None:
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [("924695948", 7617, 7617)]
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor
    items = [{"rootid": "924695948", "source_label": "ОЗН", "name": "Test"}]

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        _annotate_personal_total_areas(items)

    assert items[0]["area_label"] == "0,7617 га"
    assert items[0]["clean_area_m2"] == 7617
    sql = mock_cursor.execute.call_args[0][0]
    assert '"OznPoly"' in sql
    assert '"TotalArea"' in sql
    assert '"TotalCleanArea"' in sql
    assert "lower(" not in sql
    assert "ANY(%s::bigint[])" in sql
    assert mock_cursor.execute.call_args[0][1] == [[924695948]]


def test_annotate_personal_total_areas_skips_missing_clean_area_column() -> None:
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = None
    mock_cursor.fetchall.return_value = [("54", 10000, None)]
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor
    items = [{"rootid": "54", "source_label": "ОДХ", "name": "odh"}]

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        _annotate_personal_total_areas(items)

    assert items[0]["area_label"] == "1 га"
    assert items[0]["clean_area_m2"] is None
    sqls = [call.args[0] for call in mock_cursor.execute.call_args_list]
    assert any("information_schema.columns" in sql for sql in sqls)
    select_sql = next(sql for sql in sqls if '"OdhPoly"' in sql and "SELECT t." in sql)
    assert '"TotalArea"' in select_sql
    assert '"TotalCleanArea"' not in select_sql
    assert ", NULL " in select_sql


def test_annotate_personal_total_areas_isolates_source_errors() -> None:
    mock_cursor = MagicMock()

    def execute(sql, _params=None):
        if '"YardPoly"' in sql:
            raise RuntimeError("timeout")
        mock_cursor.fetchall.return_value = [("924695948", 7617, 7617)]

    mock_cursor.execute.side_effect = execute
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor
    items = [
        {"rootid": "111", "source_label": "ДТ", "name": "dt"},
        {"rootid": "924695948", "source_label": "ОЗН", "name": "oo"},
    ]

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        _annotate_personal_total_areas(items)

    assert items[0]["area_label"] == ""
    assert items[0]["clean_area_m2"] is None
    assert items[1]["area_label"] == "0,7617 га"
    assert items[1]["clean_area_m2"] == 7617
    sqls = [call.args[0] for call in mock_cursor.execute.call_args_list]
    assert any('"YardPoly"' in sql for sql in sqls)
    assert any('"OznPoly"' in sql for sql in sqls)


def test_personal_metrics_sum_clean_area() -> None:
    metrics = _build_personal_account_metrics(
        [
            {"rootid": "1", "clean_area_m2": 7617},
            {"rootid": "2", "clean_area_m2": 100.4},
            {"rootid": "", "request_id": "9"},
        ],
        [],
    )
    assert metrics["passport_count"] == 2
    assert metrics["request_count"] == 1
    assert metrics["total_area_label"] == "7 717 м²"


def test_format_personal_ogh_status() -> None:
    assert _format_personal_ogh_status(None, found=False) == "—"
    assert _format_personal_ogh_status(None, found=True) == "Утверждён"
    assert _format_personal_ogh_status("  ", found=True) == "Утверждён"
    assert _format_personal_ogh_status("На согласовании", found=True) == "На согласовании"
    assert _format_personal_passportization_year(None, found=False) == "—"
    assert _format_personal_passportization_year(None, found=True) == "—"
    assert _format_personal_passportization_year(2026, found=True) == "2026"
    assert _format_personal_passportization_year(2026.0, found=True) == "2026"


def test_annotate_personal_ogh_statuses() -> None:
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [
        ("111", None, None),
        ("222", "На согласовании", 2026),
    ]
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor
    items = [
        {"rootid": "111", "name": "null-status"},
        {"rootid": "222", "name": "has-status"},
        {"rootid": "333", "name": "missing"},
    ]

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        _annotate_personal_ogh_statuses(items)

    assert items[0]["status"] == "Утверждён"
    assert items[0]["passportization_year"] == "—"
    assert items[1]["status"] == "На согласовании"
    assert items[1]["passportization_year"] == "2026"
    assert items[2]["status"] == "—"
    assert items[2]["passportization_year"] == "—"
    sql = mock_cursor.execute.call_args[0][0]
    assert '"ogh_analiz"' in sql
    assert '"OghStatus"' in sql
    assert '"PassportizationYear"' in sql
    assert '"gis"' in sql


def test_fetch_personal_master_details_queries_yardpoly() -> None:
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.71], [37.6, 55.7]]],
    }
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = (
        datetime(2024, 1, 15),
        "100",
        "200",
        1234.6,
        '{"type":"Polygon","coordinates":[[[37.6,55.7],[37.61,55.7],[37.61,55.71],[37.6,55.71],[37.6,55.7]]]}',
    )
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        details = _fetch_personal_master_details("ДТ", "924695948")

    assert details["owner_id"] == "100"
    assert details["department_id"] == "200"
    assert details["area"] == 1234.6
    assert details["geometry"]["type"] == geometry["type"]
    sql = mock_cursor.execute.call_args[0][0]
    assert '"YardPoly"' in sql
    assert '"RootId"' in sql
    assert '"StartDate"' in sql
    assert '"DepartmentLegalPersonId"' in sql
    assert '"GrbsLegalPersonId"' not in sql
    assert '"TotalCleanArea"' in sql
    assert '"CleaningArea"' not in sql
    assert "lower(" not in sql
    assert "%s::bigint" in sql
    assert mock_cursor.execute.call_args[0][1] == ["924695948"]


def test_fetch_personal_master_details_uses_grbs_for_odhpoly() -> None:
    mock_cursor = MagicMock()
    data_row = (
        datetime(2024, 1, 15),
        "100",
        "300",
        1234.6,
        '{"type":"Polygon","coordinates":[[[37.6,55.7],[37.61,55.7],[37.61,55.71],[37.6,55.7]]]}',
    )

    def execute(sql, params=None):
        mock_cursor._last_sql = sql
        mock_cursor._last_params = params

    def fetchone():
        sql = getattr(mock_cursor, "_last_sql", "") or ""
        params = getattr(mock_cursor, "_last_params", None) or []
        if "information_schema.columns" in sql:
            column_name = str(params[2]).lower() if len(params) > 2 else ""
            if column_name in {"grbslegalpersonid", "cleaningarea"}:
                return (1,)
            return None
        return data_row

    mock_cursor.execute.side_effect = execute
    mock_cursor.fetchone.side_effect = fetchone
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        details = _fetch_personal_master_details("ОДХ", "10001283")

    assert details["owner_id"] == "100"
    assert details["department_id"] == "300"
    assert details["area"] == 1234.6
    sqls = [call.args[0] for call in mock_cursor.execute.call_args_list]
    select_sql = next(sql for sql in sqls if '"OdhPoly"' in sql and "SELECT t." in sql)
    assert '"GrbsLegalPersonId"' in select_sql
    assert '"DepartmentLegalPersonId"' not in select_sql
    assert '"CleaningArea"' in select_sql
    assert '"TotalCleanArea"' not in select_sql


@pytest.mark.django_db
def test_personal_object_details_maps_master_fields(client) -> None:
    user = User.objects.create_user(username="personal_details_user", password="pass")
    ExternalUser.objects.create(
        login="personal_details_user",
        password="pass",
        owner_legal_person_id="OWNER_A",
    )
    client.force_login(user)
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.71], [37.6, 55.7]]],
    }

    with patch("pass_viewer.views._passport_in_user_scope", return_value=True), patch(
        "pass_viewer.views._fetch_personal_master_details",
        return_value={
            "startdate": datetime(2024, 1, 15),
            "owner_id": "100",
            "department_id": "200",
            "area": 1234.6,
            "geometry": geometry,
        },
    ), patch(
        "pass_viewer.views._get_id_name_lookup_value",
        side_effect=lambda pid: {"100": "ГУП Жилищник", "200": "ДЖКХ"}[str(pid)],
    ):
        response = client.post(
            reverse("personal_object_details"),
            data=json.dumps({"rootid": "924695948", "source_label": "ОЗН"}),
            content_type="application/json",
        )

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["approval_date"] == "15.01.2024"
    assert data["owner_name"] == "ГУП Жилищник"
    assert data["oiv_name"] == "ДЖКХ"
    assert data["area_label"] == "1 235 м²"
    assert data["geometry"]["type"] == "Polygon"


@pytest.mark.django_db
def test_personal_object_details_foreign_rootid_returns_404(client) -> None:
    user = User.objects.create_user(username="personal_details_foreign", password="pass")
    ExternalUser.objects.create(
        login="personal_details_foreign",
        password="pass",
        owner_legal_person_id="OWNER_A",
    )
    client.force_login(user)

    with patch("pass_viewer.views._passport_in_user_scope", return_value=False):
        response = client.post(
            reverse("personal_object_details"),
            data=json.dumps({"rootid": "999", "source_label": "ДТ"}),
            content_type="application/json",
        )

    assert response.status_code == 404
    assert response.json()["ok"] is False

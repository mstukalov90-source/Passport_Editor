"""Personal-account object details and ASU ODS helpers."""

from __future__ import annotations

import json
from datetime import date, datetime, timedelta
from unittest.mock import MagicMock, patch

import pytest
from django.contrib.auth.models import User
from django.urls import reverse
from django.utils import timezone

from pass_viewer.models import ExternalUser
from pass_viewer.page_config import personal_page_config
from pass_viewer.views import (
    _annotate_and_filter_ods_registry_against_gis,
    _annotate_personal_ogh_statuses,
    _annotate_personal_total_areas,
    _build_personal_account_metrics,
    _build_personal_statistics,
    _build_personal_table_items,
    _personal_kind_filter_counts,
    _fetch_personal_master_details,
    _format_personal_area,
    _format_personal_area_hectares,
    _format_personal_date,
    _format_personal_ogh_status,
    _format_personal_passportization_year,
    _personal_display_status,
    _personal_passportization_kind,
    _personal_rootid_any_match_sql,
    _personal_rootid_values_are_int,
)


def test_personal_object_details_url() -> None:
    assert reverse("personal_object_details") == "/personal/object-details/"


def test_personal_page_config_has_open_owned() -> None:
    config = personal_page_config()
    assert config["urls"]["openOwned"] == reverse("open_owned_object")
    assert config["urls"]["personalObjectDetails"] == reverse("personal_object_details")
    assert config["urls"]["checkDgi"] == reverse("check_dgi_intersections")


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


def test_annotate_personal_total_areas_uses_square_meters() -> None:
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [("924695948", 7617, 7617)]
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor
    items = [{"rootid": "924695948", "source_label": "ОЗН", "name": "Test"}]

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        _annotate_personal_total_areas(items)

    assert items[0]["area_label"] == "7 617 м²"
    assert items[0]["clean_area_m2"] == 7617
    sql = mock_cursor.execute.call_args[0][0]
    assert '"OznPoly"' in sql
    assert '"TotalArea"' in sql
    assert '"TotalCleanArea"' in sql
    assert "lower(" not in sql
    assert "ANY(%s::bigint[])" in sql
    assert mock_cursor.execute.call_args[0][1] == [[924695948]]


def test_annotate_personal_total_areas_uses_ods_matched_rootid() -> None:
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [("4280571", 5000, 4000)]
    mock_db = MagicMock()
    mock_db.cursor.return_value.__enter__.return_value = mock_cursor
    items = [
        {
            "rootid": "",
            "is_ods_request": True,
            "short_object_root_id": "4280571",
            "ods_matched_rootid": "4280571",
            "ods_matched_source_label": "ОЗН",
            "source_label": "ОДС",
            "name": "ODS",
        }
    ]

    with patch("pass_viewer.views.connections") as mock_connections:
        mock_connections.__getitem__.return_value = mock_db
        _annotate_personal_total_areas(items)

    assert items[0]["area_label"] == "5 000 м²"
    assert items[0]["clean_area_m2"] == 4000
    sql = mock_cursor.execute.call_args[0][0]
    assert '"OznPoly"' in sql
    assert mock_cursor.execute.call_args[0][1] == [[4280571]]


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

    assert items[0]["area_label"] == "10 000 м²"
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
    assert items[1]["area_label"] == "7 617 м²"
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


def test_build_personal_statistics_groups_fixture_rows() -> None:
    stats = _build_personal_statistics(
        [
            {
                "row_kind": "passport",
                "source_label": "ОЗН",
                "passportization_kind": "",
                "passportization_year": "2026",
                "display_status": "Утверждён",
                "asu_ods_enabled": True,
                "has_drawn_request": True,
            },
            {
                "row_kind": "request",
                "source_label": "ДТ",
                "passportization_kind": "Первичная",
                "passportization_year": "—",
                "display_status": "Включена в график",
                "asu_ods_enabled": False,
                "has_drawn_request": False,
            },
            {
                "row_kind": "ods",
                "source_label": "ОДС",
                "passportization_kind": "Актуализация",
                "passportization_year": "2024",
                "display_status": "Включена в график",
                "asu_ods_enabled": True,
                "has_drawn_request": False,
            },
            {
                "row_kind": "request",
                "source_label": "ОДХ",
                "passportization_kind": "Ожидает подтверждение",
                "passportization_year": "2026",
                "display_status": "Не определено",
                "asu_ods_enabled": False,
                "has_drawn_request": False,
            },
            {
                "row_kind": "request",
                "source_label": "ТОП",
                "passportization_kind": "Не определено",
                "passportization_year": "",
                "display_status": "",
                "asu_ods_enabled": False,
                "has_drawn_request": False,
            },
            {
                "row_kind": "approval",
                "source_label": "ДТ",
                "passportization_kind": "",
                "passportization_year": "—",
                "display_status": "В работе",
                "asu_ods_enabled": False,
                "has_drawn_request": False,
            },
        ]
    )
    kinds = {row["label"]: row["count"] for row in stats["passportization_kinds"]}
    assert kinds == {
        "Актуализация": 1,
        "Первичная": 1,
        "Ожидает подтверждение": 1,
        "Не определено": 1,
        "без вида": 2,
    }
    ogh = {row["label"]: row["count"] for row in stats["ogh_types"]}
    assert ogh == {"ДТ": 1, "ОДХ": 1, "ОО": 1, "ТОП": 1, "прочие": 1}
    years = {row["label"]: row["count"] for row in stats["years"]}
    assert years == {"2026": 2, "2024": 1, "—": 3}
    assert [row["label"] for row in stats["years"]][:2] == ["2026", "2024"]
    statuses = {row["label"]: row["count"] for row in stats["statuses"]}
    assert statuses["Утверждён"] == 1
    assert statuses["Включена в график"] == 2
    assert statuses["В работе"] == 1
    assert statuses["—"] == 1
    links = {row["label"]: row["count"] for row in stats["links"]}
    assert links == {"Связь с АСУ ОДС": 2, "Приклеенная заявка": 1}


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


@pytest.mark.django_db
def test_personal_object_details_by_request_id(client) -> None:
    user = User.objects.create_user(username="personal_details_request", password="pass")
    ExternalUser.objects.create(
        login="personal_details_request",
        password="pass",
        owner_legal_person_id="OWNER_A",
    )
    client.force_login(user)
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.7], [37.61, 55.7], [37.61, 55.71], [37.6, 55.71], [37.6, 55.7]]],
    }

    with patch(
        "pass_viewer.views._site_request_for_scope",
        return_value={
            "request_id": "82727",
            "name": "Заявка",
            "startdate": "",
            "geom_json": json.dumps(geometry),
        },
    ):
        response = client.post(
            reverse("personal_object_details"),
            data=json.dumps({"request_id": "82727", "source_label": "ДТ"}),
            content_type="application/json",
        )

    assert response.status_code == 200
    data = response.json()
    assert data["ok"] is True
    assert data["geometry"]["type"] == "Polygon"


def test_personal_passportization_kind_for_ods_and_site_requests() -> None:
    assert _personal_passportization_kind({"is_ods_request": True, "short_object_root_id": "111"}) == "Актуализация"
    assert _personal_passportization_kind({"is_ods_request": True, "short_object_root_id": ""}) == "Первичная"
    assert (
        _personal_passportization_kind(
            {"ods_registry_brid_match": True, "ods_registry_short_root_id": "222"}
        )
        == "Актуализация"
    )
    assert _personal_passportization_kind({"ods_registry_brid_match": True, "rootid": ""}) == "Первичная"
    assert _personal_passportization_kind({"rootid": "333", "request_id": ""}) == ""
    assert _personal_passportization_kind({"rootid": "1", "merged_from_ods": True}) == "Актуализация"


def test_personal_passportization_kind_unconfirmed_gis_request() -> None:
    now = timezone.now()
    assert (
        _personal_passportization_kind(
            {"rootid": "", "request_id": "1234", "created_at": now}
        )
        == "Ожидает подтверждение"
    )
    assert (
        _personal_passportization_kind(
            {"rootid": "", "request_id": "1234", "ods_registry_brid_pending": True}
        )
        == "Ожидает подтверждение"
    )
    assert (
        _personal_passportization_kind(
            {"rootid": "", "request_id": "1234", "created_at": now - timedelta(hours=25)}
        )
        == "Не определено"
    )
    assert _personal_passportization_kind({"rootid": "", "request_id": "1234"}) == "Не определено"


def test_annotate_ods_registry_attaches_brid_to_passport() -> None:
    items = [
        {"rootid": "4280571", "name": "Passport", "request_id": "", "source_label": "ДТ"},
        {
            "rootid": "",
            "name": "Site request",
            "request_id": "78467",
            "source_label": "ДТ",
        },
        {
            "is_ods_request": True,
            "rootid": "",
            "request_id": "78467",
            "short_object_root_id": "4280571",
            "br_status_name": "Включена в график",
            "name": "ODS same brid",
        },
        {
            "is_ods_request": True,
            "rootid": "",
            "request_id": "99999",
            "short_object_root_id": "4280571",
            "br_status_name": "В работе",
            "name": "ODS matched passport",
        },
    ]
    out = _annotate_and_filter_ods_registry_against_gis(items)
    passport = next(item for item in out if item.get("rootid") == "4280571")
    site_request = next(item for item in out if item.get("request_id") == "78467" and not item.get("is_ods_request"))
    assert passport["ods_registry_root_match"] is True
    assert passport["ods_registry_brid"] == "78467"
    assert passport["ods_registry_br_status_name"] == "Включена в график"
    assert site_request["ods_registry_brid_match"] is True
    assert site_request["ods_registry_short_root_id"] == "4280571"
    assert not any(item.get("is_ods_request") and item.get("request_id") == "78467" for item in out)
    assert any(item.get("is_ods_request") and item.get("request_id") == "99999" for item in out)


def test_build_personal_table_items_includes_requests_and_approvals() -> None:
    rows = _build_personal_table_items(
        [
            {"rootid": "1", "name": "Passport", "source_label": "ОЗН", "request_id": "", "ods_registry_brid": "55"},
            {
                "rootid": "",
                "name": "Site request",
                "source_label": "ДТ",
                "request_id": "1234",
                "ods_registry_brid_match": True,
                "ods_registry_short_root_id": "",
            },
            {
                "is_ods_request": True,
                "rootid": "",
                "name": "ODS request",
                "source_label": "ОДС",
                "request_id": "78467",
                "short_object_root_id": "4280571",
                "ods_matched_rootid": "4280571",
                "ods_matched_source_label": "ДТ",
                "br_status_name": "Включена в график",
            },
        ],
        [{"id": "ap-1", "label": "Согласование 46998", "status_label": "В работе", "source_label": "ДТ"}],
    )
    by_name = {row["name"]: row for row in rows}
    assert by_name["Passport"]["display_request_id"] == "55"
    assert by_name["Passport"]["row_kind"] == "passport"
    assert by_name["Passport"]["passportization_kind"] == ""
    assert by_name["Site request"]["row_kind"] == "request"
    assert by_name["Site request"]["passportization_kind"] == "Первичная"
    assert by_name["ODS request"]["display_rootid"] == "4280571"
    assert by_name["ODS request"]["display_request_id"] == "78467"
    assert by_name["ODS request"]["passportization_kind"] == "Актуализация"
    assert by_name["ODS request"]["asu_ods_enabled"] is True
    assert by_name["ODS request"]["asu_ods_source"] == "ДТ"
    assert by_name["Согласование 46998"]["row_kind"] == "approval"
    assert by_name["Согласование 46998"]["display_status"] == "В работе"
    assert by_name["Согласование 46998"]["approve_id"] == "ap-1"
    assert by_name["Согласование 46998"]["passportization_kind"] == ""
    assert _personal_kind_filter_counts(rows) == {
        "all": 3,
        "actualization": 1,
        "primary": 1,
        "approval": 1,
    }


def test_build_personal_table_items_merges_ods_with_matching_passport() -> None:
    rows = _build_personal_table_items(
        [
            {
                "rootid": "4280571",
                "name": "Валовая ул. 10",
                "source_label": "ОЗН",
                "request_id": "",
                "status": "Полевые работы",
            },
            {
                "is_ods_request": True,
                "rootid": "",
                "name": "Валовая ул. 10 (ODS)",
                "source_label": "ОДС",
                "request_id": "78467",
                "short_object_root_id": "4280571",
                "ods_matched_rootid": "4280571",
                "ods_matched_source_label": "ОЗН",
                "br_status_name": "Включена в график",
            },
            {
                "is_ods_request": True,
                "rootid": "",
                "name": "Первичная ODS",
                "source_label": "ОДС",
                "request_id": "111",
                "short_object_root_id": "",
            },
        ],
        [],
    )
    assert len(rows) == 2
    merged = next(row for row in rows if row.get("rootid") == "4280571")
    ods_only = next(row for row in rows if row.get("row_kind") == "ods")
    assert merged["row_kind"] == "passport"
    assert merged["display_request_id"] == "78467"
    assert merged["source_label"] == "ОЗН"
    assert merged["passportization_kind"] == "Актуализация"
    assert merged["merged_from_ods"] is True
    assert ods_only["display_request_id"] == "111"
    assert ods_only["passportization_kind"] == "Первичная"
    assert not any(row.get("name") == "Валовая ул. 10 (ODS)" for row in rows)


def test_build_personal_table_items_merges_drawn_request_with_passport() -> None:
    rows = _build_personal_table_items(
        [
            {
                "rootid": "4280571",
                "name": "Валовая ул. 10",
                "source_label": "ОЗН",
                "request_id": "",
                "ods_registry_brid": "82727",
                "ods_registry_root_match": True,
            },
            {
                "rootid": "",
                "name": "Валовая ул. 10 заявка",
                "source_label": "ДТ",
                "request_id": "82727",
                "ods_registry_brid_match": True,
                "ods_registry_short_root_id": "4280571",
            },
        ],
        [],
    )
    assert len(rows) == 1
    row = rows[0]
    assert row["rootid"] == "4280571"
    assert row["row_kind"] == "passport"
    assert row["display_request_id"] == "82727"
    assert row["source_label"] == "ОЗН"
    assert row["passportization_kind"] == "Актуализация"
    assert row["has_drawn_request"] is True
    assert row["drawn_request_id"] == "82727"
    assert row["drawn_source_label"] == "ДТ"
    assert not any(item.get("name") == "Валовая ул. 10 заявка" for item in rows)


def test_build_personal_table_items_unconfirmed_request_keeps_own_row() -> None:
    now = timezone.now()
    rows = _build_personal_table_items(
        [
            {
                "rootid": "",
                "name": "Новая заявка",
                "source_label": "ДТ",
                "request_id": "1234",
                "created_at": now,
            }
        ],
        [],
    )
    assert len(rows) == 1
    assert rows[0]["row_kind"] == "request"
    assert rows[0]["passportization_kind"] == "Ожидает подтверждение"
    assert rows[0]["has_drawn_request"] is False


def test_personal_display_status_falls_back_to_ods() -> None:
    assert _personal_display_status({"status": "—"}) == "—"
    assert (
        _personal_display_status(
            {"status": "—", "ods_registry_br_status_name": "Включена в график"}
        )
        == "Включена в график"
    )
    assert _personal_display_status({"status": "", "br_status_name": "В работе"}) == "В работе"
    assert _personal_display_status({"status": "Полевые работы", "br_status_name": "В работе"}) == "Полевые работы"


def test_build_personal_table_items_uses_ods_status_when_gis_empty() -> None:
    rows = _build_personal_table_items(
        [
            {
                "rootid": "4280571",
                "name": "Валовая ул. 10",
                "source_label": "ОЗН",
                "request_id": "",
                "status": "—",
                "ods_registry_brid": "82727",
                "ods_registry_br_status_name": "Включена в график",
                "ods_registry_root_match": True,
            }
        ],
        [],
    )
    assert rows[0]["display_status"] == "Включена в график"

    merged = _build_personal_table_items(
        [
            {
                "rootid": "1",
                "name": "Passport",
                "source_label": "ДТ",
                "request_id": "",
                "status": "",
            },
            {
                "is_ods_request": True,
                "rootid": "",
                "name": "ODS",
                "source_label": "ОДС",
                "request_id": "55",
                "short_object_root_id": "1",
                "ods_matched_rootid": "1",
                "br_status_name": "Включена в график",
            },
        ],
        [],
    )
    assert len(merged) == 1
    assert merged[0]["display_status"] == "Включена в график"

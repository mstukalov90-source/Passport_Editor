from datetime import datetime, timedelta
from types import SimpleNamespace

from django.utils import timezone

from pass_viewer.request_side import (
    _fmt_dt,
    _humanize_reason_name,
    _parse_bid_approve,
    build_ods_status_timeline,
    build_validation_waiting_timeline,
    lookup_bidapprove_comments,
    lookup_ods_request_status,
    normalize_brid,
    resolve_editor_ods_status,
    VALIDATION_STATUS_LABEL,
)


def test_normalize_brid_accepts_digits_only() -> None:
    assert normalize_brid(" 12345 ") == "12345"
    assert normalize_brid("") == ""
    assert normalize_brid("12a") == ""
    assert normalize_brid(None) == ""


def test_fmt_dt_formats_iso_and_datetime() -> None:
    assert _fmt_dt(None) == ""
    assert _fmt_dt(datetime(2026, 1, 15, 12, 0, 0)) == "15.01.2026"
    assert _fmt_dt("2026-03-01") == "01.03.2026"
    assert _fmt_dt("уже готово") == "уже готово"


def test_parse_bid_approve_array_and_aliases() -> None:
    items = _parse_bid_approve(
        [
            {
                "order_number": "2",
                "action_date": "01.02.2026",
                "description": "Согласовано",
                "comment": "ок",
                "org_name": "Орг",
                "owner_name": "Иванов",
                "file_id": "f1",
            },
            {
                "orderNumber": 1,
                "actionDate": "31.01.2026",
                "description": "Направлено",
                "Comment": "старт",
                "orgName": "Другая",
                "ownerName": "Петров",
                "fileId": ["a", "b"],
            },
        ]
    )
    assert [row["order_number"] for row in items] == [1, 2]
    assert items[0]["file_id"] == ["a", "b"]
    assert items[1]["file_id"] == ["f1"]
    assert items[0]["comment"] == "старт"


def test_parse_bid_approve_json_string_and_wrapped_dict() -> None:
    raw = '{"items":[{"description":"x","comment":"y"}]}'
    items = _parse_bid_approve(raw)
    assert len(items) == 1
    assert items[0]["description"] == "x"
    assert _parse_bid_approve("not-json") == []
    assert _parse_bid_approve(None) == []


def test_lookup_ods_request_status_returns_none_for_bad_brid() -> None:
    assert lookup_ods_request_status("") is None
    assert lookup_ods_request_status("abc") is None


class _FakeCursor:
    def __init__(self, row):
        self.row = row
        self.sql = ""

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql, params=None):
        self.sql = " ".join(str(sql).split())
        self.params = params

    def fetchone(self):
        lowered = self.sql.lower()
        if "information_schema.tables" in lowered:
            return (1,)
        if "select column_name" in lowered:
            return (self.params[2],)
        if "information_schema.columns" in lowered:
            return (1,)
        if "from" in lowered:
            return self.row
        return None


def test_lookup_ods_request_status_maps_columns(monkeypatch) -> None:
    cursor = _FakeCursor(
        ("1001", "В работе", "Сквер", "2026-04-02", "Создание", "Причина", "Тип")
    )
    monkeypatch.setattr(
        "pass_viewer.request_side.connection",
        SimpleNamespace(cursor=lambda: cursor),
    )
    data = lookup_ods_request_status("1001")
    assert data is not None
    assert data["brid"] == "1001"
    assert data["status_name"] == "В работе"
    assert data["object_name"] == "Сквер"
    assert data["inspection_date_plan"] == "02.04.2026"
    assert data["create_type_name"] == "Создание"
    assert "timeline" in data
    assert data["timeline"]["steps"][0]["name"] == "В работе"
    assert data["timeline"]["steps"][0]["state"] == "current"


def test_humanize_reason_name_parses_list_string() -> None:
    assert _humanize_reason_name("['Проведено благоустройство']") == "Проведено благоустройство"
    assert _humanize_reason_name('["А", "Б"]') == "А, Б"
    assert _humanize_reason_name("просто текст") == "просто текст"


def test_build_ods_timeline_happy_path() -> None:
    project = build_ods_status_timeline("Проект")
    assert [s["state"] for s in project["steps"]] == [
        "current",
        "pending",
        "pending",
        "pending",
        "pending",
        "pending",
    ]
    assert project["summary"] == "0 из 6"
    assert project["progress_pct"] == 0

    oiv = build_ods_status_timeline("Согласована ОИВ")
    assert [s["state"] for s in oiv["steps"]][:3] == ["done", "done", "current"]
    assert oiv["summary"] == "2 из 6"

    dgp = build_ods_status_timeline("Согласована ДГП")
    assert dgp["steps"][3]["name"] == "Согласована ДГП"
    assert dgp["steps"][3]["state"] == "current"

    mka = build_ods_status_timeline("Согласована МКА")
    assert mka["steps"][3]["name"] == "Согласована ДГП"
    assert mka["steps"][3]["state"] == "current"

    scheduled = build_ods_status_timeline("Включена в график", "01.10.2027")
    assert scheduled["steps"][4]["state"] == "current"
    assert scheduled["steps"][4]["date"] == "01.10.2027"

    done = build_ods_status_timeline("Исполнено")
    assert all(s["state"] == "done" for s in done["steps"])
    assert done["progress_pct"] == 100
    assert done["summary"] == "6 из 6"


def test_build_ods_timeline_side_and_excluded_statuses() -> None:
    rejected = build_ods_status_timeline("Отклонена")
    assert rejected["steps"][-1] == {"name": "Отклонена", "state": "rejected", "date": ""}
    assert all(s["state"] == "done" for s in rejected["steps"][:-1])

    cancelled = build_ods_status_timeline("Аннулирована")
    assert cancelled["steps"][-1]["state"] == "rejected"
    assert len(cancelled["steps"]) == 6

    exclusion = build_ods_status_timeline("Запрос на исключение из графика")
    assert exclusion["steps"][-1]["state"] == "current"
    assert exclusion["steps"][-1]["name"] == "Запрос на исключение из графика"
    assert all(s["state"] == "done" for s in exclusion["steps"][:-1])

    wait = build_ods_status_timeline("Ожидание валидации")
    assert len(wait["steps"]) == 1
    assert wait["steps"][0]["state"] == "current"
    unconfirmed = build_ods_status_timeline("Заявка не подтверждена")
    assert len(unconfirmed["steps"]) == 1


def test_validation_waiting_timeline_is_single_current_step() -> None:
    timeline = build_validation_waiting_timeline()
    assert timeline["summary"] == ""
    assert timeline["progress_pct"] == 0
    assert timeline["steps"] == [
        {"name": VALIDATION_STATUS_LABEL, "state": "current", "date": ""},
    ]


def test_resolve_editor_ods_status_pending_validation(monkeypatch) -> None:
    monkeypatch.setattr("pass_viewer.request_side.lookup_ods_request_status", lambda *_a, **_k: None)
    created = timezone.now() - timedelta(hours=2)
    payload = resolve_editor_ods_status("1001", owner_id="OWN", created_at=created)
    assert payload["present"] is True
    assert payload["in_registry"] is False
    assert payload["status"]["status_name"] == VALIDATION_STATUS_LABEL
    assert payload["status"]["timeline"]["steps"][0]["name"] == VALIDATION_STATUS_LABEL


def test_resolve_editor_ods_status_hidden_when_unconfirmed(monkeypatch) -> None:
    monkeypatch.setattr("pass_viewer.request_side.lookup_ods_request_status", lambda *_a, **_k: None)
    created = timezone.now() - timedelta(hours=48)
    payload = resolve_editor_ods_status("1001", owner_id="OWN", created_at=created)
    assert payload == {"present": False, "in_registry": False, "status": None}


def test_lookup_bidapprove_comments_skips_qgis_without_ods(monkeypatch) -> None:
    monkeypatch.setattr("pass_viewer.request_side.lookup_ods_request_status", lambda *_a, **_k: None)

    class Boom:
        def __getitem__(self, _key):
            raise AssertionError("qgis must not be queried")

    monkeypatch.setattr("pass_viewer.request_side.connections", Boom())
    assert lookup_bidapprove_comments("1001") == []


def test_lookup_bidapprove_comments_empty_without_qgis(monkeypatch) -> None:
    monkeypatch.setattr(
        "pass_viewer.request_side.lookup_ods_request_status",
        lambda *_a, **_k: {"brid": "1001"},
    )
    monkeypatch.setattr("pass_viewer.request_side.connections", {})
    assert lookup_bidapprove_comments("1001") == []

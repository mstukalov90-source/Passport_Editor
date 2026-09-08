"""Request-side panel helpers: ods_request status, BidApprove comments, attachments."""

from __future__ import annotations

import ast
import json
import logging
import re
from datetime import datetime, timedelta
from typing import Any

from django.conf import settings
from django.db import connection, connections
from django.utils import timezone
from django.utils.dateparse import parse_datetime

logger = logging.getLogger(__name__)

_BRID_RE = re.compile(r"^\d{1,32}$")


def normalize_brid(value: Any) -> str:
    text = str(value or "").strip()
    if not _BRID_RE.fullmatch(text):
        return ""
    return text


def _quote_ident(identifier: str) -> str:
    return '"' + str(identifier).replace('"', '""') + '"'


def _column_exists(cursor, table_name: str, column_name: str, schema: str = "public") -> bool:
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [schema, table_name, column_name],
    )
    return cursor.fetchone() is not None


def _resolve_column_name(cursor, table_name: str, preferred_name: str, schema: str = "public") -> str:
    cursor.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [schema, table_name, preferred_name],
    )
    row = cursor.fetchone()
    return row[0] if row else preferred_name


def _table_exists(cursor, table_name: str, schema: str = "public") -> bool:
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = %s
          AND table_name = %s
        LIMIT 1
        """,
        [schema, table_name],
    )
    return cursor.fetchone() is not None


VALIDATION_STATUS_LABEL = "Валидация заявки АСУ ОДС до 24 часов"

HAPPY_PATH_STEPS = (
    "Проект",
    "Отправлена на согласование",
    "Согласована ОИВ",
    "Согласована ДГП",
    "Включена в график паспортизации",
    "Исполнено",
)

_NOT_TIMELINE_STATUSES = frozenset(
    {
        "ожидание валидации",
        "заявка не подтверждена",
        "валидация заявки асу одс до 24 часов",
        "заявка не подтверждена асу одс",
    }
)


def _norm_status(value: Any) -> str:
    return " ".join(str(value or "").strip().lower().split())


def _humanize_reason_name(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, (list, tuple)):
        return ", ".join(str(part).strip() for part in value if str(part).strip())
    text = str(value).strip()
    if not text:
        return ""
    if text[0] in "[{\"":
        parsed: Any = None
        try:
            parsed = json.loads(text)
        except json.JSONDecodeError:
            try:
                parsed = ast.literal_eval(text)
            except (SyntaxError, ValueError):
                parsed = None
        if isinstance(parsed, (list, tuple)):
            return ", ".join(str(part).strip() for part in parsed if str(part).strip())
        if isinstance(parsed, str) and parsed.strip():
            return parsed.strip()
    return text


def _step(name: str, state: str, date: str = "") -> dict[str, str]:
    return {"name": name, "state": state, "date": date or ""}


def build_ods_status_timeline(status_name: str, inspection_date_plan: str = "") -> dict[str, Any]:
    """Happy-path vertical timeline from BrStatusName. Side statuses use rejected/current extra steps."""
    raw = str(status_name or "").strip()
    key = _norm_status(raw)
    plan_date = str(inspection_date_plan or "").strip()
    total = len(HAPPY_PATH_STEPS)

    def pack(steps: list[dict[str, str]]) -> dict[str, Any]:
        done = sum(1 for step in steps if step["state"] == "done")
        pct = int(round(100 * done / total)) if total else 0
        return {
            "summary": f"{done} из {total}",
            "progress_pct": pct,
            "steps": steps,
        }

    if not key or key in _NOT_TIMELINE_STATUSES or raw in {"—", "-"}:
        return pack([_step(raw or "—", "current")])

    if key == "исполнено":
        return pack(
            [
                _step(name, "done", plan_date if name.startswith("Включена") else "")
                for name in HAPPY_PATH_STEPS
            ]
        )

    if key in {"запрос на исключение из графика", "согласование исключения оив"}:
        steps = [
            _step(name, "done", plan_date if name.startswith("Включена") else "")
            for name in HAPPY_PATH_STEPS[:-1]
        ]
        steps.append(_step(raw, "current"))
        return pack(steps)

    if key in {"отклонена", "аннулирована"}:
        kept = HAPPY_PATH_STEPS[:2] if key == "отклонена" else HAPPY_PATH_STEPS[:5]
        steps = [
            _step(name, "done", plan_date if name.startswith("Включена") else "")
            for name in kept
        ]
        steps.append(_step(raw, "rejected"))
        return pack(steps)

    current_index = None
    if key == "проект":
        current_index = 0
    elif key.startswith("отправлена на согласование"):
        current_index = 1
    elif key == "согласована оив":
        current_index = 2
    elif key in {"согласована мка", "согласована дгп"}:
        current_index = 3
    elif key.startswith("включена в график"):
        current_index = 4

    if current_index is None:
        return pack([_step(raw, "current")])

    steps = []
    for idx, name in enumerate(HAPPY_PATH_STEPS):
        date = plan_date if idx == 4 and (idx <= current_index) else ""
        if idx < current_index:
            state = "done"
        elif idx == current_index:
            state = "current"
        else:
            state = "pending"
        steps.append(_step(name, state, date))
    return pack(steps)


def build_validation_waiting_timeline() -> dict[str, Any]:
    return {
        "summary": "",
        "progress_pct": 0,
        "steps": [_step(VALIDATION_STATUS_LABEL, "current")],
    }


def _within_validation_window(created_at: Any, *, hours: int = 24) -> bool:
    if created_at is None:
        return False
    if isinstance(created_at, str):
        created_at = parse_datetime(created_at.strip()) if created_at.strip() else None
    if created_at is None:
        return False
    if timezone.is_naive(created_at):
        created_at = timezone.make_aware(created_at, timezone.get_current_timezone())
    return (timezone.now() - created_at) < timedelta(hours=hours)


def _fmt_dt(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, datetime):
        return value.strftime("%d.%m.%Y")
    text = str(value).strip()
    if not text:
        return ""
    try:
        parsed = datetime.fromisoformat(text.replace("Z", "+00:00"))
        return parsed.strftime("%d.%m.%Y")
    except ValueError:
        return text


def lookup_ods_request_status(brid: str, owner_id: Any = None) -> dict[str, Any] | None:
    """Return status fields from geodb.ods_request for BrId, or None."""
    brid = normalize_brid(brid)
    if not brid:
        return None
    table = getattr(settings, "GIS_ODS_REQUEST_TABLE", "ods_request")
    try:
        with connection.cursor() as cursor:
            if not _table_exists(cursor, table) or not _column_exists(cursor, table, "BrId"):
                return None
            brid_col = _resolve_column_name(cursor, table, "BrId")
            fields = [
                ("BrStatusName", "status_name"),
                ("ObjectName", "object_name"),
                ("InspectionDatePlan", "inspection_date_plan"),
                ("CreateTypeName", "create_type_name"),
                ("ReasonName", "reason_name"),
                ("PassportizationTypeName", "passportization_type_name"),
            ]
            select_parts = [f'{_quote_ident(brid_col)}::text AS brid']
            for src, alias in fields:
                if _column_exists(cursor, table, src):
                    col = _resolve_column_name(cursor, table, src)
                    select_parts.append(f"{_quote_ident(col)}::text AS {alias}")
                else:
                    select_parts.append(f"NULL::text AS {alias}")
            where_sql = f"WHERE {_quote_ident(brid_col)}::text = %s"
            params: list[Any] = [brid]
            owner_text = str(owner_id or "").strip()
            if owner_text and _column_exists(cursor, table, "ownerid"):
                owner_col = _resolve_column_name(cursor, table, "ownerid")
                where_sql += f" AND {_quote_ident(owner_col)}::text = %s"
                params.append(owner_text)
            cursor.execute(
                f"SELECT {', '.join(select_parts)} FROM {_quote_ident(table)} {where_sql} LIMIT 1",
                params,
            )
            row = cursor.fetchone()
            if not row:
                return None
            cols = ["brid"] + [alias for _, alias in fields]
            data = dict(zip(cols, row))
            status_name = (data.get("status_name") or "").strip() or "—"
            inspection_date_plan = _fmt_dt(data.get("inspection_date_plan"))
            return {
                "brid": str(data.get("brid") or brid),
                "status_name": status_name,
                "object_name": (data.get("object_name") or "").strip(),
                "inspection_date_plan": inspection_date_plan,
                "create_type_name": (data.get("create_type_name") or "").strip(),
                "reason_name": _humanize_reason_name(data.get("reason_name")),
                "passportization_type_name": (data.get("passportization_type_name") or "").strip(),
                "timeline": build_ods_status_timeline(status_name, inspection_date_plan),
            }
    except Exception:
        logger.exception("lookup_ods_request_status failed for brid=%s", brid)
        return None


def _parse_bid_approve(raw: Any) -> list[dict[str, Any]]:
    if raw is None or raw == "":
        return []
    if isinstance(raw, str):
        try:
            raw = json.loads(raw)
        except json.JSONDecodeError:
            return []
    if isinstance(raw, dict):
        raw = raw.get("items") or raw.get("comments") or raw.get("BidApprove") or [raw]
    if not isinstance(raw, list):
        return []
    items = []
    for idx, item in enumerate(raw, start=1):
        if not isinstance(item, dict):
            continue
        file_id = item.get("file_id") or item.get("fileId") or []
        if isinstance(file_id, str):
            file_id = [file_id] if file_id else []
        if not isinstance(file_id, list):
            file_id = []
        order = item.get("order_number") or item.get("orderNumber") or idx
        try:
            order_n = int(order)
        except (TypeError, ValueError):
            order_n = idx
        items.append(
            {
                "order_number": order_n,
                "action_date": str(item.get("action_date") or item.get("actionDate") or "").strip(),
                "description": str(item.get("description") or "").strip(),
                "comment": str(item.get("comment") or item.get("Comment") or "").strip(),
                "org_name": str(item.get("org_name") or item.get("orgName") or "").strip(),
                "owner_name": str(item.get("owner_name") or item.get("ownerName") or "").strip(),
                "file_id": [str(x) for x in file_id if x],
            }
        )
    items.sort(key=lambda row: row["order_number"])
    return items


def _lookup_gis_request_created_at(brid: str, owner_id: Any = None) -> Any:
    request_field = getattr(settings, "GIS_OBJECT_REQUEST_ID_FIELD", "request_id")
    owner_field = getattr(settings, "GIS_OBJECT_OWNER_FIELD", "OwnerLegalPersonId")
    tables = [
        getattr(settings, "GIS_OBJECT_TABLE", "dt"),
        getattr(settings, "GIS_ODH_TABLE", "odh"),
        getattr(settings, "GIS_OZN_TABLE", "ozn"),
        getattr(settings, "GIS_TOP_TABLE", "top"),
    ]
    owner_text = str(owner_id or "").strip()
    try:
        with connection.cursor() as cursor:
            for table in tables:
                if not table or not _table_exists(cursor, table):
                    continue
                if not _column_exists(cursor, table, request_field) or not _column_exists(cursor, table, "created_at"):
                    continue
                req_col = _resolve_column_name(cursor, table, request_field)
                created_col = _resolve_column_name(cursor, table, "created_at")
                sql = (
                    f"SELECT {_quote_ident(created_col)} FROM {_quote_ident(table)} "
                    f"WHERE {_quote_ident(req_col)}::text = %s"
                )
                params: list[Any] = [brid]
                if owner_text and _column_exists(cursor, table, owner_field):
                    own_col = _resolve_column_name(cursor, table, owner_field)
                    sql += f" AND {_quote_ident(own_col)}::text = %s"
                    params.append(owner_text)
                sql += " ORDER BY 1 DESC NULLS LAST LIMIT 1"
                cursor.execute(sql, params)
                row = cursor.fetchone()
                if row and row[0] is not None:
                    return row[0]
    except Exception:
        logger.exception("_lookup_gis_request_created_at failed for brid=%s", brid)
    return None


def validation_waiting_status(brid: str) -> dict[str, Any]:
    return {
        "brid": brid,
        "status_name": VALIDATION_STATUS_LABEL,
        "object_name": "",
        "inspection_date_plan": "",
        "create_type_name": "",
        "reason_name": "",
        "passportization_type_name": "",
        "timeline": build_validation_waiting_timeline(),
    }


def resolve_editor_ods_status(brid: str, owner_id: Any = None, created_at: Any = None) -> dict[str, Any]:
    """Registry timeline if this owner's ods_request row exists; else pending-validation or hidden."""
    brid = normalize_brid(brid)
    if not brid:
        return {"present": False, "in_registry": False, "status": None}
    status = lookup_ods_request_status(brid, owner_id=owner_id)
    if status:
        return {"present": True, "in_registry": True, "status": status}
    created = created_at if created_at is not None else _lookup_gis_request_created_at(brid, owner_id)
    if _within_validation_window(created):
        return {"present": True, "in_registry": False, "status": validation_waiting_status(brid)}
    return {"present": False, "in_registry": False, "status": None}


def lookup_bidapprove_comments(brid: str, owner_id: Any = None) -> list[dict[str, Any]]:
    """Live BidApprove JSON from master.BidRegistry via qgis alias."""
    brid = normalize_brid(brid)
    if not brid:
        return []
    if lookup_ods_request_status(brid, owner_id=owner_id) is None:
        return []
    try:
        qgis = connections["qgis"]
    except Exception:
        logger.warning("lookup_bidapprove_comments: qgis connection unavailable")
        return []
    try:
        with qgis.cursor() as cursor:
            if not _table_exists(cursor, "BidRegistry", schema="master") and not _table_exists(
                cursor, "bidregistry", schema="master"
            ):
                return []
            table = "BidRegistry" if _table_exists(cursor, "BidRegistry", schema="master") else "bidregistry"
            if not _column_exists(cursor, table, "BidApprove", schema="master"):
                return []
            if not _column_exists(cursor, table, "BrId", schema="master"):
                return []
            brid_col = _resolve_column_name(cursor, table, "BrId", schema="master")
            approve_col = _resolve_column_name(cursor, table, "BidApprove", schema="master")
            cursor.execute(
                f'SELECT b.{_quote_ident(approve_col)} FROM master.{_quote_ident(table)} b '
                f"WHERE b.{_quote_ident(brid_col)}::text = %s LIMIT 1",
                [brid],
            )
            row = cursor.fetchone()
            if not row:
                return []
            return _parse_bid_approve(row[0])
    except Exception:
        logger.exception("lookup_bidapprove_comments failed for brid=%s", brid)
        return []

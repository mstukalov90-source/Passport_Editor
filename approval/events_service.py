"""Serialization and business logic for approval events/chats."""

from __future__ import annotations

import calendar
import json
import re
import shutil
import uuid
from pathlib import Path

from django.conf import settings
from django.contrib.gis.geos import GEOSGeometry
from django.db import transaction
from django.db.models import Count, Prefetch
from django.db.models.functions import Lower
from django.utils import timezone

from .access import (
    get_accessible_approves,
    get_accessible_cases_queryset,
    is_inspector_for_approve,
    matching_case_owner_id,
    user_can_write_approvals,
)

from .models import (
    ApprovalGeometry,
    Approve,
    Case,
    CaseApproval,
    CaseMessage,
    CaseMessageDeleted,
    CaseMessageReaction,
    CaseServiceEvent,
)
from .work_adjacent import resolve_root_object_names
from .work_layers import (
    batch_lookup_task_poly_meta,
    lookup_task_poly_meta,
    lookup_task_survey_fields,
    resolve_task_owner_legal_person_id,
)

_NAMED_EVENT_TITLE_RE = re.compile(
    r"^Согласование заявок по паспортизации\s+(.+?)\s+и паспорта\s+(\S+)\s*$"
)


def format_named_event_title(*, task_label: str, passport_label: str) -> str:
    """Build secondary-event title with object names (or number fallbacks)."""
    return (
        f"Согласование заявок по паспортизации {task_label} "
        f"и паспорта {passport_label}"
    )


def build_case_title_named(
    case: Case,
    *,
    survey_name: str = "",
    survey_brid: str = "",
    root_names: dict[str, str] | None = None,
) -> str | None:
    """
    Named display title for a secondary case, or None when not applicable.

    Uses survey Name (fallback PassBrId / number from stored title) and
    RootId Name (fallback n_root).
    """
    if case.is_primary:
        return None
    n_root = str(case.n_root or "").strip()
    if not n_root:
        return None

    task_part = str(survey_name or "").strip() or str(survey_brid or "").strip()
    if not task_part:
        match = _NAMED_EVENT_TITLE_RE.match(str(case.title or "").strip())
        if match:
            task_part = str(match.group(1) or "").strip()
    if not task_part:
        return None

    names = root_names or {}
    passport_part = str(names.get(n_root) or "").strip() or n_root
    return format_named_event_title(task_label=task_part, passport_label=passport_part)


def attach_title_named(
    payload: dict,
    case: Case,
    *,
    survey_name: str = "",
    survey_brid: str = "",
    root_names: dict[str, str] | None = None,
) -> dict:
    """Set title_named on a serialized case payload."""
    payload["title_named"] = build_case_title_named(
        case,
        survey_name=survey_name,
        survey_brid=survey_brid,
        root_names=root_names,
    )
    return payload


def resolve_and_attach_title_named(payload: dict, case: Case) -> dict:
    """Resolve survey/root names for one case and attach title_named."""
    if case.is_primary:
        payload["title_named"] = None
        return payload
    approve = getattr(case, "approve", None)
    task_guid = str(getattr(approve, "incoming_guid", "") or "")
    survey_name, survey_brid = lookup_task_survey_fields(task_guid)
    n_root = str(case.n_root or "").strip()
    root_names = resolve_root_object_names([n_root]) if n_root else {}
    return attach_title_named(
        payload,
        case,
        survey_name=survey_name,
        survey_brid=survey_brid,
        root_names=root_names,
    )


def enrich_cases_payload_title_named(
    cases_payload: list[dict],
    cases: list[Case],
    *,
    task_guid: str,
) -> list[dict]:
    """Batch-resolve names and attach title_named to serialized case list."""
    if not cases_payload:
        return cases_payload

    survey_name, survey_brid = lookup_task_survey_fields(task_guid)
    root_ids = [
        str(case.n_root or "").strip()
        for case in cases
        if not case.is_primary and str(case.n_root or "").strip()
    ]
    root_names = resolve_root_object_names(root_ids)
    case_by_id = {str(case.id): case for case in cases}
    for payload in cases_payload:
        case = case_by_id.get(str(payload.get("id") or ""))
        if case is None:
            payload.setdefault("title_named", None)
            continue
        attach_title_named(
            payload,
            case,
            survey_name=survey_name,
            survey_brid=survey_brid,
            root_names=root_names,
        )
    return cases_payload


class ApproveAlreadyApprovedError(ValueError):
    """Raised when upsert is attempted on a fully approved approve."""


class ApproveUserConflictError(ValueError):
    """Raised when upsert is attempted by a different user for the same incoming_guid."""


def _format_dt(value):
    if not value:
        return ""
    local = timezone.localtime(value)
    return local.strftime("%d.%m.%Y %H:%M")


def _format_date(value):
    if not value:
        return ""
    local = timezone.localtime(value)
    return local.strftime("%d.%m.%Y")


def _add_calendar_months(value, months: int = 1):
    """Return value shifted by whole calendar months (clamped to month length)."""
    local = timezone.localtime(value)
    month_index = local.month - 1 + months
    year = local.year + month_index // 12
    month = month_index % 12 + 1
    day = min(local.day, calendar.monthrange(year, month)[1])
    return local.replace(year=year, month=month, day=day)


def _case_is_overdue(case: Case) -> bool:
    if case.approved or not case.created_at:
        return False
    return timezone.now() >= _add_calendar_months(case.created_at, 1)


def _ensure_overdue_closed_event(case: Case) -> None:
    """Lazily record a one-time closed_overdue service strip when the case becomes overdue."""
    if not _case_is_overdue(case):
        return
    if case.service_events.filter(kind=CaseServiceEvent.KIND_CLOSED_OVERDUE).exists():
        return
    deadline = _add_calendar_months(case.created_at, 1)
    event = CaseServiceEvent(
        case=case,
        actor_login="",
        kind=CaseServiceEvent.KIND_CLOSED_OVERDUE,
        created_at=deadline,
    )
    event.save()


def serialize_approve_option(
    approve: Approve,
    *,
    username: str | None = None,
    poly_meta: dict | None = None,
) -> dict:
    incoming_guid = str(approve.incoming_guid)
    name = (approve.name or "").strip()
    if name:
        label = name
    else:
        label = f"Согласование {incoming_guid[:8]}…"

    meta = poly_meta if isinstance(poly_meta, dict) else lookup_task_poly_meta(incoming_guid)
    source_label = str(meta.get("source_label") or "").strip()
    object_name = str(meta.get("object_name") or "").strip()
    if object_name:
        label = f"{label} ({object_name})"

    return {
        "id": str(approve.id),
        "incoming_guid": incoming_guid,
        "name": name,
        "label": label,
        "approved": approve.approved,
        "status_label": "Согласовано" if approve.approved else "В работе",
        "can_delete": bool(
            is_inspector_for_approve(username, approve) and user_can_write_approvals(username)
        ),
        "is_mine": bool(
            username
            and (approve.user or "").strip()
            and str(username).strip() == (approve.user or "").strip()
        ),
        "source_label": source_label,
        "object_name": object_name,
    }


def serialize_approve_options(
    approves,
    *,
    username: str | None = None,
) -> list[dict]:
    """Serialize approves with one batch poly-meta lookup for TaskGUIDs."""
    approve_list = list(approves or [])
    metas = batch_lookup_task_poly_meta(
        [getattr(item, "incoming_guid", "") for item in approve_list]
    )
    return [
        serialize_approve_option(
            item,
            username=username,
            poly_meta=metas.get(str(item.incoming_guid), {}),
        )
        for item in approve_list
    ]


def serialize_approve_qgis_summary(approve: Approve) -> dict:
    """Short approve payload for QGIS list/detail headers."""
    name = (approve.name or "").strip()
    cases_count = getattr(approve, "cases_count", None)
    if cases_count is None:
        cases_count = approve.cases.count()
    return {
        "id": str(approve.id),
        "incoming_guid": str(approve.incoming_guid),
        "name": name,
        "approved": bool(approve.approved),
        "user": (approve.user or "").strip(),
        "owners": list(approve.owners or []),
        "n_root": list(approve.n_root or []),
        "v_root": list(approve.v_root or []) if approve.v_root is not None else None,
        "cases_count": int(cases_count),
        "created_at": _format_dt(approve.created_at),
        "updated_at": _format_dt(approve.updated_at),
    }


def build_geometries_feature_collection(geometry_rows) -> dict:
    """GeoJSON FeatureCollection for QGIS map layers."""
    features = []
    for row in geometry_rows:
        geometry = _geometry_to_geojson(row)
        if geometry is None:
            continue
        case = row.case if hasattr(row, "case") else None
        features.append(
            {
                "type": "Feature",
                "id": row.id,
                "geometry": geometry,
                "properties": {
                    "geometry_id": row.id,
                    "approve_id": str(row.approve_id),
                    "case_id": str(row.case_id) if row.case_id else None,
                    "message_id": row.message_id,
                    "label": (row.label or "").strip(),
                    "n_root": (case.n_root or "") if case is not None else "",
                    "is_primary": bool(case.is_primary) if case is not None else False,
                    "owner_legal_person_id": row.owner_legal_person_id or "",
                },
            }
        )
    return {"type": "FeatureCollection", "features": features}


@transaction.atomic
def delete_approve_for_inspector(*, approve_id, username: str | None) -> Approve:
    username_text = (username or "").strip()
    if not username_text:
        raise ValueError("Не указан пользователь.")

    approve = Approve.objects.filter(pk=approve_id).first()
    if approve is None:
        raise ValueError("Согласование не найдено.")
    if not is_inspector_for_approve(username_text, approve):
        raise ValueError("Удаление доступно только инспектору этого согласования.")

    case_ids = list(approve.cases.values_list("id", flat=True))
    approve.delete()

    attachments_root = Path(settings.MEDIA_ROOT) / "approval" / "attachments"
    for case_id in case_ids:
        storage_dir = attachments_root / str(case_id)
        if storage_dir.is_dir():
            shutil.rmtree(storage_dir, ignore_errors=True)

    return approve


@transaction.atomic
def delete_case_for_inspector(*, case: Case, username: str | None) -> Case:
    username_text = (username or "").strip()
    if not username_text:
        raise ValueError("Не указан пользователь.")

    approve = case.approve
    if not is_inspector_for_approve(username_text, approve):
        raise ValueError("Удаление доступно только инспектору этого согласования.")
    if case.is_primary:
        raise ValueError("Нельзя удалить основное событие.")

    case_id = case.id
    case.delete()

    storage_dir = Path(settings.MEDIA_ROOT) / "approval" / "attachments" / str(case_id)
    if storage_dir.is_dir():
        shutil.rmtree(storage_dir, ignore_errors=True)

    return case


def _geometry_to_geojson(geometry_row: ApprovalGeometry | None) -> dict | None:
    if not geometry_row or not geometry_row.geom:
        return None
    try:
        return json.loads(geometry_row.geom.geojson)
    except (TypeError, ValueError):
        return None


def _case_status_class(case: Case) -> str:
    if case.approved:
        return "closed"
    if _case_is_overdue(case):
        return "overdue"
    return "active"


def _case_display_status(case: Case) -> str:
    if case.approved:
        return case.status or "согласовано"
    if _case_is_overdue(case):
        return "Просрочено"
    return case.status or "в работе"


def _case_last_message(case: Case) -> CaseMessage | None:
    return case.messages.order_by("-created_at").first()


def _case_preview(case: Case) -> str:
    last = _case_last_message(case)
    if not last:
        return ""
    body = (last.body or "").strip()
    if len(body) > 120:
        return body[:117] + "…"
    return body


def _case_approve_until(case: Case) -> str:
    if not case.created_at:
        return ""
    return _format_date(_add_calendar_months(case.created_at, 1))


def serialize_notification_case_row(case: Case) -> dict:
    """Compact case row for the home notifications modal."""
    _ensure_overdue_closed_event(case)
    last = _case_last_message(case)
    title = (case.title or "").strip()
    display_title = f"{title} (Основное)" if case.is_primary and title else title
    if case.is_primary and not title:
        display_title = "Основное событие"
    return {
        "id": str(case.id),
        "approve_id": str(case.approve_id),
        "title": title,
        "display_title": display_title,
        "title_named": None,
        "display_title_named": display_title,
        "is_primary": bool(case.is_primary),
        "status": _case_display_status(case),
        "status_class": _case_status_class(case),
        "approved": bool(case.approved),
        "created_at_date": _format_date(case.created_at),
        "last_message_author": (last.author_login if last else "") or "",
        "preview": _case_preview(case),
        "approve_until": _case_approve_until(case),
        "n_root": (case.n_root or "").strip(),
    }


def _finalize_notification_case_rows(
    rows: list[dict],
    cases: list[Case],
    *,
    task_guid: str,
) -> list[dict]:
    enrich_cases_payload_title_named(rows, cases, task_guid=task_guid)
    for row in rows:
        named = (row.get("title_named") or "").strip()
        if named:
            if row.get("is_primary"):
                row["display_title_named"] = f"{named} (Основное)"
            else:
                row["display_title_named"] = named
        else:
            row["display_title_named"] = row.get("display_title") or row.get("title") or ""
    return rows


def build_home_notifications(
    *,
    owner_id=None,
    username: str | None = None,
    owned_rootids=None,
) -> dict:
    """
    Build home notifications payload.

    Section 1: accessible non-approved Approves with nested open Cases that are
    not tied to the user's passport n_root (typically primary / taskguid cases).
    Section 2: open Cases whose n_root matches the user's passport rootids.
    """
    login = (username or "").strip()
    root_set = {
        str(root).strip().lower()
        for root in (owned_rootids or [])
        if root is not None and str(root).strip()
    }

    approves = list(get_accessible_approves(owner_id, username=login or None))
    open_approves = [item for item in approves if not item.approved]
    approve_options = {
        item["id"]: item
        for item in serialize_approve_options(open_approves, username=login or None)
    }

    approve_groups: list[dict] = []
    n_root_cases: list[dict] = []
    n_root_case_objs: list[Case] = []
    seen_n_root_ids: set[str] = set()
    open_case_count = 0

    def _is_user_n_root_case(case: Case) -> bool:
        n_root = (case.n_root or "").strip().lower()
        return bool(n_root and n_root in root_set)

    for approve in open_approves:
        cases_qs = list(
            get_accessible_cases_queryset(owner_id, approve.id, username=login or None)
            .filter(approved=False)
            .select_related("approve")
            .order_by("-is_primary", "-created_at")
        )
        nested_cases: list[Case] = []
        nested_rows: list[dict] = []
        for case in cases_qs:
            if _is_user_n_root_case(case):
                case_id = str(case.id)
                if case_id not in seen_n_root_ids:
                    n_root_cases.append(serialize_notification_case_row(case))
                    n_root_case_objs.append(case)
                    seen_n_root_ids.add(case_id)
                    open_case_count += 1
                continue
            nested_cases.append(case)
            nested_rows.append(serialize_notification_case_row(case))
            open_case_count += 1
        if not nested_rows:
            continue
        _finalize_notification_case_rows(
            nested_rows,
            nested_cases,
            task_guid=str(approve.incoming_guid),
        )
        option = approve_options.get(str(approve.id)) or serialize_approve_option(
            approve, username=login or None
        )
        approve_groups.append(
            {
                "approve": option,
                "cases": nested_rows,
            }
        )

    if root_set:
        n_root_qs = list(
            get_accessible_cases_queryset(owner_id, username=login or None)
            .filter(approved=False)
            .exclude(n_root__isnull=True)
            .exclude(n_root="")
            .annotate(n_root_lower=Lower("n_root"))
            .filter(n_root_lower__in=root_set)
            .select_related("approve")
            .order_by("-created_at")
        )
        for case in n_root_qs:
            case_id = str(case.id)
            if case_id in seen_n_root_ids:
                continue
            n_root_cases.append(serialize_notification_case_row(case))
            n_root_case_objs.append(case)
            seen_n_root_ids.add(case_id)
            open_case_count += 1

    if n_root_cases:
        by_guid: dict[str, list[tuple[dict, Case]]] = {}
        for row, case in zip(n_root_cases, n_root_case_objs):
            guid = str(getattr(case.approve, "incoming_guid", "") or "")
            by_guid.setdefault(guid, []).append((row, case))
        for guid, pairs in by_guid.items():
            rows = [pair[0] for pair in pairs]
            cases = [pair[1] for pair in pairs]
            _finalize_notification_case_rows(rows, cases, task_guid=guid)

    return {
        "approve_groups": approve_groups,
        "n_root_cases": n_root_cases,
        "open_case_count": open_case_count,
    }


def _normalized_case_owners(case: Case) -> list[str]:
    return [str(item).strip() for item in (case.owners or []) if str(item).strip()]


def _inspector_login_for_case(case: Case) -> str:
    return (case.approve.user or "").strip()


def _inspector_approved(case: Case) -> bool:
    inspector_login = _inspector_login_for_case(case)
    if not inspector_login:
        return True
    return case.approvals.filter(approver_login=inspector_login).exists()


def _owners_approved(case: Case) -> bool:
    required_owners = _normalized_case_owners(case)
    if not required_owners:
        return False
    done = case.approvals.filter(owner_legal_person_id__in=required_owners).count()
    return done >= len(required_owners)


def _case_is_fully_approved(case: Case) -> bool:
    return _owners_approved(case) and _inspector_approved(case)


def _approvals_progress(case: Case) -> tuple[int, int]:
    required_owners = _normalized_case_owners(case)
    owners_done = case.approvals.filter(owner_legal_person_id__in=required_owners).count()
    inspector_login = _inspector_login_for_case(case)
    inspector_required = bool(inspector_login)
    inspector_done = _inspector_approved(case)
    done = owners_done + (1 if inspector_done and inspector_required else 0)
    total = len(required_owners) + (1 if inspector_required else 0)
    return done, total


def validate_case_owners(*, is_primary: bool, owners: list[str]) -> list[str]:
    normalized = [str(item).strip() for item in owners if str(item).strip()]
    if is_primary:
        if len(normalized) != 1:
            raise ValueError("Основное событие должно иметь ровно одного владельца.")
    elif len(normalized) != 2:
        raise ValueError("Событие должно иметь ровно двух владельцев.")
    return normalized


def resolve_event_case_owners(*, task_owner_id: str, event_owners: list[str]) -> list[str]:
    task_owner = str(task_owner_id).strip()
    if not task_owner:
        raise ValueError("Не найден OwnerLegalPersonId для объекта съёмки.")

    normalized_event = [str(item).strip() for item in (event_owners or []) if str(item).strip()]
    if not normalized_event:
        raise ValueError("Укажите owners в events.")

    merged: list[str] = []
    for owner in [task_owner, *normalized_event]:
        if owner not in merged:
            merged.append(owner)

    if len(merged) > 2:
        raise ValueError("Событие должно иметь ровно двух владельцев.")
    return merged


def aggregate_approve_owners(*, task_owner_id: str, event_owners: list[str]) -> list[str]:
    merged: list[str] = []
    for owner in [str(task_owner_id).strip(), *(event_owners or [])]:
        if owner and owner not in merged:
            merged.append(owner)
    return merged


def _normalized_participant_logins(case: Case) -> list[str]:
    return [str(item).strip() for item in (case.participant_logins or []) if str(item).strip()]


def _case_participants(case: Case, *, inspector_login: str) -> list[dict]:
    participants: list[dict] = []
    for owner_id in _normalized_case_owners(case):
        participants.append({"kind": "owner", "id": owner_id})
    for login in _normalized_participant_logins(case):
        participants.append({"kind": "login", "login": login})
    if inspector_login:
        participants.append({"kind": "inspector", "login": inspector_login})
    return participants


def _merge_case_owners_preserving_extras(previous: list[str], qgis_owners: list[str]) -> list[str]:
    """Keep inspector-added owners that are not part of the QGIS owner set."""
    merged: list[str] = []
    seen: set[str] = set()
    for owner in [*(qgis_owners or []), *(previous or [])]:
        text = str(owner).strip()
        if not text or text in seen:
            continue
        seen.add(text)
        merged.append(text)
    return merged


@transaction.atomic
def change_case_owner(*, case: Case, old_owner: str, new_owner: str, username: str | None) -> Case:
    username_text = (username or "").strip()
    if not username_text:
        raise ValueError("Не указан пользователь.")
    if case.is_primary:
        raise ValueError("Смена владельца основного события недоступна.")
    if case.approved:
        raise ValueError("Событие уже согласовано. Изменение владельцев недоступно.")
    if not is_inspector_for_approve(username_text, case.approve):
        raise ValueError("Смена владельца доступна только инспектору этого согласования.")

    old_text = str(old_owner or "").strip()
    new_text = str(new_owner or "").strip()
    if not old_text or not new_text:
        raise ValueError("Укажите текущего и нового владельца.")
    if old_text == new_text:
        raise ValueError("Новый владелец совпадает с текущим.")

    owners = _normalized_case_owners(case)
    if old_text not in owners:
        raise ValueError("Указанный владелец не найден в событии.")
    if new_text in owners:
        raise ValueError("Новый владелец уже участвует в событии.")

    case.owners = [new_text if item == old_text else item for item in owners]
    case.save(update_fields=["owners", "updated_at"])
    return case


@transaction.atomic
def add_case_participant(*, case: Case, kind: str, value: str, username: str | None) -> Case:
    from pass_viewer.models import ExternalUser

    username_text = (username or "").strip()
    if not username_text:
        raise ValueError("Не указан пользователь.")
    if case.approved:
        raise ValueError("Событие уже согласовано. Добавление участников недоступно.")
    if not is_inspector_for_approve(username_text, case.approve):
        raise ValueError("Добавление участников доступно только инспектору этого согласования.")

    kind_text = str(kind or "").strip().lower()
    value_text = str(value or "").strip()
    if kind_text not in ("owner", "login"):
        raise ValueError("Укажите kind: owner или login.")
    if not value_text:
        raise ValueError("Укажите значение участника.")

    if kind_text == "owner":
        owners = _normalized_case_owners(case)
        if value_text in owners:
            raise ValueError("Владелец уже участвует в событии.")
        case.owners = [*owners, value_text]
        case.save(update_fields=["owners", "updated_at"])
        return case

    if not ExternalUser.objects.filter(login=value_text).exists():
        raise ValueError("Пользователь с таким login не найден.")
    logins = _normalized_participant_logins(case)
    if value_text in logins:
        raise ValueError("Пользователь уже добавлен в событие.")
    inspector_login = _inspector_login_for_case(case)
    if inspector_login and value_text == inspector_login:
        raise ValueError("Инспектор уже участвует в событии.")
    case.participant_logins = [*logins, value_text]
    case.save(update_fields=["participant_logins", "updated_at"])
    return case


def serialize_case_summary(
    case: Case,
    *,
    current_login: str,
    owner_id: str | None,
    approvals_done: int | None = None,
    approvals_total: int | None = None,
) -> dict:
    _ensure_overdue_closed_event(case)
    required_owners = _normalized_case_owners(case)
    if approvals_total is None or approvals_done is None:
        computed_done, computed_total = _approvals_progress(case)
        if approvals_total is None:
            approvals_total = computed_total
        if approvals_done is None:
            approvals_done = computed_done

    geometry_row = case.geometries.filter(message__isnull=True).order_by("id").first()
    matched_owner = matching_case_owner_id(case, owner_id, username=current_login)
    current_owner_approved = False
    if matched_owner:
        current_owner_approved = case.approvals.filter(owner_legal_person_id=matched_owner).exists()

    inspector_login = _inspector_login_for_case(case)
    inspector_required = bool(inspector_login)
    inspector_approved = _inspector_approved(case)
    current_user_is_inspector = is_inspector_for_approve(current_login, case.approve)
    can_write = user_can_write_approvals(current_login)
    current_user_is_owner = bool(matched_owner)
    current_inspector_approved = current_user_is_inspector and inspector_approved
    current_user_approved = current_inspector_approved or current_owner_approved

    return {
        "id": str(case.id),
        "title": case.title,
        "title_named": None,
        "status": _case_display_status(case),
        "status_class": _case_status_class(case),
        "approved": case.approved,
        "is_primary": case.is_primary,
        "messages_count": getattr(case, "messages_count", None) or case.messages.count(),
        "preview": _case_preview(case),
        "approvals_done": approvals_done,
        "approvals_total": approvals_total,
        "current_owner_approved": current_owner_approved,
        "current_user_approved": current_user_approved,
        "current_user_is_inspector": current_user_is_inspector and can_write,
        "current_user_is_owner": current_user_is_owner and can_write,
        "can_manage_participants": current_user_is_inspector and can_write and not case.approved,
        "can_delete": current_user_is_inspector and can_write and not case.is_primary,
        "inspector_login": inspector_login,
        "inspector_required": inspector_required,
        "inspector_approved": inspector_approved,
        "participants": _case_participants(case, inspector_login=inspector_login),
        "geometry": _geometry_to_geojson(geometry_row),
        "n_root": case.n_root or "",
        "owners": list(case.owners or []),
        "participant_logins": _normalized_participant_logins(case),
        "created_by_login": case.created_by_login or "",
        "created_at": _format_dt(case.created_at),
        "created_at_date": _format_date(case.created_at),
    }


def serialize_message(
    message: CaseMessage,
    *,
    current_login: str,
    request=None,
    case: Case | None = None,
    attachment_url_mode: str = "web",
) -> dict:
    attachments = []
    login = (current_login or "").strip()
    for attachment in message.attachments.all():
        if attachment_url_mode == "qgis":
            url = f"/approval/api/qgis/attachments/{attachment.id}/"
            if login:
                url = f"{url}?user={login}"
        else:
            url = f"/approval/api/attachments/{attachment.id}/"
        if request is not None:
            url = request.build_absolute_uri(url)
        attachments.append(
            {
                "id": attachment.id,
                "original_name": attachment.original_name,
                "content_type": attachment.content_type,
                "size_bytes": attachment.size_bytes,
                "url": url,
            }
        )
    geometry_rows = list(message.geometries.order_by("id"))
    geometries_payload = []
    for geometry_row in geometry_rows:
        geojson = _geometry_to_geojson(geometry_row)
        if geojson is None:
            continue
        geometries_payload.append({"id": geometry_row.id, "geometry": geojson})
    first_geometry = geometry_rows[0] if geometry_rows else None
    geometry_payload = _geometry_to_geojson(first_geometry) if first_geometry else None

    reactions = []
    my_reaction = None
    for reaction in message.reactions.all():
        is_own = reaction.reactor_login == current_login
        if is_own:
            my_reaction = reaction.kind
        reactions.append(
            {
                "kind": reaction.kind,
                "author": reaction.reactor_login,
                "is_own": is_own,
            }
        )

    parent = message.parent
    parent_id = parent.id if parent is not None else message.parent_id
    reply_to_author = parent.author_login if parent is not None else ""

    case_obj = case if case is not None else message.case
    inspector_login = _inspector_login_for_case(case_obj)
    can_delete = (
        bool(current_login)
        and message.author_login == current_login
        and bool(inspector_login)
        and current_login == inspector_login
        and not case_obj.approved
    )

    return {
        "id": message.id,
        "kind": "chat",
        "is_service": False,
        "author": message.author_login,
        "role": message.author_role or "",
        "time": _format_dt(message.created_at),
        "text": message.body,
        "is_own": message.author_login == current_login,
        "can_delete": can_delete,
        "parent_id": parent_id,
        "reply_to_author": reply_to_author,
        "attachments": attachments,
        "geometry": geometry_payload,
        "geometry_id": first_geometry.id if first_geometry else None,
        "geometries": geometries_payload,
        "reactions": reactions,
        "my_reaction": my_reaction,
        "created_at_sort": message.created_at.isoformat() if message.created_at else "",
    }


def serialize_service_event(event: CaseServiceEvent, *, current_login: str) -> dict:
    if event.kind == CaseServiceEvent.KIND_REVOKED:
        kind = "service_revoked"
        text = f"{event.actor_login} отменил согласование"
    elif event.kind == CaseServiceEvent.KIND_CLOSED:
        kind = "service_closed"
        text = "Событие закрыто"
    elif event.kind == CaseServiceEvent.KIND_CLOSED_OVERDUE:
        kind = "service_closed_overdue"
        text = "Событие закрыто по истечению срока"
    else:
        kind = "service_approved"
        text = f"{event.actor_login} согласовал"
    return {
        "id": f"s{event.id}",
        "kind": kind,
        "is_service": True,
        "author": event.actor_login,
        "role": "",
        "time": _format_dt(event.created_at),
        "text": text,
        "is_own": bool(event.actor_login) and event.actor_login == current_login,
        "can_delete": False,
        "parent_id": None,
        "reply_to_author": "",
        "attachments": [],
        "geometry": None,
        "geometry_id": None,
        "geometries": [],
        "reactions": [],
        "my_reaction": None,
        "created_at_sort": event.created_at.isoformat() if event.created_at else "",
    }


def compute_message_reaction_stats(messages) -> dict:
    unprocessed = 0
    in_progress = 0
    done = 0
    accepted = 0
    rejected = 0
    for message in messages:
        kinds = {reaction.kind for reaction in message.reactions.all()}
        has_target = _message_has_geometry_or_file(message)
        if has_target and CaseMessageReaction.KIND_IN_PROGRESS not in kinds and CaseMessageReaction.KIND_DONE not in kinds:
            unprocessed += 1
        if CaseMessageReaction.KIND_IN_PROGRESS in kinds:
            in_progress += 1
        if CaseMessageReaction.KIND_DONE in kinds:
            done += 1
        if CaseMessageReaction.KIND_ACCEPTED in kinds:
            accepted += 1
        if CaseMessageReaction.KIND_REJECTED in kinds:
            rejected += 1
    return {
        "unprocessed": unprocessed,
        "in_progress": in_progress,
        "done": done,
        "accepted": accepted,
        "rejected": rejected,
    }


def serialize_case_detail(
    case: Case,
    *,
    current_login: str,
    owner_id: str | None,
    request=None,
    attachment_url_mode: str = "web",
) -> dict:
    data = serialize_case_summary(case, current_login=current_login, owner_id=owner_id)
    messages = list(
        case.messages.select_related("parent").prefetch_related(
            "attachments",
            "geometries",
            "reactions",
        ).all()
    )
    chat_payload = [
        serialize_message(
            message,
            current_login=current_login,
            request=request,
            case=case,
            attachment_url_mode=attachment_url_mode,
        )
        for message in messages
    ]
    service_payload = [
        serialize_service_event(event, current_login=current_login)
        for event in case.service_events.all()
    ]
    timeline = chat_payload + service_payload
    timeline.sort(key=lambda item: (item.get("created_at_sort") or "", str(item.get("id") or "")))
    for item in timeline:
        item.pop("created_at_sort", None)
    data["messages"] = timeline
    data["message_reaction_stats"] = compute_message_reaction_stats(messages)
    return data


INSPECTOR_REACTION_KINDS = {
    CaseMessageReaction.KIND_IN_PROGRESS,
    CaseMessageReaction.KIND_DONE,
}
OWNER_VERDICT_KINDS = {
    CaseMessageReaction.KIND_ACCEPTED,
    CaseMessageReaction.KIND_REJECTED,
}
REACTION_KINDS = INSPECTOR_REACTION_KINDS | OWNER_VERDICT_KINDS


def _message_has_geometry_or_file(message: CaseMessage) -> bool:
    if hasattr(message, "_prefetched_objects_cache"):
        cache = message._prefetched_objects_cache
        if "attachments" in cache and "geometries" in cache:
            return bool(message.attachments.all()) or bool(message.geometries.all())
    return message.attachments.exists() or message.geometries.exists()


@transaction.atomic
def upsert_message_reaction(
    *,
    message: CaseMessage,
    username: str,
    kind: str,
    owner_id: str | None = None,
) -> CaseMessage:
    login = (username or "").strip()
    if not login:
        raise ValueError("Не найден пользователь.")
    if message.case.approved:
        raise ValueError("Событие уже согласовано. Реакции недоступны.")
    if kind not in REACTION_KINDS:
        raise ValueError("Некорректный тип реакции.")

    case = message.case
    if kind in INSPECTOR_REACTION_KINDS:
        if not is_inspector_for_approve(login, case.approve):
            raise ValueError("Реакции «В работе» и «Выполнено» доступны только инспектору.")
        if message.author_login == login:
            raise ValueError("Нельзя поставить реакцию на своё сообщение.")
        if not _message_has_geometry_or_file(message):
            raise ValueError("Реакцию можно поставить только на сообщение с геометрией или файлом.")
    else:
        owner_text = str(owner_id or "").strip()
        if not owner_text or owner_text not in _normalized_case_owners(case):
            raise ValueError("Реакции «Принято» и «Отклонено» доступны только владельцу события.")
        if not CaseMessageReaction.objects.filter(
            message=message,
            kind=CaseMessageReaction.KIND_DONE,
        ).exists():
            raise ValueError("Сначала инспектор должен отметить сообщение как «Выполнено».")

    existing = CaseMessageReaction.objects.filter(message=message, reactor_login=login).first()
    removed_done = False
    if existing and existing.kind == kind:
        removed_done = existing.kind == CaseMessageReaction.KIND_DONE
        existing.delete()
    elif existing:
        removed_done = (
            existing.kind == CaseMessageReaction.KIND_DONE
            and kind != CaseMessageReaction.KIND_DONE
        )
        existing.kind = kind
        existing.save(update_fields=["kind"])
    else:
        CaseMessageReaction.objects.create(
            message=message,
            reactor_login=login,
            kind=kind,
        )

    if removed_done and not CaseMessageReaction.objects.filter(
        message=message,
        kind=CaseMessageReaction.KIND_DONE,
    ).exists():
        CaseMessageReaction.objects.filter(
            message=message,
            kind__in=OWNER_VERDICT_KINDS,
        ).delete()

    return message


def get_cases_queryset(approve_id):
    return (
        Case.objects.filter(approve_id=approve_id)
        .select_related("approve")
        .annotate(messages_count=Count("messages"))
        .prefetch_related(
            Prefetch("geometries", queryset=ApprovalGeometry.objects.order_by("id")),
            "approvals",
        )
        .order_by("-is_primary", "-created_at")
    )


def parse_geometry_payload(payload) -> GEOSGeometry:
    if isinstance(payload, str):
        payload = json.loads(payload)
    if not isinstance(payload, dict):
        raise ValueError("Геометрия должна быть GeoJSON-объектом.")
    geom = GEOSGeometry(json.dumps(payload), srid=4326)
    if geom.srid != 4326:
        geom.transform(4326)
    return geom


def _normalize_string_list(raw, *, field_name: str) -> list[str]:
    if not isinstance(raw, list) or not raw:
        raise ValueError(f"Укажите непустой список {field_name}.")
    values = [str(item).strip() for item in raw if str(item).strip()]
    if not values:
        raise ValueError(f"Укажите непустой список {field_name}.")
    return values


def _normalize_optional_string_list(raw, *, field_name: str) -> tuple[list[str], bool]:
    if raw is None:
        return [], False
    if not isinstance(raw, list):
        raise ValueError(f"{field_name} должен быть массивом строк.")
    values = [str(item).strip() for item in raw if str(item).strip()]
    return values, True


def _validate_qgis_event(raw, *, index: int) -> dict:
    if not isinstance(raw, dict):
        raise ValueError(f"events[{index}] должен быть объектом.")

    n_root_raw = raw.get("n_root")
    if n_root_raw is None or str(n_root_raw).strip() == "":
        raise ValueError(f"Укажите n_root в events[{index}].")
    n_root = str(n_root_raw).strip()

    owners = _normalize_string_list(raw.get("owners"), field_name=f"owners в events[{index}]")

    title = (raw.get("name") or "").strip()
    if not title:
        raise ValueError(f"Укажите name в events[{index}].")

    geometry_payload = raw.get("geometry")
    if geometry_payload is None:
        raise ValueError(f"Укажите geometry в events[{index}].")
    geom = parse_geometry_payload(geometry_payload)

    return {
        "n_root": n_root,
        "owners": owners,
        "title": title,
        "geom": geom,
    }


def validate_qgis_approve_payload(payload) -> dict:
    if not isinstance(payload, dict):
        raise ValueError("Тело запроса должно быть JSON-объектом.")

    incoming_guid_raw = payload.get("incoming_guid")
    if not incoming_guid_raw:
        raise ValueError("Укажите incoming_guid.")
    try:
        incoming_guid = uuid.UUID(str(incoming_guid_raw))
    except (ValueError, AttributeError, TypeError):
        raise ValueError("Некорректный incoming_guid.") from None

    if "v_root" in payload:
        v_root, v_root_provided = _normalize_optional_string_list(
            payload.get("v_root"),
            field_name="v_root",
        )
    else:
        v_root, v_root_provided = [], False

    user = (payload.get("user") or "").strip()
    if not user:
        raise ValueError("Укажите user.")

    name = (payload.get("name") or "").strip()
    if not name:
        raise ValueError("Укажите name.")

    events_raw = payload.get("events")
    if not isinstance(events_raw, list) or not events_raw:
        raise ValueError("Укажите непустой список events.")

    events: list[dict] = []
    seen_n_roots: set[str] = set()
    for index, event_raw in enumerate(events_raw):
        event = _validate_qgis_event(event_raw, index=index)
        if event["n_root"] in seen_n_roots:
            raise ValueError(f"Дублирующийся n_root в events: {event['n_root']}.")
        seen_n_roots.add(event["n_root"])
        events.append(event)

    n_root: list[str] = []
    owners: list[str] = []
    owners_seen: set[str] = set()
    for event in events:
        if event["n_root"] not in n_root:
            n_root.append(event["n_root"])
        for owner in event["owners"]:
            if owner not in owners_seen:
                owners_seen.add(owner)
                owners.append(owner)

    return {
        "incoming_guid": incoming_guid,
        "v_root": v_root,
        "v_root_provided": v_root_provided,
        "user": user,
        "name": name,
        "n_root": n_root,
        "owners": owners,
        "events": events,
    }


def _upsert_case_geometry(*, approve: Approve, case: Case, geom: GEOSGeometry, label: str) -> ApprovalGeometry:
    geometry = case.geometries.filter(message__isnull=True).order_by("id").first()
    if geometry:
        geometry.geom = geom
        geometry.label = label
        geometry.save(update_fields=["geom", "label"])
        return geometry
    return ApprovalGeometry.objects.create(
        approve=approve,
        case=case,
        geom=geom,
        label=label,
    )


def _sync_primary_case_fields(*, primary_case: Case, owners: list[str], title: str) -> None:
    validate_case_owners(is_primary=True, owners=owners)
    primary_case.title = title
    primary_case.n_root = None
    primary_case.owners = owners
    primary_case.save(update_fields=["title", "n_root", "owners", "updated_at"])


def _upsert_qgis_event_cases(
    *,
    approve: Approve,
    events: list[dict],
    user: str,
    task_owner_id: str,
) -> list[dict]:
    results: list[dict] = []
    for event in events:
        n_root = event["n_root"]
        case = Case.objects.filter(
            approve=approve,
            is_primary=False,
            n_root=n_root,
        ).first()

        if case is not None and case.approved:
            geometry = case.geometries.filter(message__isnull=True).order_by("id").first()
            results.append(
                {
                    "n_root": n_root,
                    "case_id": str(case.id),
                    "geometry_id": geometry.id if geometry else None,
                    "created": False,
                    "skipped": True,
                }
            )
            continue

        event_owners = resolve_event_case_owners(
            task_owner_id=task_owner_id,
            event_owners=event["owners"],
        )

        if case is None:
            case = Case.objects.create(
                approve=approve,
                is_primary=False,
                title=event["title"],
                status="в работе",
                created_by_login=user,
                n_root=n_root,
                owners=event_owners,
            )
            CaseMessage.objects.create(
                case=case,
                author_login=user,
                author_role="",
                body="Событие создано.",
            )
            event_created = True
        else:
            previous_owners = _normalized_case_owners(case)
            case.title = event["title"]
            case.owners = _merge_case_owners_preserving_extras(previous_owners, event_owners)
            case.created_by_login = user
            case.save(update_fields=["title", "owners", "created_by_login", "updated_at"])
            event_created = False

        geometry = _upsert_case_geometry(
            approve=approve,
            case=case,
            geom=event["geom"],
            label=event["title"],
        )
        results.append(
            {
                "n_root": n_root,
                "case_id": str(case.id),
                "geometry_id": geometry.id,
                "created": event_created,
                "skipped": False,
            }
        )
    return results


@transaction.atomic
def upsert_approve_from_qgis(payload) -> dict:
    data = validate_qgis_approve_payload(payload)
    incoming_guid = data["incoming_guid"]
    primary_owner_id = resolve_task_owner_legal_person_id(str(incoming_guid))
    primary_owners = validate_case_owners(is_primary=True, owners=[primary_owner_id])
    approve_owners = aggregate_approve_owners(
        task_owner_id=primary_owner_id,
        event_owners=data["owners"],
    )

    approve = Approve.objects.filter(incoming_guid=incoming_guid).first()
    if approve is None:
        approve = Approve.objects.create(
            incoming_guid=incoming_guid,
            n_root=data["n_root"],
            v_root=data["v_root"],
            name=data["name"],
            owners=approve_owners,
            user=data["user"],
        )
        created = True
    else:
        existing_user = (approve.user or "").strip()
        if existing_user and existing_user != data["user"]:
            raise ApproveUserConflictError(
                "Согласование с этим incoming_guid уже создано другим пользователем."
            )
        if approve.approved:
            raise ApproveAlreadyApprovedError("Согласование уже согласовано. Изменение запрещено.")
        created = False
        approve.n_root = data["n_root"]
        approve.name = data["name"]
        approve.owners = approve_owners
        approve.user = data["user"]
        update_fields = ["n_root", "name", "owners", "user", "updated_at"]
        if data["v_root_provided"]:
            approve.v_root = data["v_root"]
            update_fields.insert(1, "v_root")
        approve.save(update_fields=update_fields)

    primary_case = approve.cases.get(is_primary=True)
    _sync_primary_case_fields(
        primary_case=primary_case,
        owners=primary_owners,
        title=data["name"],
    )

    event_results = _upsert_qgis_event_cases(
        approve=approve,
        events=data["events"],
        user=data["user"],
        task_owner_id=primary_owner_id,
    )

    return {
        "created": created,
        "approve_id": str(approve.id),
        "incoming_guid": str(incoming_guid),
        "primary_case_id": str(primary_case.id),
        "events": event_results,
    }


@transaction.atomic
def create_case_with_geometry(
    *,
    approve: Approve,
    title: str,
    geometry_payload,
    created_by_login: str,
    owner_id: str | None,
) -> Case:
    title_text = (title or "").strip()
    if not title_text:
        raise ValueError("Укажите название события.")

    geom = parse_geometry_payload(geometry_payload)

    approve_roots = [str(item).strip() for item in (approve.n_root or []) if str(item).strip()]
    case_n_root = approve_roots[0] if approve_roots else None

    case = Case.objects.create(
        approve=approve,
        is_primary=False,
        title=title_text,
        status="в работе",
        created_by_login=created_by_login,
        n_root=case_n_root,
        owners=list(approve.owners or []),
    )
    ApprovalGeometry.objects.create(
        approve=approve,
        case=case,
        geom=geom,
        label=title_text,
        owner_legal_person_id=owner_id,
    )
    CaseMessage.objects.create(
        case=case,
        author_login=created_by_login,
        author_role="",
        body="Событие создано.",
    )
    return case


@transaction.atomic
def create_event_from_adjacent(
    *,
    approve: Approve,
    n_root: str,
    geometry_payload,
    neighbor_owner: str,
    username: str | None,
    title: str | None = None,
) -> Case:
    username_text = (username or "").strip()
    if not username_text:
        raise ValueError("Не указан пользователь.")
    if not is_inspector_for_approve(username_text, approve):
        raise ValueError("Создание события доступно только инспектору этого согласования.")
    if approve.approved:
        raise ValueError("Согласование уже согласовано. Создание событий недоступно.")

    root_text = str(n_root or "").strip()
    if not root_text:
        raise ValueError("Укажите n_root (RootId) смежного объекта.")

    neighbor_text = str(neighbor_owner or "").strip()
    if not neighbor_text:
        raise ValueError("Не указан OwnerLegalPersonId смежного объекта.")

    if Case.objects.filter(approve=approve, is_primary=False, n_root=root_text).exists():
        raise ValueError(f"Событие для паспорта {root_text} уже существует.")

    task_owner_id = resolve_task_owner_legal_person_id(str(approve.incoming_guid))
    event_owners = resolve_event_case_owners(
        task_owner_id=task_owner_id,
        event_owners=[neighbor_text],
    )
    geom = parse_geometry_payload(geometry_payload)

    title_text = (title or "").strip()
    if not title_text:
        title_text = f"Согласование с паспортом {root_text}"

    case = Case.objects.create(
        approve=approve,
        is_primary=False,
        title=title_text,
        status="в работе",
        created_by_login=username_text,
        n_root=root_text,
        owners=event_owners,
    )
    ApprovalGeometry.objects.create(
        approve=approve,
        case=case,
        geom=geom,
        label=title_text,
        owner_legal_person_id=neighbor_text,
    )
    CaseMessage.objects.create(
        case=case,
        author_login=username_text,
        author_role="",
        body="Событие создано.",
    )

    n_roots = [str(item).strip() for item in (approve.n_root or []) if str(item).strip()]
    if root_text not in n_roots:
        n_roots.append(root_text)
    v_roots = [
        str(item).strip()
        for item in (approve.v_root or [])
        if str(item).strip() and str(item).strip() != root_text
    ]
    approve_owners = list(approve.owners or [])
    for owner in event_owners:
        if owner not in approve_owners:
            approve_owners.append(owner)
    approve.n_root = n_roots
    approve.v_root = v_roots
    approve.owners = approve_owners
    approve.save(update_fields=["n_root", "v_root", "owners", "updated_at"])

    return case


def _sync_approve_status_after_case_approval(approve: Approve, case: Case) -> None:
    if not case.is_primary or not case.approved or approve.approved:
        return
    approve.approved = True
    approve.save(update_fields=["approved", "updated_at"])


@transaction.atomic
def record_case_approval(*, case: Case, owner_id: str | None = None, username: str | None = None) -> Case:
    if case.approved:
        return case

    if username and not user_can_write_approvals(username):
        raise ValueError("Режим только для просмотра: согласование недоступно.")

    approve = case.approve
    inspector_login = (approve.user or "").strip()
    username_text = (username or "").strip()
    approval_author = ""

    if username_text and is_inspector_for_approve(username_text, approve):
        # Assigned inspector or global MGGT: fulfill the inspector approval slot.
        slot_login = inspector_login or username_text
        _, created = CaseApproval.objects.get_or_create(
            case=case,
            approver_login=slot_login,
            defaults={"owner_legal_person_id": None},
        )
        approval_author = username_text
    else:
        matched_owner = matching_case_owner_id(case, owner_id, username=username_text)
        if not matched_owner:
            raise ValueError("У вас нет права согласовывать это событие.")

        _, created = CaseApproval.objects.get_or_create(
            case=case,
            owner_legal_person_id=matched_owner,
            defaults={"approver_login": None},
        )
        approval_author = username_text or matched_owner

    if created and approval_author:
        CaseServiceEvent.objects.create(
            case=case,
            actor_login=approval_author,
            kind=CaseServiceEvent.KIND_APPROVED,
        )

    if _case_is_fully_approved(case):
        case.approved = True
        case.status = "согласовано"
        case.closed_at = timezone.now()
        case.save(update_fields=["approved", "status", "closed_at", "updated_at"])
        _sync_approve_status_after_case_approval(approve, case)
        CaseServiceEvent.objects.get_or_create(
            case=case,
            kind=CaseServiceEvent.KIND_CLOSED,
            defaults={"actor_login": approval_author or ""},
        )
    return case


def _sync_approve_status_after_case_revoke(approve: Approve, case: Case) -> None:
    if not case.is_primary or not approve.approved:
        return
    approve.approved = False
    approve.save(update_fields=["approved", "updated_at"])


@transaction.atomic
def revoke_case_approval(*, case: Case, owner_id: str | None = None, username: str | None = None) -> Case:
    if username and not user_can_write_approvals(username):
        raise ValueError("Режим только для просмотра: отзыв согласования недоступен.")

    approve = case.approve
    inspector_login = (approve.user or "").strip()
    username_text = (username or "").strip()
    deleted = 0
    revoke_author = ""

    if username_text and is_inspector_for_approve(username_text, approve):
        slot_login = inspector_login or username_text
        deleted, _ = CaseApproval.objects.filter(case=case, approver_login=slot_login).delete()
        revoke_author = username_text
    else:
        matched_owner = matching_case_owner_id(case, owner_id, username=username_text)
        if not matched_owner:
            raise ValueError("У вас нет права отзывать согласование этого события.")
        deleted, _ = CaseApproval.objects.filter(case=case, owner_legal_person_id=matched_owner).delete()
        revoke_author = username_text or matched_owner

    if not deleted:
        raise ValueError("У вас нет активного согласования для отзыва.")

    if revoke_author:
        CaseServiceEvent.objects.create(
            case=case,
            actor_login=revoke_author,
            kind=CaseServiceEvent.KIND_REVOKED,
        )

    if case.approved and not _case_is_fully_approved(case):
        case.approved = False
        case.status = "в работе"
        case.closed_at = None
        case.save(update_fields=["approved", "status", "closed_at", "updated_at"])
        _sync_approve_status_after_case_revoke(approve, case)
    return case


@transaction.atomic
def delete_inspector_own_message(*, message: CaseMessage, username: str | None) -> Case:
    username_text = (username or "").strip()
    if not username_text:
        raise ValueError("Не указан пользователь.")

    case = message.case
    approve = case.approve
    if not is_inspector_for_approve(username_text, approve):
        raise ValueError("Удаление сообщений доступно только инспектору этого согласования.")
    if message.author_login != username_text:
        raise ValueError("Можно удалять только свои сообщения.")
    if case.approved:
        raise ValueError("Нельзя удалять сообщения в согласованном событии.")

    attachments_snapshot = [
        {
            "id": attachment.id,
            "original_name": attachment.original_name,
            "content_type": attachment.content_type,
            "size_bytes": attachment.size_bytes,
            "stored_name": attachment.stored_name,
        }
        for attachment in message.attachments.all()
    ]

    CaseMessageDeleted.objects.create(
        original_message_id=message.id,
        case_id=case.id,
        author_login=message.author_login,
        author_role=message.author_role or "",
        body=message.body,
        parent_id=message.parent_id,
        created_at=message.created_at,
        deleted_by_login=username_text,
        attachments_json=attachments_snapshot or None,
    )

    storage_dir = Path(settings.MEDIA_ROOT) / "approval" / "attachments" / str(case.id)
    for attachment in message.attachments.all():
        target = storage_dir / attachment.stored_name
        if target.is_file():
            target.unlink(missing_ok=True)

    message.delete()
    return case


def attachment_allowed_extensions() -> set[str]:
    raw = getattr(
        settings,
        "APPROVAL_ATTACHMENT_ALLOWED_EXTENSIONS",
        {".jpg", ".jpeg", ".png", ".pdf", ".doc", ".docx"},
    )
    return {str(ext).lower() for ext in raw}


def attachment_max_bytes() -> int:
    return int(getattr(settings, "APPROVAL_ATTACHMENT_MAX_BYTES", 10 * 1024 * 1024))


def validate_attachment_file(uploaded_file):
    from pathlib import Path

    original_name = Path(uploaded_file.name or "").name
    if not original_name:
        raise ValueError("Пустое имя файла.")

    suffix = Path(original_name).suffix.lower()
    if suffix not in attachment_allowed_extensions():
        allowed = ", ".join(sorted(attachment_allowed_extensions()))
        raise ValueError(f"Недопустимый тип файла. Разрешены: {allowed}")

    size = int(getattr(uploaded_file, "size", 0) or 0)
    max_bytes = attachment_max_bytes()
    if size <= 0:
        raise ValueError("Пустой файл.")
    if size > max_bytes:
        raise ValueError(f"Файл слишком большой (максимум {max_bytes // (1024 * 1024)} МБ).")

    return original_name, suffix


@transaction.atomic
def attach_geometry_to_message(
    *,
    case: Case,
    message: CaseMessage,
    geometry_payload,
    owner_id: str | None,
) -> ApprovalGeometry:
    geom = parse_geometry_payload(geometry_payload)
    return ApprovalGeometry.objects.create(
        approve=case.approve,
        case=case,
        message=message,
        geom=geom,
        owner_legal_person_id=owner_id,
    )

"""Serialization and business logic for approval events/chats."""

from __future__ import annotations

import json
import uuid

from django.conf import settings
from django.contrib.gis.geos import GEOSGeometry
from django.db import transaction
from django.db.models import Count, Prefetch
from django.utils import timezone

from .models import (
    ApprovalGeometry,
    Approve,
    Case,
    CaseApproval,
    CaseMessage,
)
from .work_layers import resolve_task_owner_legal_person_id


class ApproveAlreadyApprovedError(ValueError):
    """Raised when upsert is attempted on a fully approved approve."""


def _format_dt(value):
    if not value:
        return ""
    local = timezone.localtime(value)
    return local.strftime("%d.%m.%Y %H:%M")


def serialize_approve_option(approve: Approve) -> dict:
    incoming_guid = str(approve.incoming_guid)
    name = (approve.name or "").strip()
    if name:
        label = name
    else:
        label = f"Согласование {incoming_guid[:8]}…"
    return {
        "id": str(approve.id),
        "incoming_guid": incoming_guid,
        "name": name,
        "label": label,
        "approved": approve.approved,
        "status_label": "Согласовано" if approve.approved else "В работе",
    }


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
    return "active"


def _case_preview(case: Case) -> str:
    last = case.messages.order_by("-created_at").first()
    if not last:
        return ""
    body = (last.body or "").strip()
    if len(body) > 120:
        return body[:117] + "…"
    return body


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

    if len(merged) < 2:
        raise ValueError(
            "Владелец объекта съёмки и сторона смежного паспорта должны быть разными участниками события."
        )
    if len(merged) > 2:
        raise ValueError("Событие должно иметь ровно двух владельцев.")
    return merged


def aggregate_approve_owners(*, task_owner_id: str, event_owners: list[str]) -> list[str]:
    merged: list[str] = []
    for owner in [str(task_owner_id).strip(), *(event_owners or [])]:
        if owner and owner not in merged:
            merged.append(owner)
    return merged


def _case_participants(case: Case, *, inspector_login: str) -> list[dict]:
    participants: list[dict] = []
    for owner_id in _normalized_case_owners(case):
        participants.append({"kind": "owner", "id": owner_id})
    if inspector_login:
        participants.append({"kind": "inspector", "login": inspector_login})
    return participants


def serialize_case_summary(
    case: Case,
    *,
    current_login: str,
    owner_id: str | None,
    approvals_done: int | None = None,
    approvals_total: int | None = None,
) -> dict:
    required_owners = _normalized_case_owners(case)
    if approvals_total is None or approvals_done is None:
        computed_done, computed_total = _approvals_progress(case)
        if approvals_total is None:
            approvals_total = computed_total
        if approvals_done is None:
            approvals_done = computed_done

    geometry_row = case.geometries.filter(message__isnull=True).order_by("id").first()
    current_owner_approved = False
    if owner_id:
        current_owner_approved = case.approvals.filter(owner_legal_person_id=str(owner_id)).exists()

    inspector_login = _inspector_login_for_case(case)
    inspector_required = bool(inspector_login)
    inspector_approved = _inspector_approved(case)
    current_user_is_inspector = bool(inspector_login) and current_login == inspector_login
    current_inspector_approved = current_user_is_inspector and inspector_approved
    current_user_approved = current_inspector_approved or current_owner_approved

    return {
        "id": str(case.id),
        "title": case.title,
        "status": case.status,
        "status_class": _case_status_class(case),
        "approved": case.approved,
        "is_primary": case.is_primary,
        "messages_count": getattr(case, "messages_count", None) or case.messages.count(),
        "preview": _case_preview(case),
        "approvals_done": approvals_done,
        "approvals_total": approvals_total,
        "current_owner_approved": current_owner_approved,
        "current_user_approved": current_user_approved,
        "current_user_is_inspector": current_user_is_inspector,
        "inspector_login": inspector_login,
        "inspector_required": inspector_required,
        "inspector_approved": inspector_approved,
        "participants": _case_participants(case, inspector_login=inspector_login),
        "geometry": _geometry_to_geojson(geometry_row),
        "n_root": case.n_root or "",
        "owners": list(case.owners or []),
        "created_by_login": case.created_by_login or "",
    }


def serialize_message(message: CaseMessage, *, current_login: str, request=None) -> dict:
    attachments = []
    for attachment in message.attachments.all():
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
    geometry_row = message.geometries.order_by("id").first()
    geometry_payload = _geometry_to_geojson(geometry_row)
    return {
        "id": message.id,
        "author": message.author_login,
        "role": message.author_role or "",
        "time": _format_dt(message.created_at),
        "text": message.body,
        "is_own": message.author_login == current_login,
        "attachments": attachments,
        "geometry": geometry_payload,
        "geometry_id": geometry_row.id if geometry_row else None,
    }


def serialize_case_detail(case: Case, *, current_login: str, owner_id: str | None, request=None) -> dict:
    data = serialize_case_summary(case, current_login=current_login, owner_id=owner_id)
    data["messages"] = [
        serialize_message(message, current_login=current_login, request=request)
        for message in case.messages.prefetch_related("attachments", "geometries").all()
    ]
    return data


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
            case.title = event["title"]
            case.owners = event_owners
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


def _sync_approve_status_after_case_approval(approve: Approve, case: Case) -> None:
    if not case.is_primary or not case.approved or approve.approved:
        return
    approve.approved = True
    approve.save(update_fields=["approved", "updated_at"])


@transaction.atomic
def record_case_approval(*, case: Case, owner_id: str | None = None, username: str | None = None) -> Case:
    if case.approved:
        return case

    approve = case.approve
    inspector_login = (approve.user or "").strip()
    username_text = (username or "").strip()

    if username_text and inspector_login and username_text == inspector_login:
        CaseApproval.objects.get_or_create(
            case=case,
            approver_login=inspector_login,
            defaults={"owner_legal_person_id": None},
        )
    elif owner_id:
        owner_text = str(owner_id).strip()
        if not owner_text:
            raise ValueError("Не найден OwnerLegalPersonId для пользователя.")

        required_owners = _normalized_case_owners(case)
        if owner_text not in required_owners:
            raise ValueError("У вас нет права согласовывать это событие.")

        CaseApproval.objects.get_or_create(
            case=case,
            owner_legal_person_id=owner_text,
            defaults={"approver_login": None},
        )
    else:
        raise ValueError("Не найден OwnerLegalPersonId для пользователя.")

    if _case_is_fully_approved(case):
        case.approved = True
        case.status = "согласовано"
        case.closed_at = timezone.now()
        case.save(update_fields=["approved", "status", "closed_at", "updated_at"])
        _sync_approve_status_after_case_approval(approve, case)
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

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


def serialize_case_summary(
    case: Case,
    *,
    current_login: str,
    owner_id: str | None,
    approvals_done: int | None = None,
    approvals_total: int | None = None,
) -> dict:
    required_owners = [str(item).strip() for item in (case.owners or []) if str(item).strip()]
    if approvals_total is None:
        approvals_total = len(required_owners)
    if approvals_done is None:
        approvals_done = case.approvals.filter(owner_legal_person_id__in=required_owners).count()

    geometry_row = case.geometries.filter(message__isnull=True).order_by("id").first()
    current_owner_approved = False
    if owner_id:
        current_owner_approved = case.approvals.filter(owner_legal_person_id=str(owner_id)).exists()

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
        "geometry": _geometry_to_geojson(geometry_row),
        "n_root": list(case.n_root or []),
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

    n_root_raw = payload.get("n_root")
    if isinstance(n_root_raw, str):
        n_root_raw = [n_root_raw]
    if not isinstance(n_root_raw, list) or not n_root_raw:
        raise ValueError("Укажите непустой список n_root.")
    n_root = [str(item).strip() for item in n_root_raw if str(item).strip()]
    if not n_root:
        raise ValueError("Укажите непустой список n_root.")

    v_root_raw = payload.get("v_root")
    if not isinstance(v_root_raw, list) or len(v_root_raw) != 2:
        raise ValueError("v_root должен содержать ровно 2 элемента.")
    v_root = [str(item).strip() for item in v_root_raw]
    if not all(v_root):
        raise ValueError("Элементы v_root не могут быть пустыми.")

    name = (payload.get("name") or "").strip()
    if not name:
        raise ValueError("Укажите name.")

    owners_raw = payload.get("owners")
    if not isinstance(owners_raw, list) or not owners_raw:
        raise ValueError("Укажите непустой список owners.")
    owners = [str(item).strip() for item in owners_raw if str(item).strip()]
    if not owners:
        raise ValueError("Укажите непустой список owners.")

    geometry_payload = payload.get("geometry")
    if geometry_payload is None:
        raise ValueError("Укажите geometry.")
    geom = parse_geometry_payload(geometry_payload)

    return {
        "incoming_guid": incoming_guid,
        "n_root": n_root,
        "v_root": v_root,
        "name": name,
        "owners": owners,
        "geom": geom,
    }


def _upsert_primary_geometry(*, approve: Approve, primary_case: Case, geom: GEOSGeometry, label: str) -> ApprovalGeometry:
    geometry = primary_case.geometries.filter(message__isnull=True).order_by("id").first()
    if geometry:
        geometry.geom = geom
        geometry.label = label
        geometry.save(update_fields=["geom", "label"])
        return geometry
    return ApprovalGeometry.objects.create(
        approve=approve,
        case=primary_case,
        geom=geom,
        label=label,
    )


def _sync_primary_case_fields(*, primary_case: Case, n_root: list[str], owners: list[str], title: str) -> None:
    primary_case.title = title
    primary_case.n_root = n_root
    primary_case.owners = owners
    primary_case.save(update_fields=["title", "n_root", "owners", "updated_at"])


@transaction.atomic
def upsert_approve_from_qgis(payload) -> dict:
    data = validate_qgis_approve_payload(payload)
    incoming_guid = data["incoming_guid"]

    approve = Approve.objects.filter(incoming_guid=incoming_guid).first()
    if approve is None:
        approve = Approve.objects.create(
            incoming_guid=incoming_guid,
            n_root=data["n_root"],
            v_root=data["v_root"],
            name=data["name"],
            owners=data["owners"],
        )
        created = True
        primary_case = approve.cases.get(is_primary=True)
        _sync_primary_case_fields(
            primary_case=primary_case,
            n_root=data["n_root"],
            owners=data["owners"],
            title=data["name"],
        )
        geometry = ApprovalGeometry.objects.create(
            approve=approve,
            case=primary_case,
            geom=data["geom"],
            label=data["name"],
        )
    else:
        if approve.approved:
            raise ApproveAlreadyApprovedError("Согласование уже согласовано. Изменение запрещено.")
        created = False
        approve.n_root = data["n_root"]
        approve.v_root = data["v_root"]
        approve.name = data["name"]
        approve.owners = data["owners"]
        approve.save(update_fields=["n_root", "v_root", "name", "owners", "updated_at"])
        primary_case = approve.cases.get(is_primary=True)
        _sync_primary_case_fields(
            primary_case=primary_case,
            n_root=data["n_root"],
            owners=data["owners"],
            title=data["name"],
        )
        geometry = _upsert_primary_geometry(
            approve=approve,
            primary_case=primary_case,
            geom=data["geom"],
            label=data["name"],
        )

    return {
        "created": created,
        "approve_id": str(approve.id),
        "incoming_guid": str(incoming_guid),
        "primary_case_id": str(primary_case.id),
        "geometry_id": geometry.id,
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

    case = Case.objects.create(
        approve=approve,
        is_primary=False,
        title=title_text,
        status="в работе",
        created_by_login=created_by_login,
        n_root=list(approve.n_root or []),
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
def record_case_approval(*, case: Case, owner_id: str) -> Case:
    owner_text = str(owner_id).strip()
    if not owner_text:
        raise ValueError("Не найден OwnerLegalPersonId для пользователя.")

    required_owners = [str(item).strip() for item in (case.owners or []) if str(item).strip()]
    if owner_text not in required_owners:
        raise ValueError("У вас нет права согласовывать это событие.")

    if case.approved:
        return case

    CaseApproval.objects.get_or_create(
        case=case,
        owner_legal_person_id=owner_text,
    )
    done = case.approvals.filter(owner_legal_person_id__in=required_owners).count()
    if done >= len(required_owners):
        case.approved = True
        case.status = "согласовано"
        case.closed_at = timezone.now()
        case.save(update_fields=["approved", "status", "closed_at", "updated_at"])
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

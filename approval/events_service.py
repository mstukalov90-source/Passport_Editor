"""Serialization and business logic for approval events/chats."""

from __future__ import annotations

import json

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


def _format_dt(value):
    if not value:
        return ""
    local = timezone.localtime(value)
    return local.strftime("%d.%m.%Y %H:%M")


def serialize_approve_option(approve: Approve) -> dict:
    label = str(approve.incoming_guid)
    short = label[:8]
    return {
        "id": str(approve.id),
        "incoming_guid": label,
        "label": f"Согласование {short}…",
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
    if approvals_total is None:
        approvals_total = len(case.approve.owners or [])
    if approvals_done is None:
        approvals_done = case.approvals.count()

    geometry_row = case.geometries.order_by("id").first()
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
    return {
        "id": message.id,
        "author": message.author_login,
        "role": message.author_role or "",
        "time": _format_dt(message.created_at),
        "text": message.body,
        "is_own": message.author_login == current_login,
        "attachments": attachments,
    }


def serialize_case_detail(case: Case, *, current_login: str, owner_id: str | None, request=None) -> dict:
    data = serialize_case_summary(case, current_login=current_login, owner_id=owner_id)
    data["messages"] = [
        serialize_message(message, current_login=current_login, request=request)
        for message in case.messages.prefetch_related("attachments").all()
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

    required_owners = [str(item).strip() for item in (case.approve.owners or []) if str(item).strip()]
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

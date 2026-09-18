from __future__ import annotations

from datetime import timedelta

from django.contrib.gis.geos import GEOSGeometry
from django.contrib.gis.geos.error import GEOSException
from django.db import transaction
from django.utils import timezone

from pass_viewer.roles import ROLE_MGGT, get_user_role, resolve_user_scope

from .models import (
    AttributeChange,
    ObjectChangeRequest,
    RecheckApproval,
    RecheckEvent,
    RecheckMessage,
)


def add_business_days(value, days: int):
    result = value
    remaining = max(0, int(days))
    while remaining:
        result += timedelta(days=1)
        if result.weekday() < 5:
            remaining -= 1
    return result


@transaction.atomic
def create_recheck_for_approved(approve) -> RecheckEvent:
    primary = approve.cases.filter(is_primary=True).only("owners").first()
    task_owner_id = ""
    if primary:
        task_owner_id = next(
            (str(item).strip() for item in (primary.owners or []) if str(item).strip()),
            "",
        )
    event, _ = RecheckEvent.objects.get_or_create(
        source_approve=approve,
        defaults={
            "task_guid": approve.incoming_guid,
            "task_owner_id": task_owner_id,
            "due_at": add_business_days(timezone.now(), 5),
        },
    )
    return event


def expire_due_events(now=None) -> int:
    moment = now or timezone.now()
    return RecheckEvent.objects.filter(
        status=RecheckEvent.STATUS_OPEN,
        due_at__lte=moment,
    ).update(status=RecheckEvent.STATUS_EXPIRED, closed_at=moment)


def _normalize_changes(changes) -> list[dict]:
    if not isinstance(changes, list) or not changes:
        raise ValueError("Укажите хотя бы одно изменение характеристики.")
    normalized = []
    seen = set()
    for raw in changes:
        if not isinstance(raw, dict):
            raise ValueError("Каждое изменение должно быть объектом.")
        field_name = str(raw.get("field_name") or "").strip()
        if not field_name:
            raise ValueError("У изменения не указано имя поля.")
        if field_name in seen:
            raise ValueError(f"Поле {field_name} указано несколько раз.")
        if raw.get("old_value") == raw.get("new_value"):
            continue
        seen.add(field_name)
        normalized.append(
            {
                "field_name": field_name,
                "field_label": str(raw.get("field_label") or field_name).strip(),
                "old_value": raw.get("old_value"),
                "new_value": raw.get("new_value"),
            }
        )
    if not normalized:
        raise ValueError("Новые значения не отличаются от исходных.")
    return normalized


def _format_change_message(obj: ObjectChangeRequest, changes: list[dict]) -> str:
    identity = obj.object_name or obj.root_id or obj.object_key
    lines = [f"Запрошено изменение объекта «{identity}» ({obj.source_layer}):"]
    for change in changes:
        lines.append(
            f"• {change['field_label']}: {change['old_value']!s} → {change['new_value']!s}"
        )
    return "\n".join(lines)


@transaction.atomic
def create_object_request(*, event, actor_login: str, payload: dict) -> ObjectChangeRequest:
    if event.status != RecheckEvent.STATUS_OPEN or event.due_at <= timezone.now():
        expire_due_events()
        raise ValueError("Срок проверки завершён.")
    changes = _normalize_changes(payload.get("changes"))
    source_layer = str(payload.get("source_layer") or "").strip()
    object_key = str(payload.get("object_key") or "").strip()
    if not source_layer or not object_key:
        raise ValueError("Не удалось определить слой или идентификатор объекта.")
    properties = payload.get("properties") or {}
    if not isinstance(properties, dict):
        raise ValueError("properties должно быть объектом.")
    geometry = payload.get("geometry")
    geom = None
    if geometry:
        try:
            import json

            geom = GEOSGeometry(json.dumps(geometry), srid=4326)
        except (GEOSException, TypeError, ValueError):
            raise ValueError("Некорректная геометрия объекта.") from None
    obj = ObjectChangeRequest.objects.create(
        event=event,
        source_layer=source_layer,
        object_key=object_key,
        root_id=str(payload.get("root_id") or "").strip(),
        object_name=str(payload.get("object_name") or "").strip(),
        original_properties=properties,
        geom=geom,
        requested_by_login=actor_login,
    )
    AttributeChange.objects.bulk_create(
        [AttributeChange(object_request=obj, **change) for change in changes]
    )
    RecheckMessage.objects.create(
        event=event,
        object_request=obj,
        author_login=actor_login,
        body=_format_change_message(obj, changes),
    )
    return obj


@transaction.atomic
def approve_event(*, event: RecheckEvent, actor_login: str) -> RecheckEvent:
    expire_due_events()
    event = RecheckEvent.objects.select_for_update().get(pk=event.pk)
    if event.status != RecheckEvent.STATUS_OPEN:
        raise ValueError("Проверка уже закрыта.")
    login = str(actor_login or "").strip()
    if event.task_owner_id in resolve_user_scope(login).owner_ids:
        kind = RecheckApproval.KIND_REQUESTER
    elif get_user_role(login) == ROLE_MGGT:
        kind = RecheckApproval.KIND_INSPECTOR
    else:
        raise ValueError("У вас нет права согласовывать эту проверку.")
    RecheckApproval.objects.get_or_create(
        event=event,
        kind=kind,
        defaults={"actor_login": login},
    )
    kinds = set(event.approvals.values_list("kind", flat=True))
    required = {RecheckApproval.KIND_REQUESTER, RecheckApproval.KIND_INSPECTOR}
    if required.issubset(kinds):
        event.status = RecheckEvent.STATUS_AGREED
        event.closed_at = timezone.now()
        event.save(update_fields=["status", "closed_at"])
    return event

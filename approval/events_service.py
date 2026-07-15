"""Serialization and business logic for approval events/chats."""

from __future__ import annotations

import json
import shutil
import uuid
from pathlib import Path

from django.conf import settings
from django.contrib.gis.geos import GEOSGeometry
from django.db import transaction
from django.db.models import Count, Prefetch
from django.utils import timezone

from .access import is_inspector_for_approve
from .models import (
    ApprovalGeometry,
    Approve,
    Case,
    CaseApproval,
    CaseMessage,
    CaseMessageReaction,
)
from .work_layers import resolve_task_owner_legal_person_id


class ApproveAlreadyApprovedError(ValueError):
    """Raised when upsert is attempted on a fully approved approve."""


class ApproveUserConflictError(ValueError):
    """Raised when upsert is attempted by a different user for the same incoming_guid."""


def _format_dt(value):
    if not value:
        return ""
    local = timezone.localtime(value)
    return local.strftime("%d.%m.%Y %H:%M")


def serialize_approve_option(approve: Approve, *, username: str | None = None) -> dict:
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
        "can_delete": is_inspector_for_approve(username, approve),
    }


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
        "can_manage_participants": current_user_is_inspector and not case.approved,
        "inspector_login": inspector_login,
        "inspector_required": inspector_required,
        "inspector_approved": inspector_approved,
        "participants": _case_participants(case, inspector_login=inspector_login),
        "geometry": _geometry_to_geojson(geometry_row),
        "n_root": case.n_root or "",
        "owners": list(case.owners or []),
        "participant_logins": _normalized_participant_logins(case),
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

    return {
        "id": message.id,
        "author": message.author_login,
        "role": message.author_role or "",
        "time": _format_dt(message.created_at),
        "text": message.body,
        "is_own": message.author_login == current_login,
        "parent_id": parent_id,
        "reply_to_author": reply_to_author,
        "attachments": attachments,
        "geometry": geometry_payload,
        "geometry_id": first_geometry.id if first_geometry else None,
        "geometries": geometries_payload,
        "reactions": reactions,
        "my_reaction": my_reaction,
    }


def serialize_case_detail(case: Case, *, current_login: str, owner_id: str | None, request=None) -> dict:
    data = serialize_case_summary(case, current_login=current_login, owner_id=owner_id)
    data["messages"] = [
        serialize_message(message, current_login=current_login, request=request)
        for message in case.messages.select_related("parent").prefetch_related(
            "attachments",
            "geometries",
            "reactions",
        ).all()
    ]
    return data


REACTION_KINDS = {
    CaseMessageReaction.KIND_IN_PROGRESS,
    CaseMessageReaction.KIND_DONE,
}


@transaction.atomic
def upsert_message_reaction(
    *,
    message: CaseMessage,
    username: str,
    kind: str,
) -> CaseMessage:
    login = (username or "").strip()
    if not login:
        raise ValueError("Не найден пользователь.")
    if message.author_login == login:
        raise ValueError("Нельзя поставить реакцию на своё сообщение.")
    if message.case.approved:
        raise ValueError("Событие уже согласовано. Реакции недоступны.")
    if kind not in REACTION_KINDS:
        raise ValueError("Некорректный тип реакции.")

    existing = CaseMessageReaction.objects.filter(message=message, reactor_login=login).first()
    if existing and existing.kind == kind:
        existing.delete()
    elif existing:
        existing.kind = kind
        existing.save(update_fields=["kind"])
    else:
        CaseMessageReaction.objects.create(
            message=message,
            reactor_login=login,
            kind=kind,
        )
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


def _sync_approve_status_after_case_revoke(approve: Approve, case: Case) -> None:
    if not case.is_primary or not approve.approved:
        return
    approve.approved = False
    approve.save(update_fields=["approved", "updated_at"])


@transaction.atomic
def revoke_case_approval(*, case: Case, owner_id: str | None = None, username: str | None = None) -> Case:
    approve = case.approve
    inspector_login = (approve.user or "").strip()
    username_text = (username or "").strip()
    deleted = 0

    if username_text and inspector_login and username_text == inspector_login:
        deleted, _ = CaseApproval.objects.filter(case=case, approver_login=inspector_login).delete()
    elif owner_id:
        owner_text = str(owner_id).strip()
        if not owner_text:
            raise ValueError("Не найден OwnerLegalPersonId для пользователя.")
        required_owners = _normalized_case_owners(case)
        if owner_text not in required_owners:
            raise ValueError("У вас нет права отзывать согласование этого события.")
        deleted, _ = CaseApproval.objects.filter(case=case, owner_legal_person_id=owner_text).delete()
    else:
        raise ValueError("Не найден OwnerLegalPersonId для пользователя.")

    if not deleted:
        raise ValueError("У вас нет активного согласования для отзыва.")

    if case.approved and not _case_is_fully_approved(case):
        case.approved = False
        case.status = "в работе"
        case.closed_at = None
        case.save(update_fields=["approved", "status", "closed_at", "updated_at"])
        _sync_approve_status_after_case_revoke(approve, case)
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

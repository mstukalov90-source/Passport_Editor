import json
import uuid

from django.contrib.auth.decorators import login_required
from django.db import IntegrityError
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render
from django.urls import reverse
from django.views.decorators.http import require_GET, require_POST

from approval.map_load import build_map_layer_load_order, resolve_map_layer_features
from approval.qml_style_builder import load_manifest, load_svg_index
from approval.work_geojson import allowed_cls_lookups, list_cls_lookup_options
from approval.work_layers import (
    build_layer_groups,
    build_topopassport_layer_groups,
    count_features_by_table,
    count_topopassport_features_by_table,
    resolve_task_survey_title,
)
from pass_viewer.roles import resolve_user_scope

from .access import accessible_events, can_access_event, is_mggt
from .models import RecheckEvent, RecheckMessage
from .services import approve_event, create_object_request, expire_due_events


def _error(message, status=400):
    return JsonResponse({"ok": False, "error": message}, status=status)


def _payload(request):
    try:
        value = json.loads(request.body or "{}")
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None
    return value if isinstance(value, dict) else None


def _event_for_user(event_id, username):
    event = get_object_or_404(RecheckEvent.objects.select_related("source_approve"), pk=event_id)
    return event if can_access_event(event, username) else None


def _serialize_event(event, username, *, detail=False):
    approvals = {item.kind: item.actor_login for item in event.approvals.all()}
    is_task_user = bool(event.task_owner_id) and event.task_owner_id in resolve_user_scope(username).owner_ids
    data = {
        "id": str(event.id),
        "task_guid": str(event.task_guid),
        "title": event.title,
        "status": event.status,
        "status_label": event.get_status_display(),
        "task_owner_id": event.task_owner_id,
        "created_at": event.created_at.isoformat(),
        "due_at": event.due_at.isoformat(),
        "approvals": approvals,
        "can_approve": event.status == RecheckEvent.STATUS_OPEN
        and (
            (is_task_user and "requester" not in approvals)
            or (is_mggt(username) and "inspector" not in approvals)
        ),
    }
    if detail:
        data["messages"] = [
            {
                "id": message.id,
                "author_login": message.author_login,
                "body": message.body,
                "created_at": message.created_at.isoformat(),
                "object_request_id": str(message.object_request_id) if message.object_request_id else None,
            }
            for message in event.messages.all()
        ]
        data["object_requests"] = [
            {
                "id": str(item.id),
                "source_layer": item.source_layer,
                "object_key": item.object_key,
                "root_id": item.root_id,
                "object_name": item.object_name,
                "status": item.status,
                "changes": [
                    {
                        "field_name": change.field_name,
                        "field_label": change.field_label,
                        "old_value": change.old_value,
                        "new_value": change.new_value,
                    }
                    for change in item.changes.all()
                ],
            }
            for item in event.object_requests.prefetch_related("changes").all()
        ]
    return data


@login_required
def landing(request):
    expire_due_events()
    username = (request.user.username or "").strip()
    events = list(accessible_events(username).select_related("source_approve"))
    selected_id = (request.GET.get("event") or "").strip()
    selected = next((item for item in events if str(item.id) == selected_id), None)
    if selected is None and events:
        selected = events[0]
    layer_order = []
    layer_groups = []
    page_title = "Проверка геоподосновы"
    if selected:
        task_guids = [str(selected.task_guid)]
        work_counts = count_features_by_table(task_guids)
        topo_counts = count_topopassport_features_by_table(task_guids)
        layer_groups = build_layer_groups(work_counts)
        if topo_counts:
            layer_groups += build_topopassport_layer_groups(topo_counts)
        layer_order = build_map_layer_load_order(
            work_counts=work_counts,
            topo_counts=topo_counts,
            has_adjacent=False,
            include_reference=False,
        )
        page_title = resolve_task_survey_title(selected.task_guid, prefix="Согласование ЦГ")
    return render(
        request,
        "recheck/landing.html",
        {
            "events": events,
            "selected_event": selected,
            "layer_groups": layer_groups,
            "work_layer_styles": load_manifest(),
            "svg_index": load_svg_index(),
            "page_title": page_title,
            "config": {
                "selectedEventId": str(selected.id) if selected else None,
                "layerOrder": layer_order,
                "urls": {
                    "bootstrap": reverse("recheck:api_bootstrap"),
                    "mapLayer": reverse("recheck:api_map_layer"),
                    "lookupOptions": reverse("recheck:api_lookup_options"),
                    "objectRequests": reverse(
                        "recheck:api_create_object_request", args=[selected.id]
                    ) if selected else "",
                    "messages": reverse("recheck:api_post_message", args=[selected.id]) if selected else "",
                    "approve": reverse("recheck:api_approve", args=[selected.id]) if selected else "",
                },
            },
        },
    )


@login_required
@require_GET
def api_bootstrap(request):
    expire_due_events()
    username = (request.user.username or "").strip()
    events = list(accessible_events(username).prefetch_related("approvals"))
    selected_raw = request.GET.get("event")
    selected = next((item for item in events if str(item.id) == selected_raw), None)
    if selected is None and events:
        selected = events[0]
    if selected:
        selected = (
            accessible_events(username)
            .prefetch_related("approvals", "messages", "object_requests__changes")
            .get(pk=selected.pk)
        )
    return JsonResponse(
        {
            "ok": True,
            "events": [_serialize_event(item, username) for item in events],
            "selected": _serialize_event(selected, username, detail=True) if selected else None,
            "current_user": username,
            "is_mggt": is_mggt(username),
        }
    )


@login_required
@require_POST
def api_map_layer(request):
    payload = _payload(request)
    if payload is None:
        return _error("Некорректный JSON.")
    try:
        event_id = uuid.UUID(str(payload.get("event_id") or ""))
    except (TypeError, ValueError):
        return _error("Некорректный event_id.")
    event = _event_for_user(event_id, request.user.username)
    if event is None:
        return _error("Проверка не найдена или недоступна.", 404)
    layer = str(payload.get("layer") or "").strip()
    features, warning = resolve_map_layer_features(event.source_approve, layer)
    response = {"ok": True, "layer": layer, "features": features}
    if warning:
        response["warning"] = warning
    return JsonResponse(response)


@login_required
@require_POST
def api_lookup_options(request):
    payload = _payload(request)
    if payload is None:
        return _error("Некорректный JSON.")
    table = str(payload.get("table") or "").strip()
    key = str(payload.get("key") or "Code").strip() or "Code"
    value = str(payload.get("value") or "Name").strip() or "Name"
    if (table, key, value) not in allowed_cls_lookups():
        return _error("Справочник недоступен.")
    filters = payload.get("filters") or {}
    if not isinstance(filters, dict):
        return _error("filters должно быть объектом.")
    try:
        options = list_cls_lookup_options(
            {"schema": "cls", "table": table, "key": key, "value": value},
            filters={str(column): raw for column, raw in filters.items()},
        )
    except ValueError as exc:
        return _error(str(exc))
    return JsonResponse({"ok": True, "options": options})


@login_required
@require_POST
def api_create_object_request(request, event_id):
    event = _event_for_user(event_id, request.user.username)
    if event is None:
        return _error("Проверка не найдена или недоступна.", 404)
    payload = _payload(request)
    if payload is None:
        return _error("Некорректный JSON.")
    try:
        item = create_object_request(
            event=event,
            actor_login=request.user.username,
            payload=payload,
        )
    except IntegrityError:
        return _error("Для этого объекта запрос уже создан.", 409)
    except ValueError as exc:
        return _error(str(exc))
    return JsonResponse({"ok": True, "object_request_id": str(item.id)}, status=201)


@login_required
@require_POST
def api_post_message(request, event_id):
    event = _event_for_user(event_id, request.user.username)
    if event is None:
        return _error("Проверка не найдена или недоступна.", 404)
    expire_due_events()
    event.refresh_from_db()
    if event.status != RecheckEvent.STATUS_OPEN:
        return _error("Проверка закрыта. Новые сообщения недоступны.")
    payload = _payload(request)
    body = str((payload or {}).get("body") or "").strip()
    if not body:
        return _error("Введите текст сообщения.")
    message = RecheckMessage.objects.create(
        event=event,
        author_login=request.user.username,
        body=body,
    )
    return JsonResponse({"ok": True, "message_id": message.id}, status=201)


@login_required
@require_POST
def api_approve(request, event_id):
    event = _event_for_user(event_id, request.user.username)
    if event is None:
        return _error("Проверка не найдена или недоступна.", 404)
    try:
        event = approve_event(event=event, actor_login=request.user.username)
    except ValueError as exc:
        return _error(str(exc), 403)
    return JsonResponse({"ok": True, "status": event.status})

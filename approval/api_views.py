"""JSON API for approval events and chats."""

from __future__ import annotations

import json
import uuid
from pathlib import Path

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.http import FileResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect
from django.views.decorators.http import require_GET, require_POST

from .access import get_accessible_approve, get_accessible_approves, get_accessible_cases_queryset, get_owner_id_for_username, user_can_access_case
from .events_service import (
    add_case_participant,
    attach_geometry_to_message,
    change_case_owner,
    delete_approve_for_inspector,
    get_cases_queryset,
    parse_geometry_payload,
    record_case_approval,
    revoke_case_approval,
    serialize_approve_option,
    serialize_case_detail,
    serialize_case_summary,
    serialize_message,
    upsert_message_reaction,
    validate_attachment_file,
)
from .models import Case, CaseMessage, CaseMessageAttachment


def _json_error(message, *, status=400):
    return JsonResponse({"ok": False, "error": message}, status=status)


def _actor_context(request):
    username = (request.user.username or "").strip()
    owner_id = get_owner_id_for_username(username)
    if not owner_id and not username:
        return None, _json_error("Не найден OwnerLegalPersonId для пользователя.", status=403)
    return {"owner_id": owner_id, "username": username}, None


def _parse_json_body(request):
    if not request.body:
        return {}
    try:
        payload = json.loads(request.body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None
    return payload if isinstance(payload, dict) else None


def _case_or_error(case_id, *, owner_id=None, username=None):
    case = get_object_or_404(Case.objects.select_related("approve"), pk=case_id)
    if not user_can_access_case(case, owner_id, username=username):
        return None, _json_error("Событие не найдено или недоступно.", status=404)
    return case, None


def _serialize_case(case, *, request, actor):
    return serialize_case_summary(
        case,
        current_login=actor["username"],
        owner_id=actor["owner_id"],
    )


def _serialize_case_detail(case, *, request, actor):
    return serialize_case_detail(
        case,
        current_login=actor["username"],
        owner_id=actor["owner_id"],
        request=request,
    )


@login_required
@require_GET
def api_bootstrap(request):
    actor, error = _actor_context(request)
    if error:
        return error

    owner_id = actor["owner_id"]
    username = actor["username"]

    approves = list(get_accessible_approves(owner_id, username=username))
    approve_options = [serialize_approve_option(item, username=username) for item in approves]

    selected_approve_id = request.GET.get("approve_id") or request.GET.get("approve")
    selected = None
    if selected_approve_id:
        selected = get_accessible_approve(selected_approve_id, owner_id, username=username)
    if selected is None and approves:
        selected = approves[0]

    cases_payload = []
    primary_case_id = None
    if selected is not None:
        accessible_case_ids = set(
            get_accessible_cases_queryset(owner_id, selected.id, username=username).values_list("id", flat=True)
        )
        for case in get_cases_queryset(selected.id):
            if case.id not in accessible_case_ids:
                continue
            cases_payload.append(
                serialize_case_summary(
                    case,
                    current_login=username,
                    owner_id=owner_id,
                )
            )
            if case.is_primary and primary_case_id is None:
                primary_case_id = str(case.id)

    return JsonResponse(
        {
            "ok": True,
            "approves": approve_options,
            "selected_approve_id": str(selected.id) if selected else None,
            "primary_case_id": primary_case_id,
            "cases": cases_payload,
            "current_user": username,
        }
    )


@login_required
@require_POST
def api_create_case(request):
    return _json_error(
        "Создание событий через веб-интерфейс отключено. События передаются из QGIS.",
        status=410,
    )


@login_required
@require_GET
def api_case_detail(request, case_id):
    actor, error = _actor_context(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    return JsonResponse(
        {
            "ok": True,
            "case": _serialize_case_detail(case, request=request, actor=actor),
        }
    )


@login_required
@require_POST
def api_post_message(request, case_id):
    actor, error = _actor_context(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    if case.approved:
        return _json_error("Событие уже согласовано. Новые сообщения недоступны.")

    body = ""
    uploads = []
    geometry_payloads = []
    parent_id_raw = None
    if request.content_type and "multipart/form-data" in request.content_type:
        body = (request.POST.get("body") or "").strip()
        uploads = list(request.FILES.getlist("files"))
        parent_id_raw = request.POST.get("parent_id")
        geometries_raw = (request.POST.get("geometries") or "").strip()
        geometry_raw = (request.POST.get("geometry") or "").strip()
        if geometries_raw:
            try:
                parsed = json.loads(geometries_raw)
            except json.JSONDecodeError:
                return _json_error("Некорректный JSON в поле geometries.")
            if not isinstance(parsed, list):
                return _json_error("Поле geometries должно быть массивом.")
            geometry_payloads = parsed
        elif geometry_raw:
            try:
                geometry_payloads = [json.loads(geometry_raw)]
            except json.JSONDecodeError:
                return _json_error("Некорректный JSON в поле geometry.")
    else:
        payload = _parse_json_body(request)
        if payload is None:
            return _json_error("Некорректный JSON.")
        body = (payload.get("body") or "").strip()
        parent_id_raw = payload.get("parent_id")
        if payload.get("geometries") is not None:
            if not isinstance(payload.get("geometries"), list):
                return _json_error("Поле geometries должно быть массивом.")
            geometry_payloads = payload.get("geometries") or []
        elif payload.get("geometry") is not None:
            geometry_payloads = [payload.get("geometry")]

    for geometry_payload in geometry_payloads:
        try:
            parse_geometry_payload(geometry_payload)
        except ValueError as exc:
            return _json_error(str(exc))

    parent = None
    if parent_id_raw not in (None, ""):
        try:
            parent_id = int(parent_id_raw)
        except (TypeError, ValueError):
            return _json_error("Некорректный parent_id.")
        parent = CaseMessage.objects.filter(pk=parent_id, case=case).first()
        if parent is None:
            return _json_error("Сообщение для ответа не найдено в этом событии.")

    if not body and not uploads and not geometry_payloads:
        return _json_error("Введите текст сообщения, прикрепите файл или добавьте геометрию.")

    message = CaseMessage.objects.create(
        case=case,
        parent=parent,
        author_login=actor["username"],
        author_role="",
        body=body or ("(геометрия)" if geometry_payloads else "(вложение)"),
    )

    for geometry_payload in geometry_payloads:
        attach_geometry_to_message(
            case=case,
            message=message,
            geometry_payload=geometry_payload,
            owner_id=actor["owner_id"],
        )

    storage_dir = Path(settings.MEDIA_ROOT) / "approval" / "attachments" / str(case.id)
    storage_dir.mkdir(parents=True, exist_ok=True)

    for uploaded in uploads:
        try:
            original_name, _suffix = validate_attachment_file(uploaded)
        except ValueError as exc:
            return _json_error(str(exc))

        stored_name = f"{uuid.uuid4().hex}_{original_name}"
        target = storage_dir / stored_name
        with target.open("wb") as handle:
            for chunk in uploaded.chunks():
                handle.write(chunk)

        CaseMessageAttachment.objects.create(
            message=message,
            stored_name=stored_name,
            original_name=original_name,
            content_type=getattr(uploaded, "content_type", "") or "application/octet-stream",
            size_bytes=target.stat().st_size,
        )

    message = CaseMessage.objects.select_related("parent").prefetch_related(
        "attachments",
        "geometries",
        "reactions",
    ).get(pk=message.pk)

    return JsonResponse(
        {
            "ok": True,
            "message": serialize_message(message, current_login=actor["username"], request=request),
            "case": _serialize_case(case, request=request, actor=actor),
        }
    )


@login_required
@require_POST
def api_approve_case(request, case_id):
    actor, error = _actor_context(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    if case.approved:
        return JsonResponse(
            {
                "ok": True,
                "case": _serialize_case(case, request=request, actor=actor),
            }
        )

    try:
        case = record_case_approval(
            case=case,
            owner_id=actor["owner_id"],
            username=actor["username"],
        )
    except ValueError as exc:
        return _json_error(str(exc))

    return JsonResponse(
        {
            "ok": True,
            "case": _serialize_case(case, request=request, actor=actor),
        }
    )


@login_required
@require_POST
def api_revoke_case(request, case_id):
    actor, error = _actor_context(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    try:
        case = revoke_case_approval(
            case=case,
            owner_id=actor["owner_id"],
            username=actor["username"],
        )
    except ValueError as exc:
        return _json_error(str(exc))

    return JsonResponse(
        {
            "ok": True,
            "case": _serialize_case(case, request=request, actor=actor),
        }
    )


@login_required
@require_POST
def api_message_reaction(request, message_id):
    actor, error = _actor_context(request)
    if error:
        return error

    message = get_object_or_404(
        CaseMessage.objects.select_related("case__approve", "parent").prefetch_related(
            "attachments",
            "geometries",
            "reactions",
        ),
        pk=message_id,
    )
    case = message.case
    if not user_can_access_case(case, actor["owner_id"], username=actor["username"]):
        return _json_error("Сообщение не найдено или недоступно.", status=404)

    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")
    kind = (payload.get("kind") or "").strip()

    try:
        upsert_message_reaction(
            message=message,
            username=actor["username"],
            kind=kind,
        )
    except ValueError as exc:
        return _json_error(str(exc))

    message = CaseMessage.objects.select_related("parent").prefetch_related(
        "attachments",
        "geometries",
        "reactions",
    ).get(pk=message.pk)

    return JsonResponse(
        {
            "ok": True,
            "message": serialize_message(message, current_login=actor["username"], request=request),
            "case": _serialize_case(case, request=request, actor=actor),
        }
    )


@login_required
@require_GET
def api_download_attachment(request, attachment_id):
    actor, error = _actor_context(request)
    if error:
        return error

    attachment = get_object_or_404(
        CaseMessageAttachment.objects.select_related("message__case__approve"),
        pk=attachment_id,
    )
    case = attachment.message.case
    if not user_can_access_case(case, actor["owner_id"], username=actor["username"]):
        return _json_error("Вложение не найдено или недоступно.", status=404)

    file_path = Path(settings.MEDIA_ROOT) / "approval" / "attachments" / str(case.id) / attachment.stored_name
    if not file_path.is_file():
        return _json_error("Файл не найден на сервере.", status=404)

    content_type = attachment.content_type or "application/octet-stream"
    force_download = request.GET.get("download") in ("1", "true", "yes")
    is_image = content_type.startswith("image/")
    as_attachment = force_download or not is_image

    response = FileResponse(
        file_path.open("rb"),
        as_attachment=as_attachment,
        filename=attachment.original_name,
    )
    response["Content-Type"] = content_type
    return response


@login_required
@require_POST
def api_change_case_owner(request, case_id):
    actor, error = _actor_context(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    try:
        case = change_case_owner(
            case=case,
            old_owner=payload.get("old_owner") or "",
            new_owner=payload.get("new_owner") or "",
            username=actor["username"],
        )
    except ValueError as exc:
        return _json_error(str(exc))

    return JsonResponse(
        {
            "ok": True,
            "case": _serialize_case(case, request=request, actor=actor),
        }
    )


@login_required
@require_POST
def api_add_case_participant(request, case_id):
    actor, error = _actor_context(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    try:
        case = add_case_participant(
            case=case,
            kind=payload.get("kind") or "",
            value=payload.get("value") or "",
            username=actor["username"],
        )
    except ValueError as exc:
        return _json_error(str(exc))

    return JsonResponse(
        {
            "ok": True,
            "case": _serialize_case(case, request=request, actor=actor),
        }
    )


@login_required
@require_POST
def delete_approve(request):
    approve_id = (request.POST.get("approve_id") or "").strip()
    if not approve_id:
        return redirect("home")

    try:
        delete_approve_for_inspector(approve_id=approve_id, username=request.user.username)
    except ValueError:
        pass

    return redirect("home")

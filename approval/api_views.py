"""JSON API for approval events and chats."""

from __future__ import annotations

import json
import uuid
from pathlib import Path

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.http import FileResponse, JsonResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET, require_POST

from .access import get_accessible_approve, get_accessible_approves, get_accessible_cases_queryset, get_owner_id_for_username, user_can_access_case
from .events_service import (
    ApproveAlreadyApprovedError,
    attach_geometry_to_message,
    create_case_with_geometry,
    get_cases_queryset,
    parse_geometry_payload,
    record_case_approval,
    serialize_approve_option,
    serialize_case_detail,
    serialize_case_summary,
    serialize_message,
    upsert_approve_from_qgis,
    validate_attachment_file,
)
from .models import Case, CaseMessage, CaseMessageAttachment
from .qgis_access import qgis_api_host_allowed


def _json_error(message, *, status=400):
    return JsonResponse({"ok": False, "error": message}, status=status)


def _owner_or_error(request):
    owner_id = get_owner_id_for_username(request.user.username)
    if not owner_id:
        return None, _json_error("Не найден OwnerLegalPersonId для пользователя.", status=403)
    return owner_id, None


def _parse_json_body(request):
    if not request.body:
        return {}
    try:
        payload = json.loads(request.body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None
    return payload if isinstance(payload, dict) else None


@csrf_exempt
@require_POST
def api_qgis_upsert_approve(request):
    if not qgis_api_host_allowed(request):
        return _json_error(
            "QGIS API доступен только по внутреннему адресу сервера (172.21.197.77).",
            status=403,
        )

    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    try:
        result = upsert_approve_from_qgis(payload)
    except ApproveAlreadyApprovedError as exc:
        return _json_error(str(exc), status=409)
    except ValueError as exc:
        return _json_error(str(exc))
    except Exception:
        return _json_error("Не удалось сохранить согласование.", status=500)

    return JsonResponse({"ok": True, **result})


def _case_or_error(case_id, owner_id):
    case = get_object_or_404(Case.objects.select_related("approve"), pk=case_id)
    if not user_can_access_case(case, owner_id):
        return None, _json_error("Событие не найдено или недоступно.", status=404)
    return case, None


@login_required
@require_GET
def api_bootstrap(request):
    owner_id, error = _owner_or_error(request)
    if error:
        return error

    approves = list(get_accessible_approves(owner_id))
    approve_options = [serialize_approve_option(item) for item in approves]

    selected_approve_id = request.GET.get("approve_id") or request.GET.get("approve")
    selected = None
    if selected_approve_id:
        selected = get_accessible_approve(selected_approve_id, owner_id)
    if selected is None and approves:
        selected = approves[0]

    cases_payload = []
    primary_case_id = None
    if selected is not None:
        accessible_case_ids = set(
            get_accessible_cases_queryset(owner_id, selected.id).values_list("id", flat=True)
        )
        for case in get_cases_queryset(selected.id):
            if case.id not in accessible_case_ids:
                continue
            cases_payload.append(
                serialize_case_summary(
                    case,
                    current_login=request.user.username,
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
            "current_user": request.user.username,
        }
    )


@login_required
@require_POST
def api_create_case(request):
    owner_id, error = _owner_or_error(request)
    if error:
        return error

    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    approve_id = payload.get("approve_id")
    approve = get_accessible_approve(approve_id, owner_id)
    if approve is None:
        return _json_error("Согласование не найдено или недоступно.", status=404)

    try:
        case = create_case_with_geometry(
            approve=approve,
            title=payload.get("title") or "",
            geometry_payload=payload.get("geometry"),
            created_by_login=request.user.username,
            owner_id=owner_id,
        )
    except ValueError as exc:
        return _json_error(str(exc))
    except Exception:
        return _json_error("Не удалось сохранить событие.", status=500)

    return JsonResponse(
        {
            "ok": True,
            "case": serialize_case_detail(
                case,
                current_login=request.user.username,
                owner_id=owner_id,
                request=request,
            ),
        }
    )


@login_required
@require_GET
def api_case_detail(request, case_id):
    owner_id, error = _owner_or_error(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id)
    if error:
        return error

    return JsonResponse(
        {
            "ok": True,
            "case": serialize_case_detail(
                case,
                current_login=request.user.username,
                owner_id=owner_id,
                request=request,
            ),
        }
    )


@login_required
@require_POST
def api_post_message(request, case_id):
    owner_id, error = _owner_or_error(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id)
    if error:
        return error

    if case.approved:
        return _json_error("Событие уже согласовано. Новые сообщения недоступны.")

    body = ""
    uploads = []
    geometry_payload = None
    if request.content_type and "multipart/form-data" in request.content_type:
        body = (request.POST.get("body") or "").strip()
        uploads = list(request.FILES.getlist("files"))
        geometry_raw = (request.POST.get("geometry") or "").strip()
        if geometry_raw:
            try:
                geometry_payload = json.loads(geometry_raw)
            except json.JSONDecodeError:
                return _json_error("Некорректный JSON в поле geometry.")
    else:
        payload = _parse_json_body(request)
        if payload is None:
            return _json_error("Некорректный JSON.")
        body = (payload.get("body") or "").strip()
        geometry_payload = payload.get("geometry")

    if geometry_payload is not None:
        try:
            parse_geometry_payload(geometry_payload)
        except ValueError as exc:
            return _json_error(str(exc))

    if not body and not uploads and geometry_payload is None:
        return _json_error("Введите текст сообщения, прикрепите файл или добавьте геометрию.")

    message = CaseMessage.objects.create(
        case=case,
        author_login=request.user.username,
        author_role="",
        body=body or ("(геометрия)" if geometry_payload is not None else "(вложение)"),
    )

    if geometry_payload is not None:
        attach_geometry_to_message(
            case=case,
            message=message,
            geometry_payload=geometry_payload,
            owner_id=owner_id,
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

    return JsonResponse(
        {
            "ok": True,
            "message": serialize_message(message, current_login=request.user.username, request=request),
            "case": serialize_case_summary(
                case,
                current_login=request.user.username,
                owner_id=owner_id,
            ),
        }
    )


@login_required
@require_POST
def api_approve_case(request, case_id):
    owner_id, error = _owner_or_error(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id)
    if error:
        return error

    if case.approved:
        return JsonResponse(
            {
                "ok": True,
                "case": serialize_case_summary(
                    case,
                    current_login=request.user.username,
                    owner_id=owner_id,
                ),
            }
        )

    try:
        case = record_case_approval(case=case, owner_id=owner_id)
    except ValueError as exc:
        return _json_error(str(exc))

    return JsonResponse(
        {
            "ok": True,
            "case": serialize_case_summary(
                case,
                current_login=request.user.username,
                owner_id=owner_id,
            ),
        }
    )


@login_required
@require_GET
def api_download_attachment(request, attachment_id):
    owner_id, error = _owner_or_error(request)
    if error:
        return error

    attachment = get_object_or_404(
        CaseMessageAttachment.objects.select_related("message__case__approve"),
        pk=attachment_id,
    )
    case = attachment.message.case
    if not user_can_access_case(case, owner_id):
        return _json_error("Вложение не найдено или недоступно.", status=404)

    file_path = Path(settings.MEDIA_ROOT) / "approval" / "attachments" / str(case.id) / attachment.stored_name
    if not file_path.is_file():
        return _json_error("Файл не найден на сервере.", status=404)

    response = FileResponse(file_path.open("rb"), as_attachment=True, filename=attachment.original_name)
    response["Content-Type"] = attachment.content_type or "application/octet-stream"
    return response

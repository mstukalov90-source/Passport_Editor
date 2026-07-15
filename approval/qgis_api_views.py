"""QGIS HTTP API: ingest, read and write approval data (host-only + login)."""

from __future__ import annotations

import json
import uuid
from pathlib import Path

from django.conf import settings
from django.db.models import Count
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET, require_http_methods, require_POST

from .access import (
    get_accessible_approve,
    get_accessible_approves,
    get_accessible_cases_queryset,
    get_owner_id_for_username,
    user_can_access_case,
)
from .events_service import (
    ApproveAlreadyApprovedError,
    ApproveUserConflictError,
    attach_geometry_to_message,
    build_geometries_feature_collection,
    get_cases_queryset,
    parse_geometry_payload,
    record_case_approval,
    revoke_case_approval,
    serialize_approve_qgis_summary,
    serialize_case_detail,
    serialize_case_summary,
    serialize_message,
    upsert_approve_from_qgis,
    validate_attachment_file,
)
from .models import ApprovalGeometry, Approve, Case, CaseMessage, CaseMessageAttachment
from .qgis_access import qgis_api_host_allowed


def _json_error(message, *, status=400):
    return JsonResponse({"ok": False, "error": message}, status=status)


def _parse_json_body(request):
    if not request.body:
        return {}
    try:
        payload = json.loads(request.body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None
    return payload if isinstance(payload, dict) else None


def _qgis_host_guard(request):
    if not qgis_api_host_allowed(request):
        return _json_error(
            "QGIS API доступен только по внутреннему адресу сервера (172.21.197.77).",
            status=403,
        )
    return None


def _qgis_username_from_request(request, *, payload=None):
    username = (request.GET.get("user") or "").strip()
    if username:
        return username
    if payload and isinstance(payload, dict):
        username = (payload.get("user") or "").strip()
        if username:
            return username
    if request.method in ("POST", "PUT", "PATCH"):
        username = (request.POST.get("user") or "").strip()
        if username:
            return username
    return ""


def _qgis_actor(request, *, payload=None):
    host_error = _qgis_host_guard(request)
    if host_error:
        return None, host_error

    username = _qgis_username_from_request(request, payload=payload)
    if not username:
        return None, _json_error("Укажите логин пользователя (параметр user).")

    owner_id = get_owner_id_for_username(username)
    return {"owner_id": owner_id, "username": username}, None


def _case_or_error(case_id, *, owner_id=None, username=None):
    case = get_object_or_404(Case.objects.select_related("approve"), pk=case_id)
    if not user_can_access_case(case, owner_id, username=username):
        return None, _json_error("Событие не найдено или недоступно.", status=404)
    return case, None


def _serialize_case(case, *, actor):
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


def _approve_detail_payload(approve, *, request, actor):
    accessible_case_ids = set(
        get_accessible_cases_queryset(
            actor["owner_id"],
            approve.id,
            username=actor["username"],
        ).values_list("id", flat=True)
    )
    cases_payload = []
    primary_case_id = None
    for case in get_cases_queryset(approve.id):
        if case.id not in accessible_case_ids:
            continue
        cases_payload.append(
            serialize_case_summary(
                case,
                current_login=actor["username"],
                owner_id=actor["owner_id"],
            )
        )
        if case.is_primary and primary_case_id is None:
            primary_case_id = str(case.id)

    return {
        "ok": True,
        "approve": serialize_approve_qgis_summary(approve),
        "primary_case_id": primary_case_id,
        "cases": cases_payload,
        "current_user": actor["username"],
    }


@csrf_exempt
@require_http_methods(["GET", "POST"])
def api_qgis_approves(request):
    """GET list by user; POST upsert (legacy ingest)."""
    if request.method == "GET":
        return api_qgis_list_approves(request)
    return api_qgis_upsert_approve(request)


@csrf_exempt
@require_POST
def api_qgis_upsert_approve(request):
    host_error = _qgis_host_guard(request)
    if host_error:
        return host_error

    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    try:
        result = upsert_approve_from_qgis(payload)
    except (ApproveAlreadyApprovedError, ApproveUserConflictError) as exc:
        return _json_error(str(exc), status=409)
    except ValueError as exc:
        return _json_error(str(exc))
    except Exception:
        return _json_error("Не удалось сохранить согласование.", status=500)

    return JsonResponse({"ok": True, **result})


@csrf_exempt
@require_GET
def api_qgis_list_approves(request):
    actor, error = _qgis_actor(request)
    if error:
        return error

    approves = (
        get_accessible_approves(actor["owner_id"], username=actor["username"])
        .annotate(cases_count=Count("cases", distinct=True))
    )
    return JsonResponse(
        {
            "ok": True,
            "approves": [serialize_approve_qgis_summary(item) for item in approves],
            "current_user": actor["username"],
        }
    )


@csrf_exempt
@require_GET
def api_qgis_approve_detail(request, approve_id):
    actor, error = _qgis_actor(request)
    if error:
        return error

    approve = get_accessible_approve(approve_id, actor["owner_id"], username=actor["username"])
    if approve is None:
        return _json_error("Согласование не найдено или недоступно.", status=404)

    approve = (
        Approve.objects.filter(pk=approve.id)
        .annotate(cases_count=Count("cases", distinct=True))
        .first()
    )
    return JsonResponse(_approve_detail_payload(approve, request=request, actor=actor))


@csrf_exempt
@require_GET
def api_qgis_approve_by_guid(request, incoming_guid):
    actor, error = _qgis_actor(request)
    if error:
        return error

    approve = (
        get_accessible_approves(actor["owner_id"], username=actor["username"])
        .filter(incoming_guid=incoming_guid)
        .annotate(cases_count=Count("cases", distinct=True))
        .first()
    )
    if approve is None:
        return _json_error("Согласование не найдено или недоступно.", status=404)

    return JsonResponse(_approve_detail_payload(approve, request=request, actor=actor))


@csrf_exempt
@require_GET
def api_qgis_case_detail(request, case_id):
    actor, error = _qgis_actor(request)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    return JsonResponse(
        {
            "ok": True,
            "case": _serialize_case_detail(case, request=request, actor=actor),
            "current_user": actor["username"],
        }
    )


@csrf_exempt
@require_GET
def api_qgis_approve_geometries(request, approve_id):
    actor, error = _qgis_actor(request)
    if error:
        return error

    approve = get_accessible_approve(approve_id, actor["owner_id"], username=actor["username"])
    if approve is None:
        return _json_error("Согласование не найдено или недоступно.", status=404)

    accessible_case_ids = list(
        get_accessible_cases_queryset(
            actor["owner_id"],
            approve.id,
            username=actor["username"],
        ).values_list("id", flat=True)
    )
    geometry_rows = (
        ApprovalGeometry.objects.filter(approve=approve, case_id__in=accessible_case_ids)
        .select_related("case")
        .order_by("id")
    )
    return JsonResponse(
        {
            "ok": True,
            "approve_id": str(approve.id),
            "type": "FeatureCollection",
            "features": build_geometries_feature_collection(geometry_rows)["features"],
            "current_user": actor["username"],
        }
    )


def _extract_message_inputs(request):
    body = ""
    uploads = []
    geometry_payloads = []
    parent_id_raw = None
    payload = None

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
                return None, _json_error("Некорректный JSON в поле geometries.")
            if not isinstance(parsed, list):
                return None, _json_error("Поле geometries должно быть массивом.")
            geometry_payloads = parsed
        elif geometry_raw:
            try:
                geometry_payloads = [json.loads(geometry_raw)]
            except json.JSONDecodeError:
                return None, _json_error("Некорректный JSON в поле geometry.")
        payload = {"user": request.POST.get("user")}
    else:
        payload = _parse_json_body(request)
        if payload is None:
            return None, _json_error("Некорректный JSON.")
        body = (payload.get("body") or "").strip()
        parent_id_raw = payload.get("parent_id")
        if payload.get("geometries") is not None:
            if not isinstance(payload.get("geometries"), list):
                return None, _json_error("Поле geometries должно быть массивом.")
            geometry_payloads = payload.get("geometries") or []
        elif payload.get("geometry") is not None:
            geometry_payloads = [payload.get("geometry")]

    return (
        {
            "body": body,
            "uploads": uploads,
            "geometry_payloads": geometry_payloads,
            "parent_id_raw": parent_id_raw,
            "payload": payload or {},
        },
        None,
    )


@csrf_exempt
@require_POST
def api_qgis_post_message(request, case_id):
    extracted, error = _extract_message_inputs(request)
    if error:
        return error

    actor, error = _qgis_actor(request, payload=extracted["payload"])
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    if case.approved:
        return _json_error("Событие уже согласовано. Новые сообщения недоступны.")

    body = extracted["body"]
    uploads = extracted["uploads"]
    geometry_payloads = extracted["geometry_payloads"]
    parent_id_raw = extracted["parent_id_raw"]

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
            "case": _serialize_case(case, actor=actor),
            "current_user": actor["username"],
        }
    )


@csrf_exempt
@require_POST
def api_qgis_approve_case(request, case_id):
    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    actor, error = _qgis_actor(request, payload=payload)
    if error:
        return error

    case, error = _case_or_error(case_id, owner_id=actor["owner_id"], username=actor["username"])
    if error:
        return error

    if case.approved:
        return JsonResponse(
            {
                "ok": True,
                "case": _serialize_case(case, actor=actor),
                "current_user": actor["username"],
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
            "case": _serialize_case(case, actor=actor),
            "current_user": actor["username"],
        }
    )


@csrf_exempt
@require_POST
def api_qgis_revoke_case(request, case_id):
    payload = _parse_json_body(request)
    if payload is None:
        return _json_error("Некорректный JSON.")

    actor, error = _qgis_actor(request, payload=payload)
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
            "case": _serialize_case(case, actor=actor),
            "current_user": actor["username"],
        }
    )

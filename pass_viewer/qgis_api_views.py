"""QGIS HTTP API: read-only слои отрисованных заявок и досъёмов (host-only + login).

Как и approval QGIS API: без сессий и CSRF — host allowlist (общий
APPROVAL_QGIS_ALLOWED_HOSTS) + логин в параметре ``user``. Слои отдают всех
заявки/досъёмы без ограничений по владельцу, поэтому доступ только сотрудникам
(MGGT/SUP).
"""

from __future__ import annotations

import logging

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET

from approval.qgis_access import qgis_api_host_allowed
from pass_viewer.roles import resolve_user_scope, sees_all_approvals

from .qgis_layers import (
    build_recaps_layer_geojson,
    build_recaps_list,
    build_requests_layer_geojson,
    build_requests_list,
)
from .views import _normalize_source_label, _top_source_label

logger = logging.getLogger(__name__)


def _json_error(message, *, status=400):
    return JsonResponse({"ok": False, "error": message}, status=status)


def _qgis_staff_actor(request):
    """(actor, None) или (None, JsonResponse-ошибка): host + user + роль MGGT/SUP."""
    if not qgis_api_host_allowed(request):
        return None, _json_error(
            "QGIS API доступен только с разрешённого Host (домен или внутренний адрес сервера).",
            status=403,
        )

    username = (request.GET.get("user") or "").strip()
    if not username:
        return None, _json_error("Укажите логин пользователя (параметр user).")

    scope = resolve_user_scope(username)
    if not sees_all_approvals(scope):
        return None, _json_error(
            "Слои заявок и досъёмов доступны только сотрудникам (MGGT/SUP).",
            status=403,
        )
    return {"username": username}, None


def _digits_param(request, name, *, label):
    value = (request.GET.get(name) or "").strip()
    if value and not value.isdigit():
        return None, _json_error(f"{label} должен содержать только цифры.")
    return value or None, None


def _normalize_source_filter(value):
    """Нормализованная метка источника ('' = все) или None, если источник неизвестен."""
    source = str(value or "").strip().upper()
    if not source:
        return ""
    top_label = _top_source_label().upper()
    if source not in {"ДТ", "ОДХ", "ОЗН", "ОО", "TOP", top_label}:
        return None
    return _normalize_source_label(source)


def _layer_response(request, *, actor, collection):
    return JsonResponse({"ok": True, "current_user": actor["username"], **collection})


def _list_response(*, actor, key, items):
    return JsonResponse(
        {"ok": True, "current_user": actor["username"], "count": len(items), key: items}
    )


@csrf_exempt
@require_GET
def api_qgis_requests_layer(request):
    """GeoJSON-слой отрисованных заявок (ДТ/ОДХ/ОЗН/ТОП)."""
    actor, error = _qgis_staff_actor(request)
    if error:
        return error

    request_id, error = _digits_param(request, "request_id", label="Номер заявки (request_id)")
    if error:
        return error

    source = _normalize_source_filter(request.GET.get("source"))
    if source is None:
        return _json_error(
            "Неизвестный источник (source). Доступны: ДТ, ОДХ, ОЗН, "
            f"{_top_source_label()}."
        )

    try:
        collection = build_requests_layer_geojson(
            request_id=request_id,
            source=source or None,
        )
    except Exception:
        logger.exception("api_qgis_requests_layer failed")
        return _json_error("Не удалось получить слой заявок.", status=500)

    return _layer_response(request, actor=actor, collection=collection)


@csrf_exempt
@require_GET
def api_qgis_recaps_layer(request):
    """GeoJSON-слой досъёмов (recaps)."""
    actor, error = _qgis_staff_actor(request)
    if error:
        return error

    request_id, error = _digits_param(request, "request_id", label="Номер заявки (request_id)")
    if error:
        return error
    recap_id, error = _digits_param(request, "recap_id", label="Номер досъёма (recap_id)")
    if error:
        return error

    try:
        collection = build_recaps_layer_geojson(
            request_id=request_id,
            recap_id=recap_id,
        )
    except Exception:
        logger.exception("api_qgis_recaps_layer failed")
        return _json_error("Не удалось получить слой досъёмов.", status=500)

    return _layer_response(request, actor=actor, collection=collection)


@csrf_exempt
@require_GET
def api_qgis_requests_list(request):
    """Список всех отрисованных заявок (без геометрии)."""
    actor, error = _qgis_staff_actor(request)
    if error:
        return error

    request_id, error = _digits_param(request, "request_id", label="Номер заявки (request_id)")
    if error:
        return error

    source = _normalize_source_filter(request.GET.get("source"))
    if source is None:
        return _json_error(
            "Неизвестный источник (source). Доступны: ДТ, ОДХ, ОЗН, "
            f"{_top_source_label()}."
        )

    try:
        items = build_requests_list(
            request_id=request_id,
            source=source or None,
        )
    except Exception:
        logger.exception("api_qgis_requests_list failed")
        return _json_error("Не удалось получить список заявок.", status=500)

    return _list_response(actor=actor, key="requests", items=items)


@csrf_exempt
@require_GET
def api_qgis_recaps_list(request):
    """Список всех досъёмов (без геометрии)."""
    actor, error = _qgis_staff_actor(request)
    if error:
        return error

    request_id, error = _digits_param(request, "request_id", label="Номер заявки (request_id)")
    if error:
        return error
    recap_id, error = _digits_param(request, "recap_id", label="Номер досъёма (recap_id)")
    if error:
        return error

    try:
        items = build_recaps_list(
            request_id=request_id,
            recap_id=recap_id,
        )
    except Exception:
        logger.exception("api_qgis_recaps_list failed")
        return _json_error("Не удалось получить список досъёмов.", status=500)

    return _list_response(actor=actor, key="recaps", items=items)

import json

from django.http import JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET, require_POST

from approval.qgis_access import qgis_api_host_allowed

from .models import ObjectChangeRequest


def _guard(request):
    if qgis_api_host_allowed(request):
        return None
    return JsonResponse({"ok": False, "error": "Host не разрешён для QGIS API."}, status=403)


@csrf_exempt
@require_GET
def list_changes(request):
    error = _guard(request)
    if error:
        return error
    queryset = ObjectChangeRequest.objects.select_related("event").prefetch_related("changes")
    status = (request.GET.get("status") or "pending").strip()
    if status:
        queryset = queryset.filter(status=status)
    task_guid = (request.GET.get("task_guid") or "").strip()
    if task_guid:
        queryset = queryset.filter(event__task_guid=task_guid)
    rows = []
    for item in queryset:
        geometry = None
        if item.geom:
            import json

            geometry = json.loads(item.geom.geojson)
        for change in item.changes.all():
            rows.append(
                {
                    "request_id": str(item.id),
                    "task_guid": str(item.event.task_guid),
                    "source_layer": item.source_layer,
                    "object_key": item.object_key,
                    "root_id": item.root_id,
                    "object_name": item.object_name,
                    "field_name": change.field_name,
                    "field_label": change.field_label,
                    "old_value": change.old_value,
                    "new_value": change.new_value,
                    "status": item.status,
                    "requested_by": item.requested_by_login,
                    "created_at": item.created_at.isoformat(),
                    "geometry": geometry,
                }
            )
    return JsonResponse({"ok": True, "count": len(rows), "rows": rows})


@csrf_exempt
@require_POST
def complete_request(request, request_id):
    error = _guard(request)
    if error:
        return error
    item = ObjectChangeRequest.objects.filter(pk=request_id).first()
    if item is None:
        return JsonResponse({"ok": False, "error": "Запрос не найден."}, status=404)
    payload = {}
    if request.content_type and "application/json" in request.content_type:
        try:
            payload = json.loads(request.body or "{}")
        except (UnicodeDecodeError, json.JSONDecodeError):
            return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)
        if not isinstance(payload, dict):
            return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)
    operator = (
        request.POST.get("user")
        or payload.get("user")
        or request.GET.get("user")
        or ""
    ).strip()
    if not operator:
        return JsonResponse({"ok": False, "error": "Укажите user."}, status=400)
    item.status = ObjectChangeRequest.STATUS_APPLIED
    item.processed_at = timezone.now()
    item.processed_by_login = operator
    item.save(update_fields=["status", "processed_at", "processed_by_login"])
    return JsonResponse({"ok": True, "request_id": str(item.id), "status": item.status})

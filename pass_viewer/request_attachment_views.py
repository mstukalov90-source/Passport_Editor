"""HTTP endpoints for ods status, BidApprove comments, and request file attachments."""

from __future__ import annotations

import uuid
from pathlib import Path

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.http import FileResponse, Http404, JsonResponse
from django.urls import reverse
from django.views.decorators.http import require_GET, require_http_methods, require_POST

from pass_viewer.models import ExternalUser, RequestAttachment
from pass_viewer.request_side import (
    lookup_bidapprove_comments,
    normalize_brid,
    resolve_editor_ods_status,
)

ALLOWED_EXT = {".pdf", ".doc", ".docx"}
ALLOWED_CT = {
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/octet-stream",
}
MAX_BYTES = 20 * 1024 * 1024


def _brid_from_request(request) -> str:
    return normalize_brid(request.GET.get("request_id") or request.POST.get("request_id") or "")


def _serialize_attachment(item: RequestAttachment) -> dict:
    return {
        "id": item.id,
        "name": item.original_name,
        "size_bytes": item.size_bytes,
        "size": _human_size(item.size_bytes),
        "download_url": reverse("download_request_attachment", args=[item.id]),
        "delete_url": reverse("delete_request_attachment", args=[item.id]),
    }


def _human_size(n: int) -> str:
    if n < 1024:
        return f"{n} Б"
    if n < 1024 * 1024:
        return f"{n / 1024:.0f} КБ"
    return f"{n / (1024 * 1024):.1f} МБ".replace(".", ",")


def _owner_id_for_request(request) -> str:
    username = str(getattr(request.user, "username", "") or "")
    if not username:
        return ""
    row = ExternalUser.objects.filter(login=username).only("owner_legal_person_id").first()
    return str(row.owner_legal_person_id or "").strip() if row else ""


@login_required
@require_GET
def request_ods_status(request):
    brid = _brid_from_request(request)
    payload = resolve_editor_ods_status(
        brid,
        owner_id=_owner_id_for_request(request),
        created_at=request.GET.get("created_at"),
    )
    return JsonResponse({"ok": True, **payload})


@login_required
@require_GET
def request_bid_comments(request):
    brid = _brid_from_request(request)
    owner_id = _owner_id_for_request(request)
    comments = lookup_bidapprove_comments(brid, owner_id=owner_id) if brid else []
    return JsonResponse({"ok": True, "comments": comments})


@login_required
@require_GET
def list_request_attachments(request):
    brid = _brid_from_request(request)
    if not brid:
        return JsonResponse({"ok": True, "files": []})
    files = [_serialize_attachment(item) for item in RequestAttachment.objects.filter(brid=brid)]
    return JsonResponse({"ok": True, "files": files})


@login_required
@require_POST
def upload_request_attachment(request):
    brid = normalize_brid(request.POST.get("request_id") or "")
    if not brid:
        return JsonResponse({"ok": False, "error": "Нет номера заявки."}, status=400)
    uploaded = request.FILES.get("file")
    if not uploaded:
        return JsonResponse({"ok": False, "error": "Выберите файл."}, status=400)
    name = Path(uploaded.name or "").name
    ext = Path(name).suffix.lower()
    if ext not in ALLOWED_EXT:
        return JsonResponse({"ok": False, "error": "Допустимы только файлы PDF, DOC и DOCX."}, status=400)
    if uploaded.size > MAX_BYTES:
        return JsonResponse({"ok": False, "error": "Файл больше 20 МБ."}, status=400)
    content_type = (uploaded.content_type or "").split(";")[0].strip().lower()
    if content_type and content_type not in ALLOWED_CT:
        return JsonResponse({"ok": False, "error": "Недопустимый тип файла."}, status=400)
    stored_name = f"{uuid.uuid4().hex}{ext}"
    dest_dir = Path(settings.MEDIA_ROOT) / "request_attachments" / brid
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest_path = dest_dir / stored_name
    with dest_path.open("wb") as out:
        for chunk in uploaded.chunks():
            out.write(chunk)
    item = RequestAttachment.objects.create(
        brid=brid,
        original_name=name,
        stored_name=stored_name,
        content_type=content_type or "",
        size_bytes=int(uploaded.size or dest_path.stat().st_size),
        uploaded_by=str(getattr(request.user, "username", "") or ""),
    )
    return JsonResponse({"ok": True, "file": _serialize_attachment(item)})


@login_required
@require_GET
def download_request_attachment(request, attachment_id: int):
    try:
        item = RequestAttachment.objects.get(pk=attachment_id)
    except RequestAttachment.DoesNotExist:
        raise Http404("Файл не найден.")
    path = Path(settings.MEDIA_ROOT) / "request_attachments" / item.brid / item.stored_name
    if not path.is_file():
        raise Http404("Файл не найден на диске.")
    return FileResponse(path.open("rb"), as_attachment=True, filename=item.original_name)


@login_required
@require_http_methods(["POST", "DELETE"])
def delete_request_attachment(request, attachment_id: int):
    try:
        item = RequestAttachment.objects.get(pk=attachment_id)
    except RequestAttachment.DoesNotExist:
        return JsonResponse({"ok": False, "error": "Файл не найден."}, status=404)
    path = Path(settings.MEDIA_ROOT) / "request_attachments" / item.brid / item.stored_name
    try:
        if path.is_file():
            path.unlink()
    except OSError:
        pass
    item.delete()
    return JsonResponse({"ok": True})

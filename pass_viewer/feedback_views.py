"""Модальная форма обратной связи и страница просмотра обращений для МГГТ."""

import logging
import uuid
from pathlib import Path

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.http import (
    FileResponse,
    Http404,
    HttpResponseForbidden,
    HttpResponseRedirect,
    JsonResponse,
)
from django.shortcuts import get_object_or_404, render
from django.urls import reverse
from django.views.decorators.http import require_GET, require_POST

from .models import ExternalUser, FeedbackAttachment, FeedbackMessage
from .roles import ROLE_MGGT, resolve_user_scope

logger = logging.getLogger(__name__)

ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".pdf", ".doc", ".docx"}
ALLOWED_CT = {
    "image/jpeg",
    "image/png",
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/octet-stream",
}
MAX_BYTES = 10 * 1024 * 1024
MAX_FILES = 10
MAX_BODY_LENGTH = 5000

_VALID_STATUSES = {FeedbackMessage.STATUS_NEW, FeedbackMessage.STATUS_PROCESSED}


def _mggt_scope(request):
    scope = resolve_user_scope(request.user.username)
    return scope if scope.role == ROLE_MGGT else None


def _author_name(request) -> str:
    username = str(getattr(request.user, "username", "") or "")
    row = ExternalUser.objects.filter(login=username).only("display_name").first()
    if row and row.display_name.strip():
        return row.display_name.strip()
    full_name = str(getattr(request.user, "get_full_name", lambda: "")() or "").strip()
    return full_name or username


def _attachment_dir(message_id: int) -> Path:
    return Path(settings.MEDIA_ROOT) / "feedback" / str(message_id)


@login_required
@require_POST
def feedback_submit(request):
    """Приём обращения из модалки обратной связи: текст + вложения."""
    body = (request.POST.get("body") or "").strip()
    if not body:
        return JsonResponse({"ok": False, "error": "Введите текст сообщения."}, status=400)
    if len(body) > MAX_BODY_LENGTH:
        return JsonResponse(
            {"ok": False, "error": f"Текст не должен превышать {MAX_BODY_LENGTH} символов."},
            status=400,
        )

    files = request.FILES.getlist("files")
    if len(files) > MAX_FILES:
        return JsonResponse(
            {"ok": False, "error": f"Можно прикрепить не более {MAX_FILES} файлов."},
            status=400,
        )
    for uploaded in files:
        name = Path(uploaded.name or "").name
        ext = Path(name).suffix.lower()
        if ext not in ALLOWED_EXT:
            return JsonResponse(
                {"ok": False, "error": "Допустимы только файлы JPG, PNG, PDF, DOC и DOCX."},
                status=400,
            )
        if uploaded.size > MAX_BYTES:
            return JsonResponse(
                {"ok": False, "error": f"Файл «{name}» больше 10 МБ."}, status=400
            )
        content_type = (uploaded.content_type or "").split(";")[0].strip().lower()
        if content_type and content_type not in ALLOWED_CT:
            return JsonResponse(
                {"ok": False, "error": f"Недопустимый тип файла «{name}»."}, status=400
            )

    username = str(getattr(request.user, "username", "") or "")
    message = FeedbackMessage.objects.create(
        author_login=username,
        author_name=_author_name(request),
        body=body,
    )

    dest_dir = _attachment_dir(message.id)
    dest_dir.mkdir(parents=True, exist_ok=True)
    for uploaded in files:
        name = Path(uploaded.name or "").name
        ext = Path(name).suffix.lower()
        stored_name = f"{uuid.uuid4().hex}{ext}"
        dest_path = dest_dir / stored_name
        with dest_path.open("wb") as out:
            for chunk in uploaded.chunks():
                out.write(chunk)
        content_type = (uploaded.content_type or "").split(";")[0].strip().lower()
        FeedbackAttachment.objects.create(
            feedback=message,
            original_name=name,
            stored_name=stored_name,
            content_type=content_type or "",
            size_bytes=int(uploaded.size or dest_path.stat().st_size),
        )

    logger.info("Новое обращение обратной связи: %s (вложений: %d)", username, len(files))
    return JsonResponse({"ok": True})


def _filtered_messages(request):
    status = request.GET.get("status", "")
    queryset = FeedbackMessage.objects.prefetch_related("attachments")
    if status in _VALID_STATUSES:
        queryset = queryset.filter(status=status)
    return queryset, status


def _list_url(filter_status):
    url = reverse("feedback_list")
    if filter_status in _VALID_STATUSES:
        url = f"{url}?status={filter_status}"
    return url


@login_required
@require_GET
def feedback_list(request):
    """Список обращений пользователей для сотрудников МГГТ."""
    scope = _mggt_scope(request)
    if scope is None:
        return HttpResponseForbidden("Доступ разрешён только сотрудникам МГГТ.")
    queryset, status = _filtered_messages(request)
    return render(
        request,
        "pass_viewer/feedback_list.html",
        {
            "items": queryset,
            "status_filter": status,
            "new_count": FeedbackMessage.objects.filter(
                status=FeedbackMessage.STATUS_NEW
            ).count(),
            "user_role": scope.role,
        },
    )


@login_required
@require_POST
def feedback_set_status(request, pk):
    """Пометить обращение обработанным или вернуть в новые."""
    if _mggt_scope(request) is None:
        return HttpResponseForbidden("Доступ разрешён только сотрудникам МГГТ.")
    new_status = request.POST.get("status", "")
    if new_status not in _VALID_STATUSES:
        return HttpResponseForbidden("Недопустимый статус обращения.")
    item = get_object_or_404(FeedbackMessage, pk=pk)
    item.status = new_status
    item.save(update_fields=["status"])
    return HttpResponseRedirect(_list_url(request.POST.get("filter_status", "")))


@login_required
@require_GET
def feedback_attachment_download(request, attachment_id: int):
    """Скачивание вложения обращения (только для сотрудников МГГТ)."""
    if _mggt_scope(request) is None:
        return HttpResponseForbidden("Доступ разрешён только сотрудникам МГГТ.")
    try:
        item = FeedbackAttachment.objects.select_related("feedback").get(pk=attachment_id)
    except FeedbackAttachment.DoesNotExist:
        raise Http404("Файл не найден.") from None
    path = _attachment_dir(item.feedback_id) / item.stored_name
    if not path.is_file():
        raise Http404("Файл не найден на диске.")
    return FileResponse(path.open("rb"), as_attachment=True, filename=item.original_name)

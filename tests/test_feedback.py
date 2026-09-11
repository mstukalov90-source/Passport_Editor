"""Тесты модалки обратной связи и страницы обращений для МГГТ."""

from __future__ import annotations

from pathlib import Path

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from pass_viewer.models import ExternalUser, FeedbackAttachment, FeedbackMessage


def _login_as(client, login, role):
    ExternalUser.objects.create(login=login, password='pass', role=role)
    client.post(reverse('login'), {'username': login, 'password': 'pass'})


@pytest.mark.django_db
def test_feedback_urls_resolve() -> None:
    assert reverse("feedback_submit") == "/feedback/submit/"
    assert reverse("feedback_list") == "/feedback/"
    assert reverse("feedback_set_status", args=[1]) == "/feedback/1/status/"
    assert reverse("feedback_attachment_download", args=[2]) == "/feedback/attachments/2/download/"


@pytest.mark.django_db
def test_submit_anonymous_redirects_to_login(client) -> None:
    response = client.post(reverse("feedback_submit"), {"body": "Текст"})
    assert response.status_code == 302
    assert "/accounts/login/" in response.url


@pytest.mark.django_db
def test_submit_requires_body(client) -> None:
    _login_as(client, 'fb_body', role=ExternalUser.ROLE_BD)
    response = client.post(reverse("feedback_submit"), {"body": "   "})
    assert response.status_code == 400
    body = response.json()
    assert body["ok"] is False
    assert "Введите текст сообщения." in body["error"]
    assert FeedbackMessage.objects.count() == 0


@pytest.mark.django_db
def test_submit_rejects_disallowed_extension(client) -> None:
    _login_as(client, 'fb_ext', role=ExternalUser.ROLE_BD)
    txt = SimpleUploadedFile("note.txt", b"hello", content_type="text/plain")
    response = client.post(
        reverse("feedback_submit"),
        {"body": "Текст", "files": txt},
    )
    assert response.status_code == 400
    body = response.json()
    assert body["ok"] is False
    assert "JPG" in body["error"]
    assert FeedbackMessage.objects.count() == 0


@pytest.mark.django_db
def test_submit_creates_message_with_attachments(client, settings, tmp_path) -> None:
    settings.MEDIA_ROOT = tmp_path
    _login_as(client, 'fb_ok', role=ExternalUser.ROLE_BD)
    jpg = SimpleUploadedFile("shot.jpg", b"\xff\xd8\xff\xe0fake", content_type="image/jpeg")
    pdf = SimpleUploadedFile("doc.pdf", b"%PDF-1.4 fake", content_type="application/pdf")

    response = client.post(
        reverse("feedback_submit"),
        {"body": "  Не работает выгрузка  ", "files": [jpg, pdf]},
    )
    assert response.status_code == 200
    assert response.json() == {"ok": True}

    assert FeedbackMessage.objects.count() == 1
    message = FeedbackMessage.objects.get()
    assert message.body == "Не работает выгрузка"
    assert message.author_login == "fb_ok"
    assert message.status == FeedbackMessage.STATUS_NEW

    attachments = list(message.attachments.order_by("pk"))
    assert len(attachments) == 2
    assert {a.original_name for a in attachments} == {"shot.jpg", "doc.pdf"}
    for attachment in attachments:
        stored = Path(tmp_path) / "feedback" / str(message.pk) / attachment.stored_name
        assert stored.is_file()
        assert stored.stat().st_size == attachment.size_bytes


@pytest.mark.django_db
def test_list_anonymous_redirects_to_login(client) -> None:
    response = client.get(reverse("feedback_list"))
    assert response.status_code == 302
    assert "/accounts/login/" in response.url


@pytest.mark.django_db
def test_list_forbidden_for_non_mggt(client) -> None:
    _login_as(client, 'fb_bd', role=ExternalUser.ROLE_BD)
    assert client.get(reverse("feedback_list")).status_code == 403


@pytest.mark.django_db
def test_list_shows_items_and_filters_for_mggt(client) -> None:
    _login_as(client, 'fb_mggt', role=ExternalUser.ROLE_MGGT)
    FeedbackMessage.objects.create(
        author_login="fb_ok",
        author_name="Иванов И. И.",
        body="Не работает выгрузка",
    )
    FeedbackMessage.objects.create(
        author_login="fb_other",
        author_name="Петров П. П.",
        body="Спасибо за карту",
        status=FeedbackMessage.STATUS_PROCESSED,
    )

    response = client.get(reverse("feedback_list"))
    assert response.status_code == 200
    content = response.content.decode("utf-8")
    assert "Обращения пользователей" in content
    assert "Не работает выгрузка" in content
    assert "Новые (1)" in content

    response = client.get(reverse("feedback_list"), {"status": "new"})
    content = response.content.decode("utf-8")
    assert "Не работает выгрузка" in content
    assert "Спасибо за карту" not in content


@pytest.mark.django_db
def test_set_status_toggles_message_state(client) -> None:
    _login_as(client, 'fb_mggt_status', role=ExternalUser.ROLE_MGGT)
    message = FeedbackMessage.objects.create(
        author_login="fb_ok",
        author_name="",
        body="Текст",
    )
    response = client.post(
        reverse("feedback_set_status", args=[message.pk]),
        {"status": FeedbackMessage.STATUS_PROCESSED},
    )
    assert response.status_code == 302
    message.refresh_from_db()
    assert message.status == FeedbackMessage.STATUS_PROCESSED


@pytest.mark.django_db
def test_download_attachment_for_mggt_and_forbidden_for_bd(client, settings, tmp_path) -> None:
    settings.MEDIA_ROOT = tmp_path
    message = FeedbackMessage.objects.create(author_login="fb_ok", author_name="", body="Текст")
    stored_dir = Path(tmp_path) / "feedback" / str(message.pk)
    stored_dir.mkdir(parents=True)
    (stored_dir / "stored.jpg").write_bytes(b"\xff\xd8fake")
    attachment = FeedbackAttachment.objects.create(
        feedback=message,
        original_name="shot.jpg",
        stored_name="stored.jpg",
        content_type="image/jpeg",
        size_bytes=6,
    )

    _login_as(client, 'fb_mggt_dl', role=ExternalUser.ROLE_MGGT)
    response = client.get(reverse("feedback_attachment_download", args=[attachment.pk]))
    assert response.status_code == 200
    assert b"".join(response.streaming_content) == b"\xff\xd8fake"

    client.logout()
    _login_as(client, 'fb_bd_dl', role=ExternalUser.ROLE_BD)
    assert client.get(reverse("feedback_attachment_download", args=[attachment.pk])).status_code == 403


@pytest.mark.django_db
def test_header_has_feedback_button_and_modal(client) -> None:
    _login_as(client, 'fb_header', role=ExternalUser.ROLE_BD)
    content = client.get(reverse("personal_account")).content.decode("utf-8")
    assert 'id="feedback-open-btn"' in content
    assert 'id="feedback-modal"' in content
    assert "Обращения пользователей" not in content


@pytest.mark.django_db
def test_header_shows_feedback_list_link_for_mggt(client) -> None:
    _login_as(client, 'fb_header_mggt', role=ExternalUser.ROLE_MGGT)
    content = client.get(reverse("personal_account")).content.decode("utf-8")
    assert 'id="feedback-open-btn"' in content
    assert "Обращения пользователей" in content
    assert reverse("feedback_list") in content

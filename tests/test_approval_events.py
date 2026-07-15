"""Tests for approval events, chats, and unanimous approval."""

from __future__ import annotations

import json
import uuid
from unittest.mock import patch

import pytest
from approval.models import (
    ApprovalGeometry,
    Approve,
    Case,
    CaseApproval,
    CaseMessage,
    CaseMessageAttachment,
    CaseMessageReaction,
)
from approval.events_service import serialize_approve_option
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from pass_viewer.models import ExternalUser


@pytest.fixture
def owner_a():
    return ExternalUser.objects.create(login="owner_a", password="pass", owner_legal_person_id="OWNER_A")


@pytest.fixture
def owner_b_user():
    return ExternalUser.objects.create(login="owner_b", password="pass", owner_legal_person_id="OWNER_B")


@pytest.fixture
def inspector_user():
    return ExternalUser.objects.create(login="inspector_user", password="pass", owner_legal_person_id=None)


@pytest.fixture
def approve_with_primary_owner():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A", "OWNER_B"],
        user="inspector_user",
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["OWNER_A"]
    primary.save(update_fields=["owners", "updated_at"])
    return approve


def _login(client, username):
    client.post(reverse("login"), {"username": username, "password": "pass"})


def _primary_case(approve):
    return approve.cases.filter(is_primary=True).first()


def _event_case(*, approve, n_root="09811", owners=None, title="Событие"):
    return Case.objects.create(
        approve=approve,
        is_primary=False,
        title=title,
        owners=owners or ["OWNER_A", "OWNER_B"],
        n_root=n_root,
    )


@pytest.mark.django_db
def test_serialize_approve_option_uses_name_when_present():
    incoming_guid = uuid.uuid4()
    approve = Approve.objects.create(
        incoming_guid=incoming_guid,
        owners=["OWNER_A"],
        name="Согласование границ паспорта ДТ-10482",
    )
    payload = serialize_approve_option(approve)
    assert payload["label"] == "Согласование границ паспорта ДТ-10482"
    assert payload["name"] == "Согласование границ паспорта ДТ-10482"
    assert payload["status_label"] == "В работе"
    assert payload["can_delete"] is False


@pytest.mark.django_db
def test_serialize_approve_option_falls_back_to_guid_without_name():
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    approve = Approve.objects.create(
        incoming_guid=incoming_guid,
        owners=["OWNER_A"],
    )
    payload = serialize_approve_option(approve)
    assert payload["label"] == "Согласование 2e333940…"
    assert payload["name"] == ""
    assert payload["can_delete"] is False


@pytest.mark.django_db
def test_serialize_approve_option_can_delete_for_inspector():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A"],
        user="inspector_user",
        name="Согласование инспектора",
    )
    as_inspector = serialize_approve_option(approve, username="inspector_user")
    as_owner = serialize_approve_option(approve, username="owner_a")
    assert as_inspector["can_delete"] is True
    assert as_owner["can_delete"] is False


@pytest.mark.django_db
def test_bootstrap_returns_primary_case(client, owner_a, approve_with_primary_owner):
    _login(client, "owner_a")
    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve_with_primary_owner.id)})
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["primary_case_id"]
    assert len(payload["cases"]) >= 1


@pytest.mark.django_db
def test_create_case_endpoint_disabled(client, owner_a, approve_with_primary_owner):
    _login(client, "owner_a")
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.75], [37.61, 55.75], [37.61, 55.76], [37.6, 55.76], [37.6, 55.75]]],
    }
    response = client.post(
        reverse("approval:api_create_case"),
        data=json.dumps(
            {
                "approve_id": str(approve_with_primary_owner.id),
                "title": "Тестовое событие",
                "geometry": geometry,
            }
        ),
        content_type="application/json",
    )
    assert response.status_code == 410
    payload = response.json()
    assert payload["ok"] is False
    assert "QGIS" in payload["error"]


@pytest.mark.django_db
def test_post_message_with_png_attachment(client, owner_a, approve_with_primary_owner, settings, tmp_path):
    settings.MEDIA_ROOT = tmp_path
    _login(client, "owner_a")
    primary = _primary_case(approve_with_primary_owner)
    png_bytes = (
        b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
        b"\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01"
        b"\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
    )
    upload = SimpleUploadedFile("test.png", png_bytes, content_type="image/png")
    response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data={"body": "Смотрите вложение", "files": upload},
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    message = CaseMessage.objects.filter(case=primary).order_by("-created_at").first()
    assert message.attachments.count() == 1


@pytest.mark.django_db
def test_download_attachment_inline_for_images_attachment_for_download(
    client, owner_a, approve_with_primary_owner, settings, tmp_path
):
    settings.MEDIA_ROOT = tmp_path
    _login(client, "owner_a")
    primary = _primary_case(approve_with_primary_owner)
    png_bytes = (
        b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"
        b"\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01"
        b"\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
    )
    upload = SimpleUploadedFile("test.png", png_bytes, content_type="image/png")
    post_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data={"body": "Фото", "files": upload},
    )
    assert post_response.status_code == 200
    attachment = CaseMessageAttachment.objects.get(message__case=primary)

    inline_response = client.get(
        reverse("approval:api_download_attachment", kwargs={"attachment_id": attachment.id})
    )
    assert inline_response.status_code == 200
    assert "attachment" not in (inline_response.get("Content-Disposition") or "").lower()

    download_response = client.get(
        reverse("approval:api_download_attachment", kwargs={"attachment_id": attachment.id}),
        {"download": "1"},
    )
    assert download_response.status_code == 200
    assert "attachment" in (download_response.get("Content-Disposition") or "").lower()

    pdf_upload = SimpleUploadedFile("doc.pdf", b"%PDF-1.4 minimal", content_type="application/pdf")
    pdf_post = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data={"body": "PDF", "files": pdf_upload},
    )
    assert pdf_post.status_code == 200
    pdf_attachment = CaseMessageAttachment.objects.get(original_name="doc.pdf")
    pdf_response = client.get(
        reverse("approval:api_download_attachment", kwargs={"attachment_id": pdf_attachment.id})
    )
    assert pdf_response.status_code == 200
    assert "attachment" in (pdf_response.get("Content-Disposition") or "").lower()


@pytest.mark.django_db
def test_primary_approval_requires_owner_and_inspector(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    _login(client, "owner_a")
    primary = _primary_case(approve_with_primary_owner)

    response_owner = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_owner.status_code == 200
    primary.refresh_from_db()
    assert primary.approved is False
    assert CaseApproval.objects.filter(case=primary, owner_legal_person_id="OWNER_A").exists()

    _login(client, "inspector_user")
    response_inspector = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_inspector.status_code == 200
    primary.refresh_from_db()
    assert primary.approved is True
    assert primary.status == "согласовано"
    assert primary.closed_at is not None
    approve_with_primary_owner.refresh_from_db()
    assert approve_with_primary_owner.approved is True


@pytest.mark.django_db
def test_event_approval_requires_both_owners_and_inspector(
    client,
    owner_a,
    owner_b_user,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)

    _login(client, "owner_a")
    response_a = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": event.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_a.status_code == 200
    event.refresh_from_db()
    assert event.approved is False

    _login(client, "owner_b")
    response_b = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": event.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_b.status_code == 200
    event.refresh_from_db()
    assert event.approved is False

    _login(client, "inspector_user")
    response_inspector = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": event.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_inspector.status_code == 200
    event.refresh_from_db()
    assert event.approved is True
    approve_with_primary_owner.refresh_from_db()
    assert approve_with_primary_owner.approved is False


@pytest.mark.django_db
def test_closed_case_rejects_new_message(client, owner_a, approve_with_primary_owner):
    _login(client, "owner_a")
    primary = _primary_case(approve_with_primary_owner)
    primary.approved = True
    primary.status = "согласовано"
    primary.save(update_fields=["approved", "status"])

    response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Поздно"}),
        content_type="application/json",
    )
    assert response.status_code == 400


@pytest.mark.django_db
def test_post_message_with_geometry(client, owner_a, approve_with_primary_owner):
    _login(client, "owner_a")
    primary = _primary_case(approve_with_primary_owner)
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.75], [37.61, 55.75], [37.61, 55.76], [37.6, 55.76], [37.6, 55.75]]],
    }
    response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Зона замечания", "geometry": geometry}),
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["message"]["geometry"]["type"] == "Polygon"
    assert len(payload["message"]["geometries"]) == 1
    assert ApprovalGeometry.objects.filter(case=primary, message__isnull=False).exists()


@pytest.mark.django_db
def test_post_message_with_multiple_geometries(client, owner_a, approve_with_primary_owner):
    _login(client, "owner_a")
    primary = _primary_case(approve_with_primary_owner)
    geometries = [
        {
            "type": "Polygon",
            "coordinates": [[[37.6, 55.75], [37.61, 55.75], [37.61, 55.76], [37.6, 55.76], [37.6, 55.75]]],
        },
        {
            "type": "Point",
            "coordinates": [37.62, 55.77],
        },
    ]
    response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Несколько зон", "geometries": geometries}),
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert len(payload["message"]["geometries"]) == 2
    assert payload["message"]["geometry"]["type"] == "Polygon"
    assert ApprovalGeometry.objects.filter(message_id=payload["message"]["id"]).count() == 2


@pytest.mark.django_db
def test_post_message_reply_and_nested_reply(client, owner_a, owner_b_user, approve_with_primary_owner):
    primary = _primary_case(approve_with_primary_owner)
    primary.owners = ["OWNER_A", "OWNER_B"]
    primary.save(update_fields=["owners", "updated_at"])
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.75], [37.61, 55.75], [37.61, 55.76], [37.6, 55.76], [37.6, 55.75]]],
    }

    _login(client, "owner_a")
    root_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Корневое", "geometry": geometry}),
        content_type="application/json",
    )
    assert root_response.status_code == 200
    root = root_response.json()["message"]
    assert root["parent_id"] is None
    assert root["geometry"] is not None

    _login(client, "owner_b")
    reply_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Ответ", "parent_id": root["id"], "geometry": geometry}),
        content_type="application/json",
    )
    assert reply_response.status_code == 200
    reply = reply_response.json()["message"]
    assert reply["parent_id"] == root["id"]
    assert reply["reply_to_author"] == "owner_a"

    nested_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Ответ на ответ", "parent_id": reply["id"]}),
        content_type="application/json",
    )
    assert nested_response.status_code == 200
    nested = nested_response.json()["message"]
    assert nested["parent_id"] == reply["id"]
    assert nested["reply_to_author"] == "owner_b"


@pytest.mark.django_db
def test_post_message_rejects_reply_to_text_only(client, owner_a, owner_b_user, approve_with_primary_owner):
    primary = _primary_case(approve_with_primary_owner)
    primary.owners = ["OWNER_A", "OWNER_B"]
    primary.save(update_fields=["owners", "updated_at"])

    _login(client, "owner_a")
    root_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Только текст"}),
        content_type="application/json",
    )
    assert root_response.status_code == 200
    root = root_response.json()["message"]

    _login(client, "owner_b")
    reply_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Ответ", "parent_id": root["id"]}),
        content_type="application/json",
    )
    assert reply_response.status_code == 400
    assert "геометрией или файлом" in reply_response.json()["error"].lower()


@pytest.mark.django_db
def test_post_message_rejects_parent_from_other_case(client, owner_a, approve_with_primary_owner):
    primary = _primary_case(approve_with_primary_owner)
    other = _event_case(approve=approve_with_primary_owner, owners=["OWNER_A"])
    foreign_message = CaseMessage.objects.create(
        case=other,
        author_login="owner_a",
        body="Чужой кейс",
    )

    _login(client, "owner_a")
    response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Ответ", "parent_id": foreign_message.id}),
        content_type="application/json",
    )
    assert response.status_code == 400
    assert "не найдено" in response.json()["error"].lower()


@pytest.mark.django_db
def test_owner_in_approve_but_not_case_cannot_access(client, owner_a, approve_with_primary_owner):
    primary = _primary_case(approve_with_primary_owner)
    primary.owners = ["OWNER_B"]
    primary.save(update_fields=["owners"])

    _login(client, "owner_a")
    response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert response.status_code == 404


@pytest.mark.django_db
def test_foreign_owner_cannot_access_case(client, owner_a, approve_with_primary_owner):
    ExternalUser.objects.create(login="outsider", password="pass", owner_legal_person_id="OWNER_X")
    _login(client, "outsider")
    primary = _primary_case(approve_with_primary_owner)
    response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert response.status_code == 404


@pytest.mark.django_db
def test_landing_page_has_events_shell(client, owner_a, approve_with_primary_owner):
    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                _login(client, "owner_a")
                response = client.get(reverse("approval:landing"))
    assert response.status_code == 200
    content = response.content.decode("utf-8")
    assert "approval-approve-select" not in content
    assert "approval-create-event-btn" not in content
    assert "approval-chat-geometry-btn" in content
    assert "approval-chat-approve-btn" in content
    assert "approval-chat-confirm-dialog" in content
    assert "Прикрепить файл" in content
    assert "Досъём участка №142" not in content


@pytest.mark.django_db
def test_message_reaction_set_switch_and_toggle_off(
    client,
    owner_a,
    owner_b_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = CaseMessage.objects.create(
        case=event,
        author_login="owner_a",
        body="Нужна правка",
    )

    _login(client, "owner_b")
    url = reverse("approval:api_message_reaction", kwargs={"message_id": message.id})

    set_response = client.post(
        url,
        data=json.dumps({"kind": "in_progress"}),
        content_type="application/json",
    )
    assert set_response.status_code == 200
    payload = set_response.json()
    assert payload["ok"] is True
    assert payload["message"]["my_reaction"] == "in_progress"
    assert len(payload["message"]["reactions"]) == 1
    assert CaseMessageReaction.objects.filter(message=message, reactor_login="owner_b", kind="in_progress").exists()

    switch_response = client.post(
        url,
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert switch_response.status_code == 200
    switch_payload = switch_response.json()
    assert switch_payload["message"]["my_reaction"] == "done"
    assert CaseMessageReaction.objects.filter(message=message, reactor_login="owner_b").count() == 1
    assert CaseMessageReaction.objects.get(message=message, reactor_login="owner_b").kind == "done"

    toggle_response = client.post(
        url,
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert toggle_response.status_code == 200
    toggle_payload = toggle_response.json()
    assert toggle_payload["message"]["my_reaction"] is None
    assert toggle_payload["message"]["reactions"] == []
    assert not CaseMessageReaction.objects.filter(message=message).exists()


@pytest.mark.django_db
def test_message_reaction_rejects_own_message_and_closed_case(
    client,
    owner_a,
    owner_b_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    own_message = CaseMessage.objects.create(case=event, author_login="owner_a", body="Моё")
    other_message = CaseMessage.objects.create(case=event, author_login="owner_b", body="Чужое")

    _login(client, "owner_a")
    own_response = client.post(
        reverse("approval:api_message_reaction", kwargs={"message_id": own_message.id}),
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert own_response.status_code == 400

    event.approved = True
    event.status = "согласовано"
    event.save(update_fields=["approved", "status"])

    closed_response = client.post(
        reverse("approval:api_message_reaction", kwargs={"message_id": other_message.id}),
        data=json.dumps({"kind": "in_progress"}),
        content_type="application/json",
    )
    assert closed_response.status_code == 400


@pytest.mark.django_db
def test_revoke_case_approval_reopens_primary(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    primary = _primary_case(approve_with_primary_owner)

    _login(client, "owner_a")
    client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    _login(client, "inspector_user")
    client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    primary.refresh_from_db()
    assert primary.approved is True
    approve_with_primary_owner.refresh_from_db()
    assert approve_with_primary_owner.approved is True

    response = client.post(
        reverse("approval:api_revoke_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["case"]["approved"] is False
    assert payload["case"]["status"] == "в работе"
    assert payload["case"]["current_user_approved"] is False
    assert payload["case"]["approvals_done"] == 1

    primary.refresh_from_db()
    assert primary.approved is False
    assert primary.closed_at is None
    assert not CaseApproval.objects.filter(case=primary, approver_login="inspector_user").exists()
    assert CaseApproval.objects.filter(case=primary, owner_legal_person_id="OWNER_A").exists()
    approve_with_primary_owner.refresh_from_db()
    assert approve_with_primary_owner.approved is False

    reapprove = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert reapprove.status_code == 200
    primary.refresh_from_db()
    assert primary.approved is True
    approve_with_primary_owner.refresh_from_db()
    assert approve_with_primary_owner.approved is True

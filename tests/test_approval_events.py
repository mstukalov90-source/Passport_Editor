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
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
def test_serialize_approve_option_uses_name_when_present(_mock_poly):
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
    assert payload["source_label"] == ""
    assert payload["object_name"] == ""


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
def test_serialize_approve_option_falls_back_to_guid_without_name(_mock_poly):
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
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
def test_serialize_approve_option_can_delete_for_inspector(_mock_poly):
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
def test_serialize_approve_option_appends_object_name_and_source():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A"],
        name="Согласование заявки из графика паспортизации 24976",
    )
    payload = serialize_approve_option(
        approve,
        poly_meta={
            "source_label": "ДТ",
            "object_name": "Шаболовка ул. 23",
            "table": "YardPoly",
        },
    )
    assert payload["source_label"] == "ДТ"
    assert payload["object_name"] == "Шаболовка ул. 23"
    assert payload["label"] == (
        "Согласование заявки из графика паспортизации 24976 (Шаболовка ул. 23)"
    )


@pytest.mark.django_db
@patch("approval.events_service.batch_lookup_task_poly_meta")
def test_serialize_approve_options_uses_batch_meta(mock_batch):
    from approval.events_service import serialize_approve_options

    guid = uuid.uuid4()
    approve = Approve.objects.create(
        incoming_guid=guid,
        owners=["OWNER_A"],
        name="Согласование ОДХ",
    )
    mock_batch.return_value = {
        str(guid): {
            "source_label": "ОДХ",
            "object_name": "Дорога 1",
            "table": "OdhPoly",
        }
    }
    payloads = serialize_approve_options([approve], username="owner_a")
    assert len(payloads) == 1
    assert payloads[0]["source_label"] == "ОДХ"
    assert payloads[0]["label"] == "Согласование ОДХ (Дорога 1)"
    mock_batch.assert_called_once()


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
def test_bootstrap_includes_title_named_for_secondary(client, owner_a, approve_with_primary_owner):
    _event_case(
        approve=approve_with_primary_owner,
        n_root="930062866",
        title="Согласование заявок по паспортизации 24976 и паспорта 930062866",
    )
    _login(client, "owner_a")
    with patch(
        "approval.events_service.lookup_task_survey_fields",
        return_value=("Шаболовка ул. 23", "24976"),
    ):
        with patch(
            "approval.events_service.resolve_root_object_names",
            return_value={"930062866": "ул. Шаболовка, вл. 19А"},
        ):
            response = client.get(
                reverse("approval:api_bootstrap"),
                {"approve_id": str(approve_with_primary_owner.id)},
            )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    secondary = next(item for item in payload["cases"] if not item["is_primary"])
    primary = next(item for item in payload["cases"] if item["is_primary"])
    assert primary["title_named"] is None
    assert secondary["title"] == "Согласование заявок по паспортизации 24976 и паспорта 930062866"
    assert (
        secondary["title_named"]
        == "Согласование заявок по паспортизации Шаболовка ул. 23 и паспорта ул. Шаболовка, вл. 19А"
    )


@pytest.mark.django_db
def test_build_case_title_named_fallbacks():
    from approval.events_service import build_case_title_named, format_named_event_title

    approve = Approve.objects.create(incoming_guid=uuid.uuid4(), owners=["OWNER_A"])
    secondary = _event_case(
        approve=approve,
        n_root="930062866",
        title="Согласование заявок по паспортизации 24976 и паспорта 930062866",
    )
    primary = _primary_case(approve)

    assert build_case_title_named(primary, survey_name="X") is None
    assert (
        build_case_title_named(
            secondary,
            survey_name="Шаболовка ул. 23",
            root_names={"930062866": "ул. Шаболовка, вл. 19А"},
        )
        == "Согласование заявок по паспортизации Шаболовка ул. 23 и паспорта ул. Шаболовка, вл. 19А"
    )
    assert (
        build_case_title_named(secondary, survey_brid="24976", root_names={})
        == "Согласование заявок по паспортизации 24976 и паспорта 930062866"
    )
    assert format_named_event_title(task_label="A", passport_label="B") == (
        "Согласование заявок по паспортизации A и паспорта B"
    )


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
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                _login(client, "owner_a")
                response = client.get(reverse("approval:landing"))
    assert response.status_code == 200
    content = response.content.decode("utf-8")
    assert "approval-approve-select" not in content
    assert "approval-create-event-btn" not in content
    assert "approval-chat-geometry-btn" in content
    assert "approval-chat-approve-btn" in content
    assert "approval-chat-confirm-dialog" in content
    assert "approval-message-stats" in content
    assert "Прикрепить файл" in content
    assert "Досъём участка №142" not in content


@pytest.mark.django_db
def test_landing_passes_initial_case_id(client, owner_a, approve_with_primary_owner):
    primary = _primary_case(approve_with_primary_owner)
    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features_by_source", return_value={}):
                _login(client, "owner_a")
                response = client.get(
                    reverse("approval:landing"),
                    {"approve": str(approve_with_primary_owner.id), "case": str(primary.id)},
                )
    assert response.status_code == 200
    config = response.context["page_config"]
    assert config["initialCaseId"] == str(primary.id)
    assert config["selectedApproveId"] == str(approve_with_primary_owner.id)


def _message_with_attachment(case, *, author_login="owner_a", body="Нужна правка"):
    message = CaseMessage.objects.create(case=case, author_login=author_login, body=body)
    CaseMessageAttachment.objects.create(
        message=message,
        stored_name="file.png",
        original_name="file.png",
        content_type="image/png",
        size_bytes=10,
    )
    return message


@pytest.mark.django_db
def test_message_reaction_inspector_set_switch_and_toggle_off(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = _message_with_attachment(event)

    _login(client, "inspector_user")
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
    assert CaseMessageReaction.objects.filter(
        message=message, reactor_login="inspector_user", kind="in_progress"
    ).exists()

    switch_response = client.post(
        url,
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert switch_response.status_code == 200
    switch_payload = switch_response.json()
    assert switch_payload["message"]["my_reaction"] == "done"
    assert CaseMessageReaction.objects.filter(message=message, reactor_login="inspector_user").count() == 1
    assert CaseMessageReaction.objects.get(message=message, reactor_login="inspector_user").kind == "done"

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
def test_message_reaction_owner_cannot_set_inspector_kinds(
    client,
    owner_a,
    owner_b_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = _message_with_attachment(event, author_login="owner_a")

    _login(client, "owner_b")
    response = client.post(
        reverse("approval:api_message_reaction", kwargs={"message_id": message.id}),
        data=json.dumps({"kind": "in_progress"}),
        content_type="application/json",
    )
    assert response.status_code == 400
    assert not CaseMessageReaction.objects.filter(message=message).exists()


@pytest.mark.django_db
def test_message_reaction_inspector_rejects_text_only_and_own_message(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    text_message = CaseMessage.objects.create(case=event, author_login="owner_a", body="Только текст")
    own_message = _message_with_attachment(event, author_login="inspector_user", body="Моё")

    _login(client, "inspector_user")
    text_response = client.post(
        reverse("approval:api_message_reaction", kwargs={"message_id": text_message.id}),
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert text_response.status_code == 400

    own_response = client.post(
        reverse("approval:api_message_reaction", kwargs={"message_id": own_message.id}),
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert own_response.status_code == 400


@pytest.mark.django_db
def test_message_reaction_rejects_closed_case(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = _message_with_attachment(event, author_login="owner_a")
    event.approved = True
    event.status = "согласовано"
    event.save(update_fields=["approved", "status"])

    _login(client, "inspector_user")
    closed_response = client.post(
        reverse("approval:api_message_reaction", kwargs={"message_id": message.id}),
        data=json.dumps({"kind": "in_progress"}),
        content_type="application/json",
    )
    assert closed_response.status_code == 400


@pytest.mark.django_db
def test_message_reaction_owner_verdict_after_done(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = _message_with_attachment(event, author_login="owner_a")
    url = reverse("approval:api_message_reaction", kwargs={"message_id": message.id})

    _login(client, "owner_a")
    before_done = client.post(
        url,
        data=json.dumps({"kind": "accepted"}),
        content_type="application/json",
    )
    assert before_done.status_code == 400

    _login(client, "inspector_user")
    done_response = client.post(
        url,
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert done_response.status_code == 200

    _login(client, "owner_a")
    accepted_response = client.post(
        url,
        data=json.dumps({"kind": "accepted"}),
        content_type="application/json",
    )
    assert accepted_response.status_code == 200
    accepted_payload = accepted_response.json()
    assert accepted_payload["message"]["my_reaction"] == "accepted"
    assert CaseMessageReaction.objects.filter(
        message=message, reactor_login="owner_a", kind="accepted"
    ).exists()

    rejected_response = client.post(
        url,
        data=json.dumps({"kind": "rejected"}),
        content_type="application/json",
    )
    assert rejected_response.status_code == 200
    assert CaseMessageReaction.objects.get(message=message, reactor_login="owner_a").kind == "rejected"


@pytest.mark.django_db
def test_message_reaction_removing_done_clears_owner_verdicts(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = _message_with_attachment(event, author_login="owner_a")
    url = reverse("approval:api_message_reaction", kwargs={"message_id": message.id})

    _login(client, "inspector_user")
    assert (
        client.post(url, data=json.dumps({"kind": "done"}), content_type="application/json").status_code
        == 200
    )

    _login(client, "owner_a")
    assert (
        client.post(url, data=json.dumps({"kind": "accepted"}), content_type="application/json").status_code
        == 200
    )
    assert CaseMessageReaction.objects.filter(message=message, kind="accepted").exists()

    _login(client, "inspector_user")
    toggle_response = client.post(
        url,
        data=json.dumps({"kind": "done"}),
        content_type="application/json",
    )
    assert toggle_response.status_code == 200
    assert not CaseMessageReaction.objects.filter(message=message).exists()


@pytest.mark.django_db
def test_message_reaction_owner_can_verdict_own_message_with_done(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    message = _message_with_attachment(event, author_login="owner_a")
    url = reverse("approval:api_message_reaction", kwargs={"message_id": message.id})

    _login(client, "inspector_user")
    assert (
        client.post(url, data=json.dumps({"kind": "done"}), content_type="application/json").status_code
        == 200
    )

    _login(client, "owner_a")
    response = client.post(
        url,
        data=json.dumps({"kind": "accepted"}),
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["message"]["my_reaction"] == "accepted"
    assert payload["case"]["current_user_is_owner"] is True
    assert CaseMessageReaction.objects.filter(
        message=message, reactor_login="owner_a", kind="accepted"
    ).exists()


@pytest.mark.django_db
def test_case_detail_message_reaction_stats(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    event = _event_case(approve=approve_with_primary_owner)
    unprocessed = _message_with_attachment(event, author_login="owner_a", body="Без реакции")
    in_progress_msg = _message_with_attachment(event, author_login="owner_a", body="В работе")
    done_accepted = _message_with_attachment(event, author_login="owner_a", body="Выполнено и принято")
    done_rejected = _message_with_attachment(event, author_login="owner_a", body="Выполнено и отклонено")
    CaseMessage.objects.create(case=event, author_login="owner_a", body="Только текст")

    CaseMessageReaction.objects.create(
        message=in_progress_msg,
        reactor_login="inspector_user",
        kind="in_progress",
    )
    CaseMessageReaction.objects.create(
        message=done_accepted,
        reactor_login="inspector_user",
        kind="done",
    )
    CaseMessageReaction.objects.create(
        message=done_accepted,
        reactor_login="owner_a",
        kind="accepted",
    )
    CaseMessageReaction.objects.create(
        message=done_rejected,
        reactor_login="inspector_user",
        kind="done",
    )
    CaseMessageReaction.objects.create(
        message=done_rejected,
        reactor_login="owner_a",
        kind="rejected",
    )

    _login(client, "inspector_user")
    response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": event.id}))
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["case"]["current_user_is_inspector"] is True
    assert payload["case"]["message_reaction_stats"] == {
        "unprocessed": 1,
        "in_progress": 1,
        "done": 2,
        "accepted": 1,
        "rejected": 1,
    }
    assert unprocessed.id in {item["id"] for item in payload["case"]["messages"]}

    _login(client, "owner_a")
    owner_response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": event.id}))
    assert owner_response.status_code == 200
    owner_payload = owner_response.json()
    assert owner_payload["case"]["current_user_is_inspector"] is False
    assert owner_payload["case"]["message_reaction_stats"]["unprocessed"] == 1


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


@pytest.mark.django_db
def test_case_detail_marks_overdue_after_one_month(client, owner_a, approve_with_primary_owner):
    from datetime import timedelta

    from approval.models import CaseServiceEvent
    from django.utils import timezone

    primary = _primary_case(approve_with_primary_owner)
    Case.objects.filter(pk=primary.pk).update(created_at=timezone.now() - timedelta(days=32))

    _login(client, "owner_a")
    response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["case"]["status"] == "Просрочено"
    assert payload["case"]["status_class"] == "overdue"
    assert payload["case"]["created_at_date"]

    overdue_events = CaseServiceEvent.objects.filter(
        case=primary, kind=CaseServiceEvent.KIND_CLOSED_OVERDUE
    )
    assert overdue_events.count() == 1
    overdue_items = [
        item
        for item in payload["case"]["messages"]
        if item.get("kind") == "service_closed_overdue"
    ]
    assert len(overdue_items) == 1
    assert overdue_items[0]["text"] == "Событие закрыто по истечению срока"

    response2 = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert response2.status_code == 200
    assert (
        CaseServiceEvent.objects.filter(
            case=primary, kind=CaseServiceEvent.KIND_CLOSED_OVERDUE
        ).count()
        == 1
    )
    overdue_items2 = [
        item
        for item in response2.json()["case"]["messages"]
        if item.get("kind") == "service_closed_overdue"
    ]
    assert len(overdue_items2) == 1


@pytest.mark.django_db
def test_full_approval_creates_closed_service_event(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    from approval.models import CaseServiceEvent

    primary = _primary_case(approve_with_primary_owner)

    _login(client, "owner_a")
    client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    _login(client, "inspector_user")
    response = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response.status_code == 200
    primary.refresh_from_db()
    assert primary.approved is True

    closed = CaseServiceEvent.objects.filter(
        case=primary, kind=CaseServiceEvent.KIND_CLOSED
    )
    assert closed.count() == 1

    detail = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert detail.status_code == 200
    closed_items = [
        item for item in detail.json()["case"]["messages"] if item.get("kind") == "service_closed"
    ]
    assert len(closed_items) == 1
    assert closed_items[0]["text"] == "Событие закрыто"


@pytest.mark.django_db
def test_approve_creates_service_event(client, owner_a, approve_with_primary_owner):
    from approval.models import CaseServiceEvent

    primary = _primary_case(approve_with_primary_owner)
    before_messages = CaseMessage.objects.filter(case=primary).count()
    before_events = CaseServiceEvent.objects.filter(case=primary).count()

    _login(client, "owner_a")
    response = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response.status_code == 200
    assert CaseMessage.objects.filter(case=primary).count() == before_messages
    assert CaseServiceEvent.objects.filter(case=primary).count() == before_events + 1
    event = CaseServiceEvent.objects.filter(case=primary).latest("id")
    assert event.kind == CaseServiceEvent.KIND_APPROVED
    assert event.actor_login == "owner_a"

    detail = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert detail.status_code == 200
    service_items = [
        item for item in detail.json()["case"]["messages"] if item.get("kind") == "service_approved"
    ]
    assert len(service_items) == 1
    assert service_items[0]["is_service"] is True
    assert service_items[0]["can_delete"] is False
    assert "согласовал" in service_items[0]["text"]


@pytest.mark.django_db
def test_revoke_creates_service_event(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    from approval.models import CaseServiceEvent

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

    revoke = client.post(
        reverse("approval:api_revoke_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert revoke.status_code == 200
    revoked = CaseServiceEvent.objects.filter(
        case=primary, kind=CaseServiceEvent.KIND_REVOKED
    ).latest("id")
    assert revoked.actor_login == "inspector_user"

    detail = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert detail.status_code == 200
    service_items = [
        item for item in detail.json()["case"]["messages"] if item.get("kind") == "service_revoked"
    ]
    assert len(service_items) >= 1
    assert "отменил согласование" in service_items[-1]["text"]


@pytest.mark.django_db
def test_inspector_can_delete_own_message(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
    settings,
    tmp_path,
):
    from approval.models import CaseMessageDeleted

    settings.MEDIA_ROOT = tmp_path
    primary = _primary_case(approve_with_primary_owner)

    _login(client, "inspector_user")
    create_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data={"body": "Сообщение инспектора"},
    )
    assert create_response.status_code == 200
    message_id = create_response.json()["message"]["id"]
    assert create_response.json()["message"]["can_delete"] is True

    delete_response = client.delete(
        reverse("approval:api_delete_message", kwargs={"message_id": message_id})
    )
    assert delete_response.status_code == 200
    assert delete_response.json()["ok"] is True
    assert not CaseMessage.objects.filter(pk=message_id).exists()
    archived = CaseMessageDeleted.objects.get(original_message_id=message_id)
    assert archived.body == "Сообщение инспектора"
    assert archived.deleted_by_login == "inspector_user"
    assert archived.author_login == "inspector_user"


@pytest.mark.django_db
def test_inspector_cannot_delete_foreign_message(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
):
    primary = _primary_case(approve_with_primary_owner)

    _login(client, "owner_a")
    create_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data={"body": "Сообщение владельца"},
    )
    assert create_response.status_code == 200
    message_id = create_response.json()["message"]["id"]
    assert create_response.json()["message"]["can_delete"] is False

    _login(client, "inspector_user")
    delete_response = client.delete(
        reverse("approval:api_delete_message", kwargs={"message_id": message_id})
    )
    assert delete_response.status_code == 403
    assert CaseMessage.objects.filter(pk=message_id).exists()


@pytest.mark.django_db
def test_owner_cannot_delete_own_message(
    client,
    owner_a,
    approve_with_primary_owner,
):
    primary = _primary_case(approve_with_primary_owner)

    _login(client, "owner_a")
    create_response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data={"body": "Сообщение владельца"},
    )
    assert create_response.status_code == 200
    message_id = create_response.json()["message"]["id"]

    delete_response = client.delete(
        reverse("approval:api_delete_message", kwargs={"message_id": message_id})
    )
    assert delete_response.status_code == 403
    assert CaseMessage.objects.filter(pk=message_id).exists()


@pytest.mark.django_db
def test_serialize_case_summary_can_delete_secondary_for_inspector(
    inspector_user,
    approve_with_primary_owner,
):
    from approval.events_service import serialize_case_summary

    primary = _primary_case(approve_with_primary_owner)
    secondary = _event_case(approve=approve_with_primary_owner)

    primary_payload = serialize_case_summary(
        primary, current_login="inspector_user", owner_id=None
    )
    secondary_payload = serialize_case_summary(
        secondary, current_login="inspector_user", owner_id=None
    )
    owner_payload = serialize_case_summary(
        secondary, current_login="owner_a", owner_id="OWNER_A"
    )

    assert primary_payload["can_delete"] is False
    assert secondary_payload["can_delete"] is True
    assert owner_payload["can_delete"] is False


@pytest.mark.django_db
def test_inspector_can_delete_secondary_case(
    client,
    owner_a,
    inspector_user,
    approve_with_primary_owner,
    settings,
    tmp_path,
):
    settings.MEDIA_ROOT = tmp_path
    primary = _primary_case(approve_with_primary_owner)
    secondary = _event_case(approve=approve_with_primary_owner)
    secondary_id = secondary.id

    _login(client, "inspector_user")
    response = client.delete(
        reverse("approval:api_case_detail", kwargs={"case_id": secondary_id})
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["deleted_case_id"] == str(secondary_id)
    assert payload["primary_case_id"] == str(primary.id)
    assert not Case.objects.filter(pk=secondary_id).exists()
    assert Case.objects.filter(pk=primary.id).exists()


@pytest.mark.django_db
def test_inspector_cannot_delete_primary_case(
    client,
    inspector_user,
    approve_with_primary_owner,
):
    primary = _primary_case(approve_with_primary_owner)

    _login(client, "inspector_user")
    response = client.delete(
        reverse("approval:api_case_detail", kwargs={"case_id": primary.id})
    )
    assert response.status_code == 403
    assert "основное" in response.json()["error"].lower()
    assert Case.objects.filter(pk=primary.id).exists()


@pytest.mark.django_db
def test_owner_cannot_delete_secondary_case(
    client,
    owner_a,
    approve_with_primary_owner,
):
    secondary = _event_case(approve=approve_with_primary_owner)

    _login(client, "owner_a")
    response = client.delete(
        reverse("approval:api_case_detail", kwargs={"case_id": secondary.id})
    )
    assert response.status_code == 403
    assert Case.objects.filter(pk=secondary.id).exists()

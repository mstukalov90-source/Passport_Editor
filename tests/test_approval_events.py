"""Tests for approval events, chats, and unanimous approval."""

from __future__ import annotations

import json
import uuid
from unittest.mock import patch

import pytest
from approval.models import (
    ApprovalGeometry,
    Approve,
    CaseApproval,
    CaseMessage,
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
def approve_two_owners():
    return Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A", "OWNER_B"],
    )


def _login(client, username):
    client.post(reverse("login"), {"username": username, "password": "pass"})


def _primary_case(approve):
    return approve.cases.filter(is_primary=True).first()


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


@pytest.mark.django_db
def test_bootstrap_returns_primary_case(client, owner_a, approve_two_owners):
    _login(client, "owner_a")
    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve_two_owners.id)})
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["primary_case_id"]
    assert len(payload["cases"]) >= 1


@pytest.mark.django_db
def test_create_case_with_geometry(client, owner_a, approve_two_owners):
    _login(client, "owner_a")
    geometry = {
        "type": "Polygon",
        "coordinates": [[[37.6, 55.75], [37.61, 55.75], [37.61, 55.76], [37.6, 55.76], [37.6, 55.75]]],
    }
    response = client.post(
        reverse("approval:api_create_case"),
        data=json.dumps(
            {
                "approve_id": str(approve_two_owners.id),
                "title": "Тестовое событие",
                "geometry": geometry,
            }
        ),
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    case_id = payload["case"]["id"]
    assert ApprovalGeometry.objects.filter(case_id=case_id).exists()
    assert CaseMessage.objects.filter(case_id=case_id, body="Событие создано.").exists()


@pytest.mark.django_db
def test_post_message_with_png_attachment(client, owner_a, approve_two_owners, settings, tmp_path):
    settings.MEDIA_ROOT = tmp_path
    _login(client, "owner_a")
    primary = _primary_case(approve_two_owners)
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
def test_unanimous_approval_closes_case(client, owner_a, owner_b_user, approve_two_owners):
    _login(client, "owner_a")
    primary = _primary_case(approve_two_owners)

    response_a = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_a.status_code == 200
    primary.refresh_from_db()
    assert primary.approved is False
    assert CaseApproval.objects.filter(case=primary).count() == 1

    _login(client, "owner_b")
    response_b = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response_b.status_code == 200
    primary.refresh_from_db()
    assert primary.approved is True
    assert primary.status == "согласовано"
    assert primary.closed_at is not None


@pytest.mark.django_db
def test_closed_case_rejects_new_message(client, owner_a, approve_two_owners):
    _login(client, "owner_a")
    primary = _primary_case(approve_two_owners)
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
def test_post_message_with_geometry(client, owner_a, approve_two_owners):
    _login(client, "owner_a")
    primary = _primary_case(approve_two_owners)
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
    assert ApprovalGeometry.objects.filter(case=primary, message__isnull=False).exists()


@pytest.mark.django_db
def test_owner_in_approve_but_not_case_cannot_access(client, owner_a, approve_two_owners):
    primary = _primary_case(approve_two_owners)
    primary.owners = ["OWNER_B"]
    primary.save(update_fields=["owners"])

    _login(client, "owner_a")
    response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert response.status_code == 404


@pytest.mark.django_db
def test_foreign_owner_cannot_access_case(client, owner_a, approve_two_owners):
    ExternalUser.objects.create(login="outsider", password="pass", owner_legal_person_id="OWNER_X")
    _login(client, "outsider")
    primary = _primary_case(approve_two_owners)
    response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert response.status_code == 404


@pytest.mark.django_db
def test_landing_page_has_events_shell(client, owner_a, approve_two_owners):
    with patch("approval.views.count_features_by_table", return_value={}):
        with patch(
            "approval.views.build_work_feature_collection",
            return_value=({"type": "FeatureCollection", "features": []}, None),
        ):
            _login(client, "owner_a")
            response = client.get(reverse("approval:landing"))
    assert response.status_code == 200
    content = response.content.decode("utf-8")
    assert "approval-approve-select" not in content
    assert "approval-create-event-btn" not in content
    assert "approval-chat-geometry-btn" in content
    assert "approval-chat-approve-btn" in content
    assert "Прикрепить файл" in content
    assert "Досъём участка №142" not in content

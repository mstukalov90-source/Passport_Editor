"""Integration tests for inspector access to approval chats."""

from __future__ import annotations

import json
import uuid

import pytest
from approval.models import Approve, Case, CaseMessage
from django.urls import reverse
from pass_viewer.models import ExternalUser


@pytest.fixture
def inspector_user():
    return ExternalUser.objects.create(login="inspector_user", password="pass", owner_legal_person_id=None)


@pytest.fixture
def owner_a_user():
    return ExternalUser.objects.create(login="owner_a", password="pass", owner_legal_person_id="OWNER_A")


@pytest.fixture
def owner_b_user():
    return ExternalUser.objects.create(login="owner_b", password="pass", owner_legal_person_id="OWNER_B")


@pytest.fixture
def approve_bundle():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A", "OWNER_B"],
        user="inspector_user",
        name="Согласование тест",
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["OWNER_A"]
    primary.title = approve.name
    primary.save(update_fields=["owners", "title", "updated_at"])
    event = Case.objects.create(
        approve=approve,
        is_primary=False,
        title="Событие смежника",
        owners=["OWNER_A", "OWNER_B"],
        n_root="10001260",
    )
    return approve, primary, event


def _login(client, username):
    client.post(reverse("login"), {"username": username, "password": "pass"})


@pytest.mark.django_db
def test_inspector_bootstrap_without_owner_id(client, inspector_user, approve_bundle):
    approve, primary, event = approve_bundle
    _login(client, "inspector_user")

    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve.id)})
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    case_ids = {item["id"] for item in payload["cases"]}
    assert str(primary.id) in case_ids
    assert str(event.id) in case_ids


@pytest.mark.django_db
def test_inspector_can_open_all_cases(client, inspector_user, approve_bundle):
    approve, primary, event = approve_bundle
    _login(client, "inspector_user")

    for case_id in (primary.id, event.id):
        response = client.get(reverse("approval:api_case_detail", kwargs={"case_id": case_id}))
        assert response.status_code == 200
        payload = response.json()
        assert payload["ok"] is True
        assert payload["case"]["current_user_is_inspector"] is True
        assert payload["case"]["inspector_login"] == "inspector_user"
        assert any(item["kind"] == "inspector" for item in payload["case"]["participants"])


@pytest.mark.django_db
def test_inspector_can_post_message(client, inspector_user, approve_bundle):
    _, primary, _ = approve_bundle
    _login(client, "inspector_user")

    response = client.post(
        reverse("approval:api_post_message", kwargs={"case_id": primary.id}),
        data=json.dumps({"body": "Комментарий инспектора"}),
        content_type="application/json",
    )
    assert response.status_code == 200
    assert CaseMessage.objects.filter(case=primary, body="Комментарий инспектора").exists()


@pytest.mark.django_db
def test_inspector_can_approve_case(client, inspector_user, approve_bundle):
    _, primary, _ = approve_bundle
    _login(client, "inspector_user")

    response = client.post(
        reverse("approval:api_approve_case", kwargs={"case_id": primary.id}),
        data="{}",
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["case"]["current_user_approved"] is True
    assert payload["case"]["inspector_approved"] is True


@pytest.mark.django_db
def test_owner_b_sees_event_but_not_primary(client, owner_b_user, approve_bundle):
    approve, primary, event = approve_bundle
    _login(client, "owner_b")

    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve.id)})
    assert response.status_code == 200
    payload = response.json()
    case_ids = {item["id"] for item in payload["cases"]}
    assert str(event.id) in case_ids
    assert str(primary.id) not in case_ids

    detail_primary = client.get(reverse("approval:api_case_detail", kwargs={"case_id": primary.id}))
    assert detail_primary.status_code == 404

    detail_event = client.get(reverse("approval:api_case_detail", kwargs={"case_id": event.id}))
    assert detail_event.status_code == 200


@pytest.mark.django_db
def test_owner_a_sees_primary_and_shared_event(client, owner_a_user, approve_bundle):
    approve, primary, event = approve_bundle
    _login(client, "owner_a")

    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve.id)})
    assert response.status_code == 200
    payload = response.json()
    case_ids = {item["id"] for item in payload["cases"]}
    assert str(primary.id) in case_ids
    assert str(event.id) in case_ids

    event_payload = next(item for item in payload["cases"] if item["id"] == str(event.id))
    assert event_payload["n_root"] == "10001260"

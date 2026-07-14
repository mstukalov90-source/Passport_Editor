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


@pytest.mark.django_db
def test_inspector_can_delete_approve(client, inspector_user, approve_bundle):
    approve, primary, event = approve_bundle
    approve_id = approve.id
    primary_id = primary.id
    event_id = event.id
    _login(client, "inspector_user")

    response = client.post(reverse("approval:delete_approve"), {"approve_id": str(approve_id)})
    assert response.status_code == 302
    assert response.url == reverse("home")
    assert not Approve.objects.filter(pk=approve_id).exists()
    assert not Case.objects.filter(pk__in=[primary_id, event_id]).exists()


@pytest.mark.django_db
def test_owner_cannot_delete_approve(client, owner_a_user, approve_bundle):
    approve, primary, event = approve_bundle
    approve_id = approve.id
    _login(client, "owner_a")

    response = client.post(reverse("approval:delete_approve"), {"approve_id": str(approve_id)})
    assert response.status_code == 302
    assert response.url == reverse("home")
    assert Approve.objects.filter(pk=approve_id).exists()
    assert Case.objects.filter(pk=primary.id).exists()
    assert Case.objects.filter(pk=event.id).exists()


@pytest.mark.django_db
def test_bootstrap_marks_can_delete_for_inspector(client, inspector_user, approve_bundle):
    approve, _, _ = approve_bundle
    _login(client, "inspector_user")

    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve.id)})
    assert response.status_code == 200
    payload = response.json()
    option = next(item for item in payload["approves"] if item["id"] == str(approve.id))
    assert option["can_delete"] is True


@pytest.mark.django_db
def test_bootstrap_hides_can_delete_for_owner(client, owner_a_user, approve_bundle):
    approve, _, _ = approve_bundle
    _login(client, "owner_a")

    response = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(approve.id)})
    assert response.status_code == 200
    payload = response.json()
    option = next(item for item in payload["approves"] if item["id"] == str(approve.id))
    assert option["can_delete"] is False


@pytest.mark.django_db
def test_inspector_can_change_secondary_case_owner(client, inspector_user, approve_bundle):
    _, primary, event = approve_bundle
    _login(client, "inspector_user")

    response = client.post(
        reverse("approval:api_change_case_owner", kwargs={"case_id": event.id}),
        data=json.dumps({"old_owner": "OWNER_B", "new_owner": "OWNER_C"}),
        content_type="application/json",
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert set(payload["case"]["owners"]) == {"OWNER_A", "OWNER_C"}
    event.refresh_from_db()
    assert set(event.owners) == {"OWNER_A", "OWNER_C"}

    primary_response = client.post(
        reverse("approval:api_change_case_owner", kwargs={"case_id": primary.id}),
        data=json.dumps({"old_owner": "OWNER_A", "new_owner": "OWNER_C"}),
        content_type="application/json",
    )
    assert primary_response.status_code == 400
    assert "основного события" in primary_response.json()["error"].lower()


@pytest.mark.django_db
def test_owner_cannot_change_case_owner(client, owner_a_user, approve_bundle):
    _, _, event = approve_bundle
    _login(client, "owner_a")

    response = client.post(
        reverse("approval:api_change_case_owner", kwargs={"case_id": event.id}),
        data=json.dumps({"old_owner": "OWNER_B", "new_owner": "OWNER_C"}),
        content_type="application/json",
    )
    assert response.status_code == 400
    assert "инспектору" in response.json()["error"].lower()
    event.refresh_from_db()
    assert set(event.owners) == {"OWNER_A", "OWNER_B"}


@pytest.mark.django_db
def test_inspector_can_add_owner_and_login_participants(client, inspector_user, approve_bundle):
    ExternalUser.objects.create(login="extra_login", password="pass", owner_legal_person_id=None)
    _, _, event = approve_bundle
    _login(client, "inspector_user")

    owner_response = client.post(
        reverse("approval:api_add_case_participant", kwargs={"case_id": event.id}),
        data=json.dumps({"kind": "owner", "value": "OWNER_EXTRA"}),
        content_type="application/json",
    )
    assert owner_response.status_code == 200
    assert "OWNER_EXTRA" in owner_response.json()["case"]["owners"]
    assert owner_response.json()["case"]["can_manage_participants"] is True

    login_response = client.post(
        reverse("approval:api_add_case_participant", kwargs={"case_id": event.id}),
        data=json.dumps({"kind": "login", "value": "extra_login"}),
        content_type="application/json",
    )
    assert login_response.status_code == 200
    payload = login_response.json()["case"]
    assert "extra_login" in payload["participant_logins"]
    assert any(item["kind"] == "login" and item["login"] == "extra_login" for item in payload["participants"])

    missing_response = client.post(
        reverse("approval:api_add_case_participant", kwargs={"case_id": event.id}),
        data=json.dumps({"kind": "login", "value": "no_such_user"}),
        content_type="application/json",
    )
    assert missing_response.status_code == 400
    assert "не найден" in missing_response.json()["error"].lower()


@pytest.mark.django_db
def test_login_participant_can_access_case(client, inspector_user, approve_bundle):
    ExternalUser.objects.create(login="guest_login", password="pass", owner_legal_person_id=None)
    _, primary, event = approve_bundle
    event.participant_logins = ["guest_login"]
    event.save(update_fields=["participant_logins", "updated_at"])

    _login(client, "guest_login")
    bootstrap = client.get(reverse("approval:api_bootstrap"), {"approve_id": str(event.approve_id)})
    assert bootstrap.status_code == 200
    case_ids = {item["id"] for item in bootstrap.json()["cases"]}
    assert str(event.id) in case_ids
    assert str(primary.id) not in case_ids

    detail = client.get(reverse("approval:api_case_detail", kwargs={"case_id": event.id}))
    assert detail.status_code == 200


@pytest.mark.django_db
def test_owner_cannot_add_case_participant(client, owner_a_user, approve_bundle):
    _, _, event = approve_bundle
    _login(client, "owner_a")

    response = client.post(
        reverse("approval:api_add_case_participant", kwargs={"case_id": event.id}),
        data=json.dumps({"kind": "owner", "value": "OWNER_EXTRA"}),
        content_type="application/json",
    )
    assert response.status_code == 400
    assert "инспектору" in response.json()["error"].lower()

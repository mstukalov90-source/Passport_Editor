"""Tests for home notification change events feed."""

from __future__ import annotations

import uuid
from datetime import timedelta
from unittest.mock import patch

import pytest
from approval.events_service import build_home_notification_events
from approval.models import Approve, Case, CaseMessage, CaseServiceEvent
from django.contrib.auth.models import User
from django.urls import reverse
from django.utils import timezone
from pass_viewer.models import ExternalUser


@pytest.fixture
def owner_a():
    return ExternalUser.objects.create(
        login="owner_a", password="pass", owner_legal_person_id="OWNER_A"
    )


@pytest.fixture
def approve_open():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A", "OWNER_B"],
        user="inspector_user",
        name="Согласование тестовое",
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["OWNER_A"]
    primary.title = "Основное событие съёмки"
    primary.save(update_fields=["owners", "title", "updated_at"])
    return approve


def _secondary(*, approve, n_root="09811", owners=None, title="Событие по паспорту"):
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
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
@patch(
    "approval.events_service.lookup_task_survey_fields",
    return_value=("", ""),
)
@patch(
    "approval.events_service.resolve_root_object_names",
    return_value={},
)
def test_build_home_notification_events_includes_message_case_approved(
    _mock_roots, _mock_survey, _mock_batch, _mock_poly, approve_open, owner_a
):
    secondary = _secondary(approve=approve_open, n_root="ROOT-1")
    foreign_message = CaseMessage.objects.create(
        case=secondary,
        author_login="inspector_user",
        body="Привет от инспектора",
    )
    CaseMessage.objects.create(
        case=secondary,
        author_login=owner_a.login,
        body="Моё сообщение не должно попасть",
    )
    service = CaseServiceEvent.objects.create(
        case=secondary,
        actor_login="inspector_user",
        kind=CaseServiceEvent.KIND_APPROVED,
    )
    CaseServiceEvent.objects.create(
        case=secondary,
        actor_login=owner_a.login,
        kind=CaseServiceEvent.KIND_APPROVED,
    )

    events = build_home_notification_events(
        owner_id="OWNER_A",
        username=owner_a.login,
    )
    by_id = {item["id"]: item for item in events}

    assert f"approve:{approve_open.id}" in by_id
    assert by_id[f"approve:{approve_open.id}"]["kind"] == "new_approve"
    assert f"case:{secondary.id}" in by_id
    assert by_id[f"case:{secondary.id}"]["kind"] == "new_case"
    assert f"msg:{foreign_message.id}" in by_id
    assert by_id[f"msg:{foreign_message.id}"]["kind"] == "message"
    assert "inspector_user" in by_id[f"msg:{foreign_message.id}"]["subtitle"]
    assert f"svc:{service.id}" in by_id
    assert by_id[f"svc:{service.id}"]["kind"] == "approved"

    own_message_ids = [
        item["id"] for item in events if item["kind"] == "message" and item.get("author") == owner_a.login
    ]
    assert own_message_ids == []
    own_approved_ids = [
        item["id"] for item in events if item["kind"] == "approved" and item.get("author") == owner_a.login
    ]
    assert own_approved_ids == []


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
@patch(
    "approval.events_service.lookup_task_survey_fields",
    return_value=("", ""),
)
@patch(
    "approval.events_service.resolve_root_object_names",
    return_value={},
)
def test_build_home_notification_events_excludes_own_new_approve(
    _mock_roots, _mock_survey, _mock_batch, _mock_poly, owner_a
):
    own_approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A"],
        user=owner_a.login,
        name="Создал сам",
    )
    events = build_home_notification_events(
        owner_id="OWNER_A",
        username=owner_a.login,
    )
    assert all(item["id"] != f"approve:{own_approve.id}" for item in events)


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
@patch(
    "approval.events_service.lookup_task_survey_fields",
    return_value=("", ""),
)
@patch(
    "approval.events_service.resolve_root_object_names",
    return_value={},
)
def test_build_home_notification_events_respects_lookback(
    _mock_roots, _mock_survey, _mock_batch, _mock_poly, approve_open, owner_a
):
    secondary = _secondary(approve=approve_open, n_root="ROOT-OLD", title="Старое событие")
    old_time = timezone.now() - timedelta(days=45)
    Case.objects.filter(id=secondary.id).update(created_at=old_time, updated_at=old_time)
    CaseMessage.objects.create(
        case=secondary,
        author_login="inspector_user",
        body="Старое сообщение",
    )
    CaseMessage.objects.filter(case=secondary).update(created_at=old_time)

    events = build_home_notification_events(
        owner_id="OWNER_A",
        username=owner_a.login,
        lookback_days=30,
    )
    assert all(item["id"] != f"case:{secondary.id}" for item in events)
    assert all(not item["id"].startswith("msg:") for item in events if "Старое" in (item.get("subtitle") or ""))


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
@patch(
    "approval.events_service.lookup_task_survey_fields",
    return_value=("", ""),
)
@patch(
    "approval.events_service.resolve_root_object_names",
    return_value={},
)
def test_build_home_notification_events_mggt_only_mine(
    _mock_roots, _mock_survey, _mock_batch, _mock_poly
):
    mggt = ExternalUser.objects.create(
        login="mggt_inspector",
        password="pass",
        owner_legal_person_id=None,
        role="MGGT",
    )
    mine = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_X"],
        user=mggt.login,
        name="Моё согласование MGGT",
    )
    mine_case = Case.objects.create(
        approve=mine,
        is_primary=False,
        title="Моё событие",
        owners=["OWNER_X"],
        n_root="MINE-1",
    )
    foreign_msg = CaseMessage.objects.create(
        case=mine_case,
        author_login="owner_bd",
        body="Сообщение BD",
    )
    CaseMessage.objects.create(
        case=mine_case,
        author_login=mggt.login,
        body="Своё сообщение MGGT",
    )
    mine_svc = CaseServiceEvent.objects.create(
        case=mine_case,
        actor_login="owner_bd",
        kind=CaseServiceEvent.KIND_APPROVED,
    )

    other = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_Y"],
        user="other_inspector",
        name="Чужое согласование",
    )
    other_case = Case.objects.create(
        approve=other,
        is_primary=False,
        title="Чужое событие",
        owners=["OWNER_Y"],
        n_root="OTHER-1",
    )
    CaseMessage.objects.create(
        case=other_case,
        author_login="someone",
        body="Не должно попасть к MGGT",
    )

    events = build_home_notification_events(username=mggt.login)
    by_id = {item["id"]: item for item in events}

    assert f"case:{mine_case.id}" in by_id
    assert f"msg:{foreign_msg.id}" in by_id
    assert f"svc:{mine_svc.id}" in by_id
    # Assigned approve is created by this MGGT user — own new_approve is skipped.
    assert f"approve:{mine.id}" not in by_id

    assert f"approve:{other.id}" not in by_id
    assert f"case:{other_case.id}" not in by_id
    assert all(
        item.get("case_id") != str(other_case.id) for item in events if item.get("case_id")
    )
    assert all(item.get("author") != mggt.login for item in events if item["kind"] == "message")


@pytest.mark.django_db
def test_actions_page_requires_login(client):
    response = client.get(reverse("actions"))
    assert response.status_code == 302
    assert "/accounts/login/" in response["Location"]


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
@patch(
    "approval.events_service.lookup_task_survey_fields",
    return_value=("", ""),
)
@patch(
    "approval.events_service.resolve_root_object_names",
    return_value={},
)
def test_actions_page_shows_all_events_and_modal_link(
    _mock_roots, _mock_survey, _mock_batch, _mock_poly, client, approve_open, owner_a
):
    user = User.objects.create_user(username=owner_a.login, password="pass")
    _secondary(approve=approve_open, n_root="ROOT-1", title="Событие по паспорту")
    client.force_login(user)

    response = client.get(reverse("actions"))
    assert response.status_code == 200
    html = response.content.decode("utf-8")
    assert "Все события" in html
    assert 'class="approval-notifications-all-link"' in html
    assert reverse("actions") in html
    assert 'id="actions-events-feed"' in html
    assert 'id="actions-ods-sync-section"' in html
    assert 'id="actions-ods-sync-list"' in html
    assert "АСУ ОДС" in html
    assert "Событие по паспорту" in html
    assert "Нет событий" in html


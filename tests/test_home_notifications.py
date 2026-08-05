"""Tests for home notifications payload (Approve→Cases + n_root section)."""

from __future__ import annotations

import uuid
from datetime import timedelta
from unittest.mock import patch

import pytest
from approval.events_service import build_home_notifications, serialize_notification_case_row
from approval.models import Approve, Case, CaseMessage
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
def test_build_home_notifications_nests_cases_under_approve(
    _mock_batch, _mock_poly, approve_open, owner_a
):
    secondary = _secondary(approve=approve_open, n_root="ROOT-1")
    CaseMessage.objects.create(
        case=secondary,
        author_login="inspector_user",
        body="Привет",
    )

    payload = build_home_notifications(
        owner_id="OWNER_A",
        username=owner_a.login,
        owned_rootids=["OTHER-ROOT"],
    )

    assert payload["open_case_count"] == 2
    assert len(payload["approve_groups"]) == 1
    group = payload["approve_groups"][0]
    assert group["approve"]["id"] == str(approve_open.id)
    assert "Согласование тестовое" in group["approve"]["label"]
    case_ids = {row["id"] for row in group["cases"]}
    assert str(approve_open.cases.get(is_primary=True).id) in case_ids
    assert str(secondary.id) in case_ids
    secondary_row = next(row for row in group["cases"] if row["id"] == str(secondary.id))
    assert secondary_row["last_message_author"] == "inspector_user"
    assert secondary_row["approve_until"]
    assert payload["n_root_cases"] == []


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
def test_build_home_notifications_n_root_section_and_dedup(
    _mock_batch, _mock_poly, approve_open, owner_a
):
    nested = _secondary(approve=approve_open, n_root="ROOT-SHARED", title="По паспорту пользователя")

    other = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_X", "OWNER_A"],
        user="other_inspector",
        name="Чужое согласование",
    )
    only_n_root = Case.objects.create(
        approve=other,
        is_primary=False,
        title="Только по паспорту",
        owners=["OWNER_A", "OWNER_X"],
        n_root="ROOT-ONLY",
    )

    payload = build_home_notifications(
        owner_id="OWNER_A",
        username=owner_a.login,
        owned_rootids=["ROOT-SHARED", "ROOT-ONLY", "root-only"],
    )

    section1_ids = {
        row["id"]
        for group in payload["approve_groups"]
        for row in group["cases"]
    }
    assert str(nested.id) not in section1_ids
    assert str(approve_open.cases.get(is_primary=True).id) in section1_ids

    n_root_ids = {row["id"] for row in payload["n_root_cases"]}
    assert str(nested.id) in n_root_ids
    assert str(only_n_root.id) in n_root_ids
    only_row = next(row for row in payload["n_root_cases"] if row["id"] == str(only_n_root.id))
    assert only_row["n_root"] == "ROOT-ONLY"


@pytest.mark.django_db
@patch(
    "approval.events_service.lookup_task_poly_meta",
    return_value={"source_label": "", "object_name": "", "table": ""},
)
@patch(
    "approval.events_service.batch_lookup_task_poly_meta",
    return_value={},
)
def test_build_home_notifications_skips_approved_approve(
    _mock_batch, _mock_poly, approve_open, owner_a
):
    approve_open.approved = True
    approve_open.save(update_fields=["approved", "updated_at"])
    for case in approve_open.cases.all():
        case.approved = True
        case.save(update_fields=["approved", "updated_at"])

    payload = build_home_notifications(
        owner_id="OWNER_A",
        username=owner_a.login,
        owned_rootids=[],
    )
    assert payload["approve_groups"] == []
    assert payload["open_case_count"] == 0


@pytest.mark.django_db
def test_serialize_notification_case_row_marks_primary(approve_open):
    primary = approve_open.cases.get(is_primary=True)
    primary.created_at = timezone.now() - timedelta(days=5)
    primary.save(update_fields=["created_at"])
    row = serialize_notification_case_row(primary)
    assert row["is_primary"] is True
    assert "Основное" in row["display_title"]
    assert row["approve_id"] == str(approve_open.id)
    assert row["approve_until"]

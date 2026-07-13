"""Unit tests for approval access rules and inspector approvals."""

from __future__ import annotations

import uuid

import pytest
from approval.access import (
    get_accessible_approves,
    get_accessible_cases_queryset,
    is_inspector_for_approve,
    user_can_access_case,
)
from approval.events_service import (
    aggregate_approve_owners,
    record_case_approval,
    resolve_event_case_owners,
    serialize_case_summary,
    validate_case_owners,
)
from approval.models import Approve, Case


@pytest.fixture
def approve_with_inspector():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A", "OWNER_B"],
        user="inspector_user",
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["OWNER_A"]
    primary.save(update_fields=["owners", "updated_at"])
    return approve


def _secondary_case(*, approve, owners=None, n_root="09811", title="Событие"):
    return Case.objects.create(
        approve=approve,
        is_primary=False,
        title=title,
        owners=owners or ["OWNER_A", "OWNER_B"],
        n_root=n_root,
    )


@pytest.mark.django_db
def test_is_inspector_for_approve():
    approve = Approve.objects.create(incoming_guid=uuid.uuid4(), user="inspector_user")
    assert is_inspector_for_approve("inspector_user", approve) is True
    assert is_inspector_for_approve("other_user", approve) is False


@pytest.mark.django_db
def test_user_can_access_case_for_owner(approve_with_inspector):
    case = _secondary_case(approve=approve_with_inspector)
    assert user_can_access_case(case, "OWNER_A") is True
    assert user_can_access_case(case, "OWNER_X") is False


@pytest.mark.django_db
def test_user_can_access_case_for_inspector(approve_with_inspector):
    primary = approve_with_inspector.cases.get(is_primary=True)
    assert user_can_access_case(primary, owner_id=None, username="inspector_user") is True
    assert user_can_access_case(primary, owner_id="OWNER_X", username="inspector_user") is True


@pytest.mark.django_db
def test_primary_hidden_from_n_root_owner(approve_with_inspector):
    primary = approve_with_inspector.cases.get(is_primary=True)
    secondary = _secondary_case(approve=approve_with_inspector)

    assert user_can_access_case(primary, "OWNER_A") is True
    assert user_can_access_case(primary, "OWNER_B") is False
    assert user_can_access_case(secondary, "OWNER_B") is True


@pytest.mark.django_db
def test_get_accessible_approves_for_inspector_without_owner_id(approve_with_inspector):
    qs = get_accessible_approves(username="inspector_user")
    assert qs.filter(pk=approve_with_inspector.pk).exists()


@pytest.mark.django_db
def test_get_accessible_cases_queryset_for_inspector(approve_with_inspector):
    primary = approve_with_inspector.cases.get(is_primary=True)
    secondary = _secondary_case(approve=approve_with_inspector)

    cases = list(get_accessible_cases_queryset(username="inspector_user", approve_id=approve_with_inspector.id))
    assert {item.id for item in cases} == {primary.id, secondary.id}


@pytest.mark.django_db
def test_get_accessible_cases_queryset_for_owner_only(approve_with_inspector):
    primary = approve_with_inspector.cases.get(is_primary=True)
    secondary = _secondary_case(approve=approve_with_inspector)

    cases = list(get_accessible_cases_queryset("OWNER_B", approve_id=approve_with_inspector.id))
    assert {item.id for item in cases} == {secondary.id}
    assert primary.id not in {item.id for item in cases}


@pytest.mark.django_db
def test_validate_case_owners_primary():
    assert validate_case_owners(is_primary=True, owners=["OWNER_A"]) == ["OWNER_A"]
    with pytest.raises(ValueError, match="ровно одного"):
        validate_case_owners(is_primary=True, owners=["OWNER_A", "OWNER_B"])


@pytest.mark.django_db
def test_validate_case_owners_secondary():
    assert validate_case_owners(is_primary=False, owners=["OWNER_A", "OWNER_B"]) == ["OWNER_A", "OWNER_B"]
    with pytest.raises(ValueError, match="ровно двух"):
        validate_case_owners(is_primary=False, owners=["OWNER_A"])


@pytest.mark.django_db
def test_resolve_event_case_owners_merges_task_owner():
    assert resolve_event_case_owners(task_owner_id="OWNER_TASK", event_owners=["9000022"]) == [
        "OWNER_TASK",
        "9000022",
    ]


@pytest.mark.django_db
def test_resolve_event_case_owners_rejects_duplicate_task_owner():
    with pytest.raises(ValueError, match="разными"):
        resolve_event_case_owners(task_owner_id="OWNER_TASK", event_owners=["OWNER_TASK"])


@pytest.mark.django_db
def test_resolve_event_case_owners_rejects_more_than_two_after_merge():
    with pytest.raises(ValueError, match="ровно двух"):
        resolve_event_case_owners(task_owner_id="OWNER_TASK", event_owners=["9000022", "9000033"])


@pytest.mark.django_db
def test_aggregate_approve_owners_includes_task_owner():
    assert aggregate_approve_owners(task_owner_id="OWNER_TASK", event_owners=["9000022", "9000033"]) == [
        "OWNER_TASK",
        "9000022",
        "9000033",
    ]


@pytest.mark.django_db
def test_record_case_approval_requires_inspector_signature(approve_with_inspector):
    case = _secondary_case(approve=approve_with_inspector)

    record_case_approval(case=case, owner_id="OWNER_A")
    case.refresh_from_db()
    assert case.approved is False

    record_case_approval(case=case, owner_id="OWNER_B")
    case.refresh_from_db()
    assert case.approved is False

    record_case_approval(case=case, username="inspector_user")
    case.refresh_from_db()
    assert case.approved is True
    assert case.status == "согласовано"
    approve_with_inspector.refresh_from_db()
    assert approve_with_inspector.approved is False


@pytest.mark.django_db
def test_record_case_approval_primary_without_inspector_when_not_assigned():
    approve = Approve.objects.create(incoming_guid=uuid.uuid4(), owners=["OWNER_A"])
    case = approve.cases.get(is_primary=True)
    case.owners = ["OWNER_A"]
    case.save(update_fields=["owners", "updated_at"])

    record_case_approval(case=case, owner_id="OWNER_A")
    case.refresh_from_db()
    assert case.approved is True
    approve.refresh_from_db()
    assert approve.approved is True


@pytest.mark.django_db
def test_serialize_case_summary_includes_inspector_fields(approve_with_inspector):
    case = _secondary_case(approve=approve_with_inspector)
    payload = serialize_case_summary(case, current_login="inspector_user", owner_id=None)

    assert payload["n_root"] == "09811"
    assert payload["inspector_required"] is True
    assert payload["inspector_approved"] is False
    assert payload["inspector_login"] == "inspector_user"
    assert payload["current_user_is_inspector"] is True
    assert payload["current_user_approved"] is False
    assert payload["approvals_total"] == 3
    assert any(item["kind"] == "inspector" for item in payload["participants"])

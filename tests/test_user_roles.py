"""Tests for user roles BD / MGGT / DEP / DEP+ / SUP access rules."""

from __future__ import annotations

import uuid

import pytest
from approval.access import (
    get_accessible_approves,
    is_inspector_for_approve,
    matching_case_owner_id,
    user_can_access_case,
    user_can_write_approvals,
)
from approval.events_service import record_case_approval, serialize_case_summary
from approval.models import Approve, Case
from pass_viewer.models import ExternalUser
from pass_viewer.roles import (
    FILTER_OWNER_MULTI,
    ROLE_BD,
    ROLE_DEP,
    ROLE_DEP_PLUS,
    ROLE_MGGT,
    ROLE_SUP,
    resolve_user_scope,
)


@pytest.fixture
def approve_foreign_inspector():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A"],
        user="assigned_inspector",
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["OWNER_A"]
    primary.save(update_fields=["owners", "updated_at"])
    return approve


def _mk_user(*, login: str, role: str, owner_id: str | None = None, **extra):
    return ExternalUser.objects.create(
        login=login,
        password="x",
        owner_legal_person_id=owner_id,
        role=role,
        hood_scope=False,
        **extra,
    )


@pytest.mark.django_db
def test_resolve_user_scope_bd_default():
    _mk_user(login="bd1", role=ROLE_BD, owner_id="OWNER_1")
    scope = resolve_user_scope("bd1")
    assert scope.role == ROLE_BD
    assert scope.owner_id == "OWNER_1"
    assert scope.owner_ids == ("OWNER_1",)
    assert scope.can_write is True
    assert scope.include_ods is True
    assert scope.filter_field == "owner"
    assert scope.display_name == ""


@pytest.mark.django_db
def test_resolve_user_scope_mggt():
    _mk_user(login="mggt1", role=ROLE_MGGT, owner_id=None)
    scope = resolve_user_scope("mggt1")
    assert scope.role == ROLE_MGGT
    assert scope.is_global_inspector is True
    assert scope.approvals_mode == "all"
    assert scope.include_ods is False
    assert scope.can_write is True


@pytest.mark.django_db
def test_resolve_user_scope_dep():
    _mk_user(login="dep1", role=ROLE_DEP, owner_id="DEPT_9")
    scope = resolve_user_scope("dep1")
    assert scope.role == ROLE_DEP
    assert scope.filter_field == "department"
    assert scope.owner_id == "DEPT_9"
    assert scope.owner_ids == ("DEPT_9",)


@pytest.mark.django_db
def test_resolve_user_scope_dep_plus():
    _mk_user(
        login="depplus1",
        role=ROLE_DEP_PLUS,
        owner_id=None,
        owner_legal_person_ids=["OWN_X", "OWN_Y", "OWN_X"],
        display_name="Группа департаментов Север",
    )
    scope = resolve_user_scope("depplus1")
    assert scope.role == ROLE_DEP_PLUS
    assert scope.owner_ids == ("OWN_X", "OWN_Y")
    assert scope.owner_id == "OWN_X"
    assert scope.filter_field == FILTER_OWNER_MULTI
    assert scope.include_ods is True
    assert scope.can_write is True
    assert scope.approvals_mode == "owned"
    assert scope.display_name == "Группа департаментов Север"
    assert scope.is_global_inspector is False


@pytest.mark.django_db
def test_resolve_user_scope_sup_readonly():
    _mk_user(login="sup1", role=ROLE_SUP, owner_id=None)
    scope = resolve_user_scope("sup1")
    assert scope.role == ROLE_SUP
    assert scope.can_write is False
    assert scope.approvals_mode == "all"
    assert user_can_write_approvals("sup1") is False


@pytest.mark.django_db
def test_mggt_is_global_inspector(approve_foreign_inspector):
    _mk_user(login="mggt1", role=ROLE_MGGT)
    assert is_inspector_for_approve("mggt1", approve_foreign_inspector) is True
    assert is_inspector_for_approve("random", approve_foreign_inspector) is False


@pytest.mark.django_db
def test_mggt_sees_all_approves(approve_foreign_inspector):
    _mk_user(login="mggt1", role=ROLE_MGGT)
    other = Approve.objects.create(incoming_guid=uuid.uuid4(), user="someone_else")
    qs = get_accessible_approves(username="mggt1")
    ids = set(qs.values_list("pk", flat=True))
    assert approve_foreign_inspector.pk in ids
    assert other.pk in ids


@pytest.mark.django_db
def test_dep_plus_sees_approve_for_any_owner_id(approve_foreign_inspector):
    _mk_user(
        login="depplus1",
        role=ROLE_DEP_PLUS,
        owner_legal_person_ids=["OTHER", "OWNER_A"],
        display_name="Test DEP+",
    )
    other = Approve.objects.create(incoming_guid=uuid.uuid4(), owners=["UNRELATED"])
    other_case = other.cases.get(is_primary=True)
    other_case.owners = ["UNRELATED"]
    other_case.save(update_fields=["owners", "updated_at"])

    qs = get_accessible_approves(username="depplus1")
    ids = set(qs.values_list("pk", flat=True))
    assert approve_foreign_inspector.pk in ids
    assert other.pk not in ids

    case = approve_foreign_inspector.cases.get(is_primary=True)
    assert user_can_access_case(case, username="depplus1") is True
    assert matching_case_owner_id(case, username="depplus1") == "OWNER_A"


@pytest.mark.django_db
def test_bd_still_scoped_to_single_owner(approve_foreign_inspector):
    _mk_user(login="bd1", role=ROLE_BD, owner_id="OWNER_B")
    qs = get_accessible_approves(username="bd1")
    assert not qs.filter(pk=approve_foreign_inspector.pk).exists()

    _mk_user(login="bd2", role=ROLE_BD, owner_id="OWNER_A")
    qs2 = get_accessible_approves(username="bd2")
    assert qs2.filter(pk=approve_foreign_inspector.pk).exists()


@pytest.mark.django_db
def test_dep_still_scoped_like_bd(approve_foreign_inspector):
    _mk_user(login="dep1", role=ROLE_DEP, owner_id="OWNER_A")
    assert get_accessible_approves(username="dep1").filter(pk=approve_foreign_inspector.pk).exists()
    _mk_user(login="dep2", role=ROLE_DEP, owner_id="OWNER_Z")
    assert not get_accessible_approves(username="dep2").filter(pk=approve_foreign_inspector.pk).exists()


@pytest.mark.django_db
def test_sup_sees_all_approves_readonly(approve_foreign_inspector):
    _mk_user(login="sup1", role=ROLE_SUP)
    qs = get_accessible_approves(username="sup1")
    assert qs.filter(pk=approve_foreign_inspector.pk).exists()
    assert user_can_access_case(
        approve_foreign_inspector.cases.get(is_primary=True),
        username="sup1",
    )
    payload = serialize_case_summary(
        approve_foreign_inspector.cases.get(is_primary=True),
        current_login="sup1",
        owner_id=None,
    )
    assert payload["current_user_is_inspector"] is False
    assert payload["can_manage_participants"] is False
    assert payload["can_delete"] is False


@pytest.mark.django_db
def test_mggt_can_approve_foreign_as_inspector(approve_foreign_inspector):
    _mk_user(login="mggt1", role=ROLE_MGGT)
    case = Case.objects.create(
        approve=approve_foreign_inspector,
        is_primary=False,
        title="Событие",
        owners=["OWNER_A", "OWNER_B"],
        n_root="1",
    )
    record_case_approval(case=case, owner_id="OWNER_A")
    record_case_approval(case=case, owner_id="OWNER_B")
    case.refresh_from_db()
    assert case.approved is False

    record_case_approval(case=case, username="mggt1")
    case.refresh_from_db()
    assert case.approved is True


@pytest.mark.django_db
def test_dep_plus_can_record_approval_for_matching_owner():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWN_X", "OWN_Y"],
        user="insp",
    )
    case = approve.cases.get(is_primary=True)
    case.owners = ["OWN_X", "OWN_Y"]
    case.save(update_fields=["owners", "updated_at"])

    _mk_user(
        login="depplus1",
        role=ROLE_DEP_PLUS,
        owner_legal_person_ids=["OWN_Y", "OWN_Z"],
        display_name="Multi",
    )
    record_case_approval(case=case, username="depplus1")
    case.refresh_from_db()
    assert case.approvals.filter(owner_legal_person_id="OWN_Y").exists()


@pytest.mark.django_db
def test_sup_cannot_record_approval(approve_foreign_inspector):
    _mk_user(login="sup1", role=ROLE_SUP)
    case = approve_foreign_inspector.cases.get(is_primary=True)
    with pytest.raises(ValueError, match="просмотра"):
        record_case_approval(case=case, username="sup1")

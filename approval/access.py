"""Access control for approval workflows."""

from __future__ import annotations

from django.db.models import Q

from pass_viewer.roles import (
    ROLE_MGGT,
    get_user_role,
    resolve_user_scope,
    sees_all_approvals,
)

from .models import Approve, Case


def get_owner_id_for_username(username):
    if not username:
        return None
    scope = resolve_user_scope(username)
    return scope.owner_id


def get_owner_ids_for_username(username) -> tuple[str, ...]:
    if not username:
        return ()
    return resolve_user_scope(username).owner_ids


def _normalize_owner_ids_arg(owner_id=None, owner_ids=None) -> tuple[str, ...]:
    out: list[str] = []
    seen: set[str] = set()
    for raw in list(owner_ids or ()) + ([owner_id] if owner_id else []):
        text = str(raw).strip() if raw is not None else ""
        if not text or text in seen:
            continue
        seen.add(text)
        out.append(text)
    return tuple(out)


def is_inspector_for_approve(username, approve) -> bool:
    if not username or not approve:
        return False
    login = str(username).strip()
    if not login:
        return False
    # MGGT is a global inspector for every approve.
    if get_user_role(login) == ROLE_MGGT:
        return True
    inspector_login = (approve.user or "").strip()
    return bool(inspector_login) and inspector_login == login


def _normalized_participant_logins(case) -> list[str]:
    return [str(item).strip() for item in (case.participant_logins or []) if str(item).strip()]


def _username_sees_all_approvals(username: str | None) -> bool:
    if not username:
        return False
    scope = resolve_user_scope(username)
    return sees_all_approvals(scope)


def _owners_q_for_ids(ids: tuple[str, ...], *, case_field: bool = False) -> Q:
    """OR of owners__contains for each id. case_field=False uses cases__owners."""
    filters = Q()
    for owner_text in ids:
        if case_field:
            filters |= Q(owners__contains=[owner_text])
        else:
            filters |= Q(cases__owners__contains=[owner_text])
    return filters


def user_can_access_case(case, owner_id=None, *, username=None, owner_ids=None) -> bool:
    if not case:
        return False

    if _username_sees_all_approvals(username):
        return True

    approve = case.approve if hasattr(case, "approve") else None
    if approve is None:
        approve = Approve.objects.filter(pk=case.approve_id).first()
    if approve and is_inspector_for_approve(username, approve):
        return True

    login = str(username or "").strip()
    if login and login in _normalized_participant_logins(case):
        return True

    ids = _normalize_owner_ids_arg(owner_id, owner_ids)
    if username:
        ids = _normalize_owner_ids_arg(None, ids + get_owner_ids_for_username(username))
    if not ids:
        return False
    case_owners = [str(item).strip() for item in (case.owners or []) if str(item).strip()]
    return any(oid in case_owners for oid in ids)


def get_accessible_approves(owner_id=None, *, username=None, owner_ids=None):
    if _username_sees_all_approvals(username):
        return Approve.objects.all().order_by("-created_at")

    ids = _normalize_owner_ids_arg(owner_id, owner_ids)
    if username:
        ids = _normalize_owner_ids_arg(None, ids + get_owner_ids_for_username(username))

    if not ids and not username:
        return Approve.objects.none()

    filters = Q()
    if ids:
        filters |= _owners_q_for_ids(ids, case_field=False)
    if username:
        login = str(username).strip()
        if login:
            filters |= Q(user=login)
            filters |= Q(cases__participant_logins__contains=[login])

    if not filters:
        return Approve.objects.none()

    return Approve.objects.filter(filters).distinct().order_by("-created_at")


def get_accessible_approve(approve_id, owner_id=None, *, username=None, owner_ids=None):
    if not approve_id:
        return None
    return get_accessible_approves(owner_id, username=username, owner_ids=owner_ids).filter(pk=approve_id).first()


def get_accessible_cases_queryset(owner_id=None, approve_id=None, *, username=None, owner_ids=None):
    queryset = Case.objects.select_related("approve")

    if approve_id:
        queryset = queryset.filter(approve_id=approve_id)

    if _username_sees_all_approvals(username):
        return queryset

    ids = _normalize_owner_ids_arg(owner_id, owner_ids)
    if username:
        ids = _normalize_owner_ids_arg(None, ids + get_owner_ids_for_username(username))

    if not ids and not username:
        return Case.objects.none()

    login = str(username).strip() if username else ""

    if login and not ids:
        return queryset.filter(Q(approve__user=login) | Q(participant_logins__contains=[login]))

    if ids:
        owner_cases = queryset.filter(_owners_q_for_ids(ids, case_field=True))
        if login:
            login_cases = queryset.filter(
                Q(approve__user=login) | Q(participant_logins__contains=[login])
            )
            return (owner_cases | login_cases).distinct()
        return owner_cases

    return Case.objects.none()


def matching_case_owner_id(case, owner_id=None, *, username=None, owner_ids=None) -> str | None:
    """First of the user's owner ids that appears in case.owners (for CaseApproval slot)."""
    ids = _normalize_owner_ids_arg(owner_id, owner_ids)
    if username:
        ids = _normalize_owner_ids_arg(None, ids + get_owner_ids_for_username(username))
    case_owners = [str(item).strip() for item in (case.owners or []) if str(item).strip()]
    for oid in ids:
        if oid in case_owners:
            return oid
    return None


def user_can_write_approvals(username: str | None) -> bool:
    """SUP is read-only; other roles may mutate when otherwise authorized."""
    if not username:
        return False
    scope = resolve_user_scope(username)
    return scope.can_write

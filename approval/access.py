"""Access control for approval workflows."""

from django.db.models import Q

from pass_viewer.models import ExternalUser

from .models import Approve, Case


def get_owner_id_for_username(username):
    if not username:
        return None
    user = ExternalUser.objects.filter(login=username).only("owner_legal_person_id").first()
    if not user or not user.owner_legal_person_id:
        return None
    return str(user.owner_legal_person_id).strip() or None


def is_inspector_for_approve(username, approve) -> bool:
    if not username or not approve:
        return False
    inspector_login = (approve.user or "").strip()
    return bool(inspector_login) and inspector_login == str(username).strip()


def user_can_access_case(case, owner_id=None, *, username=None) -> bool:
    if not case:
        return False

    approve = case.approve if hasattr(case, "approve") else None
    if approve is None:
        approve = Approve.objects.filter(pk=case.approve_id).first()
    if approve and is_inspector_for_approve(username, approve):
        return True

    if not owner_id:
        return False
    owner_text = str(owner_id).strip()
    if not owner_text:
        return False
    return owner_text in [str(item).strip() for item in (case.owners or []) if str(item).strip()]


def get_accessible_approves(owner_id=None, *, username=None):
    if not owner_id and not username:
        return Approve.objects.none()

    filters = Q()
    if owner_id:
        owner_text = str(owner_id).strip()
        if owner_text:
            filters |= Q(cases__owners__contains=[owner_text])
    if username:
        login = str(username).strip()
        if login:
            filters |= Q(user=login)

    if not filters:
        return Approve.objects.none()

    return Approve.objects.filter(filters).distinct().order_by("-created_at")


def get_accessible_approve(approve_id, owner_id=None, *, username=None):
    if not approve_id:
        return None
    return get_accessible_approves(owner_id, username=username).filter(pk=approve_id).first()


def get_accessible_cases_queryset(owner_id=None, approve_id=None, *, username=None):
    if not owner_id and not username:
        return Case.objects.none()

    queryset = Case.objects.select_related("approve")

    if approve_id:
        queryset = queryset.filter(approve_id=approve_id)

    if username and not owner_id:
        login = str(username).strip()
        if login:
            return queryset.filter(approve__user=login)

    if owner_id:
        owner_text = str(owner_id).strip()
        if owner_text:
            owner_cases = queryset.filter(owners__contains=[owner_text])
            if username:
                login = str(username).strip()
                if login:
                    inspector_cases = queryset.filter(approve__user=login)
                    return (owner_cases | inspector_cases).distinct()
            return owner_cases

    return Case.objects.none()

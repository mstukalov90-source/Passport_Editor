"""Access control for approval workflows."""

from pass_viewer.models import ExternalUser

from .models import Approve


def get_owner_id_for_username(username):
    if not username:
        return None
    user = ExternalUser.objects.filter(login=username).only("owner_legal_person_id").first()
    if not user or not user.owner_legal_person_id:
        return None
    return str(user.owner_legal_person_id).strip() or None


def get_accessible_approves(owner_id):
    if not owner_id:
        return Approve.objects.none()
    return Approve.objects.filter(owners__contains=[str(owner_id)]).order_by("-created_at")


def get_accessible_approve(approve_id, owner_id):
    if not approve_id or not owner_id:
        return None
    return get_accessible_approves(owner_id).filter(pk=approve_id).first()


def user_can_access_case(case, owner_id):
    if not case or not owner_id:
        return False
    return get_accessible_approves(owner_id).filter(pk=case.approve_id).exists()

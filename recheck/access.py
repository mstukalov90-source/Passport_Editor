from __future__ import annotations

from pass_viewer.roles import ROLE_MGGT, get_user_role, resolve_user_scope

from .models import RecheckEvent


def is_mggt(username: str | None) -> bool:
    return bool(username) and get_user_role(str(username).strip()) == ROLE_MGGT


def can_access_event(event: RecheckEvent, username: str | None) -> bool:
    login = str(username or "").strip()
    if not login:
        return False
    if is_mggt(login):
        return True
    scope = resolve_user_scope(login)
    return event.task_owner_id in scope.owner_ids


def accessible_events(username: str | None):
    login = str(username or "").strip()
    if not login:
        return RecheckEvent.objects.none()
    if is_mggt(login):
        return RecheckEvent.objects.all()
    scope = resolve_user_scope(login)
    if not scope.owner_ids:
        return RecheckEvent.objects.none()
    return RecheckEvent.objects.filter(task_owner_id__in=scope.owner_ids)

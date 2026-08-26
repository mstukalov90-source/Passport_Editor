"""Template context shared across authenticated HTML pages."""

from __future__ import annotations

from approval.events_service import build_home_notification_events
from pass_viewer.roles import resolve_user_scope


def approval_notifications(request):
    empty = {
        "home_notification_events": [],
        "pending_approval_count": 0,
        "notifications_owner_id": "",
    }
    user = getattr(request, "user", None)
    if user is None or not user.is_authenticated:
        return empty

    owner_id = ""
    try:
        scope = resolve_user_scope(user.username)
        owner_id = str(scope.owner_id or "").strip()
        events = build_home_notification_events(
            owner_id=scope.owner_id,
            username=user.username,
        )
    except Exception:
        events = []

    return {
        "home_notification_events": events or [],
        "pending_approval_count": 0,
        "notifications_owner_id": owner_id,
    }

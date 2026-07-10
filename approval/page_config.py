"""Page bootstrap config for approval templates (json_script)."""

from django.urls import reverse

from .events_service import serialize_approve_option


def landing_page_config(
    *,
    layer_groups=None,
    approves=None,
    selected_approve_id=None,
    current_user_login="",
    default_zoom=10,
):
    groups = layer_groups or []
    layer_group_map = {
        group["key"]: [layer["key"] for layer in group.get("layers", [])]
        for group in groups
        if group.get("key")
    }
    approve_options = [serialize_approve_option(approve) for approve in approves or []]

    return {
        "page": "approval_landing",
        "mapElementId": "approval-map",
        "defaultZoom": default_zoom,
        "center": [55.75, 37.61],
        "layerGroups": layer_group_map,
        "currentUser": current_user_login,
        "selectedApproveId": str(selected_approve_id) if selected_approve_id else None,
        "approves": approve_options,
        "apiUrls": {
            "bootstrap": reverse("approval:api_bootstrap"),
            "caseDetail": "/approval/api/cases/{caseId}/",
            "postMessage": "/approval/api/cases/{caseId}/messages/",
            "approveCase": "/approval/api/cases/{caseId}/approve/",
            "attachment": "/approval/api/attachments/{attachmentId}/",
        },
        "layerStyleIconsBase": "/static/approval/icons/svg/",
    }

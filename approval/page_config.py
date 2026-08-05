"""Page bootstrap config for approval templates (json_script)."""

from django.urls import reverse

from .events_service import serialize_approve_options
from .work_layers import layer_stack_order


def landing_page_config(
    *,
    layer_groups=None,
    approves=None,
    selected_approve_id=None,
    focus_task_guid=None,
    current_user_login="",
    default_zoom=10,
    adjacent_roots=None,
    map_layer_load_order=None,
    initial_case_id=None,
):
    groups = layer_groups or []
    layer_group_map = {
        group["key"]: [layer["key"] for layer in group.get("layers", [])]
        for group in groups
        if group.get("key")
    }
    approve_options = serialize_approve_options(
        approves or [],
        username=current_user_login,
    )

    return {
        "page": "approval_landing",
        "mapElementId": "approval-map",
        "defaultZoom": default_zoom,
        "center": [55.75, 37.61],
        "layerGroups": layer_group_map,
        "layerStackOrder": layer_stack_order(groups),
        "currentUser": current_user_login,
        "selectedApproveId": str(selected_approve_id) if selected_approve_id else None,
        "initialCaseId": str(initial_case_id) if initial_case_id else None,
        "focusTaskGuid": str(focus_task_guid) if focus_task_guid else None,
        "approves": approve_options,
        "adjacentRoots": adjacent_roots or {"n_roots": [], "v_roots": []},
        "mapLayerLoadOrder": map_layer_load_order or [],
        "apiUrls": {
            "bootstrap": reverse("approval:api_bootstrap"),
            "mapLayer": reverse("approval:api_map_layer"),
            "caseDetail": "/approval/api/cases/{caseId}/",
            "postMessage": "/approval/api/cases/{caseId}/messages/",
            "approveCase": "/approval/api/cases/{caseId}/approve/",
            "revokeCase": "/approval/api/cases/{caseId}/revoke/",
            "changeCaseOwner": "/approval/api/cases/{caseId}/change-owner/",
            "addCaseParticipant": "/approval/api/cases/{caseId}/participants/",
            "createAdjacentEvent": "/approval/api/approves/{approveId}/adjacent-events/",
            "messageReaction": "/approval/api/messages/{messageId}/reactions/",
            "deleteMessage": "/approval/api/messages/{messageId}/",
            "deleteCase": "/approval/api/cases/{caseId}/",
            "attachment": "/approval/api/attachments/{attachmentId}/",
        },
        "layerStyleIconsBase": "/static/approval/icons/svg/",
    }

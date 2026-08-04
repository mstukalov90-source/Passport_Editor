"""Page bootstrap config for pass_viewer map templates (json_script)."""

from django.conf import settings
from django.urls import reverse


def _adjacent_nearby_meters_for_page():
    try:
        return float(getattr(settings, "GIS_ADJACENT_NEARBY_METERS", 25))
    except (TypeError, ValueError):
        return 25.0


def map_deferred_layer_specs():
    return [
        {"key": "adjacent_dt", "label": "Смежные паспорта ДТ"},
        {"key": "request_objects_dt", "label": "Заявки ДТ"},
        {"key": "request_objects_odh", "label": "Заявки ОДХ"},
        {"key": "request_objects_ozn", "label": "Заявки ОЗН"},
        {"key": "request_objects_top", "label": "Заявки ТОП"},
        {"key": "dgi_moscow_rent", "label": "З/У г. Москва с арендой"},
        {"key": "dgi_moscow_no_rent", "label": "З/У г. Москва без аренды"},
        {"key": "dgi_private_rent", "label": "З/У Частная или федеральная собственность с арендой"},
        {"key": "dgi_private_no_rent", "label": "З/У Частная или федеральная собственность без аренды"},
        {"key": "odh", "label": "ОДХ"},
        {"key": "ozn", "label": "ОЗН"},
        {"key": "renew", "label": "Реновация"},
        {"key": "recaps", "label": "Рекапы"},
        {"key": "oozt", "label": "ООЗТ"},
        {"key": "rzd", "label": "Полосы отвода ЖД"},
        {"key": "top", "label": "ТОП"},
    ]


def _editor_api_urls():
    return {
        "loadMapLayer": reverse("load_map_layer"),
        "loadMapAdjacentLayers": reverse("load_map_adjacent_layers"),
        "loadMapReferenceLayers": reverse("load_map_reference_layers"),
        "loadMapContextLayers": reverse("load_map_context_layers"),
        "checkRelations": reverse("check_new_object_relations"),
        "checkDgi": reverse("check_dgi_intersections"),
        "autoRemove": reverse("auto_remove_intersections"),
        "cutGeometry": reverse("cut_edited_geometry"),
        "saveNewObject": reverse("save_new_object"),
        "repairGeometry": reverse("repair_save_geometry"),
        "exportGeometry": reverse("export_new_object_geometry"),
        "listCommentPoints": reverse("list_comment_points"),
        "saveCommentPoint": reverse("save_comment_point"),
        "deleteCommentPoint": reverse("delete_comment_point"),
    }


def build_page_config(page, **extra):
    config = {"page": page, "urls": {}, "features": {}}
    if page in ("main", "add_object", "add_recap", "split"):
        config["urls"] = _editor_api_urls()
        config["adjacentNearbyMeters"] = _adjacent_nearby_meters_for_page()
    config.update(extra)
    return config


def home_page_config(*, need_entry_request_id, ods_source_label, owner_id=None):
    return build_page_config(
        "home",
        urls={
            "cancelPending": reverse("cancel_pending_entry"),
            "addRecap": reverse("add_recap"),
            "listOwnedRecaps": reverse("list_owned_recaps"),
            "exportRecap": reverse("export_recap_geometry"),
            "deleteRecap": reverse("delete_recap_object"),
            "checkDgi": reverse("check_dgi_intersections"),
            "resolveAsuOdsUrl": reverse("resolve_asu_ods_url"),
            "openOwned": reverse("open_owned_object"),
        },
        needEntryRequestId=bool(need_entry_request_id),
        odsSourceLabel=ods_source_label or "ОДС",
        ownerId=str(owner_id) if owner_id is not None else "",
        features={
            "workflowModal": bool(getattr(settings, "HOME_WORKFLOW_MODAL_ENABLED", False)),
        },
    )


def add_object_page_config(*, effective_request_id="", selected_rootid="", selected_source_label="ДТ"):
    return build_page_config(
        "add_object",
        defaultZoom=12,
        effectiveRequestId=effective_request_id or "",
        selectedRootid=selected_rootid or "",
        selectedSourceLabel=selected_source_label or "ДТ",
        features={"pdf": True, "selectedGeometry": False},
    )


def main_page_config(
    *,
    selected_rootid="",
    selected_name="",
    selected_request_id="",
    selected_ctid="",
    effective_request_id="",
    selected_customer_legal_person_id="",
    selected_department_legal_person_id="",
    selected_customer_legal_person_name="",
    selected_department_legal_person_name="",
    selected_startdate="",
    selected_datesurvey="",
    selected_createtype="",
    selected_source_label="ДТ",
    view_only=False,
):
    return build_page_config(
        "main",
        defaultZoom=10,
        selectedRootid=selected_rootid or "",
        selectedName=selected_name or "",
        selectedRequestId=selected_request_id or "",
        selectedRowCtid=selected_ctid or "",
        effectiveRequestId=effective_request_id or "",
        selectedCustomerLegalPersonId=selected_customer_legal_person_id or "",
        selectedDepartmentLegalPersonId=selected_department_legal_person_id or "",
        selectedCustomerLegalPersonName=selected_customer_legal_person_name or "",
        selectedDepartmentLegalPersonName=selected_department_legal_person_name or "",
        selectedStartdate=selected_startdate or "",
        selectedDatesurvey=selected_datesurvey or "",
        selectedCreatetype=selected_createtype or "",
        selectedSourceLabel=selected_source_label or "ДТ",
        features={
            "pdf": True,
            "selectedGeometry": True,
            "deferredMapContextLayers": bool(view_only) or _defer_map_context_layers_for_page(),
            "viewOnly": bool(view_only),
        },
        mapLayerLoadOrder=map_deferred_layer_specs(),
    )


def _defer_map_context_layers_for_page():
    return str(getattr(settings, "GIS_DEFER_MAP_CONTEXT_LAYERS", "1")).lower() not in (
        "0",
        "false",
        "no",
    )


def add_recap_page_config(
    *,
    request_id="",
    name="",
    selected_source_label="ДТ",
    selected_rootid="",
    selected_row_ctid="",
    initial_recap_id="",
):
    urls = _editor_api_urls()
    urls["saveRecap"] = reverse("save_recap_object")
    return build_page_config(
        "add_recap",
        urls=urls,
        defaultZoom=10,
        requestId=request_id or "",
        objectName=name or "",
        selectedSourceLabel=selected_source_label or "ДТ",
        selectedRootid=selected_rootid or "",
        selectedRowCtid=selected_row_ctid or "",
        initialRecapId=initial_recap_id or "",
        features={"pdf": False, "selectedGeometry": True},
    )


def split_object_page_config(
    *,
    selected_name="",
    selected_request_id="",
    selected_source_label="ДТ",
):
    return build_page_config(
        "split",
        selectedName=selected_name or "",
        selectedRequestId=selected_request_id or "",
        selectedSourceLabel=selected_source_label or "ДТ",
        defaultZoom=10,
        features={"pdf": False},
    )

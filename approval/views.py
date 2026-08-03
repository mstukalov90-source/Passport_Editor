from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.shortcuts import render
from django.views.decorators.http import require_POST

from .access import get_accessible_approve, get_accessible_approves, get_owner_id_for_username
from .map_load import build_map_layer_load_order, resolve_map_layer_features
from .page_config import landing_page_config
from .qml_style_builder import load_manifest, load_svg_index
from .work_adjacent import (
    collect_adjacent_roots,
    count_adjacent_features_by_source,
    format_adjacent_roots_message,
)
from .work_layers import (
    build_adjacent_layer_groups,
    build_layer_groups,
    build_reference_layer_groups,
    build_topopassport_layer_groups,
    count_features_by_table,
    count_topopassport_features_by_table,
    resolve_task_survey_title,
)

import json
import uuid


@login_required
def landing(request):
    username = request.user.username
    owner_id = get_owner_id_for_username(username)
    approves = list(get_accessible_approves(owner_id, username=username))

    map_message = None
    map_error = None

    if not approves:
        if not owner_id:
            map_message = "Нет доступных согласований для вашего пользователя."
        else:
            map_message = "Нет доступных согласований для вашей организации."

    selected_approve_id = request.GET.get("approve")
    selected_approve = None
    if selected_approve_id:
        selected_approve = next((item for item in approves if str(item.id) == selected_approve_id), None)
    if selected_approve is None and approves:
        selected_approve = approves[0]

    map_task_guids = (
        [str(selected_approve.incoming_guid)]
        if selected_approve is not None
        else []
    )

    feature_counts = count_features_by_table(map_task_guids) if map_task_guids else {}
    topo_counts = count_topopassport_features_by_table(map_task_guids) if map_task_guids else {}
    layer_groups = build_layer_groups(feature_counts)
    if topo_counts:
        layer_groups = layer_groups + build_topopassport_layer_groups(topo_counts)

    adjacent_n_count = 0
    adjacent_v_count = 0
    adjacent_n_roots: list[str] = []
    adjacent_v_roots: list[str] = []
    if selected_approve is not None:
        adjacent_n_roots, adjacent_v_roots = collect_adjacent_roots(selected_approve)
        adjacent_counts = count_adjacent_features_by_source(
            adjacent_n_roots,
            adjacent_v_roots,
        )
        adjacent_n_count = sum(int(bucket.get("n", 0) or 0) for bucket in adjacent_counts.values())
        adjacent_v_count = sum(int(bucket.get("v", 0) or 0) for bucket in adjacent_counts.values())
        adjacent_groups = build_adjacent_layer_groups(adjacent_counts)
        if adjacent_groups:
            layer_groups = layer_groups + adjacent_groups
        # Reference layers always listed when an approve is selected (counts fill in as they load).
        layer_groups = layer_groups + build_reference_layer_groups()

        if (adjacent_n_roots or adjacent_v_roots) and adjacent_n_count == 0 and adjacent_v_count == 0:
            map_message = map_message or format_adjacent_roots_message(
                adjacent_n_roots,
                adjacent_v_roots,
            )

    if map_task_guids and not feature_counts and not topo_counts and not adjacent_n_count and not adjacent_v_count:
        map_message = map_message or "Для согласования не найдено объектов в схемах work/topopassport."

    map_layer_load_order = (
        build_map_layer_load_order(
            work_counts=feature_counts,
            topo_counts=topo_counts,
            has_adjacent=bool(adjacent_n_count or adjacent_v_count),
            include_reference=selected_approve is not None,
        )
        if selected_approve is not None
        else []
    )

    # GeoJSON loads progressively via api_map_layer.
    map_geojson = {"type": "FeatureCollection", "features": []}

    page_title = "Согласование границ ОГХ"
    if selected_approve is not None:
        page_title = resolve_task_survey_title(selected_approve.incoming_guid)

    return render(
        request,
        "approval/landing.html",
        {
            "page_config": landing_page_config(
                layer_groups=layer_groups,
                approves=approves,
                selected_approve_id=selected_approve.id if selected_approve else None,
                focus_task_guid=selected_approve.incoming_guid if selected_approve else None,
                current_user_login=request.user.username,
                adjacent_roots={
                    "n_roots": adjacent_n_roots,
                    "v_roots": adjacent_v_roots,
                }
                if selected_approve is not None
                else None,
                map_layer_load_order=map_layer_load_order,
            ),
            "layer_groups": layer_groups,
            "map_geojson": map_geojson,
            "work_layer_styles": load_manifest(),
            "svg_index": load_svg_index(),
            "map_message": map_message,
            "map_error": map_error,
            "page_title": page_title,
        },
    )


@login_required
@require_POST
def api_map_layer(request):
    username = (request.user.username or "").strip()
    owner_id = get_owner_id_for_username(username)

    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    if not isinstance(payload, dict):
        return JsonResponse({"ok": False, "error": "Некорректный JSON."}, status=400)

    layer_key = str(payload.get("layer") or "").strip()
    if not layer_key:
        return JsonResponse({"ok": False, "error": "Не указан слой."}, status=400)

    approve_id_raw = payload.get("approve_id")
    if not approve_id_raw:
        return JsonResponse({"ok": False, "error": "Не указан approve_id."}, status=400)
    try:
        approve_id = uuid.UUID(str(approve_id_raw))
    except (TypeError, ValueError):
        return JsonResponse({"ok": False, "error": "Некорректный approve_id."}, status=400)

    approve = get_accessible_approve(approve_id, owner_id, username=username)
    if approve is None:
        return JsonResponse({"ok": False, "error": "Согласование не найдено или недоступно."}, status=404)

    features, error = resolve_map_layer_features(approve, layer_key)
    if error and (
        error.startswith("Неизвест")
        or error.startswith("Некоррект")
        or error.startswith("Не указан")
    ):
        return JsonResponse({"ok": False, "error": error}, status=400)

    response = {
        "ok": True,
        "layer": layer_key,
        "features": features,
    }
    if error:
        response["warning"] = error
    return JsonResponse(response)

from django.contrib.auth.decorators import login_required
from django.shortcuts import render

from .access import get_accessible_approves, get_owner_id_for_username
from .page_config import landing_page_config
from .qml_style_builder import load_manifest, load_svg_index
from .work_adjacent import (
    build_adjacent_features,
    collect_adjacent_roots,
    count_adjacent_features,
    format_adjacent_roots_message,
)
from .work_geojson import build_work_feature_collection
from .work_layers import build_adjacent_layer_groups, build_layer_groups, count_features_by_table


@login_required
def landing(request):
    username = request.user.username
    owner_id = get_owner_id_for_username(username)
    approves = list(get_accessible_approves(owner_id, username=username))
    task_guids = [str(approve.incoming_guid) for approve in approves]

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
        else task_guids
    )

    feature_counts = count_features_by_table(map_task_guids) if map_task_guids else {}
    layer_groups = build_layer_groups(feature_counts)

    adjacent_n_count = 0
    adjacent_v_count = 0
    adjacent_n_roots: list[str] = []
    adjacent_v_roots: list[str] = []
    if selected_approve is not None:
        adjacent_n_roots, adjacent_v_roots = collect_adjacent_roots(selected_approve)
        adjacent_n_count, adjacent_v_count = count_adjacent_features(
            adjacent_n_roots,
            adjacent_v_roots,
        )
        adjacent_groups = build_adjacent_layer_groups(adjacent_n_count, adjacent_v_count)
        if adjacent_groups:
            layer_groups = layer_groups + adjacent_groups

    map_geojson, load_error = build_work_feature_collection(
        map_task_guids,
        tables=list(feature_counts.keys()) or None,
    )
    if selected_approve is not None:
        adjacent_features, adjacent_error = build_adjacent_features(
            adjacent_n_roots,
            adjacent_v_roots,
        )
        if adjacent_features:
            map_geojson.setdefault("features", []).extend(adjacent_features)
        if adjacent_error:
            map_error = adjacent_error
        elif (adjacent_n_roots or adjacent_v_roots) and not adjacent_features:
            if adjacent_n_count == 0 and adjacent_v_count == 0:
                map_message = map_message or format_adjacent_roots_message(
                    adjacent_n_roots,
                    adjacent_v_roots,
                )
    if load_error:
        map_error = load_error
    elif map_task_guids and not feature_counts and not adjacent_n_count and not adjacent_v_count:
        map_message = map_message or "Для согласования не найдено объектов в схеме work."

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
            ),
            "layer_groups": layer_groups,
            "map_geojson": map_geojson,
            "work_layer_styles": load_manifest(),
            "svg_index": load_svg_index(),
            "map_message": map_message,
            "map_error": map_error,
        },
    )

from django.contrib.auth.decorators import login_required
from django.shortcuts import render

from .access import get_accessible_approves, get_owner_id_for_username
from .qml_style_builder import load_manifest, load_svg_index
from .page_config import landing_page_config
from .work_adjacent import build_adjacent_features, count_adjacent_features
from .work_geojson import build_work_feature_collection
from .work_layers import build_adjacent_layer_groups, build_layer_groups, count_features_by_table


@login_required
def landing(request):
    owner_id = get_owner_id_for_username(request.user.username)
    approves = list(get_accessible_approves(owner_id))
    task_guids = [str(approve.incoming_guid) for approve in approves]

    map_message = None
    map_error = None

    if not owner_id:
        map_message = "Не найден OwnerLegalPersonId для пользователя."
    elif not approves:
        map_message = "Нет доступных согласований для вашей организации."

    selected_approve_id = request.GET.get("approve")
    selected_approve = None
    if selected_approve_id:
        selected_approve = next((item for item in approves if str(item.id) == selected_approve_id), None)
    if selected_approve is None and approves:
        selected_approve = approves[0]

    feature_counts = count_features_by_table(task_guids) if task_guids else {}
    layer_groups = build_layer_groups(feature_counts)

    adjacent_n_count = 0
    adjacent_v_count = 0
    if selected_approve is not None:
        adjacent_n_count, adjacent_v_count = count_adjacent_features(
            selected_approve.n_root,
            selected_approve.v_root,
        )
        adjacent_groups = build_adjacent_layer_groups(adjacent_n_count, adjacent_v_count)
        if adjacent_groups:
            layer_groups = layer_groups + adjacent_groups

    map_geojson, load_error = build_work_feature_collection(
        task_guids,
        tables=list(feature_counts.keys()) or None,
    )
    if selected_approve is not None:
        adjacent_features = build_adjacent_features(
            selected_approve.n_root,
            selected_approve.v_root,
        )
        if adjacent_features:
            map_geojson.setdefault("features", []).extend(adjacent_features)
    if load_error:
        map_error = load_error
    elif task_guids and not feature_counts and not adjacent_n_count and not adjacent_v_count:
        map_message = map_message or "Для согласования не найдено объектов в схеме work."

    return render(
        request,
        "approval/landing.html",
        {
            "page_config": landing_page_config(
                layer_groups=layer_groups,
                approves=approves,
                selected_approve_id=selected_approve.id if selected_approve else None,
                current_user_login=request.user.username,
            ),
            "layer_groups": layer_groups,
            "map_geojson": map_geojson,
            "work_layer_styles": load_manifest(),
            "svg_index": load_svg_index(),
            "map_message": map_message,
            "map_error": map_error,
        },
    )

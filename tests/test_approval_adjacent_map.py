"""Tests for adjacent passport layers on the approval map."""

from __future__ import annotations

import uuid
from unittest.mock import MagicMock, patch

import pytest
from approval.models import Approve, Case
from approval.views import landing
from approval.work_adjacent import (
    LAYER_KEY_APPROVAL,
    LAYER_KEY_OBJECTS,
    _adjacent_select_sql,
    adjacent_root_ids,
    build_adjacent_features,
    collect_adjacent_roots,
    count_adjacent_features,
    format_adjacent_roots_message,
)
from approval.work_layers import build_adjacent_layer_groups
from django.http import HttpResponse
from django.test import RequestFactory
from pass_viewer.models import ExternalUser


def test_adjacent_root_ids_excludes_n_root_from_v_root():
    n_values, v_values = adjacent_root_ids(["09811"], ["10482", "09811"])
    assert n_values == ["09811"]
    assert v_values == ["10482"]


def test_adjacent_root_ids_accepts_string_legacy():
    n_values, v_values = adjacent_root_ids("09811", ["10482", "09811"])
    assert n_values == ["09811"]
    assert v_values == ["10482"]


def test_adjacent_root_ids_empty_when_no_values():
    assert adjacent_root_ids(None, None) == ([], [])
    assert adjacent_root_ids("  ", ["", "  "]) == ([], [])


def test_build_adjacent_layer_groups_names_and_counts():
    groups = build_adjacent_layer_groups(2, 3)
    assert len(groups) == 1
    assert groups[0]["key"] == "adjacent"
    assert groups[0]["title"] == "Смежные паспорта"
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert layers["adjacent_approval"]["name"] == "Смежный объект для согласования"
    assert layers["adjacent_approval"]["count"] == 2
    assert layers["adjacent_objects"]["name"] == "Смежные объекты"
    assert layers["adjacent_objects"]["count"] == 3


def test_build_adjacent_layer_groups_skips_zero_counts():
    assert build_adjacent_layer_groups(0, 0) == []
    groups = build_adjacent_layer_groups(1, 0)
    assert len(groups[0]["layers"]) == 1
    assert groups[0]["layers"][0]["key"] == "adjacent_approval"


@patch("approval.work_adjacent.connections")
def test_count_adjacent_features(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    # found roots in work (3 tables) then counts for n_work/v_work across 3 tables each
    cursor.fetchall.side_effect = [
        [("09811",), ("10482",)],
        [],
        [],
    ]
    cursor.fetchone.side_effect = [(1,), (2,), (0,), (1,), (0,), (0,)]

    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        n_count, v_count = count_adjacent_features("09811", ["10482", "09811"])

    assert n_count == 3
    assert v_count == 1


@patch("approval.work_adjacent.connections")
def test_build_adjacent_features_prefers_work_then_master(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    feature_work = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "YardPoly",
            "fid": 1,
            "RootId": "09811",
        },
    }
    feature_master = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "YardPoly",
            "fid": 2,
            "RootId": "10482",
        },
    }
    # found in work: only 09811
    # work features for 09811 across 3 tables
    # master features for 10482 across 3 tables
    cursor.fetchall.side_effect = [
        [("09811",)],
        [],
        [],
        [(feature_work,)],
        [],
        [],
        [(feature_master,)],
        [],
        [],
    ]

    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        with patch("approval.work_adjacent._adjacent_select_sql", return_value="SELECT 1"):
            with patch("approval.work_adjacent._style_fields_for_table", return_value=[]):
                features, error = build_adjacent_features(["09811"], ["10482"])

    assert error is None
    assert len(features) == 2
    by_root = {feature["properties"]["RootId"]: feature["properties"] for feature in features}
    assert by_root["09811"]["adjacentRootKind"] == "n"
    assert by_root["09811"]["sourceSchema"] == "work"
    assert by_root["10482"]["adjacentRootKind"] == "v"
    assert by_root["10482"]["sourceSchema"] == "master"


@patch("approval.work_adjacent.connections")
def test_build_adjacent_features_assigns_layer_keys(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    feature_n = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "YardPoly",
            "fid": 1,
            "RootId": "09811",
        },
    }
    feature_v = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "YardPoly",
            "fid": 2,
            "RootId": "10482",
        },
    }
    cursor.fetchall.side_effect = [
        [("09811",), ("10482",)],
        [],
        [],
        [(feature_n,), (feature_v,)],
        [],
        [],
    ]

    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        with patch("approval.work_adjacent._adjacent_select_sql", return_value="SELECT 1"):
            with patch("approval.work_adjacent._style_fields_for_table", return_value=[]):
                features, error = build_adjacent_features(["09811"], ["10482", "09811"])

    assert error is None
    assert len(features) == 2
    by_root = {feature["properties"]["RootId"]: feature["properties"] for feature in features}
    assert by_root["09811"]["adjacentRootKind"] == "n"
    assert by_root["09811"]["layerKey"] == LAYER_KEY_APPROVAL
    assert by_root["10482"]["adjacentRootKind"] == "v"
    assert by_root["10482"]["layerKey"] == LAYER_KEY_OBJECTS


@patch("approval.work_adjacent.connections")
def test_build_adjacent_features_active_case_moves_single_n_root(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    feature_a = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "YardPoly",
            "fid": 1,
            "RootId": "10001",
        },
    }
    feature_b = {
        "type": "Feature",
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "layerKey": LAYER_KEY_OBJECTS,
            "sourceTable": "YardPoly",
            "fid": 2,
            "RootId": "10002",
        },
    }
    cursor.fetchall.side_effect = [
        [("10001",), ("10002",)],
        [],
        [],
        [(feature_a,), (feature_b,)],
        [],
        [],
    ]

    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        with patch("approval.work_adjacent._adjacent_select_sql", return_value="SELECT 1"):
            with patch("approval.work_adjacent._style_fields_for_table", return_value=[]):
                features, error = build_adjacent_features(
                    ["10001", "10002"],
                    [],
                    active_n_root="10002",
                )

    assert error is None
    by_root = {feature["properties"]["RootId"]: feature["properties"] for feature in features}
    assert by_root["10001"]["layerKey"] == LAYER_KEY_OBJECTS
    assert by_root["10002"]["layerKey"] == LAYER_KEY_APPROVAL


@pytest.mark.django_db
def test_collect_adjacent_roots_merges_case_n_roots():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
        n_root=[],
        v_root=["10482", "20001"],
    )
    Case.objects.create(
        approve=approve,
        is_primary=False,
        title="Событие A",
        n_root="10001260",
        owners=["10233594", "9000022"],
    )
    Case.objects.create(
        approve=approve,
        is_primary=False,
        title="Событие B",
        n_root="12345148",
        owners=["10233594", "9000022"],
    )

    n_roots, v_roots = collect_adjacent_roots(approve)

    assert n_roots == ["10001260", "12345148"]
    assert v_roots == ["10482", "20001"]


@pytest.mark.django_db
def test_collect_adjacent_roots_deduplicates_approve_and_case_n_roots():
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
        n_root=["09811"],
        v_root=["10482", "09811"],
    )
    Case.objects.create(
        approve=approve,
        is_primary=False,
        title="Событие",
        n_root="09811",
        owners=["10233594", "9000022"],
    )

    n_roots, v_roots = collect_adjacent_roots(approve)

    assert n_roots == ["09811"]
    assert v_roots == ["10482"]


@pytest.mark.django_db
def test_landing_with_case_only_n_roots():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="case_roots_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(
        incoming_guid=incoming_guid,
        owners=[owner_id],
        n_root=[],
        v_root=["10482"],
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])
    Case.objects.create(
        approve=approve,
        is_primary=False,
        title="Событие",
        n_root="09811",
        owners=[owner_id, "9000022"],
    )

    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="case_roots_user")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(1, 1)):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            response = landing(request)

    assert response.status_code == 200
    page_config = mock_render.call_args[0][2]["page_config"]
    assert page_config["adjacentRoots"]["n_roots"] == ["09811"]
    assert page_config["adjacentRoots"]["v_roots"] == ["10482"]
    assert any(spec["key"] == "adjacent" for spec in page_config["mapLayerLoadOrder"])


@pytest.mark.django_db
def test_landing_with_adjacent_layers():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="adjacent_map_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(
        incoming_guid=incoming_guid,
        owners=[owner_id],
        n_root=["09811"],
        v_root=["10482", "09811"],
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="adjacent_map_user")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(1, 1)):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    layer_groups = context["layer_groups"]
    assert any(
        layer["name"] == "Смежный объект для согласования"
        for group in layer_groups
        for layer in group["layers"]
    )
    assert any(
        layer["name"] == "Смежные объекты"
        for group in layer_groups
        for layer in group["layers"]
    )
    assert context["map_geojson"]["features"] == []
    assert any(spec["key"] == "adjacent" for spec in context["page_config"]["mapLayerLoadOrder"])


@pytest.mark.django_db
def test_landing_without_owner_shows_message_unchanged():
    ExternalUser.objects.create(login="no_owner_adjacent", password="x", owner_legal_person_id=None)
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="no_owner_adjacent")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        response = landing(request)

    assert response.status_code == 200
    assert "Нет доступных согласований" in mock_render.call_args[0][2]["map_message"]


@patch("approval.work_adjacent.connections")
def test_build_adjacent_features_returns_error_on_qgis_failure(mock_connections):
    mock_connections.__getitem__.side_effect = RuntimeError("qgis unavailable")

    features, error = build_adjacent_features(["09811"], ["10482"])

    assert features == []
    assert error == "Не удалось загрузить смежные паспорта из mggt_asu."


def test_format_adjacent_roots_message_lists_unique_roots():
    message = format_adjacent_roots_message(["09811", "10001"], ["10482"])
    assert "09811" in message
    assert "10001" in message
    assert "10482" in message
    assert "work/master" in message
    assert "YardPoly/OznPoly/OdhPoly" in message


def test_adjacent_select_sql_uses_master_schema_by_default():
    cursor = MagicMock()
    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        with patch("approval.work_adjacent._column_exists", return_value=False):
            sql = _adjacent_select_sql(
                "YardPoly",
                LAYER_KEY_OBJECTS,
                [],
                cursor,
                single_root=False,
            )
    assert sql is not None
    assert '"master"."YardPoly"' in sql


def test_adjacent_select_sql_accepts_work_schema():
    cursor = MagicMock()
    with patch("approval.work_adjacent._resolve_rootid_column", return_value="RootId"):
        with patch("approval.work_adjacent._column_exists", return_value=False):
            sql = _adjacent_select_sql(
                "YardPoly",
                LAYER_KEY_OBJECTS,
                [],
                cursor,
                single_root=False,
                schema="work",
            )
    assert sql is not None
    assert '"work"."YardPoly"' in sql


@pytest.mark.django_db
def test_landing_scopes_work_to_selected_approve():
    inspector_login = "inspector_scope"
    ExternalUser.objects.create(login=inspector_login, password="pass", owner_legal_person_id=None)
    guid_a = uuid.uuid4()
    guid_b = uuid.uuid4()
    approve_a = Approve.objects.create(
        incoming_guid=guid_a,
        owners=["OWNER_A"],
        user=inspector_login,
        name="Согласование A",
    )
    approve_b = Approve.objects.create(
        incoming_guid=guid_b,
        owners=["OWNER_B"],
        user=inspector_login,
        name="Согласование B",
        n_root=["09811"],
        v_root=["10482"],
    )
    approve_a.cases.get(is_primary=True).owners = ["OWNER_A"]
    approve_a.cases.get(is_primary=True).save(update_fields=["owners", "updated_at"])
    approve_b.cases.get(is_primary=True).owners = ["OWNER_B"]
    approve_b.cases.get(is_primary=True).save(update_fields=["owners", "updated_at"])

    request = RequestFactory().get("/approval/", {"approve": str(approve_b.id)})
    request.user = MagicMock(is_authenticated=True, username=inspector_login)

    with patch("approval.views.count_features_by_table", return_value={}) as mock_counts:
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            response = landing(request)

    assert response.status_code == 200
    mock_counts.assert_called_once_with([str(guid_b)])
    context = mock_render.call_args[0][2]
    assert context["map_geojson"]["features"] == []


@pytest.mark.django_db
def test_landing_inspector_adjacent_roots_from_cases():
    inspector_login = "inspector_adjacent_roots"
    ExternalUser.objects.create(login=inspector_login, password="pass", owner_legal_person_id=None)
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["OWNER_A", "OWNER_B"],
        user=inspector_login,
        n_root=[],
        v_root=["10482"],
    )
    approve.cases.get(is_primary=True).owners = ["OWNER_A"]
    approve.cases.get(is_primary=True).save(update_fields=["owners", "updated_at"])
    Case.objects.create(
        approve=approve,
        is_primary=False,
        title="Событие",
        n_root="09811",
        owners=["OWNER_A", "OWNER_B"],
    )

    request = RequestFactory().get("/approval/", {"approve": str(approve.id)})
    request.user = MagicMock(is_authenticated=True, username=inspector_login)

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(1, 1)):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            response = landing(request)

    assert response.status_code == 200
    page_config = mock_render.call_args[0][2]["page_config"]
    assert page_config["adjacentRoots"]["n_roots"] == ["09811"]
    assert page_config["adjacentRoots"]["v_roots"] == ["10482"]


@pytest.mark.django_db
def test_landing_adjacent_message_when_roots_but_no_features():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="adjacent_msg_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(
        incoming_guid=incoming_guid,
        owners=[owner_id],
        n_root=["09811"],
        v_root=["10482"],
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="adjacent_msg_user")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            response = landing(request)

    assert response.status_code == 200
    map_message = mock_render.call_args[0][2]["map_message"]
    assert "Смежные паспорта не найдены" in map_message
    assert "09811" in map_message
    assert "10482" in map_message

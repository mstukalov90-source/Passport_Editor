"""Tests for approval map data loading."""

from __future__ import annotations

import uuid
from unittest.mock import MagicMock, patch

import pytest
from approval.access import get_accessible_approves, get_owner_id_for_username
from approval.models import Approve
from approval.views import landing
from approval.page_config import landing_page_config
from approval.work_layers import build_layer_groups, count_features_by_table, layer_stack_order
from django.http import HttpResponse
from django.test import RequestFactory
from django.urls import reverse
from pass_viewer.models import ExternalUser


@pytest.mark.django_db
def test_get_owner_id_for_username():
    ExternalUser.objects.create(login="owner_user", password="x", owner_legal_person_id="10233594")
    assert get_owner_id_for_username("owner_user") == "10233594"
    assert get_owner_id_for_username("missing") is None


@pytest.mark.django_db
def test_get_accessible_approves_filters_by_owner():
    guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    approve = Approve.objects.create(incoming_guid=guid, owners=["10233594"])
    primary = approve.cases.get(is_primary=True)
    primary.owners = ["10233594"]
    primary.save(update_fields=["owners", "updated_at"])
    Approve.objects.create(incoming_guid=uuid.uuid4(), owners=["99999999"])

    qs = get_accessible_approves("10233594")
    assert qs.count() == 1
    assert qs.first().incoming_guid == guid


def test_build_layer_groups_skips_zero_counts():
    groups = build_layer_groups({"DtsPoly": 12, "OznPoly": 0})
    assert len(groups) == 1
    assert groups[0]["key"] == "work"
    assert [layer["key"] for layer in groups[0]["layers"]] == ["DtsPoly"]


def test_build_layer_groups_uses_russian_labels_and_geometry():
    groups = build_layer_groups({"DtsPoly": 3})
    layer = groups[0]["layers"][0]
    assert layer["name"] == "Дорожно-тропиночная сеть"
    assert layer["geometry"] == "polygon"
    assert groups[0]["title"] == "Объект согласования"


def test_build_layer_groups_tracks_geometry_for_line_layers():
    groups = build_layer_groups({"AbutmentLine": 2})
    layer = groups[0]["layers"][0]
    assert layer["geometry"] == "line"


def test_build_layer_groups_hides_task_and_yardpoly_by_default():
    groups = build_layer_groups({"task": 2, "YardPoly": 4, "DtsPoly": 1})
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert layers["task"]["checked"] is False
    assert layers["YardPoly"]["checked"] is False
    assert layers["DtsPoly"]["checked"] is True


def test_build_layer_groups_empty():
    assert build_layer_groups({}) == []


def test_build_layer_groups_orders_by_geometry():
    groups = build_layer_groups(
        {
            "DtsPoly": 1,
            "AbutmentLine": 2,
            "PhotoFixPoint": 3,
            "OdhPoly": 4,
            "YardPoly": 5,
            "OznPoly": 6,
        }
    )
    keys = [layer["key"] for layer in groups[0]["layers"]]
    assert keys.index("PhotoFixPoint") < keys.index("AbutmentLine")
    assert keys.index("AbutmentLine") < keys.index("DtsPoly")
    assert keys.index("DtsPoly") < keys.index("OdhPoly")
    assert keys.index("DtsPoly") < keys.index("OznPoly")
    assert keys.index("DtsPoly") < keys.index("YardPoly")


def test_layer_stack_order_places_points_on_top():
    groups = build_layer_groups(
        {
            "DtsPoly": 1,
            "AbutmentLine": 2,
            "PhotoFixPoint": 3,
            "OdhPoly": 4,
        }
    )
    stack = layer_stack_order(groups)
    assert stack.index("OdhPoly") < stack.index("DtsPoly")
    assert stack.index("DtsPoly") < stack.index("AbutmentLine")
    assert stack.index("AbutmentLine") < stack.index("PhotoFixPoint")


def test_landing_page_config_includes_focus_task_guid():
    guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    groups = build_layer_groups({"DtsPoly": 1})
    config = landing_page_config(layer_groups=groups, focus_task_guid=guid)
    assert config["focusTaskGuid"] == str(guid)
    assert config["layerStackOrder"] == ["DtsPoly"]


@patch("approval.work_layers.connections")
def test_count_features_by_table(mock_connections):
    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor

    with patch(
        "approval.work_layers.list_work_layer_tables",
        return_value=["DtsPoly", "OznPoly"],
    ):
        cursor.fetchone.side_effect = [(3,), (0,)]
        counts = count_features_by_table(["2e333940-831b-48f5-9751-acd0c2880974"])

    assert counts == {"DtsPoly": 3}


@pytest.mark.django_db
def test_landing_without_owner_shows_message():
    ExternalUser.objects.create(login="no_owner", password="x", owner_legal_person_id=None)
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="no_owner")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    assert "Нет доступных согласований" in context["map_message"]
    assert context["map_geojson"]["type"] == "FeatureCollection"


@pytest.mark.django_db
def test_landing_inspector_without_owner_id_loads_approves():
    ExternalUser.objects.create(login="inspector_only", password="x", owner_legal_person_id=None)
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
        user="inspector_only",
    )
    request = RequestFactory().get("/approval/")
    request.user = MagicMock(is_authenticated=True, username="inspector_only")

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    assert context["map_message"] is None or "OwnerLegalPersonId" not in context["map_message"]


@pytest.mark.django_db
def test_landing_with_approve_and_mock_qgis_layers():
    owner_id = "10233594"
    incoming_guid = uuid.UUID("2e333940-831b-48f5-9751-acd0c2880974")
    ExternalUser.objects.create(login="approval_map_user", password="pass", owner_legal_person_id=owner_id)
    approve = Approve.objects.create(incoming_guid=incoming_guid, owners=[owner_id])
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=["owners", "updated_at"])

    with patch("approval.views.count_features_by_table", return_value={"DtsPoly": 1}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.load_manifest", return_value={"version": 1, "tables": {}}):
                    with patch("approval.views.load_svg_index", return_value={"marker.svg": "marker.svg"}):
                        with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                            request = RequestFactory().get("/approval/")
                            request.user = MagicMock(is_authenticated=True, username="approval_map_user")
                            response = landing(request)

    assert response.status_code == 200
    context = mock_render.call_args[0][2]
    layer_names = [layer["name"] for group in context["layer_groups"] for layer in group["layers"]]
    assert "Дорожно-тропиночная сеть" in layer_names
    assert context["map_geojson"]["features"] == []
    page_config = context["page_config"]
    assert page_config["mapLayerLoadOrder"][0]["key"] == "work:DtsPoly"
    assert any(spec["key"] == "dgi" for spec in page_config["mapLayerLoadOrder"])


@pytest.mark.django_db
def test_landing_without_matching_approve_shows_empty_message():
    ExternalUser.objects.create(login="other_owner", password="pass", owner_legal_person_id="11111111")
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=["10233594"],
    )

    with patch("approval.views.count_features_by_table", return_value={}):
        with patch("approval.views.count_topopassport_features_by_table", return_value={}):
            with patch("approval.views.count_adjacent_features", return_value=(0, 0)):
                with patch("approval.views.landing_page_config", return_value={}):
                    with patch("approval.views.render", return_value=HttpResponse("ok")) as mock_render:
                        request = RequestFactory().get("/approval/")
                        request.user = MagicMock(is_authenticated=True, username="other_owner")
                        response = landing(request)

    assert response.status_code == 200
    assert "Нет доступных согласований" in mock_render.call_args[0][2]["map_message"]


def test_build_topopassport_layer_groups_uses_prefixed_keys():
    from approval.work_layers import build_topopassport_layer_groups

    groups = build_topopassport_layer_groups({"DtsPoly": 2})
    assert groups[0]["key"] == "topopassport"
    assert groups[0]["layers"][0]["key"] == "topo:DtsPoly"


def test_build_topopassport_hides_topopoint_and_topotext_by_default():
    from approval.work_layers import build_topopassport_layer_groups

    groups = build_topopassport_layer_groups(
        {"topolines": 10, "topopoint": 5, "topotext": 3}
    )
    layers = {layer["key"]: layer for layer in groups[0]["layers"]}
    assert layers["topo:topolines"]["checked"] is True
    assert layers["topo:topopoint"]["checked"] is False
    assert layers["topo:topotext"]["checked"] is False


def test_build_map_layer_load_order():
    from approval.map_load import build_map_layer_load_order

    specs = build_map_layer_load_order(
        work_counts={"DtsPoly": 1},
        topo_counts={"YardPoly": 2},
        has_adjacent=True,
        include_reference=True,
    )
    keys = [item["key"] for item in specs]
    assert keys[0] == "work:DtsPoly"
    assert "topo:YardPoly" in keys
    assert "adjacent" in keys
    assert keys.index("work:DtsPoly") < keys.index("topo:YardPoly")
    assert keys.index("topo:YardPoly") < keys.index("adjacent")
    assert keys[-4:] == ["dgi", "oozt", "renew", "rzd"]


def test_schema_taskguid_column_uses_guid_for_topopassport():
    from approval.work_layers import schema_taskguid_column

    assert schema_taskguid_column("work") == "TaskGUID"
    assert schema_taskguid_column("topopassport") == "guid"


def test_topopassport_feature_select_sql_uses_guid_column():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    sql = _feature_select_sql(
        "SomePoly",
        [],
        cursor,
        schema="topopassport",
        layer_key="topo:SomePoly",
    )
    assert '"topopassport"."SomePoly"' in sql
    assert '"guid"' in sql
    assert "TaskGUID" not in sql


def test_work_feature_select_sql_still_uses_taskguid():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    sql = _feature_select_sql(
        "DtsPoly",
        [],
        cursor,
        schema="work",
        layer_key="DtsPoly",
    )
    assert '"work"."DtsPoly"' in sql
    assert '"TaskGUID"' in sql


def test_feature_select_sql_resolves_style_columns_case_insensitively():
    from unittest.mock import MagicMock

    from approval.work_geojson import _feature_select_sql

    cursor = MagicMock()
    cursor.fetchone.return_value = ("dtstype",)

    sql = _feature_select_sql(
        "DtsPoly",
        ["DtsType"],
        cursor,
        schema="topopassport",
        layer_key="topo:DtsPoly",
    )

    assert "'DtsType', t.\"dtstype\"::text" in sql
    query = cursor.execute.call_args[0][0]
    params = cursor.execute.call_args[0][1]
    assert "lower(column_name)" in query
    assert params == ["topopassport", "DtsPoly", "DtsType"]


def test_build_reference_layer_groups_unchecked_by_default():
    from approval.work_layers import build_reference_layer_groups

    groups = build_reference_layer_groups()
    assert len(groups) == 1
    assert groups[0]["key"] == "reference"
    assert groups[0]["checked"] is False
    assert all(layer["checked"] is False for layer in groups[0]["layers"])
    assert [layer["key"] for layer in groups[0]["layers"]] == ["dgi", "oozt", "renew", "rzd"]


@patch("approval.work_layers.connections")
def test_list_topopassport_tables_looks_for_guid_column(mock_connections):
    from approval.work_layers import list_schema_layer_tables

    cursor = MagicMock()
    mock_connections.__getitem__.return_value.cursor.return_value.__enter__.return_value = cursor
    cursor.fetchall.return_value = [("TopoPoly",)]

    tables = list_schema_layer_tables("topopassport", force_refresh=True)

    assert tables == ["TopoPoly"]
    sql = cursor.execute.call_args[0][0]
    params = cursor.execute.call_args[0][1]
    assert params[0] == "topopassport"
    assert params[1] == "guid"

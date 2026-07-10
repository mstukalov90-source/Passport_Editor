"""Tests for QGIS approval ingest API."""

from __future__ import annotations

import json
import uuid

import pytest
from approval.events_service import parse_geometry_payload
from approval.models import ApprovalGeometry, Approve, Case
from django.urls import reverse


@pytest.fixture(autouse=True)
def qgis_test_hosts(settings):
    settings.ALLOWED_HOSTS = [
        "172.21.197.77",
        "border-ogh.mggt.ru",
        "testserver",
        "localhost",
        "127.0.0.1",
    ]


INCOMING_GUID = "2e333940-831b-48f5-9751-acd0c2880974"

SAMPLE_GEOMETRY = {
    "type": "Polygon",
    "coordinates": [
        [
            [37.605, 55.748],
            [37.618, 55.748],
            [37.618, 55.756],
            [37.605, 55.756],
            [37.605, 55.748],
        ]
    ],
}

UPDATED_GEOMETRY = {
    "type": "Polygon",
    "coordinates": [
        [
            [37.61, 55.75],
            [37.62, 55.75],
            [37.62, 55.76],
            [37.61, 55.76],
            [37.61, 55.75],
        ]
    ],
}


def _valid_payload(**overrides):
    payload = {
        "incoming_guid": INCOMING_GUID,
        "n_root": ["09811"],
        "v_root": ["10482", "09811"],
        "name": "Согласование границ паспорта ДТ-10482",
        "owners": ["10233594", "10233595"],
        "geometry": SAMPLE_GEOMETRY,
    }
    payload.update(overrides)
    return payload


def _post_qgis_approve(client, payload, *, host="172.21.197.77"):
    return client.post(
        reverse("approval:api_qgis_upsert_approve"),
        data=json.dumps(payload),
        content_type="application/json",
        HTTP_HOST=host,
    )


@pytest.mark.django_db
def test_create_approve_from_qgis(client):
    response = _post_qgis_approve(client, _valid_payload())
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["created"] is True
    assert payload["incoming_guid"] == INCOMING_GUID

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.n_root == ["09811"]
    assert approve.v_root == ["10482", "09811"]
    assert approve.name == "Согласование границ паспорта ДТ-10482"
    assert approve.owners == ["10233594", "10233595"]

    primary = approve.cases.get(is_primary=True)
    assert primary.title == "Согласование границ паспорта ДТ-10482"
    assert primary.n_root == ["09811"]
    assert primary.owners == ["10233594", "10233595"]
    assert str(primary.id) == payload["primary_case_id"]

    geometry = ApprovalGeometry.objects.get(pk=payload["geometry_id"])
    assert geometry.approve_id == approve.id
    assert geometry.case_id == primary.id
    assert geometry.label == approve.name


@pytest.mark.django_db
def test_upsert_updates_fields(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200
    approve_id = create_response.json()["approve_id"]

    update_response = _post_qgis_approve(
        client,
        _valid_payload(
            name="Обновлённое согласование",
            owners=["10233594"],
            geometry=UPDATED_GEOMETRY,
        ),
    )
    assert update_response.status_code == 200
    payload = update_response.json()
    assert payload["ok"] is True
    assert payload["created"] is False
    assert payload["approve_id"] == approve_id

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.name == "Обновлённое согласование"
    assert approve.owners == ["10233594"]

    primary = approve.cases.get(is_primary=True)
    assert primary.title == "Обновлённое согласование"

    geometry = ApprovalGeometry.objects.get(pk=payload["geometry_id"])
    expected_geom = parse_geometry_payload(UPDATED_GEOMETRY)
    assert geometry.geom.equals_exact(expected_geom, tolerance=1e-9)


@pytest.mark.django_db
def test_upsert_rejected_when_approved(client):
    _post_qgis_approve(client, _valid_payload())
    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    approve.approved = True
    approve.save(update_fields=["approved"])

    response = _post_qgis_approve(
        client,
        _valid_payload(name="Попытка обновить согласованное"),
    )
    assert response.status_code == 409
    payload = response.json()
    assert payload["ok"] is False
    assert "согласовано" in payload["error"].lower()


@pytest.mark.django_db
@pytest.mark.parametrize(
    "payload_overrides,expected_error",
    [
        ({"incoming_guid": "not-a-uuid"}, "incoming_guid"),
        ({"owners": []}, "owners"),
        ({"n_root": []}, "n_root"),
        ({"v_root": ["10482"]}, "v_root"),
        ({"name": ""}, "name"),
        ({"geometry": None}, "geometry"),
    ],
)
def test_validation_errors(client, payload_overrides, expected_error):
    payload = _valid_payload(**payload_overrides)
    response = _post_qgis_approve(client, payload)
    assert response.status_code == 400
    payload_json = response.json()
    assert payload_json["ok"] is False
    assert expected_error in payload_json["error"].lower()


@pytest.mark.django_db
def test_rejects_public_host(client):
    response = _post_qgis_approve(client, _valid_payload(), host="border-ogh.mggt.ru")
    assert response.status_code == 403
    payload = response.json()
    assert payload["ok"] is False
    assert "внутреннему" in payload["error"].lower()


@pytest.mark.django_db
def test_primary_case_created_by_trigger(client):
    response = _post_qgis_approve(client, _valid_payload())
    assert response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    primary_cases = Case.objects.filter(approve=approve, is_primary=True)
    assert primary_cases.count() == 1

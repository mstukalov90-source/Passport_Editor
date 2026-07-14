"""Tests for QGIS approval ingest API."""

from __future__ import annotations

import json
import uuid
from unittest.mock import patch

import pytest
from approval.events_service import parse_geometry_payload, upsert_approve_from_qgis
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


@pytest.fixture(autouse=True)
def mock_task_owner():
    with patch(
        "approval.events_service.resolve_task_owner_legal_person_id",
        return_value="OWNER_TASK",
    ) as mocked:
        yield mocked


INCOMING_GUID = "956c45bb-dc44-46a7-9944-9d1996fec147"
TASK_OWNER = "OWNER_TASK"

EVENT_GEOMETRY_A = {
    "type": "Point",
    "coordinates": [37.618173936455285, 55.720464618162595],
}

EVENT_GEOMETRY_B = {
    "type": "Point",
    "coordinates": [37.61776133391202, 55.720827777176524],
}

UPDATED_GEOMETRY_A = {
    "type": "Point",
    "coordinates": [37.62, 55.721],
}


def _valid_payload(**overrides):
    payload = {
        "incoming_guid": INCOMING_GUID,
        "v_root": ["141564", "4066869", "1289566312"],
        "user": "asidorov",
        "brid": "46998",
        "name": "Согласование заявки из графика паспортизации 46998",
        "events": [
            {
                "n_root": "10001260",
                "owners": ["9000022"],
                "name": "Согласование заявок по паспортизации 46998 и паспорта 10001260",
                "geometry": EVENT_GEOMETRY_A,
            },
            {
                "n_root": "12345148",
                "owners": ["9000022"],
                "name": "Согласование заявок по паспортизации 46998 и паспорта 12345148",
                "geometry": EVENT_GEOMETRY_B,
            },
        ],
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
def test_create_approve_with_events(client):
    response = _post_qgis_approve(client, _valid_payload())
    assert response.status_code == 200
    payload = response.json()
    assert payload["ok"] is True
    assert payload["created"] is True
    assert payload["incoming_guid"] == INCOMING_GUID
    assert len(payload["events"]) == 2

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.v_root == ["141564", "4066869", "1289566312"]
    assert approve.user == "asidorov"
    assert approve.name == "Согласование заявки из графика паспортизации 46998"
    assert approve.n_root == ["10001260", "12345148"]
    assert approve.owners == [TASK_OWNER, "9000022"]

    primary = approve.cases.get(is_primary=True)
    assert primary.title == approve.name
    assert primary.n_root is None
    assert primary.owners == [TASK_OWNER]
    assert str(primary.id) == payload["primary_case_id"]
    assert not ApprovalGeometry.objects.filter(case=primary).exists()

    event_cases = Case.objects.filter(approve=approve, is_primary=False).order_by("n_root")
    assert event_cases.count() == 2
    assert list(event_cases.values_list("n_root", flat=True)) == ["10001260", "12345148"]
    for case in event_cases:
        assert case.owners == [TASK_OWNER, "9000022"]

    for event_payload, case in zip(payload["events"], event_cases, strict=True):
        assert event_payload["case_id"] == str(case.id)
        assert event_payload["created"] is True
        assert event_payload["skipped"] is False
        geometry = ApprovalGeometry.objects.get(pk=event_payload["geometry_id"])
        assert geometry.case_id == case.id
        assert geometry.approve_id == approve.id


@pytest.mark.django_db
def test_upsert_via_service_merges_task_owner_with_event_owner():
    result = upsert_approve_from_qgis(_valid_payload())
    assert result["created"] is True

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    event_case = approve.cases.get(is_primary=False, n_root="10001260")
    assert event_case.owners == [TASK_OWNER, "9000022"]


@pytest.mark.django_db
def test_aggregates_n_root_and_owners_on_approve(client):
    response = _post_qgis_approve(
        client,
        _valid_payload(
            events=[
                {
                    "n_root": "10001260",
                    "owners": ["9000022"],
                    "name": "Event A",
                    "geometry": EVENT_GEOMETRY_A,
                },
                {
                    "n_root": "12345148",
                    "owners": ["9000033"],
                    "name": "Event B",
                    "geometry": EVENT_GEOMETRY_B,
                },
            ]
        ),
    )
    assert response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.n_root == ["10001260", "12345148"]
    assert approve.owners == [TASK_OWNER, "9000022", "9000033"]


@pytest.mark.django_db
def test_upsert_updates_event_by_n_root(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200
    approve_id = create_response.json()["approve_id"]
    first_event_case_id = create_response.json()["events"][0]["case_id"]
    first_geometry_id = create_response.json()["events"][0]["geometry_id"]

    update_response = _post_qgis_approve(
        client,
        _valid_payload(
            name="Обновлённое согласование",
            events=[
                {
                    "n_root": "10001260",
                    "owners": ["9000099"],
                    "name": "Обновлённое событие",
                    "geometry": UPDATED_GEOMETRY_A,
                },
                {
                    "n_root": "12345148",
                    "owners": ["9000022"],
                    "name": "Согласование заявок по паспортизации 46998 и паспорта 12345148",
                    "geometry": EVENT_GEOMETRY_B,
                },
            ],
        ),
    )
    assert update_response.status_code == 200
    payload = update_response.json()
    assert payload["ok"] is True
    assert payload["created"] is False
    assert payload["approve_id"] == approve_id
    assert payload["events"][0]["case_id"] == first_event_case_id
    assert payload["events"][0]["geometry_id"] == first_geometry_id
    assert payload["events"][0]["created"] is False

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.name == "Обновлённое согласование"
    assert approve.owners == [TASK_OWNER, "9000099", "9000022"]

    updated_case = Case.objects.get(pk=first_event_case_id)
    assert updated_case.title == "Обновлённое событие"
    assert updated_case.owners == [TASK_OWNER, "9000099"]

    geometry = ApprovalGeometry.objects.get(pk=first_geometry_id)
    expected_geom = parse_geometry_payload(UPDATED_GEOMETRY_A)
    assert geometry.geom.equals_exact(expected_geom, tolerance=1e-9)


@pytest.mark.django_db
def test_upsert_does_not_delete_missing_events(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200

    update_response = _post_qgis_approve(
        client,
        _valid_payload(
            events=[
                {
                    "n_root": "99999999",
                    "owners": ["9000033"],
                    "name": "Новое событие",
                    "geometry": EVENT_GEOMETRY_A,
                }
            ]
        ),
    )
    assert update_response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert Case.objects.filter(approve=approve, is_primary=False).count() == 3
    assert Case.objects.filter(approve=approve, is_primary=False, n_root="99999999").exists()
    assert Case.objects.filter(approve=approve, is_primary=False, n_root="10001260").exists()


@pytest.mark.django_db
def test_upsert_skips_approved_event_case(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200
    case_id = create_response.json()["events"][0]["case_id"]

    case = Case.objects.get(pk=case_id)
    case.approved = True
    case.status = "согласовано"
    case.save(update_fields=["approved", "status"])

    update_response = _post_qgis_approve(
        client,
        _valid_payload(
            events=[
                {
                    "n_root": "10001260",
                    "owners": ["9000099"],
                    "name": "Попытка обновить согласованное событие",
                    "geometry": UPDATED_GEOMETRY_A,
                },
                {
                    "n_root": "12345148",
                    "owners": ["9000022"],
                    "name": "Согласование заявок по паспортизации 46998 и паспорта 12345148",
                    "geometry": EVENT_GEOMETRY_B,
                },
            ]
        ),
    )
    assert update_response.status_code == 200
    payload = update_response.json()
    assert payload["events"][0]["skipped"] is True

    case.refresh_from_db()
    assert case.title != "Попытка обновить согласованное событие"
    assert case.owners == [TASK_OWNER, "9000022"]


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
def test_upsert_rejected_when_different_user(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200

    response = _post_qgis_approve(
        client,
        _valid_payload(user="other_user", name="Попытка чужого upsert"),
    )
    assert response.status_code == 409
    payload = response.json()
    assert payload["ok"] is False
    assert "другим пользователем" in payload["error"].lower()

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.user == "asidorov"
    assert approve.name == "Согласование заявки из графика паспортизации 46998"


@pytest.mark.django_db
def test_create_approve_when_task_owner_matches_n_root_owner(client):
    response = _post_qgis_approve(
        client,
        _valid_payload(
            events=[
                {
                    "n_root": "10001260",
                    "owners": [TASK_OWNER],
                    "name": "Согласование с одним владельцем",
                    "geometry": EVENT_GEOMETRY_A,
                },
            ]
        ),
    )
    assert response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.owners == [TASK_OWNER]

    event_case = approve.cases.get(is_primary=False, n_root="10001260")
    assert event_case.owners == [TASK_OWNER]


@pytest.mark.django_db
@pytest.mark.parametrize(
    "payload_overrides,expected_error",
    [
        ({"incoming_guid": "not-a-uuid"}, "incoming_guid"),
        ({"events": []}, "events"),
        ({"user": ""}, "user"),
        ({"name": ""}, "name"),
        (
            {
                "events": [
                    {
                        "n_root": "10001260",
                        "owners": [],
                        "name": "Event",
                        "geometry": EVENT_GEOMETRY_A,
                    }
                ]
            },
            "owners",
        ),
        (
            {
                "events": [
                    {
                        "n_root": "10001260",
                        "owners": ["9000022", "9000033"],
                        "name": "Event",
                        "geometry": EVENT_GEOMETRY_A,
                    }
                ]
            },
            "двух",
        ),
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
def test_create_without_v_root(client):
    payload = _valid_payload()
    del payload["v_root"]

    response = _post_qgis_approve(client, payload)
    assert response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.v_root == []


@pytest.mark.django_db
def test_upsert_without_v_root_preserves_existing(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200

    payload = _valid_payload(name="Обновлённое согласование")
    del payload["v_root"]

    update_response = _post_qgis_approve(client, payload)
    assert update_response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    assert approve.v_root == ["141564", "4066869", "1289566312"]
    assert approve.name == "Обновлённое согласование"


@pytest.mark.django_db
def test_validation_v_root_three_elements(client):
    response = _post_qgis_approve(
        client,
        _valid_payload(v_root=["141564", "4066869", "1289566312"]),
    )
    assert response.status_code == 200


@pytest.mark.django_db
def test_validation_missing_owner_in_mggt(client, mock_task_owner):
    mock_task_owner.side_effect = ValueError("Не найден OwnerLegalPersonId для TaskGUID")

    response = _post_qgis_approve(client, _valid_payload())
    assert response.status_code == 400
    payload = response.json()
    assert payload["ok"] is False
    assert "ownerlegalpersonid" in payload["error"].lower()


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


@pytest.mark.django_db
def test_upsert_preserves_inspector_extra_owners_and_participant_logins(client):
    create_response = _post_qgis_approve(client, _valid_payload())
    assert create_response.status_code == 200

    approve = Approve.objects.get(incoming_guid=INCOMING_GUID)
    event_case = approve.cases.get(is_primary=False, n_root="10001260")
    event_case.owners = [TASK_OWNER, "9000022", "OWNER_EXTRA"]
    event_case.participant_logins = ["guest_login"]
    event_case.save(update_fields=["owners", "participant_logins", "updated_at"])

    update_response = _post_qgis_approve(client, _valid_payload())
    assert update_response.status_code == 200

    event_case.refresh_from_db()
    assert event_case.owners == [TASK_OWNER, "9000022", "OWNER_EXTRA"]
    assert event_case.participant_logins == ["guest_login"]

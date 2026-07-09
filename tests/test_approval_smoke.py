"""Smoke tests for approval (Согласование) landing."""

from __future__ import annotations

import uuid
from unittest.mock import patch

import pytest
from approval.models import Approve
from django.urls import reverse
from pass_viewer.models import ExternalUser


@pytest.mark.django_db
def test_anonymous_approval_landing_redirects_to_login(client):
    response = client.get(reverse('approval:landing'))
    assert response.status_code == 302
    assert '/accounts/login/' in response.url


@pytest.mark.django_db
def test_approval_landing_loads_for_authenticated_user(client, e2e_credentials):
    with patch('approval.views.count_features_by_table', return_value={}):
        with patch(
            'approval.views.build_work_feature_collection',
            return_value=({'type': 'FeatureCollection', 'features': []}, None),
        ):
            client.post(
                reverse('login'),
                {
                    'username': e2e_credentials['username'],
                    'password': e2e_credentials['password'],
                },
            )
            response = client.get(reverse('approval:landing'))
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert 'approval-map' in content
    assert 'Согласование' in content
    assert 'События' in content
    assert 'Чат события' in content
    assert 'Чаты дополнительных событий' in content
    assert 'Управление слоями' in content
    assert 'approval-map-geojson' in content
    assert 'approval-create-event-btn' in content


@pytest.mark.django_db
def test_home_shows_notifications_badge_and_approvals_tab(client):
    owner_id = 'HOME_APPROVAL_OWNER'
    ExternalUser.objects.create(login='home_owner', password='pass', owner_legal_person_id=owner_id)
    Approve.objects.create(incoming_guid=uuid.uuid4(), owners=[owner_id], approved=False)
    owned_stub = [{'rootid': 'abc', 'name': 'Объект', 'source_label': 'ДТ', 'request_id': ''}]
    with patch('pass_viewer.views._get_owned_objects', return_value=owned_stub):
        with patch('pass_viewer.views._merge_owned_ods_requests', side_effect=lambda items, _oid: items):
            with patch('pass_viewer.views._annotate_and_filter_ods_registry_against_gis', side_effect=lambda items: items):
                with patch('pass_viewer.views._enrich_ods_interaction_and_geometry', side_effect=lambda items: items):
                    with patch('pass_viewer.views._get_recap_counts_by_request_ids', return_value={}):
                        with patch(
                            'pass_viewer.views._build_owned_passports_geojson',
                            return_value={'type': 'FeatureCollection', 'features': []},
                        ):
                            with patch(
                                'pass_viewer.views.get_hood_allowed_districts_geojson',
                                return_value={'type': 'FeatureCollection', 'features': []},
                            ):
                                client.post(
                                    reverse('login'),
                                    {'username': 'home_owner', 'password': 'pass'},
                                )
                                response = client.get(reverse('home'))
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert 'Уведомления' in content
    assert 'approval-notifications-badge' in content
    assert 'data-owned-list-tab="approvals"' in content
    assert 'owned-approval-row' in content


@pytest.mark.django_db
def test_home_contains_notifications_link(client, e2e_credentials):
    client.post(
        reverse('login'),
        {
            'username': e2e_credentials['username'],
            'password': e2e_credentials['password'],
        },
    )
    response = client.get(reverse('home'))
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert reverse('approval:landing') in content
    assert 'Уведомления' in content

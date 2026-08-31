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
        with patch('approval.views.count_topopassport_features_by_table', return_value={}):
            with patch('approval.views.count_adjacent_features_by_source', return_value={}):
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
    assert 'Согласование границ ОГХ' in content
    assert 'Чат события' in content
    assert 'Процесс согласования границ' in content
    assert 'Управление слоями' in content
    assert 'approval-map-geojson' in content
    assert 'approval-create-event-btn' not in content
    assert 'approval-chat-geometry-btn' in content


@pytest.mark.django_db
def test_home_shows_notifications_badge_and_approvals_tab(client):
    owner_id = 'HOME_APPROVAL_OWNER'
    ExternalUser.objects.create(login='home_owner', password='pass', owner_legal_person_id=owner_id)
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=[owner_id],
        approved=False,
        name='Тестовое согласование',
    )
    primary = Approve.objects.latest('created_at').cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=['owners', 'updated_at'])
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
    assert 'id="approval-notifications-btn"' in content
    assert 'approval-notifications-panel' in content
    assert 'approval-notifications-item' in content
    assert 'data-approve-id=' in content
    assert 'data-owned-list-tab="approvals"' in content
    assert 'owned-approval-row' in content
    assert 'Тестовое согласование' in content
    assert 'data-approval-status="В работе"' in content
    assert '<option value="В работе">В работе</option>' in content
    assert '<option value="Согласовано">Согласовано</option>' in content


@pytest.mark.django_db
def test_home_shows_approvals_for_inspector(client):
    ExternalUser.objects.create(login='inspector_home', password='pass', owner_legal_person_id=None)
    Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=['OWNER_A'],
        user='inspector_home',
        approved=False,
        name='Согласование инспектора',
    )
    client.post(reverse('login'), {'username': 'inspector_home', 'password': 'pass'})
    response = client.get(reverse('home'))
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert 'data-owned-list-tab="approvals"' in content
    assert 'owned-approval-row' in content
    assert 'Согласование инспектора' in content
    assert 'owned-approval-delete-btn' in content
    assert 'approval-notifications-badge' in content
    assert 'id="approval-notifications-btn"' in content
    assert 'approval-notifications-panel' in content


@pytest.mark.django_db
def test_home_hides_delete_button_for_owner(client):
    owner_id = 'HOME_APPROVAL_OWNER'
    ExternalUser.objects.create(login='home_owner_del', password='pass', owner_legal_person_id=owner_id)
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=[owner_id],
        user='some_inspector',
        approved=False,
        name='Согласование владельца',
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=['owners', 'updated_at'])
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
                                    {'username': 'home_owner_del', 'password': 'pass'},
                                )
                                response = client.get(reverse('home'))
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert 'Согласование владельца' in content
    assert 'owned-approval-delete-btn' not in content


@pytest.mark.django_db
def test_home_contains_notifications_dropdown(client, e2e_credentials):
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
    assert 'id="approval-notifications-btn"' in content
    assert 'approval-notifications-panel' in content
    assert 'Уведомления' in content
    assert 'approval-notifications-empty' in content
    assert 'id="approval-ods-sync-section"' in content
    assert 'id="approval-ods-sync-list"' in content
    assert 'home-workflow-ods-sync-block' not in content
    assert 'home-workflow-ods-sync-list' not in content


@pytest.mark.django_db
def test_personal_notifications_panel_shows_all_events(client):
    owner_id = 'PERSONAL_NOTIF_OWNER'
    ExternalUser.objects.create(login='personal_notif', password='pass', owner_legal_person_id=owner_id)
    approve = Approve.objects.create(
        incoming_guid=uuid.uuid4(),
        owners=[owner_id],
        approved=False,
        name='Событие для панели personal',
    )
    primary = approve.cases.get(is_primary=True)
    primary.owners = [owner_id]
    primary.save(update_fields=['owners', 'updated_at'])
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
                                    {'username': 'personal_notif', 'password': 'pass'},
                                )
                                response = client.get(reverse('personal_account'))
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert 'id="personal-notifications-panel"' not in content
    assert 'id="approval-notifications-btn"' in content
    assert 'id="approval-notifications-modal"' in content
    assert 'Событие для панели personal' in content
    assert 'class="site-header__icon-link" href="/" aria-label="Уведомления"' not in content
    assert 'personal-account-layout' in content


@pytest.mark.django_db
def test_non_home_page_opens_notifications_modal_markup(client, e2e_credentials):
    with patch('approval.views.count_features_by_table', return_value={}):
        with patch('approval.views.count_topopassport_features_by_table', return_value={}):
            with patch('approval.views.count_adjacent_features_by_source', return_value={}):
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
    assert 'id="approval-notifications-btn"' in content
    assert 'id="approval-notifications-modal"' in content
    assert 'id="approval-notifications-feed"' in content
    assert 'class="site-header__icon-link" href="/" aria-label="Уведомления"' not in content

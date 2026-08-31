"""Browser smoke tests (Playwright)."""

from __future__ import annotations

import json

import pytest
from django.urls import reverse


@pytest.mark.e2e
@pytest.mark.django_db
def test_login_page_renders(page, live_server):
    page.goto(f'{live_server.url}{reverse("login")}')
    assert page.locator('input[name="username"]').is_visible()
    assert page.get_by_role('button', name='Войти').is_visible()


@pytest.mark.e2e
@pytest.mark.django_db
def test_login_navigates_to_home(page, live_server, e2e_credentials):
    page.goto(f'{live_server.url}{reverse("login")}')
    page.fill('input[name="username"]', e2e_credentials['username'])
    page.fill('input[name="password"]', e2e_credentials['password'])
    page.get_by_role('button', name='Войти').click()
    page.wait_for_url(f'{live_server.url}/', wait_until='load')
    assert page.locator('.owned-home-shell').is_visible()
    assert page.locator('#user-guide-open-btn').is_visible() or page.get_by_role(
        'button', name='Выйти'
    ).is_visible()


@pytest.mark.e2e
@pytest.mark.django_db
def test_home_page_config_script(page, live_server, e2e_credentials):
    page.goto(f'{live_server.url}{reverse("login")}')
    page.fill('input[name="username"]', e2e_credentials['username'])
    page.fill('input[name="password"]', e2e_credentials['password'])
    page.get_by_role('button', name='Войти').click()
    page.wait_for_selector('#page-config', state='attached')
    config_text = page.locator('#page-config').inner_text()
    assert '"page"' in config_text
    assert 'home' in config_text
    config = json.loads(config_text)
    assert config.get('features', {}).get('workflowModal') is False


@pytest.mark.e2e
@pytest.mark.django_db
def test_static_home_js_served(page, live_server, e2e_credentials):
    page.goto(f'{live_server.url}{reverse("login")}')
    page.fill('input[name="username"]', e2e_credentials['username'])
    page.fill('input[name="password"]', e2e_credentials['password'])
    page.get_by_role('button', name='Войти').click()
    page.wait_for_selector('.owned-home-shell', state='visible')
    response = page.request.get(f'{live_server.url}/static/pass_viewer/js/home.js')
    assert response.status == 200
    body = response.text()
    assert 'getMergeCheckboxPayload' in body
    assert 'merge_item_object_key' in body


@pytest.mark.e2e
@pytest.mark.django_db
def test_user_guide_modal_opens(page, live_server, e2e_credentials):
    page.goto(f'{live_server.url}{reverse("login")}')
    page.fill('input[name="username"]', e2e_credentials['username'])
    page.fill('input[name="password"]', e2e_credentials['password'])
    page.get_by_role('button', name='Войти').click()
    page.wait_for_selector('.owned-home-shell', state='visible')
    page.wait_for_load_state('networkidle')
    workflow_modal = page.locator('#home-workflow-modal')
    assert workflow_modal.evaluate('el => el.style.display') != 'flex'
    page.locator('#user-guide-open-btn').click()
    guide_modal = page.locator('#user-guide-modal')
    assert guide_modal.evaluate('el => !el.hidden') is True
    assert 'is-open' in (guide_modal.get_attribute('class') or '')
    page.locator('#user-guide-close-btn').click()
    assert guide_modal.evaluate('el => el.hidden') is True


@pytest.mark.e2e
@pytest.mark.django_db
def test_approval_notifications_dropdown_opens(page, live_server, e2e_credentials):
    page.goto(f'{live_server.url}{reverse("login")}')
    page.fill('input[name="username"]', e2e_credentials['username'])
    page.fill('input[name="password"]', e2e_credentials['password'])
    page.get_by_role('button', name='Войти').click()
    page.wait_for_selector('.personal-account', state='visible')
    page.wait_for_load_state('networkidle')
    page.locator('#approval-notifications-btn').click()
    modal = page.locator('#approval-notifications-modal')
    assert modal.evaluate('el => !el.hidden') is True
    assert page.locator('#approval-ods-sync-section').count() == 1
    assert page.locator('#personal-notifications-panel').count() == 0

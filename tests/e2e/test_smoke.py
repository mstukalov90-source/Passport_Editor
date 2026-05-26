"""Browser smoke tests (Playwright)."""

from __future__ import annotations

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

"""Fast auth smoke tests (Django test client, no browser)."""

from __future__ import annotations

import pytest
from django.urls import reverse


@pytest.mark.django_db
def test_anonymous_home_redirects_to_login(client):
    response = client.get(reverse('home'))
    assert response.status_code == 302
    assert '/accounts/login/' in response.url


@pytest.mark.django_db
def test_login_and_home_loads(client, e2e_credentials):
    login_url = reverse('login')
    response = client.post(
        login_url,
        {
            'username': e2e_credentials['username'],
            'password': e2e_credentials['password'],
        },
        follow=True,
    )
    assert response.status_code == 200
    content = response.content.decode('utf-8')
    assert 'owned-home-shell' in content or 'Объекты балансодержателя' in content

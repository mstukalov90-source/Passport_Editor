"""Shared pytest fixtures."""

from __future__ import annotations

import os

# pytest-playwright runs an asyncio loop; allow sync Django ORM during db setup.
os.environ.setdefault('DJANGO_ALLOW_ASYNC_UNSAFE', 'true')

import pytest
from django.core.management import call_command
from django.db.backends.signals import connection_created

pytest_plugins = ['pytest_playwright']


def _ensure_approval_schema(sender, connection, **kwargs):
    if connection.vendor != 'postgresql':
        return
    with connection.cursor() as cursor:
        cursor.execute('CREATE SCHEMA IF NOT EXISTS approval')


connection_created.connect(_ensure_approval_schema, dispatch_uid='approval_test_schema')


@pytest.fixture(autouse=True)
def disable_axes_for_tests(settings):
    settings.AXES_ENABLED = False


@pytest.fixture(scope='session')
def django_db_use_migrations():
    """Smoke tests only need ORM tables (users); GIS tables come from seed/import."""
    return False


@pytest.fixture(scope='session')
def e2e_credentials():
    return {
        'username': os.getenv('E2E_LOGIN', 'e2e_test'),
        'password': os.getenv('E2E_PASSWORD', 'e2e_test_pass'),
    }


@pytest.fixture(scope='session')
def django_db_setup(django_db_setup, django_db_blocker):
    with django_db_blocker.unblock():
        call_command('ensure_e2e_user', verbosity=0)

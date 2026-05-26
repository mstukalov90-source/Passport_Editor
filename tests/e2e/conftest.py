"""E2E fixtures (Playwright + live_server)."""

from __future__ import annotations

import pytest
from django.core.management import call_command


@pytest.fixture(scope='session')
def browser_type_launch_args():
    return {'headless': True}


@pytest.fixture(autouse=True)
def _ensure_e2e_user_per_test(db):
    """Recreate E2E user inside each test transaction (visible to live_server)."""
    call_command('ensure_e2e_user', verbosity=0)

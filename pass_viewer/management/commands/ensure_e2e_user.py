"""Create or update the E2E test user in the users table (idempotent)."""

from __future__ import annotations

import os

from django.core.management.base import BaseCommand

from pass_viewer.models import ExternalUser


class Command(BaseCommand):
    help = 'Ensure E2E test user exists (login/password from E2E_* env vars).'

    def handle(self, *args, **options):
        login = os.getenv('E2E_LOGIN', 'e2e_test')
        password = os.getenv('E2E_PASSWORD', 'e2e_test_pass')
        owner_id = os.getenv('E2E_OWNER_ID', 'E2E_OWNER')

        user, created = ExternalUser.objects.update_or_create(
            login=login,
            defaults={
                'password': password,
                'owner_legal_person_id': owner_id,
                'hood_scope': False,
                'role': ExternalUser.ROLE_BD,
            },
        )
        verb = 'Created' if created else 'Updated'
        self.stdout.write(self.style.SUCCESS(f'{verb} E2E user "{user.login}" (owner={owner_id})'))

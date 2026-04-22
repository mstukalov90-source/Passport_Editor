from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.backends import BaseBackend

import psycopg2


class DockerUsersTableBackend(BaseBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        if not username or not password:
            return None

        db = settings.EXTERNAL_USERS_DB
        with psycopg2.connect(
            dbname=db['NAME'],
            user=db['USER'],
            password=db['PASSWORD'],
            host=db['HOST'],
            port=db['PORT'],
        ) as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    "SELECT 1 FROM users WHERE login = %s AND password = %s LIMIT 1",
                    [username, password],
                )
                exists = cursor.fetchone() is not None

        if not exists:
            return None

        user_model = get_user_model()
        user, _ = user_model.objects.get_or_create(username=username)
        if not user.is_active:
            user.is_active = True
            user.save(update_fields=['is_active'])
        return user

    def get_user(self, user_id):
        user_model = get_user_model()
        try:
            return user_model.objects.get(pk=user_id)
        except user_model.DoesNotExist:
            return None

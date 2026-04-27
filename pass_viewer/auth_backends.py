from django.contrib.auth import get_user_model
from django.contrib.auth.backends import BaseBackend

from .models import ExternalUser


class DockerUsersTableBackend(BaseBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        if not username or not password:
            return None

        exists = ExternalUser.objects.filter(login=username, password=password).exists()
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

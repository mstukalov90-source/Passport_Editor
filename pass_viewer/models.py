from django.db import models


class ExternalUser(models.Model):
    login = models.CharField(max_length=150, unique=True)
    password = models.CharField(max_length=255)
    owner_legal_person_id = models.CharField(
        max_length=255,
        db_column='OwnerLegalPersonId',
        blank=True,
        null=True,
    )

    class Meta:
        db_table = 'users'

    def __str__(self):
        return self.login

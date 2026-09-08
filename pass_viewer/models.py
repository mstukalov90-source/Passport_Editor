from django.contrib.postgres.fields import ArrayField
from django.db import models


class ExternalUser(models.Model):
    ROLE_BD = "BD"
    ROLE_MGGT = "MGGT"
    ROLE_DEP = "DEP"
    ROLE_DEP_PLUS = "DEP+"
    ROLE_SUP = "SUP"
    ROLE_CHOICES = (
        (ROLE_BD, "BD"),
        (ROLE_MGGT, "MGGT"),
        (ROLE_DEP, "DEP"),
        (ROLE_DEP_PLUS, "DEP+"),
        (ROLE_SUP, "SUP"),
    )

    login = models.CharField(max_length=150, unique=True)
    password = models.CharField(max_length=255)
    owner_legal_person_id = models.CharField(
        max_length=255,
        db_column="OwnerLegalPersonId",
        blank=True,
        null=True,
    )
    owner_legal_person_ids = ArrayField(
        models.TextField(),
        default=list,
        blank=True,
        db_column="OwnerLegalPersonIds",
    )
    display_name = models.CharField(max_length=255, blank=True, default="")
    hood_scope = models.BooleanField(default=False)
    role = models.CharField(
        max_length=8,
        choices=ROLE_CHOICES,
        default=ROLE_BD,
        db_column="role",
    )

    class Meta:
        db_table = "users"

    def __str__(self):
        return self.login


class RequestAttachment(models.Model):
    brid = models.CharField(max_length=32, db_index=True)
    original_name = models.TextField()
    stored_name = models.TextField()
    content_type = models.TextField(blank=True, default="")
    size_bytes = models.BigIntegerField()
    uploaded_by = models.CharField(max_length=150, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "request_attachments"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.brid}:{self.original_name}"

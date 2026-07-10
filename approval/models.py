import uuid

from django.contrib.gis.db import models
from django.contrib.postgres.fields import ArrayField


class Approve(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    incoming_guid = models.UUIDField(unique=True)
    n_root = ArrayField(models.TextField(), blank=True, null=True)
    v_root = ArrayField(models.TextField(), blank=True, null=True)
    name = models.TextField(blank=True, null=True)
    owners = ArrayField(models.TextField(), default=list)
    approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = '"approval"."approves"'

    def __str__(self):
        return str(self.incoming_guid)


class Case(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    approve = models.ForeignKey(
        Approve,
        on_delete=models.CASCADE,
        related_name="cases",
        db_column="approve_id",
    )
    is_primary = models.BooleanField(default=False)
    title = models.TextField()
    status = models.TextField(default="в работе")
    approved = models.BooleanField(default=False)
    created_by_login = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    closed_at = models.DateTimeField(blank=True, null=True)
    n_root = ArrayField(models.TextField(), blank=True, null=True)
    owners = ArrayField(models.TextField(), default=list)

    class Meta:
        db_table = '"approval"."cases"'

    def __str__(self):
        return self.title


class CaseMessage(models.Model):
    case = models.ForeignKey(
        Case,
        on_delete=models.CASCADE,
        related_name="messages",
        db_column="case_id",
    )
    author_login = models.TextField()
    author_role = models.TextField(blank=True, null=True)
    body = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."case_messages"'
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.author_login}: {self.body[:40]}"


class CaseApproval(models.Model):
    case = models.ForeignKey(
        Case,
        on_delete=models.CASCADE,
        related_name="approvals",
        db_column="case_id",
    )
    owner_legal_person_id = models.TextField()
    approved_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."case_approvals"'
        constraints = [
            models.UniqueConstraint(
                fields=["case", "owner_legal_person_id"],
                name="case_approvals_case_owner_uniq",
            ),
        ]

    def __str__(self):
        return f"{self.case_id}:{self.owner_legal_person_id}"


class CaseMessageAttachment(models.Model):
    message = models.ForeignKey(
        CaseMessage,
        on_delete=models.CASCADE,
        related_name="attachments",
        db_column="message_id",
    )
    stored_name = models.TextField()
    original_name = models.TextField()
    content_type = models.TextField()
    size_bytes = models.BigIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."case_message_attachments"'

    def __str__(self):
        return self.original_name


class ApprovalGeometry(models.Model):
    approve = models.ForeignKey(
        Approve,
        on_delete=models.CASCADE,
        related_name="geometries",
        db_column="approve_id",
    )
    case = models.ForeignKey(
        Case,
        on_delete=models.SET_NULL,
        related_name="geometries",
        db_column="case_id",
        blank=True,
        null=True,
    )
    geom = models.GeometryField(srid=4326)
    label = models.TextField(blank=True, null=True)
    owner_legal_person_id = models.TextField(blank=True, null=True)
    message = models.ForeignKey(
        CaseMessage,
        on_delete=models.CASCADE,
        related_name="geometries",
        db_column="message_id",
        blank=True,
        null=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."geometry"'

    def __str__(self):
        return self.label or f"geometry #{self.pk}"

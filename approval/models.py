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
    user = models.TextField(blank=True, db_column="user", null=True)
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
    n_root = models.TextField(blank=True, null=True)
    owners = ArrayField(models.TextField(), default=list)
    participant_logins = ArrayField(models.TextField(), default=list, blank=True)

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
    parent = models.ForeignKey(
        "self",
        on_delete=models.CASCADE,
        related_name="replies",
        db_column="parent_id",
        blank=True,
        null=True,
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


class CaseServiceEvent(models.Model):
    KIND_APPROVED = "approved"
    KIND_REVOKED = "revoked"
    KIND_CLOSED = "closed"
    KIND_CLOSED_OVERDUE = "closed_overdue"
    KIND_CHOICES = (
        (KIND_APPROVED, "Согласовано"),
        (KIND_REVOKED, "Отмена согласования"),
        (KIND_CLOSED, "Событие закрыто"),
        (KIND_CLOSED_OVERDUE, "Событие закрыто по истечению срока"),
    )

    case = models.ForeignKey(
        Case,
        on_delete=models.CASCADE,
        related_name="service_events",
        db_column="case_id",
    )
    actor_login = models.TextField()
    kind = models.TextField(choices=KIND_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."case_service_events"'
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.kind}:{self.actor_login}:{self.case_id}"


class CaseMessageDeleted(models.Model):
    original_message_id = models.BigIntegerField()
    case_id = models.UUIDField()
    author_login = models.TextField()
    author_role = models.TextField(blank=True, null=True)
    body = models.TextField()
    parent_id = models.BigIntegerField(blank=True, null=True)
    created_at = models.DateTimeField()
    deleted_at = models.DateTimeField(auto_now_add=True)
    deleted_by_login = models.TextField()
    attachments_json = models.JSONField(blank=True, null=True)

    class Meta:
        db_table = '"approval"."case_messages_deleted"'
        ordering = ["-deleted_at"]

    def __str__(self):
        return f"deleted:{self.original_message_id}:{self.author_login}"


class CaseApproval(models.Model):
    case = models.ForeignKey(
        Case,
        on_delete=models.CASCADE,
        related_name="approvals",
        db_column="case_id",
    )
    owner_legal_person_id = models.TextField(blank=True, null=True)
    approver_login = models.TextField(blank=True, null=True)
    approved_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."case_approvals"'
        constraints = [
            models.UniqueConstraint(
                fields=["case", "owner_legal_person_id"],
                name="case_approvals_case_owner_uniq",
            ),
            models.UniqueConstraint(
                fields=["case", "approver_login"],
                condition=models.Q(approver_login__isnull=False),
                name="case_approvals_case_inspector_uniq",
            ),
        ]

    def __str__(self):
        if self.approver_login:
            return f"{self.case_id}:inspector:{self.approver_login}"
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


class CaseMessageReaction(models.Model):
    KIND_IN_PROGRESS = "in_progress"
    KIND_DONE = "done"
    KIND_ACCEPTED = "accepted"
    KIND_REJECTED = "rejected"
    KIND_CHOICES = (
        (KIND_IN_PROGRESS, "В работе"),
        (KIND_DONE, "Выполнено"),
        (KIND_ACCEPTED, "Принято"),
        (KIND_REJECTED, "Отклонено"),
    )

    message = models.ForeignKey(
        CaseMessage,
        on_delete=models.CASCADE,
        related_name="reactions",
        db_column="message_id",
    )
    reactor_login = models.TextField()
    kind = models.TextField(choices=KIND_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"approval"."case_message_reactions"'
        constraints = [
            models.UniqueConstraint(
                fields=["message", "reactor_login"],
                name="case_message_reactions_message_reactor_uniq",
            ),
        ]

    def __str__(self):
        return f"{self.reactor_login}:{self.kind}:{self.message_id}"


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

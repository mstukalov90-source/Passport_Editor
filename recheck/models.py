import uuid

from django.contrib.gis.db import models


class RecheckEvent(models.Model):
    STATUS_OPEN = "open"
    STATUS_AGREED = "agreed"
    STATUS_EXPIRED = "expired"
    STATUS_CHOICES = (
        (STATUS_OPEN, "На проверке"),
        (STATUS_AGREED, "Согласовано"),
        (STATUS_EXPIRED, "Закрыто по сроку"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    source_approve = models.OneToOneField(
        "approval.Approve",
        on_delete=models.PROTECT,
        related_name="recheck_event",
        db_column="source_approve_id",
    )
    task_guid = models.UUIDField(unique=True)
    title = models.TextField(default="Проверка геоподосновы")
    task_owner_id = models.TextField(blank=True)
    status = models.TextField(choices=STATUS_CHOICES, default=STATUS_OPEN)
    created_at = models.DateTimeField(auto_now_add=True)
    due_at = models.DateTimeField()
    closed_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = '"recheck"."events"'
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.title}: {self.task_guid}"


class RecheckApproval(models.Model):
    KIND_REQUESTER = "requester"
    KIND_INSPECTOR = "inspector"
    KIND_CHOICES = (
        (KIND_REQUESTER, "Пользователь задания"),
        (KIND_INSPECTOR, "Инспектор МГГТ"),
    )

    event = models.ForeignKey(
        RecheckEvent,
        on_delete=models.CASCADE,
        related_name="approvals",
        db_column="event_id",
    )
    kind = models.TextField(choices=KIND_CHOICES)
    actor_login = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"recheck"."approvals"'
        constraints = [
            models.UniqueConstraint(fields=["event", "kind"], name="recheck_approval_event_kind_uniq"),
        ]


class ObjectChangeRequest(models.Model):
    STATUS_PENDING = "pending"
    STATUS_APPLIED = "applied"
    STATUS_REJECTED = "rejected"
    STATUS_CHOICES = (
        (STATUS_PENDING, "Ожидает внесения"),
        (STATUS_APPLIED, "Внесено в QGIS"),
        (STATUS_REJECTED, "Отклонено"),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(
        RecheckEvent,
        on_delete=models.CASCADE,
        related_name="object_requests",
        db_column="event_id",
    )
    source_layer = models.TextField()
    object_key = models.TextField()
    root_id = models.TextField(blank=True)
    object_name = models.TextField(blank=True)
    original_properties = models.JSONField(default=dict)
    geom = models.GeometryField(srid=4326, blank=True, null=True)
    status = models.TextField(choices=STATUS_CHOICES, default=STATUS_PENDING)
    requested_by_login = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(blank=True, null=True)
    processed_by_login = models.TextField(blank=True)

    class Meta:
        db_table = '"recheck"."object_requests"'
        ordering = ["created_at"]
        indexes = [
            models.Index(fields=["status"], name="recheck_request_status_idx"),
            models.Index(fields=["source_layer", "object_key"], name="recheck_request_object_idx"),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=["event", "source_layer", "object_key"],
                name="recheck_one_request_per_object",
            ),
        ]


class AttributeChange(models.Model):
    object_request = models.ForeignKey(
        ObjectChangeRequest,
        on_delete=models.CASCADE,
        related_name="changes",
        db_column="object_request_id",
    )
    field_name = models.TextField()
    field_label = models.TextField(blank=True)
    old_value = models.JSONField(blank=True, null=True)
    new_value = models.JSONField(blank=True, null=True)

    class Meta:
        db_table = '"recheck"."attribute_changes"'
        ordering = ["id"]
        constraints = [
            models.UniqueConstraint(
                fields=["object_request", "field_name"],
                name="recheck_change_request_field_uniq",
            ),
        ]


class RecheckMessage(models.Model):
    event = models.ForeignKey(
        RecheckEvent,
        on_delete=models.CASCADE,
        related_name="messages",
        db_column="event_id",
    )
    object_request = models.OneToOneField(
        ObjectChangeRequest,
        on_delete=models.CASCADE,
        related_name="message",
        db_column="object_request_id",
        blank=True,
        null=True,
    )
    author_login = models.TextField()
    body = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = '"recheck"."messages"'
        ordering = ["created_at"]

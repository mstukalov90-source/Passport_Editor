import uuid

import django.contrib.gis.db.models.fields
import django.db.models.deletion
from django.db import migrations, models


def backfill_approved(apps, schema_editor):
    from datetime import timedelta

    Approve = apps.get_model("approval", "Approve")
    Case = apps.get_model("approval", "Case")
    RecheckEvent = apps.get_model("recheck", "RecheckEvent")
    for approve in Approve.objects.filter(approved=True).iterator():
        due_at = approve.updated_at
        remaining = 5
        while remaining:
            due_at += timedelta(days=1)
            if due_at.weekday() < 5:
                remaining -= 1
        primary = Case.objects.filter(approve_id=approve.pk, is_primary=True).first()
        task_owner_id = next(
            (str(item).strip() for item in ((primary.owners if primary else None) or []) if str(item).strip()),
            "",
        )
        RecheckEvent.objects.get_or_create(
            source_approve_id=approve.pk,
            defaults={
                "task_guid": approve.incoming_guid,
                "task_owner_id": task_owner_id,
                "due_at": due_at,
            },
        )


class Migration(migrations.Migration):
    initial = True

    dependencies = [("approval", "0014_case_event_type")]

    operations = [
        migrations.RunSQL(
            "CREATE SCHEMA IF NOT EXISTS recheck;",
            reverse_sql="DROP SCHEMA IF EXISTS recheck CASCADE;",
        ),
        migrations.CreateModel(
            name="RecheckEvent",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("task_guid", models.UUIDField(unique=True)),
                ("title", models.TextField(default="Проверка геоподосновы")),
                ("task_owner_id", models.TextField(blank=True)),
                ("status", models.TextField(choices=[("open", "На проверке"), ("agreed", "Согласовано"), ("expired", "Закрыто по сроку")], default="open")),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("due_at", models.DateTimeField()),
                ("closed_at", models.DateTimeField(blank=True, null=True)),
                ("source_approve", models.OneToOneField(db_column="source_approve_id", on_delete=django.db.models.deletion.PROTECT, related_name="recheck_event", to="approval.approve")),
            ],
            options={"db_table": '"recheck"."events"', "ordering": ["-created_at"]},
        ),
        migrations.CreateModel(
            name="ObjectChangeRequest",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("source_layer", models.TextField()),
                ("object_key", models.TextField()),
                ("root_id", models.TextField(blank=True)),
                ("object_name", models.TextField(blank=True)),
                ("original_properties", models.JSONField(default=dict)),
                ("geom", django.contrib.gis.db.models.fields.GeometryField(blank=True, null=True, srid=4326)),
                ("status", models.TextField(choices=[("pending", "Ожидает внесения"), ("applied", "Внесено в QGIS"), ("rejected", "Отклонено")], default="pending")),
                ("requested_by_login", models.TextField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("processed_at", models.DateTimeField(blank=True, null=True)),
                ("processed_by_login", models.TextField(blank=True)),
                ("event", models.ForeignKey(db_column="event_id", on_delete=django.db.models.deletion.CASCADE, related_name="object_requests", to="recheck.recheckevent")),
            ],
            options={
                "db_table": '"recheck"."object_requests"',
                "ordering": ["created_at"],
                "indexes": [
                    models.Index(fields=["status"], name="recheck_request_status_idx"),
                    models.Index(fields=["source_layer", "object_key"], name="recheck_request_object_idx"),
                ],
            },
        ),
        migrations.CreateModel(
            name="RecheckMessage",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("author_login", models.TextField()),
                ("body", models.TextField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("event", models.ForeignKey(db_column="event_id", on_delete=django.db.models.deletion.CASCADE, related_name="messages", to="recheck.recheckevent")),
                ("object_request", models.OneToOneField(blank=True, db_column="object_request_id", null=True, on_delete=django.db.models.deletion.CASCADE, related_name="message", to="recheck.objectchangerequest")),
            ],
            options={"db_table": '"recheck"."messages"', "ordering": ["created_at"]},
        ),
        migrations.CreateModel(
            name="RecheckApproval",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("kind", models.TextField(choices=[("requester", "Пользователь задания"), ("inspector", "Инспектор МГГТ")])),
                ("actor_login", models.TextField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("event", models.ForeignKey(db_column="event_id", on_delete=django.db.models.deletion.CASCADE, related_name="approvals", to="recheck.recheckevent")),
            ],
            options={"db_table": '"recheck"."approvals"'},
        ),
        migrations.CreateModel(
            name="AttributeChange",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("field_name", models.TextField()),
                ("field_label", models.TextField(blank=True)),
                ("old_value", models.JSONField(blank=True, null=True)),
                ("new_value", models.JSONField(blank=True, null=True)),
                ("object_request", models.ForeignKey(db_column="object_request_id", on_delete=django.db.models.deletion.CASCADE, related_name="changes", to="recheck.objectchangerequest")),
            ],
            options={"db_table": '"recheck"."attribute_changes"', "ordering": ["id"]},
        ),
        migrations.AddConstraint(model_name="recheckapproval", constraint=models.UniqueConstraint(fields=("event", "kind"), name="recheck_approval_event_kind_uniq")),
        migrations.AddConstraint(model_name="objectchangerequest", constraint=models.UniqueConstraint(fields=("event", "source_layer", "object_key"), name="recheck_one_request_per_object")),
        migrations.AddConstraint(model_name="attributechange", constraint=models.UniqueConstraint(fields=("object_request", "field_name"), name="recheck_change_request_field_uniq")),
        migrations.RunSQL(
            sql="""
                CREATE VIEW recheck.qgis_changes AS
                SELECT
                    c.id AS change_id,
                    r.id AS request_id,
                    e.task_guid,
                    r.source_layer,
                    r.object_key,
                    r.root_id,
                    r.object_name,
                    c.field_name,
                    c.field_label,
                    c.old_value::text AS old_value,
                    c.new_value::text AS new_value,
                    r.status,
                    r.requested_by_login,
                    r.created_at,
                    r.processed_at,
                    r.processed_by_login,
                    r.geom
                FROM recheck.attribute_changes c
                JOIN recheck.object_requests r ON r.id = c.object_request_id
                JOIN recheck.events e ON e.id = r.event_id;
            """,
            reverse_sql="DROP VIEW IF EXISTS recheck.qgis_changes;",
        ),
        migrations.RunPython(backfill_approved, migrations.RunPython.noop),
    ]

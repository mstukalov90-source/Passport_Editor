from django.db import migrations, models
from django.db.models import Q


def forwards_backfill_roles(apps, schema_editor):
    ExternalUser = apps.get_model("pass_viewer", "ExternalUser")
    # Existing users keep BD behavior.
    ExternalUser.objects.filter(Q(role__isnull=True) | Q(role="")).update(role="BD")
    # Inspectors historically had OwnerLegalPersonId NULL.
    ExternalUser.objects.filter(
        Q(owner_legal_person_id__isnull=True) | Q(owner_legal_person_id=""),
        role="BD",
    ).update(role="MGGT")


def backwards_noop(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0026_add_dgi_rent"),
    ]

    operations = [
        migrations.AddField(
            model_name="externaluser",
            name="role",
            field=models.CharField(
                choices=[
                    ("BD", "BD"),
                    ("MGGT", "MGGT"),
                    ("DEP", "DEP"),
                    ("SUP", "SUP"),
                ],
                db_column="role",
                default="BD",
                max_length=8,
            ),
        ),
        migrations.RunPython(forwards_backfill_roles, backwards_noop),
    ]

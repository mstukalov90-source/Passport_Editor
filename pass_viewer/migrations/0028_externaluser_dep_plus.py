from django.contrib.postgres.fields import ArrayField
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0027_externaluser_role"),
    ]

    operations = [
        migrations.AddField(
            model_name="externaluser",
            name="owner_legal_person_ids",
            field=ArrayField(
                base_field=models.TextField(),
                blank=True,
                db_column="OwnerLegalPersonIds",
                default=list,
                size=None,
            ),
        ),
        migrations.AddField(
            model_name="externaluser",
            name="display_name",
            field=models.CharField(blank=True, default="", max_length=255),
        ),
        migrations.AlterField(
            model_name="externaluser",
            name="role",
            field=models.CharField(
                choices=[
                    ("BD", "BD"),
                    ("MGGT", "MGGT"),
                    ("DEP", "DEP"),
                    ("DEP+", "DEP+"),
                    ("SUP", "SUP"),
                ],
                db_column="role",
                default="BD",
                max_length=8,
            ),
        ),
    ]

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0012_case_service_events"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[],
            state_operations=[
                migrations.AlterField(
                    model_name="caseserviceevent",
                    name="kind",
                    field=models.TextField(
                        choices=[
                            ("approved", "Согласовано"),
                            ("revoked", "Отмена согласования"),
                            ("closed", "Событие закрыто"),
                            ("closed_overdue", "Событие закрыто по истечению срока"),
                        ]
                    ),
                ),
            ],
        ),
    ]

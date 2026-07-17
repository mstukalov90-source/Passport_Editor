from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0009_case_participant_logins"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[],
            state_operations=[
                migrations.AlterField(
                    model_name="casemessagereaction",
                    name="kind",
                    field=models.TextField(
                        choices=[
                            ("in_progress", "В работе"),
                            ("done", "Выполнено"),
                            ("accepted", "Принято"),
                            ("rejected", "Отклонено"),
                        ]
                    ),
                ),
            ],
        ),
    ]

from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.approves
    ADD COLUMN IF NOT EXISTS neighbour_guid uuid NULL;
"""

REVERSE_SQL = """
ALTER TABLE approval.approves
    DROP COLUMN IF EXISTS neighbour_guid;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0002_cases_approved_chat_files"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.AddField(
                    model_name="approve",
                    name="neighbour_guid",
                    field=models.UUIDField(blank=True, null=True),
                ),
            ],
        ),
    ]

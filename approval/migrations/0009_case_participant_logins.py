from django.contrib.postgres.fields import ArrayField
from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.cases
    ADD COLUMN IF NOT EXISTS participant_logins text[] NOT NULL DEFAULT '{}';
"""

REVERSE_SQL = """
ALTER TABLE approval.cases
    DROP COLUMN IF EXISTS participant_logins;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0008_case_message_parent"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.AddField(
                    model_name="case",
                    name="participant_logins",
                    field=ArrayField(
                        models.TextField(),
                        blank=True,
                        default=list,
                    ),
                ),
            ],
        ),
    ]

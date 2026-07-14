from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.case_messages
    ADD COLUMN IF NOT EXISTS parent_id bigint NULL
    REFERENCES approval.case_messages(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS case_messages_parent_id_idx
    ON approval.case_messages (parent_id);
"""

REVERSE_SQL = """
DROP INDEX IF EXISTS approval.case_messages_parent_id_idx;
ALTER TABLE approval.case_messages
    DROP COLUMN IF EXISTS parent_id;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0007_case_message_reactions"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.AddField(
                    model_name="casemessage",
                    name="parent",
                    field=models.ForeignKey(
                        blank=True,
                        db_column="parent_id",
                        null=True,
                        on_delete=models.deletion.CASCADE,
                        related_name="replies",
                        to="approval.casemessage",
                    ),
                ),
            ],
        ),
    ]

from django.contrib.postgres.fields import ArrayField
from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.approves
    RENAME COLUMN neighbour_guid TO n_root;

ALTER TABLE approval.approves
    ALTER COLUMN n_root TYPE text USING n_root::text;

ALTER TABLE approval.approves
    ADD COLUMN IF NOT EXISTS v_root text[] NULL;

ALTER TABLE approval.approves
    ADD COLUMN IF NOT EXISTS name text NULL;
"""

REVERSE_SQL = """
ALTER TABLE approval.approves DROP COLUMN IF EXISTS name;
ALTER TABLE approval.approves DROP COLUMN IF EXISTS v_root;
ALTER TABLE approval.approves ALTER COLUMN n_root TYPE uuid USING n_root::uuid;
ALTER TABLE approval.approves RENAME COLUMN n_root TO neighbour_guid;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0003_approves_neighbour_guid"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.RemoveField(
                    model_name="approve",
                    name="neighbour_guid",
                ),
                migrations.AddField(
                    model_name="approve",
                    name="n_root",
                    field=models.TextField(blank=True, null=True),
                ),
                migrations.AddField(
                    model_name="approve",
                    name="v_root",
                    field=ArrayField(base_field=models.TextField(), blank=True, null=True, size=None),
                ),
                migrations.AddField(
                    model_name="approve",
                    name="name",
                    field=models.TextField(blank=True, null=True),
                ),
            ],
        ),
    ]

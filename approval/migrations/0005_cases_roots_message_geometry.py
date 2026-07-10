from django.contrib.postgres.fields import ArrayField
from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.approves
    ALTER COLUMN n_root TYPE text[]
    USING CASE
        WHEN n_root IS NULL THEN NULL
        ELSE ARRAY[n_root]
    END;

ALTER TABLE approval.cases
    ADD COLUMN IF NOT EXISTS n_root text[] NULL;

ALTER TABLE approval.cases
    ADD COLUMN IF NOT EXISTS owners text[] NOT NULL DEFAULT '{}';

CREATE INDEX IF NOT EXISTS cases_owners_gin
    ON approval.cases
    USING GIN (owners);

ALTER TABLE approval.geometry
    ADD COLUMN IF NOT EXISTS message_id bigint NULL
    REFERENCES approval.case_messages(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS geometry_message_id_idx
    ON approval.geometry (message_id);

UPDATE approval.cases c
SET n_root = a.n_root, owners = a.owners
FROM approval.approves a
WHERE c.approve_id = a.id AND c.is_primary IS TRUE;

CREATE OR REPLACE FUNCTION approval.create_primary_case()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO approval.cases (approve_id, is_primary, title, status, n_root, owners)
    VALUES (NEW.id, true, 'Основное событие', 'в работе', NEW.n_root, NEW.owners);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
"""

REVERSE_SQL = """
CREATE OR REPLACE FUNCTION approval.create_primary_case()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO approval.cases (approve_id, is_primary, title, status)
    VALUES (NEW.id, true, 'Основное событие', 'в работе');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE approval.geometry DROP COLUMN IF EXISTS message_id;

ALTER TABLE approval.cases DROP COLUMN IF EXISTS owners;
ALTER TABLE approval.cases DROP COLUMN IF EXISTS n_root;

DROP INDEX IF EXISTS cases_owners_gin;

ALTER TABLE approval.approves
    ALTER COLUMN n_root TYPE text
    USING CASE
        WHEN n_root IS NULL OR array_length(n_root, 1) IS NULL THEN NULL
        ELSE n_root[1]
    END;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0004_approves_n_root_v_root_name"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.AlterField(
                    model_name="approve",
                    name="n_root",
                    field=ArrayField(
                        base_field=models.TextField(),
                        blank=True,
                        null=True,
                        size=None,
                    ),
                ),
                migrations.AddField(
                    model_name="case",
                    name="n_root",
                    field=ArrayField(
                        base_field=models.TextField(),
                        blank=True,
                        null=True,
                        size=None,
                    ),
                ),
                migrations.AddField(
                    model_name="case",
                    name="owners",
                    field=ArrayField(base_field=models.TextField(), default=list, size=None),
                ),
                migrations.AddField(
                    model_name="approvalgeometry",
                    name="message",
                    field=models.ForeignKey(
                        blank=True,
                        db_column="message_id",
                        null=True,
                        on_delete=models.deletion.CASCADE,
                        related_name="geometries",
                        to="approval.casemessage",
                    ),
                ),
            ],
        ),
    ]

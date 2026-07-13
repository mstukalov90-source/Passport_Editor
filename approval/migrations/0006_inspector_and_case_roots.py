from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.approves
    ADD COLUMN IF NOT EXISTS "user" text NULL;

ALTER TABLE approval.cases
    ALTER COLUMN n_root TYPE text
    USING CASE
        WHEN n_root IS NULL OR array_length(n_root, 1) IS NULL THEN NULL
        ELSE n_root[1]
    END;

ALTER TABLE approval.case_approvals
    ADD COLUMN IF NOT EXISTS approver_login text NULL;

ALTER TABLE approval.case_approvals
    ALTER COLUMN owner_legal_person_id DROP NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS case_approvals_case_inspector_uniq
    ON approval.case_approvals (case_id, approver_login)
    WHERE approver_login IS NOT NULL;

CREATE OR REPLACE FUNCTION approval.create_primary_case()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO approval.cases (approve_id, is_primary, title, status, n_root, owners)
    VALUES (NEW.id, true, 'Основное событие', 'в работе', NULL, '{}');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
"""

REVERSE_SQL = """
CREATE OR REPLACE FUNCTION approval.create_primary_case()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO approval.cases (approve_id, is_primary, title, status, n_root, owners)
    VALUES (NEW.id, true, 'Основное событие', 'в работе', NEW.n_root, NEW.owners);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP INDEX IF EXISTS case_approvals_case_inspector_uniq;

ALTER TABLE approval.case_approvals
    ALTER COLUMN owner_legal_person_id SET NOT NULL;

ALTER TABLE approval.case_approvals
    DROP COLUMN IF EXISTS approver_login;

ALTER TABLE approval.cases
    ALTER COLUMN n_root TYPE text[]
    USING CASE
        WHEN n_root IS NULL THEN NULL
        ELSE ARRAY[n_root]
    END;

ALTER TABLE approval.approves
    DROP COLUMN IF EXISTS "user";
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0005_cases_roots_message_geometry"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.AddField(
                    model_name="approve",
                    name="user",
                    field=models.TextField(blank=True, db_column="user", null=True),
                ),
                migrations.AlterField(
                    model_name="case",
                    name="n_root",
                    field=models.TextField(blank=True, null=True),
                ),
                migrations.AddField(
                    model_name="caseapproval",
                    name="approver_login",
                    field=models.TextField(blank=True, null=True),
                ),
                migrations.AlterField(
                    model_name="caseapproval",
                    name="owner_legal_person_id",
                    field=models.TextField(blank=True, null=True),
                ),
            ],
        ),
    ]

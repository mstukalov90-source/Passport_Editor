from django.db import migrations, models


FORWARD_SQL = """
ALTER TABLE approval.cases
    ADD COLUMN IF NOT EXISTS event_type text NOT NULL DEFAULT 'standard';

CREATE UNIQUE INDEX IF NOT EXISTS cases_one_surface_junction_per_approve
    ON approval.cases (approve_id)
    WHERE event_type = 'surface_junction';

INSERT INTO approval.cases (
    approve_id, is_primary, title, status, created_by_login, n_root, owners, event_type
)
SELECT a.id,
       false,
       'Согласование элементов сопряжения поверхностей',
       'в работе',
       a."user",
       NULL,
       a.owners,
       'surface_junction'
FROM approval.approves a
WHERE NOT EXISTS (
    SELECT 1
    FROM approval.cases c
    WHERE c.approve_id = a.id
      AND c.event_type = 'surface_junction'
);

INSERT INTO approval.case_messages (case_id, author_login, author_role, body)
SELECT c.id, COALESCE(a."user", ''), '', 'Событие создано.'
FROM approval.cases c
JOIN approval.approves a ON a.id = c.approve_id
WHERE c.event_type = 'surface_junction'
  AND NOT EXISTS (
      SELECT 1 FROM approval.case_messages m WHERE m.case_id = c.id
  );

CREATE OR REPLACE FUNCTION approval.create_primary_case()
RETURNS TRIGGER AS $$
DECLARE
    surface_case_id uuid;
BEGIN
    INSERT INTO approval.cases (approve_id, is_primary, title, status, n_root, owners, event_type)
    VALUES (NEW.id, true, 'Основное событие', 'в работе', NULL, '{}', 'standard');

    INSERT INTO approval.cases (
        approve_id, is_primary, title, status, created_by_login, n_root, owners, event_type
    )
    VALUES (
        NEW.id,
        false,
        'Согласование элементов сопряжения поверхностей',
        'в работе',
        NEW."user",
        NULL,
        NEW.owners,
        'surface_junction'
    )
    RETURNING id INTO surface_case_id;

    INSERT INTO approval.case_messages (case_id, author_login, author_role, body)
    VALUES (surface_case_id, COALESCE(NEW."user", ''), '', 'Событие создано.');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
"""

REVERSE_SQL = """
CREATE OR REPLACE FUNCTION approval.create_primary_case()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO approval.cases (approve_id, is_primary, title, status, n_root, owners)
    VALUES (NEW.id, true, 'Основное событие', 'в работе', NULL, '{}');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DELETE FROM approval.cases WHERE event_type = 'surface_junction';
DROP INDEX IF EXISTS approval.cases_one_surface_junction_per_approve;
ALTER TABLE approval.cases
    DROP COLUMN IF EXISTS event_type;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("approval", "0013_case_service_event_closed_kinds"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
            ],
            state_operations=[
                migrations.AddField(
                    model_name="case",
                    name="event_type",
                    field=models.TextField(
                        choices=[
                            ("standard", "Обычное событие"),
                            (
                                "surface_junction",
                                "Согласование элементов сопряжения поверхностей",
                            ),
                        ],
                        default="standard",
                    ),
                ),
            ],
        ),
    ]

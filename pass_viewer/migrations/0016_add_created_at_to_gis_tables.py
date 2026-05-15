from django.db import migrations


# Hour precision: date_trunc('hour', …). Existing rows get migration-time hour; new rows via DEFAULT + trigger.
FORWARD_SQL = """
CREATE OR REPLACE FUNCTION pass_viewer_set_created_at_hour()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at := date_trunc('hour', CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    tbl text;
BEGIN
    FOREACH tbl IN ARRAY ARRAY['pass_objects', 'odh', 'ozn']
    LOOP
        IF to_regclass('public.' || tbl) IS NULL THEN
            CONTINUE;
        END IF;

        EXECUTE format(
            'ALTER TABLE %I ADD COLUMN IF NOT EXISTS created_at timestamptz',
            tbl
        );
        EXECUTE format(
            'UPDATE %I SET created_at = date_trunc(''hour'', CURRENT_TIMESTAMP) '
            'WHERE created_at IS NULL',
            tbl
        );
        EXECUTE format(
            'ALTER TABLE %I ALTER COLUMN created_at SET DEFAULT date_trunc(''hour'', CURRENT_TIMESTAMP)',
            tbl
        );
        EXECUTE format(
            'ALTER TABLE %I ALTER COLUMN created_at SET NOT NULL',
            tbl
        );
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trg_%I_set_created_at ON %I',
            tbl, tbl
        );
        EXECUTE format(
            'CREATE TRIGGER trg_%I_set_created_at '
            'BEFORE INSERT ON %I '
            'FOR EACH ROW EXECUTE PROCEDURE pass_viewer_set_created_at_hour()',
            tbl, tbl
        );
    END LOOP;
END
$$;
"""

REVERSE_SQL = """
DO $$
DECLARE
    tbl text;
BEGIN
    FOREACH tbl IN ARRAY ARRAY['pass_objects', 'odh', 'ozn']
    LOOP
        IF to_regclass('public.' || tbl) IS NULL THEN
            CONTINUE;
        END IF;
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_set_created_at ON %I', tbl, tbl);
        EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS created_at', tbl);
    END LOOP;
END
$$;

DROP FUNCTION IF EXISTS pass_viewer_set_created_at_hour();
"""


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0015_add_ods_request_short_object_root_id'),
    ]

    operations = [
        migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
    ]

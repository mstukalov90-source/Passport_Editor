from django.db import migrations


FORWARD_SQL = """
DO $$
DECLARE
    col text;
BEGIN
    IF to_regclass('public.auto_remove_square') IS NULL THEN
        RETURN;
    END IF;
    FOREACH col IN ARRAY ARRAY['dt', 'odh', 'ozn', 'top', 'oozt', 'dgi', 'renew', 'rzd', 'summ']
    LOOP
        EXECUTE format(
            'ALTER TABLE auto_remove_square ALTER COLUMN %I TYPE numeric(14, 4)',
            col
        );
    END LOOP;
END $$;
"""

REVERSE_SQL = """
DO $$
DECLARE
    col text;
BEGIN
    IF to_regclass('public.auto_remove_square') IS NULL THEN
        RETURN;
    END IF;
    FOREACH col IN ARRAY ARRAY['dt', 'odh', 'ozn', 'top', 'oozt', 'dgi', 'renew', 'rzd', 'summ']
    LOOP
        EXECUTE format(
            'ALTER TABLE auto_remove_square ALTER COLUMN %I TYPE numeric(12, 1)',
            col
        );
    END LOOP;
END $$;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0020_create_auto_remove_square_table"),
    ]

    operations = [
        migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
    ]

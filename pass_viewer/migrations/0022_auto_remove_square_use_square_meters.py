from django.db import migrations


FORWARD_SQL = """
DO $$
DECLARE
    col text;
BEGIN
    IF to_regclass('public.auto_remove_square') IS NULL THEN
        RETURN;
    END IF;

    -- Предыдущие версии хранили км²; переводим существующие строки в м².
    UPDATE auto_remove_square
    SET
        dt = dt * 1000000,
        odh = odh * 1000000,
        ozn = ozn * 1000000,
        top = top * 1000000,
        oozt = oozt * 1000000,
        dgi = dgi * 1000000,
        renew = renew * 1000000,
        rzd = rzd * 1000000,
        summ = summ * 1000000;

    FOREACH col IN ARRAY ARRAY['dt', 'odh', 'ozn', 'top', 'oozt', 'dgi', 'renew', 'rzd', 'summ']
    LOOP
        EXECUTE format(
            'ALTER TABLE auto_remove_square ALTER COLUMN %I TYPE numeric(14, 1)',
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

    UPDATE auto_remove_square
    SET
        dt = dt / 1000000,
        odh = odh / 1000000,
        ozn = ozn / 1000000,
        top = top / 1000000,
        oozt = oozt / 1000000,
        dgi = dgi / 1000000,
        renew = renew / 1000000,
        rzd = rzd / 1000000,
        summ = summ / 1000000;

    FOREACH col IN ARRAY ARRAY['dt', 'odh', 'ozn', 'top', 'oozt', 'dgi', 'renew', 'rzd', 'summ']
    LOOP
        EXECUTE format(
            'ALTER TABLE auto_remove_square ALTER COLUMN %I TYPE numeric(14, 4)',
            col
        );
    END LOOP;
END $$;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0021_auto_remove_square_precision"),
    ]

    operations = [
        migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
    ]

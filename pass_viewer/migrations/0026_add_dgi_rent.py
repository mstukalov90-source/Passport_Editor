from django.db import migrations

FORWARD_SQL = """
DO $$
BEGIN
    IF to_regclass('public.dgi') IS NULL THEN
        RETURN;
    END IF;

    ALTER TABLE public.dgi
        ADD COLUMN IF NOT EXISTS rent boolean NOT NULL DEFAULT false;

    UPDATE public.dgi
    SET rent = COALESCE(tip_doc_dgi ILIKE '%ДОГОВОР АРЕНДЫ%', false);

    CREATE INDEX IF NOT EXISTS idx_dgi_rent
        ON public.dgi (rent)
        WHERE rent IS TRUE;
END $$;
"""

REVERSE_SQL = """
DROP INDEX IF EXISTS public.idx_dgi_rent;
DO $$
BEGIN
    IF to_regclass('public.dgi') IS NOT NULL THEN
        ALTER TABLE public.dgi DROP COLUMN IF EXISTS rent;
    END IF;
END $$;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0025_add_oozt_rzd_spatial_indexes"),
    ]

    operations = [
        migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
    ]

from django.db import migrations


FORWARD_SQL = """
DO $$
BEGIN
    IF to_regclass('public.dgi') IS NOT NULL THEN
        ALTER TABLE public.dgi
        ADD COLUMN IF NOT EXISTS short_sobstv_rr text NULL;
    END IF;
END $$;
"""

REVERSE_SQL = """
DO $$
BEGIN
    IF to_regclass('public.dgi') IS NOT NULL THEN
        ALTER TABLE public.dgi
        DROP COLUMN IF EXISTS short_sobstv_rr;
    END IF;
END $$;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0018_create_top_table"),
    ]

    operations = [
        migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
    ]

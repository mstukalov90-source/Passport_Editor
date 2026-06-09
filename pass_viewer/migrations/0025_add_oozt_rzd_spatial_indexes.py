from django.db import migrations


CREATE_INDEXES_SQL = """
DO $$
BEGIN
    IF to_regclass('public.oozt') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'oozt' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_oozt_geom_gist ON public.oozt USING GIST (geom)';
    END IF;
    IF to_regclass('public.oozt') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'oozt' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_oozt_request_id ON public.oozt (request_id)';
    END IF;

    IF to_regclass('public.rzd') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'rzd' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_rzd_geom_gist ON public.rzd USING GIST (geom)';
    END IF;
    IF to_regclass('public.rzd') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'rzd' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_rzd_request_id ON public.rzd (request_id)';
    END IF;
END
$$;
"""


DROP_INDEXES_SQL = """
DROP INDEX IF EXISTS public.idx_oozt_geom_gist;
DROP INDEX IF EXISTS public.idx_oozt_request_id;
DROP INDEX IF EXISTS public.idx_rzd_geom_gist;
DROP INDEX IF EXISTS public.idx_rzd_request_id;
"""


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0024_add_dgi_aprove"),
    ]

    operations = [
        migrations.RunSQL(CREATE_INDEXES_SQL, reverse_sql=DROP_INDEXES_SQL),
    ]

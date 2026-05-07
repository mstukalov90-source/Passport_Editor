from django.db import migrations


CREATE_INDEXES_SQL = """
DO $$
BEGIN
    IF to_regclass('public.pass_objects') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'pass_objects' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_pass_objects_geom_gist ON public.pass_objects USING GIST (geom)';
    END IF;
    IF to_regclass('public.pass_objects') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'pass_objects' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_pass_objects_request_id ON public.pass_objects (request_id)';
    END IF;

    IF to_regclass('public.odh') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'odh' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_odh_geom_gist ON public.odh USING GIST (geom)';
    END IF;
    IF to_regclass('public.odh') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'odh' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_odh_request_id ON public.odh (request_id)';
    END IF;

    IF to_regclass('public.dgi') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'dgi' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_dgi_geom_gist ON public.dgi USING GIST (geom)';
    END IF;
    IF to_regclass('public.dgi') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'dgi' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_dgi_request_id ON public.dgi (request_id)';
    END IF;

    IF to_regclass('public.recaps') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'recaps' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_recaps_geom_gist ON public.recaps USING GIST (geom)';
    END IF;
    IF to_regclass('public.recaps') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'recaps' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_recaps_request_id ON public.recaps (request_id)';
    END IF;

    IF to_regclass('public.ozn') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'ozn' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_ozn_geom_gist ON public.ozn USING GIST (geom)';
    END IF;
    IF to_regclass('public.ozn') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'ozn' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_ozn_request_id ON public.ozn (request_id)';
    END IF;

    IF to_regclass('public.renew') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'renew' AND column_name = 'geom'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_renew_geom_gist ON public.renew USING GIST (geom)';
    END IF;
    IF to_regclass('public.renew') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = 'renew' AND column_name = 'request_id'
       ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_renew_request_id ON public.renew (request_id)';
    END IF;
END
$$;
"""


DROP_INDEXES_SQL = """
DROP INDEX IF EXISTS public.idx_pass_objects_geom_gist;
DROP INDEX IF EXISTS public.idx_pass_objects_request_id;
DROP INDEX IF EXISTS public.idx_odh_geom_gist;
DROP INDEX IF EXISTS public.idx_odh_request_id;
DROP INDEX IF EXISTS public.idx_dgi_geom_gist;
DROP INDEX IF EXISTS public.idx_dgi_request_id;
DROP INDEX IF EXISTS public.idx_recaps_geom_gist;
DROP INDEX IF EXISTS public.idx_recaps_request_id;
DROP INDEX IF EXISTS public.idx_ozn_geom_gist;
DROP INDEX IF EXISTS public.idx_ozn_request_id;
DROP INDEX IF EXISTS public.idx_renew_geom_gist;
DROP INDEX IF EXISTS public.idx_renew_request_id;
"""


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0009_deploy_seed_import_tooling'),
    ]

    operations = [
        migrations.RunSQL(CREATE_INDEXES_SQL, reverse_sql=DROP_INDEXES_SQL),
    ]


from django.db import migrations


FORWARD_SQL = """
DO $$
BEGIN
    IF to_regclass('public.pass_objects') IS NULL THEN
        RETURN;
    END IF;

    -- INCLUDING NULLABILITY requires PostgreSQL 15+; DEFAULTS matches 0002/recaps pattern.
    CREATE TABLE IF NOT EXISTS top (
        LIKE pass_objects INCLUDING DEFAULTS
    );

    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind = 'S' AND c.relname = 'top_ogc_fid_seq'
    ) THEN
        CREATE SEQUENCE top_ogc_fid_seq OWNED BY top.ogc_fid;
    END IF;

    ALTER TABLE top ALTER COLUMN ogc_fid SET DEFAULT nextval('top_ogc_fid_seq');

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'top_pkey' AND conrelid = 'public.top'::regclass
    ) THEN
        ALTER TABLE top ADD CONSTRAINT top_pkey PRIMARY KEY (ogc_fid);
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'top' AND column_name = 'geom'
    ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_top_geom_gist ON public.top USING GIST (geom)';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'top' AND column_name = 'request_id'
    ) THEN
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_top_request_id ON public.top (request_id)';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'top' AND column_name = 'created_at'
    ) THEN
        DROP TRIGGER IF EXISTS trg_top_set_created_at ON top;
        CREATE TRIGGER trg_top_set_created_at
        BEFORE INSERT ON top
        FOR EACH ROW EXECUTE PROCEDURE pass_viewer_set_created_at_hour();
    END IF;
END
$$;
"""

REVERSE_SQL = """
DROP TRIGGER IF EXISTS trg_top_set_created_at ON top;
DROP TABLE IF EXISTS top;
DROP SEQUENCE IF EXISTS top_ogc_fid_seq;
"""


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0016_add_created_at_to_gis_tables'),
    ]

    operations = [
        migrations.RunSQL(sql=FORWARD_SQL, reverse_sql=REVERSE_SQL),
    ]

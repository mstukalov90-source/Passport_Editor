from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0011_add_geojson_date_columns'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                CREATE TABLE IF NOT EXISTS hood (
                    gid integer NOT NULL PRIMARY KEY,
                    rayon text NULL,
                    okrug text NULL,
                    okrug_shor text NULL,
                    area double precision NULL,
                    geom geometry(MultiPolygon, 4326) NOT NULL
                );

                CREATE INDEX IF NOT EXISTS hood_geom_gix
                ON hood
                USING GIST (geom);
            """,
            reverse_sql="""
                DROP TABLE IF EXISTS hood;
            """,
        ),
    ]

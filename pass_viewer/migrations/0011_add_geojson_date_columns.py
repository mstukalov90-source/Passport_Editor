from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0010_add_spatial_and_request_indexes'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE pass_objects
                ADD COLUMN IF NOT EXISTS datesurvey timestamptz NULL;

                ALTER TABLE odh
                ADD COLUMN IF NOT EXISTS startdate timestamptz NULL;

                ALTER TABLE odh
                ADD COLUMN IF NOT EXISTS datesurvey timestamptz NULL;

                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS startdate timestamptz NULL;

                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS datesurvey timestamptz NULL;

                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS createtype text NULL;
            """,
            reverse_sql="""
                ALTER TABLE pass_objects
                DROP COLUMN IF EXISTS datesurvey;

                ALTER TABLE odh
                DROP COLUMN IF EXISTS startdate;

                ALTER TABLE odh
                DROP COLUMN IF EXISTS datesurvey;

                ALTER TABLE ozn
                DROP COLUMN IF EXISTS startdate;

                ALTER TABLE ozn
                DROP COLUMN IF EXISTS datesurvey;

                ALTER TABLE ozn
                DROP COLUMN IF EXISTS createtype;
            """,
        ),
    ]

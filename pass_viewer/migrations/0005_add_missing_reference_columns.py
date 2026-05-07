from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0004_create_ozn_table'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS departmentlegalpersonid text NULL;

                ALTER TABLE odh
                ADD COLUMN IF NOT EXISTS grbslegalpersonid integer NULL;
            """,
            reverse_sql="""
                ALTER TABLE ozn
                DROP COLUMN IF EXISTS departmentlegalpersonid;

                ALTER TABLE odh
                DROP COLUMN IF EXISTS grbslegalpersonid;
            """,
        ),
    ]

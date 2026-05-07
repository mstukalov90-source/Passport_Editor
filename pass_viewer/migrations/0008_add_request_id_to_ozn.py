from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0007_create_renew_table'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS request_id text NULL;
            """,
            reverse_sql="""
                ALTER TABLE ozn
                DROP COLUMN IF EXISTS request_id;
            """,
        ),
    ]

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0014_create_ods_request_table'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE ods_request
                ADD COLUMN IF NOT EXISTS "ShortObjectRootId" bigint NULL;
            """,
            reverse_sql="""
                ALTER TABLE ods_request
                DROP COLUMN IF EXISTS "ShortObjectRootId";
            """,
        ),
    ]

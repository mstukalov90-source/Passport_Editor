from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0005_add_missing_reference_columns'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS ownerlegalpersonalid text NULL;
            """,
            reverse_sql="""
                ALTER TABLE ozn
                DROP COLUMN IF EXISTS ownerlegalpersonalid;
            """,
        ),
    ]

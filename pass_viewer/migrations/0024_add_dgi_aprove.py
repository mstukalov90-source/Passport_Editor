from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0023_auto_remove_square_add_type"),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE pass_objects
                ADD COLUMN IF NOT EXISTS dgi_aprove jsonb NULL;

                ALTER TABLE odh
                ADD COLUMN IF NOT EXISTS dgi_aprove jsonb NULL;

                ALTER TABLE ozn
                ADD COLUMN IF NOT EXISTS dgi_aprove jsonb NULL;

                ALTER TABLE top
                ADD COLUMN IF NOT EXISTS dgi_aprove jsonb NULL;

                ALTER TABLE recaps
                ADD COLUMN IF NOT EXISTS dgi_aprove jsonb NULL;
            """,
            reverse_sql="""
                ALTER TABLE pass_objects DROP COLUMN IF EXISTS dgi_aprove;
                ALTER TABLE odh DROP COLUMN IF EXISTS dgi_aprove;
                ALTER TABLE ozn DROP COLUMN IF EXISTS dgi_aprove;
                ALTER TABLE top DROP COLUMN IF EXISTS dgi_aprove;
                ALTER TABLE recaps DROP COLUMN IF EXISTS dgi_aprove;
            """,
        ),
    ]

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0022_auto_remove_square_use_square_meters"),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE auto_remove_square
                ADD COLUMN IF NOT EXISTS "type" text NULL;
            """,
            reverse_sql="""
                ALTER TABLE auto_remove_square
                DROP COLUMN IF EXISTS "type";
            """,
        ),
    ]

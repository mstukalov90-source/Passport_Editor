from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0029_create_dgi_intersection_results"),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE dgi_intersection_results
                ADD COLUMN IF NOT EXISTS pct_dgi_renovation numeric(8,2) NOT NULL DEFAULT 0;
            """,
            reverse_sql="""
                ALTER TABLE dgi_intersection_results
                DROP COLUMN IF EXISTS pct_dgi_renovation;
            """,
        ),
    ]

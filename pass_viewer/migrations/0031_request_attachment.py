from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0030_dgi_intersection_pct_dgi_renovation"),
    ]

    operations = [
        migrations.CreateModel(
            name="RequestAttachment",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("brid", models.CharField(db_index=True, max_length=32)),
                ("original_name", models.TextField()),
                ("stored_name", models.TextField()),
                ("content_type", models.TextField(blank=True, default="")),
                ("size_bytes", models.BigIntegerField()),
                ("uploaded_by", models.CharField(blank=True, default="", max_length=150)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
            ],
            options={
                "db_table": "request_attachments",
                "ordering": ["-created_at"],
            },
        ),
    ]

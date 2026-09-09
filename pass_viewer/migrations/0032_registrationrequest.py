from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("pass_viewer", "0031_request_attachment"),
    ]

    operations = [
        migrations.CreateModel(
            name="RegistrationRequest",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("executive_authority", models.CharField(max_length=255)),
                ("institution_name", models.CharField(max_length=255)),
                ("representative_name", models.CharField(max_length=255)),
                ("position", models.CharField(max_length=255)),
                ("phone", models.CharField(max_length=50)),
                ("email", models.EmailField(max_length=254)),
                (
                    "status",
                    models.CharField(
                        choices=[("new", "Новая"), ("processed", "Обработана")],
                        default="new",
                        max_length=16,
                    ),
                ),
                ("created_at", models.DateTimeField(auto_now_add=True)),
            ],
            options={
                "db_table": "registration_requests",
                "ordering": ["-created_at"],
            },
        ),
    ]

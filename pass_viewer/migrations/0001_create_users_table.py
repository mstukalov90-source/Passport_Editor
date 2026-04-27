from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name='ExternalUser',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('login', models.CharField(max_length=150, unique=True)),
                ('password', models.CharField(max_length=255)),
                (
                    'owner_legal_person_id',
                    models.CharField(
                        blank=True,
                        db_column='OwnerLegalPersonId',
                        max_length=255,
                        null=True,
                    ),
                ),
            ],
            options={
                'db_table': 'users',
            },
        ),
    ]

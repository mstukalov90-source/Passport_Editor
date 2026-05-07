"""
Placeholder migration for deploy workflows.

Load reference data from flat files after schema migrations (see management command
``import_seed_from_files``). This migration does not modify the database or load files;
it exists so environments that expect a new migration after tooling changes apply cleanly.

Operational steps (manual / CI):
  python manage.py migrate
  python manage.py import_seed_from_files --all
"""

from django.db import migrations


def _noop(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    dependencies = [
        ('pass_viewer', '0008_add_request_id_to_ozn'),
    ]

    operations = [
        migrations.RunPython(_noop, _noop),
    ]

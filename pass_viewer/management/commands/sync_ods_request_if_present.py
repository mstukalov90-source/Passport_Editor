"""
Daily sync: reload ods_request from ods_request.json if the file exists.

Intended for cron at 12:00 Europe/Moscow. If the file is missing, exits 0 without
touching the database. On success, deletes the JSON file.

Examples:
  python manage.py sync_ods_request_if_present
  python manage.py sync_ods_request_if_present --path /data/incoming/ods_request.json
  python manage.py sync_ods_request_if_present --dry-run
"""

from __future__ import annotations

from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from pass_viewer.data_import.json_loaders import import_ods_request


class Command(BaseCommand):
    help = (
        "If ods_request.json exists, truncate and reload ods_request, then delete the file. "
        "If missing, exit successfully without changes."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--path",
            type=Path,
            default=None,
            help="Path to ods_request.json (default: BASE_DIR/ods_request.json).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report row count only; do not write to DB or delete the file.",
        )

    def handle(self, *args, **options):
        path: Path = (options["path"] or Path(settings.BASE_DIR) / "ods_request.json").expanduser().resolve()
        dry_run: bool = options["dry_run"]

        if not path.is_file():
            self.stdout.write(f"No file at {path}; nothing to do.")
            return

        try:
            inserted, _ = import_ods_request(path, dry_run=dry_run)
        except Exception as exc:
            raise CommandError(f"ods_request import failed: {exc}") from exc

        if dry_run:
            self.stdout.write(
                self.style.SUCCESS(f"[dry-run] would reload ods_request with up to {inserted} rows from {path}")
            )
            return

        path.unlink()
        self.stdout.write(self.style.SUCCESS(f"ods_request: reloaded {inserted} rows; removed {path}"))

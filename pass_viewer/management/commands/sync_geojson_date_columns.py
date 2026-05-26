"""
Fill StartDate / DateSurvey / CreateType on pass_objects, odh, ozn from large GeoJSON files.

Requires columns created by migration 0011_add_geojson_date_columns (uses IF NOT EXISTS).
Streams features with ijson; updates rows in batches (does not truncate).

Example:
  python manage.py sync_geojson_date_columns --table pass_objects
  python manage.py sync_geojson_date_columns --table odh --path /data/odh.geojson --batch-size 2000
"""

from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from pass_viewer.data_import.geojson_column_sync import SPECS, sync_table


class Command(BaseCommand):
    help = (
        "Update startdate, datesurvey, createtype from GeoJSON properties "
        "(matched by objectid for pass_objects/odh, rootid for ozn)."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--table",
            required=True,
            choices=sorted(SPECS.keys()),
            help="Target table name.",
        )
        parser.add_argument(
            "--path",
            type=str,
            default=None,
            help="GeoJSON path (default: BASE_DIR/<table>.geojson).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Parse file and count rows only; no database writes.",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=1000,
            help="Number of UPDATE rows per statement (default: 1000).",
        )

    def handle(self, *args, **options):
        table: str = options["table"]
        root = Path(settings.BASE_DIR)
        path = Path(options["path"]).expanduser().resolve() if options["path"] else root / f"{table}.geojson"
        if not path.exists():
            raise CommandError(f"File not found: {path}")

        dry_run: bool = options["dry_run"]
        batch_size: int = options["batch_size"]
        if batch_size < 1:
            raise CommandError("--batch-size must be >= 1")

        self.stdout.write(f"Table={table} file={path} dry_run={dry_run} batch_size={batch_size}")

        seen, batched, skipped = sync_table(table, str(path), dry_run=dry_run, batch_size=batch_size)

        self.stdout.write(
            self.style.SUCCESS(
                f"Features seen: {seen}; batches flushed (rows): {batched}; skipped (no join key): {skipped}."
            )
        )

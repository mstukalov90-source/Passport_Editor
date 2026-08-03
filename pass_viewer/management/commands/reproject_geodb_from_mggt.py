"""
Reproject geodb GIS geometries from mggt_asu using MSC-77 proj4text (SRID 980077).

Geometry-only update (attrs unchanged). For full daily sync (attrs + INSERT/DELETE +
ods_request + dgi.rent) use ``sync_geodb_from_mggt``.

Read-only against DATABASES['qgis']; writes only to DATABASES['default'] (geodb).

Examples:
  python manage.py reproject_geodb_from_mggt --dry-run
  python manage.py reproject_geodb_from_mggt --table pass_objects
  python manage.py reproject_geodb_from_mggt --batch-size 2000
"""

from __future__ import annotations

from django.core.management.base import BaseCommand, CommandError
from django.db import connections
from django.db.utils import OperationalError

from pass_viewer.data_import.reproject_geodb_from_mggt import (
    TABLE_ORDER,
    resolve_tables,
    sync_keyed_table,
    sync_rzd,
)


class Command(BaseCommand):
    help = (
        "Reproject geometries from mggt_asu into local geodb using "
        "spatial_ref_sys.proj4text for SRID 980077 (MSC-77 → WGS84)."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report source/geodb counts only; no writes to geodb.",
        )
        parser.add_argument(
            "--table",
            type=str,
            default=None,
            help=f"Only this table ({', '.join(TABLE_ORDER)}). Default: all.",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=2000,
            help="Rows per UPDATE batch for keyed tables (default: 2000).",
        )

    def handle(self, *args, **options):
        dry_run: bool = options["dry_run"]
        batch_size: int = options["batch_size"]
        if batch_size < 1:
            raise CommandError("--batch-size must be >= 1")

        try:
            tables = resolve_tables(options["table"])
        except ValueError as exc:
            raise CommandError(str(exc)) from exc

        self._check_connections()

        mode = "dry-run" if dry_run else "WRITE geodb"
        self.stdout.write(
            f"mode={mode} tables={','.join(tables)} batch_size={batch_size} "
            f"(mggt_asu=read-only)"
        )
        self.stdout.flush()

        for name in tables:
            self.stdout.write(f"--- {name} starting ---")
            self.stdout.flush()
            try:
                if name == "rzd":
                    stats = sync_rzd(dry_run=dry_run)
                else:
                    stats = sync_keyed_table(
                        name, dry_run=dry_run, batch_size=batch_size
                    )
            except OperationalError as exc:
                raise CommandError(f"Database error on {name}: {exc}") from exc
            except Exception as exc:
                raise CommandError(f"{name}: {exc}") from exc

            if dry_run:
                self.stdout.write(
                    self.style.SUCCESS(
                        f"[dry-run] {name}: source_rows={stats['source_rows']} "
                        f"geodb_keys={stats['geodb_keys']}"
                    )
                )
            else:
                self.stdout.write(
                    self.style.SUCCESS(
                        f"{name}: source_rows={stats['source_rows']} "
                        f"updated_or_inserted={stats['updated']}"
                    )
                )
            self.stdout.flush()

    def _check_connections(self) -> None:
        for alias in ("default", "qgis"):
            try:
                with connections[alias].cursor() as cursor:
                    cursor.execute("SELECT 1")
                    cursor.fetchone()
            except OperationalError as exc:
                raise CommandError(
                    f"Cannot connect to DATABASES[{alias!r}]: {exc}"
                ) from exc

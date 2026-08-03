"""
Daily full sync: mggt_asu (read-only) → geodb.

Compares attrs + MSC-77 reprojected geometry; INSERT/UPDATE/DELETE orphans.
ods_request is loaded from master.bidregistry with status/date filters.
After dgi sync, recomputes dgi.rent.

Examples:
  python manage.py sync_geodb_from_mggt --dry-run
  python manage.py sync_geodb_from_mggt --table dgi
  python manage.py sync_geodb_from_mggt --batch-size 2000
"""

from __future__ import annotations

from django.core.management.base import BaseCommand, CommandError
from django.db import connections
from django.db.utils import OperationalError

from pass_viewer.data_import.sync_geodb_from_mggt import (
    FULL_TABLE_ORDER,
    resolve_sync_tables,
    run_full_sync,
)


class Command(BaseCommand):
    help = (
        "Sync geodb GIS tables and ods_request from mggt_asu (read-only). "
        "Reprojects geometries via spatial_ref_sys SRID 980077. "
        "Preserves pass_objects/odh/ozn rows with NULL rootid and non-empty request_id."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report counts only; no persistent writes to geodb.",
        )
        parser.add_argument(
            "--table",
            type=str,
            default=None,
            help=f"Only this table ({', '.join(FULL_TABLE_ORDER)}). Default: all.",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=2000,
            help="Rows per staging batch for keyed tables (default: 2000).",
        )

    def handle(self, *args, **options):
        dry_run: bool = options["dry_run"]
        batch_size: int = options["batch_size"]
        if batch_size < 1:
            raise CommandError("--batch-size must be >= 1")

        try:
            tables = resolve_sync_tables(options["table"])
        except ValueError as exc:
            raise CommandError(str(exc)) from exc

        self._check_connections(tables)

        mode = "dry-run" if dry_run else "WRITE geodb"
        self.stdout.write(
            f"mode={mode} tables={','.join(tables)} batch_size={batch_size} "
            f"(mggt_asu=read-only)"
        )
        self.stdout.flush()

        try:
            results = run_full_sync(
                tables, dry_run=dry_run, batch_size=batch_size
            )
        except OperationalError as exc:
            raise CommandError(f"Database error: {exc}") from exc
        except Exception as exc:
            raise CommandError(str(exc)) from exc

        for name, stats in results:
            if name == "dgi.rent":
                self.stdout.write(
                    self.style.SUCCESS(
                        f"dgi.rent: updated={stats.get('updated', 0)} "
                        f"TRUE={stats.get('true_count', 0)} "
                        f"FALSE={stats.get('false_count', 0)}"
                    )
                )
                continue
            prefix = "[dry-run] " if dry_run else ""
            self.stdout.write(
                self.style.SUCCESS(
                    f"{prefix}{name}: source={stats.get('source_rows', 0)} "
                    f"inserted={stats.get('inserted', 0)} "
                    f"updated={stats.get('updated', 0)} "
                    f"deleted={stats.get('deleted', 0)}"
                    + (
                        f" geodb_keys={stats['geodb_keys']}"
                        if dry_run and stats.get("geodb_keys")
                        else ""
                    )
                )
            )
            self.stdout.flush()

    def _check_connections(self, tables: list[str]) -> None:
        del tables  # both aliases always required
        for alias in ("default", "qgis"):
            try:
                with connections[alias].cursor() as cursor:
                    cursor.execute("SELECT 1")
                    cursor.fetchone()
            except OperationalError as exc:
                raise CommandError(
                    f"Cannot connect to DATABASES[{alias!r}]: {exc}"
                ) from exc

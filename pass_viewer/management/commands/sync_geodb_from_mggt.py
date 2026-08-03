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

from pass_viewer.data_import.dgi_rent import set_dgi_rent
from pass_viewer.data_import.reproject_geodb_from_mggt import sync_rzd
from pass_viewer.data_import.sync_geodb_from_mggt import (
    FULL_TABLE_ORDER,
    resolve_sync_tables,
    sync_keyed_table_full,
    sync_ods_request_from_bidregistry,
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

        self._check_connections()

        mode = "dry-run" if dry_run else "WRITE geodb"
        self.stdout.write(
            f"mode={mode} tables={','.join(tables)} batch_size={batch_size} "
            f"(mggt_asu=read-only)"
        )
        self.stdout.flush()

        # Process one table at a time so partial progress is visible on failure.
        for name in tables:
            self.stdout.write(f"--- {name} starting ---")
            self.stdout.flush()
            try:
                if name == "rzd":
                    raw = sync_rzd(dry_run=dry_run)
                    stats = {
                        "source_rows": raw.get("source_rows", 0),
                        "inserted": raw.get("updated", 0) if not dry_run else 0,
                        "updated": 0,
                        "deleted": raw.get("geodb_keys", 0) if dry_run else 0,
                        "geodb_keys": raw.get("geodb_keys", 0),
                    }
                elif name == "ods_request":
                    stats = sync_ods_request_from_bidregistry(dry_run=dry_run)
                else:
                    stats = sync_keyed_table_full(
                        name, dry_run=dry_run, batch_size=batch_size
                    )
            except OperationalError as exc:
                raise CommandError(f"Database error on {name}: {exc}") from exc
            except Exception as exc:
                raise CommandError(f"{name}: {exc}") from exc

            prefix = "[dry-run] " if dry_run else ""
            extra = ""
            if dry_run and stats.get("geodb_keys"):
                extra += f" geodb_keys={stats['geodb_keys']}"
            if name == "ods_request" and dry_run:
                if "ownerid_filled" in stats:
                    extra += (
                        f" ownerid_filled={stats['ownerid_filled']}"
                        f" grbsid_filled={stats['grbsid_filled']}"
                    )
            self.stdout.write(
                self.style.SUCCESS(
                    f"{prefix}{name}: source={stats.get('source_rows', 0)} "
                    f"inserted={stats.get('inserted', 0)} "
                    f"updated={stats.get('updated', 0)} "
                    f"deleted={stats.get('deleted', 0)}"
                    + extra
                )
            )
            self.stdout.flush()

            if name == "dgi" and not dry_run:
                try:
                    rent_stats = set_dgi_rent(dry_run=False)
                except Exception as exc:
                    raise CommandError(f"dgi.rent: {exc}") from exc
                self.stdout.write(
                    self.style.SUCCESS(
                        f"dgi.rent: updated={rent_stats.get('updated', 0)} "
                        f"TRUE={rent_stats.get('true_count', 0)} "
                        f"FALSE={rent_stats.get('false_count', 0)}"
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

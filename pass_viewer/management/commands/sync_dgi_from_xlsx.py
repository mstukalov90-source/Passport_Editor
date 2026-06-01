"""
Sync short_sobstv_rr (and optionally address / sobstv_rr) from dgi.xlsx into the dgi table.

Match key: descr (trimmed text). New descr values are inserted; geometry uses NULL or an empty
polygon placeholder when geom is NOT NULL.

Examples:
  python manage.py sync_dgi_from_xlsx --dry-run
  python manage.py sync_dgi_from_xlsx --path /data/dgi.xlsx --sync-attrs
"""

from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from pass_viewer.data_import.dgi_xlsx_sync import sync_dgi_from_xlsx


class Command(BaseCommand):
    help = "Update/insert dgi rows from dgi.xlsx (matched by descr)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--path",
            type=str,
            default=None,
            help="Path to dgi.xlsx (default: BASE_DIR/dgi.xlsx).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Parse file and report counts only; no database writes.",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=2000,
            help="Rows per UPDATE/INSERT batch (default: 2000).",
        )
        parser.add_argument(
            "--sync-attrs",
            action="store_true",
            help="Also update address and sobstv_rr when xlsx cells are non-empty.",
        )
        parser.add_argument(
            "--srid",
            type=int,
            default=4326,
            help="SRID for placeholder geometry on INSERT when geom is NOT NULL (default: 4326).",
        )

    def handle(self, *args, **options):
        root = Path(settings.BASE_DIR)
        path = Path(options["path"]).expanduser().resolve() if options["path"] else root / "dgi.xlsx"
        if not path.exists():
            raise CommandError(f"File not found: {path}")

        table = getattr(settings, "GIS_DGI_TABLE", "dgi")
        dry_run: bool = options["dry_run"]
        batch_size: int = options["batch_size"]
        if batch_size < 1:
            raise CommandError("--batch-size must be >= 1")

        self.stdout.write(
            f"table={table} file={path} dry_run={dry_run} batch_size={batch_size} "
            f"sync_attrs={options['sync_attrs']} srid={options['srid']}"
        )

        try:
            stats = sync_dgi_from_xlsx(
                path,
                table_name=table,
                dry_run=dry_run,
                batch_size=batch_size,
                sync_attrs=options["sync_attrs"],
                target_srid=options["srid"],
            )
        except (FileNotFoundError, ValueError) as exc:
            raise CommandError(str(exc)) from exc

        self.stdout.write(
            self.style.SUCCESS(
                f"Rows in file (unique descr): {stats.rows_seen}; skipped (empty descr): {stats.skipped_empty_descr}; "
                f"duplicate descr in file (last wins): {stats.duplicate_descr_in_file}; "
                f"batches: {stats.batches}; updated: {stats.updated}; inserted: {stats.inserted}; "
                f"inserted with placeholder geom: {stats.inserted_placeholder_geom}; "
                f"approx. no DB match on update: {stats.no_match}."
            )
        )
        if stats.inserted_placeholder_geom and not dry_run:
            self.stdout.write(
                self.style.WARNING(
                    f"{stats.inserted_placeholder_geom} new row(s) got POLYGON EMPTY geometry "
                    f"(SRID {options['srid']}); replace with real geometry when available."
                )
            )

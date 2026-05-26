"""
Delete GIS rows whose request_id is not in ods_request."BrId" and created_at is older than N days.

Only rows with a non-empty request_id are considered. Intended for cron at 04:20 Europe/Moscow.

Examples:
  python manage.py cleanup_orphan_gis_rows
  python manage.py cleanup_orphan_gis_rows --days 40 --dry-run
"""

from __future__ import annotations

from datetime import timedelta

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import connection, transaction
from django.utils import timezone


def _table_exists(cursor, table_name: str) -> bool:
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = %s
        LIMIT 1
        """,
        [table_name],
    )
    return cursor.fetchone() is not None


def _column_exists(cursor, table_name: str, column_name: str) -> bool:
    cursor.execute(
        """
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = %s
          AND lower(column_name) = lower(%s)
        LIMIT 1
        """,
        [table_name, column_name],
    )
    return cursor.fetchone() is not None


_ORPHAN_WHERE = """
    t.created_at < %s
    AND NULLIF(BTRIM(t.request_id::text), '') IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM ods_request o
        WHERE o."BrId" IS NOT NULL
          AND LOWER(BTRIM(o."BrId"::text)) = LOWER(BTRIM(t.request_id::text))
    )
"""


class Command(BaseCommand):
    help = (
        "Delete pass_objects / odh / ozn rows with request_id not in ods_request.BrId "
        "and created_at older than --days (default 40)."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--days",
            type=int,
            default=40,
            help="Only rows with created_at before now minus this many days (default: 40).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Count matching rows without deleting.",
        )

    def handle(self, *args, **options):
        days: int = options["days"]
        dry_run: bool = options["dry_run"]

        if days < 1:
            raise CommandError("--days must be >= 1")

        cutoff = timezone.now() - timedelta(days=days)
        tables = [
            "pass_objects",
            getattr(settings, "GIS_ODH_TABLE", "odh"),
            "ozn",
        ]
        ods_table = getattr(settings, "GIS_ODS_REQUEST_TABLE", "ods_request")

        total = 0
        with transaction.atomic():
            with connection.cursor() as cursor:
                if not _table_exists(cursor, ods_table):
                    raise CommandError(f"Table {ods_table!r} does not exist; cannot match BrId.")

                for table in tables:
                    if not _table_exists(cursor, table):
                        self.stdout.write(self.style.WARNING(f"Skip {table}: table not found."))
                        continue
                    if not _column_exists(cursor, table, "request_id"):
                        self.stdout.write(self.style.WARNING(f"Skip {table}: no request_id column."))
                        continue
                    if not _column_exists(cursor, table, "created_at"):
                        self.stdout.write(self.style.WARNING(f"Skip {table}: no created_at column."))
                        continue

                    if dry_run:
                        cursor.execute(
                            f"SELECT COUNT(*) FROM {table} t WHERE {_ORPHAN_WHERE}",
                            [cutoff],
                        )
                        count = cursor.fetchone()[0]
                    else:
                        cursor.execute(
                            f"DELETE FROM {table} t WHERE {_ORPHAN_WHERE}",
                            [cutoff],
                        )
                        count = cursor.rowcount

                    total += count
                    verb = "would delete" if dry_run else "deleted"
                    self.stdout.write(f"{table}: {verb} {count} row(s)")

        prefix = "[dry-run] total would delete" if dry_run else "total deleted"
        self.stdout.write(
            self.style.SUCCESS(f"{prefix} {total} row(s) (cutoff created_at < {cutoff.isoformat()})")
        )

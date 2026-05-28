"""
Delete pass_comment_points rows whose request_id is not in pass_objects / odh / ozn
and created_at is older than N days.

Only rows with a non-empty request_id are considered. Intended for cron at 04:20 Europe/Moscow.

Examples:
  python manage.py cleanup_orphan_comment_points
  python manage.py cleanup_orphan_comment_points --days 40 --dry-run
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


def _not_exists_ref_clause(ref_table: str, alias: str) -> str:
    return f"""
    AND NOT EXISTS (
        SELECT 1 FROM {ref_table} {alias}
        WHERE NULLIF(BTRIM({alias}.request_id::text), '') IS NOT NULL
          AND LOWER(BTRIM({alias}.request_id::text)) = LOWER(BTRIM(t.request_id::text))
    )"""


def _build_orphan_where(ref_tables: list[str]) -> str:
    base = """
    t.created_at < %s
    AND NULLIF(BTRIM(t.request_id::text), '') IS NOT NULL
"""
    for i, table in enumerate(ref_tables):
        base += _not_exists_ref_clause(table, f"ref{i}")
    return base


class Command(BaseCommand):
    help = (
        "Delete pass_comment_points rows with request_id not in pass_objects / odh / ozn "
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
        comment_table = getattr(settings, "GIS_COMMENT_POINTS_TABLE", "pass_comment_points")
        ref_candidates = [
            "pass_objects",
            getattr(settings, "GIS_ODH_TABLE", "odh"),
            "ozn",
            getattr(settings, "GIS_TOP_TABLE", "top"),
        ]

        with transaction.atomic():
            with connection.cursor() as cursor:
                if not _table_exists(cursor, comment_table):
                    self.stdout.write(
                        self.style.WARNING(f"Skip {comment_table}: table not found.")
                    )
                    return
                if not _column_exists(cursor, comment_table, "request_id"):
                    self.stdout.write(
                        self.style.WARNING(f"Skip {comment_table}: no request_id column.")
                    )
                    return
                if not _column_exists(cursor, comment_table, "created_at"):
                    self.stdout.write(
                        self.style.WARNING(f"Skip {comment_table}: no created_at column.")
                    )
                    return

                ref_tables: list[str] = []
                for table in ref_candidates:
                    if not _table_exists(cursor, table):
                        self.stdout.write(self.style.WARNING(f"Skip ref {table}: table not found."))
                        continue
                    if not _column_exists(cursor, table, "request_id"):
                        self.stdout.write(
                            self.style.WARNING(f"Skip ref {table}: no request_id column.")
                        )
                        continue
                    ref_tables.append(table)

                if not ref_tables:
                    raise CommandError(
                        "No reference tables (pass_objects / odh / ozn) with request_id; "
                        "cannot determine orphans."
                    )

                orphan_where = _build_orphan_where(ref_tables)

                if dry_run:
                    cursor.execute(
                        f"SELECT COUNT(*) FROM {comment_table} t WHERE {orphan_where}",
                        [cutoff],
                    )
                    count = cursor.fetchone()[0]
                else:
                    cursor.execute(
                        f"DELETE FROM {comment_table} t WHERE {orphan_where}",
                        [cutoff],
                    )
                    count = cursor.rowcount

        verb = "would delete" if dry_run else "deleted"
        self.stdout.write(f"{comment_table}: {verb} {count} row(s)")

        prefix = "[dry-run] total would delete" if dry_run else "total deleted"
        self.stdout.write(
            self.style.SUCCESS(f"{prefix} {count} row(s) (cutoff created_at < {cutoff.isoformat()})")
        )

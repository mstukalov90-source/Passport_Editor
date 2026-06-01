"""
Remove export files under media/exports older than N days.

Intended for cron at 04:20 Europe/Moscow.

Examples:
  python manage.py cleanup_media_exports
  python manage.py cleanup_media_exports --days 7 --dry-run
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone


class Command(BaseCommand):
    help = "Delete files in media/exports older than --days (default 7)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--days",
            type=int,
            default=7,
            help="Delete files with mtime older than this many days (default: 7).",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report what would be deleted without removing files.",
        )

    def handle(self, *args, **options):
        days: int = options["days"]
        dry_run: bool = options["dry_run"]

        if days < 1:
            raise CommandError("--days must be >= 1")

        export_root = Path(settings.MEDIA_ROOT) / "exports"
        if not export_root.is_dir():
            self.stdout.write(f"No directory at {export_root}; nothing to do.")
            return

        cutoff = timezone.now() - timedelta(days=days)
        files_removed = 0
        bytes_removed = 0
        dirs_removed = 0

        stale_files: list[Path] = []
        for path in export_root.rglob("*"):
            if not path.is_file():
                continue
            mtime = datetime.fromtimestamp(path.stat().st_mtime, tz=UTC)
            if timezone.is_naive(mtime):
                mtime = timezone.make_aware(mtime, UTC)
            if mtime < cutoff:
                stale_files.append(path)

        for path in sorted(stale_files, key=lambda p: len(p.parts), reverse=True):
            size = path.stat().st_size
            if dry_run:
                self.stdout.write(f"[dry-run] would delete file {path} ({size} bytes)")
            else:
                path.unlink(missing_ok=True)
            files_removed += 1
            bytes_removed += size

        if not dry_run:
            all_dirs = sorted(
                (p for p in export_root.rglob("*") if p.is_dir()),
                key=lambda p: len(p.parts),
                reverse=True,
            )
            for path in all_dirs:
                if path == export_root:
                    continue
                try:
                    next(path.iterdir())
                except StopIteration:
                    path.rmdir()
                    dirs_removed += 1

        prefix = "[dry-run] would remove" if dry_run else "removed"
        self.stdout.write(
            self.style.SUCCESS(
                f"{prefix} {files_removed} file(s), {bytes_removed} bytes, {dirs_removed} empty dir(s) "
                f"under {export_root} (older than {days} day(s), cutoff {cutoff.isoformat()})"
            )
        )

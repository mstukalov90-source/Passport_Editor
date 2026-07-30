"""
Recompute public.dgi.rent from tip_doc_dgi.

Rule (same as Excel AutoFilter on tip_doc_dgi):
  tip_doc_dgi ILIKE '%ДОГОВОР АРЕНДЫ%'

Examples:
  python manage.py set_dgi_rent
  python manage.py set_dgi_rent --dry-run
"""

from django.core.management.base import BaseCommand, CommandError

from pass_viewer.data_import.dgi_rent import RENT_SQL_PREDICATE, set_dgi_rent


class Command(BaseCommand):
    help = (
        "Set dgi.rent from tip_doc_dgi "
        f"({RENT_SQL_PREDICATE})."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Count rows that would be TRUE/FALSE without writing.",
        )

    def handle(self, *args, **options):
        dry_run: bool = options["dry_run"]
        try:
            stats = set_dgi_rent(dry_run=dry_run)
        except ValueError as exc:
            raise CommandError(str(exc)) from exc

        prefix = "[dry-run] " if dry_run else ""
        self.stdout.write(
            self.style.SUCCESS(
                f"{prefix}rent=TRUE: {stats['true_count']}, "
                f"rent=FALSE: {stats['false_count']}"
                + ("" if dry_run else f", updated={stats['updated']}")
            )
        )

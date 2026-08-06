"""
Recompute DGI intersection percents for all GIS passports/requests
and store the snapshot in public.dgi_intersection_results.

Intended to run daily after sync_geodb_from_mggt.

Examples:
  python manage.py compute_dgi_intersections
  python manage.py compute_dgi_intersections --limit 20
  python manage.py compute_dgi_intersections --rayon Замосковоречье
"""

from django.core.management.base import BaseCommand, CommandError

from pass_viewer.dgi_intersection_batch import run_dgi_intersection_batch


class Command(BaseCommand):
    help = (
        "Compute DGI intersection percents for all GIS passports/requests "
        "and replace dgi_intersection_results."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--limit",
            type=int,
            default=None,
            help="Process at most N objects (for debugging).",
        )
        parser.add_argument(
            "--rayon",
            type=str,
            default=None,
            help="Only objects intersecting hood.rayon (ILIKE %%value%%).",
        )

    def handle(self, *args, **options):
        limit = options.get("limit")
        if limit is not None and limit < 1:
            raise CommandError("--limit must be a positive integer.")
        rayon = options.get("rayon")

        def progress(msg: str) -> None:
            self.stdout.write(msg, ending="\n")

        try:
            stats = run_dgi_intersection_batch(
                limit=limit,
                rayon=rayon,
                progress=progress,
            )
        except ValueError as exc:
            raise CommandError(str(exc)) from exc

        self.stdout.write(
            self.style.SUCCESS(
                f"Done: scanned={stats['scanned']}, stored={stats['stored']}, "
                f"errors={stats['errors']}"
            )
        )

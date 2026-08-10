"""
Recompute DGI intersection percents for all GIS passports/requests
and store the snapshot in public.dgi_intersection_results.

Intended to run daily after sync_geodb_from_mggt.

Writes in chunks and skips objects that hit PostgreSQL statement_timeout.

Examples:
  python manage.py compute_dgi_intersections
  python manage.py compute_dgi_intersections --limit 20
  python manage.py compute_dgi_intersections --rayon Замосковоречье
  python manage.py compute_dgi_intersections --chunk-size 25 --object-timeout 20
"""

from django.core.management.base import BaseCommand, CommandError

from pass_viewer.dgi_intersection_batch import run_dgi_intersection_batch


class Command(BaseCommand):
    help = (
        "Compute DGI intersection percents for all GIS passports/requests "
        "and replace dgi_intersection_results (chunked writes, per-object timeout)."
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
        parser.add_argument(
            "--chunk-size",
            type=int,
            default=50,
            help="Commit INSERT every N successful objects (default: 50).",
        )
        parser.add_argument(
            "--object-timeout",
            type=float,
            default=30.0,
            help="PostgreSQL statement_timeout per object in seconds (default: 30).",
        )

    def handle(self, *args, **options):
        limit = options.get("limit")
        if limit is not None and limit < 1:
            raise CommandError("--limit must be a positive integer.")
        chunk_size = options.get("chunk_size") or 50
        if chunk_size < 1:
            raise CommandError("--chunk-size must be >= 1.")
        object_timeout = options.get("object_timeout")
        if object_timeout is None or float(object_timeout) <= 0:
            raise CommandError("--object-timeout must be > 0.")
        rayon = options.get("rayon")

        def progress(msg: str) -> None:
            self.stdout.write(msg, ending="\n")

        try:
            stats = run_dgi_intersection_batch(
                limit=limit,
                rayon=rayon,
                chunk_size=int(chunk_size),
                object_timeout_sec=float(object_timeout),
                progress=progress,
            )
        except ValueError as exc:
            raise CommandError(str(exc)) from exc

        self.stdout.write(
            self.style.SUCCESS(
                f"Done: scanned={stats['scanned']}, stored={stats['stored']}, "
                f"errors={stats['errors']}, timeouts={stats.get('skipped_timeout', 0)}"
            )
        )

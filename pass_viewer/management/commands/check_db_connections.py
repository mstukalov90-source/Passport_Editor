"""Verify PostGIS connectivity for default (geodb) and qgis (mggt_asu) database aliases."""

from __future__ import annotations

from django.conf import settings
from django.core.management.base import BaseCommand
from django.db import connections
from django.db.utils import OperationalError

_LOCAL_DOCKER_HINT = (
    "Подсказка: для локальной geodb запустите Docker PostGIS:\n"
    "  ./scripts/local_postgis_up.sh\n"
    "Первый раз залейте данные с прода:\n"
    "  ./scripts/sync_geodb_from_prod.sh --yes"
)

_TUNNEL_HINT = (
    "Подсказка: geodb на 172.21.197.77 слушает только 127.0.0.1:5433. "
    "Запустите SSH-туннель:\n"
    "  ssh -N -L 5433:127.0.0.1:5433 pasp-ssh-user@172.21.197.77"
)


def _default_db_failure_hint(cfg: dict) -> str:
    host = str(cfg.get("HOST", "")).strip().lower()
    if host in ("localhost", "127.0.0.1"):
        return _LOCAL_DOCKER_HINT
    return _TUNNEL_HINT


class Command(BaseCommand):
    help = "Check PostGIS connections for DATABASES aliases (default, qgis)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--alias",
            action="append",
            dest="aliases",
            help="Database alias to check (repeatable). Default: all configured aliases.",
        )

    def handle(self, *args, **options):
        aliases = options.get("aliases") or list(settings.DATABASES.keys())
        failures = 0

        for alias in aliases:
            if alias not in settings.DATABASES:
                self.stderr.write(self.style.ERROR(f"[{alias}] FAIL — unknown database alias"))
                failures += 1
                continue

            cfg = settings.DATABASES[alias]
            host = cfg.get("HOST", "")
            port = cfg.get("PORT", "")
            name = cfg.get("NAME", "")
            user = cfg.get("USER", "")

            self.stdout.write(f"[{alias}] connecting to {user}@{host}:{port}/{name} ...")

            try:
                with connections[alias].cursor() as cursor:
                    cursor.execute("SELECT current_database(), PostGIS_Version()")
                    db_name, postgis_version = cursor.fetchone()
            except OperationalError as exc:
                failures += 1
                self.stderr.write(self.style.ERROR(f"[{alias}] FAIL — {exc}"))
                if alias == "default":
                    self.stderr.write(_default_db_failure_hint(cfg))
                continue

            self.stdout.write(
                self.style.SUCCESS(
                    f"[{alias}] OK — database={db_name}, PostGIS={postgis_version}"
                )
            )

        if failures:
            self.stderr.write(self.style.ERROR(f"{failures} connection(s) failed."))
            raise SystemExit(1)

        self.stdout.write(self.style.SUCCESS("All database connections OK."))

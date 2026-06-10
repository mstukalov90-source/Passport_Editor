"""
Load seed / reference data from JSON and GeoJSON files.

Default root is ``import/`` under BASE_DIR when that directory exists, else BASE_DIR.
Filenames match table names: users.json, ods_request.json, pass_objects.geojson, ...

When using --all, tables without a matching file are skipped. When using --table, the file must exist.

Examples:
  python manage.py import_seed_from_files --list
  python manage.py import_seed_from_files --dry-run --all
  python manage.py import_seed_from_files --table ods_request
"""

from __future__ import annotations

from pathlib import Path

from django.conf import settings
from django.core.management import call_command
from django.core.management.base import BaseCommand, CommandError

from pass_viewer.data_import.geojson_dynamic import import_geojson_dynamic_from_path
from pass_viewer.data_import.json_loaders import import_id_names, import_ods_request, import_users
from pass_viewer.data_import.table_registry import TableImportSpec, build_default_registry, expected_filename


def default_import_root() -> Path:
    base = Path(settings.BASE_DIR)
    import_dir = base / "import"
    if import_dir.is_dir():
        return import_dir
    return base


class Command(BaseCommand):
    help = (
        "Import tables from flat files named like tables (.json / .geojson) under --root "
        "(default: BASE_DIR/import when present, else BASE_DIR)."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--root",
            type=Path,
            default=None,
            help="Directory containing data files (default: BASE_DIR/import or BASE_DIR).",
        )
        parser.add_argument(
            "--table",
            type=str,
            default=None,
            help="Import only this table name (must match registry).",
        )
        parser.add_argument(
            "--all",
            action="store_true",
            help="Process every registered table for which a file exists.",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Show what would be imported without writing to the database.",
        )
        parser.add_argument(
            "--append",
            action="store_true",
            help="Append instead of truncating before geo imports (passed to specialized commands).",
        )
        parser.add_argument(
            "--srid",
            type=int,
            default=4326,
            help="Target SRID for dynamic GeoJSON import (default: 4326).",
        )
        parser.add_argument(
            "--batch-size",
            type=int,
            default=1000,
            help="GeoJSON INSERT batch size for streaming import (default: 1000).",
        )
        parser.add_argument(
            "--list",
            action="store_true",
            dest="list_tables",
            help="List registered tables and expected filenames, then exit.",
        )

    def handle(self, *args, **options):
        root: Path = (options["root"] or default_import_root()).expanduser().resolve()
        dry_run: bool = options["dry_run"]
        append: bool = options["append"]
        target_srid: int = options["srid"]
        batch_size: int = options["batch_size"]

        registry = build_default_registry()

        if options["list_tables"]:
            self.stdout.write(self.style.NOTICE(f"Data root (default): {root}"))
            self.stdout.write("")
            for spec in registry:
                fn = expected_filename(spec)
                extra = f"  [{spec.note}]" if spec.note else ""
                line = f"  {spec.table:30}  {fn}"
                if spec.delegate_command:
                    line += f"  -> {spec.delegate_command}"
                elif spec.dynamic_geojson:
                    line += "  -> dynamic GeoJSON"
                self.stdout.write(line + extra)
            return

        target_tables = options["table"]
        use_all = options["all"]
        if not target_tables and not use_all:
            raise CommandError("Specify --table NAME or --all (or use --list).")

        specs = self._select_specs(registry, target_tables, use_all)
        if not specs:
            raise CommandError("No matching tables in registry.")

        explicit_table = bool(target_tables)
        for spec in specs:
            self._import_one(
                spec,
                root,
                dry_run=dry_run,
                append=append,
                target_srid=target_srid,
                batch_size=batch_size,
                require_file=explicit_table,
            )

    def _select_specs(
        self,
        registry: list[TableImportSpec],
        single: str | None,
        use_all: bool,
    ) -> list[TableImportSpec]:
        if single:
            found = [s for s in registry if s.table == single]
            if not found:
                names = ", ".join(s.table for s in registry)
                raise CommandError(f"Unknown table {single!r}. Known: {names}")
            return found
        if use_all:
            return list(registry)
        return []

    def _import_one(
        self,
        spec: TableImportSpec,
        root: Path,
        *,
        dry_run: bool,
        append: bool,
        target_srid: int,
        batch_size: int,
        require_file: bool,
    ) -> None:
        filename = expected_filename(spec)
        path = root / filename
        if not path.exists():
            if require_file:
                raise CommandError(f"File not found for table {spec.table}: {path}")
            self.stdout.write(self.style.WARNING(f"Skip {spec.table}: file not found {path}"))
            return

        self.stdout.write(f"--- {spec.table} ({filename}) ---")

        if spec.delegate_command:
            if dry_run:
                self.stdout.write(
                    self.style.WARNING(
                        f"[dry-run] delegating to {spec.delegate_command} is not supported; "
                        f"run without --dry-run or invoke {spec.delegate_command} directly."
                    )
                )
                return
            call_command(
                spec.delegate_command,
                path=str(path),
                append=append,
                verbosity=1,
            )
            return

        if spec.table == "users":
            created, updated = import_users(path, dry_run=dry_run)
            if dry_run:
                self.stdout.write(self.style.SUCCESS(f"[dry-run] would process up to {created} user rows"))
            else:
                self.stdout.write(self.style.SUCCESS(f"users: created={created}, updated={updated}"))
            return

        if spec.table == "id_names":
            ins, upd = import_id_names(path, dry_run=dry_run)
            if dry_run:
                self.stdout.write(self.style.SUCCESS(f"[dry-run] would process up to {ins} id_names rows"))
            else:
                self.stdout.write(self.style.SUCCESS(f"id_names: upserted ~{ins} rows"))
            return

        if spec.table == "ods_request":
            n, _ = import_ods_request(path, dry_run=dry_run, append=append)
            if dry_run:
                self.stdout.write(self.style.SUCCESS(f"[dry-run] would insert up to {n} ods_request rows"))
            else:
                self.stdout.write(self.style.SUCCESS(f"ods_request: inserted {n} rows"))
            return

        if spec.dynamic_geojson:
            try:
                imported, skipped = import_geojson_dynamic_from_path(
                    spec.table,
                    path,
                    target_srid=target_srid,
                    append=append,
                    batch_size=batch_size,
                    dry_run=dry_run,
                )
            except Exception as exc:
                raise CommandError(f"{spec.table}: import failed: {exc}") from exc
            if dry_run:
                self.stdout.write(
                    self.style.SUCCESS(f"[dry-run] would import up to {imported} features into {spec.table}")
                )
            else:
                msg = f"{spec.table}: imported={imported}, skipped={skipped}"
                self.stdout.write(self.style.SUCCESS(msg))
            return

        self.stdout.write(self.style.WARNING(f"No handler implemented for {spec.table}"))

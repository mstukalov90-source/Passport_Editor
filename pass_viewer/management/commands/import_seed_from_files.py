"""
Load seed / reference data from JSON and GeoJSON files in the project root.

Default root is Django BASE_DIR (directory containing manage.py). Filenames match table names:
  users.json, id_names.json, ozn.geojson, renew.geojson, pass_objects.geojson, ...

When using --all, tables without a matching file are skipped. When using --table, the file must exist.

Examples:
  python manage.py import_seed_from_files --list
  python manage.py import_seed_from_files --dry-run --all
  python manage.py import_seed_from_files --table users
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import List, Optional

from django.conf import settings
from django.core.management import call_command
from django.core.management.base import BaseCommand, CommandError

from pass_viewer.data_import.geojson_dynamic import import_geojson_dynamic
from pass_viewer.data_import.json_loaders import import_id_names, import_users
from pass_viewer.data_import.table_registry import TableImportSpec, build_default_registry, expected_filename


class Command(BaseCommand):
    help = (
        'Import tables from flat files named like tables (.json / .geojson) under --root '
        '(default: project root / BASE_DIR).'
    )

    def add_arguments(self, parser):
        parser.add_argument(
            '--root',
            type=Path,
            default=None,
            help='Directory containing data files (default: settings.BASE_DIR).',
        )
        parser.add_argument(
            '--table',
            type=str,
            default=None,
            help='Import only this table name (must match registry).',
        )
        parser.add_argument(
            '--all',
            action='store_true',
            help='Process every registered table for which a file exists.',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be imported without writing to the database.',
        )
        parser.add_argument(
            '--append',
            action='store_true',
            help='Append instead of truncating before geo imports (passed to specialized commands).',
        )
        parser.add_argument(
            '--srid',
            type=int,
            default=4326,
            help='Target SRID for dynamic GeoJSON import (default: 4326).',
        )
        parser.add_argument(
            '--list',
            action='store_true',
            dest='list_tables',
            help='List registered tables and expected filenames, then exit.',
        )

    def handle(self, *args, **options):
        root: Path = (options['root'] or Path(settings.BASE_DIR)).expanduser().resolve()
        dry_run: bool = options['dry_run']
        append: bool = options['append']
        target_srid: int = options['srid']

        registry = build_default_registry()

        if options['list_tables']:
            self.stdout.write(self.style.NOTICE(f'Data root (default): {root}'))
            self.stdout.write('')
            for spec in registry:
                fn = expected_filename(spec)
                extra = f'  [{spec.note}]' if spec.note else ''
                line = f'  {spec.table:30}  {fn}'
                if spec.delegate_command:
                    line += f'  -> {spec.delegate_command}'
                elif spec.dynamic_geojson:
                    line += '  -> dynamic GeoJSON'
                self.stdout.write(line + extra)
            return

        target_tables = options['table']
        use_all = options['all']
        if not target_tables and not use_all:
            raise CommandError('Specify --table NAME or --all (or use --list).')

        specs = self._select_specs(registry, target_tables, use_all)
        if not specs:
            raise CommandError('No matching tables in registry.')

        explicit_table = bool(target_tables)
        for spec in specs:
            self._import_one(
                spec,
                root,
                dry_run=dry_run,
                append=append,
                target_srid=target_srid,
                require_file=explicit_table,
            )

    def _select_specs(
        self,
        registry: List[TableImportSpec],
        single: Optional[str],
        use_all: bool,
    ) -> List[TableImportSpec]:
        if single:
            found = [s for s in registry if s.table == single]
            if not found:
                names = ', '.join(s.table for s in registry)
                raise CommandError(f'Unknown table {single!r}. Known: {names}')
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
        require_file: bool,
    ) -> None:
        filename = expected_filename(spec)
        path = root / filename
        if not path.exists():
            if require_file:
                raise CommandError(f'File not found for table {spec.table}: {path}')
            self.stdout.write(self.style.WARNING(f'Skip {spec.table}: file not found {path}'))
            return

        self.stdout.write(f'--- {spec.table} ({filename}) ---')

        if spec.delegate_command:
            if dry_run:
                self.stdout.write(
                    self.style.WARNING(
                        f'[dry-run] delegating to {spec.delegate_command} is not supported; '
                        f'run without --dry-run or invoke {spec.delegate_command} directly.'
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

        if spec.table == 'users':
            created, updated = import_users(path, dry_run=dry_run)
            if dry_run:
                self.stdout.write(self.style.SUCCESS(f'[dry-run] would process up to {created} user rows'))
            else:
                self.stdout.write(self.style.SUCCESS(f'users: created={created}, updated={updated}'))
            return

        if spec.table == 'id_names':
            ins, upd = import_id_names(path, dry_run=dry_run)
            if dry_run:
                self.stdout.write(self.style.SUCCESS(f'[dry-run] would process up to {ins} id_names rows'))
            else:
                self.stdout.write(self.style.SUCCESS(f'id_names: upserted ~{ins} rows'))
            return

        if spec.dynamic_geojson:
            try:
                payload = json.loads(path.read_text(encoding='utf-8'))
            except Exception as exc:
                raise CommandError(f'{spec.table}: invalid JSON: {exc}') from exc
            imported, skipped = import_geojson_dynamic(
                spec.table,
                payload,
                target_srid=target_srid,
                append=append,
                dry_run=dry_run,
            )
            if dry_run:
                self.stdout.write(
                    self.style.SUCCESS(f'[dry-run] would import up to {imported} features into {spec.table}')
                )
            else:
                msg = f'{spec.table}: imported={imported}, skipped={skipped}'
                self.stdout.write(self.style.SUCCESS(msg))
            return

        self.stdout.write(self.style.WARNING(f'No handler implemented for {spec.table}'))

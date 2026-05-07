import json
from pathlib import Path

from django.core.management.base import BaseCommand, CommandError
from django.db import connection, transaction


class Command(BaseCommand):
    help = 'Import features from ozn.geojson into table "ozn".'

    def add_arguments(self, parser):
        parser.add_argument(
            '--path',
            default='ozn.geojson',
            help='Path to GeoJSON file (default: ozn.geojson in project root).',
        )
        parser.add_argument(
            '--srid',
            type=int,
            default=4326,
            help='Target SRID for geometries in DB (default: 4326).',
        )
        parser.add_argument(
            '--source-srid',
            type=int,
            default=None,
            help='Source SRID in GeoJSON. If omitted, tries to detect from GeoJSON crs.',
        )
        parser.add_argument(
            '--append',
            action='store_true',
            help='Append data instead of truncating the table before import.',
        )

    def handle(self, *args, **options):
        file_path = Path(options['path']).expanduser().resolve()
        target_srid = options['srid']
        source_srid = options['source_srid']
        append = options['append']

        if not file_path.exists():
            raise CommandError(f'GeoJSON file not found: {file_path}')

        try:
            payload = json.loads(file_path.read_text(encoding='utf-8'))
        except Exception as exc:
            raise CommandError(f'Failed to read/parse GeoJSON: {exc}') from exc

        features = payload.get('features')
        if payload.get('type') != 'FeatureCollection' or not isinstance(features, list):
            raise CommandError('GeoJSON must be a FeatureCollection with a "features" array.')
        if not features:
            self.stdout.write(self.style.WARNING('GeoJSON has no features. Nothing to import.'))
            return

        if source_srid is None:
            source_srid = _detect_source_srid(payload) or target_srid

        geom_sql = (
            "ST_SetSRID(ST_GeomFromGeoJSON(%s), %s)"
            if source_srid == target_srid
            else "ST_Transform(ST_SetSRID(ST_GeomFromGeoJSON(%s), %s), %s)"
        )
        insert_sql = f"""
            INSERT INTO ozn (
                rootid, name, descr, address, vri, sobstv_rr, departmentlegalpersonid, ownerlegalpersonalid, properties, geom
            )
            VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s::jsonb,
                {geom_sql}
            )
        """

        imported = 0
        skipped = 0

        with transaction.atomic():
            with connection.cursor() as cursor:
                if not append:
                    cursor.execute("TRUNCATE TABLE ozn RESTART IDENTITY")

                for feature in features:
                    if not isinstance(feature, dict):
                        skipped += 1
                        continue

                    geometry = feature.get('geometry')
                    if not geometry:
                        skipped += 1
                        continue

                    properties = feature.get('properties') or {}
                    if not isinstance(properties, dict):
                        properties = {}

                    cursor.execute(
                        insert_sql,
                        [
                            _text_or_none(_pick_prop(properties, 'rootid', 'RootId')),
                            _text_or_none(_pick_prop(properties, 'name', 'Name')),
                            _text_or_none(_pick_prop(properties, 'descr', 'Descr')),
                            _text_or_none(_pick_prop(properties, 'address', 'Address')),
                            _text_or_none(_pick_prop(properties, 'vri', 'Vri')),
                            _text_or_none(_pick_prop(properties, 'sobstv_rr', 'SobstvRr')),
                            _text_or_none(_pick_prop(properties, 'departmentlegalpersonid', 'DepartmentLegalPersonId')),
                            _text_or_none(_pick_prop(properties, 'ownerlegalpersonalid', 'OwnerLegalPersonId')),
                            json.dumps(properties, ensure_ascii=False),
                            json.dumps(geometry, ensure_ascii=False),
                            source_srid,
                            *([target_srid] if source_srid != target_srid else []),
                        ],
                    )
                    imported += 1

        self.stdout.write(
            self.style.SUCCESS(
                f'Imported {imported} features into ozn'
                + (f' (skipped {skipped}).' if skipped else '.')
                + f' source_srid={source_srid}, target_srid={target_srid}.'
            )
        )


def _text_or_none(value):
    if value is None:
        return None
    text = str(value).strip()
    if not text:
        return None
    return text


def _pick_prop(properties, *keys):
    for key in keys:
        if key in properties:
            return properties[key]
    return None


def _detect_source_srid(payload):
    crs = payload.get('crs')
    if not isinstance(crs, dict):
        return None
    props = crs.get('properties')
    if not isinstance(props, dict):
        return None
    name = str(props.get('name') or '').strip()
    if not name:
        return None
    upper = name.upper()
    for marker in ('EPSG::', 'EPSG:'):
        idx = upper.rfind(marker)
        if idx != -1:
            tail = upper[idx + len(marker):]
            digits = ''.join(ch for ch in tail if ch.isdigit())
            if digits:
                try:
                    return int(digits)
                except ValueError:
                    return None
    return None

import json
from pathlib import Path

from django.core.management.base import BaseCommand, CommandError
from django.db import connection, transaction


class Command(BaseCommand):
    help = 'Import Polygon/MultiPolygon features from renew.geojson into table "renew".'

    def add_arguments(self, parser):
        parser.add_argument(
            "--path",
            default="renew.geojson",
            help="Path to GeoJSON file (default: renew.geojson in project root).",
        )
        parser.add_argument(
            "--append",
            action="store_true",
            help="Append data instead of truncating the table before import.",
        )

    def handle(self, *args, **options):
        file_path = Path(options["path"]).expanduser().resolve()
        append = options["append"]

        if not file_path.exists():
            raise CommandError(f"GeoJSON file not found: {file_path}")

        try:
            payload = json.loads(file_path.read_text(encoding="utf-8"))
        except Exception as exc:
            raise CommandError(f"Failed to read/parse GeoJSON: {exc}") from exc

        features = payload.get("features")
        if payload.get("type") != "FeatureCollection" or not isinstance(features, list):
            raise CommandError('GeoJSON must be a FeatureCollection with a "features" array.')

        insert_sql = """
            INSERT INTO renew (
                id, code, name, status_code, ext_status, soon, county, district,
                develop_address, developer, infocenter, finishing_code, vvod, floors, flats,
                metro, metro_walk, metro_car, anons_texts, img, geom
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326)
            )
        """

        imported = 0
        skipped_non_polygon = 0
        skipped_invalid = 0

        with transaction.atomic():
            with connection.cursor() as cursor:
                if not append:
                    cursor.execute("TRUNCATE TABLE renew RESTART IDENTITY")

                for feature in features:
                    if not isinstance(feature, dict):
                        skipped_invalid += 1
                        continue
                    geometry = feature.get("geometry")
                    if not isinstance(geometry, dict):
                        skipped_invalid += 1
                        continue
                    geom_type = str(geometry.get("type") or "").strip()
                    if geom_type not in ("Polygon", "MultiPolygon"):
                        skipped_non_polygon += 1
                        continue

                    properties = feature.get("properties") or {}
                    if not isinstance(properties, dict):
                        properties = {}

                    cursor.execute(
                        insert_sql,
                        [
                            _to_text(properties.get("id")),
                            _to_text(properties.get("code")),
                            _to_text(properties.get("name")),
                            _to_text(properties.get("status_code")),
                            _to_text(properties.get("ext_status")),
                            _to_text(properties.get("soon")),
                            _to_text(properties.get("county")),
                            _to_text(properties.get("district")),
                            _to_text(properties.get("develop_address")),
                            _to_text(properties.get("developer")),
                            _to_text(properties.get("infocenter")),
                            _to_text(properties.get("finishing_code")),
                            _to_text(properties.get("vvod")),
                            _to_text(properties.get("floors")),
                            _to_text(properties.get("flats")),
                            _to_text(properties.get("metro")),
                            _to_text(properties.get("metro_walk")),
                            _to_text(properties.get("metro_car")),
                            _to_text(properties.get("anons_texts")),
                            _to_text(properties.get("img")),
                            json.dumps(geometry, ensure_ascii=False),
                        ],
                    )
                    imported += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Imported {imported} renew features. "
                f"Skipped non-polygons: {skipped_non_polygon}. "
                f"Skipped invalid: {skipped_invalid}."
            )
        )


def _to_text(value):
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None

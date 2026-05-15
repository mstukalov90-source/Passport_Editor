"""
Registry of database tables that can be populated from flat files during deploy.

File naming: same stem as the table name, extension .json or .geojson (see kind).
Root directory: pass `--root` to the management command (default: settings.BASE_DIR).
"""

from dataclasses import dataclass
from enum import Enum
from typing import Iterator, List, Optional

from django.conf import settings


class FileKind(str, Enum):
    JSON = 'json'
    GEOJSON = 'geojson'


@dataclass(frozen=True)
class TableImportSpec:
    """How to import one logical table from the filesystem."""

    table: str
    kind: FileKind
    # If set, delegate to this Django management command (same argv style as CLI).
    delegate_command: Optional[str] = None
    # If True, use SQL introspection + generic GeoJSON row insert (see geojson_dynamic).
    dynamic_geojson: bool = False
    note: str = ''


def _comment_points_table() -> str:
    return getattr(settings, 'GIS_COMMENT_POINTS_TABLE', 'pass_comment_points')


def build_default_registry() -> List[TableImportSpec]:
    """
    Tables referenced by this application (PostGIS / app migrations / views).

    Tables without Django migrations (pass_objects, odh, dgi) are loaded only if
    they already exist in the target database — migrations elsewhere must create them.
    """
    comment_tbl = _comment_points_table()
    return [
        TableImportSpec('users', FileKind.JSON, note='Model ExternalUser; columns login, password, OwnerLegalPersonId'),
        TableImportSpec('id_names', FileKind.JSON, note='Columns "LegalPersonId", "name"'),
        TableImportSpec(
            'ods_request',
            FileKind.JSON,
            note='ODS bidregistry_view rows from ods_request.json (migration 0014)',
        ),
        TableImportSpec('ozn', FileKind.GEOJSON, delegate_command='import_ozn_geojson'),
        TableImportSpec('renew', FileKind.GEOJSON, delegate_command='import_renew_geojson'),
        TableImportSpec('hood', FileKind.GEOJSON, dynamic_geojson=True, note='Rayon / okrug polygons (hood.geojson)'),
        TableImportSpec('pass_objects', FileKind.GEOJSON, dynamic_geojson=True, note='Primary GIS table; schema external to Django migrations'),
        TableImportSpec(
            getattr(settings, 'GIS_ODH_TABLE', 'odh'),
            FileKind.GEOJSON,
            dynamic_geojson=True,
        ),
        TableImportSpec(
            getattr(settings, 'GIS_DGI_TABLE', 'dgi'),
            FileKind.GEOJSON,
            dynamic_geojson=True,
        ),
        TableImportSpec('recaps', FileKind.GEOJSON, dynamic_geojson=True, note='Structure LIKE pass_objects'),
        TableImportSpec(comment_tbl, FileKind.GEOJSON, dynamic_geojson=True, note='Comment markers; default table from GIS_COMMENT_POINTS_TABLE'),
    ]


def iter_known_tables() -> Iterator[TableImportSpec]:
    return iter(build_default_registry())


def expected_filename(spec: TableImportSpec) -> str:
    return f'{spec.table}.{spec.kind.value}'


def expected_files_doc() -> str:
    lines = []
    for spec in build_default_registry():
        lines.append(f'  {expected_filename(spec)}  # {spec.note or spec.table}'.strip())
    return '\n'.join(lines)


def expected_file_names() -> List[str]:
    return [expected_filename(s) for s in build_default_registry()]

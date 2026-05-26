"""
Helpers for loading seed / reference data from JSON and GeoJSON files.

Expected layout (by default: Django project root = directory containing manage.py):
  users.json
  id_names.json
  ods_request.json
  ozn.geojson
  renew.geojson
  hood.geojson
  pass_objects.geojson
  odh.geojson
  dgi.geojson
  recaps.geojson
  pass_comment_points.geojson   (unless GIS_COMMENT_POINTS_TABLE overrides the table name)

CLI: ``python manage.py import_seed_from_files --list``
"""

from pass_viewer.data_import.table_registry import expected_file_names, iter_known_tables

__all__ = ["expected_file_names", "iter_known_tables"]

"""Contract tests for geometry shape passed to the map editor (main page)."""

import json

import pytest

from pass_viewer.views import _simplify_geojson_for_editing

SAMPLE_POLYGON = {
    "type": "Polygon",
    "coordinates": [
        [
            [37.6, 55.7],
            [37.61, 55.7],
            [37.61, 55.71],
            [37.6, 55.71],
            [37.6, 55.7],
        ]
    ],
}


@pytest.mark.django_db
def test_simplify_single_polygon_returns_bare_polygon_geometry():
    """main embeds this via selected_geometry_for_editing; utils.js must wrap it as FC."""
    result = _simplify_geojson_for_editing(json.dumps(SAMPLE_POLYGON), tolerance_meters=0.75)
    assert isinstance(result, dict)
    assert result.get("type") == "Polygon"
    assert "coordinates" in result

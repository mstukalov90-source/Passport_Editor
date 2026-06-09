"""Unit tests for polygon normalization helpers in geometry-multipolygon-save.js."""

from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JS_PATH = ROOT / "pass_viewer/static/pass_viewer/js/geometry-multipolygon-save.js"


def _run_js_tests() -> None:
    script = f"""
const fs = require('fs');
const code = fs.readFileSync({str(JS_PATH)!r}, 'utf8');
const PassViewer = {{}};
const fn = new Function('global', 'PassViewer', code + '; return PassViewer;');
const PV = fn({{PassViewer}}, PassViewer);
const mps = PV.multipolygonSave;

function LL(lat, lng) {{ this.lat = lat; this.lng = lng; }}

const group = {{
  eachLayer(cb) {{
    cb({{
      getLatLngs() {{
        return [new LL(55.75, 37.61), new LL(55.76, 37.62), new LL(55.77, 37.63)];
      }},
    }});
  }},
  toGeoJSON() {{ return {{ type: 'FeatureCollection', features: [] }}; }},
}};

const ring = mps.readGeometriesFromLeafletGroup(group);
if (!ring.length) throw new Error('expected one polygon');
const coords = ring[0].coordinates[0];
if (coords.length !== 4) throw new Error('ring should be closed with 4 points, got ' + coords.length);
if (coords[0][0] !== coords[coords.length - 1][0] || coords[0][1] !== coords[coords.length - 1][1]) {{
  throw new Error('ring is not closed');
}}

const merged = mps.mergePolygonGeometriesForExport(ring.concat(ring));
if (merged.type !== 'MultiPolygon' || merged.coordinates.length !== 2) {{
  throw new Error('expected MultiPolygon with 2 parts');
}}

const geometry = mps.buildGeometryForExport({{
  featureGroup: group,
  isEditing: true,
  pendingRepairedGeometry: null,
  editToolbar: null,
}});
const built = geometry.coordinates[0];
if (built[0][0] !== built[built.length - 1][0]) throw new Error('built geometry ring not closed');

const repaired = {{ type: 'Polygon', coordinates: [[[0, 0], [1, 0], [1, 1], [0, 0]]] }};
const pending = mps.buildGeometryForExport({{
  featureGroup: group,
  isEditing: true,
  pendingRepairedGeometry: repaired,
  editToolbar: null,
}});
if (pending !== repaired) throw new Error('pending repaired geometry not returned');

const fc = mps.mergeFeatureCollectionForExport({{
  type: 'FeatureCollection',
  features: [
    {{ type: 'Feature', geometry: {{ type: 'Polygon', coordinates: [[[0, 0], [1, 0], [1, 1], [0, 0]]] }} }},
    {{ type: 'Feature', geometry: {{ type: 'Polygon', coordinates: [[[2, 2], [3, 2], [3, 3], [2, 2]]] }} }},
  ],
}});
if (fc.type !== 'MultiPolygon') throw new Error('expected MultiPolygon from feature collection');

console.log('ok');
"""
    result = subprocess.run(
        ["node", "-e", script],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise AssertionError(result.stderr or result.stdout)


def test_geometry_multipolygon_export_helpers() -> None:
    _run_js_tests()

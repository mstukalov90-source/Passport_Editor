#!/usr/bin/env bash
# Install Python deps on CI (Ubuntu): match pip gdal to system libgdal from apt.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

GDAL_VERSION="$(gdal-config --version)"
echo "System GDAL version: ${GDAL_VERSION}"

# requirements.txt pins gdal==3.6.2 for macOS/dev; on CI use the apt version.
grep -v '^gdal==' requirements.txt | grep -v '^#' | grep -v '^$' > /tmp/requirements-no-gdal.txt
pip install -r /tmp/requirements-no-gdal.txt
pip install "gdal==${GDAL_VERSION}"

# Dev tools without re-installing requirements.txt (would pull gdal==3.6.2 again).
grep -v '^-r requirements.txt' requirements-dev.txt | grep -v '^#' | grep -v '^$' > /tmp/requirements-dev-only.txt
pip install -r /tmp/requirements-dev-only.txt

python -c "from osgeo import gdal; print('osgeo gdal', gdal.VersionInfo())"

#!/usr/bin/env bash
# Resolve GDAL/GEOS library paths on Linux CI (avoids ogdi plugin stubs).
# Usage:
#   source scripts/ci_resolve_gdal_paths.sh
#   source scripts/ci_resolve_gdal_paths.sh --github-env
set -euo pipefail

GITHUB_ENV_MODE=false
if [[ "${1:-}" == "--github-env" ]]; then
  GITHUB_ENV_MODE=true
fi

_arch_lib() {
  echo "/usr/lib/$(uname -m)-linux-gnu"
}

_resolve_gdal() {
  local arch_lib="$1"
  local candidate

  if [[ -e "${arch_lib}/libgdal.so" ]]; then
    readlink -f "${arch_lib}/libgdal.so"
    return 0
  fi

  candidate="$(find "${arch_lib}" -maxdepth 1 -name 'libgdal.so.*' 2>/dev/null | sort -V | tail -1)"
  if [[ -n "${candidate}" && -e "${candidate}" ]]; then
    readlink -f "${candidate}"
    return 0
  fi

  if command -v ldconfig >/dev/null 2>&1; then
    candidate="$(ldconfig -p 2>/dev/null | grep 'libgdal\.so' | grep -v ogdi | awk '{print $NF}' | head -1)"
    if [[ -n "${candidate}" && -e "${candidate}" ]]; then
      readlink -f "${candidate}"
      return 0
    fi
  fi

  echo "ERROR: could not resolve libgdal.so (checked ${arch_lib}, ldconfig)" >&2
  return 1
}

_resolve_geos() {
  local arch_lib="$1"
  local candidate

  if [[ -e "${arch_lib}/libgeos_c.so" ]]; then
    readlink -f "${arch_lib}/libgeos_c.so"
    return 0
  fi

  candidate="$(find "${arch_lib}" -maxdepth 1 -name 'libgeos_c.so.*' 2>/dev/null | sort -V | tail -1)"
  if [[ -n "${candidate}" && -e "${candidate}" ]]; then
    readlink -f "${candidate}"
    return 0
  fi

  if command -v ldconfig >/dev/null 2>&1; then
    candidate="$(ldconfig -p 2>/dev/null | grep 'libgeos_c\.so' | awk '{print $NF}' | head -1)"
    if [[ -n "${candidate}" && -e "${candidate}" ]]; then
      readlink -f "${candidate}"
      return 0
    fi
  fi

  echo "ERROR: could not resolve libgeos_c.so (checked ${arch_lib}, ldconfig)" >&2
  return 1
}

ARCH_LIB="$(_arch_lib)"
export GDAL_LIBRARY_PATH="$(_resolve_gdal "${ARCH_LIB}")"
export GEOS_LIBRARY_PATH="$(_resolve_geos "${ARCH_LIB}")"

echo "GDAL_LIBRARY_PATH=${GDAL_LIBRARY_PATH}"
echo "GEOS_LIBRARY_PATH=${GEOS_LIBRARY_PATH}"

if [[ "${GITHUB_ENV_MODE}" == true && -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "GDAL_LIBRARY_PATH=${GDAL_LIBRARY_PATH}"
    echo "GEOS_LIBRARY_PATH=${GEOS_LIBRARY_PATH}"
  } >>"${GITHUB_ENV}"
fi

if python -c "import django" >/dev/null 2>&1; then
  python -c "
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pass_map.settings')
import django
django.setup()
from django.contrib.gis.gdal import GDAL_VERSION
print('Django GIS GDAL OK', GDAL_VERSION)
"
else
  echo "Skip Django GIS check (django not installed yet)"
fi

#!/usr/bin/env bash
set -euo pipefail
docker exec passport_web python manage.py sync_geodb_from_mggt
docker exec passport_web python manage.py compute_dgi_intersections

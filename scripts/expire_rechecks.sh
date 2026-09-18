#!/usr/bin/env bash
set -euo pipefail
docker exec passport_web python manage.py expire_rechecks

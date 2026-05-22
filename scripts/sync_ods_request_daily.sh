#!/usr/bin/env bash
set -euo pipefail
docker exec passport_web python manage.py sync_ods_request_if_present

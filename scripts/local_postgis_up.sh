#!/usr/bin/env bash
# Start local PostGIS container for development (geodb on localhost:5433).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is not installed or not in PATH" >&2
  exit 1
fi

echo "Starting local PostGIS (docker-compose.local.yml) ..."

if lsof -nP -iTCP:5433 -sTCP:LISTEN 2>/dev/null | grep -q '[s]sh'; then
  echo "warning: SSH tunnel is already listening on port 5433." >&2
  echo "  Stop it before using local Docker: pkill -f 'ssh.*-L 5433:127.0.0.1:5433'" >&2
fi

docker compose -f docker-compose.local.yml up -d

echo "Waiting for postgis-db healthcheck ..."
deadline=$((SECONDS + 120))
while true; do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}unknown{{end}}' postgis-db 2>/dev/null || echo missing)"
  if [[ "$status" == "healthy" ]]; then
    break
  fi
  if [[ "$status" == "missing" ]]; then
    echo "error: container postgis-db not found" >&2
    exit 1
  fi
  if (( SECONDS > deadline )); then
    echo "error: postgis-db did not become healthy within 120s (status=$status)" >&2
    docker compose -f docker-compose.local.yml ps
    exit 1
  fi
  sleep 2
done

docker compose -f docker-compose.local.yml ps
echo "Local geodb ready: postgres@localhost:5433/geodb (password: postgres)"

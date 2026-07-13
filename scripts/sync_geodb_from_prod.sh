#!/usr/bin/env bash
# Full geodb sync: prod (172.21.197.77) -> local Docker postgis-db.
# Prod is read-only (pg_dump). Local geodb is dropped and recreated.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROD_SSH_USER="${PROD_SSH_USER:-pasp-ssh-user}"
PROD_SSH_HOST="${PROD_SSH_HOST:-172.21.197.77}"
PROD_DB_CONTAINER="${PROD_DB_CONTAINER:-passport_db}"
LOCAL_DB_CONTAINER="${LOCAL_DB_CONTAINER:-postgis-db}"
LOCAL_DB_NAME="${LOCAL_DB_NAME:-geodb}"
LOCAL_DB_USER="${LOCAL_DB_USER:-postgres}"
LOCAL_POSTGRES_PASSWORD="${LOCAL_POSTGRES_PASSWORD:-postgres}"

SAVE_FILE=""
FROM_FILE=""
ASSUME_YES=0

usage() {
  cat <<'EOF'
Usage: scripts/sync_geodb_from_prod.sh [options]

Options:
  --save PATH       Save dump to PATH (.sql or .sql.gz) while restoring
  --from-file PATH  Restore from local dump file (skip prod SSH)
  --yes             Do not ask for confirmation
  -h, --help        Show this help

Environment:
  PROD_SSH_USER     default: pasp-ssh-user
  PROD_SSH_HOST     default: 172.21.197.77
  PROD_DB_CONTAINER default: passport_db
  LOCAL_DB_CONTAINER default: postgis-db
  LOCAL_POSTGRES_PASSWORD default: postgres (docker-compose.local.yml)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --save)
      SAVE_FILE="$2"
      shift 2
      ;;
    --from-file)
      FROM_FILE="$2"
      shift 2
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -n "$SAVE_FILE" && -n "$FROM_FILE" ]]; then
  echo "error: use either --save or --from-file, not both" >&2
  exit 1
fi

if ! docker inspect "$LOCAL_DB_CONTAINER" >/dev/null 2>&1; then
  echo "error: container $LOCAL_DB_CONTAINER is not running. Run: ./scripts/local_postgis_up.sh" >&2
  exit 1
fi

if lsof -nP -iTCP:5433 -sTCP:LISTEN 2>/dev/null | grep -q '[s]sh'; then
  echo "warning: SSH tunnel is listening on port 5433 — host connections may hit prod instead of Docker." >&2
  echo "  Stop it: pkill -f 'ssh.*-L 5433:127.0.0.1:5433'" >&2
fi

if [[ -z "$FROM_FILE" ]]; then
  if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "${PROD_SSH_USER}@${PROD_SSH_HOST}" "echo ok" >/dev/null 2>&1; then
    echo "error: SSH to ${PROD_SSH_USER}@${PROD_SSH_HOST} failed" >&2
    exit 1
  fi
elif [[ ! -f "$FROM_FILE" ]]; then
  echo "error: dump file not found: $FROM_FILE" >&2
  exit 1
fi

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo "This will DROP and recreate local database '${LOCAL_DB_NAME}' in container ${LOCAL_DB_CONTAINER}."
  if [[ -n "$FROM_FILE" ]]; then
    echo "Source: local file $FROM_FILE"
  else
    echo "Source: prod ${PROD_SSH_HOST} (${PROD_DB_CONTAINER})"
  fi
  read -r -p "Continue? [y/N] " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

recreate_local_geodb() {
  echo "Recreating local ${LOCAL_DB_NAME} ..."
  docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d postgres -v ON_ERROR_STOP=1 -c \
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${LOCAL_DB_NAME}' AND pid <> pg_backend_pid();" \
    >/dev/null 2>&1 || true
  docker exec "$LOCAL_DB_CONTAINER" dropdb -U "$LOCAL_DB_USER" --if-exists "$LOCAL_DB_NAME"
  docker exec "$LOCAL_DB_CONTAINER" createdb -U "$LOCAL_DB_USER" "$LOCAL_DB_NAME"
}

reset_local_postgres_password() {
  echo "Resetting local postgres password for host connections ..."
  docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d postgres -v ON_ERROR_STOP=1 -c \
    "ALTER USER postgres PASSWORD '${LOCAL_POSTGRES_PASSWORD}';"
}

restore_sql_stream() {
  docker exec -i "$LOCAL_DB_CONTAINER" psql -v ON_ERROR_STOP=1 -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME"
}

print_local_counts() {
  echo "--- local ---"
  docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -At -c \
    "SELECT 'pass_objects', count(*)::text FROM pass_objects
     UNION ALL SELECT 'users', count(*)::text FROM users
     UNION ALL SELECT 'ods_request', count(*)::text FROM ods_request;" 2>/dev/null \
    || docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -At -c \
    "SELECT 'users', count(*)::text FROM users;" 2>/dev/null || true
}

print_prod_counts() {
  echo "--- prod (${PROD_SSH_HOST}) ---"
  ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" \
    "sudo docker exec ${PROD_DB_CONTAINER} psql -U postgres -d ${LOCAL_DB_NAME} -At -c \
    \"SELECT 'pass_objects', count(*)::text FROM pass_objects UNION ALL SELECT 'users', count(*)::text FROM users UNION ALL SELECT 'ods_request', count(*)::text FROM ods_request;\"" \
    2>/dev/null || true
}

recreate_local_geodb

if [[ -n "$FROM_FILE" ]]; then
  echo "Restoring from $FROM_FILE ..."
  if [[ "$FROM_FILE" == *.gz ]]; then
    gunzip -c "$FROM_FILE" | restore_sql_stream
  else
    restore_sql_stream <"$FROM_FILE"
  fi
elif [[ -n "$SAVE_FILE" ]]; then
  mkdir -p "$(dirname "$SAVE_FILE")"
  echo "Dumping from prod and saving to $SAVE_FILE (this may take a long time) ..."
  if [[ "$SAVE_FILE" == *.gz ]]; then
    ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" \
      "sudo docker exec ${PROD_DB_CONTAINER} pg_dump -U postgres -d ${LOCAL_DB_NAME} --no-owner --no-privileges" \
      | tee >(gzip -c >"$SAVE_FILE") | restore_sql_stream
  else
    ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" \
      "sudo docker exec ${PROD_DB_CONTAINER} pg_dump -U postgres -d ${LOCAL_DB_NAME} --no-owner --no-privileges" \
      | tee "$SAVE_FILE" | restore_sql_stream
  fi
else
  echo "Streaming full dump from prod (this may take a long time) ..."
  ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" \
    "sudo docker exec ${PROD_DB_CONTAINER} pg_dump -U postgres -d ${LOCAL_DB_NAME} --no-owner --no-privileges" \
    | restore_sql_stream
fi

reset_local_postgres_password

echo "Restore finished. Row counts:"
print_local_counts

if [[ -z "$FROM_FILE" ]]; then
  print_prod_counts
fi

echo "Done. Local geodb is ready at localhost:5433 (password: ${LOCAL_POSTGRES_PASSWORD})."

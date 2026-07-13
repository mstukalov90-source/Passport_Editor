#!/usr/bin/env bash
# Approval schema data sync: prod (172.21.197.77) -> local Docker postgis-db.
# Prod is read-only (pg_dump --schema=approval --data-only).
# Local approval tables are truncated; other geodb schemas are untouched.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROD_SSH_USER="${PROD_SSH_USER:-pasp-ssh-user}"
PROD_SSH_HOST="${PROD_SSH_HOST:-172.21.197.77}"
PROD_DB_CONTAINER="${PROD_DB_CONTAINER:-passport_db}"
LOCAL_DB_CONTAINER="${LOCAL_DB_CONTAINER:-postgis-db}"
LOCAL_DB_NAME="${LOCAL_DB_NAME:-geodb}"
LOCAL_DB_USER="${LOCAL_DB_USER:-postgres}"

SAVE_FILE=""
FROM_FILE=""
ASSUME_YES=0

APPROVAL_COUNTS_SQL="
SELECT 'approves', count(*)::text FROM approval.approves
UNION ALL SELECT 'cases', count(*)::text FROM approval.cases
UNION ALL SELECT 'case_messages', count(*)::text FROM approval.case_messages
UNION ALL SELECT 'case_approvals', count(*)::text FROM approval.case_approvals
UNION ALL SELECT 'geometry', count(*)::text FROM approval.geometry
UNION ALL SELECT 'case_message_attachments', count(*)::text FROM approval.case_message_attachments;
"

usage() {
  cat <<'EOF'
Usage: scripts/sync_approval_from_prod.sh [options]

Sync approval schema DATA ONLY from prod geodb to local postgis-db.
Requires approval schema structure already present (python manage.py migrate approval).

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

if ! docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -At -c \
  "SELECT 1 FROM information_schema.tables WHERE table_schema='approval' AND table_name='approves' LIMIT 1;" \
  | grep -q 1; then
  echo "error: approval schema not found in local ${LOCAL_DB_NAME}. Run: python manage.py migrate approval" >&2
  exit 1
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
  echo "This will TRUNCATE all approval.* tables in local '${LOCAL_DB_NAME}' (${LOCAL_DB_CONTAINER})."
  echo "Other schemas (public, etc.) are not affected."
  if [[ -n "$FROM_FILE" ]]; then
    echo "Source: local file $FROM_FILE"
  else
    echo "Source: prod ${PROD_SSH_HOST} (${PROD_DB_CONTAINER}), schema approval (data only)"
  fi
  read -r -p "Continue? [y/N] " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

prod_pg_dump() {
  ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" \
    "sudo docker exec ${PROD_DB_CONTAINER} pg_dump -U postgres -d ${LOCAL_DB_NAME} \
      --schema=approval --data-only --no-owner --no-privileges"
}

truncate_local_approval() {
  echo "Truncating local approval.* tables ..."
  docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -v ON_ERROR_STOP=1 -c \
    "TRUNCATE TABLE
       approval.case_message_attachments,
       approval.case_approvals,
       approval.geometry,
       approval.case_messages,
       approval.cases,
       approval.approves
     RESTART IDENTITY CASCADE;"
}

restore_sql_stream() {
  {
    echo "SET session_replication_role = replica;"
    cat
    echo "SET session_replication_role = DEFAULT;"
  } | docker exec -i "$LOCAL_DB_CONTAINER" psql -v ON_ERROR_STOP=1 -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME"
}

print_local_counts() {
  echo "--- local ---"
  docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -At -c "$APPROVAL_COUNTS_SQL" \
    2>/dev/null || true
}

print_prod_counts() {
  echo "--- prod (${PROD_SSH_HOST}) ---"
  ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" \
    "sudo docker exec ${PROD_DB_CONTAINER} psql -U postgres -d ${LOCAL_DB_NAME} -At -c \"${APPROVAL_COUNTS_SQL}\"" \
    2>/dev/null || true
}

check_duplicate_primary_cases() {
  local dupes
  dupes="$(docker exec "$LOCAL_DB_CONTAINER" psql -U "$LOCAL_DB_USER" -d "$LOCAL_DB_NAME" -At -c \
    "SELECT approve_id, count(*) FROM approval.cases WHERE is_primary IS TRUE GROUP BY approve_id HAVING count(*) > 1;" \
    2>/dev/null || true)"
  if [[ -n "$dupes" ]]; then
    echo "warning: duplicate primary cases detected:" >&2
    echo "$dupes" >&2
    return 1
  fi
  echo "No duplicate primary cases."
}

truncate_local_approval

if [[ -n "$FROM_FILE" ]]; then
  echo "Restoring from $FROM_FILE ..."
  if [[ "$FROM_FILE" == *.gz ]]; then
    gunzip -c "$FROM_FILE" | restore_sql_stream
  else
    restore_sql_stream <"$FROM_FILE"
  fi
elif [[ -n "$SAVE_FILE" ]]; then
  mkdir -p "$(dirname "$SAVE_FILE")"
  echo "Dumping approval data from prod and saving to $SAVE_FILE ..."
  if [[ "$SAVE_FILE" == *.gz ]]; then
    prod_pg_dump | tee >(gzip -c >"$SAVE_FILE") | restore_sql_stream
  else
    prod_pg_dump | tee "$SAVE_FILE" | restore_sql_stream
  fi
else
  echo "Streaming approval data dump from prod ..."
  prod_pg_dump | restore_sql_stream
fi

echo "Restore finished. Row counts:"
print_local_counts

if [[ -z "$FROM_FILE" ]]; then
  print_prod_counts
fi

check_duplicate_primary_cases

echo "Done. Local approval data ready in ${LOCAL_DB_NAME} at localhost:5433."

#!/usr/bin/env bash
set -euo pipefail
# Simple DB health check that prefers checking the Postgres container directly.
# Usage:
#   ./scripts/check_db.sh [container-name] [db-user] [db-name]
# Environment variables supported: DB_CONTAINER, DB_USER, DB_NAME, DB_HOST

CONTAINER=${1:-${DB_CONTAINER:-wander-postgres}}
DB_USER=${2:-${DB_USER:-wanderuser}}
DB_NAME=${3:-${DB_NAME:-wanderlistdb}}

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  # If the container exists, use pg_isready inside the container (fast and reliable)
  if docker exec -i "${CONTAINER}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
    echo "DB Connected (container=${CONTAINER})"
    exit 0
  else
    echo "DB Unreachable inside container ${CONTAINER}" >&2
    exit 2
  fi
else
  # Fallback: try host-based pg_isready if available
  if command -v pg_isready >/dev/null 2>&1; then
    PGHOST=${DB_HOST:-localhost}
    if pg_isready -h "${PGHOST}" -p "${DB_PORT:-5432}" -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
      echo "DB Connected (host=${PGHOST})"
      exit 0
    else
      echo "DB Unreachable on host ${PGHOST}" >&2
      exit 2
    fi
  else
    echo "Neither container '${CONTAINER}' found nor 'pg_isready' available on host. Cannot check DB." >&2
    exit 3
  fi
fi

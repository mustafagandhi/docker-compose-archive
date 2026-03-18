#!/usr/bin/env bash
# =============================================================================
# Reads nodes.conf + .env, generates db.json for the cluster.
#
# Usage:
#   ./scripts/generate-db-json.sh                # prints to stdout
#   ./scripts/generate-db-json.sh path/db.json   # writes to a specific file
#   ./scripts/generate-db-json.sh --all           # writes to deploy/*/ dirs
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

# --- Load passwords from .env ---
ENV_FILE="${ROOT}/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: ${ENV_FILE} not found. Copy .env.example to .env and fill in passwords." >&2
  exit 1
fi
set -a; source "$ENV_FILE"; set +a

for var in APP_PASSWORD ADMIN_PASSWORD PGEDGE_PASSWORD PGCAT_AUTH_PASSWORD PGCAT_ADMIN_PASSWORD; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: $var is empty in .env" >&2
    exit 1
  fi
done

# --- Parse nodes.conf ---
NODES_CONF="${ROOT}/nodes.conf"
if [[ ! -f "$NODES_CONF" ]]; then
  echo "ERROR: ${NODES_CONF} not found." >&2
  exit 1
fi

NODES_JSON=""
FIRST=true
while read -r name region hostname; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  if $FIRST; then FIRST=false; else NODES_JSON+=","; fi
  NODES_JSON+="
    {\"name\": \"${name}\", \"region\": \"${region}\", \"hostname\": \"${hostname}\"}"
done < "$NODES_CONF"

if [[ -z "$NODES_JSON" ]]; then
  echo "ERROR: No nodes found in nodes.conf" >&2
  exit 1
fi

# --- Build db.json ---
DB_JSON=$(cat "${ROOT}/db.json.template")
DB_JSON="${DB_JSON//NODES_PLACEHOLDER/$NODES_JSON}"
DB_JSON="${DB_JSON//APP_PASSWORD_PLACEHOLDER/$APP_PASSWORD}"
DB_JSON="${DB_JSON//ADMIN_PASSWORD_PLACEHOLDER/$ADMIN_PASSWORD}"
DB_JSON="${DB_JSON//PGEDGE_PASSWORD_PLACEHOLDER/$PGEDGE_PASSWORD}"
DB_JSON="${DB_JSON//PGCAT_AUTH_PASSWORD_PLACEHOLDER/$PGCAT_AUTH_PASSWORD}"
DB_JSON="${DB_JSON//PGCAT_ADMIN_PASSWORD_PLACEHOLDER/$PGCAT_ADMIN_PASSWORD}"

# --- Output ---
if [[ "${1:-}" == "--all" ]]; then
  for dir in "${ROOT}"/deploy/*/; do
    [[ -d "$dir" ]] || continue
    echo "$DB_JSON" > "${dir}/db.json"
    echo "Wrote: ${dir}db.json"
  done
elif [[ -n "${1:-}" ]]; then
  echo "$DB_JSON" > "$1"
  echo "Wrote: $1"
else
  echo "$DB_JSON"
fi

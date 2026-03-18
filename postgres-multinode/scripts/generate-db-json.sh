#!/usr/bin/env bash
# =============================================================================
# Generates db.json from template using environment variables.
# Run this ONCE before starting any node, then copy the generated db.json
# to all three node directories.
#
# Usage: ./generate-db-json.sh [output-path]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="${PROJECT_DIR}/shared/db.json.template"
OUTPUT="${1:-${PROJECT_DIR}/shared/db.json}"

# Source .env if available
if [[ -f "${PROJECT_DIR}/.env" ]]; then
  set -a
  source "${PROJECT_DIR}/.env"
  set +a
fi

# Validate required variables
required_vars=(
  NODE_INDIA_HOSTNAME NODE_US_EAST_HOSTNAME NODE_TOKYO_HOSTNAME
  APP_PASSWORD ADMIN_PASSWORD PGEDGE_PASSWORD
  PGCAT_AUTH_PASSWORD PGCAT_ADMIN_PASSWORD
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" || "${!var}" == CHANGE_ME* ]]; then
    echo "ERROR: $var is not set or still has the default value." >&2
    echo "       Please configure your .env file first." >&2
    exit 1
  fi
done

# Generate db.json using envsubst
envsubst < "$TEMPLATE" > "$OUTPUT"

echo "Generated: $OUTPUT"
echo ""
echo "Node hostnames configured:"
echo "  India (n1):    ${NODE_INDIA_HOSTNAME}"
echo "  US East (n2):  ${NODE_US_EAST_HOSTNAME}"
echo "  Tokyo (n3):    ${NODE_TOKYO_HOSTNAME}"
echo ""
echo "Next steps:"
echo "  1. Copy $OUTPUT to each node directory:"
echo "     cp $OUTPUT ${PROJECT_DIR}/node-india/db.json"
echo "     cp $OUTPUT ${PROJECT_DIR}/node-us-east/db.json"
echo "     cp $OUTPUT ${PROJECT_DIR}/node-tokyo/db.json"
echo "  2. Deploy each node's docker-compose.yml on its respective server."

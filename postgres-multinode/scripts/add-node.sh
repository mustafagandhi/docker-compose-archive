#!/usr/bin/env bash
# =============================================================================
# Create a deploy bundle for a new node.
#
# Usage: ./scripts/add-node.sh <node-name> <region> <hostname>
#   e.g.: ./scripts/add-node.sh n4 ap-southeast-1 10.100.0.4
#
# Creates deploy/<node-name>/ with the files needed to run on that server.
# Also appends the node to nodes.conf.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

NODE_NAME="${1:?Usage: $0 <node-name> <region> <hostname>}"
REGION="${2:?Usage: $0 <node-name> <region> <hostname>}"
HOSTNAME="${3:?Usage: $0 <node-name> <region> <hostname>}"
TARGET="${ROOT}/deploy/${NODE_NAME}"

if [[ -d "$TARGET" ]]; then
  echo "ERROR: ${TARGET} already exists." >&2
  exit 1
fi

# Append to nodes.conf
echo "${NODE_NAME}  ${REGION}  ${HOSTNAME}" >> "${ROOT}/nodes.conf"
echo "Added ${NODE_NAME} to nodes.conf"

# Create deploy bundle
mkdir -p "$TARGET"
echo "NODE_NAME=${NODE_NAME}" > "${TARGET}/.env"
cp "${ROOT}/docker-compose.yml" "${TARGET}/docker-compose.yml"

echo ""
echo "Created: ${TARGET}"
echo ""
echo "Next steps:"
echo "  1. Regenerate db.json:    ./scripts/generate-db-json.sh --all"
echo "  2. Redistribute db.json to ALL running nodes and restart them"
echo "  3. Copy ${TARGET}/ to the new server"
echo "  4. On the server:         docker compose up -d"

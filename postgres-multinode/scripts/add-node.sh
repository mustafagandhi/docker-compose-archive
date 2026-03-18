#!/usr/bin/env bash
# =============================================================================
# Scaffold a new node directory.
#
# Usage: ./scripts/add-node.sh <dir-name> <node-name>
#   e.g.: ./scripts/add-node.sh node-tokyo n3
#
# This copies node-n/ as a template and sets NODE_NAME in .env.
# After running, add the node to nodes.conf and regenerate db.json.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

DIR_NAME="${1:?Usage: $0 <dir-name> <node-name>}"
NODE_NAME="${2:?Usage: $0 <dir-name> <node-name>}"
TARGET="${ROOT}/${DIR_NAME}"

if [[ -d "$TARGET" ]]; then
  echo "ERROR: ${TARGET} already exists." >&2
  exit 1
fi

cp -r "${ROOT}/node-n" "$TARGET"
echo "NODE_NAME=${NODE_NAME}" > "${TARGET}/.env"

echo "Created: ${TARGET}"
echo ""
echo "Next steps:"
echo "  1. Add '${NODE_NAME}' to nodes.conf with its region and hostname"
echo "  2. Regenerate db.json:  ./scripts/generate-db-json.sh --all"
echo "  3. Redistribute db.json to ALL existing nodes and restart them"
echo "  4. Deploy:  cd ${TARGET} && docker compose up -d"

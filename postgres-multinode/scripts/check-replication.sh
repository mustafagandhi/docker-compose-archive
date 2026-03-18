#!/usr/bin/env bash
# =============================================================================
# Check Spock replication status on a node.
#
# Usage: ./scripts/check-replication.sh <node-name>
#   e.g.: ./scripts/check-replication.sh n1
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
NODE="${1:?Usage: $0 <node-name> (e.g. n1)}"
NODE_DIR="${ROOT}/deploy/${NODE}"

if [[ ! -d "$NODE_DIR" ]]; then
  echo "ERROR: ${NODE_DIR} does not exist. Run add-node.sh first." >&2
  exit 1
fi

run_sql() {
  docker compose -f "$NODE_DIR/docker-compose.yml" exec -T pgedge \
    psql -U pgedge -d defaultdb -c "$1"
}

echo "=== Spock Node Info ==="
run_sql "SELECT * FROM spock.node;"

echo ""
echo "=== Subscriptions ==="
run_sql "SELECT * FROM spock.subscription;"

echo ""
echo "=== Replication Sets ==="
run_sql "SELECT * FROM spock.replication_set;"

echo ""
echo "=== Replication Slots ==="
run_sql "SELECT slot_name, active, restart_lsn, confirmed_flush_lsn FROM pg_replication_slots;"

echo ""
echo "=== WAL Senders ==="
run_sql "SELECT pid, application_name, state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication;"

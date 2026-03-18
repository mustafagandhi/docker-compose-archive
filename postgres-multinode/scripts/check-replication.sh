#!/usr/bin/env bash
# =============================================================================
# Check Spock replication status on a node.
#
# Usage: ./scripts/check-replication.sh [node-dir]
#   e.g.: ./scripts/check-replication.sh node-a
#         ./scripts/check-replication.sh          # defaults to node-a
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
NODE_DIR="${ROOT}/${1:-node-a}"

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

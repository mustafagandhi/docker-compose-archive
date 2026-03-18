#!/usr/bin/env bash
# =============================================================================
# Check Spock replication status across all nodes.
#
# Usage: ./check-replication.sh <node-dir>
#   e.g.: ./check-replication.sh node-india
#
# Run this from any node to check replication health.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

NODE_DIR="${1:?Usage: $0 <node-dir> (e.g., node-india)}"
FULL_PATH="${PROJECT_DIR}/${NODE_DIR}"

echo "=== Spock Replication Status ==="
echo ""

# Check Spock node status
echo "--- Node Info ---"
docker compose -f "$FULL_PATH/docker-compose.yml" exec -T pgedge \
  psql -U pgedge -d defaultdb -c "SELECT * FROM spock.node;"

echo ""
echo "--- Subscriptions ---"
docker compose -f "$FULL_PATH/docker-compose.yml" exec -T pgedge \
  psql -U pgedge -d defaultdb -c "SELECT * FROM spock.subscription;"

echo ""
echo "--- Replication Sets ---"
docker compose -f "$FULL_PATH/docker-compose.yml" exec -T pgedge \
  psql -U pgedge -d defaultdb -c "SELECT * FROM spock.replication_set;"

echo ""
echo "--- Replication Lag ---"
docker compose -f "$FULL_PATH/docker-compose.yml" exec -T pgedge \
  psql -U pgedge -d defaultdb -c \
  "SELECT slot_name, active, restart_lsn, confirmed_flush_lsn FROM pg_replication_slots;"

echo ""
echo "--- WAL Senders ---"
docker compose -f "$FULL_PATH/docker-compose.yml" exec -T pgedge \
  psql -U pgedge -d defaultdb -c \
  "SELECT pid, application_name, state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication;"

#!/usr/bin/env bash
# =============================================================================
# Deploy a pgEdge node on the current server.
#
# Usage: ./deploy-node.sh <node-dir>
#   e.g.: ./deploy-node.sh node-india
#
# Prerequisites:
#   1. Docker and Docker Compose installed
#   2. .env file configured in the node directory
#   3. db.json generated and copied to the node directory
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

NODE_DIR="${1:?Usage: $0 <node-dir> (e.g., node-india, node-us-east, node-tokyo)}"
FULL_PATH="${PROJECT_DIR}/${NODE_DIR}"

if [[ ! -d "$FULL_PATH" ]]; then
  echo "ERROR: Directory $FULL_PATH does not exist." >&2
  exit 1
fi

if [[ ! -f "$FULL_PATH/.env" ]]; then
  echo "ERROR: $FULL_PATH/.env not found." >&2
  echo "       Copy .env.example to .env and configure it." >&2
  exit 1
fi

if [[ ! -f "$FULL_PATH/db.json" ]]; then
  echo "ERROR: $FULL_PATH/db.json not found." >&2
  echo "       Run ./generate-db-json.sh first, then copy db.json here." >&2
  exit 1
fi

echo "Deploying pgEdge node from: $FULL_PATH"
echo "============================================"

cd "$FULL_PATH"

# Pull latest images
echo "Pulling images..."
docker compose pull

# Start services
echo "Starting services..."
docker compose up -d

# Wait for health check
echo "Waiting for pgEdge to become healthy..."
for i in $(seq 1 30); do
  if docker compose exec pgedge pg_isready -U pgedge -d defaultdb -p 5432 >/dev/null 2>&1; then
    echo "pgEdge is ready!"
    break
  fi
  if [[ $i -eq 30 ]]; then
    echo "WARNING: pgEdge did not become healthy within 5 minutes."
    echo "Check logs: docker compose -f $FULL_PATH/docker-compose.yml logs pgedge"
    exit 1
  fi
  sleep 10
done

echo ""
echo "Node deployed successfully!"
echo "============================================"
echo "Check status:  docker compose -f $FULL_PATH/docker-compose.yml ps"
echo "View logs:     docker compose -f $FULL_PATH/docker-compose.yml logs -f"
echo "Stop:          docker compose -f $FULL_PATH/docker-compose.yml down"

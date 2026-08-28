#!/bin/bash
# Generate secure environment variables for Redis
# Run on server, then paste output into Komodo Stack env vars

APP_NAME="${1:-myapp}"
REDIS_PASS=$(openssl rand -base64 24)

cat << EOF
# Redis — ${APP_NAME}
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

REDIS_PASSWORD=${REDIS_PASS}
REDIS_MAXMEMORY=256mb

# Connection string for applications:
# redis://:${REDIS_PASS}@${APP_NAME}-redis:6379/0
EOF

#!/bin/bash
# Generate secure environment variables for PostgreSQL + pgvector
APP_NAME="${1:-myapp}"
DB_PASS=$(openssl rand -base64 24)

cat << EOF
# PostgreSQL + pgvector — ${APP_NAME}
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

DB_NAME=${APP_NAME}
DB_USER=${APP_NAME}
DB_PASSWORD=${DB_PASS}

# Connection string for applications:
# postgresql://${APP_NAME}:${DB_PASS}@${APP_NAME}-postgres:5432/${APP_NAME}

# After deploy, enable pgvector:
# docker exec ${APP_NAME}-postgres psql -U ${APP_NAME} -d ${APP_NAME} -c "CREATE EXTENSION IF NOT EXISTS vector;"
EOF

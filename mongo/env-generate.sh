#!/bin/bash
# Generate environment variables for MongoDB
APP_NAME="${1:-myapp}"

cat << EOF
# MongoDB — ${APP_NAME}
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

DB_NAME=${APP_NAME}

# Connection string for applications:
# mongodb://${APP_NAME}-mongo:27017/${APP_NAME}
EOF

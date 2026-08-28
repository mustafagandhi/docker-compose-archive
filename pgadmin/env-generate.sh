#!/bin/bash
# Generate secure environment variables for pgAdmin
# Run on server, then paste output into Komodo Stack env vars

PGADMIN_PASS=$(openssl rand -base64 16)

cat << EOF
# pgAdmin
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=${PGADMIN_PASS}
EOF

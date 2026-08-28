#!/bin/bash
# Generate secure environment variables for Traefik + Komodo
# Run on server, then paste output into compose.env
#
# Usage: bash env-generate.sh example.com accounts@example.com

DOMAIN="${1:-example.com}"
ACME_EMAIL="${2:-accounts@example.com}"

ADMIN_PASS=$(openssl rand -base64 16)
DB_PASS=$(openssl rand -base64 16)
PASSKEY=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)
WEBHOOK_SECRET=$(openssl rand -hex 16)

cat << EOF
# Traefik + Komodo — ${DOMAIN}
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Save these credentials securely!

COMPOSE_PROJECT_NAME=infra-core
KOMODO_IMAGE_TAG=latest

DOMAIN=${DOMAIN}
TRAEFIK_ACME_EMAIL=${ACME_EMAIL}
CF_DNS_API_TOKEN=PASTE_YOUR_CF_DNS_TOKEN_HERE

KOMODO_HOST=https://komodo.${DOMAIN}
KOMODO_TITLE=Docker Infra
KOMODO_FIRST_SERVER=https://komodo-periphery:8120
KOMODO_FIRST_SERVER_NAME=server-1

KOMODO_LOCAL_AUTH=true
KOMODO_INIT_ADMIN_USERNAME=admin
KOMODO_INIT_ADMIN_PASSWORD=${ADMIN_PASS}
KOMODO_DISABLE_USER_REGISTRATION=true
KOMODO_ENABLE_NEW_USERS=false
KOMODO_DISABLE_NON_ADMIN_CREATE=false

KOMODO_PASSKEY=${PASSKEY}
KOMODO_JWT_SECRET=${JWT_SECRET}
KOMODO_WEBHOOK_SECRET=${WEBHOOK_SECRET}
KOMODO_JWT_TTL=1-day

KOMODO_DB_USERNAME=admin
KOMODO_DB_PASSWORD=${DB_PASS}

KOMODO_MONITORING_INTERVAL=15-sec
KOMODO_RESOURCE_POLL_INTERVAL=1-hr
KOMODO_LOGGING_PRETTY=false
KOMODO_DISABLE_CONFIRM_DIALOG=false
TZ=Asia/Kolkata

KOMODO_OIDC_ENABLED=false

PERIPHERY_PASSKEYS=${PASSKEY}
PERIPHERY_SSL_ENABLED=true
PERIPHERY_ROOT_DIRECTORY=/komodo-data
PERIPHERY_INCLUDE_DISK_MOUNTS=/etc/hostname
PERIPHERY_DISABLE_TERMINALS=false
EOF

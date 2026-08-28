#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════
# Traefik + Komodo — Automated Setup
# Usage: bash setup.sh <domain> <acme_email> <cf_dns_token>
# Example: bash setup.sh example.com accounts@example.com cfat_xxx
# ═══════════════════════════════════════════════════════════

DOMAIN="${1:?Usage: bash setup.sh <domain> <acme_email> <cf_dns_token>}"
ACME_EMAIL="${2:?Usage: bash setup.sh <domain> <acme_email> <cf_dns_token>}"
CF_DNS_TOKEN="${3:?Usage: bash setup.sh <domain> <acme_email> <cf_dns_token>}"

INSTALL_DIR="/opt"
COMPOSE_DIR="${INSTALL_DIR}/komodo"

echo ""
echo "═══════════════════════════════════════"
echo "  Traefik + Komodo Setup"
echo "  Domain: ${DOMAIN}"
echo "═══════════════════════════════════════"
echo ""

# ─── Step 1: Prerequisites ────────────────────────────────

echo "[1/6] Creating directories..."
mkdir -p ${INSTALL_DIR}/traefik/{letsencrypt,dynamic,logs}
mkdir -p ${INSTALL_DIR}/komodo/{backups,syncs,data}

echo "[1/6] Creating Docker networks..."
docker network create proxy 2>/dev/null || true
docker network create komodo 2>/dev/null || true

# ─── Step 2: Install htpasswd ─────────────────────────────

if ! command -v htpasswd &> /dev/null; then
    echo "[2/6] Installing apache2-utils for htpasswd..."
    apt install -y apache2-utils > /dev/null 2>&1
else
    echo "[2/6] htpasswd already installed"
fi

# ─── Step 3: Generate all credentials ─────────────────────

echo "[3/6] Generating secure credentials..."

ADMIN_PASS=$(openssl rand -base64 16)
DB_PASS=$(openssl rand -base64 16)
PASSKEY=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)
WEBHOOK_SECRET=$(openssl rand -hex 16)
TRAEFIK_DASH_PASS=$(openssl rand -base64 12)
HTPASSWD=$(htpasswd -nb admin "$TRAEFIK_DASH_PASS")

# ─── Step 4: Write Traefik middleware config ───────────────

echo "[4/6] Writing Traefik middleware config..."

cat > ${INSTALL_DIR}/traefik/dynamic/middleware.yml << EOF
http:
  middlewares:
    secure-headers:
      headers:
        stsSeconds: 31536000
        stsIncludeSubdomains: true
        stsPreload: true
        forceSTSHeader: true
        contentTypeNosniff: true
        browserXssFilter: true
        referrerPolicy: "strict-origin-when-cross-origin"
        frameDeny: true

    traefik-auth:
      basicAuth:
        users:
          - "${HTPASSWD}"
EOF

# ─── Step 5: Write compose.env ─────────────────────────────

echo "[5/6] Writing compose.env..."

cat > ${COMPOSE_DIR}/compose.env << EOF
# Traefik + Komodo — ${DOMAIN}
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# DO NOT COMMIT THIS FILE

COMPOSE_PROJECT_NAME=infra-core
KOMODO_IMAGE_TAG=latest

DOMAIN=${DOMAIN}
TRAEFIK_ACME_EMAIL=${ACME_EMAIL}
CF_DNS_API_TOKEN=${CF_DNS_TOKEN}

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

# ─── Step 6: Deploy ────────────────────────────────────────

echo "[6/6] Deploying..."
cd ${COMPOSE_DIR}
docker compose --env-file compose.env up -d

echo ""
echo "═══════════════════════════════════════════════════"
echo "  DEPLOYMENT COMPLETE"
echo "═══════════════════════════════════════════════════"
echo ""
echo "  Traefik Dashboard:"
echo "    URL:      https://traefik.${DOMAIN}"
echo "    Username: admin"
echo "    Password: ${TRAEFIK_DASH_PASS}"
echo ""
echo "  Komodo Dashboard:"
echo "    URL:      https://komodo.${DOMAIN}"
echo "    Username: admin"
echo "    Password: ${ADMIN_PASS}"
echo ""
echo "  MongoDB:"
echo "    Username: admin"
echo "    Password: ${DB_PASS}"
echo ""
echo "  Passkey:        ${PASSKEY}"
echo "  JWT Secret:     ${JWT_SECRET}"
echo "  Webhook Secret: ${WEBHOOK_SECRET}"
echo ""
echo "  ⚠  SAVE THESE CREDENTIALS NOW"
echo "  ⚠  They are also in: ${COMPOSE_DIR}/compose.env"
echo "═══════════════════════════════════════════════════"

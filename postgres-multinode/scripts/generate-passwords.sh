#!/usr/bin/env bash
# =============================================================================
# Generates secure random passwords for the deployment.
# Outputs values suitable for pasting into your .env file.
# =============================================================================
set -euo pipefail

gen_password() {
  openssl rand -base64 24 | tr -d '/+=' | head -c 24
}

cat <<EOF
# --- Generated Passwords (paste into your .env files) ---
APP_PASSWORD=$(gen_password)
ADMIN_PASSWORD=$(gen_password)
PGEDGE_PASSWORD=$(gen_password)
PGCAT_AUTH_PASSWORD=$(gen_password)
PGCAT_ADMIN_PASSWORD=$(gen_password)
EOF

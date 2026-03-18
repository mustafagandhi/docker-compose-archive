#!/usr/bin/env bash
# Generates secure random passwords. Paste output into .env.
set -euo pipefail

gen() { openssl rand -base64 24 | tr -d '/+=' | head -c 24; }

cat <<EOF
APP_PASSWORD=$(gen)
ADMIN_PASSWORD=$(gen)
PGEDGE_PASSWORD=$(gen)
PGCAT_AUTH_PASSWORD=$(gen)
PGCAT_ADMIN_PASSWORD=$(gen)
EOF

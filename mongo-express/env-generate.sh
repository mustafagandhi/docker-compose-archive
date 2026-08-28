#!/bin/bash
# Generate environment variables for Mongo Express
APP_NAME="${1:-myapp}"
ME_PASS=$(openssl rand -base64 24)

cat << EOF
# Mongo Express — MongoDB GUI
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

# MongoDB connection (internal Docker network)
ME_CONFIG_MONGODB_URL=mongodb://${APP_NAME}-mongo:27017

# Basic auth for web UI (required — do not expose without auth)
ME_CONFIG_BASICAUTH_USERNAME=admin
ME_CONFIG_BASICAUTH_PASSWORD=${ME_PASS}

# Access: https://mongo.example.com
EOF

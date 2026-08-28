# Traefik + Komodo

Reverse proxy (Traefik v3, image: `traefik:v3`) + container management (Komodo Core + Periphery, images: `ghcr.io/moghtech/komodo-core` / `ghcr.io/moghtech/komodo-periphery`). Deploy first — everything depends on this.

## Access

- `https://traefik.DOMAIN` — Traefik dashboard (basic auth)
- `https://komodo.DOMAIN` — Komodo container management

## Quick Start (Automated)

One command does everything — creates directories, generates credentials, writes configs, deploys:

```bash
bash setup.sh example.com accounts@example.com YOUR_CF_DNS_TOKEN
```

Save the credentials printed at the end.

## Manual Setup

If you prefer step-by-step:

### 1. Prerequisites

```bash
docker network create proxy
docker network create komodo
mkdir -p /opt/traefik/{letsencrypt,dynamic,logs}
mkdir -p /opt/komodo/{backups,syncs,data}
```

### 2. Generate credentials

```bash
bash env-generate.sh example.com accounts@example.com
```

Copy the output into `/opt/komodo/compose.env`. Replace `CF_DNS_API_TOKEN`.

### 3. Generate Traefik middleware

The automated `setup.sh` writes `/opt/traefik/dynamic/middleware.yml` for you. To do it manually: run `htpasswd -nb admin YOUR_PASSWORD` and paste the result as a basicAuth user into `/opt/traefik/dynamic/middleware.yml` (see `setup.sh` for the full middleware template).

### 4. Deploy

```bash
cd /opt/komodo
docker compose --env-file compose.env up -d
```

## DNS Records

| Record | Type | Value |
|--------|------|-------|
| `DOMAIN` | A | VPS IP |
| `*.DOMAIN` | A | VPS IP |

Set Cloudflare SSL to **Full (Strict)**.

## Environment Variables

See `env-generate.sh` for the full list. Key ones:

| Variable | Description |
|----------|-------------|
| `DOMAIN` | Root domain |
| `CF_DNS_API_TOKEN` | Cloudflare DNS API token (DNS edit for this zone) |
| `KOMODO_INIT_ADMIN_PASSWORD` | Komodo login password |
| `KOMODO_PASSKEY` | Periphery auth passkey |
| `KOMODO_DB_PASSWORD` | MongoDB password |

## Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Stack definition (paste into Komodo or run directly) |
| `setup.sh` | Full automated setup (prereqs + creds + middleware + deploy) |
| `env-generate.sh` | Generate compose.env credentials only |

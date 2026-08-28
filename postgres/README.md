# PostgreSQL

PostgreSQL 18.3 on Alpine 3.23 (image: `postgres:18.3-alpine3.23`). Deploy one instance per application.

## Usage

1. Replace `APP_NAME` in `docker-compose.yml` with your app name (e.g., `myapp`, `shop`)
2. Generate credentials: `bash env-generate.sh myapp`
3. Paste compose into Komodo Stack, set env vars, deploy

## Prerequisites

Create the app network before deploying:
```bash
docker network create myapp   # or whatever your APP_NAME is
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_NAME` | Database name | `myapp` |
| `DB_USER` | Database user | `myapp` |
| `DB_PASSWORD` | Generated password | (from env-generate.sh) |

## Connect from Application

```
postgresql://myapp:PASSWORD@myapp-postgres:5432/myapp
```

Container is on the `APP_NAME` network. Any container on the same network can connect via hostname `APP_NAME-postgres`.

## Backup

```bash
docker exec APP_NAME-postgres pg_dump -U DB_USER DB_NAME > backup.sql
```

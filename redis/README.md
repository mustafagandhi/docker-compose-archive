# Redis

Redis 8.6.2 on Alpine 3.23 (image: `redis:8.6.2-alpine3.23`). Deploy one instance per application.

## Usage

1. Replace `APP_NAME` in `docker-compose.yml` with your app name
2. Generate credentials: `bash env-generate.sh myapp`
3. Paste compose into Komodo Stack, set env vars, deploy

## Prerequisites

```bash
docker network create myapp   # or your APP_NAME
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_PASSWORD` | Auth password | (from env-generate.sh) |
| `REDIS_MAXMEMORY` | Memory limit | `256mb` |

## Connect from Application

```
redis://:PASSWORD@myapp-redis:6379/0
```

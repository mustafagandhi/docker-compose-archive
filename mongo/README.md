# MongoDB 8

Document database (image: `mongo:8`) for services that need flexible schemas.

## Quick Start

1. Replace `APP_NAME` in `docker-compose.yml` with your app name (e.g., `myapp`)
2. Set env vars in Komodo UI:
   - `DB_NAME` — database name (default: `myapp`)
3. Deploy as Komodo Stack

## Connection

Internal only (no port mapping):
```
mongodb://APP_NAME-mongo:27017/DB_NAME
```

## Notes

- No authentication configured — internal network access only
- Data persisted in named volume `APP_NAME-mongodata`
- Memory limit: 1GB (adjust in deploy.resources.limits)

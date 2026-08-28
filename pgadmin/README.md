# pgAdmin

PostgreSQL web management UI (image: `dpage/pgadmin4:latest`, listens on port 5050). Shared instance — connects to all Postgres databases.

## Access

`https://pgadmin.example.com`

## Usage

1. Generate credentials: `bash env-generate.sh`
2. Paste compose into Komodo, set env vars, deploy
3. Add database connections in pgAdmin UI after login

## Adding New Databases

When a new app deploys Postgres, add its network to this stack's compose file:
```yaml
networks:
  - proxy
  - myapp
  - newapp    # add this
```
Then redeploy the pgAdmin stack in Komodo.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PGADMIN_EMAIL` | Login email |
| `PGADMIN_PASSWORD` | Login password |

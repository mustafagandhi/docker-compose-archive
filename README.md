# docker-compose-template

**Battle-tested, production-grade Docker Compose recipes for popular self-hosted apps.**

Every stack in this repo is actively maintained and deployed in production by us. Each folder is a self-contained, independently deployable stack with secure defaults: generated secrets, health checks, restart policies, log rotation, and memory limits. Copy a folder, generate credentials, deploy.

## Why this repo

Most docker-compose examples on the internet are toys: hardcoded passwords, no health checks, no resource limits, no persistence strategy. These are the opposite — the same files we run in prod, published so you don't have to reinvent them.

## Stacks

| Stack | Path | Image | Purpose |
|-------|------|-------|---------|
| PostgreSQL | [`postgres/`](postgres/) | `postgres:18.3-alpine3.23` | Relational database (standard) |
| PostgreSQL + pgvector | [`postgres-pgvector/`](postgres-pgvector/) | `pgvector/pgvector:0.8.2-pg18-bookworm` | Relational DB + vector search for AI/RAG workloads |
| PostgreSQL Multi-Node | [`postgres-multinode/`](postgres-multinode/) | pgEdge (PG 16 + Spock) | Multi-active write cluster, any number of nodes |
| MongoDB | [`mongo/`](mongo/) | `mongo:8` | Document database |
| Mongo Express | [`mongo-express/`](mongo-express/) | `mongo-express` | MongoDB web admin UI |
| Redis | [`redis/`](redis/) | `redis:8.6.2-alpine3.23` | Cache, message broker |
| RedisInsight | [`redisinsight/`](redisinsight/) | `redis/redisinsight` | Redis web admin UI |
| pgAdmin | [`pgadmin/`](pgadmin/) | `dpage/pgadmin4` | PostgreSQL web admin UI |
| Traefik + Komodo | [`traefik-komodo/`](traefik-komodo/) | `traefik:v3` + Komodo | Reverse proxy (HTTPS) + container management UI |

Each stack has its own `README.md` with full setup instructions — start there.

## Quick start

Every stack follows the same pattern:

```bash
# 1. Enter the stack folder
cd postgres

# 2. Generate secure credentials (prints env vars to stdout)
./env-generate.sh > .env

# 3. Deploy — either directly:
docker compose --env-file .env up -d

# ...or paste docker-compose.yml + the generated env vars into
# Komodo / Portainer / Dockge and deploy from the UI.
```

Some stacks (e.g. `postgres/`) use an `APP_NAME` placeholder — read the stack's README first and replace it with your app's name.

## Standards

All stacks in this repo follow these rules:

- **Pinned versions** — no floating `:latest` on databases or infra (a few admin UIs excepted; pinning PRs welcome)
- **Generated secrets** — credentials come from `env-generate.sh` (openssl), never hardcoded, never committed
- **Health checks** on every service
- **Restart policies** (`unless-stopped`)
- **Log rotation** (json-file, size-capped)
- **Memory limits** on all services
- **Named volumes** for persistent data
- **Least exposure** — databases bind to internal Docker networks only (`expose`, not `ports`); UIs go behind Traefik with HTTPS
- **Self-contained** — each stack deploys and destroys independently

## Repository structure

```
stack-name/
  docker-compose.yml    # the stack definition
  env-generate.sh       # generates secure env vars (run on the server)
  README.md             # stack-specific setup docs
```

## Networks

Some stacks expect external Docker networks so multiple stacks can communicate:

| Network | Purpose | Created by |
|---------|---------|------------|
| `proxy` | Traefik HTTPS ingress | [`traefik-komodo/`](traefik-komodo/) |
| `myapp` | Your application's network (rename freely) | your first app stack |

```bash
docker network create proxy
docker network create myapp
```

## Suggested deploy order

1. [`traefik-komodo/`](traefik-komodo/) — reverse proxy + management UI (first)
2. [`postgres/`](postgres/) or [`postgres-pgvector/`](postgres-pgvector/) — database
3. [`redis/`](redis/) — cache / broker
4. [`mongo/`](mongo/) — document store (if needed)
5. [`pgadmin/`](pgadmin/), [`redisinsight/`](redisinsight/), [`mongo-express/`](mongo-express/) — admin UIs
6. Your application stacks

## Contributing

Recipes, fixes, and version bumps are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). The bar for inclusion: pinned versions, generated secrets, health checks, resource limits, and a README that lets a stranger deploy it in five minutes.

## License

[MIT](LICENSE) — use these anywhere, including commercial production.

# Changelog

All notable changes to this repo are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2026.08.28] - 2026-08-28

### Added
- Initial public release under MIT
- Imported 8 production stacks from our internal infrastructure repo:
  - `postgres/` — PostgreSQL 18.3 Alpine
  - `postgres-pgvector/` — PostgreSQL 18 + pgvector 0.8.2
  - `mongo/` — MongoDB 8
  - `mongo-express/` — MongoDB web admin UI
  - `redis/` — Redis 8.6.2 Alpine
  - `redisinsight/` — Redis web admin UI
  - `pgadmin/` — pgAdmin 4 with Traefik integration
  - `traefik-komodo/` — Traefik v3 + Komodo Core/Periphery + MongoDB
- `postgres-multinode/` — pgEdge multi-active write PostgreSQL cluster (any number of nodes)
- Per-stack `env-generate.sh` for secure credential generation
- `CONTRIBUTING.md` with stack standards and submission requirements
- `.gitattributes` enforcing LF line endings for shell scripts

### Changed
- All stacks genericized for public use: placeholder domains (`example.com`), neutral install paths (`/opt/...`), no internal references

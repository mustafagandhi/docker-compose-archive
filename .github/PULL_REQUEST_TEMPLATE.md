## What does this PR do?

<!-- Describe the change: new stack, fix to an existing stack, docs update, etc. -->

## How was it tested?

<!-- e.g. `docker compose config`, `docker compose up -d` on Ubuntu 24.04 / Docker 27.x -->

## Checklist

- [ ] Pinned image versions (no `:latest` on databases/infra)
- [ ] No secrets, real domains, or credentials committed
- [ ] Health check on every service
- [ ] `restart: unless-stopped`, log rotation, and memory limits set
- [ ] Named volumes for persistent data
- [ ] `expose` used instead of `ports` where possible
- [ ] `env-generate.sh` included for new stacks (LF line endings)
- [ ] Stack `README.md` added/updated
- [ ] `docker compose config` validates / YAML parses cleanly

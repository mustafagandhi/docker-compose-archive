# Contributing

Thanks for helping keep these recipes current. This repo's value is that every stack actually works in production — contributions should uphold that.

## What we accept

- **New stacks** for popular self-hostable apps (databases, caches, proxies, admin UIs, app servers, monitoring, etc.)
- **Version bumps** with a note on what you tested
- **Fixes** — broken health checks, deprecated images, security issues
- **Docs improvements** — clearer READMEs, missing prerequisites

## Stack requirements

Every stack folder must contain:

```
your-stack/
  docker-compose.yml    # complete, deployable as-is
  env-generate.sh       # bash script printing secure env vars (openssl rand)
  README.md             # what it is, prerequisites, setup steps, ports
```

And must follow these standards:

1. **Pinned image versions** — `postgres:18.3-alpine3.23`, never `postgres:latest` (admin UIs may float on `:latest` if no stable tag scheme exists)
2. **No secrets in the repo** — no passwords, tokens, or real domains anywhere; use `example.com` for placeholder hostnames
3. **Health check** for every service
4. **`restart: unless-stopped`**
5. **Log rotation** — json-file driver with `max-size`/`max-file`
6. **Memory limit** under `deploy.resources.limits`
7. **Named volumes** for anything that must persist
8. **Minimal exposure** — use `expose` for service-to-service ports; only publish `ports` when the host genuinely needs them
9. **Independence** — your stack must deploy and `docker compose down` without touching other stacks; shared networks are `external: true`

## Before submitting

```bash
# YAML parses and compose accepts it (with dummy env vars if needed)
docker compose -f your-stack/docker-compose.yml config --quiet

# Shell script syntax is valid
bash -n your-stack/env-generate.sh
```

Ideally, actually deploy the stack once and note that in your PR description.

## Style notes

- READMEs: lead with one line saying what the stack is and the image/version it uses, then prerequisites, then numbered setup steps
- Shell scripts must keep LF line endings (the repo's `.gitattributes` enforces this)
- Keep comments in compose files short and at the top

## Reporting issues

Open an issue with: the stack name, your Docker/Compose versions, the exact error, and what you expected. Redact secrets and real hostnames.

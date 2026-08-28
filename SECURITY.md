# Security Policy

## Supported Versions

Only the `main` branch of this repository is maintained and receives fixes.
Individual stacks are versioned by date — see [CHANGELOG.md](CHANGELOG.md) for
the current state of each stack. Older dated revisions are not supported;
please update to `main` before reporting a problem.

## Reporting a Vulnerability

**Please do NOT open a public GitHub issue for security problems.**

Instead, use GitHub's private vulnerability reporting:

1. Go to the repository's **Security** tab.
2. Click **"Report a vulnerability"**.
3. Describe the issue, the affected stack(s), and how to reproduce it.

This opens a private advisory that only the maintainer can see until a fix is
coordinated and published.

### Expected Response Time

You can expect an acknowledgement of your report within **7 days**.

## What Counts as a Security Issue Here

This repository contains Docker Compose configuration, not application code.
Please report any of the following:

- A stack that is **vulnerable by default configuration** — for example, a
  service exposing a port without authentication, or a weak default-credential
  pattern baked into the template.
- **Committed secrets** — real credentials, tokens, or private keys that were
  accidentally checked in.
- **Compromised or malicious image tags** — a pinned image digest/tag that is
  known to be compromised or has been replaced upstream.
- A pinned image version with a **known, relevant vulnerability** that should
  be bumped.

### A Note on Upstream CVEs

Most CVEs apply to the **upstream container images**, not to this repository's
configuration. If you find a vulnerability in PostgreSQL, MongoDB, Redis,
Traefik, or any other application itself, please report it to that upstream
project's security process.

That said, **DO** open a private report here if this repository pins a
known-vulnerable image version — we will update the pin.

## Scope Note for Users

These stacks are **secure-by-default templates** (health checks, restart
policies, log rotation, memory limits, `expose` over `ports`, placeholder
hostnames). However:

- You **must** change all generated credentials before deploying to any real
  environment. The `env-generate.sh` scripts produce secrets for your local
  copy only — never commit the resulting `.env` files.
- You **must** review the exposure of each stack for your own environment.
  Defaults are conservative, but your network, firewall, and threat model are
  your responsibility.

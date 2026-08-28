# Mongo Express

Web-based MongoDB admin interface (image: `mongo-express:latest`). Browse databases, collections, documents, indexes.

## Quick Start

1. Run `./env-generate.sh myapp` to generate env vars with a random password
2. Set env vars in Komodo UI
3. Deploy as Komodo Stack
4. Access at https://mongo.example.com

## Env Vars

| Variable | Required | Default | Description |
|---|---|---|---|
| `ME_CONFIG_MONGODB_URL` | Yes | `mongodb://myapp-mongo-dev:27017` | MongoDB connection string |
| `ME_CONFIG_BASICAUTH_USERNAME` | Yes | `admin` | Web UI username |
| `ME_CONFIG_BASICAUTH_PASSWORD` | Yes | — | Web UI password |

## Networks

Mongo Express needs access to:
- `proxy` — Traefik reverse proxy (for HTTPS)
- `myapp` — your application's Docker network (to reach `myapp-mongo-dev`)

Add more app networks as needed.

## Notes

- Basic auth is required — never expose without a password
- Traefik handles HTTPS termination via `mongo.example.com`
- Read-only by default in the UI — enable writes via the settings page

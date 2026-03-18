# pgEdge Multi-Active Write PostgreSQL

Multi-active write PostgreSQL cluster using [pgEdge](https://www.pgedge.com/) with Spock logical replication. Every node accepts reads and writes. Supports any number of nodes.

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Node n1 │◄───►│  Node n2 │◄───►│  Node nN │
│  pgEdge  │     │  pgEdge  │     │  pgEdge  │
│  pgCat   │     │  pgCat   │     │  pgCat   │
└──────────┘     └──────────┘     └──────────┘
   ◄── Spock bidirectional replication ──►
```

## Files

```
postgres-multinode/
├── docker-compose.yml      ← the compose file every node runs (identical)
├── db.json.template        ← template for pgEdge cluster config
├── nodes.conf              ← registry of all nodes in the cluster
├── .env.example            ← template for shared database passwords
├── .gitignore
├── README.md
├── deploy/                 ← generated per-node deploy bundles (gitignored)
│   ├── n1/
│   │   ├── docker-compose.yml
│   │   ├── db.json
│   │   └── .env
│   ├── n2/ ...
│   └── nN/ ...
└── scripts/
    ├── generate-passwords.sh
    ├── generate-db-json.sh
    ├── add-node.sh
    └── check-replication.sh
```

### Source files (checked into git)

| File | Purpose |
|---|---|
| `docker-compose.yml` | Runs pgEdge (PostgreSQL 16 + Spock) and pgCat (connection pooler). Every node uses this same file. The only per-node difference is the `NODE_NAME` variable in `.env`. |
| `nodes.conf` | Plain-text registry of every node in the cluster. One line per node: `<name> <region> <hostname>`. The hostname must be reachable from all other nodes (VPN IP, FQDN, etc). Used by `generate-db-json.sh` to build the cluster config. |
| `db.json.template` | Template for pgEdge's `db.json` config. Contains placeholder tokens that `generate-db-json.sh` replaces with values from `nodes.conf` and `.env`. Defines the database name, Spock options (`autoddl:enabled`), node list, and database users. |
| `.env.example` | Template for the five shared passwords (app, admin, pgedge, pgcat_auth, pgcat_admin). Copy to `.env` and fill in. These passwords must be identical across all nodes. |

### Scripts

| Script | Purpose |
|---|---|
| `scripts/generate-passwords.sh` | Prints five cryptographically random passwords to stdout. Paste the output into `.env`. |
| `scripts/generate-db-json.sh` | Reads `nodes.conf` + `.env`, renders `db.json.template` into a final `db.json`. Use `--all` to write it into every `deploy/*/` directory at once. |
| `scripts/add-node.sh` | Scaffolds a new deploy bundle under `deploy/<name>/`. Copies `docker-compose.yml`, creates `.env` with the right `NODE_NAME`, and appends the node to `nodes.conf`. |
| `scripts/check-replication.sh` | Runs Spock diagnostic queries on a node: node info, subscriptions, replication sets, replication slots, and WAL senders. |

### Generated files (gitignored)

| File | Purpose |
|---|---|
| `.env` | Actual passwords. Never committed. |
| `deploy/<name>/` | One directory per node. Contains `docker-compose.yml`, `.env` (just `NODE_NAME=...`), and the generated `db.json`. This entire directory is what you copy to a server. |
| `deploy/<name>/db.json` | The rendered pgEdge cluster config with real passwords and the full node list. Identical on every node — pgEdge reads `NODE_NAME` from the environment to know which node it is. |

## Deployment

### 1. Generate passwords

```bash
./scripts/generate-passwords.sh > .env
```

### 2. Define nodes in `nodes.conf`

```
n1  ap-south-1      10.100.0.1
n2  us-east-1       10.100.0.2
n3  ap-northeast-1  10.100.0.3
```

### 3. Create deploy bundles

```bash
./scripts/add-node.sh n1 ap-south-1 10.100.0.1
./scripts/add-node.sh n2 us-east-1 10.100.0.2
./scripts/add-node.sh n3 ap-northeast-1 10.100.0.3
```

### 4. Generate db.json for all nodes

```bash
./scripts/generate-db-json.sh --all
```

### 5. Copy and start each node

```bash
# Copy deploy/n1/ to the India server, then on that server:
docker compose up -d

# Same for n2 on US East, n3 on Tokyo, etc.
```

Start the first node, then the rest in any order. Spock automatically establishes replication between all nodes.

### Adding a node later

```bash
./scripts/add-node.sh n4 ap-southeast-1 10.100.0.4
./scripts/generate-db-json.sh --all
# Redistribute db.json to all running nodes, restart them, then start n4
```

### Checking replication

```bash
./scripts/check-replication.sh n1
```

## Ports

| Port | Service | Use |
|------|---------|-----|
| 5432 | pgEdge PostgreSQL | Replication between nodes, admin access |
| 6432 | pgCat pooler | Application connections |

## Notes

- **Conflict resolution**: Last-write-wins based on commit timestamps
- **AutoDDL**: Schema changes (CREATE TABLE, ALTER, etc.) replicate automatically
- **Networking**: Not included — add Traefik, Netbird, or your own overlay separately
- **All nodes are identical**: Same `docker-compose.yml`, same `db.json`, only `NODE_NAME` differs

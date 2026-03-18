# pgEdge Multi-Active Write PostgreSQL

Multi-active write PostgreSQL cluster using pgEdge with Spock logical replication. Supports N nodes.

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Node n1 │◄───►│  Node n2 │◄───►│  Node n3 │◄───►│  Node nN │
│  pgEdge  │     │  pgEdge  │     │  pgEdge  │     │  pgEdge  │
│  pgCat   │     │  pgCat   │     │  pgCat   │     │  pgCat   │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
       ◄──── Spock bidirectional replication (all nodes read/write) ────►
```

## File Structure

```
postgres-multinode/
├── .env.example          # Shared passwords (same on all nodes)
├── db.json.template      # Cluster config template
├── nodes.conf            # Node registry (name, region, hostname)
├── node-a/               # First node (ready to use)
│   ├── docker-compose.yml
│   └── .env              # NODE_NAME=n1
├── node-n/               # Template for additional nodes
│   ├── docker-compose.yml
│   └── .env              # NODE_NAME=<set per node>
└── scripts/
    ├── generate-passwords.sh   # Generate secure passwords
    ├── generate-db-json.sh     # Build db.json from nodes.conf + .env
    ├── add-node.sh             # Scaffold a new node directory
    └── check-replication.sh    # Query Spock replication status
```

## Quick Start

### 1. Generate passwords

```bash
./scripts/generate-passwords.sh
```

Paste the output into `.env`:

```bash
cp .env.example .env
vi .env
```

### 2. Define your nodes

Edit `nodes.conf` — one line per node:

```
n1  ap-south-1      10.100.0.1
n2  us-east-1       10.100.0.2
n3  ap-northeast-1  10.100.0.3
```

Hostnames must be reachable from every other node (VPN IPs, FQDNs, etc).

### 3. Generate db.json

```bash
./scripts/generate-db-json.sh --all
```

This writes `db.json` into every `node-*/` directory.

### 4. Deploy

Copy each node directory to its server, then:

```bash
cd node-a
docker compose up -d
```

Start node-a first, then the rest in any order.

## Adding More Nodes

```bash
# Scaffold
./scripts/add-node.sh node-singapore n4

# Register in nodes.conf
echo "n4  ap-southeast-1  10.100.0.4" >> nodes.conf

# Regenerate config for all nodes
./scripts/generate-db-json.sh --all

# Redistribute db.json to all running nodes and restart them
# Then deploy the new node
cd node-singapore && docker compose up -d
```

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 5432 | pgEdge  | PostgreSQL direct (replication + admin) |
| 6432 | pgCat   | Connection pooler (application traffic) |

## Checking Replication

```bash
./scripts/check-replication.sh node-a
```

## Notes

- **Conflict resolution**: Last-write-wins via commit timestamps (default)
- **AutoDDL**: Schema changes replicate automatically (`autoddl:enabled`)
- **Networking**: Not included here — add Traefik, Netbird, or your own overlay separately
- All nodes share identical `db.json` and passwords; only `NODE_NAME` differs per node

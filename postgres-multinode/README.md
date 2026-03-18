# PostgreSQL Multi-Active Write Deployment (3 Nodes)

Multi-active write PostgreSQL cluster using **pgEdge** with **Spock** logical replication across 3 geographically distributed nodes.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   India (n1)        │     │   US East (n2)       │     │   Tokyo (n3)        │
│   ap-south-1        │     │   us-east-1          │     │   ap-northeast-1    │
│                     │     │                      │     │                     │
│  ┌───────────────┐  │     │  ┌───────────────┐   │     │  ┌───────────────┐  │
│  │   Traefik     │  │     │  │   Traefik     │   │     │  │   Traefik     │  │
│  │  :80 / :443   │  │     │  │  :80 / :443   │   │     │  │  :80 / :443   │  │
│  └───────┬───────┘  │     │  └───────┬───────┘   │     │  └───────┬───────┘  │
│          │          │     │          │           │     │          │          │
│  ┌───────┴───────┐  │     │  ┌───────┴───────┐   │     │  ┌───────┴───────┐  │
│  │    pgCat      │  │     │  │    pgCat      │   │     │  │    pgCat      │  │
│  │  (pooler)     │  │     │  │  (pooler)     │   │     │  │  (pooler)     │  │
│  └───────┬───────┘  │     │  └───────┬───────┘   │     │  └───────┬───────┘  │
│          │          │     │          │           │     │          │          │
│  ┌───────┴───────┐  │     │  ┌───────┴───────┐   │     │  ┌───────┴───────┐  │
│  │   pgEdge      │◄─┼─────┼─►│   pgEdge      │◄──┼─────┼─►│   pgEdge      │  │
│  │  PostgreSQL   │  │     │  │  PostgreSQL   │   │     │  │  PostgreSQL   │  │
│  │  + Spock      │  │     │  │  + Spock      │   │     │  │  + Spock      │  │
│  └───────────────┘  │     │  └───────────────┘   │     │  └───────────────┘  │
│                     │     │                      │     │                     │
│  ┌───────────────┐  │     │  ┌───────────────┐   │     │  ┌───────────────┐  │
│  │   Netbird     │◄─┼─────┼─►│   Netbird     │◄──┼─────┼─►│   Netbird     │  │
│  │   VPN Mesh    │  │     │  │   VPN Mesh    │   │     │  │   VPN Mesh    │  │
│  └───────────────┘  │     │  └───────────────┘   │     │  └───────────────┘  │
└─────────────────────┘     └──────────────────────┘     └─────────────────────┘
         ◄──── Spock Multi-Active Write Replication (bidirectional) ────►
```

## Key Components

| Component | Purpose |
|-----------|---------|
| **pgEdge** | PostgreSQL 16 with Spock multi-master replication |
| **Spock** | Logical replication extension enabling multi-active writes |
| **pgCat** | Connection pooler with auth integration |
| **Traefik** | Reverse proxy with automatic TLS (Let's Encrypt) |
| **Netbird** | WireGuard-based mesh VPN for encrypted inter-node traffic |

## Networking Options

### Option A: Netbird VPN (Recommended)

All inter-node PostgreSQL replication flows over Netbird's encrypted WireGuard mesh.
- No public ports needed for replication (only 80/443 for application access via Traefik)
- Automatic peer discovery and NAT traversal
- Each node gets a stable VPN hostname

### Option B: Traefik TLS Only

PostgreSQL connections are routed through Traefik on ports 80/443 with TLS.
- Uses SNI-based routing for PostgreSQL TCP streams
- Requires public domain names for each node
- All traffic encrypted via Let's Encrypt certificates

**Both options can run simultaneously** (the default configuration includes both).

## Deployment Guide

### Prerequisites

- Docker Engine 24+ and Docker Compose v2 on each server
- Netbird account with a setup key (for VPN option)
- Domain names pointing to each server (for Traefik TLS option)
- Ports 80 and 443 open on each server

### Step 1: Generate Passwords

```bash
chmod +x scripts/*.sh
./scripts/generate-passwords.sh
```

Copy the output passwords - you'll use them in every node's `.env`.

### Step 2: Configure Environment

On each server, copy and edit the node's `.env`:

```bash
# On India server:
cp node-india/.env.example node-india/.env
vi node-india/.env

# On US East server:
cp node-us-east/.env.example node-us-east/.env
vi node-us-east/.env

# On Tokyo server:
cp node-tokyo/.env.example node-tokyo/.env
vi node-tokyo/.env
```

**Critical**: All nodes MUST have identical passwords and hostnames.

### Step 3: Generate db.json

```bash
# Set up a root .env with shared values, then:
./scripts/generate-db-json.sh

# Copy to each node directory
cp shared/db.json node-india/db.json
cp shared/db.json node-us-east/db.json
cp shared/db.json node-tokyo/db.json
```

### Step 4: Deploy Nodes

Deploy nodes one at a time, starting with India (n1):

```bash
# On India server:
./scripts/deploy-node.sh node-india

# On US East server:
./scripts/deploy-node.sh node-us-east

# On Tokyo server:
./scripts/deploy-node.sh node-tokyo
```

Or manually:

```bash
cd node-india
docker compose up -d
```

### Step 5: Verify Replication

```bash
./scripts/check-replication.sh node-india
```

You should see:
- 3 Spock nodes registered
- Active subscriptions between all node pairs
- WAL senders for each subscription

## Connecting to the Database

### Application Connection (via pgCat pooler)

```
# Connect to nearest node for lowest latency
psql "host=db-india.example.com port=5432 dbname=defaultdb user=app password=<APP_PASSWORD> sslmode=require"
```

### Admin Connection (direct to pgEdge)

```bash
# Via docker exec on any node
docker compose exec pgedge psql -U admin -d defaultdb
```

## How Multi-Active Write Works

pgEdge uses **Spock**, a logical replication extension that enables:

1. **All nodes accept writes** - No primary/replica distinction
2. **Conflict resolution** - Last-write-wins using commit timestamps (configurable)
3. **AutoDDL** - Schema changes automatically replicate to all nodes
4. **Row-level filtering** - Optional per-node data partitioning

Writes to any node asynchronously replicate to all other nodes. For most workloads, replication lag is sub-second within the same region and low single-digit seconds cross-region.

### Conflict Resolution

The default `autoddl:enabled` option in `db.json` enables:
- Automatic DDL replication (CREATE TABLE, ALTER TABLE, etc.)
- Last-writer-wins conflict resolution based on commit timestamps

For custom conflict resolution, refer to the [pgEdge Spock documentation](https://docs.pgedge.com).

## Operations

### View Logs

```bash
docker compose -f node-india/docker-compose.yml logs -f pgedge
docker compose -f node-india/docker-compose.yml logs -f traefik
docker compose -f node-india/docker-compose.yml logs -f netbird
```

### Stop a Node

```bash
docker compose -f node-india/docker-compose.yml down
```

The other nodes continue operating. When this node comes back, Spock automatically catches up.

### Backup

```bash
# On any node:
docker compose exec pgedge pg_dump -U admin defaultdb > backup.sql
```

### Scale (Add a 4th Node)

1. Create a new node directory with docker-compose.yml
2. Add the node to `db.json` and redistribute to all nodes
3. Restart all nodes to pick up the new configuration

## File Structure

```
postgres-multinode/
├── .env.example              # Template for shared environment variables
├── .gitignore
├── README.md
├── shared/
│   └── db.json.template      # Template for pgEdge cluster configuration
├── node-india/
│   ├── docker-compose.yml    # Docker Compose for India node (n1)
│   ├── .env.example
│   └── traefik-dynamic/
│       └── tls.yml
├── node-us-east/
│   ├── docker-compose.yml    # Docker Compose for US East node (n2)
│   ├── .env.example
│   └── traefik-dynamic/
│       └── tls.yml
├── node-tokyo/
│   ├── docker-compose.yml    # Docker Compose for Tokyo node (n3)
│   ├── .env.example
│   └── traefik-dynamic/
│       └── tls.yml
└── scripts/
    ├── generate-passwords.sh # Generate secure random passwords
    ├── generate-db-json.sh   # Generate db.json from template
    ├── deploy-node.sh        # Deploy a node
    └── check-replication.sh  # Check replication status
```

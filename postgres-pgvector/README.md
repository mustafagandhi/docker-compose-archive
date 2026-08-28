# PostgreSQL + pgvector

PostgreSQL 18 with pgvector 0.8.2 for vector similarity search. Use this instead of standard postgres when your app needs vector embeddings.

## Image

`pgvector/pgvector:0.8.2-pg18-bookworm` (Debian-based, Alpine not available for pgvector)

## Usage

1. Replace `APP_NAME` in `docker-compose.yml` with your app name
2. Generate credentials: `bash env-generate.sh myapp`
3. Paste compose into Komodo, set env vars, deploy
4. Enable extension:
```bash
docker exec APP_NAME-postgres psql -U APP_NAME -d APP_NAME -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

## Vector Operations

```sql
-- Create a table with vector column
CREATE TABLE items (id SERIAL PRIMARY KEY, embedding vector(512));

-- Insert
INSERT INTO items (embedding) VALUES ('[0.1, 0.2, ...]');

-- Cosine similarity search
SELECT id, embedding <=> '[0.1, 0.2, ...]'::vector AS distance
FROM items ORDER BY distance LIMIT 10;

-- Create index for faster search
CREATE INDEX ON items USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

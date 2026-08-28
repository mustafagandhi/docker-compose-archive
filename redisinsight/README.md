# RedisInsight

Redis web management UI (image: `redis/redisinsight:latest`, listens on port 5540). Shared instance — connects to all Redis databases.

## Access

`https://redis.example.com`

## Usage

1. Paste compose into Komodo, deploy (no env vars needed)
2. Open RedisInsight in browser
3. Add Redis connections: host=`APP_NAME-redis`, port=`6379`, password from Redis stack

## Adding New Databases

When a new app deploys Redis, add its network to this stack:
```yaml
networks:
  - proxy
  - myapp
  - newapp    # add this
```
Then redeploy in Komodo.

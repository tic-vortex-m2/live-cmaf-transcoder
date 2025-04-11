#!/usr/bin/sh

REDIS_PASSWORD="${REDIS_PASSWORD:-eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81}"
REDIS_CONF="/etc/redis/redis.conf"

if grep -q "^requirepass " "$REDIS_CONF"; then
  sed -i "s/^requirepass .*/requirepass $REDIS_PASSWORD/" "$REDIS_CONF"
else
  echo "requirepass $REDIS_PASSWORD" >> "$REDIS_CONF"
fi

if ! grep -qE '^save[[:space:]]+20[[:space:]]+1' "$REDIS_CONF"; then
  echo "save 20 1" >> "$REDIS_CONF"
fi

sed -i 's/^loglevel.*/loglevel warning/' "$REDIS_CONF"
sed -i 's/^notify-keyspace-events.*/notify-keyspace-events KEA/' "$REDIS_CONF"
sed -i 's/^bind.*/# bind/' "$REDIS_CONF"
sed -i 's|^?dir .*|dir /data|' "$REDIS_CONF"

if [ "$REDIS_SERVICE_DISABLED" = "true" ] || [ "$REDIS_SERVICE_DISABLED" = "1" ]; then
  echo "Redis is disabled. Skipping start."
else
  service redis-server start
fi
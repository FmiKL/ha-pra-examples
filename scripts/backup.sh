#!/bin/sh

# Export cohérent avec les droits du compte applicatif.
docker compose exec -T db sh -c '
    MYSQL_PWD="$MYSQL_PASSWORD" exec mysqldump \
        --single-transaction \
        --no-tablespaces \
        --set-gtid-purged=OFF \
        -u "$MYSQL_USER" "$MYSQL_DATABASE"
'

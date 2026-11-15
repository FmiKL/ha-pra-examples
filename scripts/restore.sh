#!/bin/sh

docker compose exec -T db sh -c '
    MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -u "$MYSQL_USER" "$MYSQL_DATABASE"
'

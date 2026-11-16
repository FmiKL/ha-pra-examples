#!/bin/sh

set -eu

. ./scripts/common.sh
select_environment "${1:-ovh}"

# Export cohérent avec les droits du compte applicatif.
docker exec "$db_container" sh -c '
    MYSQL_PWD="$MYSQL_PASSWORD" exec mysqldump \
        --single-transaction \
        --no-tablespaces \
        --set-gtid-purged=OFF \
        -u "$MYSQL_USER" "$MYSQL_DATABASE"
'

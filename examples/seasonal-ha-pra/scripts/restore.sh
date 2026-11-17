#!/bin/sh

set -eu

. ./scripts/common.sh
select_environment "${1:-ovh}"

docker exec -i "$db_container" sh -c '
    MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -u "$MYSQL_USER" "$MYSQL_DATABASE"
'

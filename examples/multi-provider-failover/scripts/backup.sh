#!/bin/sh

set -eu

case "${1:-scaleway}" in
    scaleway|ovh) ;;
    *)
        printf 'Usage: %s [scaleway|ovh]\n' "$0" >&2
        exit 1
        ;;
esac

# Export cohérent avec les droits du compte applicatif.
docker compose exec -T "${1:-scaleway}-db" sh -c '
    MYSQL_PWD="$MYSQL_PASSWORD" exec mysqldump \
        --single-transaction \
        --no-tablespaces \
        --set-gtid-purged=OFF \
        -u "$MYSQL_USER" "$MYSQL_DATABASE"
'

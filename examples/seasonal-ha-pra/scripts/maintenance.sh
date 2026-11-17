#!/bin/sh

set -eu

case "${1:-}" in
    on|off) ;;
    *)
        printf 'Usage: %s on|off [ovh|scaleway]\n' "$0" >&2
        exit 1
        ;;
esac

. ./scripts/common.sh
select_environment "${2:-ovh}"

if [ -z "$app_containers" ]; then
    printf 'Aucun conteneur applicatif pour cet environnement.\n' >&2
    exit 1
fi

for container in $app_containers; do
    if [ "$1" = on ]; then
        # Poser le marqueur même sur une instance arrêtée.
        docker cp .maintenance "$container:/var/www/html/public/.maintenance"
    else
        docker exec "$container" rm -f /var/www/html/public/.maintenance
    fi
done

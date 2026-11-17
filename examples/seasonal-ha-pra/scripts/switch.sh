#!/bin/sh

set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] || [ "$1" = "$2" ]; then
    printf 'Usage: %s source destination [sauvegarde.sql]\n' "$0" >&2
    exit 1
fi

. ./scripts/common.sh
source_environment="$1"
destination_environment="$2"

select_environment "$source_environment"
if [ "$#" -eq 3 ] && [ ! -s "$3" ]; then
    printf 'Sauvegarde absente ou vide.\n' >&2
    exit 1
fi

mkdir -p backups
mkdir backups/.switch.lock

dump=backups/.switch.lock/app.sql
trap 'rm -f "$dump"; rmdir backups/.switch.lock' EXIT
trap 'exit 1' HUP INT TERM

active_origin="$(docker compose exec -T cloudflare cat /usr/local/etc/haproxy/routing/origin.map)"
if [ "$active_origin" != "active $source_environment" ]; then
    printf "La source indiquée ne correspond pas à l'origine active.\n" >&2
    exit 1
fi

if [ "$#" -eq 2 ]; then
    docker compose exec -T cloudflare wget -q -T 10 -O - "http://$source_environment/health" > /dev/null
fi

./scripts/maintenance.sh on "$destination_environment"
./scripts/maintenance.sh on "$source_environment"

# Terminer les requêtes en cours avant le transfert SQL.
docker stop $app_containers
select_environment "$destination_environment"
docker stop $app_containers

if [ "$#" -eq 3 ]; then
    cp "$3" "$dump"
else
    ./scripts/backup.sh "$source_environment" > "$dump"

    # Remettre la source en service, toujours en maintenance.
    select_environment "$source_environment"
    docker start $app_containers
    for container in $app_containers; do
        wait_healthy "$container"
    done
fi

# La base de destination peut être arrêtée, par exemple au retour d'un PRA.
select_environment "$destination_environment"
docker start "$db_container"
wait_healthy "$db_container"

./scripts/restore.sh "$destination_environment" < "$dump"

docker start $app_containers
for container in $app_containers; do
    wait_healthy "$container"
done

if [ "$destination_environment" = scaleway ]; then
    docker start "$origin_container"
    wait_healthy "$origin_container"
fi

docker compose exec -T cloudflare wget -q -T 10 -O - "http://$destination_environment/health"
printf '\n'

# Conserver l'origine active dans le volume du proxy.
docker compose exec -T --user root cloudflare sh -c \
    'printf "active %s\n" "$1" > /usr/local/etc/haproxy/routing/origin.map' sh "$destination_environment"
docker compose restart cloudflare
docker compose start --wait cloudflare
docker compose exec -T cloudflare wget -q -T 10 -O - http://127.0.0.1/health
printf '\n'

./scripts/maintenance.sh off "$destination_environment"
docker compose exec -T cloudflare wget -q -T 10 -O /dev/null http://127.0.0.1/
printf 'Origine active : %s\n' "$destination_environment"

#!/bin/sh

set -eu

case "$*" in
    vps1|vps2|"vps1 --force"|"vps2 --force") ;;
    *)
        printf 'Usage: %s vps1|vps2 [--force]\n' "$0" >&2
        exit 1
        ;;
esac

target="$1"
action=setPrimaryInstance
if [ "${2:-}" = --force ]; then
    # Le primaire est inaccessible, les transactions non répliquées sont perdues.
    action=forcePrimaryInstance
fi

docker compose exec -T "$target-db" sh -c '
    exec mysqlsh --no-defaults --uri "root:$MYSQL_ROOT_PASSWORD@localhost" --js -e "$1"
' sh "dba.getReplicaSet().$action('$target-db:3306')"

# Retirer l'IP flottante de l'autre VPS avant de la donner au VPS promu.
network="${COMPOSE_PROJECT_NAME:-active-standby}_default"
other=vps2
if [ "$target" = vps2 ]; then
    other=vps1
fi

other_app="$(docker compose ps -aq "$other-app")"
docker network disconnect "$network" "$other_app"
docker network connect "$network" "$other_app"

target_app="$(docker compose ps -aq "$target-app")"
docker network disconnect "$network" "$target_app"
docker network connect --alias vip "$network" "$target_app"

# Attendre que la passerelle suive l'IP flottante.
remaining=10

while [ "$remaining" -gt 0 ]; do
    health="$(docker compose exec -T gateway wget -q -T 2 -O - http://127.0.0.1/health || true)"
    case "$health" in
        *"\"environment\":\"$target\""*)
            printf '%s\n' "$health"
            exit 0
            ;;
    esac

    sleep 1
    remaining=$((remaining - 1))
done

printf "L'IP flottante ne répond pas depuis %s.\n" "$target" >&2
exit 1

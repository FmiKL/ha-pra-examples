#!/bin/sh

set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] || [ "$1" = "$2" ]; then
    printf 'Usage: %s source destination [sauvegarde.sql]\n' "$0" >&2
    exit 1
fi

for environment in "$1" "$2"; do
    case "$environment" in
        scaleway|ovh) ;;
        *)
            printf 'Environnement attendu : scaleway ou ovh.\n' >&2
            exit 1
            ;;
    esac
done

if [ "$#" -eq 3 ] && [ ! -s "$3" ]; then
    printf 'Sauvegarde absente ou vide.\n' >&2
    exit 1
fi

# La base active est enregistrée dans .env, que lit Compose.
active="$(sed -n 's/^ACTIVE_DATABASE=//p' .env 2>/dev/null || true)"
if [ "${active:-scaleway-db}" != "$1-db" ]; then
    printf 'La source indiquée ne correspond pas à la base active.\n' >&2
    exit 1
fi

# Arrêter les applications pour figer les données pendant le transfert.
docker compose stop scaleway-app ovh-app

if [ "$#" -eq 3 ]; then
    dump="$3"
else
    mkdir -p backups
    dump="backups/$1-$(date +%Y%m%d-%H%M%S).sql"
    ./scripts/backup.sh "$1" > "$dump"
fi

docker compose exec -T "$2-db" sh -c '
    MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -u "$MYSQL_USER" "$MYSQL_DATABASE"
' < "$dump"

# Mettre à jour la base active, sans toucher aux autres réglages de .env.
touch .env
grep -v '^ACTIVE_DATABASE=' .env > .env.new || true
printf 'ACTIVE_DATABASE=%s-db\n' "$2" >> .env.new
mv .env.new .env
docker compose up -d --no-deps --wait scaleway-app ovh-app

# Attendre que Cloudflare considère de nouveau les origines comme saines.
remaining=10

while [ "$remaining" -gt 0 ]; do
    if docker compose exec -T cloudflare wget -q -T 2 -O - http://127.0.0.1/health; then
        printf '\n'
        exit 0
    fi

    sleep 1
    remaining=$((remaining - 1))
done

printf "L'application ne répond pas sur la base %s.\n" "$2" >&2
exit 1

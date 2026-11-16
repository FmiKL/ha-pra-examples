#!/bin/sh

select_environment() {
    project_name="${COMPOSE_PROJECT_NAME:-seasonal-ha-pra}"

    case "$1" in
        ovh)
            app_containers="$(docker compose ps -aq app)"
            db_container="$(docker compose ps -aq db)"
            origin_container="$app_containers"
            ;;
        scaleway)
            app_containers="$(docker ps -aq --filter "label=seasonal-ha-pra.app=$project_name-scaleway")"
            db_container="$project_name-scaleway-db"
            origin_container="$project_name-scaleway-lb"
            ;;
        *)
            printf 'Environnement attendu : ovh ou scaleway.\n' >&2
            exit 1
            ;;
    esac
}

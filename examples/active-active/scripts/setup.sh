#!/bin/sh

set -eu

case "${1:-vps1}" in
    vps1) other=vps2 ;;
    vps2) other=vps1 ;;
    *)
        printf 'Usage: %s [vps1|vps2]\n' "$0" >&2
        exit 1
        ;;
esac

first="${1:-vps1}"
variable="$(printf '%s' "$first" | tr '[:lower:]' '[:upper:]')_CLUSTER_JOIN"

# Créer le cluster sur le premier nœud, puis y faire entrer l'autre et l'arbitre.
env "$variable=" docker compose up -d --wait --no-deps "$first-db"
env "$variable=" docker compose up -d --wait --no-deps "$other-db" arbiter

# Relancer le premier nœud pour qu'il rejoigne ensuite le cluster au lieu d'en créer un.
docker compose up -d --wait --no-deps "$first-db"

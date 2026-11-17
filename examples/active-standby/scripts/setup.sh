#!/bin/sh

set -eu

# Créer le ReplicaSet avec vps1 comme primaire, puis cloner vps1 vers vps2.
docker compose exec -T vps1-db sh -c '
    exec mysqlsh --no-defaults --uri "root:$MYSQL_ROOT_PASSWORD@localhost" --js -e "$1"
' sh "dba.createReplicaSet('app').addInstance('vps2-db:3306', { recoveryMethod: 'clone' })"

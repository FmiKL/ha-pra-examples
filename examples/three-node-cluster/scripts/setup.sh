#!/bin/sh

set -eu

# Créer le cluster sur vps1, puis cloner vps1 vers vps2 et vps3.
docker compose exec -T vps1-db sh -c '
    exec mysqlsh --no-defaults --uri "root:$MYSQL_ROOT_PASSWORD@localhost" --js -e "$1"
' sh "
    const cluster = dba.createCluster('app');
    cluster.addInstance('vps2-db:3306', { recoveryMethod: 'clone' });
    cluster.addInstance('vps3-db:3306', { recoveryMethod: 'clone' });
"

#!/bin/sh

set -eu

# Créer le ReplicaSet avec vps1 comme primaire, puis cloner vps1 vers vps2.
# Chaque base se reconnecte toutes les 5 secondes si elle perd sa source.
docker compose exec -T vps1-db sh -c '
    exec mysqlsh --no-defaults --uri "root:$MYSQL_ROOT_PASSWORD@localhost" --js -e "$1"
' sh "
    const replicaSet = dba.createReplicaSet('app');
    replicaSet.setInstanceOption('vps1-db:3306', 'replicationConnectRetry', 5);
    replicaSet.addInstance('vps2-db:3306', { recoveryMethod: 'clone', replicationConnectRetry: 5 });
"

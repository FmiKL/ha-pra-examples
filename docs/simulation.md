# Simulation locale

| Environnement | Simulation                                                | Accès                                   |
| ------------- | --------------------------------------------------------- | --------------------------------------- |
| Cloudflare    | Proxy commun et choix de l'origine active                 | [localhost:8080](http://localhost:8080) |
| OVHcloud      | PHP/Apache et MySQL sous Compose                          | [localhost:8081](http://localhost:8081) |
| Scaleway      | Deux instances PHP, load balancer et MySQL sous Terraform | [localhost:8082](http://localhost:8082) |

Les deux environnements utilisent la même image applicative et tournent sur le même poste, avec une seule instance MySQL chacun. La délégation DNS, DNSSEC, HTTPS, MySQL HA et les protections Cloudflare ne sont pas simulés.

## Maintenance

Le fichier `public/.maintenance` bloque les pages et les écritures avec une réponse `503`. La route `/health` reste accessible et indique `maintenance: true`.

```sh
./scripts/maintenance.sh on ovh
docker compose run --rm --no-deps app php tests/smoke.php http://ovh --maintenance
./scripts/maintenance.sh off ovh
```

Le marqueur est inclus dans l'image, donc toute nouvelle instance démarre en maintenance. Un redémarrage conserve le mode courant. Le script pose aussi le marqueur sur les instances arrêtées.

## Préparer Scaleway

Depuis la racine du projet, avec OVHcloud et le proxy démarrés. La première commande transmet le contexte Docker courant au fournisseur Terraform.

```sh
export DOCKER_CONTEXT="$(docker context show)"
terraform -chdir=terraform/local init
terraform -chdir=terraform/local apply
docker compose run --rm --no-deps app php tests/smoke.php http://scaleway --maintenance
```

## Bascules

Basculer sur Scaleway, puis revenir sur OVHcloud.

```sh
./scripts/switch.sh ovh scaleway
./scripts/switch.sh scaleway ovh
```

Le script :

1. Pose un verrou et vérifie que la source est l'origine active.
2. Met les deux environnements en maintenance et arrête PHP.
3. Exporte la source, ou reprend la sauvegarde indiquée, puis restaure la destination.
4. Vérifie la santé de la destination et modifie le routage du proxy commun.
5. Vérifie l'accès public, puis autorise les écritures sur la destination.

L'ancienne origine reste en maintenance et l'adresse publique reste `localhost:8080`. Un échec avant la dernière étape laisse les écritures bloquées. Le choix d'origine persiste au redémarrage et à la recréation du proxy.

## Panne d'une instance Scaleway

Avec Scaleway actif, arrêter une instance, vérifier le fonctionnement par l'entrée publique, puis rétablir l'instance avec Terraform.

```sh
docker stop seasonal-ha-pra-scaleway-app-1
docker compose run --rm --no-deps app php tests/smoke.php
terraform -chdir=terraform/local apply
```

## Reprise depuis une sauvegarde

Avec OVHcloud actif, conserver un export puis simuler sa panne.

```sh
mkdir -p backups
./scripts/backup.sh ovh > backups/ovh.sql
docker compose stop app db
./scripts/switch.sh ovh scaleway backups/ovh.sql
```

Seules les données de cet export sont reprises. Le script pose le marqueur sur les conteneurs source arrêtés et échoue s'ils ont été supprimés. Chez les fournisseurs, ce blocage doit être garanti par un mécanisme prévu avant la panne.

## Panne de Cloudflare

L'accès direct à l'origine active simule le contournement de Cloudflare. Avec OVHcloud actif, vérifier cet accès pendant l'arrêt du proxy.

```sh
docker compose stop cloudflare
curl --fail http://localhost:8081/health
docker compose start --wait cloudflare
```

Si Scaleway est actif, utiliser son load balancer sur `localhost:8082`.

## Fin de saison

Après le retour validé sur OVHcloud, détruire les ressources saisonnières.

```sh
terraform -chdir=terraform/local destroy
```

L'application OVHcloud, le proxy, leurs volumes et l'état Terraform sont conservés. Pour arrêter les services permanents, utiliser `docker compose down`.

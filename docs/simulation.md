# Simulation locale

OVHcloud est représenté par PHP/Apache et MySQL sous Compose. Terraform crée le réseau privé, les deux instances PHP, le load balancer et la base MySQL séparée de Scaleway. Les deux environnements utilisent la même image applicative.

## Préparer Scaleway

Depuis la racine du projet, avec OVHcloud démarré et son image construite.

```sh
export DOCKER_CONTEXT="$(docker context show)"
terraform -chdir=terraform/local init
terraform -chdir=terraform/local apply
docker compose run --rm --no-deps app php tests/smoke.php http://scaleway
```

Scaleway est accessible sur [localhost:8081](http://localhost:8081). Les conteneurs représentent les deux VPS, mais restent sur le même poste. MySQL est unique dans chaque environnement.

## Panne d'une instance

Arrêter une instance Scaleway, vérifier le fonctionnement par son load balancer, puis rétablir l'instance avec Terraform.

```sh
docker stop seasonal-ha-pra-scaleway-app-1
docker compose run --rm --no-deps app php tests/smoke.php http://scaleway
terraform -chdir=terraform/local apply
```

## Fin de simulation

```sh
terraform -chdir=terraform/local destroy
docker compose down
```

Terraform détruit uniquement les ressources Scaleway. L'environnement OVHcloud, l'image applicative et les fichiers d'état restent disponibles.

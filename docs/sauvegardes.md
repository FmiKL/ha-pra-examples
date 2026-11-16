# Sauvegardes

Chaque export est copié dans deux buckets permanents, chez **OVHcloud** et **Scaleway**, quelle que soit la base active. Ces buckets sont indépendants des ressources Terraform saisonnières.

## Principes

1. Produire régulièrement un export MySQL cohérent depuis un environnement autorisé à accéder à la base.
2. Chiffrer, dater et vérifier les exports avant leur stockage.
3. Conserver plusieurs générations et signaler les échecs de sauvegarde.
4. Tester périodiquement une restauration dans un environnement isolé.

Les sauvegardes sont planifiées chez les fournisseurs. Sur le mutualisé OVHcloud, les exports doivent être exécutés depuis l'hébergement. Les éventuels fichiers persistants suivent la même stratégie.

La fréquence, la durée de conservation et les objectifs de reprise (RPO et RTO) sont à définir avant la mise en production. Le planificateur natif de l'hébergement web OVHcloud permet au maximum une exécution par heure. Une fréquence supérieure nécessite un autre mécanisme de déclenchement. Voir les [limitations des tâches CRON OVHcloud](https://docs.ovhcloud.com/fr/guides/web-cloud/web-hosting/cron-tasks).

Les sauvegardes natives de MySQL managé complètent les copies externes sans les remplacer.

## Exécution locale

Les commandes s'exécutent depuis la racine du projet, avec les services Compose démarrés. Les fichiers SQL sont produits avec [`mysqldump`](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html) et conservés dans `backups/`, hors du volume MySQL. Ce dossier est exclu de Git et du contexte de construction Docker.

```sh
mkdir -p backups
./scripts/backup.sh > backups/app.sql.tmp && mv backups/app.sql.tmp backups/app.sql
```

L'export passe par un fichier temporaire, pour ne pas écraser la sauvegarde précédente s'il échoue.

Sans argument, les scripts utilisent OVHcloud. Ajouter `scaleway` pour sauvegarder ou restaurer sa base.

La restauration remplace les données courantes par celles de l'export. Arrêter l'application pendant l'importation.

```sh
docker compose stop app &&
./scripts/restore.sh < backups/app.sql &&
docker compose start --wait
```

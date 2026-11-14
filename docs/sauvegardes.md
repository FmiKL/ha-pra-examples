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

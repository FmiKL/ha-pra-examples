# HA & PRA Examples

Exemples d'architectures de haute disponibilité et de reprise d'activité, testables en local avec Docker.

| Exemple                                                 | Architecture                                                      | Statut     |
| ------------------------------------------------------- | ----------------------------------------------------------------- | ---------- |
| [Seasonal HA & PRA](examples/seasonal-ha-pra/README.md) | Haute disponibilité saisonnière et PRA entre OVHcloud et Scaleway | Disponible |
| Active/Standby (InnoDB ReplicaSet)                      | Deux VPS, réplication asynchrone et IP flottante                  | En projet  |
| Three-Node Cluster (InnoDB Cluster)                     | Load balancer, MySQL Router et bascule automatique du primaire    | En projet  |

Tous les exemples utilisent la même application PHP, dans [app/](app/). Elle incrémente un compteur stocké dans MySQL et expose une route `/health`. Chaque exemple construit son image à partir de ce dossier et dispose de sa propre documentation.

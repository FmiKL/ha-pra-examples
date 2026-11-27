# Exemples HA et PRA

Exemples d'architectures de haute disponibilité et de reprise d'activité, testables en local avec Docker.

| Exemple                                                                                         | Architecture                                                               |
| ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [Haute disponibilité saisonnière et PRA](examples/seasonal-ha-pra/README.md)                    | OVHcloud permanent, renfort saisonnier chez Scaleway et PRA entre les deux |
| [Actif/secours (InnoDB ReplicaSet)](examples/active-standby/README.md)                          | Deux VPS, réplication asynchrone et IP flottante                           |
| [Cluster à trois nœuds (InnoDB Cluster)](examples/three-node-cluster/README.md)                 | Load balancer, MySQL Router et bascule automatique du primaire             |
| [Actif-actif (Percona XtraDB Cluster)](examples/active-active/README.md)                        | Deux VPS qui écrivent tous les deux, avec un arbitre                       |
| [Repli multi-hébergeur (Cloudflare Load Balancing)](examples/multi-provider-failover/README.md) | Application chez Scaleway et OVHcloud, base managée chez Scaleway          |

Un seul exemple tourne à la fois, car ils utilisent les mêmes ports locaux.

Tous les exemples utilisent la même application PHP, dans [app/](app/). Elle incrémente un compteur stocké dans MySQL et expose une route `/health`. Chaque exemple construit son image à partir de ce dossier et dispose de sa propre documentation.

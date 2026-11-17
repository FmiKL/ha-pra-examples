# Exemples HA et PRA

Exemples d'architectures de haute disponibilité et de reprise d'activité, testables en local avec Docker.

| Exemple                                                                      | Architecture                                                               |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [Haute disponibilité saisonnière et PRA](examples/seasonal-ha-pra/README.md) | OVHcloud permanent, renfort saisonnier chez Scaleway et PRA entre les deux |

Tous les exemples utilisent la même application PHP, dans [app/](app/). Elle incrémente un compteur stocké dans MySQL et expose une route `/health`. Chaque exemple construit son image à partir de ce dossier et dispose de sa propre documentation.

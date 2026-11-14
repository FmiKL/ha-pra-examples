# Plan de reprise d'activité

| Incident                                 | Procédure                                                                      |
| ---------------------------------------- | ------------------------------------------------------------------------------ |
| [Scaleway indisponible](scaleway.md)     | Si Scaleway est l'hébergeur principal, reprise sur OVHcloud après restauration |
| [OVHcloud indisponible](ovhcloud.md)     | Maintien ou déploiement de Scaleway selon la saison                            |
| [Cloudflare indisponible](cloudflare.md) | Reprise manuelle de la gestion DNS depuis OVHcloud                             |

Une panne isolée d'instance ou de nœud MySQL chez Scaleway relève d'abord de la **haute disponibilité interne**. Le PRA entre fournisseurs est déclenché manuellement et peut nécessiter la restauration d'une sauvegarde antérieure.

Voir aussi [Orchestration](../orchestration.md) et [Sauvegardes](../sauvegardes.md).

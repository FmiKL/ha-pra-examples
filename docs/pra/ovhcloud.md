# PRA : OVHcloud indisponible

## Hors saison : OVHcloud actif

1. Provisionner Scaleway et déployer l'application.
2. Exporter MySQL depuis OVHcloud si possible, après suspension des écritures. Sinon, récupérer la dernière sauvegarde exploitable du bucket Scaleway.
3. Restaurer les données et vérifier le fonctionnement de l'application sur Scaleway.
4. Vérifier qu'OVHcloud ne peut plus écrire, même après redémarrage.
5. Modifier le DNS Cloudflare vers Scaleway, vérifier l'accès public, puis autoriser les écritures.

Les scripts, les identifiants et l'état Terraform doivent rester accessibles même si OVHcloud est indisponible.

## Pendant la saison : Scaleway actif

Si Scaleway est sain, une panne d'OVHcloud ne nécessite aucune bascule applicative. La copie des sauvegardes chez OVHcloud est reprise après rétablissement du service.

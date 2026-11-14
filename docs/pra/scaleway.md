# PRA : Scaleway indisponible

Reprise exceptionnelle chez OVHcloud pendant la saison, lorsque la haute disponibilité interne à Scaleway ne suffit plus.

1. Vérifier la disponibilité de l'application OVHcloud, sans autoriser les écritures.
2. Exporter MySQL depuis Scaleway si possible, après suspension des écritures. Sinon, récupérer la dernière sauvegarde exploitable du bucket OVHcloud.
3. Restaurer les données sur OVHcloud et vérifier le fonctionnement de l'application.
4. Vérifier que Scaleway ne peut plus écrire, même après redémarrage.
5. Modifier le DNS Cloudflare vers OVHcloud, vérifier l'accès public, puis autoriser les écritures.

Des données récentes peuvent être perdues. Leur récupération éventuelle doit être traitée après la reprise, sans réactiver l'ancienne base en parallèle.

# PRA : Cloudflare indisponible

Procédure manuelle de dernier recours, indépendante de Cloudflare et de Rundeck.

Le domaine est enregistré chez OVHcloud, mais sa zone DNS habituelle est gérée par Cloudflare. En cas de panne majeure de Cloudflare, la délégation DNS peut être modifiée depuis l'espace client OVHcloud, si les services OVHcloud restent accessibles.

1. Identifier l'origine active (OVHcloud ou Scaleway) et vérifier son accès direct en HTTPS.
2. Vérifier la zone DNS de secours préparée chez OVHcloud : adresse de l'origine active et enregistrements indispensables, notamment ceux de messagerie.
3. Appliquer la procédure DNSSEC prévue pour la zone de secours, notamment pour l'enregistrement DS chez le registraire.
4. Remplacer manuellement les serveurs DNS Cloudflare par ceux d'OVHcloud.
5. Contrôler la résolution du domaine et l'accès HTTPS depuis plusieurs réseaux.

La zone de secours et la procédure DNSSEC doivent être vérifiées à chaque bascule saisonnière. La mise à jour des serveurs DNS peut prendre jusqu'à 48 heures selon les caches, voire davantage si DNSSEC doit être modifié. Ce contournement retire les protections du proxy Cloudflare. Si l'origine active est saine, **aucune restauration MySQL n'est nécessaire**.

Référence : [Modifier les serveurs DNS chez OVHcloud](https://docs.ovhcloud.com/fr/guides/web-cloud/domains/dns-server-edit).

# Vanadium Suite

Module root pour installer les bases système de **Vanadium Browser**,
**Vanadium WebView** et **Vanadium Config**, puis laisser les mises à jour à
l’**App Store GrapheneOS**.

**Version : v1 — testée par l’utilisateur sur VoltageOS 16.2 / Android 16,
ARM64 multilib, avec BakaSU.** Les autres configurations ne sont pas validées.

> Projet communautaire non officiel, sans affiliation avec GrapheneOS.
> Il ne reproduit pas les protections de GrapheneOS. Une modification du
> WebView système peut casser des applications : prévoir un retour arrière.

## Fonctionnement

1. Le module télécharge les APK officiels depuis une révision fixe de GrapheneOS.
2. Browser, WebView et Config sont montés dans `/product/app`.
3. L’overlay fourni déclare AOSP WebView, Google WebView stable et Vanadium.
4. Les mises à jour installées par le PackageManager dans `/data/app` restent
   prioritaires et ne sont pas supprimées au démarrage.

Les bases Browser/WebView sont en **157.0.8103.38.0**, commit officiel :
`1e9bda1bb3d56f03ad0429ccaf601be266b43431`.
Lors des essais, le catalogue proposait **157.0.8103.78.0**. Ce décalage permettait
une mise à jour via l’App Store ; sa disponibilité future n’est pas garantie.
Les APK et leurs numéros de version ne sont ni modifiés ni resignés.

**L’ancienne base n’est pas destinée à rester utilisée au quotidien.** Appliquer
les mises à jour disponibles avant de naviguer. Si elles ne sont pas accessibles
ou ne fonctionnent pas, conserver le WebView AOSP et un navigateur à jour.
Le numéro `v1` du module est indépendant de celui des applications.

## Fonctionnalités

- Téléchargement à l’installation, avec progression et quantité reçue.
- Petit ZIP : aucun APK Browser, WebView ou Config embarqué par défaut.
- Nouvel overlay fourni avec ses sources et sa procédure de reconstruction.
- WebView stock conservé et aucune sélection de provider forcée au démarrage.
- Aucun bouton Action, aucune WebUI et aucun updater maison.
- Aucune suppression des données ou des mises à jour utilisateur.
- Compteur de démarrages incomplets : mécanisme de secours non garanti,
  **pas une protection absolue contre les bootloops**.

## Prérequis

- Android 14 / API 34 minimum selon les contrôles de l’installateur.
- ARM64 ou x86_64 ; ARM64 multilib choisi si le système annonce ARM32.
- Magisk, KernelSU / dérivé ou APatch avec **montage systemless fonctionnel**.
  Sous les gestionnaires qui le demandent, un métamodule de montage est nécessaire.
- Connexion réseau et espace disponible pour des APK de plusieurs centaines de Mo.
- App Store GrapheneOS officiel installé pour les mises à jour souhaitées.
  Le module ne l’installe pas et ne lui accorde pas de privilèges supplémentaires.

La validation de version Android ne garantit pas la compatibilité du moteur sur
une ROM donnée. La révision GrapheneOS choisie appartient à une base Android 17 ;
son usage sur Android 16 est confirmé uniquement pour la configuration d’essai
avec les mises à jour rapportées, pas pour toute ROM API 34+.

## Installation

1. Télécharger le **ZIP flashable** d’une release du projet, et non le ZIP
   « Source code » généré automatiquement par GitHub.
2. Le flasher depuis le gestionnaire root, **Android démarré**. Pas en recovery.
3. Redémarrer puis ouvrir l’App Store GrapheneOS et actualiser le catalogue.
4. Mettre à jour les applications Vanadium proposées.
5. Dans les options développeur, sélectionner Vanadium comme implémentation WebView
   si souhaité, puis tester les applications qui utilisent WebView.

Si une mise à jour fonctionnelle est déjà installée, elle est conservée : il est
normal que l’App Store n’en propose pas immédiatement une autre.
Ne pas cumuler avec des modules concurrents montant les mêmes APK ou remplaçant
la liste des providers WebView.

### Migration des anciennes versions de ce projet

Flasher par-dessus `vanadium-suite`, sans désinstaller les mises à jour.
Le complément historique `vanadium-browser-system` est désactivé à la fin de la
préparation réussie. Après redémarrage et vérification, il peut être supprimé.
La v1.1 remplace l’ancien overlay par `org.vanadiumsuite.overlay.webview`.

### Fournir les APK hors ligne

Ajouter au ZIP les APK officiels **de la révision fixe indiquée plus haut** :

```text
payload/webview.apk
payload/browser.apk
payload/config.apk
```

Ils doivent correspondre à l’architecture choisie. Aucun dossier parent supplémentaire.
L’installateur contrôle la structure ZIP et l’intégrité de la copie ; **il ne
vérifie pas cryptographiquement la provenance des APK fournis manuellement**.
N’utiliser que des APK officiels obtenus d’une source de confiance.
La base WebView d’une ancienne v1.8 reconnue peut être réutilisée sans téléchargement.

## Limitation connue sur VoltageOS

Des copies système ont présenté un nom de paquet au lieu du nom de l’application,
une icône absente et des crashs. Un journal Browser montrait une exception dans
`com.android.internal.util.voltage.FontController` / `Typeface.changeFont`.
La copie système et la copie utilisateur du navigateur avaient le même SHA-256.

L’installation d’une mise à jour via le PackageManager a rétabli le fonctionnement.
**Le module conserve ce schéma ; il ne corrige pas le framework de VoltageOS.**
La cause précise du crash WebView initial n’a pas été établie par cette trace.
Le nouvel overlay a été testé avec succès sur le téléphone de l’utilisateur.

## Vérification

Dans un shell root :

```sh
cmd overlay list | grep -i vanadiumsuite
dumpsys webviewupdate
dumpsys package app.vanadium.browser | grep -E 'codePath=|pkgFlags='
```

Une application active depuis `/data/app` avec `SYSTEM UPDATED_SYSTEM_APP` est
normale : c’est une mise à jour d’une application système. Ne pas la supprimer.
L’overlay remplace la liste, sans la fusionner : Google beta/dev/canary et les
providers tiers ne sont pas déclarés par cette version. Les entrées sans
certificat sont destinées aux paquets système et à leurs mises à jour système.

## Retour arrière

1. Sélectionner le WebView AOSP dans les options développeur si possible.
2. Désactiver Vanadium Suite dans le gestionnaire root.
3. Redémarrer. Ne pas effacer les données des applications pour dépanner.

En shell root, désactivation manuelle :

```sh
touch /data/adb/modules/vanadium-suite/disable
reboot
```

La désinstallation du module ne lance pas de désinstallation des applications
utilisateur. Le comportement final dépend néanmoins des paquets restants et du ROM.

## Construire le ZIP

Sous Linux avec Bash et `zip` :

```sh
bash tools/build.sh dist/vanadium-suite-v1.zip
```

Le binaire overlay validé est inclus dans `overlay/`. Pour le reconstruire depuis
`overlay-src/`, voir [les instructions de compilation](BUILDING.md).

## Crédits et licences

- [Crédits](CREDITS.md)
- [Notices](THIRD_PARTY_NOTICES.md)
- [Licence MIT du nouvel overlay](overlay-src/LICENSE)
- [Portée des licences et points à vérifier](LICENSE.md)

Ces licences ne signifient pas que tout le dépôt est sous MIT.
Ne pas retirer les notices des composants repris.

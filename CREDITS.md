# Credits — Vanadium Suite v1.1

## Overlay de cette version

L'overlay embarque est compile depuis les fichiers XML ecrits pour cette version,
fournis dans overlay-src/. Paquet : org.vanadiumsuite.overlay.webview.
Licence de ces nouveaux fichiers : MIT (overlay-src/LICENSE).
Aucun APK overlay du depot NoneBaiano ou Lordify n'est inclus dans cette version.
Les mecanismes RRO et config_webview_packages sont ceux de la plateforme Android.
Outils de compilation : Android aapt2, zipalign et apksigner (non embarques).

## Provenance historique et references

Les versions precedentes utilisaient un overlay attribue a Lordify et recupere
chez NoneBaiano. Ce binaire est maintenant remplace, pas simplement renomme.
Leurs modules ont aussi servi de references pendant le developpement :
https://gitlab.com/Lordify/webview-changer
https://github.com/NoneBaiano/Vanadium-WebViewBrowser

Autres references consultees :
- LeanxModulostk : https://github.com/LeanxModulostk/VanadiumWebviewManager
- Magisk / topjohnwu, KernelSU et APatch : conventions d'installation et documentation.

## Applications officielles

GrapheneOS / Vanadium et contributeurs Chromium : APK officiels telecharges,
sources d'integration et documentation.
https://github.com/GrapheneOS/Vanadium
https://gitlab.com/grapheneos/platform_external_vanadium

Merci a l'utilisateur pour les tests sous VoltageOS / BakaSU.
Les auteurs cites ne sont pas presentes comme participants ou soutiens de ce module.

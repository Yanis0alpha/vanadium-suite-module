# Compilation

## Archive flashable

```sh
bash tools/build.sh dist/vanadium-suite-v1.1.zip
unzip -t dist/vanadium-suite-v1.1.zip
```

Le script n’inclut pas `.git`, les workflows, les APK des applications ou les
outils SDK. Il inclut les sources et le script de reconstruction de l’overlay.

## Overlay

Installer les outils Android SDK Build Tools (`aapt2`, `zipalign`, `apksigner.jar`),
une plateforme SDK contenant `android.jar` API 35 ou supérieure, Java et `keytool`.
Exemple avec les variables définies vers les fichiers de son SDK :

```sh
export AAPT2="$ANDROID_HOME/build-tools/35.0.0/aapt2"
export ZIPALIGN="$ANDROID_HOME/build-tools/35.0.0/zipalign"
export APKSIGNER_JAR="$ANDROID_HOME/build-tools/35.0.0/lib/apksigner.jar"
export ANDROID_JAR="$ANDROID_HOME/platforms/android-35/android.jar"
bash tools/build-overlay.sh
```

Selon l’installation Linux, les bibliothèques de `zipalign` doivent être
accessibles via `LD_LIBRARY_PATH` (répertoire `lib64` des Build Tools).
Le script crée une clé de développement temporaire, compile et signe l’overlay,
puis vérifie sa signature. Pas de clé GrapheneOS, pas de clé privée conservée.
Les builds ne sont **pas reproductibles octet pour octet** : la clé est renouvelée.
Le binaire obtenu doit être retesté ; celui embarqué est celui validé sur appareil.

## Vérifications locales

```sh
for f in customize.sh post-fs-data.sh service.sh uninstall.sh common/*.sh scripts/*.sh; do
  sh -n "$f" || exit 1
done
bash -n tools/build.sh tools/build-overlay.sh
```

La CI vérifie la syntaxe et fabrique une archive à télécharger comme artefact.
Elle ne valide ni les APK distants ni le fonctionnement sur téléphone.

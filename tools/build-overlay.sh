#!/bin/bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
: "${AAPT2:?Chemin vers aapt2 requis}"
: "${ANDROID_JAR:?Chemin vers android.jar API 35 ou plus requis}"
: "${APKSIGNER_JAR:?Chemin vers apksigner.jar requis}"
: "${ZIPALIGN:?Chemin vers zipalign requis}"
KEYTOOL=${KEYTOOL:-keytool}
JAVA=${JAVA:-java}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# Cle locale de developpement generee a chaque build : ce n'est PAS une cle GrapheneOS.
# APK systeme RRO, pas distribue comme mise a jour utilisateur autonome.
"$KEYTOOL" -genkeypair -keystore "$TMP/overlay.p12" -storetype PKCS12 \
  -storepass overlay-build -keypass overlay-build -alias overlay \
  -keyalg RSA -keysize 2048 -validity 3650 \
  -dname 'CN=Vanadium Suite Overlay Development' >/dev/null 2>&1
"$AAPT2" compile --dir overlay-src/res -o "$TMP/res.zip"
"$AAPT2" link -I "$ANDROID_JAR" --manifest overlay-src/AndroidManifest.xml \
  --auto-add-overlay -o "$TMP/unsigned.apk" "$TMP/res.zip"
"$ZIPALIGN" -f 4 "$TMP/unsigned.apk" "$TMP/aligned.apk"
mkdir -p overlay
"$JAVA" -jar "$APKSIGNER_JAR" sign --ks "$TMP/overlay.p12" \
  --ks-pass pass:overlay-build --key-pass pass:overlay-build \
  --v1-signing-enabled false --v2-signing-enabled true --v3-signing-enabled true --v4-signing-enabled false \
  --out overlay/WebViewOverlay.apk "$TMP/aligned.apk"
"$JAVA" -jar "$APKSIGNER_JAR" verify --verbose overlay/WebViewOverlay.apk
"$AAPT2" dump badging overlay/WebViewOverlay.apk | head -4
# Sources reconstructibles ; pas d'identite binaire garantie (cle et dates variables).

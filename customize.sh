#!/system/bin/sh
SKIPUNZIP=1
API=$(getprop ro.build.version.sdk)
case "$API" in ''|*[!0-9]*) abort "API Android inconnue" ;; esac
[ "$API" -ge 34 ] || abort "Android 14 minimum"
ARCH=$(getprop ro.product.cpu.abi)
ABILIST=$(getprop ro.product.cpu.abilist)
case "$ARCH" in arm64-v8a|x86_64) ;; *) abort "Architecture non supportee" ;; esac
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2 || abort "Extraction impossible"
. "$MODPATH/common/util.sh"
. "$MODPATH/common/net.sh"
ui_print "- Vanadium Suite v1.1 : bases officielles 157.0.8103.38.0"
ui_print "- Les mises a jour et donnees utilisateur sont conservees"
# Fourniture locale optionnelle : dossier payload dans le ZIP.
# Sinon reutilisation de la base .38 du module precedent, ou telechargement officiel.
BASEOLD=/data/adb/modules/vanadium-suite
mkdir -p "$MODPATH/payload"
if [ ! -s "$MODPATH/payload/webview.apk" ] && [ -s "$BASEOLD/.base-revision" ] && grep -qx '1e9bda1bb3d56f03ad0429ccaf601be266b43431' "$BASEOLD/.base-revision"; then
  cp "$BASEOLD/system/product/app/VanadiumWebView/VanadiumWebView.apk" "$MODPATH/payload/webview.apk" 2>/dev/null || true
fi
# La version 1.8 connue contient cette meme base figee.
if [ ! -s "$MODPATH/payload/webview.apk" ] && grep -q '^version=v1.8.0-test-157.0.8103.38.0$' "$BASEOLD/module.prop" 2>/dev/null; then
  cp "$BASEOLD/system/product/app/VanadiumWebView/VanadiumWebView.apk" "$MODPATH/payload/webview.apk" 2>/dev/null || true
fi
for component in webview browser config; do
  case "$component" in
    webview) URL=$(vs_url_webview); DIR=VanadiumWebView; NAME=VanadiumWebView.apk ;;
    browser) URL=$(vs_url_browser); DIR=VanadiumBrowser; NAME=VanadiumBrowser.apk ;;
    config) URL=$(vs_url_config); DIR=VanadiumConfig; NAME=VanadiumConfig.apk ;;
  esac
  SRC="$MODPATH/payload/$component.apk"
  if [ ! -s "$SRC" ]; then
    ui_print "- Telechargement officiel : $component"
    vs_download_bar "$URL" "$SRC" || abort "Telechargement impossible : $component"
  else
    ui_print "- APK local reutilise : $component"
  fi
  # Verifier la structure ZIP, sans pretendue validation de signature par grep.
  unzip -t "$SRC" >/dev/null 2>&1 || abort "Archive APK invalide : $component"
  DEST="$MODPATH/system/product/app/$DIR"
  mkdir -p "$DEST" || abort "Creation du dossier impossible"
  # Retirer les noms de fichiers herites du meme repertoire.
  rm -f "$DEST"/*.apk
  cp "$SRC" "$DEST/$NAME" || abort "Copie impossible : $component"
  A=$(sha256sum "$SRC" | awk '{print $1}')
  B=$(sha256sum "$DEST/$NAME" | awk '{print $1}')
  [ -n "$A" ] && [ "$A" = "$B" ] || abort "Verification de copie echouee"
done
# Nouvel overlay compile depuis overlay-src ; validation sur appareil requise.
OVERLAY="$MODPATH/overlay/WebViewOverlay.apk"
[ -s "$OVERLAY" ] || abort "Overlay absent"
if [ -d /system/product/overlay ]; then
  ODIR=system/product/overlay
elif [ -d /system_ext/overlay ]; then
  ODIR=system/system_ext/overlay
else
  ODIR=system/vendor/overlay
fi
# Seulement les copies de NOTRE ancien overlay.
for d in system/product/overlay system/system_ext/overlay system/vendor/overlay system/overlay; do
  rm -f "$MODPATH/$d/WebViewOverlay.apk"
done
mkdir -p "$MODPATH/$ODIR"
cp "$OVERLAY" "$MODPATH/$ODIR/WebViewOverlay.apk" || abort "Copie overlay impossible"
rm -rf "$MODPATH/system/app/VanadiumWebView" "$MODPATH/system/app/VanadiumConfig" "$MODPATH/webroot" "$MODPATH/bin" "$MODPATH/payload" "$MODPATH/overlay"
rm -f "$MODPATH/action.sh" "$MODPATH/skip_mount" "$MODPATH/webview.apk" "$MODPATH/browser.apk" "$MODPATH/config.apk"
# Droits explicites : independants des fonctions du gestionnaire root.
find "$MODPATH/system" -type d -exec chown 0:0 {} \;
find "$MODPATH/system" -type d -exec chmod 0755 {} \;
find "$MODPATH/system" -type f -exec chown 0:0 {} \;
find "$MODPATH/system" -type f -exec chmod 0644 {} \;
find "$MODPATH/system" -exec chcon u:object_r:system_file:s0 {} \; 2>/dev/null
chmod 0755 "$MODPATH/post-fs-data.sh" "$MODPATH/service.sh" "$MODPATH/uninstall.sh"
echo 0 > "$MODPATH/.bootcount"
echo 1e9bda1bb3d56f03ad0429ccaf601be266b43431 > "$MODPATH/.base-revision"
sync
# Ne neutraliser le complement qu'une fois les nouvelles copies pretes.
if [ -d /data/adb/modules/vanadium-browser-system ]; then
  touch /data/adb/modules/vanadium-browser-system/disable
  ui_print "- Ancien complement Browser desactive : remplace au prochain boot"
fi
if [ -d /data/adb/modules_update/vanadium-browser-system ]; then
  touch /data/adb/modules_update/vanadium-browser-system/disable
fi
ui_print "- Termine. Redemarre puis verifie Browser et ChatGPT."
ui_print "- Aucun pm install/uninstall, aucune selection forcee de WebView."
ui_print "- Les mises a jour App Store existantes restent prioritaires."

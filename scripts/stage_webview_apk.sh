#!/system/bin/sh
# Copie l'APK du WebView dans /product/app pour que le PackageManager le voie
# comme application systeme (isSystemApp() == true), ce qui :
#   - autorise la selection comme provider sans correspondance de signature
#   - fait ignorer le controle de versionCode minimum
# usage: stage_webview_apk.sh <apk> <destination>
MODDIR=${0%/*}
APK="$1"; DEST="$2"
[ -f "$APK" ] || exit 1
mkdir -p "$DEST" || exit 1
cp -f "$APK" "$DEST/VanadiumWebView.apk" || exit 1
chmod 0644 "$DEST/VanadiumWebView.apk"
chown 0:0 "$DEST/VanadiumWebView.apk" 2>/dev/null
chcon u:object_r:system_file:s0 "$DEST/VanadiumWebView.apk" 2>/dev/null
sync 2>/dev/null
chown 0:0 "$DEST/VanadiumWebView.apk" 2>/dev/null
chcon u:object_r:system_file:s0 "$DEST/VanadiumWebView.apk" 2>/dev/null
exit 0

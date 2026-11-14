#!/system/bin/sh
# Vanadium Suite - executed by the root manager right before the module is removed
MODDIR=${0%/*}
. "$MODDIR/common/util.sh" 2>/dev/null

# put a working WebView back before the module disappears
for p in com.google.android.webview com.android.webview; do
  has_pkg "$p" && pm enable "$p" >/dev/null 2>&1
done
CUR=$(current_webview)
if [ "$CUR" = "app.vanadium.webview" ]; then
  cmd webviewupdate set-webview-implementation com.google.android.webview >/dev/null 2>&1 \
    || cmd webviewupdate set-webview-implementation com.android.webview >/dev/null 2>&1
fi

# Conserver le navigateur, Config et les mises a jour utilisateur.
exit 0

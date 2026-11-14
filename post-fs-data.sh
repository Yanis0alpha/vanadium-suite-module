#!/system/bin/sh
# Vanadium Suite - runs in post-fs-data mode (before zygote starts)
MODDIR=${0%/*}
. "$MODDIR/common/util.sh"

# ---------------------------------------------------------------- boot counter
CNT="$MODDIR/.bootcount"
COUNT=$(cat "$CNT" 2>/dev/null || echo 0)
case "$COUNT" in ''|*[!0-9]*) COUNT=0 ;; esac
COUNT=$((COUNT + 1))
echo "$COUNT" > "$CNT"

# 3 boots without reaching sys.boot_completed => the module is the problem:
# switch back to the stock WebView and disable the module.
if [ "$COUNT" -ge 3 ]; then
  echo 0 > "$CNT"
  touch "$MODDIR/disable"
  for p in com.google.android.webview com.android.webview com.google.android.trichromelibrary; do
    pm enable "$p" >/dev/null 2>&1
  done
  cmd webviewupdate set-webview-implementation com.google.android.webview >/dev/null 2>&1
  rm -rf "$MODDIR/system/product/overlay" "$MODDIR/system/vendor/overlay" 2>/dev/null
  log "3 boots sans succes: module desactive, WebView d'origine restaure"
  exit 0
fi

# ------------------------------------------------------- SELinux on our APKs
for f in "$MODDIR"/system/*/overlay/*.apk "$MODDIR"/system/overlay/*.apk "$MODDIR"/system/app/*/*.apk "$MODDIR"/system/product/app/*/*.apk; do
  [ -f "$f" ] && chcon u:object_r:system_file:s0 "$f" 2>/dev/null
done
exit 0

#!/system/bin/sh
# Verifie que l'id de ressource cible par l'overlay existe bien dans le framework
# de la ROM courante. Un overlay pointant sur un id absent est ignore en silence.
OUT=$(cmd overlay list 2>/dev/null | grep -i "config_webview_packages")
if [ -z "$OUT" ]; then
  echo "overlay-non-vu"
elif echo "$OUT" | grep -qi "vanadium\|suite"; then
  echo "overlay-ok"
else
  echo "overlay-autres"
fi

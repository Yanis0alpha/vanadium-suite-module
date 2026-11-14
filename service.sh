#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common/util.sh"
i=0
while [ "$(getprop sys.boot_completed)" != 1 ] && [ "$i" -lt 90 ]; do
  sleep 2; i=$((i+1))
done
[ "$(getprop sys.boot_completed)" = 1 ] || exit 0
echo 0 > "$MODDIR/.bootcount"
# Ne jamais toucher aux applications ou aux mises a jour utilisateur.
# Aucun reseau ni changement de provider au demarrage.
exit 0

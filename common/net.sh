#!/system/bin/sh
# Vanadium Suite - download helpers (no curl binary is bundled: uses toybox/curl of the ROM)

vs_bar() {
  filled="$1"; pad=$((10 - filled))
  bar=""; i=0
  while [ "$i" -lt "$filled" ]; do bar="$bar#"; i=$((i+1)); done
  sp=""; i=0
  while [ "$i" -lt "$pad" ]; do sp="$sp "; i=$((i+1)); done
  ui_print "  [$bar$sp] $((filled*10))%"
}

# vs_download <url> <dest> [sha256]
vs_download() {
  url="$1"; dest="$2"; want="$3"
  rm -f "$dest"
  if command -v curl >/dev/null 2>&1; then
    curl -s -L --fail --connect-timeout 25 --retry 2 -o "$dest" "$url" || return 1
  else
    toybox wget -q -O "$dest" "$url" 2>/dev/null || wget -q -O "$dest" "$url" || return 1
  fi
  [ -s "$dest" ] || return 1
  if [ -n "$want" ]; then
    got=$(sha256sum "$dest" 2>/dev/null | awk '{print $1}')
    [ "$got" = "$want" ] || { echo "checksum mismatch ($got != $want)"; rm -f "$dest"; return 1; }
  fi
  return 0
}

# Progression visible meme si la taille totale est inconnue ou curl absent.
vs_download_bar() {
  progress_url="$1"; progress_dest="$2"; progress_hash="$3"
  total=0
  if command -v curl >/dev/null 2>&1; then
    total=$(curl -sIL --connect-timeout 10 --max-time 20 "$progress_url" 2>/dev/null | tr -d '\r' | awk 'tolower($1)=="content-length:"{l=$2} END{print l}')
  fi
  case "$total" in ''|*[!0-9]*) total=0 ;; esac
  rm -f "$progress_dest"
  ui_print "  [          ] demarrage du telechargement..."
  (vs_download "$progress_url" "$progress_dest" "$progress_hash") &
  progress_pid=$!
  progress_tick=0
  while kill -0 "$progress_pid" 2>/dev/null; do
    sleep 2
    kill -0 "$progress_pid" 2>/dev/null || break
    cur=$(stat -c %s "$progress_dest" 2>/dev/null || echo 0)
    case "$cur" in ''|*[!0-9]*) cur=0 ;; esac
    amount=$(awk -v n="$cur" 'BEGIN {printf "%.1f", n/1048576}')
    if [ "$total" -gt 0 ]; then
      percent=$((cur * 100 / total))
      # Le 100% est reserve a la fin du transfert et a sa verification.
      [ "$percent" -gt 99 ] && percent=99
      step=$((percent / 10))
      bar=""; j=0
      while [ "$j" -lt 10 ]; do
        if [ "$j" -lt "$step" ]; then bar="${bar}#"; else bar="${bar} "; fi
        j=$((j+1))
      done
      size=$(awk -v n="$total" 'BEGIN {printf "%.1f", n/1048576}')
      ui_print "  [$bar] $percent% - $amount / $size Mo"
    else
      case $((progress_tick % 4)) in
        0) indicator='>         ' ;; 1) indicator='  >       ' ;;
        2) indicator='     >    ' ;; 3) indicator='        > ' ;;
      esac
      ui_print "  [$indicator] $amount Mo recus - taille totale inconnue"
    fi
    progress_tick=$((progress_tick+1))
  done
  if ! wait "$progress_pid"; then
    ui_print "  [ ECHEC ] telechargement interrompu ou verification echouee"
    return 1
  fi
  [ -s "$progress_dest" ] || return 1
  cur=$(stat -c %s "$progress_dest" 2>/dev/null || echo 0)
  amount=$(awk -v n="$cur" 'BEGIN {printf "%.1f", n/1048576}')
  ui_print "  [##########] 100% - $amount Mo telecharges"
  return 0
}

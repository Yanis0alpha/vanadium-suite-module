#!/bin/bash
# Pack the module into a flashable zip.
# usage: tools/build.sh [output.zip]
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-dist/vanadium-suite-$(grep '^version=' module.prop | cut -d= -f2).zip}"
mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"
# module.prop first (some managers read it from the zip listing order)
zip -q -X -9 "$OUT" module.prop
zip -q -X -9 -r "$OUT" \
  META-INF \
  customize.sh post-fs-data.sh service.sh uninstall.sh \
  common overlay overlay-src scripts tools/build-overlay.sh README.md CREDITS.md THIRD_PARTY_NOTICES.md licenses module.prop
ls -l "$OUT"
echo "--- contenu ---"
unzip -l "$OUT" | tail -n +2 | head -40

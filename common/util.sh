#!/system/bin/sh
# Vanadium Suite - shared helpers

# Official prebuilt mirror (same binaries that ship on GrapheneOS).
# Revision stable figee; integration experimentale hors GrapheneOS.
VS_GL_BASE="https://gitlab.com/grapheneos/platform_external_vanadium/-/raw/1e9bda1bb3d56f03ad0429ccaf601be266b43431/prebuilt"
# Fallback: GrapheneOS app repository (needs an explicit versionCode).
VS_APPS_BASE="${VS_APPS_BASE:-https://apps.grapheneos.org}"

VS_WV_PKG=app.vanadium.webview
VS_BROWSER_PKG=app.vanadium.browser
VS_CONFIG_PKG=app.vanadium.config
VS_OVERLAY_PKG=app.vanadium.suite.webviewoverlay

ARCH=$(getprop ro.product.cpu.abi 2>/dev/null)
ABILIST=$(getprop ro.product.cpu.abilist 2>/dev/null)
API=$(getprop ro.build.version.sdk 2>/dev/null)

log() { echo "[VanadiumSuite] $*"; }

has_pkg()    { pm list packages "$1" 2>/dev/null | grep -qx "package:$1"; }
pkg_installed() { [ -n "$(pkg_version_name "$1")" ]; }
pkg_version_name() { dumpsys package "$1" 2>/dev/null | grep -m1 versionName= | sed 's/.*versionName=//'; }
pkg_version_code() { dumpsys package "$1" 2>/dev/null | grep -m1 versionCode= | sed 's/.*versionCode=//;s/ .*//'; }
pkg_apk_path()   { pm path "$1" 2>/dev/null | sed -n 's/^package://p' | head -1; }

# --- etat WebView : "cmd webviewupdate get-current-webview-package" N'EXISTE PAS
# --- sur Android 16 (seule commande shell: set-webview-implementation). On lit
# --- donc dumpsys webviewupdate, dont le format est stable.
wv_dump() { dumpsys webviewupdate 2>/dev/null; }

current_webview() {
  out=$(wv_dump)
  pkg=$(echo "$out" | sed -n 's/.*Current WebView package (name, version): (\([^,]*\),.*/\1/p' | head -1)
  echo "$pkg"
}
wv_current_is_null() { wv_dump | grep -q "Current WebView package is null"; }
wv_min_version_code() { wv_dump | sed -n 's/.*Minimum WebView version code: \([0-9]*\).*/\1/p' | head -1; }
wv_valid_list()   { wv_dump | sed -n 's/^ *Valid package \([^ ]*\) .*/\1/p'; }
wv_invalid_list() { wv_dump | sed -n 's/^ *Invalid package \([^ ]*\) .*reason: \(.*\)/\1 : \2/p'; }
wv_not_installed() { wv_dump | sed -n 's/^ *\([^ ]*\) is NOT installed.*/\1/p'; }
wv_valid_for_all_users() { wv_dump | sed -n 's/^ *Valid package \([^ ]*\) .* is \(NOT \)\?installed\/enabled.*/\1/p'; }
wv_any_installed() { wv_dump | sed -n 's/.*Any WebView package installed: \(.*\)/\1/p' | head -1; }
pkg_apk_size()   { p=$(pkg_apk_path "$1"); [ -n "$p" ] && stat -c %s "$p" 2>/dev/null; }

# URL of a prebuilt for the current device
# vs_url_webview|vs_url_browser|vs_url_config
vs_url_webview() {
  if [ -n "$VS_URL_WEBVIEW" ]; then echo "$VS_URL_WEBVIEW"; return; fi
  case "$ARCH" in
    arm64*) case "$ABILIST" in
              *armeabi*|*armeabi-v7a*) echo "$VS_GL_BASE/arm64-multilib/VanadiumWebView.apk" ;;
              *)                       echo "$VS_GL_BASE/arm64/VanadiumWebView.apk" ;;
            esac ;;
    x86_64*) echo "$VS_GL_BASE/x86_64/VanadiumWebView.apk" ;;
    *) echo "" ;;
  esac
}
vs_url_browser() {
  if [ -n "$VS_URL_BROWSER" ]; then echo "$VS_URL_BROWSER"; return; fi
  case "$ARCH" in
    arm64*)  echo "$VS_GL_BASE/arm64/VanadiumBrowser.apk" ;;
    x86_64*) echo "$VS_GL_BASE/x86_64/VanadiumBrowser.apk" ;;
    *) echo "" ;;
  esac
}
vs_url_config() {
  if [ -n "$VS_URL_CONFIG" ]; then echo "$VS_URL_CONFIG"; return; fi
  echo "$VS_GL_BASE/VanadiumConfig.apk"
}

# Where the WebView APK has to live in the module so the ROM picks it up
vs_webview_dir() {
  if grep -qi "lineage" /system/build.prop /system/etc/*.prop /vendor/build.prop 2>/dev/null; then
    echo "system/product/app/VanadiumWebView"
  else
    echo "system/app/VanadiumWebView"
  fi
}

# Local state file (module dir may be read-only under some managers)
vs_state_dir() { echo "${MODDIR:-/data/adb/modules/vanadium-suite}"; }

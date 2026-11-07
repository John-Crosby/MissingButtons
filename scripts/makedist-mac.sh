#!/bin/bash
# makedist-mac.sh -- build all nine MissingButtons plug-ins, sign, package and
# notarize ONE macOS installer.
#
#   scripts/makedist-mac.sh                 AU + VST3 + CLAP + AAX
#   scripts/makedist-mac.sh --no-aax        without AAX
#   scripts/makedist-mac.sh --no-notarize   stop before notarization (local test)
#
# Output: installer/build-mac/MissingButtons-<version>-mac.pkg, full log in
# installer/build-mac/makedist.log.
#
# Needs: CMake (cmake.org or "brew install cmake"), Xcode 26.x for the macOS 10.13
# minimum. Xcode 27 refuses deployment targets below macOS 12; with both
# installed, point this script at 26:
#   DEVELOPER_DIR=/Applications/Xcode-26.app/Contents/Developer scripts/makedist-mac.sh
#
# One-time setup shared with Airbender / BigBro (already done there):
#   - notarization: the "AirbenderNotary" profile (Apple ID / team credentials).
#     (New Mac: xcrun notarytool store-credentials "AirbenderNotary"
#      --apple-id info@john-crosby.com --team-id NN882ZSUB6)
#   - PACE password: security add-generic-password -s "PACE wraptool"
#                      -a krizaj.janez@gmail.com -w
#     (read from the Keychain here, never written in this file or the log)
#   - each plug-in has its own PACE wrap config GUID: pace_wcguid() below.
#
# Steps: CMake Release build (universal, macOS 10.13+) -> copy the 36 bundles
# into a staging folder and check them -> sign the copies (Developer ID,
# hardened runtime, secure timestamp; AAX via PACE wraptool) -> one component
# package per plug-in and format (not relocatable) -> product archive with
# welcome, EULA and a checkbox per format and per plug-in, signed with
# Developer ID Installer -> notarize -> staple -> verify with Gatekeeper.
set -euo pipefail
cd "$(dirname "$0")/.."

# ---- configuration -------------------------------------------------------------
APP_ID="Developer ID Application: Janez Krizaj (NN882ZSUB6)"
INSTALLER_ID="Developer ID Installer: Janez Krizaj (NN882ZSUB6)"
NOTARY_PROFILE="${NOTARY_PROFILE:-AirbenderNotary}"
PACE_ACCOUNT="krizaj.janez@gmail.com"
PACE_KEYCHAIN_SERVICE="PACE wraptool"
WRAPTOOL="${WRAPTOOL:-$(ls -d /Applications/PACEAntiPiracy/Eden/Fusion/Versions/*/bin/wraptool 2>/dev/null | sort -V | tail -1 || true)}"
MIN_MACOS="10.13"
ID_PREFIX="com.JohnCrosby.MissingButtons"
NAME="MissingButtons"
PLUGINS=(Flip FlipRight Left Right Mono MidSide Side Swap SideChainer)

# PACE Central wrap configuration GUID of each plug-in (the --wcguid one, not the product GUID) (bash 3.2: no associative arrays).
pace_wcguid() {
  case "$1" in
    Flip)        echo "70DA6F30-3598-11F0-9A88-005056928F3B" ;;
    FlipRight)   echo "BF0CE5C0-3598-11F0-9A88-005056928F3B" ;;
    Left)        echo "1CAC7CE0-3599-11F0-9A88-005056928F3B" ;;
    MidSide)     echo "6751AE00-3599-11F0-BC08-005056920FF7" ;;
    Mono)        echo "B3E5DDE0-3599-11F0-BC08-005056920FF7" ;;
    Right)       echo "FDC48AB0-3599-11F0-AB63-00505692AD3E" ;;
    Side)        echo "49967C00-359A-11F0-88CE-00505692C25A" ;;
    SideChainer) echo "93B14770-359A-11F0-9A88-005056928F3B" ;;
    Swap)        echo "DB668490-359A-11F0-88CE-00505692C25A" ;;
    *) echo "no PACE GUID for $1" >&2; return 1 ;;
  esac
}

# One line per plug-in for the installer (welcome page and checkbox descriptions).
plugin_desc() {
  case "$1" in
    Flip)        echo "polarity (phase) inverter, every channel" ;;
    FlipRight)   echo "inverts the polarity of the right channel; mono in -> L = x, R = -x" ;;
    Left)        echo "left channel on both outputs" ;;
    Right)       echo "right channel on both outputs" ;;
    Mono)        echo "stereo to mono, (L + R) / 2 on both outputs" ;;
    MidSide)     echo "mid/side encoder and decoder (* 0.707)" ;;
    Side)        echo "side signal only, (L - R) / 2" ;;
    Swap)        echo "swaps left and right" ;;
    SideChainer) echo "outputs the sidechain input in place of the main input" ;;
  esac
}

WITH_AAX=1; NOTARIZE=1
for arg in "$@"; do
  case "$arg" in
    --no-aax)      WITH_AAX=0 ;;
    --no-notarize) NOTARIZE=0 ;;
    *) echo "unknown option: $arg"; exit 2 ;;
  esac
done

VERSION=$(sed -n 's/^#define PLUG_VERSION_STR "\(.*\)"/\1/p' common/config-common.h)
[ -n "$VERSION" ] || { echo "PLUG_VERSION_STR not found in common/config-common.h"; exit 1; }

OUT="installer/build-mac"
BUILD="build-dist-mac"
STAGE="$OUT/stage"; PKGS="$OUT/packages"; RES="$OUT/resources"
FINAL="$OUT/$NAME-$VERSION-mac.pkg"
rm -rf "$OUT"; mkdir -p "$STAGE" "$PKGS" "$RES"
LOG="$OUT/makedist.log"
exec > >(tee "$LOG") 2>&1
echo "=== $NAME $VERSION mac distribution  $(date) ==="
echo "    AAX: $([ $WITH_AAX = 1 ] && echo yes || echo no)   notarize: $([ $NOTARIZE = 1 ] && echo yes || echo no)"

# format key | CMake format | bundle extension | where the installer puts it | choice title
FORMATS=(
  "au|AU|component|/Library/Audio/Plug-Ins/Components|Audio Unit (AU)"
  "vst3|VST3|vst3|/Library/Audio/Plug-Ins/VST3|VST3"
  "clap|CLAP|clap|/Library/Audio/Plug-Ins/CLAP|CLAP"
)
[ $WITH_AAX = 1 ] && FORMATS+=(
  "aax|AAX|aaxplugin|/Library/Application Support/Avid/Audio/Plug-Ins|AAX (Pro Tools)"
)
CMAKE_FORMATS=""
for f in "${FORMATS[@]}"; do IFS='|' read -r key cfmt ext dest title <<< "$f"; CMAKE_FORMATS="$CMAKE_FORMATS;$cfmt"; done
CMAKE_FORMATS="${CMAKE_FORMATS#;}"

# ---- 0. tools ------------------------------------------------------------------
# CMake.app and Homebrew are often not on the PATH of a script: look there too.
CMAKE="${CMAKE:-}"
if [ -z "$CMAKE" ]; then
  for c in "$(command -v cmake || true)" /Applications/CMake.app/Contents/bin/cmake \
           "$HOME/Applications/CMake.app/Contents/bin/cmake" /opt/homebrew/bin/cmake /usr/local/bin/cmake; do
    [ -n "$c" ] && [ -x "$c" ] && { CMAKE="$c"; break; }
  done
fi
[ -n "$CMAKE" ] || { echo "cmake not found -- install CMake.app from cmake.org (or: brew install cmake), or set CMAKE=/path/to/cmake"; exit 1; }
XCODE_VER=$(xcodebuild -version | sed -n 's/^Xcode \([0-9.]*\).*/\1/p')
echo "    Xcode $XCODE_VER ($(xcode-select -p 2>/dev/null || true))   $("$CMAKE" --version | head -1)"
if [ "${XCODE_VER%%.*}" -ge 27 ]; then
  echo "Xcode $XCODE_VER cannot build for macOS $MIN_MACOS (its minimum is 12)."
  echo "Install Xcode 26.x next to it (developer.apple.com/download/all) and run:"
  echo "  DEVELOPER_DIR=/Applications/Xcode-26.app/Contents/Developer $0 $*"
  exit 1
fi
if [ $WITH_AAX = 1 ]; then
  [ -x "$WRAPTOOL" ] || { echo "wraptool not found -- install PACE Eden tools, set WRAPTOOL=..., or use --no-aax"; exit 1; }
  security find-generic-password -s "$PACE_KEYCHAIN_SERVICE" -a "$PACE_ACCOUNT" >/dev/null 2>&1 \
    || { echo "PACE password not in the Keychain -- see the setup notes at the top"; exit 1; }
  [ -f ../Dependencies/IPlug/AAX_SDK/CMakeLists.txt ] \
    || { echo "AAX SDK missing in iPlug2/Dependencies/IPlug/AAX_SDK -- add it or use --no-aax"; exit 1; }
fi

# ---- 1. build ------------------------------------------------------------------
echo; echo "=== build (Release, universal, macOS $MIN_MACOS+) ==="
GEN="Unix Makefiles"; command -v ninja >/dev/null && GEN="Ninja"   # (ninja only if on the PATH)
rm -rf "$BUILD"
blog="$OUT/build.log"
if ! { "$CMAKE" -S . -B "$BUILD" -G "$GEN" -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_OSX_DEPLOYMENT_TARGET="$MIN_MACOS" -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
         -DIPLUG_DEPLOY_PLUGINS=OFF -DMB_FORMATS="$CMAKE_FORMATS" \
       && "$CMAKE" --build "$BUILD" --parallel "$(sysctl -n hw.ncpu)"; } > "$blog" 2>&1; then
  { grep -E "error:|Error|CMake Error" "$blog" | head -30; } || true
  echo "BUILD FAILED -- full log in $blog"; exit 1
fi
echo "BUILD SUCCEEDED"

# ---- 2. stage + check ----------------------------------------------------------
echo; echo "=== stage + check ==="
for f in "${FORMATS[@]}"; do
  IFS='|' read -r key cfmt ext dest title <<< "$f"
  for p in "${PLUGINS[@]}"; do
    bundle="$p.$ext"
    src="$BUILD/out/$bundle"
    [ -d "$src" ] || { echo "build output missing: $src"; exit 1; }
    mkdir -p "$STAGE/$key/$p"
    ditto "$src" "$STAGE/$key/$p/$bundle"
    # Drop extended attributes (browser quarantine etc.) so they don't travel into the .pkg.
    xattr -cr "$STAGE/$key/$p/$bundle" 2>/dev/null || true
    b="$STAGE/$key/$p/$bundle"
    # The installer copies the modes as they are and installs as root: everything
    # must be readable by everyone, or hosts and the AU registrar (running as the
    # user) cannot read Info.plist and skip the plug-in.
    chmod -R u+rwX,go+rX,go-w "$STAGE/$key/$p"
    unreadable=$(find "$b" ! -perm -o+r -print -quit)
    [ -z "$unreadable" ] || { echo "$key/$p: not readable by everyone: $unreadable"; exit 1; }
    exe="$b/Contents/MacOS/$p"
    archs=$(lipo -archs "$exe")
    [[ "$archs" == *x86_64* && "$archs" == *arm64* ]] || { echo "$key/$p is not universal ($archs)"; exit 1; }
    # The Intel slice carries the real minimum (arm64 starts at macOS 11 anyway).
    minos=$(otool -arch x86_64 -l "$exe" | awk '/LC_VERSION_MIN_MACOSX|LC_BUILD_VERSION/{f=1} f&&/ (version|minos) /{print $2; exit}')
    [ "$minos" = "$MIN_MACOS" ] || { echo "$key/$p: x86_64 minimum macOS is '$minos', expected $MIN_MACOS"; exit 1; }
    ver=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$b/Contents/Info.plist")
    [ "$ver" = "$VERSION" ] || { echo "$key/$p: Info.plist version $ver, expected $VERSION"; exit 1; }
    bid=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$b/Contents/Info.plist")
    echo "$key/$p: $archs, macOS $minos+, $bid $ver, $(du -sh "$b" | cut -f1)"
  done
done

# ---- 3. sign -------------------------------------------------------------------
echo; echo "=== sign ==="
PACE_PASSWORD=""
[ $WITH_AAX = 1 ] && PACE_PASSWORD=$(security find-generic-password -s "$PACE_KEYCHAIN_SERVICE" -a "$PACE_ACCOUNT" -w)
for f in "${FORMATS[@]}"; do
  IFS='|' read -r key cfmt ext dest title <<< "$f"
  for p in "${PLUGINS[@]}"; do
    target="$STAGE/$key/$p/$p.$ext"
    if [ "$key" = aax ]; then
      "$WRAPTOOL" sign --verbose --account "$PACE_ACCOUNT" --password "$PACE_PASSWORD" \
        --wcguid "$(pace_wcguid "$p")" --signid "$APP_ID" \
        --extrasigningoptions "--options runtime --timestamp" --dsig1-compat off \
        --in "$target" --out "$target"
    else
      codesign --force --options runtime --timestamp --sign "$APP_ID" "$target"
    fi
    # wraptool recreates the bundle: normalize modes again after signing (they are
    # not part of the seal). A file the host (running as the user) cannot read
    # fails the PACE/codesign check in Pro Tools (AAE -7054); PT Developer skips it.
    chmod -R u+rwX,go+rX,go-w "$target"
    bad=$(find "$target" ! -type l \( ! -perm -o+r -o -perm -o+w \) -print)
    [ -z "$bad" ] || { echo "$key/$p: bad permissions:"; echo "$bad"; exit 1; }
    codesign --verify --strict "$target"
    flags=$(codesign -dv --verbose=4 "$target" 2>&1)
    echo "$flags" | grep -q "flags=.*runtime" || { echo "$key/$p: signed WITHOUT hardened runtime -- notarization would fail"; exit 1; }
    echo "$flags" | grep -q "^Timestamp=" || { echo "$key/$p: signed WITHOUT secure timestamp -- notarization would fail"; exit 1; }
    echo "$key/$p: signed, hardened runtime + timestamp OK"
  done
done
PACE_PASSWORD=""

# ---- 4. component packages: one per plug-in and format -------------------------
echo; echo "=== packages ==="
for f in "${FORMATS[@]}"; do
  IFS='|' read -r key cfmt ext dest title <<< "$f"
  for p in "${PLUGINS[@]}"; do
    root="$STAGE/$key/$p"
    plist="$OUT/components-$key-$p.plist"
    pkgbuild --analyze --root "$root" "$plist" >/dev/null
    # Never relocate: an existing copy elsewhere (a dev build) must not divert the install.
    i=0
    while /usr/libexec/PlistBuddy -c "Print :$i" "$plist" >/dev/null 2>&1; do
      /usr/libexec/PlistBuddy -c "Delete :$i:BundleIsRelocatable" "$plist" >/dev/null 2>&1 || true
      /usr/libexec/PlistBuddy -c "Add :$i:BundleIsRelocatable bool false" "$plist"
      # Always replace an existing copy, even one with the same version (e.g. a dev build).
      /usr/libexec/PlistBuddy -c "Delete :$i:BundleIsVersionChecked" "$plist" >/dev/null 2>&1 || true
      /usr/libexec/PlistBuddy -c "Add :$i:BundleIsVersionChecked bool false" "$plist"
      i=$((i + 1))
    done
    pkgbuild --root "$root" --component-plist "$plist" --install-location "$dest" \
      --identifier "$ID_PREFIX.$key.$p" --version "$VERSION" "$PKGS/$key-$p.pkg" >/dev/null
  done
  echo "$key: ${#PLUGINS[@]} packages"
done

# ---- 5. product archive: welcome, EULA, checkboxes per format and plug-in ------
cp installer/EULA.txt "$RES/EULA.txt"
{
  echo "MissingButtons $VERSION by John Crosby"
  echo
  echo "Nine free utility plug-ins: the buttons your mixer is missing."
  echo "No user interface, no parameters, no latency -- insert one and it does its job."
  echo
  for p in "${PLUGINS[@]}"; do printf '  %-12s %s\n' "$p" "$(plugin_desc "$p")"; done
  echo
  echo "This installs them for every user of this Mac, in AU, VST3, CLAP$([ $WITH_AAX = 1 ] && echo " and AAX")."
  echo "On the \"Installation Type\" page you can untick any format or plug-in you do not need."
  echo
  echo "Requires macOS $MIN_MACOS or newer; runs natively on Intel and Apple Silicon."
} > "$RES/welcome.txt"

{
  echo '<?xml version="1.0" encoding="utf-8"?>'
  echo '<installer-gui-script minSpecVersion="2">'
  echo "  <title>$NAME $VERSION</title>"
  echo '  <welcome file="welcome.txt" mime-type="text/plain"/>'
  echo '  <license file="EULA.txt" mime-type="text/plain"/>'
  # customize="always": Installation Type opens on the checkboxes.
  # rootVolumeOnly: startup disk only, so Installer skips Destination Select.
  echo '  <options customize="always" rootVolumeOnly="true" require-scripts="false" hostArchitectures="x86_64,arm64"/>'
  echo "  <volume-check><allowed-os-versions><os-version min=\"$MIN_MACOS\"/></allowed-os-versions></volume-check>"
  echo '  <choices-outline>'
  for f in "${FORMATS[@]}"; do
    IFS='|' read -r key cfmt ext dest title <<< "$f"
    echo "    <line choice=\"$key\">"
    for p in "${PLUGINS[@]}"; do echo "      <line choice=\"$key.$p\"/>"; done
    echo '    </line>'
  done
  echo '  </choices-outline>'
  for f in "${FORMATS[@]}"; do
    IFS='|' read -r key cfmt ext dest title <<< "$f"
    echo "  <choice id=\"$key\" title=\"$title\" description=\"Installs the plug-ins into $dest\"/>"
    for p in "${PLUGINS[@]}"; do
      echo "  <choice id=\"$key.$p\" title=\"$p\" description=\"$p: $(plugin_desc "$p" | sed 's/</\&lt;/g; s/>/\&gt;/g')\">"
      echo "    <pkg-ref id=\"$ID_PREFIX.$key.$p\"/>"
      echo '  </choice>'
      echo "  <pkg-ref id=\"$ID_PREFIX.$key.$p\" version=\"$VERSION\" onConclusion=\"none\">$key-$p.pkg</pkg-ref>"
    done
  done
  echo '</installer-gui-script>'
} > "$OUT/distribution.xml"
xmllint --noout "$OUT/distribution.xml"

productbuild --distribution "$OUT/distribution.xml" --resources "$RES" --package-path "$PKGS" \
  --sign "$INSTALLER_ID" --timestamp "$FINAL"
pkgutil --check-signature "$FINAL"

# ---- 6. notarize + staple ------------------------------------------------------
if [ $NOTARIZE = 1 ]; then
  echo; echo "=== notarize (takes a few minutes) ==="
  xcrun notarytool submit "$FINAL" --keychain-profile "$NOTARY_PROFILE" --wait | tee "$OUT/notary.txt"
  if ! grep -q "status: Accepted" "$OUT/notary.txt"; then
    id=$(sed -n 's/^ *id: //p' "$OUT/notary.txt" | head -1)
    echo "NOT accepted. Details:"; xcrun notarytool log "$id" --keychain-profile "$NOTARY_PROFILE" || true
    exit 1
  fi
  xcrun stapler staple "$FINAL"
  spctl --assess --type install --verbose=2 "$FINAL"
fi

rm -rf "$STAGE"
echo; echo "=== done: $FINAL ($(du -h "$FINAL" | cut -f1)) ==="

#!/bin/bash
# Membangun APK Android untuk project ini.
#
#   bash tools/build_android.sh              # debug build
#   bash tools/build_android.sh release      # release build (butuh keystore rilis)
#
# Keystore rilis dibaca dari environment variable supaya password tidak
# pernah ikut tersimpan di repository:
#   GODOT_ANDROID_KEYSTORE_RELEASE_PATH
#   GODOT_ANDROID_KEYSTORE_RELEASE_USER
#   GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-/Applications/Godot_mono.app/Contents/MacOS/Godot}"
MODE="${1:-debug}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

if [ "$MODE" = "release" ]; then
    EXPORT_METHOD="--export-release"
    OUTPUT="build/android/game1-kelas-b-eva-release.apk"
    if [ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]; then
        echo "Keystore rilis belum diset." >&2
        echo "Contoh:" >&2
        echo "  export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=\"\$HOME/Library/Application Support/Godot/keystores/release.keystore\"" >&2
        echo "  export GODOT_ANDROID_KEYSTORE_RELEASE_USER=\"eva-release\"" >&2
        echo "  export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=\"...\"" >&2
        exit 1
    fi
else
    EXPORT_METHOD="--export-debug"
    OUTPUT="build/android/game1-kelas-b-eva.apk"
fi

echo "Mode   : $MODE"
echo "Output : $OUTPUT"
mkdir -p build/android
rm -f "$OUTPUT"

# android/build/ di-ignore Git dan bisa dibuat ulang dari android_source.zip,
# jadi pengaturan hemat RAM diterapkan ulang setiap kali build.
GRADLE_PROPERTIES="android/build/gradle.properties"
if [ -f "$GRADLE_PROPERTIES" ]; then
    sed -i '' 's/^org\.gradle\.jvmargs=-Xmx[0-9]*m/org.gradle.jvmargs=-Xmx1536m/' "$GRADLE_PROPERTIES"
    if ! grep -q 'org.gradle.daemon.idletimeout' "$GRADLE_PROPERTIES"; then
        {
            echo ""
            echo "# Hemat RAM: hentikan Gradle daemon setelah 2 menit menganggur."
            echo "org.gradle.daemon.idletimeout=120000"
        } >> "$GRADLE_PROPERTIES"
    fi
    echo "Gradle heap: $(grep -oE 'org\.gradle\.jvmargs=.*' "$GRADLE_PROPERTIES")"
fi

"$GODOT_BIN" --headless --path . "$EXPORT_METHOD" "Android" "$OUTPUT"

if [ -f "$OUTPUT" ]; then
    echo
    echo "=== hasil ==="
    ls -lh "$OUTPUT"
    echo
    echo "Pasang ke HP: bash tools/install_to_device.sh $OUTPUT"
else
    echo "Export gagal: $OUTPUT tidak terbentuk" >&2
    exit 1
fi

#!/bin/bash
# Memasang APK hasil export ke HP Android yang terhubung lewat USB.
# Jalankan: bash tools/install_to_device.sh [path-apk]
set -euo pipefail

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="$ANDROID_HOME/platform-tools/adb"
APK="${1:-build/android/game1-kelas-b-eva.apk}"
PACKAGE_NAME="com.evanurhalisa.game1"

if [ ! -x "$ADB" ]; then
    echo "adb tidak ditemukan di $ADB" >&2
    exit 1
fi
if [ ! -f "$APK" ]; then
    echo "APK tidak ditemukan: $APK" >&2
    echo "Jalankan export dulu:" >&2
    echo "  /Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . --export-debug \"Android\" \"$APK\"" >&2
    exit 1
fi

echo "Perangkat yang terdeteksi:"
"$ADB" devices -l

count=$("$ADB" devices | grep -c "device$" || true)
if [ "$count" -eq 0 ]; then
    echo
    echo "Tidak ada HP yang terdeteksi. Aktifkan 'USB debugging' di HP lalu setujui prompt di layar HP." >&2
    exit 1
fi

echo
echo "Memasang $APK ..."
"$ADB" install -r "$APK"

echo "Menjalankan aplikasi ..."
"$ADB" shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 >/dev/null
echo "Selesai. Game sudah terbuka di HP."

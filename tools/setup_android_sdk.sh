#!/bin/bash
# Menyiapkan Android SDK supaya Godot bisa melakukan export.
# Jalankan: bash tools/setup_android_sdk.sh
set -euo pipefail

export JAVA_HOME="${JAVA_HOME:-$HOME/eva-toolchain/jdk17/Contents/Home}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
BUILD_TOOLS_VERSION="${BUILD_TOOLS_VERSION:-34.0.0}"
PLATFORM_VERSION="${PLATFORM_VERSION:-android-34}"

if [ ! -x "$JAVA_HOME/bin/java" ]; then
    echo "JDK belum ada di $JAVA_HOME" >&2
    exit 1
fi
if [ ! -x "$SDKMANAGER" ]; then
    echo "sdkmanager belum ada di $SDKMANAGER" >&2
    exit 1
fi

echo "Java: $("$JAVA_HOME/bin/java" -version 2>&1 | head -1)"

# Terima lisensi SDK tanpa interaksi.
yes | "$SDKMANAGER" --sdk_root="$ANDROID_HOME" --licenses >/dev/null 2>&1 || true

echo "Mengunduh platform-tools, build-tools;$BUILD_TOOLS_VERSION, platforms;$PLATFORM_VERSION"
"$SDKMANAGER" --sdk_root="$ANDROID_HOME" --install \
    "platform-tools" \
    "build-tools;$BUILD_TOOLS_VERSION" \
    "platforms;$PLATFORM_VERSION"

test -x "$ANDROID_HOME/platform-tools/adb"
test -x "$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/apksigner"
echo "ANDROID_SDK_DONE"

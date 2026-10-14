#!/bin/bash
# Memberhentikan daemon Gradle/Java yang masih menahan RAM setelah build,
# lalu menampilkan sisa proses Java dan pemakaian memori.
# Jalankan: bash tools/free_android_ram.sh
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export JAVA_HOME="${JAVA_HOME:-$HOME/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home}"

echo "=== sebelum ==="
ps -Ao rss=,command= | grep -iE 'GradleDaemon|KotlinCompileDaemon' | grep -v grep \
    | awk '{printf "  %.0f MB  %s\n", $1/1024, $2}' || true
before=$(ps -Ao rss=,command= | grep -iE 'GradleDaemon|KotlinCompileDaemon' | grep -v grep | awk '{s+=$1} END{print s+0}')

# Hentikan daemon Gradle lewat wrapper kalau ada.
if [ -x "$PROJECT_DIR/android/build/gradlew" ]; then
    (cd "$PROJECT_DIR/android/build" && ./gradlew --stop >/dev/null 2>&1) || true
fi

# Sisa daemon yang tetap hidup (mis. dari project lain) dihentikan manual.
pkill -f 'GradleDaemon' 2>/dev/null || true
pkill -f 'KotlinCompileDaemon' 2>/dev/null || true
sleep 2

after=$(ps -Ao rss=,command= | grep -iE 'GradleDaemon|KotlinCompileDaemon' | grep -v grep | awk '{s+=$1} END{print s+0}')
freed=$(( (before - after) / 1024 ))

echo
echo "=== sesudah ==="
ps -Ao rss=,command= | grep -iE 'GradleDaemon|KotlinCompileDaemon' | grep -v grep \
    | awk '{printf "  %.0f MB  %s\n", $1/1024, $2}' || true
[ -z "$(ps -Ao command= | grep -iE 'GradleDaemon|KotlinCompileDaemon' | grep -v grep)" ] && echo "  (tidak ada daemon Java yang berjalan)"

echo
echo "RAM dibebaskan: sekitar ${freed} MB"
echo
echo "Tips: cache Gradle di ~/.gradle saat ini $(du -sh "$HOME/.gradle" 2>/dev/null | cut -f1 || echo "n/a")"
echo "Hapus cache lama (perlu unduh ulang saat build berikutnya):"
echo "  rm -rf ~/.gradle/caches ~/.gradle/daemon"

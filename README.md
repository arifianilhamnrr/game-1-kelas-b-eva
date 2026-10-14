# Game 1 Kelas B Eva — Platformer PBO

Game platformer Godot 4 yang menggunakan gameplay dan aset dari Apipi Adventure,
namun logic-nya disusun ulang dengan prinsip Pemrograman Berorientasi Objek.

## Konsep PBO

- **Abstraksi:** `Actor`, `Collectible`, dan `HazardBase` menyediakan perilaku umum.
- **Enkapsulasi:** health milik `Actor`; skor, buah, dan nyawa dikelola `GameState`.
- **Inheritance:** `Player` dan `PatrolEnemy` mewarisi `Actor`; perangkap mewarisi `HazardBase`.
- **Polymorphism:** setiap hazard mengimplementasikan `affect(actor)` dan setiap collectible `collect(body)`.
- **Observer:** UI mengamati signal dari `GameState`, sehingga HUD tidak menyimpan state permainan.

## Class utama

```text
CharacterBody2D
└── Actor
    ├── Player
    └── PatrolEnemy

Area2D
├── Collectible
│   └── Fruit
└── HazardBase
    ├── InstantHazard
    ├── Saw
    ├── FireTrap
    └── RockHead
```

## Kontrol

- Bergerak: `A/D` atau panah kiri/kanan
- Lompat/double jump: `Space`, `W`, atau panah atas
- Respawn/damage manual: `R`
- Mobile: tombol layar kiri, kanan, lompat, dan restart

Jalankan `project.godot` dengan Godot 4.7, lalu tekan **F6/F5**.

## Visual dan alur permainan

- Home screen menjadi pintu masuk ke level.
- Background dibuat dari layer matahari, awan, dan pegunungan transparan.
- Setiap layer bergerak dengan rasio berbeda untuk menghasilkan efek parallax.
- Matahari memiliki dua lapisan glow dan seluruh level diberi nuansa senja hangat.
- Finish flag menampilkan layar end game dengan skor, total buah, tombol main lagi,
  dan tombol kembali ke Home.

## Export Android

Project ini memakai build Gradle, jadi toolchain berikut wajib tersedia:

- OpenJDK 17
- Android SDK (`platform-tools`, `build-tools`, `platforms`)
- Android build template Godot (folder `android/` di project)

### Sekali setup

Mesin Intel (x86_64) tidak lagi mendapat bottle Homebrew, jadi toolchain
diambil langsung dari sumber resmi tanpa sudo, dan dipasang di lokasi standar
macOS supaya bisa dipakai project lain:

```bash
# JDK 17 (Temurin) -> ~/Library/Java/JavaVirtualMachines/temurin-17.jdk
mkdir -p ~/Library/Java/JavaVirtualMachines && cd /tmp
curl -L -o jdk17.tar.gz "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1%2B1/OpenJDK17U-jdk_x64_mac_hotspot_17.0.20.1_1.tar.gz"
mkdir -p temurin-17.jdk && tar -xzf jdk17.tar.gz -C temurin-17.jdk --strip-components=1
mv temurin-17.jdk ~/Library/Java/JavaVirtualMachines/

# Android command line tools -> ~/Library/Android/sdk
curl -L -o cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"
mkdir -p ~/Library/Android/sdk/cmdline-tools
unzip -q cmdline-tools.zip -d ~/Library/Android/sdk/cmdline-tools
mv ~/Library/Android/sdk/cmdline-tools/cmdline-tools ~/Library/Android/sdk/cmdline-tools/latest

# Template Android Godot .NET + paket SDK
python3 tools/fetch_android_templates.py
bash tools/setup_android_sdk.sh
```

Verifikasi JDK terdeteksi sistem:

```bash
/usr/libexec/java_home -V      # harus menampilkan 17.0.20.1 temurin-17.jdk
```

Lalu set di **Editor Settings → Export → Android**:

```text
Java SDK Path    : ~/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
Android SDK Path : ~/Library/Android/sdk
Debug Keystore   : (dibiarkan default, Godot membuat debug.keystore otomatis)
```

### Install build template dan export

Cara praktis:

```bash
bash tools/build_android.sh            # debug
bash tools/build_android.sh release    # release (butuh keystore rilis)
```

Keystore rilis dibaca dari environment variable supaya password tidak
tersimpan di repository:

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$HOME/Library/Application Support/Godot/keystores/release.keystore"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="eva-release"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="evarelease"
```

Atau manual:

```bash
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . \
  --install-android-build-template
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . \
  --export-debug "Android" build/android/game1-kelas-b-eva.apk
```

Preset Android sudah dikonfigurasi:

- Package: `com.evanurhalisa.game1`
- Nama aplikasi: `Game 1 Kelas B`
- Versi: `1.0`
- Arsitektur: `arm64-v8a` dan `armeabi-v7a`
- Native library dikompres agar APK lebih kecil
- Ikon launcher dan splash dibuat oleh `tools/generate_android_icons.gd`

Hasil export: `build/android/game1-kelas-b-eva.apk` (sekitar 65 MB).

### Pasang ke HP

Hubungkan HP dengan **USB debugging** aktif, lalu:

```bash
bash tools/install_to_device.sh
```

Atau pasang manual:

```bash
~/Library/Android/sdk/platform-tools/adb install -r build/android/game1-kelas-b-eva.apk
```

Catatan: tutup Godot Editor saat melakukan export dari terminal, karena editor
bisa menimpa `export_presets.cfg` dan mengaktifkan kembali arsitektur `x86`.

### Hemat RAM

Gradle/JVM secara bawaan meminta heap besar (`-Xmx4536m`) dan daemon-nya tetap
hidup berjam-jam setelah build. `tools/build_android.sh` otomatis menerapkan:

```text
org.gradle.jvmargs=-Xmx1536m
org.gradle.daemon.idletimeout=120000
```

Untuk membebaskan RAM kapan saja (tanpa build ulang):

```bash
bash tools/free_android_ram.sh
```

### Ikon

Ikon launcher bisa dibuat ulang dari `icon.svg`:

```bash
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . \
  --script res://tools/generate_android_icons.gd
```


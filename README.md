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

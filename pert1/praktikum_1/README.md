# Praktikum 1 - Pengenalan Flutter, Instalasi, dan Aplikasi Pertama

**Nama:** Bagas Yoas Sibagariang
**NIM:** 20230802254
**Mata Kuliah:** Pemrograman Mobile (Flutter Fundamental)

## Deskripsi

Praktikum ini mengenalkan Flutter dan Dart, cara membuat proyek pertama, struktur folder proyek, konsep widget, serta penggunaan `StatelessWidget` dan `StatefulWidget`. Hasil akhirnya adalah aplikasi **Counter** yang angkanya bisa bertambah, berkurang, dan di-reset.

## Cara Menjalankan

```
flutter pub get
flutter run
```

## Struktur Proyek

| Folder/File | Fungsi |
|---|---|
| `lib/main.dart` | Titik masuk aplikasi (kode utama) |
| `pubspec.yaml` | Konfigurasi proyek dan dependensi |
| `android/`, `ios/` | Kode platform native |
| `test/` | Berkas pengujian |

## Penjelasan Kode (`lib/main.dart`)

### Bagian D - Hello Flutter
Widget tree dasar: `MaterialApp` -> `Scaffold` -> `AppBar` + `Center` -> `Text`.

### Bagian E - Widget Layout
`Column` dipakai untuk menyusun `Icon`, `SizedBox` (jarak), dan `Text` (nama dan NIM) secara vertikal di tengah layar.

### Bagian F - Widget Interaktif
- `MyApp` adalah `StatelessWidget` (tampilan tetap) dan `home:` menunjuk ke `CounterPage()`.
- `CounterPage` adalah `StatefulWidget` karena angkanya berubah.
- Variabel `_count` menyimpan angka. Perubahan dibungkus `setState()` agar Flutter menggambar ulang layar.

## Latihan Mandiri

1. **Warna:** `backgroundColor` pada `AppBar` dan `color` pada `TextStyle` diubah.
2. **Tombol kurang:** `FloatingActionButton` dengan `Icons.remove` yang memanggil `_decrement`.
3. **Tombol reset:** `FloatingActionButton` dengan `Icons.refresh` yang memanggil `_reset` (`_count = 0`).
4. **Cegah negatif:** `_decrement` hanya mengurangi jika `_count > 0`.

Catatan: tiap `FloatingActionButton` diberi `heroTag` berbeda agar tidak terjadi error duplicate Hero tag.

## Jawaban Pertanyaan Refleksi

1. **StatelessWidget vs StatefulWidget:** Stateless tampilannya tetap, Stateful punya data (state) yang bisa berubah sehingga tampilan ikut berubah.
2. **Mengapa perlu `setState()`:** untuk memberi tahu Flutter bahwa data berubah sehingga widget dibangun ulang. Tanpa itu, nilai berubah tetapi layar tidak diperbarui.
3. **Keuntungan hot reload:** perubahan kode langsung tampil tanpa restart penuh, sehingga pengembangan lebih cepat dan state aplikasi tetap terjaga.

## Troubleshooting

| Masalah | Solusi |
|---|---|
| `flutter` tidak dikenali | Periksa PATH (folder `flutter/bin` harus ada di PATH), lalu buka ulang terminal |
| Lisensi Android belum diterima | Jalankan `flutter doctor --android-licenses` |
| Emulator lambat atau gagal menyala | Aktifkan virtualisasi (VT-x/AMD-V) di BIOS. Di Linux, pastikan `/dev/kvm` ada dan user masuk grup `kvm` (`sudo usermod -aG kvm $USER`, lalu login ulang) |
| Perangkat tidak terdeteksi | Aktifkan USB debugging, lalu cek dengan `flutter devices` |
| Warning "no module" atau tombol Run abu-abu di Android Studio | Buka folder proyek yang berisi `pubspec.yaml` (misalnya `praktikum_1`), bukan folder induknya. Pastikan plugin Flutter dan Dart terpasang |
| Dart SDK path kosong | Isi dengan `<folder-flutter>/bin/cache/dart-sdk`. Flutter SDK path diisi `<folder-flutter>` |
| `Undefined name '_decrement'` | Fungsi `_increment`, `_decrement`, `_reset` harus berada di dalam class `_CounterPageState`, di atas `build()`, dengan nama yang persis sama |
| `Expected an identifier` di akhir `Scaffold` | Periksa kurung: penutup `Scaffold` harus `);`, bukan `};` |
| Error duplicate Hero tag | Beri tiap `FloatingActionButton` `heroTag` yang berbeda |
| Perubahan tidak muncul | Gunakan Hot Restart bila mengubah `main()` atau data `const` |


## Hasil
> Tambahkan screenshot aplikasi di sini.
![Counter](1.png?raw=true)


# Praktikum 5 - Penyimpanan Lokal (SharedPreferences dan SQLite)

Praktikum Flutter Fundamental, Pertemuan 5: **SharedPreferences dan SQLite (sqflite)**.

- **Nama:** Bagas Yoas Sibagariang
- **NIM:** 20230801254
- **Mata Kuliah:** Pemrograman Mobile

## Tujuan

- Memilih jenis penyimpanan lokal yang tepat: key-value, database, atau berkas.
- Menyimpan dan membaca pengaturan sederhana dengan `shared_preferences`.
- Merancang tabel dan membuat database SQLite dengan `sqflite`.
- Mengimplementasikan operasi CRUD (Create, Read, Update, Delete) dan menghubungkannya dengan UI.
- Memastikan data tetap ada setelah aplikasi ditutup dan dibuka kembali.

## Cara Menjalankan

```bash
flutter create praktikum_5
cd praktikum_5
flutter pub add shared_preferences sqflite path
flutter run
```

Jalankan di **emulator/perangkat Android** (sqflite tidak jalan di web, Windows, dan Linux tanpa paket tambahan). Setelah memasang paket baru, **Stop** aplikasi lalu `flutter run` ulang (hot reload tidak memuat plugin baru).

## Isi Praktikum

| Bagian | Isi | Berkas |
|--------|-----|--------|
| A | SharedPreferences: simpan nama, mode gelap, dan hitungan aplikasi dibuka | `bagian_a.dart` |
| B | Menyiapkan SQLite: model `Catatan` dan `DbHelper` | `bagian_b_d.dart` |
| C | Halaman daftar catatan (Read dan Delete) | `bagian_b_d.dart` |
| D | Form tambah dan ubah catatan (Create dan Update) | `bagian_b_d.dart` |

> Salin isi berkas yang ingin dijalankan ke `lib/main.dart`. Bagian A dan Bagian B-D adalah dua aplikasi berbeda, jadi dijalankan bergantian.

### Bagian A - SharedPreferences

Menyimpan tiga data kecil: `nama` (String), `gelap` (bool), dan `bukaKe` (int). Nilai bawaan dipakai dengan `??` bila data belum pernah disimpan.

Checkpoint: isi nama, aktifkan mode gelap, hentikan aplikasi sepenuhnya, lalu jalankan lagi. Nama dan mode gelap tetap ada, dan hitungan bertambah setiap kali dibuka.

Screenshot: `screenshots/bagian_a.png`

### Bagian B-D - SQLite (CRUD Catatan)

| CRUD | SQL | Method sqflite |
|------|-----|----------------|
| Create | INSERT | `db.insert()` |
| Read | SELECT | `db.query()` |
| Update | UPDATE | `db.update()` |
| Delete | DELETE | `db.delete()` |

Query memakai placeholder `?` dan `whereArgs` agar aman dari SQL injection.

Checkpoint: (1) menambah catatan memunculkannya di daftar, (2) mengetuk catatan membuka form terisi dan menyimpannya memperbarui data, (3) ikon sampah menghapus, (4) tutup aplikasi sepenuhnya dan buka lagi, semua catatan masih ada.

Screenshot:

- Daftar catatan: `screenshots/daftar.png`
- Form tambah/ubah: `screenshots/form.png`
- Data bertahan setelah restart: `screenshots/restart.png`

## Latihan Mandiri

Berkas: `latihan_mandiri.dart` (soal 1-4 digabung, dibangun di atas Bagian B-D). Paket tambahan: `shared_preferences`.

1. **Dialog konfirmasi hapus.** Ikon sampah menampilkan `AlertDialog` "Hapus catatan ini?" dengan tombol Batal dan Hapus. Data dihapus hanya bila memilih Hapus.
2. **Pencarian.** Kolom cari memfilter daftar memakai `where: 'judul LIKE ?'` dan `whereArgs: ['%$kata%']`.
3. **Kolom `dibuat`.** `version` dinaikkan menjadi 2 dan `onUpgrade` menjalankan `ALTER TABLE catatan ADD COLUMN dibuat TEXT`. Catatan baru diberi tanggal pembuatan, catatan lama bernilai `null` (ditampilkan "-").
4. **Urutan tersimpan.** Pilihan urutan (terbaru/terlama) disimpan dengan `shared_preferences` dan dipakai pada `orderBy`.

Hasil pengamatan soal 3 (bila `version` tidak dinaikkan): `onUpgrade` tidak dijalankan sehingga kolom `dibuat` tidak pernah dibuat, dan menambah catatan menghasilkan galat `table catatan has no column named dibuat`.

Screenshot:

- Dialog konfirmasi hapus: `screenshots/latihan1_dialog.png`
- Hasil pencarian: `screenshots/latihan2_cari.png`
- Daftar dengan tanggal dibuat: `screenshots/latihan3_dibuat.png`
- Galat saat `version` tidak dinaikkan: `screenshots/latihan3_galat.png`
- Urutan terbaru dan terlama: `screenshots/latihan4_urutan.png`

## Jawaban Pertanyaan Refleksi

1. **Mengapa `shared_preferences` kurang cocok untuk ratusan catatan?** Ia dirancang untuk pasangan key-value kecil, tanpa query, pencarian, atau pengurutan. Untuk data banyak dan terstruktur, pilihan yang lebih baik adalah database SQLite (`sqflite`).
2. **Mengapa query memakai placeholder `?` dan `whereArgs`?** Agar nilai dari pengguna tidak disambung langsung ke teks SQL, sehingga aman dari SQL injection.
3. **Mengapa daftar perlu dimuat ulang setelah kembali dari form?** Halaman daftar tidak tahu bahwa data berubah di halaman lain. Pada kode ini, `await Navigator.push(...)` menunggu form ditutup, lalu `_muat()` dipanggil untuk mengambil data terbaru.
4. **Fungsi `onCreate` dan `onUpgrade`?** `onCreate` dijalankan sekali saat database pertama kali dibuat (untuk membuat tabel). `onUpgrade` dijalankan saat `version` di kode lebih besar dari versi database di perangkat (untuk mengubah skema tanpa menghapus data).

## Referensi

- [Menyimpan data key-value](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Membaca dan menulis SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Paket shared_preferences](https://pub.dev/packages/shared_preferences)
- [Paket sqflite](https://pub.dev/packages/sqflite)
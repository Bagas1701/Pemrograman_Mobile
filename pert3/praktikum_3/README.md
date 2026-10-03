# Praktikum 3 - Form Input dan State Management

**Nama:** Bagas Yoas Sibagariang
**NIM:** 20230802254
**Mata Kuliah:** Pemrograman Mobile (Flutter Fundamental)

## Deskripsi

Praktikum ini membahas pengambilan input pengguna (`TextField`, `TextEditingController`), form dengan validasi (`Form`, `TextFormField`, dropdown, checkbox), serta state management dasar dengan `ChangeNotifier` dan paket **Provider**. Hasil akhirnya adalah aplikasi **Daftar Tugas** yang datanya dibagikan ke dua halaman.

## Cara Menjalankan

```
flutter pub add provider
flutter pub get
flutter run
```

Setelah menambah paket, **restart aplikasi** (bukan hot reload).

## Konsep Utama

| Konsep | Penjelasan |
|---|---|
| `TextEditingController` | Membaca isi `TextField`; harus di-`dispose()` agar tidak terjadi kebocoran memori |
| `Form` + `GlobalKey<FormState>` | Memvalidasi banyak isian sekaligus lewat `validate()` |
| `validator` | Mengembalikan pesan error jika salah, `null` jika valid |
| `setState` | State lokal, hanya untuk satu widget/halaman |
| `ChangeNotifier` | Objek state bersama; memanggil `notifyListeners()` saat data berubah |
| `context.watch<T>()` | Dipakai di `build()`, widget dibangun ulang saat data berubah |
| `context.read<T>()` | Dipakai di callback (`onPressed`), membaca sekali tanpa membangun ulang |

## Penjelasan Kode (`lib/main.dart`)

### Bagian A - Input Dasar
`InputPage` membaca teks dari `TextField` lewat controller, lalu `setState` menampilkan sapaan saat tombol **Sapa** ditekan.

### Bagian B - Form dengan Validasi
`FormPage` berisi nama, email (harus memuat `@`), dropdown jurusan, dan checkbox persetujuan. Tombol **Daftar** nonaktif (`onPressed: null`) sampai checkbox dicentang, dan `SnackBar` muncul jika semua isian valid.

### Bagian C - Mengapa Butuh State Management
Mengoper data antar halaman lewat constructor dan callback cepat menjadi rumit. Solusinya adalah satu objek bersama yang diakses semua halaman.

### Bagian D - Daftar Tugas dengan Provider
- `Tugas`: model data (`judul`, `selesai`).
- `TugasModel extends ChangeNotifier`: menyimpan daftar tugas, dengan method `tambah`, `toggle`, `hapus`, dan getter `jumlahSelesai`.
- `ChangeNotifierProvider` dipasang di `main()` di atas `MyApp`.
- `TugasPage`: menampilkan daftar dengan `context.watch`; checkbox dan tombol hapus memakai `context.read`.
- `TambahPage`: halaman terpisah yang menambah tugas ke model yang sama.

## Latihan Mandiri

1. **Validasi judul minimal 3 karakter:** `TambahPage` memakai `Form` + `TextFormField` dengan `validator`.
2. **`hapusSelesai()`:** method baru di `TugasModel` memakai `removeWhere`, dengan tombol (ikon sapu) di `AppBar`.
3. **SnackBar "Tugas ditambahkan":** `ScaffoldMessenger` diambil **sebelum** `Navigator.pop` agar `context` tetap aman.
4. **Daftar kosong:** jika `model.items.isEmpty`, tampilkan teks "Belum ada tugas" di tengah layar.

## Jawaban Pertanyaan Refleksi

1. **Mengapa controller harus di-dispose?** Controller memegang sumber daya di memori. Tanpa `dispose()`, objek tetap tersimpan setelah halaman ditutup (memory leak).
2. **Kapan setState, kapan Provider?** `setState` cukup untuk data satu widget/halaman. Gunakan Provider jika data dipakai banyak halaman.
3. **Jika `notifyListeners()` lupa dipanggil?** Data berubah tetapi tampilan tidak ikut diperbarui, karena widget yang `watch` hanya dibangun ulang saat model memberi sinyal.
4. **Mengapa `context.read` di `onPressed`?** Callback hanya butuh memanggil fungsi sekali, bukan memantau perubahan. `watch` hanya valid di dalam `build()`.

## Troubleshooting

| Masalah | Solusi |
|---|---|
| `Could not find the correct Provider` | Pastikan `ChangeNotifierProvider` berada di atas `MaterialApp` |
| Package `provider` tidak ditemukan | Jalankan `flutter pub get`, lalu restart aplikasi |
| Tampilan tidak berubah | Periksa `notifyListeners()` dan pemakaian `context.watch` |

## Hasil
> Tambahkan screenshot halaman Daftar Tugas, Tambah Tugas (termasuk pesan error validasi), dan kondisi daftar kosong di sini.

![Counter](1.png?raw=true) ![Counter](2.png?raw=true) ![Counter](3.png?raw=true)
# Tugas 3 - Aplikasi Daftar Belanja

**Nama:** Bagas Yoas Sibagariang
**NIM:** 20230802254
**Mata Kuliah:** Pemrograman Mobile (Flutter Fundamental)

## Deskripsi

Aplikasi **Daftar Belanja** dengan dua halaman: halaman daftar barang dan halaman form tambah barang. State disimpan pada satu `ChangeNotifier` dan dibagikan dengan Provider. Dibuat sesuai ketentuan Pertemuan 3.

## Ketentuan yang Dipenuhi

| Ketentuan | Implementasi |
|---|---|
| Form tambah dengan validasi tiap isian | `TambahBarangPage` dengan `Form` dan `validator` |
| Nama barang wajib | Tidak boleh kosong |
| Jumlah wajib, angka lebih dari 0 | Divalidasi: kosong, bukan angka, dan `<= 0` ditolak |
| Kategori (dropdown) | `DropdownButtonFormField` (Makanan, Minuman, Kebutuhan Rumah) |
| Daftar bisa dicentang "sudah dibeli" dan dihapus | `Checkbox` memanggil `toggle`, ikon sampah memanggil `hapus` |
| Satu `ChangeNotifier` + Provider | `BelanjaModel` dengan `ChangeNotifierProvider` di `main()` |
| AppBar menampilkan jumlah barang belum dibeli | Getter `jumlahBelumDibeli` |

## Cara Menjalankan

```
flutter pub add provider
flutter pub get
flutter run
```

## Penjelasan Kode (`lib/main.dart`)

1. **`Barang`** adalah model data: `nama`, `jumlah`, `kategori`, `sudahDibeli`.
2. **`BelanjaModel extends ChangeNotifier`** menyimpan daftar barang. Method `tambah`, `toggle`, dan `hapus` memanggil `notifyListeners()` agar tampilan diperbarui. Getter `jumlahBelumDibeli` menghitung barang yang belum dibeli.
3. **`main()`** membungkus `MyApp` dengan `ChangeNotifierProvider` supaya semua halaman bisa mengakses model yang sama.
4. **`BelanjaPage`** menampilkan daftar dengan `ListView.builder`. `context.watch` dipakai di `build()`, sedangkan `context.read` dipakai di callback `onChanged` dan `onPressed`. Jika daftar kosong, tampil teks "Belum ada barang".
5. **`TambahBarangPage`** berisi form dengan tiga isian dan validasi. Jika valid, data dikirim ke model lewat `context.read<BelanjaModel>().tambah(...)`, lalu halaman ditutup dengan `Navigator.pop`.

## Alur Aplikasi

```
BelanjaPage (daftar)  --tombol +-->  TambahBarangPage (form)
        ^                                   |
        |------ model.tambah() + pop -------|
```

## Contoh Pesan Validasi

| Kondisi | Pesan |
|---|---|
| Nama kosong | Nama wajib diisi |
| Jumlah kosong | Jumlah wajib diisi |
| Jumlah bukan angka | Jumlah harus berupa angka |
| Jumlah 0 atau negatif | Jumlah harus lebih dari 0 |
| Kategori belum dipilih | Pilih kategori |

## Hasil
> Tambahkan screenshot halaman Daftar dan halaman Form (saat pesan error validasi tampil) di sini.
![Counter](1.png?raw=true) ![Counter](2.png?raw=true)
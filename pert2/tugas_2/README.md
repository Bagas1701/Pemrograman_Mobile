# Tugas 2 - Aplikasi Daftar Kontak

**Nama:** Bagas Yoas Sibagariang
**NIM:** 20230802254
**Mata Kuliah:** Pemrograman Mobile (Flutter Fundamental)

## Deskripsi

Aplikasi **Daftar Kontak** dengan dua halaman: halaman daftar kontak dan halaman detail kontak. Dibuat sesuai ketentuan Pertemuan 2.

## Ketentuan yang Dipenuhi

| Ketentuan | Implementasi |
|---|---|
| Minimal 6 kontak (nama, telepon, email) dalam list berisi objek class | `daftarKontak` berisi 6 objek `Kontak` |
| Halaman utama dengan `ListView.builder` dan `ListTile` | `KontakPage` |
| Avatar berisi huruf pertama nama | `CircleAvatar(child: Text(item.nama[0]))` |
| Ketuk kontak membuka halaman detail | `Navigator.push` ke `DetailPage` |
| Detail menampilkan seluruh data dan tombol kembali | `DetailPage` dengan `Navigator.pop` |

## Cara Menjalankan

```
flutter pub get
flutter run
```

## Penjelasan Kode (`lib/main.dart`)

1. **Class `Kontak`** menyimpan `nama`, `telepon`, dan `email`.
2. **`daftarKontak`** adalah list berisi 6 objek `Kontak`.
3. **`KontakPage`** (StatelessWidget) menampilkan daftar dengan `ListView.builder`. Tiap item adalah `ListTile` dengan avatar huruf pertama, nama, dan nomor telepon. `onTap` membuka halaman detail.
4. **`DetailPage`** menerima objek `Kontak` lewat constructor, lalu menampilkan avatar, nama, telepon, email, dan tombol **Kembali**.

## Alur Aplikasi

```
KontakPage (daftar)  --ketuk kontak-->  DetailPage (detail)
                     <--tombol Kembali--
```

## Hasil
> Tambahkan screenshot halaman Daftar Kontak dan halaman Detail di sini.

![Counter](1.png?raw=true)
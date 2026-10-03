# Praktikum 2 - Layout, ListView, dan Navigasi Antar Halaman

**Nama:** Bagas Yoas Sibagariang
**NIM:** 20230802254
**Mata Kuliah:** Pemrograman Mobile (Flutter Fundamental)

## Deskripsi

Praktikum ini membahas penyusunan layout (`Container`, `Padding`, `Row`, `Column`, `Expanded`), menampilkan daftar data dengan `ListView.builder`, memodelkan data dengan class Dart, dan berpindah halaman dengan `Navigator`. Hasil akhirnya adalah aplikasi **Daftar Menu** makanan dengan halaman detail.

## Cara Menjalankan

```
flutter pub get
flutter run
```

Gunakan **Hot Restart** jika mengubah data `const` atau fungsi `main()`.

## Penjelasan Kode (`lib/main.dart`)

### Bagian A - Layout Kartu Profil
`ProfilePage` memakai `Container` (warna dan sudut membulat), `Row`, `CircleAvatar`, dan `Expanded`. `Expanded` membuat teks mengisi sisa ruang sehingga tidak overflow jika teks panjang.

### Bagian B - Model Data dan ListView
- Class `Makanan` menyimpan data (`nama`, `harga`).
- `daftarMenu` adalah list berisi objek `Makanan`.
- `MenuPage` menampilkan list dengan `ListView.builder`, `Card`, dan `ListTile`.
- `home:` pada `MyApp` diubah menjadi `const MenuPage()`.

### Bagian C - Navigasi ke Halaman Detail
- `onTap` pada `ListTile` memanggil `Navigator.push` untuk membuka `DetailPage`.
- Data dikirim lewat constructor: `DetailPage(makanan: item)`.
- Tombol **Kembali** memakai `Navigator.pop(context)`.

## Latihan Mandiri

1. **Tambah 3 menu baru** (Sate Ayam, Bakso, Jus Jeruk) sehingga total 7 menu. `ListView.builder` otomatis bisa di-scroll.
2. **Properti `deskripsi`** ditambahkan pada class `Makanan` dan ditampilkan di `DetailPage`.
3. **`Card` diganti `Container`** dengan `BoxDecoration` (warna latar dan `borderRadius`).
4. **Format ribuan:** fungsi buatan sendiri `formatHarga()` membaca angka dari belakang dan menyisipkan titik tiap 3 digit (`15000` -> `Rp 15.000`).

## Jawaban Pertanyaan Refleksi

1. **ListView vs ListView.builder:** `ListView` biasa membuat semua item sekaligus, sedangkan `ListView.builder` hanya membuat item yang terlihat sehingga efisien untuk data banyak.
2. **Overflow pada Row:** teks panjang melebihi lebar layar karena `Row` tidak membatasi anaknya. `Expanded` membatasi anak pada sisa ruang sehingga teks turun ke baris berikutnya.
3. **Pengiriman data ke halaman detail:** lewat constructor `DetailPage`, dengan objek `Makanan` yang dipilih dikirim saat `Navigator.push`.

## Troubleshooting

| Masalah | Solusi |
|---|---|
| Garis kuning-hitam (overflow) di layar | Bungkus widget dengan `Expanded` atau `SingleChildScrollView` |
| Error: `ListView` tanpa tinggi dalam `Column` | Bungkus `ListView` dengan `Expanded` |
| Navigator error: context tidak memiliki Navigator | Pastikan halaman berada di bawah `MaterialApp` |
| Perubahan tidak muncul | Gunakan Hot Restart (`Shift+R` di terminal) bila mengubah `main()` atau data `const` |
| Halaman Daftar Menu tidak tampil | Pastikan `home:` pada `MyApp` diganti menjadi `const MenuPage()`, bukan `ProfilePage()` |
| Error setelah menambah properti `deskripsi` | Setiap `Makanan(...)` di `daftarMenu` harus diberi 3 argumen: nama, harga, dan deskripsi |
| Harga tidak berformat ribuan | Pastikan `formatHarga(item.harga)` dipakai di `MenuPage` **dan** `DetailPage`, bukan `'Rp ${item.harga}'` |

## Hasil
> Tambahkan screenshot halaman Daftar Menu dan halaman Detail di sini.
![Counter](1.png?raw=true)

# Tugas 1 - Kartu Perkenalan

**Nama:** Bagas Yoas Sibagariang
**NIM:** 20230802254
**Mata Kuliah:** Pemrograman Mobile (Flutter Fundamental)

## Deskripsi

Aplikasi satu halaman bernama **Kartu Perkenalan** yang menampilkan foto/ikon, nama, NIM, jurusan, dan hobi. Dibuat sesuai ketentuan Pertemuan 1, yaitu memakai `Column`, `Text`, `Icon`, dan `SizedBox`.

## Cara Menjalankan

```
flutter pub get
flutter run
```

## Penjelasan Kode (`lib/main.dart`)

- `MyApp` adalah `StatelessWidget` karena tampilannya tidak berubah.
- Widget tree: `MaterialApp` -> `Scaffold` -> `AppBar` + `Center` -> `Column`.
- `Icon(Icons.account_circle)` berfungsi sebagai foto profil.
- `Text` menampilkan nama, NIM, jurusan, dan hobi.
- `SizedBox` memberi jarak vertikal antar elemen.
- `Column` dengan `mainAxisAlignment: MainAxisAlignment.center` menyusun semuanya vertikal di tengah layar.

## Data yang Ditampilkan

| Data | Isi |
|---|---|
| Nama | Bagas Yoas Sibagariang |
| NIM | 20230802254 |
| Jurusan | Teknik Informatika |
| Hobi | Bermain game |

> Sesuaikan jurusan dan hobi dengan data yang sebenarnya.

## Hasil
> Tambahkan screenshot aplikasi di sini.

![Counter](1.png?raw=true)

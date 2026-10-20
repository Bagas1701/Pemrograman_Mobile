# Praktikum 6 — Tema, Routing dan Navigasi, serta Animasi

**Mata kuliah:** Pemrograman Mobile (Flutter Fundamental)
**Pertemuan:** 6
**Nama / NIM:** _(isi di sini)_

Dokumen ini menjelaskan seluruh pekerjaan Pertemuan 6: Langkah Praktikum (Bagian A–D), Latihan Mandiri (soal 1–5), dan jawaban Pertanyaan Refleksi (1–5). Seluruh kode berada dalam satu berkas, `lib/main.dart`.

---

## Daftar Isi

1. [Tujuan](#1-tujuan)
2. [Cara Menjalankan](#2-cara-menjalankan)
3. [Langkah Praktikum](#3-langkah-praktikum)
   - [Bagian A: Tema Terang/Gelap dan Warna Tema](#bagian-a-tema-teranggelap-dan-warna-tema)
   - [Bagian B: Named Routes, Argumen, dan Hero](#bagian-b-named-routes-argumen-dan-hero)
   - [Bagian C: Animasi](#bagian-c-animasi)
   - [Bagian D: Navigasi Tab Bawah](#bagian-d-navigasi-tab-bawah)
4. [Latihan Mandiri](#4-latihan-mandiri)
5. [Pertanyaan Refleksi](#5-pertanyaan-refleksi)
6. [Troubleshooting yang Pernah Ditemui](#6-troubleshooting-yang-pernah-ditemui)

---

## 1. Tujuan

Setelah praktikum ini, saya mampu:

1. Membuat tema terang/gelap dan warna tema yang dapat diganti pengguna dengan `ThemeData` dan `ThemeMode`.
2. Memakai nilai tema (`Theme.of(context)`) alih-alih warna dan gaya yang ditulis manual.
3. Menerapkan named routes, mengirim argumen antar halaman, dan `onGenerateRoute`.
4. Membuat navigasi tab bawah dengan `NavigationBar` dan `IndexedStack`.
5. Membuat animasi implisit (`AnimatedContainer`, `AnimatedSwitcher`, `AnimatedOpacity`), transisi `Hero`, dan animasi eksplisit (`AnimationController`).

---

## 2. Cara Menjalankan

```bash
flutter create praktikum_6
cd praktikum_6
flutter pub add shared_preferences   # dibutuhkan mulai Latihan Mandiri 1
flutter run
```

Ganti isi `lib/main.dart` dengan kode praktikum. Setelah menambah paket baru, aplikasi harus dijalankan ulang penuh (bukan hot reload/hot restart).

---

## 3. Langkah Praktikum

Pengerjaan dilakukan bertahap. Setiap bagian membangun di atas bagian sebelumnya dalam file yang sama.

| Bagian | Topik | Bisa dijalankan sendiri? |
|---|---|---|
| A | Tema terang/gelap dan warna tema | Ya |
| B | Named routes, argumen, Hero | Ya (halaman Pengaturan sementara tidak bisa diakses) |
| C | Animasi implisit dan eksplisit | Ya (dites dengan mengganti `body` rute `/` sementara) |
| D | Navigasi tab bawah | Ya (menyatukan A, B, dan C) |

### Bagian A: Tema Terang/Gelap dan Warna Tema

**Tujuan:** pengguna dapat mengganti mode terang/gelap dan warna tema, dan seluruh aplikasi berubah tanpa restart.

**Konsep dan kode inti**

```dart
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
```

```dart
return ListenableBuilder(
  listenable: Listenable.merge([themeMode, seedColor]),
  builder: (context, _) {
    return MaterialApp(
      theme: buatTema(seedColor.value, Brightness.light),
      darkTheme: buatTema(seedColor.value, Brightness.dark),
      themeMode: themeMode.value,
      // ...
    );
  },
);
```

**Penjelasan**

- **`ValueNotifier`** adalah penyimpan satu nilai yang memberi tahu pendengarnya saat `.value` berubah. Karena dibuat global, widget mana pun (misalnya `PengaturanTab`) dapat mengubah tema milik `MyApp`.
- **`colorSchemeSeed`** cukup diberi satu warna; Material 3 menghasilkan seluruh palet (`primary`, `secondary`, `tertiary`, `*Container`, `on*`, dan lainnya).
- **`theme`, `darkTheme`, `themeMode`** pada `MaterialApp`: `theme` dipakai saat terang, `darkTheme` saat gelap, dan `themeMode` menentukan mana yang aktif (`light`, `dark`, atau `system`).
- **`ListenableBuilder` + `Listenable.merge`** menggabungkan dua notifier. Setiap kali salah satu berubah, `MaterialApp` dibangun ulang dengan tema baru.
- **`PengaturanTab`** berisi `SwitchListTile` untuk mode gelap dan deretan `CircleAvatar` yang dibungkus `GestureDetector` untuk memilih warna. Tanda centang hanya muncul pada warna yang sama dengan `seedColor.value`.
- **`Theme.of(context)`** dipakai untuk gaya teks, sehingga tidak ada warna atau ukuran font yang ditulis manual.

**Checkpoint:** saklar mode gelap dan pilihan warna langsung mengubah AppBar dan seluruh aplikasi tanpa restart.

---

### Bagian B: Named Routes, Argumen, dan Hero

**Tujuan:** membuka halaman detail lewat nama rute sambil membawa data, dengan transisi ikon yang mulus.

**Konsep dan kode inti**

```dart
class Item {
  final String nama;
  final IconData ikon;
  final Color warna;
  const Item(this.nama, this.ikon, this.warna);
}
```

```dart
// Pengirim (BerandaTab)
Navigator.pushNamed(context, '/detail', arguments: item);
```

```dart
// Pendaftaran rute (MyApp)
initialRoute: '/',
routes: {
  '/': (_) => Scaffold(/* ... */),
},
onGenerateRoute: (settings) {
  if (settings.name == '/detail') {
    final item = settings.arguments as Item;
    return MaterialPageRoute(
      builder: (_) => DetailPage(item: item),
      settings: settings,
    );
  }
  return null;
},
```

**Penjelasan**

- **Model `Item`** menyimpan nama, ikon, dan warna. `const` membuat objek dibuat sekali saat kompilasi.
- **`ListView.builder`** hanya membangun widget yang terlihat di layar, sehingga hemat untuk daftar panjang.
- **Named route** memberi nama pada halaman sehingga seluruh alamat halaman terkumpul di satu tempat (`MyApp`), tidak tersebar di setiap tombol.
- **`routes` vs `onGenerateRoute`:** `routes` untuk halaman tanpa argumen (`/`), `onGenerateRoute` untuk halaman yang membawa argumen (`/detail`). Alurnya: `pushNamed('/detail')` → dicari di `routes` → tidak ada → `onGenerateRoute` dipanggil → nama cocok → halaman dibuat.
- **`settings.arguments as Item`** mengubah tipe `Object?` menjadi `Item`. Pemeriksaan tipe ada di satu tempat, sehingga lebih aman daripada `ModalRoute.of(context)!.settings.arguments` di tiap halaman.
- **`Hero`** membuat elemen "terbang" mulus dari daftar ke detail. Syaratnya, `tag` di kedua halaman sama persis (`'ikon-${item.nama}'`) dan unik di dalam satu halaman.
- **`DetailPage`** memakai `Theme.of(context)` untuk gaya teks, sehingga ikut berubah saat mode gelap.

**Checkpoint:** mengetuk item membuka detail, ikon terbang membesar (Hero) dan mengecil saat kembali. Halaman Pengaturan sementara belum dapat diakses (kembali di Bagian D).

---

### Bagian C: Animasi

**Tujuan:** mencoba tiga jenis animasi: implisit, pergantian widget, dan eksplisit.

**Demo 1 — `AnimatedContainer` (implisit)**

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOut,
  width: _besar ? 200 : 100,
  height: 100,
  decoration: BoxDecoration(
    color: _besar ? warna.primary : warna.tertiary,
    borderRadius: BorderRadius.circular(_besar ? 50 : 8),
  ),
)
// tombol: setState(() => _besar = !_besar)
```

Cukup mengubah nilai lewat `setState`; Flutter mengisi transisi lebar, warna, dan sudut selama 500 ms.

**Demo 2 — `AnimatedSwitcher`**

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
  child: Text('$_hitung', key: ValueKey(_hitung), style: tema.textTheme.displayMedium),
)
```

`AnimatedSwitcher` hanya menganimasikan jika anaknya dianggap **widget berbeda**. Dua `Text` bertipe sama dianggap sama sehingga hanya isinya yang diperbarui tanpa animasi. Dengan `key: ValueKey(_hitung)`, setiap angka punya identitas sendiri, sehingga setiap perubahan dianggap pergantian widget dan animasi berjalan.

**Demo 3 — `AnimationController` (eksplisit)**

```dart
class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _putar;

  @override
  void initState() {
    super.initState();
    _putar = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();
    super.dispose();
  }
  // ...
  // RotationTransition(turns: _putar, child: Icon(Icons.settings, ...))
}
```

- `SingleTickerProviderStateMixin` menyediakan `vsync`, yaitu sinyal "frame baru siap digambar" yang juga menghentikan animasi bila layar tidak terlihat. Tanpa mixin ini muncul error `vsync / TickerProvider`.
- `late final` dipakai karena controller baru dibuat di `initState` (butuh `this`).
- `..repeat()` (cascade) membuat controller lalu langsung memanggil `repeat()`; nilai berjalan 0.0 → 1.0 berulang selama 2 detik.
- `RotationTransition` memutar ikon sesuai nilai controller (1.0 = satu putaran penuh).
- Tombol memakai `isAnimating` untuk memilih `stop()` atau `repeat()`. `setState(() {})` dipanggil hanya agar teks tombol diperbarui; animasinya sendiri tidak membutuhkan `setState`.
- `dispose()` wajib membuang controller (lihat Refleksi no. 5).

**Checkpoint:** (1) bentuk, warna, dan sudut berubah halus; (2) angka berganti dengan efek membesar; (3) roda gigi berputar dan dapat dihentikan.

---

### Bagian D: Navigasi Tab Bawah

**Tujuan:** menyatukan tiga halaman dalam satu `Scaffold` dengan bar navigasi bawah.

**Kode inti**

```dart
class _ShellPageState extends State<ShellPage> {
  int _index = 0;
  static const _halaman = [BerandaTab(), AnimasiTab(), PengaturanTab()];
  static const _judul = ['Beranda', 'Animasi', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [ /* 3 NavigationDestination */ ],
      ),
    );
  }
}
```

```dart
routes: {
  '/': (_) => const ShellPage(),
},
```

**Penjelasan**

- **Satu `Scaffold`, tiga isi.** `ShellPage` memegang `AppBar`, isi, dan bar bawah. Ketiga tab hanya "isi" tanpa `Scaffold` sendiri.
- **`_index`** menyimpan tab aktif dan dipakai di tiga tempat: judul AppBar, `IndexedStack`, dan `NavigationBar`.
- **`NavigationBar`** (Material 3) memanggil `onDestinationSelected` dengan nomor tombol yang diketuk. `selectedIcon` adalah ikon terisi untuk tab aktif.
- **`IndexedStack`** menumpuk semua halaman tetapi hanya menampilkan satu. Halaman lain tetap hidup, sehingga state tidak hilang (roda gigi tetap berputar, posisi scroll terjaga).
- **`static const`** dipakai karena daftar halaman dan judul tidak pernah berubah.
- **Halaman detail menutupi bar bawah** karena `Navigator.pushNamed` membuka rute baru di atas `ShellPage` sepenuhnya.
- `onGenerateRoute` untuk `/detail` tetap dipertahankan.

**Checkpoint:** tiga tab di bawah; Beranda membuka detail dengan Hero, Animasi menjalankan demo, Pengaturan mengganti tema seluruh aplikasi termasuk halaman detail.

---

## 4. Latihan Mandiri

### Latihan 1 — Menyimpan tema dengan `shared_preferences`

**Soal:** simpan mode gelap dan warna tema, lalu muat saat aplikasi dimulai.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final gelap = prefs.getBool('gelap') ?? false;
  final indeksWarna = prefs.getInt('warna') ?? 0;

  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  seedColor.value = pilihanWarna[indeksWarna.clamp(0, pilihanWarna.length - 1)];

  themeMode.addListener(() {
    prefs.setBool('gelap', themeMode.value == ThemeMode.dark);
  });
  seedColor.addListener(() {
    prefs.setInt('warna', pilihanWarna.indexOf(seedColor.value));
  });

  runApp(const MyApp());
}
```

**Penjelasan**

- `main()` menjadi `async` karena membaca penyimpanan butuh waktu dan harus selesai **sebelum** `runApp`, agar tema pertama yang tampil sudah benar.
- `WidgetsFlutterBinding.ensureInitialized()` menyiapkan jembatan Flutter–sistem. Wajib dipanggil manual karena plugin dipakai sebelum `runApp`.
- `getBool(...) ?? false`: jika belum pernah disimpan (`null`), dipakai nilai awal.
- Warna disimpan sebagai **indeks** di `pilihanWarna`, karena `SharedPreferences` hanya menyimpan tipe sederhana (`bool`, `int`, `double`, `String`, `List<String>`). `.clamp` menjaga indeks tetap valid jika daftar warna berubah.
- `addListener` pada `ValueNotifier` menyimpan otomatis setiap kali nilai berubah, tanpa mengubah `PengaturanTab`.

**Pengujian:** aktifkan mode gelap dan pilih pink, tutup aplikasi sepenuhnya, buka lagi: tampil gelap dan pink.

### Latihan 2 — `Drawer` pada `ShellPage`

**Soal:** tambahkan `Drawer` berisi menu untuk berpindah tab.

```dart
drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: warna.primaryContainer),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text('Menu',
              style: tema.textTheme.headlineMedium
                  ?.copyWith(color: warna.onPrimaryContainer)),
        ),
      ),
      for (int i = 0; i < _judul.length; i++)
        ListTile(
          leading: Icon(_ikon[i]),
          title: Text(_judul[i]),
          selected: _index == i,
          onTap: () {
            setState(() => _index = i);
            Navigator.pop(context);
          },
        ),
    ],
  ),
),
```

**Penjelasan**

- Mengisi `drawer:` pada `Scaffold` otomatis memunculkan ikon hamburger di AppBar dan gestur geser dari tepi kiri.
- `Navigator.pop(context)` menutup drawer, karena drawer adalah lapisan yang ditumpuk di atas layar. Tanpa itu tab berpindah tetapi drawer tetap terbuka.
- `selected: _index == i` menyorot menu aktif dan tersinkron dengan `NavigationBar` karena memakai `_index` yang sama.
- Warna header memakai `primaryContainer` dan `onPrimaryContainer` dari tema, sehingga kontras terjaga di mode terang maupun gelap.
- Menu dibuat dengan `for` dari `_judul` dan `_ikon`, sehingga menambah tab cukup menambah isi dua daftar itu.

### Latihan 3 — Transisi `FadeTransition` dengan `PageRouteBuilder`

**Soal:** ganti transisi halaman detail dengan `PageRouteBuilder` yang memakai `FadeTransition` di dalam `onGenerateRoute`.

```dart
onGenerateRoute: (settings) {
  if (settings.name == '/detail') {
    final item = settings.arguments as Item;
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DetailPage(item: item);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
  return null;
},
```

**Penjelasan**

- `MaterialPageRoute` memakai animasi bawaan platform yang tidak bisa diubah, sedangkan `PageRouteBuilder` adalah rute kustom.
- `pageBuilder` menentukan **apa** yang ditampilkan; `transitionsBuilder` menentukan **bagaimana** halaman itu muncul dan hilang.
- `animation` berjalan 0.0 → 1.0 saat halaman masuk dan 1.0 → 0.0 saat `pop`. Dipasang ke `opacity`, halaman memudar masuk dan keluar tanpa `AnimationController` buatan sendiri.
- Hero tetap berfungsi pada rute kustom, sehingga ikon tetap terbang sementara halaman memudar.

### Latihan 4 — `onUnknownRoute` (halaman 404)

**Soal:** tampilkan halaman "404 - Halaman tidak ditemukan" untuk rute yang tidak terdaftar.

```dart
onUnknownRoute: (settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => HalamanTidakDitemukan(namaRute: settings.name),
  );
},
```

**Penjelasan**

- Urutan pencarian rute: `routes` → `onGenerateRoute` → `onUnknownRoute`. Fungsi `return null;` di akhir `onGenerateRoute` berarti "saya tidak menangani rute ini, serahkan ke yang lain".
- Tanpa `onUnknownRoute`, muncul layar merah `Could not find a generator for route`.
- Nama rute yang salah dikirim ke halaman 404 lewat `settings.name`, sehingga memudahkan mencari salah ketik.
- Halaman 404 memakai `colorScheme.error` dan `textTheme` dari tema.

**Pengujian:** tombol sementara `Navigator.pushNamed(context, '/tidak-ada')` membuka halaman 404; rute `/detail` tetap normal.

### Latihan 5 — `AnimatedOpacity` (demo keempat)

**Soal:** tambahkan kartu yang memudar dan muncul saat tombol ditekan di `AnimasiTab`.

```dart
bool _tampil = true;   // variabel state baru
```

```dart
AnimatedOpacity(
  opacity: _tampil ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeInOut,
  child: Card(
    color: warna.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('Saya bisa memudar!',
          style: tema.textTheme.titleMedium
              ?.copyWith(color: warna.onSecondaryContainer)),
    ),
  ),
),
TextButton(
  onPressed: () => setState(() => _tampil = !_tampil),
  child: Text(_tampil ? 'Sembunyikan' : 'Tampilkan'),
),
```

**Penjelasan**

- Ini animasi **implisit**: hanya nilai `opacity` yang diubah lewat `setState`, tanpa `AnimationController`.
- `AnimatedOpacity` hanya mengubah transparansi. Saat `opacity: 0`, kartu tidak terlihat tetapi **tetap memakan ruang** dan masih menerima sentuhan. Jika widget harus benar-benar hilang beserta ruangnya, gunakan `AnimatedSwitcher` atau `AnimatedCrossFade`.
- Warna kartu dan teks memakai pasangan `secondaryContainer` / `onSecondaryContainer` dari tema.

---

## 5. Pertanyaan Refleksi

### 1. Apa perbedaan animasi implisit dan eksplisit? Kapan memilih masing-masing?

**Animasi implisit** (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`) berjalan otomatis: kita cukup mengubah nilai lewat `setState`, dan Flutter yang membandingkan nilai lama dengan baru lalu mengisi transisinya. Kodenya pendek dan tidak butuh `AnimationController`, `vsync`, atau `dispose`.

**Animasi eksplisit** (`AnimationController` + `RotationTransition`, `FadeTransition`, `SlideTransition`, dan sejenisnya) dikendalikan penuh oleh programmer: kita yang memulai, menghentikan, mengulang, membalik, dan menyusun urutan. Konsekuensinya kodenya lebih panjang (state class dengan mixin, `initState`, `dispose`).

| | Implisit | Eksplisit |
|---|---|---|
| Cara kerja | Ubah nilai, Flutter menganimasikan | Programmer mengendalikan controller |
| Kontrol | Terbatas (durasi, kurva) | Penuh (ulang, berhenti, urutan, sinkronisasi) |
| Kode | Pendek | Lebih panjang |
| Contoh | Kotak yang berubah bentuk, kartu yang memudar | Roda gigi berputar terus, animasi masuk berurutan |

**Pilih implisit** untuk perubahan sederhana yang terjadi satu kali sebagai reaksi terhadap perubahan state. **Pilih eksplisit** bila butuh animasi berulang, bisa dihentikan, berurutan, atau beberapa elemen yang harus sinkron.

### 2. Mengapa dua Hero harus memiliki tag yang sama, dan apa yang terjadi bila tag-nya kembali muncul dua kali di halaman yang sama?

Saat berpindah halaman, Flutter mencari Hero di halaman asal dan halaman tujuan, lalu **mencocokkan keduanya lewat tag**. Pasangan bertag sama dianggap elemen yang sama, sehingga Flutter dapat menerbangkan widget dari posisi dan ukuran lama ke posisi dan ukuran baru. Tanpa tag yang sama, Flutter tidak tahu elemen mana yang harus dihubungkan, sehingga tidak ada animasi terbang.

Jika tag yang sama muncul dua kali **dalam satu halaman**, Flutter tidak bisa menentukan Hero mana yang dipasangkan dan melaporkan error `There are multiple heroes that share the same tag within a subtree`. Karena itu tag harus **unik di dalam satu halaman**, dan itulah alasan tag memakai nama item (`'ikon-${item.nama}'`), bukan teks tetap seperti `'ikon'`.

### 3. Apa keuntungan memakai `Theme.of(context)` dibanding menulis warna langsung pada widget?

- **Otomatis menyesuaikan:** widget ikut berubah saat mode gelap diaktifkan atau warna tema diganti, tanpa kode tambahan. Warna yang ditulis manual tidak ikut berubah (gejala di troubleshooting: "sebagian warna tidak ikut mode gelap").
- **Konsisten:** seluruh aplikasi memakai palet dan gaya teks yang sama.
- **Satu tempat perubahan:** mengganti identitas visual cukup di `ThemeData`, tidak perlu mencari dan mengubah ratusan nilai di banyak widget.
- **Kontras terjaga:** pasangan seperti `primaryContainer` dan `onPrimaryContainer` dirancang agar teks selalu terbaca di atas latarnya, di mode terang maupun gelap.
- **Kode lebih bersih dan mudah dirawat,** karena widget menyatakan *peran* ("warna utama", "judul sedang"), bukan nilai konkret.

### 4. Apa perbedaan berpindah tab dengan `IndexedStack` dan membuka halaman dengan `Navigator`?

| | `IndexedStack` (tab) | `Navigator` (halaman) |
|---|---|---|
| Hubungan antar halaman | Setara dan sejajar | Bertumpuk, halaman baru di atas yang lama |
| Cara berpindah | Mengubah `index` | `push` dan `pop` |
| State | Semua halaman tetap hidup, state terjaga | Halaman yang di-`pop` dihancurkan; yang di bawahnya tetap ada |
| Tombol kembali | Tidak ada | Ada |
| Cocok untuk | Menu utama (Beranda, Animasi, Pengaturan) | Alur lanjutan (daftar → detail) |

Pada aplikasi ini keduanya dipakai bersamaan: tab untuk menu utama, `Navigator` untuk membuka detail di atas tab. Karena itu halaman detail menutupi bar navigasi bawah.

### 5. Mengapa `AnimationController` wajib di-`dispose`?

`AnimationController` memegang **ticker**, yaitu pencatat waktu yang dipanggil setiap frame. Jika halaman ditutup tanpa `dispose()`:

- ticker tetap berjalan dan menyimpan referensi ke state yang sudah tidak dipakai, sehingga terjadi **kebocoran memori**;
- CPU dan baterai terbuang untuk animasi yang tidak lagi terlihat;
- Flutter dapat melaporkan error, misalnya "ticker masih aktif saat state di-dispose".

Karena itu `_putar.dispose()` dipanggil di method `dispose()` milik State, sebelum `super.dispose()`.

---

## 6. Troubleshooting yang Pernah Ditemui

| Masalah | Penyebab dan solusi |
|---|---|
| `Could not find a generator for route` | Nama rute salah ketik atau belum ditangani; tambahkan di `routes` / `onGenerateRoute`, atau pasang `onUnknownRoute` |
| Halaman detail tidak terbuka setelah Bagian D | Blok `onGenerateRoute` ikut terhapus saat mengganti `routes`; pasang kembali |
| Hero tidak beranimasi | Tag di kedua halaman berbeda, atau tidak unik dalam satu halaman |
| Tema tidak berubah saat saklar digeser | `MaterialApp` belum dibungkus `ListenableBuilder`, atau nilai diubah bukan lewat `.value` |
| Sebagian warna tidak ikut mode gelap | Warna ditulis manual; ganti dengan `Theme.of(context).colorScheme` |
| `AnimatedContainer` tidak beranimasi | Nilai diubah di luar `setState`, atau tipenya tidak sama |
| `AnimatedSwitcher` tidak beranimasi | Anak tidak punya `key` yang berbeda (pakai `ValueKey`) |
| Error `vsync` / `TickerProvider` | Tambahkan `with SingleTickerProviderStateMixin` |
| `MissingPluginException` | Aplikasi belum dijalankan ulang penuh setelah menambah paket |
| Tema kembali ke awal setelah aplikasi ditutup | Listener penyimpanan belum dipasang di `main()` |
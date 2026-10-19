import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================= TEMA =================
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

// ================= MAIN =================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final gelap = prefs.getBool('gelap') ?? false;
  final indeksWarna = prefs.getInt('warna') ?? 0;

  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  seedColor.value =
  pilihanWarna[indeksWarna.clamp(0, pilihanWarna.length - 1)];

  themeMode.addListener(() {
    prefs.setBool('gelap', themeMode.value == ThemeMode.dark);
  });
  seedColor.addListener(() {
    prefs.setInt(
      'warna',
      pilihanWarna.indexWhere((c) => c == seedColor.value),
    );
  });

  runApp(const MyApp());
}

// ================= DATA =================
class Tempat {
  final String id;
  final String nama;
  final String lokasi;
  final String deskripsi;
  final IconData ikon;
  final Color warna;
  final double rating;

  const Tempat({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
    required this.rating,
  });
}

const daftarTempat = [
  Tempat(
    id: 'bromo',
    nama: 'Gunung Bromo',
    lokasi: 'Jawa Timur',
    deskripsi:
    'Gunung berapi aktif dengan lautan pasir dan pemandangan matahari '
        'terbit yang terkenal. Cocok didaki dini hari.',
    ikon: Icons.landscape,
    warna: Colors.orange,
    rating: 4.8,
  ),
  Tempat(
    id: 'borobudur',
    nama: 'Candi Borobudur',
    lokasi: 'Jawa Tengah',
    deskripsi:
    'Candi Buddha terbesar di dunia dari abad ke-9, warisan dunia '
        'UNESCO dengan ribuan relief dan stupa.',
    ikon: Icons.account_balance,
    warna: Colors.brown,
    rating: 4.9,
  ),
  Tempat(
    id: 'raja_ampat',
    nama: 'Raja Ampat',
    lokasi: 'Papua Barat Daya',
    deskripsi:
    'Gugusan pulau dengan terumbu karang dan keanekaragaman laut '
        'tertinggi di dunia. Surga bagi penyelam.',
    ikon: Icons.waves,
    warna: Colors.blue,
    rating: 4.9,
  ),
  Tempat(
    id: 'komodo',
    nama: 'Pulau Komodo',
    lokasi: 'Nusa Tenggara Timur',
    deskripsi:
    'Habitat asli komodo, kadal terbesar di dunia, dengan pantai '
        'berpasir merah muda yang langka.',
    ikon: Icons.pets,
    warna: Colors.green,
    rating: 4.7,
  ),
  Tempat(
    id: 'danau_toba',
    nama: 'Danau Toba',
    lokasi: 'Sumatera Utara',
    deskripsi:
    'Danau vulkanik terbesar di Asia Tenggara dengan Pulau Samosir '
        'di tengahnya dan budaya Batak yang kaya.',
    ikon: Icons.water,
    warna: Colors.teal,
    rating: 4.6,
  ),
  Tempat(
    id: 'ubud',
    nama: 'Ubud',
    lokasi: 'Bali',
    deskripsi:
    'Pusat seni dan budaya Bali dengan sawah terasering, hutan monyet, '
        'dan pasar kerajinan tradisional.',
    ikon: Icons.park,
    warna: Colors.pink,
    rating: 4.8,
  ),
];

// ================= APLIKASI =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Galeri Wisata',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (_) => const ShellPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final tempat = settings.arguments as Tempat;
              return PageRouteBuilder(
                settings: settings,
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return DetailPage(tempat: tempat);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            }
            return null;
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => HalamanTidakDitemukan(namaRute: settings.name),
            );
          },
        );
      },
    );
  }
}

// ================= SHELL (3 TAB) =================
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [GaleriTab(), FavoritTab(), PengaturanTab()];
  static const _judul = ['Galeri Wisata', 'Favorit', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Galeri',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ================= TAB 1: GALERI =================
class GaleriTab extends StatelessWidget {
  const GaleriTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: daftarTempat.length,
      itemBuilder: (context, i) => KartuTempat(tempat: daftarTempat[i]),
    );
  }
}

class KartuTempat extends StatelessWidget {
  final Tempat tempat;
  const KartuTempat({super.key, required this.tempat});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: tempat);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'tempat-${tempat.id}',
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: tempat.warna,
                  child: Icon(tempat.ikon, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tempat.nama,
                style: tema.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(tempat.lokasi, style: tema.textTheme.bodySmall),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: tema.colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text('${tempat.rating}', style: tema.textTheme.labelLarge),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= TAB 2: FAVORIT (sementara) =================
class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Favorit dikerjakan di Tahap 2',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

// ================= TAB 3: PENGATURAN =================
class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Warna tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () => seedColor.value = c,
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ================= DETAIL =================
class DetailPage extends StatelessWidget {
  final Tempat tempat;
  const DetailPage({super.key, required this.tempat});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(tempat.nama)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Hero(
              tag: 'tempat-${tempat.id}',
              child: CircleAvatar(
                radius: 72,
                backgroundColor: tempat.warna,
                child: Icon(tempat.ikon, size: 72, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(tempat.nama, style: tema.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.place, size: 18, color: warna.primary),
                const SizedBox(width: 4),
                Text(tempat.lokasi, style: tema.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 18, color: warna.tertiary),
                const SizedBox(width: 4),
                Text('${tempat.rating}', style: tema.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              tempat.deskripsi,
              style: tema.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 404 =================
class HalamanTidakDitemukan extends StatelessWidget {
  final String? namaRute;
  const HalamanTidakDitemukan({super.key, this.namaRute});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 96, color: tema.colorScheme.error),
              const SizedBox(height: 16),
              Text('404', style: tema.textTheme.displayLarge),
              Text('Halaman tidak ditemukan',
                  style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Rute "$namaRute" tidak terdaftar.',
                  style: tema.textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
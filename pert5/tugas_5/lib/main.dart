// Tugas Pertemuan 5 - Aplikasi Pencatat Pengeluaran
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

// ============================================================
// KONSTANTA DAN PEMBANTU
// ============================================================
const List<String> kDaftarKategori = [
  'Makanan', 'Transportasi', 'Belanja', 'Hiburan', 'Tagihan', 'Lainnya',
];
const String kSemua = 'Semua'; // nilai filter "tanpa filter"
/// 15000 -> "Rp 15.000"
String rupiah(int n) {
  final s = n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
  );
  return 'Rp $s';
}
String _dua(int n) => n.toString().padLeft(2, '0');
/// DateTime -> "2026-10-13" (disimpan di database)
String keIso(DateTime d) => '${d.year}-${_dua(d.month)}-${_dua(d.day)}';
/// "2026-10-13" -> "13/10/2026" (ditampilkan ke pengguna)
String tampilTanggal(String iso) {
  final b = iso.split('-');
  if (b.length != 3) return iso;
  return '${b[2]}/${b[1]}/${b[0]}';
}

// ============================================================
// MODEL
// ============================================================
class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal; // format yyyy-MM-dd
  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });
  Map<String, Object?> toMap() => {
    'id': id,
    'nama': nama,
    'jumlah': jumlah,
    'kategori': kategori,
    'tanggal': tanggal,
  };
  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
    id: m['id'] as int,
    nama: m['nama'] as String,
    jumlah: m['jumlah'] as int,
    kategori: m['kategori'] as String,
    tanggal: m['tanggal'] as String,
  );
}

// ============================================================
// AKSES DATA (SQLite)
// ============================================================
class DbHelper {
  static Database? _db;
  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'pengeluaran.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'nama TEXT NOT NULL, '
              'jumlah INTEGER NOT NULL, '
              'kategori TEXT NOT NULL, '
              'tanggal TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }
  // Create
  static Future<int> tambah(Pengeluaran x) async {
    final db = await database;
    return db.insert('pengeluaran', x.toMap());
  }
  // Read (dengan filter kategori opsional)
  static Future<List<Pengeluaran>> semua({String kategori = kSemua}) async {
    final db = await database;
    final semuaKategori = kategori == kSemua;
    final rows = await db.query(
      'pengeluaran',
      where: semuaKategori ? null : 'kategori = ?',
      whereArgs: semuaKategori ? null : [kategori],
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Pengeluaran.fromMap).toList();
  }
  // Total memakai SELECT SUM(jumlah)
  static Future<int> total({String kategori = kSemua}) async {
    final db = await database;
    final semuaKategori = kategori == kSemua;
    final hasil = await db.rawQuery(
      semuaKategori
          ? 'SELECT SUM(jumlah) AS total FROM pengeluaran'
          : 'SELECT SUM(jumlah) AS total FROM pengeluaran WHERE kategori = ?',
      semuaKategori ? null : [kategori],
    );
    return (hasil.first['total'] as int?) ?? 0; // null bila tabel kosong
  }
  // Update
  static Future<int> ubah(Pengeluaran x) async {
    final db = await database;
    return db.update(
      'pengeluaran',
      x.toMap(),
      where: 'id = ?',
      whereArgs: [x.id],
    );
  }
  // Delete
  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }
}

// ============================================================
// PENGATURAN (shared_preferences): filter kategori terakhir
// ============================================================
class Pengaturan {
  static const _kunciFilter = 'filterKategori';
  static Future<String> bacaFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final nilai = prefs.getString(_kunciFilter) ?? kSemua;
    // Jaga-jaga bila nilai tersimpan tidak lagi ada di daftar kategori.
    return (nilai == kSemua || kDaftarKategori.contains(nilai))
        ? nilai
        : kSemua;
  }
  static Future<void> simpanFilter(String nilai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunciFilter, nilai);
  }
}

// ============================================================
// UI
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const DaftarPage(),
    );
  }
}
/// Hasil gabungan untuk halaman utama: daftar + total.
class _Ringkasan {
  final List<Pengeluaran> daftar;
  final int total;
  const _Ringkasan(this.daftar, this.total);
}

// ---------------- Halaman utama ----------------
class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});
  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  late Future<_Ringkasan> _future;
  String _filter = kSemua;
  @override
  void initState() {
    super.initState();
    _future = _ambil();
  }

  // Baca filter terakhir dari shared_preferences, lalu ambil data dari SQLite.
  Future<_Ringkasan> _ambil() async {
    final filter = await Pengaturan.bacaFilter();
    if (mounted && filter != _filter) {
      setState(() => _filter = filter);
    }
    final daftar = await DbHelper.semua(kategori: filter);
    final total = await DbHelper.total(kategori: filter);
    return _Ringkasan(daftar, total);
  }

  void _muat() {
    setState(() {
      _future = _ambil();
    });
  }

  Future<void> _ubahFilter(String? nilai) async {
    if (nilai == null) return;
    await Pengaturan.simpanFilter(nilai);
    if (!mounted) return;
    setState(() => _filter = nilai);
    _muat();
  }

  Future<void> _buka([Pengeluaran? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPage(item: item)),
    );
    if (!mounted) return;
    _muat();
  }

  Future<void> _konfirmasiHapus(Pengeluaran x) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pengeluaran ini?'),
        content: Text('${x.nama} (${rupiah(x.jumlah)})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya != true) return;
    await DbHelper.hapus(x.id!);
    if (!mounted) return;
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencatat Pengeluaran')),
      body: FutureBuilder<_Ringkasan>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Terjadi kesalahan:\n${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muat,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = snapshot.data!;
          return Column(
            children: [
              // Kartu total pengeluaran
              Card(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _filter == kSemua
                                  ? 'Total pengeluaran'
                                  : 'Total ($_filter)',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rupiah(data.total),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Filter kategori (disimpan di shared_preferences)
                      DropdownButton<String>(
                        value: _filter,
                        items: [kSemua, ...kDaftarKategori]
                            .map((k) =>
                            DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: _ubahFilter,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: data.daftar.isEmpty
                    ? Center(
                  child: Text(
                    _filter == kSemua
                        ? 'Belum ada pengeluaran'
                        : 'Tidak ada pengeluaran kategori $_filter',
                  ),
                )
                    : ListView.builder(
                  itemCount: data.daftar.length,
                  itemBuilder: (context, i) {
                    final x = data.daftar[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(x.kategori[0]),
                      ),
                      title: Text(x.nama),
                      subtitle: Text(
                        '${x.kategori} - ${tampilTanggal(x.tanggal)}',
                      ),
                      onTap: () => _buka(x),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rupiah(x.jumlah),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _konfirmasiHapus(x),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------- Form tambah dan ubah ----------------
class FormPage extends StatefulWidget {
  final Pengeluaran? item;
  const FormPage({super.key, this.item});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  late final TextEditingController _tanggalCtrl;
  String? _kategori;
  late DateTime _tanggal;
  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nama = TextEditingController(text: item?.nama ?? '');
    _jumlah = TextEditingController(text: item?.jumlah.toString() ?? '');
    _kategori = item?.kategori;
    _tanggal = item != null ? DateTime.parse(item.tanggal) : DateTime.now();
    _tanggalCtrl = TextEditingController(text: tampilTanggal(keIso(_tanggal)));
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    _tanggalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (hasil == null) return;
    setState(() {
      _tanggal = hasil;
      _tanggalCtrl.text = tampilTanggal(keIso(hasil));
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final x = Pengeluaran(
      id: widget.item?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategori!,
      tanggal: keIso(_tanggal),
    );
    if (widget.item == null) {
      await DbHelper.tambah(x);
    } else {
      await DbHelper.ubah(x);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.item == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama: wajib diisi
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Jumlah: angka lebih dari 0
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final angka = int.tryParse((v ?? '').trim());
                if (angka == null || angka <= 0) {
                  return 'Jumlah harus angka lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Kategori: dropdown, wajib dipilih
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: kDaftarKategori
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 12),

            // Tanggal: dipilih lewat date picker
            TextFormField(
              controller: _tanggalCtrl,
              readOnly: true,
              onTap: _pilihTanggal,
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
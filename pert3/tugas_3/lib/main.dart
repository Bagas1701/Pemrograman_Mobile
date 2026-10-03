import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MODEL: satu barang belanja
class Barang {
  String nama;
  int jumlah;
  String kategori;
  bool sudahDibeli;
  Barang(this.nama, this.jumlah, this.kategori, {this.sudahDibeli = false});
}

// STATE BERSAMA
class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);
  int get jumlahBelumDibeli => _items.where((b) => !b.sudahDibeli).length;

  void tambah(String nama, int jumlah, String kategori) {
    _items.add(Barang(nama, jumlah, kategori));
    notifyListeners();
  }

  void toggle(int index) {
    _items[index].sudahDibeli = !_items[index].sudahDibeli;
    notifyListeners();
  }

  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Belanja',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const BelanjaPage(),
    );
  }
}

// HALAMAN DAFTAR
class BelanjaPage extends StatelessWidget {
  const BelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();
    return Scaffold(
      appBar: AppBar(
        // AppBar menampilkan jumlah barang yang belum dibeli
        title: Text('Belanja (${model.jumlahBelumDibeli} belum dibeli)'),
      ),
      body: model.items.isEmpty
          ? const Center(child: Text('Belum ada barang'))
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, i) {
          final b = model.items[i];
          return ListTile(
            leading: Checkbox(
              value: b.sudahDibeli,
              onChanged: (_) => context.read<BelanjaModel>().toggle(i),
            ),
            title: Text(
              b.nama,
              style: TextStyle(
                decoration:
                b.sudahDibeli ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text('${b.jumlah} - ${b.kategori}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => context.read<BelanjaModel>().hapus(i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahBarangPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// HALAMAN FORM TAMBAH
class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _jumlah = TextEditingController();
  String? _kategori;

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      context.read<BelanjaModel>().tambah(
        _nama.text.trim(),
        int.parse(_jumlah.text), // aman, sudah divalidasi
        _kategori!,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama barang (wajib)
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama barang',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Jumlah (wajib, angka lebih dari 0)
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Jumlah wajib diisi';
                final angka = int.tryParse(v.trim());
                if (angka == null) return 'Jumlah harus berupa angka';
                if (angka <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Kategori (dropdown)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Pakaian', child: Text('Pakaian')),
                DropdownMenuItem(value: 'Elektronik', child: Text('Elektronik')),
                DropdownMenuItem(value: 'Kebutuhan Rumah', child: Text('Kebutuhan Rumah')),
              ],
              onChanged: (v) => setState(() => _kategori = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 16),

            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
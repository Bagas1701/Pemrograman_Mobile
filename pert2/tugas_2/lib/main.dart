import 'package:flutter/material.dart';

// 1. Model data
class Kontak {
  final String nama;
  final String telepon;
  final String email;
  const Kontak(this.nama, this.telepon, this.email);
}

// 2. Daftar kontak (minimal 6)
const daftarKontak = [
  Kontak('Fitra Pratama', '081234567890', 'fitra@gmail.com'),
  Kontak('Raja Santoso', '082345678901', 'raja@gmail.com'),
  Kontak('Dwi Lestari', '083456789012', 'dwi@gmail.com'),
  Kontak('Andin Anggraini', '084567890123', 'andin@gmail.com'),
  Kontak('Eko Cahyono', '085678901234', 'eko@gmail.com'),
  Kontak('Hanif Handayani', '086789012345', 'hanif@gmail.com'),
];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const KontakPage(),
    );
  }
}

// 3. Halaman utama: daftar kontak
class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final item = daftarKontak[index];
          return ListTile(
            // avatar berisi huruf pertama nama
            leading: CircleAvatar(child: Text(item.nama[0])),
            title: Text(item.nama),
            subtitle: Text(item.telepon),
            trailing: const Icon(Icons.chevron_right),
            // ketuk kontak -> buka halaman detail
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(kontak: item)),
              );
            },
          );
        },
      ),
    );
  }
}

// 4. Halaman detail: tampilkan semua data kontak
class DetailPage extends StatelessWidget {
  final Kontak kontak;
  const DetailPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kontak.nama)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(kontak.nama[0], style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 16),
            Text(kontak.nama, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text('Telepon: ${kontak.telepon}'),
            Text('Email: ${kontak.email}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
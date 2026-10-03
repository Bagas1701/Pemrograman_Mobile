import 'package:flutter/material.dart';
class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;
  const Makanan(this.nama, this.harga, this.deskripsi);
}
const daftarMenu = [
  Makanan('Nasi Goreng', 15000, 'Nasi goreng dengan telur dan ayam suwir.'),
  Makanan('Mie Ayam', 12000, 'Mie dengan topping ayam dan sawi.'),
  Makanan('Es Teh', 4000, 'Teh manis dingin yang menyegarkan.'),
  Makanan('Ayam Bakar', 20000, 'Ayam bakar dengan bumbu kecap manis.'),
  Makanan('Sate Ayam', 18000, 'Sepuluh tusuk sate dengan bumbu kacang.'),
  Makanan('Bakso', 13000, 'Bakso sapi dengan kuah kaldu hangat.'),
  Makanan('Jus Jeruk', 8000, 'Jus jeruk segar tanpa pengawet.'),
];

// fungsi format ribuan
String formatHarga(int harga) {
  String angka = harga.toString();
  String hasil = '';

  for (int i = angka.length - 1; i >= 0; i--) {
    hasil = angka[i] + hasil;

    if ((angka.length - i) % 3 == 0 && i != 0) {
      hasil = '.$hasil';
    }
  }

  return 'Rp $hasil';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Praktikum 2',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const MenuPage(),
      );
    }
  }

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];
          // return Card(
          //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(item.nama),
              // subtitle: Text('Rp ${item.harga}'),
              subtitle: Text(formatHarga(item.harga)),
              trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(makanan: item)),
                  );
                }
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Makanan makanan;
  const DetailPage({super.key, required this.makanan});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(makanan.nama)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80),
            const SizedBox(height: 16),
            Text(makanan.nama, style: const TextStyle(fontSize: 24)),
            // Text('Rp ${makanan.harga}'),
            Text(formatHarga(makanan.harga)),
            const SizedBox(height: 8),
            Text(makanan.deskripsi), // untuk menampilkan deskripsi di detailpage
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bagas Yoas Sibagariang',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('20230801254'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
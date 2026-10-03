import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartu Perkenalan',
      home: Scaffold(
        appBar: AppBar(title: const Text('Kartu Perkenalan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.account_circle, size: 120, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Bagas Yoas Sibagariang',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 8),
              Text('NIM: 20230802254'),
              SizedBox(height: 8),
              Text('Jurusan: Teknik Informatika'),
              SizedBox(height: 8),
              Text('Hobi: Bermain game'),
            ],
          ),
        ),
      ),
    );
  }
}
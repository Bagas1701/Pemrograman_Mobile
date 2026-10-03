import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: const CounterPage(),
      // home: Scaffold(
      //   appBar: AppBar(title: const Text('Hello Flutter')),
      //     body: Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: const [
      //           Icon(Icons.flutter_dash, size: 80, color: Colors.blue),
      //           SizedBox(height: 16),
      //           Text('Halo, nama saya Bagas Yoas Sibagariang!', style: TextStyle(fontSize: 24)),
      //           Text('NIM: 20230802254'),
      //         ],
      //       ),
      //     ),
      // ),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}
class _CounterPageState extends State<CounterPage> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(title: const Text('Bagas Yoas Sibagariang', style: TextStyle(color: Colors.teal),
      ),
          backgroundColor: Colors.deepOrange,),
      body: Center(
        child: Text('$_count', style: const TextStyle(fontSize: 48, color: Colors.deepOrange),),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => setState(() => _count++),
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
            heroTag: 'add',
            onPressed: () => setState(() => _count++),
            child: const Icon(Icons.add),
          ),
            FloatingActionButton(
            heroTag: 'remove',
            onPressed: () {
              if (_count > 0) {
                setState(() => _count--);
              }
            },
            child: const Icon(Icons.remove),
          ),
            FloatingActionButton(
              heroTag: 'reset',
              onPressed: () => setState(() => _count = 0),
              child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
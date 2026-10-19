import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

// ============================================================
// MODEL
// ============================================================

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class Komentar {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  const Komentar({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      id: json['id'] as int,
      postId: json['postId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

// ============================================================
// LAYANAN (kode pengambil data, terpisah dari UI)
// ============================================================

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<dynamic>> _getList(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (kode ${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<List<Post>> ambilPosts() async {
    final data = await _getList('/posts');
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Komentar>> ambilKomentar(int postId) async {
    final data = await _getList('/posts/$postId/comments');
    return data
        .map((e) => Komentar.fromJson(e as Map<String, dynamic>))
        .toList();
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
      title: 'Daftar Postingan',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PostListPage(),
    );
  }
}

/// Widget tampilan galat yang dipakai di kedua halaman.
class TampilanError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const TampilanError({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan:\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Halaman utama: daftar postingan ----------------

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = PostService.ambilPosts();
  }

  void _muatUlang() {
    setState(() {
      _future = PostService.ambilPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return TampilanError(error: snapshot.error, onRetry: _muatUlang);
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = data[i];
              return ListTile(
                title: Text(
                  p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  p.body.replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: p),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- Halaman detail: isi lengkap + komentar ----------------

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();
    _futureKomentar = PostService.ambilKomentar(widget.post.id);
  }

  void _muatUlang() {
    setState(() {
      _futureKomentar = PostService.ambilKomentar(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text('Postingan #${post.id}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<List<Komentar>>(
        future: _futureKomentar,
        builder: (context, snapshot) {
          // Bagian isi postingan selalu tampil di atas.
          final header = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(post.body),
                const SizedBox(height: 16),
                const Divider(),
                Text(
                  snapshot.hasData
                      ? 'Komentar (${snapshot.data!.length})'
                      : 'Komentar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );

          Widget isiKomentar;
          if (snapshot.connectionState == ConnectionState.waiting) {
            isiKomentar = const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            isiKomentar = TampilanError(
              error: snapshot.error,
              onRetry: _muatUlang,
            );
          } else if (snapshot.data!.isEmpty) {
            isiKomentar = const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Belum ada komentar')),
            );
          } else {
            isiKomentar = Column(
              children: snapshot.data!
                  .map(
                    (k) => ListTile(
                  leading: CircleAvatar(child: Text(k.name[0].toUpperCase())),
                  title: Text(k.name),
                  subtitle: Text('${k.email}\n${k.body}'),
                  isThreeLine: true,
                ),
              )
                  .toList(),
            );
          }

          return ListView(children: [header, isiKomentar]);
        },
      ),
    );
  }
}
// Latihan 1 — Permintaan HTTP Pertama dan Membaca JSON Mentah
// Jalankan: flutter run -t lib/latihan1.dart

import 'dart:convert';                        // untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;      // package yang baru ditambahkan

import 'tema.dart';

/// Endpoint daftar resep kategori Seafood.
const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaAplikasi,
      home: const HalamanUjiApi(),
    );
  }
}

class HalamanUjiApi extends StatefulWidget {
  const HalamanUjiApi({super.key});

  @override
  State<HalamanUjiApi> createState() => _HalamanUjiApiState();
}

class _HalamanUjiApiState extends State<HalamanUjiApi> {
  bool sedangMemuat = true;
  String pesan = '';

  @override
  void initState() {
    super.initState();
    ambilData();   // dijalankan sekali saat halaman pertama kali dibuat
  }

  Future<void> ambilData() async {
    setState(() {
      sedangMemuat = true;
      pesan = '';
    });

    String hasil;
    try {
      final response = await http.get(Uri.parse(urlDaftar));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // 'meals' bisa bernilai null jika kategori tidak punya data.
        final daftar = (data['meals'] as List<dynamic>?) ?? const [];
        final contoh = daftar.isEmpty ? '(tidak ada data)' : '${daftar.first}';

        hasil = 'Status code : ${response.statusCode}\n'
            'Panjang body: ${response.body.length} karakter\n'
            'Jumlah item : ${daftar.length}\n'
            'Tipe data   : ${daftar.runtimeType}\n\n'
            'Isi item pertama (JSON mentah):\n\n$contoh';
      } else {
        hasil = 'Server membalas dengan status ${response.statusCode}.';
      }
    } catch (e) {
      hasil = 'Gagal terhubung ke server.\n\n$e';
    }

    if (!mounted) return;   // halaman mungkin sudah ditutup saat data tiba
    setState(() {
      pesan = hasil;
      sedangMemuat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan 1 - Uji API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        pesan,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: ambilData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Ambil Lagi'),
                  ),
                ],
              ),
      ),
    );
  }
}

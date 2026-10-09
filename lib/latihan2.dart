// Latihan 2 — Model Class + ListView.builder Berisi Data dari API
// Jalankan: flutter run -t lib/latihan2.dart
//
// Sudah termasuk tugas mahasiswa yang berupa perubahan kode:
//   - Tugas 2: field `kategori` (key JSON `strCategory`)
//   - Tugas 3: jumlah item pada judul AppBar
//   - Tugas 6: RefreshIndicator yang membungkus ListView

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'tema.dart';

const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

// ---------------- MODEL ----------------
class Meal {
  final String id;
  final String nama;
  final String gambar;
  final String area;
  final String kategori; // Tugas 2

  const Meal({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.area,
    required this.kategori,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String? ?? '',
      nama: json['strMeal'] as String? ?? 'Tanpa Nama',
      gambar: json['strMealThumb'] as String? ?? '',
      area: json['strArea'] as String? ?? 'Internasional',
      // filter.php tidak mengirim strCategory, jadi nilai ini selalu
      // jatuh ke default. Hanya lookup.php yang menyediakannya (Latihan 4).
      kategori: json['strCategory'] as String? ?? '(tidak tersedia)',
    );
  }
}

// ---------------- LAYANAN API ----------------
/// Mengambil data dari server dan mengubahnya menjadi `List<Meal>`.
/// Melempar Exception jika server tidak membalas status 200.
Future<List<Meal>> ambilDaftarMeal() async {
  final response = await http.get(Uri.parse(urlDaftar));

  if (response.statusCode != 200) {
    throw Exception('Server membalas status ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final daftar = (data['meals'] as List<dynamic>?) ?? const [];

  return daftar
      .map((item) => Meal.fromJson(item as Map<String, dynamic>))
      .toList();
}

// ---------------- TAMPILAN ----------------
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaAplikasi,
      home: const HalamanKatalog(),
    );
  }
}

class HalamanKatalog extends StatefulWidget {
  const HalamanKatalog({super.key});

  @override
  State<HalamanKatalog> createState() => _HalamanKatalogState();
}

class _HalamanKatalogState extends State<HalamanKatalog> {
  bool sedangMemuat = true;
  String pesanError = '';
  List<Meal> daftarMeal = [];

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    setState(() {
      sedangMemuat = true;
      pesanError = '';
    });

    try {
      final hasil = await ambilDaftarMeal();
      if (!mounted) return;
      setState(() {
        daftarMeal = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        pesanError = e.toString();
        sedangMemuat = false;
      });
    }
  }

  Widget _gambarMenu(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 64,
            height: 64,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tugas 3: tampilkan jumlah item setelah data termuat
        title: Text(
          sedangMemuat || pesanError.isNotEmpty
              ? 'Katalog Resep'
              : 'Katalog Resep (${daftarMeal.length})',
        ),
      ),
      body: sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : pesanError.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pesanError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: muatData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              // Tugas 6: tarik ke bawah untuk memuat ulang
              : RefreshIndicator(
                  onRefresh: muatData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: daftarMeal.length,
                    itemBuilder: (context, index) {
                      final meal = daftarMeal[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: _gambarMenu(meal.gambar),
                          title: Text(
                            meal.nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${meal.area} • ${meal.kategori}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('idMeal: ${meal.id}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

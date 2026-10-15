// Latihan 3 — Merapikan dengan FutureBuilder
// Jalankan: flutter run -t lib/latihan3.dart
//
// Model, layanan API, dan tampilan daftar sama seperti Latihan 2.
// Yang berubah hanya _HalamanKatalogState: loading, error, dan data
// sekarang ditangani oleh satu widget FutureBuilder.
//
// Perbandingan dengan Latihan 2:
//   Latihan 2 → 3 variabel state (sedangMemuat, pesanError, daftarMeal),
//               try/catch, dan cek `mounted` ditulis sendiri.
//   Latihan 3 → cukup 1 variabel (futureMeal). FutureBuilder memantau
//               Future tersebut dan membangun ulang tampilan otomatis
//               setiap kali statusnya berubah.

import 'dart:convert';                    // jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // permintaan HTTP

import 'tema.dart';

/// Endpoint daftar resep kategori Seafood.
const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

// ---------------- MODEL ----------------
/// Representasi satu resep dari respons filter.php.
class Meal {
  final String id;      // idMeal
  final String nama;    // strMeal
  final String gambar;  // strMealThumb (URL gambar)
  final String area;    // strArea

  const Meal({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.area,
  });

  /// Membuat Meal dari Map JSON; key yang tidak ada diganti nilai default.
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String? ?? '',
      nama: json['strMeal'] as String? ?? 'Tanpa Nama',
      gambar: json['strMealThumb'] as String? ?? '',
      area: json['strArea'] as String? ?? 'Internasional',
    );
  }
}

// ---------------- LAYANAN API ----------------
/// Mengambil daftar resep dan mengubahnya menjadi `List<Meal>`.
/// Exception yang dilempar di sini akan ditangkap otomatis oleh
/// FutureBuilder dan muncul sebagai `snapshot.hasError`.
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

/// Widget akar: mengatur tema dan halaman pertama.
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

/// Halaman katalog resep versi FutureBuilder.
class HalamanKatalog extends StatefulWidget {
  const HalamanKatalog({super.key});

  @override
  State<HalamanKatalog> createState() => _HalamanKatalogState();
}

class _HalamanKatalogState extends State<HalamanKatalog> {
  // Future disimpan di variabel, BUKAN dibuat langsung di dalam build().
  // Jika ditulis `future: ambilDaftarMeal()` di build(), setiap kali
  // build() dipanggil ulang (misalnya saat setState atau layar diputar)
  // permintaan HTTP baru akan terkirim dan loading muncul terus-menerus.
  // `late` = variabel pasti diisi sebelum dipakai (diisi di initState).
  late Future<List<Meal>> futureMeal;

  @override
  void initState() {
    super.initState();
    futureMeal = ambilDaftarMeal(); // permintaan dikirim sekali saja
  }

  /// Dipanggil oleh tombol refresh, tombol Coba Lagi, dan tarik-ke-bawah.
  void muatUlang() {
    setState(() {
      futureMeal = ambilDaftarMeal(); // permintaan baru → FutureBuilder membangun ulang
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Resep (FutureBuilder)'),
        actions: [
          // Tombol refresh di pojok kanan AppBar.
          IconButton(
            onPressed: muatUlang,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      // FutureBuilder memantau `futureMeal`. Fungsi builder dipanggil ulang
      // setiap status Future berubah; `snapshot` berisi status terbarunya:
      //   snapshot.connectionState → waiting / done
      //   snapshot.hasError / snapshot.error → jika Future gagal
      //   snapshot.data → hasil List<Meal> jika berhasil
      body: FutureBuilder<List<Meal>>(
        future: futureMeal,
        builder: (context, snapshot) {
          // ---- Keadaan 1: masih menunggu ----
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---- Keadaan 2: gagal ----
          // Terjadi jika ambilDaftarMeal() melempar Exception
          // (status bukan 200, tidak ada internet, dsb.).
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat data',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',   // isi pesan Exception
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ---- Keadaan 3: berhasil ----
          // snapshot.data bertipe List<Meal>? (bisa null), jadi diberi
          // cadangan list kosong dengan ??.
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Tidak ada data untuk kategori ini.'));
          }

          // Tarik ke bawah untuk memuat ulang. onRefresh membutuhkan fungsi
          // yang mengembalikan Future, maka muatUlang() dibungkus `async`.
          return RefreshIndicator(
            onRefresh: () async => muatUlang(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final meal = daftar[index];

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
                    // Gambar resep dengan sudut membulat.
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.gambar,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        // Ikon pengganti jika gambar gagal dimuat.
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(
                      meal.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(meal.area),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

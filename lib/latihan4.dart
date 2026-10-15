// Latihan 4 — Proyek Mini: Katalog + Detail dari Dua Endpoint
// Jalankan: flutter run -t lib/latihan4.dart
//
// Tujuan latihan:
//   1. Halaman 1 (katalog) mengambil daftar resep dari filter.php.
//   2. Saat satu resep diketuk, hanya idMeal yang dikirim ke halaman 2.
//   3. Halaman 2 (detail) memakai idMeal itu untuk meminta data lengkap
//      ke endpoint kedua, lookup.php.
//
// Kode dipisah per tanggung jawab (Tugas 7):
//   lib/models/meal.dart            → model + fromJson
//   lib/services/meal_service.dart  → endpoint + pemanggilan API
//   lib/widgets/tampilan_error.dart → tampilan gagal + tombol Coba Lagi
//   lib/pages/halaman_katalog.dart  → halaman 1 (filter.php)
//   lib/pages/halaman_detail.dart   → halaman 2 (lookup.php)
//
// File ini hanya berisi titik awal aplikasi (main + MyApp).
import 'package:flutter/material.dart';

import 'pages/halaman_katalog.dart';   // halaman pertama yang dibuka
import 'tema.dart';                    // tema warna aplikasi

void main() => runApp(const MyApp());

/// Widget akar: mengatur tema dan menjadikan HalamanKatalog sebagai
/// halaman awal. Perpindahan ke HalamanDetail diatur di halaman katalog.
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

// Latihan 4 — Proyek Mini: Katalog + Detail dari Dua Endpoint
// Jalankan: flutter run -t lib/latihan4.dart
//
// Kode dipisah per tanggung jawab (Tugas 7):
//   lib/models/meal.dart            → model + fromJson
//   lib/services/meal_service.dart  → endpoint + pemanggilan API
//   lib/widgets/tampilan_error.dart → tampilan gagal + tombol Coba Lagi
//   lib/pages/halaman_katalog.dart  → halaman 1 (filter.php)
//   lib/pages/halaman_detail.dart   → halaman 2 (lookup.php)
import 'package:flutter/material.dart';

import 'pages/halaman_katalog.dart';
import 'tema.dart';

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

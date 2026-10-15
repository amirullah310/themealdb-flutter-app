// Layanan API: semua alamat endpoint dan pemanggilan HTTP dikumpulkan di
// sini, sehingga halaman (UI) cukup memanggil fungsi tanpa perlu tahu URL
// maupun cara mengurai JSON.
import 'dart:convert';                    // jsonDecode
import 'package:http/http.dart' as http;  // permintaan HTTP

import '../models/meal.dart';

// ---------------- ENDPOINT ----------------
/// Endpoint 1: daftar resep kategori Seafood (dipakai halaman katalog).
const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

/// Endpoint 2: detail lengkap satu resep berdasarkan idMeal
/// (dipakai halaman detail). Berupa fungsi karena URL-nya bergantung id.
String urlDetail(String idMeal) =>
    'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal';

// ---------------- LAYANAN API ----------------
/// Mengambil daftar resep dan mengubahnya menjadi `List<Meal>`.
/// Melempar Exception jika status bukan 200; FutureBuilder di halaman
/// katalog akan menampilkannya sebagai error.
Future<List<Meal>> ambilDaftarMeal() async {
  final response = await http.get(Uri.parse(urlDaftar));

  if (response.statusCode != 200) {
    throw Exception('Server membalas status ${response.statusCode}');
  }

  // String JSON → Map → array 'meals' (bisa null jika tidak ada data).
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final daftar = (data['meals'] as List<dynamic>?) ?? const [];

  // Setiap item Map diubah menjadi objek Meal.
  return daftar
      .map((item) => Meal.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Mengambil detail satu resep. lookup.php tetap membalas dalam bentuk
/// array 'meals', hanya saja isinya satu item, sehingga diambil `.first`.
Future<Meal> ambilDetailMeal(String idMeal) async {
  final response = await http.get(Uri.parse(urlDetail(idMeal)));

  if (response.statusCode != 200) {
    throw Exception('Server membalas status ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  // Untuk id yang tidak dikenal, server membalas {"meals": null}.
  // Tanpa pengecekan ini, akses .first akan membuat aplikasi berhenti.
  final daftar = data['meals'] as List<dynamic>?;
  if (daftar == null || daftar.isEmpty) {
    throw Exception('Detail resep tidak ditemukan');
  }

  return Meal.fromJson(daftar.first as Map<String, dynamic>);
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/meal.dart';

// ---------------- ENDPOINT ----------------
const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

String urlDetail(String idMeal) =>
    'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal';

// ---------------- LAYANAN API ----------------
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

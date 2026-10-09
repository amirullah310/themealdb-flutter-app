import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';
import '../widgets/tampilan_error.dart';
import 'halaman_detail.dart';

// ---------------- HALAMAN 1: KATALOG ----------------
class HalamanKatalog extends StatefulWidget {
  const HalamanKatalog({super.key});

  @override
  State<HalamanKatalog> createState() => _HalamanKatalogState();
}

class _HalamanKatalogState extends State<HalamanKatalog> {
  late Future<List<Meal>> futureMeal;

  @override
  void initState() {
    super.initState();
    futureMeal = ambilDaftarMeal();
  }

  void muatUlang() {
    setState(() {
      futureMeal = ambilDaftarMeal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Resep'),
        actions: [
          IconButton(
            onPressed: muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Meal>>(
        future: futureMeal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return TampilanError(
              pesan: snapshot.error.toString(),
              onCobaLagi: muatUlang,
            );
          }

          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Tidak ada resep untuk kategori ini.'));
          }

          return ListView.builder(
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
                  // Tugas 6: Hero dengan tag yang sama di halaman detail.
                  leading: Hero(
                    tag: 'gambar-${meal.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.gambar,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    meal.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Tugas 5: kategori ikut ditampilkan pada baris katalog.
                  subtitle: Text('${meal.area} • Kategori: ${meal.kategori}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Hanya mengirim ID (dan nama untuk judul), bukan seluruh objek Meal.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanDetail(
                          idMeal: meal.id,
                          nama: meal.nama,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

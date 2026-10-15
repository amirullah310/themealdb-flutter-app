import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';      // ambilDaftarMeal()
import '../widgets/tampilan_error.dart';     // tampilan gagal yang dipakai ulang
import 'halaman_detail.dart';                // tujuan navigasi saat item diketuk

// ---------------- HALAMAN 1: KATALOG ----------------
/// Menampilkan daftar resep dari endpoint filter.php memakai FutureBuilder.
class HalamanKatalog extends StatefulWidget {
  const HalamanKatalog({super.key});

  @override
  State<HalamanKatalog> createState() => _HalamanKatalogState();
}

class _HalamanKatalogState extends State<HalamanKatalog> {
  // Future disimpan di state (diisi di initState), bukan dibuat di build(),
  // agar permintaan tidak terkirim ulang setiap kali build() dipanggil.
  late Future<List<Meal>> futureMeal;

  @override
  void initState() {
    super.initState();
    futureMeal = ambilDaftarMeal();   // permintaan pertama
  }

  /// Mengganti Future dengan permintaan baru; setState membuat
  /// FutureBuilder kembali ke keadaan waiting lalu menampilkan hasil baru.
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
            onPressed: muatUlang,   // tombol refresh di AppBar
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Meal>>(
        future: futureMeal,
        builder: (context, snapshot) {
          // ---- Keadaan 1: masih menunggu respons ----
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---- Keadaan 2: gagal → widget TampilanError ----
          if (snapshot.hasError) {
            return TampilanError(
              pesan: snapshot.error.toString(),
              onCobaLagi: muatUlang,
            );
          }

          // ---- Keadaan 3: berhasil ----
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Tidak ada resep untuk kategori ini.'));
          }

          // Daftar resep; hanya baris yang terlihat yang dibangun.
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
                  // Tag harus unik per resep, maka memakai meal.id.
                  leading: Hero(
                    tag: 'gambar-${meal.id}',
                    child: ClipRRect(
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
                    // Data lengkap (instruksi, kategori, area) diambil sendiri
                    // oleh halaman detail dari endpoint lookup.php.
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

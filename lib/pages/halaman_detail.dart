import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';
import '../tema.dart';
import '../widgets/tampilan_error.dart';

// ---------------- HALAMAN 2: DETAIL ----------------
class HalamanDetail extends StatefulWidget {
  const HalamanDetail({super.key, required this.idMeal, required this.nama});

  final String idMeal; // data utama yang dikirim dari katalog
  final String nama;   // dipakai untuk judul AppBar sebelum data tiba

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  late Future<Meal> futureDetail;

  @override
  void initState() {
    super.initState();
    // Di dalam State, properti widget diakses lewat kata kunci 'widget'.
    futureDetail = ambilDetailMeal(widget.idMeal);
  }

  void muatUlang() {
    setState(() {
      futureDetail = ambilDetailMeal(widget.idMeal);
    });
  }

  // Tugas 6: saat halaman dibuka, URL gambar belum diketahui (data masih
  // diambil). Karena itu yang "terbang" selalu gambar kecil dari katalog,
  // lalu mendarat di area gambar besar halaman detail.
  Widget _pesawatHero(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final asal = direction == HeroFlightDirection.push
        ? fromHeroContext
        : toHeroContext;
    return (asal.widget as Hero).child;
  }

  Widget _areaGambar({required Widget child}) {
    return Hero(
      tag: 'gambar-${widget.idMeal}',
      flightShuttleBuilder: _pesawatHero,
      child: child,
    );
  }

  Widget _chip(IconData ikon, String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Palet.violet.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: Palet.violet),
          const SizedBox(width: 6),
          Text(
            teks,
            style: const TextStyle(
              fontSize: 12,
              color: Palet.violet,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nama, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<Meal>(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _areaGambar(
                  child: Container(height: 220, color: Colors.grey.shade200),
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return TampilanError(
              pesan: snapshot.error.toString(),
              onCobaLagi: muatUlang,
            );
          }

          final meal = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _areaGambar(
                  child: Image.network(
                    meal.gambar,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 56, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.nama,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(Icons.restaurant_menu, meal.kategori),
                          _chip(Icons.public, meal.area),
                          _chip(Icons.tag, meal.id),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Cara Membuat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal.instruksi,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 28),
                      // Tugas 4: tombol Simpan ke Favorit (belum disimpan permanen).
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${meal.nama} disimpan ke favorit'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Palet.violet,
                          side: const BorderSide(color: Palet.violet),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Simpan ke Favorit'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali ke Katalog'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

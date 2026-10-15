import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';      // ambilDetailMeal()
import '../tema.dart';                       // Palet warna untuk chip & tombol
import '../widgets/tampilan_error.dart';

// ---------------- HALAMAN 2: DETAIL ----------------
/// Menampilkan detail satu resep. Halaman ini hanya menerima idMeal dari
/// katalog, lalu mengambil data lengkapnya sendiri dari lookup.php.
class HalamanDetail extends StatefulWidget {
  const HalamanDetail({super.key, required this.idMeal, required this.nama});

  final String idMeal; // data utama yang dikirim dari katalog
  final String nama;   // dipakai untuk judul AppBar sebelum data tiba

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  // Satu resep, bukan List, karena lookup.php mengembalikan satu item.
  late Future<Meal> futureDetail;

  @override
  void initState() {
    super.initState();
    // Di dalam State, properti widget diakses lewat kata kunci 'widget'.
    futureDetail = ambilDetailMeal(widget.idMeal);
  }

  /// Dipanggil oleh tombol Coba Lagi di TampilanError.
  void muatUlang() {
    setState(() {
      futureDetail = ambilDetailMeal(widget.idMeal);
    });
  }

  // Tugas 6: saat halaman dibuka, URL gambar belum diketahui (data masih
  // diambil). Karena itu yang "terbang" selalu gambar kecil dari katalog,
  // lalu mendarat di area gambar besar halaman detail.
  // flightShuttleBuilder menentukan widget apa yang ditampilkan selama
  // animasi Hero berlangsung:
  //   push (katalog → detail) → pakai Hero asal (fromHeroContext)
  //   pop  (detail → katalog) → pakai Hero tujuan (toHeroContext)
  // Keduanya sama-sama gambar kecil di katalog.
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

  /// Membungkus area gambar dengan Hero yang tag-nya sama dengan katalog
  /// (`'gambar-<id>'`), sehingga Flutter tahu kedua gambar itu pasangan.
  Widget _areaGambar({required Widget child}) {
    return Hero(
      tag: 'gambar-${widget.idMeal}',
      flightShuttleBuilder: _pesawatHero,
      child: child,
    );
  }

  /// Label kecil berikon (kategori, area, id) dengan latar violet transparan.
  Widget _chip(IconData ikon, String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Palet.violet.withValues(alpha: 0.1),   // violet 10%
        borderRadius: BorderRadius.circular(20),      // bentuk kapsul
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,   // lebar mengikuti isi
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
        // Nama sudah dikirim dari katalog, jadi judul langsung tampil
        // tanpa menunggu respons lookup.php.
        title: Text(widget.nama, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<Meal>(
        future: futureDetail,
        builder: (context, snapshot) {
          // ---- Keadaan 1: menunggu ----
          // Area gambar abu-abu tetap disediakan agar animasi Hero punya
          // tempat mendarat, ditambah indikator loading di bawahnya.
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

          // ---- Keadaan 2: gagal ----
          if (snapshot.hasError) {
            return TampilanError(
              pesan: snapshot.error.toString(),
              onCobaLagi: muatUlang,
            );
          }

          // ---- Keadaan 3: berhasil ----
          // Tanda ! aman dipakai: tidak waiting dan tidak error berarti
          // Future selesai dengan data (ambilDetailMeal tidak pernah
          // mengembalikan null).
          final meal = snapshot.data!;

          // SingleChildScrollView agar instruksi yang panjang bisa digulir.
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gambar besar (tinggi 220) — tujuan animasi Hero.
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
                      // Nama resep
                      Text(
                        meal.nama,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Wrap: chip otomatis pindah baris jika tidak muat.
                      Wrap(
                        spacing: 8,      // jarak horizontal antar chip
                        runSpacing: 8,   // jarak vertikal antar baris
                        children: [
                          _chip(Icons.restaurant_menu, meal.kategori),
                          _chip(Icons.public, meal.area),
                          _chip(Icons.tag, meal.id),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      // Instruksi memasak (hanya tersedia dari lookup.php).
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
                      // Saat ini hanya menampilkan SnackBar sebagai umpan balik.
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
                      // Navigator.pop menutup halaman ini dan kembali ke katalog.
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

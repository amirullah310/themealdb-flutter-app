// Latihan 2 — Model Class + ListView.builder Berisi Data dari API
// Jalankan: flutter run -t lib/latihan2.dart
//
// Tujuan latihan:
//   1. Membuat model class `Meal` agar data JSON punya tipe yang jelas
//      (meal.nama, bukan item['strMeal']).
//   2. Memisahkan pemanggilan API ke fungsi tersendiri (ambilDaftarMeal).
//   3. Menampilkan daftar resep dengan ListView.builder, termasuk
//      keadaan loading, error, dan data berhasil.
//
// Sudah termasuk tugas mahasiswa yang berupa perubahan kode:
//   - Tugas 2: field `kategori` (key JSON `strCategory`)
//   - Tugas 3: jumlah item pada judul AppBar
//   - Tugas 6: RefreshIndicator yang membungkus ListView

import 'dart:convert';                    // jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // permintaan HTTP

import 'tema.dart';

/// Endpoint daftar resep kategori Seafood.
const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

// ---------------- MODEL ----------------
/// Representasi satu resep. Setiap field diisi dari key JSON tertentu.
/// Semua field `final` sehingga objek tidak bisa diubah setelah dibuat.
class Meal {
  final String id;        // idMeal
  final String nama;      // strMeal
  final String gambar;    // strMealThumb (URL gambar)
  final String area;      // strArea (asal masakan)
  final String kategori;  // strCategory — Tugas 2

  const Meal({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.area,
    required this.kategori,
  });

  /// Factory constructor: membuat objek Meal dari satu Map hasil jsonDecode.
  /// Pola `as String? ?? 'default'` artinya: baca sebagai String yang boleh
  /// null, dan jika null (key tidak ada) pakai nilai default.
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

  // Status selain 200 dianggap gagal; Exception akan ditangkap oleh
  // blok catch di muatData().
  if (response.statusCode != 200) {
    throw Exception('Server membalas status ${response.statusCode}');
  }

  // String JSON → Map, lalu ambil array 'meals' (bisa null).
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final daftar = (data['meals'] as List<dynamic>?) ?? const [];

  // Ubah setiap item (Map) menjadi objek Meal, lalu kumpulkan ke List.
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

/// Halaman katalog resep. Stateful karena isinya berubah:
/// loading → daftar resep, atau loading → pesan error.
class HalamanKatalog extends StatefulWidget {
  const HalamanKatalog({super.key});

  @override
  State<HalamanKatalog> createState() => _HalamanKatalogState();
}

class _HalamanKatalogState extends State<HalamanKatalog> {
  // Tiga variabel state yang dikelola secara manual:
  bool sedangMemuat = true;     // sedang menunggu respons server?
  String pesanError = '';       // tidak kosong = terjadi kesalahan
  List<Meal> daftarMeal = [];   // data resep yang berhasil diambil

  @override
  void initState() {
    super.initState();
    muatData();   // ambil data sekali saat halaman dibuat
  }

  /// Memanggil API lalu memperbarui state sesuai hasilnya.
  /// Mengembalikan Future agar bisa dipakai oleh RefreshIndicator,
  /// yang menunggu Future selesai sebelum menyembunyikan animasinya.
  Future<void> muatData() async {
    // Reset ke keadaan loading.
    setState(() {
      sedangMemuat = true;
      pesanError = '';
    });

    try {
      final hasil = await ambilDaftarMeal();
      if (!mounted) return;   // halaman sudah ditutup → jangan setState
      // Berhasil: simpan daftar dan matikan loading.
      setState(() {
        daftarMeal = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Gagal: simpan pesan error agar ditampilkan di layar.
      setState(() {
        pesanError = e.toString();
        sedangMemuat = false;
      });
    }
  }

  /// Gambar kecil (thumbnail) di sisi kiri setiap baris.
  Widget _gambarMenu(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),   // sudut gambar membulat
      child: Image.network(
        url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,   // isi kotak penuh, potong bagian yang berlebih
        // Selama gambar masih diunduh, tampilkan indikator kecil.
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;   // null = unduhan selesai
          return const SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        // Jika gambar gagal dimuat (URL rusak / offline), tampilkan ikon.
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
      // Ternary bertingkat untuk memilih salah satu dari tiga tampilan:
      //   1) loading  2) error  3) daftar resep
      body: sedangMemuat
          // ---- Keadaan 1: masih memuat ----
          ? const Center(child: CircularProgressIndicator())
          : pesanError.isNotEmpty
              // ---- Keadaan 2: gagal → pesan error + tombol Coba Lagi ----
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
                          onPressed: muatData,   // ulangi permintaan
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              // ---- Keadaan 3: berhasil → daftar resep ----
              // Tugas 6: tarik ke bawah untuk memuat ulang
              : RefreshIndicator(
                  onRefresh: muatData,
                  // ListView.builder hanya membangun baris yang terlihat
                  // di layar, sehingga hemat memori untuk daftar panjang.
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: daftarMeal.length,
                    itemBuilder: (context, index) {
                      final meal = daftarMeal[index];   // data baris ke-index

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
                          leading: _gambarMenu(meal.gambar),   // kiri: gambar
                          title: Text(                         // tengah: nama
                            meal.nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,   // potong dengan "..."
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${meal.area} • ${meal.kategori}'),
                          trailing: const Icon(Icons.chevron_right),
                          // Saat baris diketuk, tampilkan idMeal di SnackBar.
                          // (Navigasi ke halaman detail baru dibuat di Latihan 4.)
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

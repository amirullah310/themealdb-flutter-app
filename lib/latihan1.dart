// Latihan 1 — Permintaan HTTP Pertama dan Membaca JSON Mentah
// Jalankan: flutter run -t lib/latihan1.dart
//
// Tujuan latihan:
//   1. Mengirim permintaan GET ke server memakai package `http`.
//   2. Memeriksa status code dari respons server.
//   3. Mengubah teks JSON (response.body) menjadi struktur data Dart
//      dengan jsonDecode, lalu menampilkan isinya apa adanya (mentah).
//
// Alur singkat:
//   initState() → ambilData() → http.get() → jsonDecode() → setState()
//   → build() menampilkan hasilnya di layar.

import 'dart:convert';                        // untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;      // package yang baru ditambahkan
                                              // (alias `http` agar fungsi
                                              // get() tidak bentrok nama)

import 'tema.dart';                           // tema warna aplikasi (Palet)

/// Endpoint daftar resep kategori Seafood.
/// Parameter `c=Seafood` pada URL menentukan kategori yang diminta.
const String urlDaftar =
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';

// Titik awal aplikasi: runApp() menjalankan widget MyApp.
void main() => runApp(const MyApp());

/// Widget akar aplikasi. Hanya mengatur tema dan halaman pertama,
/// jadi cukup StatelessWidget (tidak punya data yang berubah).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,   // sembunyikan pita "DEBUG"
      theme: temaAplikasi,                 // tema dari tema.dart
      home: const HalamanUjiApi(),         // halaman yang pertama dibuka
    );
  }
}

/// Halaman untuk menguji API. Memakai StatefulWidget karena isi layar
/// berubah: awalnya loading, lalu berganti menjadi hasil dari server.
class HalamanUjiApi extends StatefulWidget {
  const HalamanUjiApi({super.key});

  @override
  State<HalamanUjiApi> createState() => _HalamanUjiApiState();
}

class _HalamanUjiApiState extends State<HalamanUjiApi> {
  // ---------------- STATE (data yang bisa berubah) ----------------
  bool sedangMemuat = true;   // true = tampilkan indikator loading
  String pesan = '';          // teks hasil yang ditampilkan ke layar

  @override
  void initState() {
    super.initState();
    ambilData();   // dijalankan sekali saat halaman pertama kali dibuat
  }

  /// Mengambil data dari server lalu menyusun teks ringkasan hasilnya.
  /// `async` agar bisa memakai `await` (menunggu respons tanpa membekukan UI).
  Future<void> ambilData() async {
    // Kembali ke keadaan loading (berguna saat tombol "Coba Ambil Lagi" ditekan).
    setState(() {
      sedangMemuat = true;
      pesan = '';
    });

    String hasil;
    try {
      // 1) Kirim permintaan GET. Uri.parse mengubah teks URL menjadi objek Uri.
      final response = await http.get(Uri.parse(urlDaftar));

      // 2) Status 200 berarti permintaan berhasil (OK).
      if (response.statusCode == 200) {
        // 3) response.body masih berupa String JSON. jsonDecode mengubahnya
        //    menjadi Map<String, dynamic> (objek JSON paling luar).
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // 4) Ambil array di dalam key 'meals'.
        // 'meals' bisa bernilai null jika kategori tidak punya data.
        // Operator ?? memberi nilai pengganti (list kosong) bila null.
        final daftar = (data['meals'] as List<dynamic>?) ?? const [];
        final contoh = daftar.isEmpty ? '(tidak ada data)' : '${daftar.first}';

        // 5) Susun ringkasan: status, panjang body, jumlah item, tipe data,
        //    dan isi item pertama dalam bentuk mentah (Map).
        hasil = 'Status code : ${response.statusCode}\n'
            'Panjang body: ${response.body.length} karakter\n'
            'Jumlah item : ${daftar.length}\n'
            'Tipe data   : ${daftar.runtimeType}\n\n'
            'Isi item pertama (JSON mentah):\n\n$contoh';
      } else {
        // Server merespons, tetapi bukan 200 (misalnya 404 atau 500).
        hasil = 'Server membalas dengan status ${response.statusCode}.';
      }
    } catch (e) {
      // Tidak ada koneksi internet, server tidak bisa dihubungi,
      // atau format JSON tidak sesuai.
      hasil = 'Gagal terhubung ke server.\n\n$e';
    }

    if (!mounted) return;   // halaman mungkin sudah ditutup saat data tiba
    // Simpan hasil ke state; setState memicu build() dijalankan ulang.
    setState(() {
      pesan = hasil;
      sedangMemuat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan 1 - Uji API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Operator ternary: jika masih memuat tampilkan loading,
        // jika sudah selesai tampilkan teks hasil + tombol.
        child: sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,  // lebar penuh
                children: [
                  // Expanded + SingleChildScrollView: teks panjang bisa
                  // digulir tanpa menyebabkan overflow.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        pesan,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol untuk mengirim ulang permintaan ke server.
                  ElevatedButton.icon(
                    onPressed: ambilData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Ambil Lagi'),
                  ),
                ],
              ),
      ),
    );
  }
}

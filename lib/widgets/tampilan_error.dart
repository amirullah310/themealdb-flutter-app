import 'package:flutter/material.dart';

/// Pesan error + tombol coba lagi. Dipakai di halaman katalog dan detail.
/// Dengan widget terpisah ini, kode tampilan error tidak perlu ditulis
/// dua kali (pada Latihan 2 dan 3 kode yang sama masih ditulis langsung).
class TampilanError extends StatelessWidget {
  const TampilanError({super.key, required this.pesan, required this.onCobaLagi});

  final String pesan;              // isi pesan error yang ditampilkan
  final VoidCallback onCobaLagi;   // fungsi yang dijalankan saat tombol ditekan
                                   // (diisi muatUlang oleh halaman pemanggil)

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   // isi di tengah layar
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

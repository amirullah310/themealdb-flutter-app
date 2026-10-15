// Model yang sama dipakai untuk respons filter.php maupun lookup.php.
// Field yang tidak tersedia di salah satu endpoint akan berisi nilai default.
//
//   Key JSON         filter.php  lookup.php   Field
//   idMeal               ✓           ✓        id
//   strMeal              ✓           ✓        nama
//   strMealThumb         ✓           ✓        gambar
//   strArea              -           ✓        area
//   strCategory          -           ✓        kategori
//   strInstructions      -           ✓        instruksi
class Meal {
  final String id;         // ID unik resep, dikirim ke halaman detail
  final String nama;       // nama masakan
  final String gambar;     // URL gambar
  final String area;       // asal masakan (mis. Italian, Japanese)
  final String kategori;   // kategori (mis. Seafood)
  final String instruksi;  // langkah-langkah memasak

  const Meal({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.area,
    required this.kategori,
    required this.instruksi,
  });

  /// Membuat Meal dari satu Map hasil jsonDecode.
  /// `as String? ?? 'default'` → jika key tidak ada / null, pakai default.
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String? ?? '',
      nama: json['strMeal'] as String? ?? 'Tanpa Nama',
      gambar: json['strMealThumb'] as String? ?? '',
      area: json['strArea'] as String? ?? 'Internasional',
      kategori: json['strCategory'] as String? ?? '-',
      // Instruksi dari API memakai \r\n; diseragamkan menjadi \n agar rapi.
      instruksi: (json['strInstructions'] as String? ?? 'Belum ada instruksi.')
          .replaceAll('\r\n', '\n'),
    );
  }
}

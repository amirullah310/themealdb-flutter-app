// Model yang sama dipakai untuk respons filter.php maupun lookup.php.
// Field yang tidak tersedia di salah satu endpoint akan berisi nilai default.
class Meal {
  final String id;
  final String nama;
  final String gambar;
  final String area;
  final String kategori;
  final String instruksi;

  const Meal({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.area,
    required this.kategori,
    required this.instruksi,
  });

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

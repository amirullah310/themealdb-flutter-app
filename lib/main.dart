// Titik masuk: menggabungkan Latihan 1 sampai 4 dalam satu TabBar.
// Masing-masing latihan tetap bisa dijalankan sendiri:
//   flutter run -t lib/latihan1.dart
//   flutter run -t lib/latihan2.dart
//   flutter run -t lib/latihan3.dart
//   flutter run -t lib/latihan4.dart
import 'package:flutter/material.dart';

// Prefix dipakai karena beberapa latihan sama-sama punya class HalamanKatalog.
import 'latihan1.dart' as l1;
import 'latihan2.dart' as l2;
import 'latihan3.dart' as l3;
import 'pages/halaman_katalog.dart' as l4;
import 'tema.dart';

void main() => runApp(const AplikasiPraktikum());

class AplikasiPraktikum extends StatelessWidget {
  const AplikasiPraktikum({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaAplikasi,
      home: const HalamanTab(),
    );
  }
}

class HalamanTab extends StatelessWidget {
  const HalamanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        // Setiap latihan sudah punya AppBar sendiri, jadi TabBar diletakkan
        // di bawah agar tidak ada dua AppBar bertumpuk.
        body: const TabBarView(
          children: [
            _TetapHidup(child: l1.HalamanUjiApi()),
            _TetapHidup(child: l2.HalamanKatalog()),
            _TetapHidup(child: l3.HalamanKatalog()),
            _TetapHidup(child: l4.HalamanKatalog()),
          ],
        ),
        bottomNavigationBar: Material(
          color: Palet.violet,
          child: SafeArea(
            child: TabBar(
              labelColor: Palet.lime,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Palet.lime,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(icon: Icon(Icons.data_object), text: 'Latihan 1'),
                Tab(icon: Icon(Icons.list_alt), text: 'Latihan 2'),
                Tab(icon: Icon(Icons.sync), text: 'Latihan 3'),
                Tab(icon: Icon(Icons.menu_book), text: 'Latihan 4'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Menjaga state halaman tetap hidup saat berpindah tab,
/// supaya data tidak diambil ulang dari server setiap kali tab diganti.
class _TetapHidup extends StatefulWidget {
  final Widget child;
  const _TetapHidup({required this.child});

  @override
  State<_TetapHidup> createState() => _TetapHidupState();
}

class _TetapHidupState extends State<_TetapHidup>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

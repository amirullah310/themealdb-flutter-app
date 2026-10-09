// Palet warna aplikasi: Black, Violet, Lime, White.
// Background tetap putih; lime hanya dipakai di atas violet agar tetap terbaca.
import 'package:flutter/material.dart';

class Palet {
  static const Color hitam = Color(0xFF000000);  // RGB 0, 0, 0
  static const Color violet = Color(0xFF7D39EB); // RGB 125, 57, 235
  static const Color lime = Color(0xFFC6FF33);   // RGB 198, 255, 51
  static const Color putih = Color(0xFFFFFFFF);  // RGB 255, 255, 255
}

final ThemeData temaAplikasi = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Palet.putih,
  colorScheme: const ColorScheme.light(
    primary: Palet.violet,
    onPrimary: Palet.putih,
    secondary: Palet.lime,
    onSecondary: Palet.hitam,
    surface: Palet.putih,
    onSurface: Palet.hitam,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Palet.violet,
    foregroundColor: Palet.putih,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Palet.putih,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardThemeData(
    color: Palet.putih,
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Palet.violet,
      foregroundColor: Palet.putih,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Palet.violet,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Palet.violet,
    contentTextStyle: TextStyle(color: Palet.lime),
  ),
);

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const green = Color(0xFF087A4B),
      darkGreen = Color(0xFF045C3A),
      navy = Color(0xFF132238),
      background = Color(0xFFF5F8F7),
      mint = Color(0xFFE8F6EF),
      amber = Color(0xFFF59E0B),
      red = Color(0xFFD94343),
      blue = Color(0xFF1677E8);
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.notoSansBengaliTextTheme().apply(
    bodyColor: AppColors.navy,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.navy,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDE5E1)),
    ),
  ),
);

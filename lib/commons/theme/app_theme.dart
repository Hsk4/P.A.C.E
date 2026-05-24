import 'package:flutter/material.dart';

class AppTheme {
  static const Color appBackground = Color(0xFF0A0D14);
  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color primaryCrimson = Color(0xFFDC143C);
  static const Color cardBackground = Color(0xFF141A24);
  static const Color borderColor = Color(0xFF2A3140);
  static const Color textPrimary = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        onPrimary: Colors.white,
        secondary: primaryCrimson,
        onSecondary: Colors.white,
        surface: cardBackground,
        onSurface: textPrimary,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: appBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIconColor: primaryOrange,
        suffixIconColor: primaryOrange,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBackground,
        selectedItemColor: primaryOrange,
        unselectedItemColor: primaryCrimson,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        onPrimary: Colors.white,
        secondary: primaryCrimson,
        onSecondary: Colors.white,
        surface: cardBackground,
        onSurface: textPrimary,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: appBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: borderColor,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBackground,
        selectedItemColor: primaryOrange,
        unselectedItemColor: primaryCrimson,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


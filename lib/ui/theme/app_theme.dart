
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryColor = Colors.lightBlue; // Changed to lightBlue
  static const Color _lightBackgroundColor = Color(0xFFF4F6F8);
  static const Color _darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color _lightCardColor = Colors.white;
  static const Color _darkCardColor = Color(0xFF2C2C2C);

  static final ThemeData lightTheme = ThemeData.light(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor, // Using the new lightBlue seed
      brightness: Brightness.light,
      primary: _primaryColor,
      surface: _lightBackgroundColor,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    textTheme: _textTheme(GoogleFonts.interTextTheme(ThemeData.light().textTheme)),
    appBarTheme: _appBarTheme(
      backgroundColor: _lightBackgroundColor,
      foregroundColor: Colors.black87,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(_primaryColor, Colors.white),
    cardTheme: const CardThemeData(
      color: _lightCardColor,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor, // Dark theme can also be seeded from the same color for consistency
      brightness: Brightness.dark,
      primary: _primaryColor,
      surface: _darkBackgroundColor,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    textTheme: _textTheme(GoogleFonts.interTextTheme(ThemeData.dark().textTheme)),
    appBarTheme: _appBarTheme(
      backgroundColor: _darkBackgroundColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(_primaryColor, Colors.white),
     cardTheme: const CardThemeData(
      color: _darkCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 48, fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: Colors.grey[600]),
    );
  }

  static AppBarTheme _appBarTheme({required Color backgroundColor, required Color foregroundColor}) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: foregroundColor),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color primary, Color onPrimary) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    );
  }
}

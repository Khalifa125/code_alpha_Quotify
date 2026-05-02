import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF667eea),
        secondary: Color(0xFF764ba2),
        surface: Colors.white,
        onSurface: Color(0xFF1a1a2e),
        surfaceContainerHighest: Color(0xFFF8F9FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF667eea),
        secondary: Color(0xFF764ba2),
        surface: Color(0xFF1a1a2e),
        onSurface: Colors.white,
        surfaceContainerHighest: Color(0xFF0f0f1a),
      ),
      scaffoldBackgroundColor: const Color(0xFF0f0f1a),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2d2d44),
        contentTextStyle: GoogleFonts.lato(color: Colors.white),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color textColor = isLight ? const Color(0xFF1a1a2e) : Colors.white;
    final Color subtitleColor = isLight ? const Color(0xFF6b7280) : const Color(0xFF9ca3af);
    final Color accentColor = isLight ? const Color(0xFF667eea) : const Color(0xFF8b8fd4);

    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: textColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: subtitleColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: subtitleColor,
      ),
      labelLarge: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelMedium: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: accentColor,
      ),
    );
  }

  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class AppColors {
  static const Color primary = Color(0xFF667eea);
  static const Color secondary = Color(0xFF764ba2);
  
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1a1a2e);
  static const Color lightSubtitle = Color(0xFF6b7280);
  
  static const Color darkBackground = Color(0xFF0f0f1a);
  static const Color darkSurface = Color(0xFF1a1a2e);
  static const Color darkText = Colors.white;
  static const Color darkSubtitle = Color(0xFF9ca3af);
}
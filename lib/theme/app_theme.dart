import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double _radius = 20;
  static const double _buttonRadius = 14;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF667eea),
        secondary: Color(0xFF764ba2),
        surface: Colors.white,
        onSurface: Color(0xFF1a1a2e),
        surfaceContainerHighest: Color(0xFFFAFAFA),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: _buildTextTheme(Brightness.light),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withOpacity(0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: _buildTextTheme(Brightness.dark),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1333).withOpacity(0.95),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
        backgroundColor: const Color(0xFF2d2d44),
        contentTextStyle: GoogleFonts.lato(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        fontSize: 36, fontWeight: FontWeight.w600, color: textColor,
        height: 1.3, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w500, color: textColor, height: 1.3,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w500, color: textColor,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w500, color: textColor,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 18, fontWeight: FontWeight.w600, color: textColor,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 16, fontWeight: FontWeight.w500, color: textColor,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16, color: textColor, height: 1.6,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14, color: subtitleColor, height: 1.5,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12, color: subtitleColor,
      ),
      labelLarge: GoogleFonts.lato(
        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
      ),
      labelMedium: GoogleFonts.lato(
        fontSize: 12, fontWeight: FontWeight.w500, color: accentColor,
      ),
    );
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

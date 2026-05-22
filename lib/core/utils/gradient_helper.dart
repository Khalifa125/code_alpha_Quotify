import 'package:flutter/material.dart';

class GradientHelper {
  static const List<List<Color>> _gradientsLight = [
    [Color(0xFFE8E0F0), Color(0xFFE0E8F5)],
    [Color(0xFFF0E6FA), Color(0xFFE8F0FE)],
    [Color(0xFFE8EEF5), Color(0xFFF0E8F5)],
    [Color(0xFFF0E8F5), Color(0xFFE8F5F0)],
    [Color(0xFFE8F0F5), Color(0xFFF5E8F0)],
    [Color(0xFFF5E8F0), Color(0xFFE8F0F5)],
    [Color(0xFFE8F5E8), Color(0xFFF0F5E8)],
    [Color(0xFFF0E8F5), Color(0xFFE8EAF5)],
  ];

  static const List<List<Color>> _gradientsDark = [
    [Color(0xFF1A1333), Color(0xFF1A2847)],
    [Color(0xFF251A47), Color(0xFF1F2847)],
    [Color(0xFF1F2547), Color(0xFF2A1F47)],
    [Color(0xFF2A1F3D), Color(0xFF1F3D2A)],
    [Color(0xFF1F3347), Color(0xFF3D2A1F)],
    [Color(0xFF3D1F2A), Color(0xFF1F2A3D)],
    [Color(0xFF1F3D33), Color(0xFF2A331F)],
    [Color(0xFF2A1F47), Color(0xFF1F3347)],
  ];

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF6366F1);
  static List<Color> getGradientForMode(int index, bool isDark) {
    if (isDark) return _gradientsDark[index % _gradientsDark.length];
    return _gradientsLight[index % _gradientsLight.length];
  }

  static LinearGradient backgroundGradient(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0A1A), Color(0xFF151025)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF8F5FC), Color(0xFFEEEDF5)],
    );
  }

  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_primaryPurple, _primaryBlue],
  );

  static LinearGradient buttonGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9F7AEA), Color(0xFF6366F1)],
  );

  static const Color primaryColor = _primaryPurple;
  static const Color secondaryColor = _primaryBlue;
  static const Color favoriteRed = Color(0xFFFF3366);

  static Color cardBackground(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.35);
  }

  static Color cardBorder(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.05);
  }

  static Color glassTint(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.5);
  }

  static Color glassBorder(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
  }

  static Color textPrimary(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF1E1B2E);
  }

  static Color textSecondary(bool isDark) {
    return isDark ? Colors.white70 : const Color(0xFF6B6B7B);
  }

  static Color textMuted(bool isDark) {
    return isDark ? Colors.white54 : const Color(0xFF767676);
  }
}

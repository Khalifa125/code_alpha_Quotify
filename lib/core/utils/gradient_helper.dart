import 'package:flutter/material.dart';

class GradientHelper {
  static const List<List<Color>> _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFFa8edea), Color(0xFFfed6e3)],
    [Color(0xFFffecd2), Color(0xFFfcb69f)],
    [Color(0xFFff9a9e), Color(0xFFfecfef)],
  ];

  static List<Color> getGradient(int index) {
    return _gradients[index % _gradients.length];
  }

  static LinearGradient backgroundGradient(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0f0f1a),
          Color(0xFF1a1a2e),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF8F9FA),
        Color(0xFFE8ECEF),
      ],
    );
  }

  static LinearGradient cardGradient(List<Color> colors, bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors.map((c) => c.withValues(alpha: isDark ? 0.2 : 0.1)).toList(),
    );
  }
}
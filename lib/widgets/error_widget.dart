import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';

class QuoteErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const QuoteErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(isDark),
          const SizedBox(height: 32),
          _buildTitle(context, isDark),
          const SizedBox(height: 12),
          _buildMessage(context, isDark, mutedColor),
          const SizedBox(height: 32),
          _buildRetryButton(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white.withValues(alpha:  0.05) : Colors.black.withValues(alpha:  0.03),
      ),
      child: Icon(
        Icons.wifi_off_rounded,
        size: 48,
        color: isDark ? Colors.white38 : const Color(0xFF767676),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.8, 0.8), duration: 500.ms);
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    final textColor = GradientHelper.textPrimary(isDark);
    return Text(
      'Connection Issue',
      style: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildMessage(BuildContext context, bool isDark, Color mutedColor) {
    return Text(
      message,
      style: GoogleFonts.lato(
        fontSize: 14,
        color: mutedColor,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildRetryButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onRetry();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: GradientHelper.buttonGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: GradientHelper.primaryColor.withValues(alpha:  0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Try Again',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2);
  }
}
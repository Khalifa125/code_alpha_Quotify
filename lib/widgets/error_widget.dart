import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/error/failures.dart';

class QuoteErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const QuoteErrorWidget({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(isDark),
          const SizedBox(height: 32),
          _buildTitle(context, isDark),
          const SizedBox(height: 12),
          _buildMessage(context, isDark),
          const SizedBox(height: 32),
          _buildRetryButton(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.95, 0.95),
      duration: 400.ms,
    );
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
      ),
      child: Icon(
        _getIcon(),
        size: 56,
        color: isDark ? Colors.white38 : Colors.black26,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(
      begin: const Offset(0.8, 0.8),
      duration: 500.ms,
    );
  }

  IconData _getIcon() {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return Icons.wifi_off_rounded;
    } else if (failure is ApiKeyFailure) {
      return Icons.key_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return Text(
      _getTitle(),
      style: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1a1a2e),
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  String _getTitle() {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return 'Connection Issue';
    } else if (failure is ApiKeyFailure) {
      return 'Setup Required';
    }
    return 'Something Went Wrong';
  }

  Widget _buildMessage(BuildContext context, bool isDark) {
    return Text(
      failure.message,
      style: GoogleFonts.lato(
        fontSize: 14,
        color: isDark ? Colors.white54 : const Color(0xFF6b7280),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 20,
            ),
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
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';
import '../models/quote_model.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final int gradientIndex;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.gradientIndex,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = GradientHelper.getGradient(gradientIndex);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: GradientHelper.cardGradient(colors, isDark),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuoteMark(colors, isDark),
                  const SizedBox(height: 24),
                  _buildQuoteText(isDark),
                  const SizedBox(height: 32),
                  _buildAuthor(isDark),
                  const SizedBox(height: 40),
                  _buildActionButtons(isDark, colors),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
      begin: const Offset(0.96, 0.96),
      curve: Curves.easeOutCubic,
      duration: 500.ms,
    );
  }

  Widget _buildQuoteMark(List<Color> colors, bool isDark) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Text(
          '"',
          style: GoogleFonts.playfairDisplay(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: colors[0].withValues(alpha: 0.25),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.3),
      ],
    );
  }

  Widget _buildQuoteText(bool isDark) {
    return Text(
      quote.text,
      style: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF1a1a2e),
        height: 1.5,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildAuthor(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 1,
          decoration: BoxDecoration(
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          quote.author,
          style: GoogleFonts.lato(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white70 : const Color(0xFF6b7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 30,
          height: 1,
          decoration: BoxDecoration(
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildActionButtons(bool isDark, List<Color> colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: onCopy,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: onShare,
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.15);
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isDark 
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isDark ? Colors.white70 : const Color(0xFF4b5563),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white70 : const Color(0xFF4b5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
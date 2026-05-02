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
  final bool isSmallScreen;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.gradientIndex,
    required this.onCopy,
    required this.onShare,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = GradientHelper.getGradient(gradientIndex);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.white : Colors.white).withValues(alpha: 0.15),
                  (isDark ? Colors.white : Colors.white).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: isDark ? 0.2 : 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 28,
                vertical: isSmallScreen ? 28 : 48,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDecorativeQuoteMark(colors, isDark),
                  const SizedBox(height: 24),
                  _buildQuoteText(isDark),
                  const SizedBox(height: 32),
                  _buildDivider(isDark),
                  const SizedBox(height: 24),
                  _buildAuthor(isDark),
                  const SizedBox(height: 40),
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
      begin: const Offset(0.95, 0.95),
      curve: Curves.easeOutCubic,
      duration: 500.ms,
    );
  }

  Widget _buildDecorativeQuoteMark(List<Color> colors, bool isDark) {
    final fontSize = isSmallScreen ? 70.0 : 100.0;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Text(
          '"',
          style: GoogleFonts.playfairDisplay(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: (isDark ? Colors.white : const Color(0xFF1a1a2e)).withValues(alpha: 0.08),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.3),
      ],
    );
  }

  Widget _buildQuoteText(bool isDark) {
    final fontSize = isSmallScreen ? 20.0 : 24.0;
    return Text(
      quote.text,
      style: GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF1a1a2e),
        height: 1.5,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF667eea).withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildAuthor(bool isDark) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final iconWidth = isSmallScreen ? 15.0 : 20.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: iconWidth,
          height: 1,
          decoration: BoxDecoration(
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Text(
          quote.author,
          style: GoogleFonts.lato(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF667eea),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Container(
          width: iconWidth,
          height: 1,
          decoration: BoxDecoration(
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildActionButtons(bool isDark) {
    final buttonPadding = isSmallScreen ? 16.0 : 24.0;
    final buttonVertical = isSmallScreen ? 10.0 : 14.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: onCopy,
          isDark: isDark,
          horizontalPadding: buttonPadding,
          verticalPadding: buttonVertical,
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        _ActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: onShare,
          isDark: isDark,
          horizontalPadding: buttonPadding,
          verticalPadding: buttonVertical,
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
  final double horizontalPadding;
  final double verticalPadding;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.horizontalPadding = 24,
    this.verticalPadding = 14,
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
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding,
            vertical: widget.verticalPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
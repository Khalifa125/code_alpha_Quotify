import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';
import '../models/quote.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final int gradientIndex;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onShareImage;
  final VoidCallback onFavorite;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isFavorite;
  final bool isSmallScreen;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.gradientIndex,
    required this.onCopy,
    required this.onShare,
    required this.onShareImage,
    required this.onFavorite,
    required this.onNext,
    required this.onPrevious,
    required this.isFavorite,
    this.isSmallScreen = false,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> with TickerProviderStateMixin {
  double _dragX = 0;
  bool _showHeartBurst = false;
  late AnimationController _burstController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _burstController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragX = _dragX.clamp(-100.0, 100.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragX > 50) {
      widget.onNext();
    } else if (_dragX < -50) {
      widget.onPrevious();
    }
    setState(() {
      _dragX = 0;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy < -500 && !widget.isFavorite) {
      setState(() => _showHeartBurst = true);
      _burstController.forward().then((_) {
        setState(() => _showHeartBurst = false);
        _burstController.reset();
        widget.onFavorite();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = GradientHelper.getGradientForMode(widget.gradientIndex, isDark);
    final textColor = GradientHelper.textPrimary(isDark);
    final secondaryColor = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);

    return RepaintBoundary(
      child: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onVerticalDragEnd: _onVerticalDragEnd,
        onDoubleTap: () {
          widget.onCopy();
          _showCopyFlash(context);
        },
        onLongPress: () => _showQuickActions(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..translate(_dragX, 0),
          transformAlignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GradientHelper.cardBackground(isDark),
                            GradientHelper.cardBackground(isDark).withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: GradientHelper.cardBorder(isDark),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GradientHelper.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isSmallScreen ? 24 : 32,
                          vertical: widget.isSmallScreen ? 32 : 48,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuoteIcon(gradientColors),
                            const SizedBox(height: 28),
                            _buildQuoteText(textColor, isDark),
                            const SizedBox(height: 32),
                            _buildDivider(gradientColors, isDark),
                            const SizedBox(height: 24),
                            _buildAuthor(secondaryColor, mutedColor),
                            const SizedBox(height: 36),
                            _buildActionButtons(isDark),
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
              ),
              if (_showHeartBurst)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: _HeartBurstAnimation(controller: _burstController),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCopyFlash(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.15,
        left: 0,
        right: 0,
        child: Center(
          child: _CopiedToast(),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 2000), () => entry.remove());
  }

  void _showQuickActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickActionSheet(
        onCopy: () { Navigator.pop(context); widget.onCopy(); },
        onShare: () { Navigator.pop(context); widget.onShare(); },
        onSaveImage: () { Navigator.pop(context); widget.onShareImage(); },
        onFavorite: () { Navigator.pop(context); widget.onFavorite(); },
        isFavorite: widget.isFavorite,
      ),
    );
  }

  Widget _buildQuoteIcon(List<Color> gradientColors) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: GradientHelper.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GradientHelper.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.format_quote_rounded,
        color: Colors.white,
        size: 28,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildQuoteText(Color textColor, bool isDark) {
    final fontSize = widget.isSmallScreen ? 20.0 : 24.0;
    return Text(
      widget.quote.text,
      style: GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.6,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildDivider(List<Color> colors, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                GradientHelper.primaryColor.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildAuthor(Color secondaryColor, Color mutedColor) {
    final fontSize = widget.isSmallScreen ? 14.0 : 16.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 1,
          decoration: BoxDecoration(
            color: mutedColor.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '— ${widget.quote.author}',
          style: GoogleFonts.lato(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: secondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 24,
          height: 1,
          decoration: BoxDecoration(
            color: mutedColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PremiumButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: widget.onCopy,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _PremiumButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: widget.onShare,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _FavoriteButton(
          isFavorite: widget.isFavorite,
          onTap: () {
            setState(() => _showHeartBurst = true);
            _burstController.forward().then((_) {
              setState(() => _showHeartBurst = false);
              _burstController.reset();
              widget.onFavorite();
            });
          },
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.15);
  }
}

class _HeartBurstAnimation extends StatelessWidget {
  final AnimationController controller;

  const _HeartBurstAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 1.0 + (controller.value * 0.4);
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(5, (i) {
              final angle = (i * 72) * (math.pi / 180);
              final distance = controller.value * 60;
              return Transform.translate(
                offset: Offset(
                  math.cos(angle) * distance,
                  math.sin(angle) * distance,
                ),
                child: Transform.scale(
                  scale: 1 - controller.value,
                  child: Icon(
                    Icons.favorite,
                    color: const Color(0xFFFF3366).withValues(alpha: 1 - controller.value),
                    size: 20,
                  ),
                ),
              );
            }),
            Transform.scale(
              scale: scale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3366), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3366).withValues(alpha: 0.6 * (1 - controller.value)),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CopiedToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: GradientHelper.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GradientHelper.primaryColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Copied! ✓',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.3).then(delay: 1500.ms).fadeOut(duration: 300.ms);
  }
}

class _QuickActionSheet extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSaveImage;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const _QuickActionSheet({
    required this.onCopy,
    required this.onShare,
    required this.onSaveImage,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1333) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quick Actions',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E1B2E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: onCopy,
                isDark: isDark,
              ),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: onShare,
                isDark: isDark,
              ),
              _ActionButton(
                icon: Icons.image_rounded,
                label: 'Image',
                onTap: onSaveImage,
                isDark: isDark,
              ),
              _ActionButton(
                icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: isFavorite ? 'Saved' : 'Save',
                onTap: onFavorite,
                isDark: isDark,
                isActive: isFavorite,
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isActive ? const LinearGradient(colors: [Color(0xFFFF3366), Color(0xFFFF6B6B)]) : null,
              color: isActive ? null : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _PremiumButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
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
          width: 85,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: GradientHelper.buttonGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: GradientHelper.primaryColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final bool isDark;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isFavorite;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFF3366), Color(0xFFFF6B6B)],
                  )
                : null,
            color: isActive
                ? null
                : (widget.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05)),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF3366).withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isActive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 26,
            color: isActive ? Colors.white : (widget.isDark ? Colors.white54 : const Color(0xFF9B9B9B)),
          ),
        ),
      ),
    );
  }
}
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/quote.dart';
import '../../../../widgets/glass_container.dart';

class ModernQuoteCard extends StatefulWidget {
  final Quote quote;
  final int gradientIndex;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onShareImage;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCollection;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isFavorite;
  final bool isSmallScreen;
  final ScreenshotController screenshotController;

  const ModernQuoteCard({
    super.key,
    required this.quote,
    required this.gradientIndex,
    required this.onCopy,
    required this.onShare,
    required this.onShareImage,
    required this.onFavorite,
    required this.onAddToCollection,
    required this.onNext,
    required this.onPrevious,
    required this.isFavorite,
    required this.screenshotController,
    this.isSmallScreen = false,
  });

  @override
  State<ModernQuoteCard> createState() => _ModernQuoteCardState();
}

class _ModernQuoteCardState extends State<ModernQuoteCard> {
  double _dragX = 0;

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
    setState(() => _dragX = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = GradientHelper.getGradientForMode(widget.gradientIndex, isDark);
    final textColor = GradientHelper.textPrimary(isDark);
    final secondaryColor = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);

    return Screenshot(
      controller: widget.screenshotController,
      child: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onDoubleTap: () {
          widget.onCopy();
          _showCopyFlash(context);
        },
        onLongPress: () => _showQuickActions(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..translate(_dragX, 0),
          transformAlignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        GradientHelper.cardBackground(isDark),
                        GradientHelper.cardBackground(isDark).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: GradientHelper.cardBorder(isDark),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(isDark ? 0.3 : 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isSmallScreen ? 28 : 40,
                      vertical: widget.isSmallScreen ? 36 : 52,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuoteIcon(gradientColors, isDark),
                        const SizedBox(height: 32),
                        _buildQuoteText(textColor, isDark),
                        const SizedBox(height: 36),
                        _buildDivider(gradientColors),
                        const SizedBox(height: 28),
                        _buildAuthorInfo(secondaryColor, mutedColor, isDark),
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
              ),
        ),
      ),
    );
  }

  Widget _buildQuoteIcon(List<Color> gradientColors, bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.format_quote_rounded,
        color: Colors.white,
        size: 30,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildQuoteText(Color textColor, bool isDark) {
    final fontSize = widget.isSmallScreen ? 20.0 : 26.0;
    return Text(
      widget.quote.text,
      style: GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.7,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  Widget _buildDivider(List<Color> gradientColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                gradientColors[0].withOpacity(0.6),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildAuthorInfo(Color secondaryColor, Color mutedColor, bool isDark) {
    final fontSize = widget.isSmallScreen ? 14.0 : 16.0;
    return Column(
      children: [
        Container(
          width: 40,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                mutedColor.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        if (widget.quote.category != 'All') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: mutedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.quote.category,
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: mutedColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: widget.onCopy,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: widget.onShare,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        FavoriteButtonWidget(
          isFavorite: widget.isFavorite,
          onTap: widget.onFavorite,
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.15, curve: Curves.easeOutCubic);
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickActionSheet(
        onCopy: () {
          Navigator.pop(context);
          widget.onCopy();
        },
        onShare: () {
          Navigator.pop(context);
          widget.onShare();
        },
        onSaveImage: () {
          Navigator.pop(context);
          widget.onShareImage();
        },
        onFavorite: () {
          Navigator.pop(context);
          widget.onFavorite();
        },
        onAddToCollection: () {
          Navigator.pop(context);
          widget.onAddToCollection();
        },
        isFavorite: widget.isFavorite,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _CopiedToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: GradientHelper.primaryGradient.colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GradientHelper.primaryColor.withOpacity(0.4),
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
  final VoidCallback onAddToCollection;
  final bool isFavorite;
  final bool isDark;

  const _QuickActionSheet({
    required this.onCopy,
    required this.onShare,
    required this.onSaveImage,
    required this.onFavorite,
    required this.onAddToCollection,
    required this.isFavorite,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      tintOpacity: isDark ? 0.08 : 0.45,
      blurSigma: 12,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
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
              _ActionButton(
                icon: Icons.collections_bookmark_rounded,
                label: 'Collection',
                onTap: onAddToCollection,
                isDark: isDark,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isActive ? const LinearGradient(colors: [Color(0xFFFF3366), Color(0xFFFF6B6B)]) : null,
                  color: isActive ? null : (isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.35)),
                  borderRadius: BorderRadius.circular(16),
                  border: isActive ? null : Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.08 : 0.06),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                  size: 24,
                ),
              ),
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

class FavoriteButtonWidget extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final bool isDark;

  const FavoriteButtonWidget({
    super.key,
    required this.isFavorite,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<FavoriteButtonWidget> createState() => _FavoriteButtonWidgetState();
}

class _FavoriteButtonWidgetState extends State<FavoriteButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnim;
  late Animation<Offset> _floatAnim;
  late Animation<double> _fadeAnim;
  bool _showFloat = false;

  static const _bounceDuration = Duration(milliseconds: 300);
  static const _floatDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: _bounceDuration,
    );
    _floatController = AnimationController(
      vsync: this,
      duration: _floatDuration,
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
    _floatAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.85),
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(FavoriteButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      if (widget.isFavorite) {
        _playFavoriteAnimation();
      } else {
        _playUnfavoriteAnimation();
      }
    }
  }

  void _playFavoriteAnimation() {
    _floatController.stop();
    _bounceController.forward(from: 0);
    setState(() => _showFloat = true);
    _floatController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showFloat = false);
    });
  }

  void _playUnfavoriteAnimation() {
    _floatController.stop();
    setState(() => _showFloat = false);
    _bounceController
      ..duration = const Duration(milliseconds: 200)
      ..forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _bounceController.duration = _bounceDuration;
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isFavorite;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ScaleTransition(
                    scale: _bounceAnim,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [Color(0xFFFF3366), Color(0xFFFF6B6B)],
                              )
                            : null,
                        color: isActive
                            ? null
                            : (widget.isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.04)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : (widget.isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05)),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF3366).withOpacity(0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isActive
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 26,
                        color: isActive
                            ? Colors.white
                            : (widget.isDark
                                ? Colors.white54
                                : const Color(0xFF9B9B9B)),
                      ),
                    ),
                  ),
                  if (_showFloat)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: SlideTransition(
                          position: _floatAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 18,
                              color: Color(0xFFFF3366),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive ? 'Saved' : 'Save',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: isActive
                  ? const Color(0xFFFF3366)
                  : (widget.isDark ? Colors.white54 : Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}

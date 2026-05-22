import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final int favoritesCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.favoritesCount = 0,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(top: 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.85),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.format_quote_rounded,
                    label: 'Quote',
                    isActive: widget.currentIndex == 0,
                    isDark: isDark,
                    onTap: () => widget.onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    isActive: widget.currentIndex == 1,
                    isDark: isDark,
                    badgeCount: widget.favoritesCount,
                    onTap: () => widget.onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isActive: widget.currentIndex == 2,
                    isDark: isDark,
                    onTap: () => widget.onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isDark ? const Color(0xFFA78BFA) : const Color(0xFF6366F1);
    final inactiveColor = widget.isDark ? const Color(0xFF707075) : const Color(0xFF999999);
    final isActive = widget.isActive;

    return Semantics(
      label: widget.label,
      button: true,
      child: Tooltip(
        message: widget.label,
        child: GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ListenableBuilder(
        listenable: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.icon,
                    size: 24,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  if (widget.badgeCount > 0 && !isActive)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: widget.isDark ? const Color(0xFFFF453A) : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${widget.badgeCount > 99 ? 99 : widget.badgeCount}',
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }
}

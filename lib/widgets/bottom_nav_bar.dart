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
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: GradientHelper.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
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
    final inactiveColor = widget.isDark ? Colors.white54 : const Color(0xFF9B9B9B);
    final activeGradient = GradientHelper.activeNavGradient;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isActive ? activeGradient : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: GradientHelper.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.icon,
                    size: 22,
                    color: widget.isActive ? Colors.white : inactiveColor,
                  ),
                  if (widget.badgeCount > 0 && !widget.isActive)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3366),
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
              if (widget.isActive) ...[
                const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
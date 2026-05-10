import 'package:flutter/material.dart';
import '../core/utils/gradient_helper.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final int gradientIndex;
  final bool isDarkMode;

  const GradientBackground({
    super.key,
    required this.child,
    required this.gradientIndex,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: GradientHelper.backgroundGradient(isDarkMode),
      ),
      child: child,
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final int gradientIndex;
  final bool isDarkMode;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.gradientIndex,
    required this.isDarkMode,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gradientIndex != widget.gradientIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = GradientHelper.getGradientForMode(widget.gradientIndex, widget.isDarkMode);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? [
                      Color.lerp(
                        const Color(0xFF0F0A1A),
                        gradientColors[0].withValues(alpha: 0.35),
                        _animation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF151025),
                        gradientColors[1].withValues(alpha: 0.3),
                        _animation.value,
                      )!,
                    ]
                  : [
                      Color.lerp(
                        const Color(0xFFF8F5FC),
                        gradientColors[0].withValues(alpha: 0.25),
                        _animation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFEEEDF5),
                        gradientColors[1].withValues(alpha: 0.2),
                        _animation.value,
                      )!,
                    ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
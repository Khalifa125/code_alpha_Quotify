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
      duration: const Duration(milliseconds: 1500),
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
    final colors = GradientHelper.getGradient(widget.gradientIndex);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDarkMode
                  ? [
                      Color.lerp(
                        const Color(0xFF0f0f1a),
                        colors[0].withValues(alpha: 0.15),
                        _animation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF1a1a2e),
                        colors[1].withValues(alpha: 0.1),
                        _animation.value,
                      )!,
                    ]
                  : [
                      Color.lerp(
                        const Color(0xFFF8F9FA),
                        colors[0].withValues(alpha: 0.1),
                        _animation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFE8ECEF),
                        colors[1].withValues(alpha: 0.08),
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
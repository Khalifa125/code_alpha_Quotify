import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/utils/gradient_helper.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width, height;
  final EdgeInsetsGeometry? margin, padding;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final double tintOpacity;
  final LinearGradient? gradient;
  final BorderSide? border;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.tintColor,
    this.tintOpacity = 0.1,
    this.gradient,
    this.border,
    this.boxShadow,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  });

  factory GlassContainer.adaptive({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20,
    double blurSigma = 10,
    double opacity = 0.1,
    bool isDark = false,
    LinearGradient? gradient,
    List<BoxShadow>? boxShadow,
  }) {
    final dark = isDark;
    return GlassContainer(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      tintColor: dark ? Colors.white : Colors.white,
      tintOpacity: dark ? 0.06 : opacity,
      gradient: gradient,
      boxShadow: boxShadow,
      border: BorderSide(
        color: (dark ? Colors.white : Colors.black).withOpacity(dark ? 0.08 : 0.06),
        width: 0.5,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTint = tintColor ?? (isDark ? Colors.white : Colors.white);
    final effectiveOpacity = tintOpacity;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            alignment: alignment,
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient,
              color: effectiveTint.withOpacity(effectiveOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border != null ? Border.fromBorderSide(border!) : null,
              boxShadow: boxShadow ?? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.12 : 0.03),
                  blurRadius: 4,
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width, height;
  final EdgeInsetsGeometry? margin, padding;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final double tintOpacity;
  final LinearGradient? gradient;
  final BorderSide? border;
  final List<BoxShadow>? boxShadow;
  final bool disabled;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.tintColor,
    this.tintOpacity = 0.1,
    this.gradient,
    this.border,
    this.boxShadow,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTint = tintColor ?? (isDark ? Colors.white : Colors.white);
    final effectiveOpacity = tintOpacity;

    final glassChild = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: effectiveTint.withOpacity(effectiveOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border != null
                ? Border.fromBorderSide(border!)
                : Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.08 : 0.06),
                    width: 0.5,
                  ),
            boxShadow: boxShadow ?? [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.08 : 0.02),
                blurRadius: 4,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) {
      return Container(width: width, height: height, margin: margin, child: glassChild);
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        onLongPress: disabled ? null : onLongPress,
        child: glassChild,
      ),
    );
  }
}

class GlassIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final double containerSize;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;

  const GlassIconContainer({
    super.key,
    required this.icon,
    this.size = 22,
    this.containerSize = 44,
    this.color,
    this.backgroundColor,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: backgroundColor != null ? null : GradientHelper.primaryGradient,
        color: backgroundColor ?? (isDark ? Colors.white.withOpacity(0.06) : null),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, size: size, color: color ?? Colors.white),
    );
  }
}

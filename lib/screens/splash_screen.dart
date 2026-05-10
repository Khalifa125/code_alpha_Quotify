import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0A1A),
              Color(0xFF1A1333),
              Color(0xFF1A2847),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildAppIcon(),
            const SizedBox(height: 32),
            _buildAppName(),
            const SizedBox(height: 12),
            _buildTagline(),
            const Spacer(flex: 3),
            _buildVersion(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 60,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          'assets/icon1.png',
          fit: BoxFit.cover,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.85, 0.85), duration: 800.ms, curve: Curves.easeOutCubic)
        .shimmer(delay: 600.ms, duration: 1200.ms, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildAppName() {
    return Text(
      'Quotify',
      style: GoogleFonts.playfairDisplay(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1,
        shadows: [
          Shadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
            blurRadius: 30,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTagline() {
    return Text(
      'Daily Inspiration',
      style: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.6),
        letterSpacing: 3,
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.2, delay: 700.ms, duration: 600.ms);
  }

  Widget _buildVersion() {
    return Text(
      'Version 1.0.0',
      style: GoogleFonts.lato(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    ).animate().fadeIn(delay: 1200.ms, duration: 400.ms);
  }
}
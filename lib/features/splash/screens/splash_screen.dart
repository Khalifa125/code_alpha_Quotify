import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/notification_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );
    _fadeController.forward();
    _initApp();
  }

  @override
  void dispose() {
    _disposed = true;
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await Future.wait([
      dotenv.load(fileName: '.env'),
      Hive.initFlutter(),
      _initNotificationService(),
      _preloadGoogleFonts(),
    ]);

    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

    if (_disposed) return;

    try {
      await Future.delayed(const Duration(milliseconds: 1200));
    } catch (_) {
      return;
    }

    if (_disposed) return;

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed(
      showOnboarding ? '/onboarding' : '/home',
    );
  }

  Future<void> _initNotificationService() async {
    try { await NotificationService().init(); } catch (_) {}
  }

  Future<void> _preloadGoogleFonts() async {
    try {
      GoogleFonts.lato();
      GoogleFonts.playfairDisplay();
      await GoogleFonts.pendingFonts();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowColor1 = isDark
        ? const Color(0xFF8B5CF6).withValues(alpha: 0.22)
        : const Color(0xFF8B5CF6).withValues(alpha: 0.1);
    final glowColor2 = isDark
        ? const Color(0xFF2563EB).withValues(alpha: 0.18)
        : const Color(0xFF2563EB).withValues(alpha: 0.08);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment(-0.3, -0.4),
                  end: Alignment(0.4, 0.6),
                  colors: [Color(0xFF0E0920), Color(0xFF160D35), Color(0xFF0A1840), Color(0xFF041228)],
                )
              : const LinearGradient(
                  begin: Alignment(-0.3, -0.4),
                  end: Alignment(0.4, 0.6),
                  colors: [Color(0xFFF4F0FF), Color(0xFFECE6FF), Color(0xFFE0EAFF), Color(0xFFD6E8FF)],
                ),
        ),
        child: Stack(
          children: [
            // Glow orbs
            _GlowOrb(top: -80, left: -90, width: 280, height: 280, color: glowColor1),
            _GlowOrb(bottom: -60, right: -70, width: 220, height: 220, color: glowColor2),

            // Floating dots
            ...List.generate(5, (i) {
              final positions = [
                const Alignment(0.14, 0.22),
                const Alignment(0.82, 0.35),
                const Alignment(0.10, 0.60),
                const Alignment(0.76, 0.68),
                const Alignment(0.88, 0.50),
              ];
              final sizes = [4.0, 2.0, 3.0, 2.0, 3.0];
              final opacities = [0.7, 0.5, 0.4, 0.6, 0.3];
              return Positioned.fill(
                child: Align(
                  alignment: positions[i],
                  child: Container(
                    width: sizes[i], height: sizes[i],
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: opacities[i] * 0.15)
                          : const Color(0xFF8B5CF6).withValues(alpha: opacities[i] * 0.12),
                    ),
                  ),
                ),
              );
            }),

            // Center content
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.5 : 0.25),
                              blurRadius: isDark ? 40 : 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset('assets/icon1.png', fit: BoxFit.cover, cacheWidth: 180, cacheHeight: 180),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          text: 'Quot',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2.5,
                            color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                          ),
                          children: [
                            TextSpan(
                              text: 'ify',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2.5,
                                color: isDark ? const Color(0xFFB89DFF) : const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Words that move you',
                        style: GoogleFonts.lato(
                          fontSize: 10, letterSpacing: 3,
                          color: isDark
                              ? const Color(0xFFB4A0FF).withValues(alpha: 0.55)
                              : const Color(0xFF6446B4).withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _LoadingDots(isDark: isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Quote card preview at bottom
            Positioned(
              bottom: 42, left: 12, right: 12,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFF7C3AED).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFF7C3AED).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('\u201C',
                          style: GoogleFonts.playfairDisplay(fontSize: 20, height: 1,
                            color: isDark
                                ? const Color(0xFFB499FF).withValues(alpha: 0.6)
                                : const Color(0xFF7C3AED).withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The only way to do great work is to love what you do.',
                        style: GoogleFonts.lato(fontSize: 10, fontStyle: FontStyle.italic, height: 1.65,
                          color: isDark
                              ? const Color(0xFFDCD7FF).withValues(alpha: 0.82)
                              : const Color(0xFF281E5A).withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('\u2014 Steve Jobs',
                          style: GoogleFonts.lato(fontSize: 9.5, letterSpacing: 0.3,
                            color: isDark
                                ? const Color(0xFFA08CDC).withValues(alpha: 0.55)
                                : const Color(0xFF6446B4).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double? top, bottom, left, right;
  final double width, height;
  final Color color;

  const _GlowOrb({this.top, this.bottom, this.left, this.right, required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: width, height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  final bool isDark;
  const _LoadingDots({required this.isDark});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (t - i * 0.33).clamp(0.0, 1.0);
            final isOn = phase < 0.5 || (phase - 0.5) < 0.3;
            final w = isOn ? 16.0 : 5.0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: w, height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isOn ? 3 : 5),
                color: isOn
                    ? (widget.isDark ? const Color(0xFFB496FF).withValues(alpha: 0.95) : const Color(0xFF7C3AED))
                    : (widget.isDark ? const Color(0xFFA082FF).withValues(alpha: 0.35) : const Color(0xFF7C3AED).withValues(alpha: 0.2)),
              ),
            );
          }),
        );
      },
    );
  }
}

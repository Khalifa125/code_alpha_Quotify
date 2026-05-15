import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/gradient_helper.dart';
import '../../../exports.dart';
import '../../../screens/main_screen.dart';
import '../../../widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F0A1A), Color(0xFF1A1333)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F5FC), Color(0xFFEEEDF5)],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: const [
                    _OnboardingPage(
                      icon: Icons.auto_stories_rounded,
                      title: 'Welcome to Quotify',
                      description:
                          'Discover a world of wisdom with beautiful, handpicked quotes delivered fresh every day. '
                          'Let inspiring words from great minds guide your journey.',
                      subtitle: 'Your daily dose of inspiration',
                    ),
                    _OnboardingPage(
                      icon: Icons.notifications_active_rounded,
                      title: 'Daily Inspiration',
                      description:
                          'Set a daily reminder and receive a handpicked quote every morning. '
                          'Start your day with motivation, wisdom, and positive energy.',
                      subtitle: 'Never miss a moment of inspiration',
                    ),
                    _OnboardingPage(
                      icon: Icons.explore_rounded,
                      title: 'Smart Categories',
                      description:
                          'Browse quotes by mood — from Motivation and Success to Calm and Love. '
                          'Find the perfect words for every moment of your day.',
                      subtitle: 'Quotes for every mood',
                    ),
                    _OnboardingPage(
                      icon: Icons.favorite_rounded,
                      title: 'Save & Share',
                      description:
                          'Build your personal collection of favorites, share quotes as beautiful images, '
                          'and create collections to organize the words that matter most to you.',
                      subtitle: 'Your wisdom, your way',
                    ),
                  ],
                ),
              ),
              _buildBottomSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPageIndicator(isDark),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: _currentPage == 3
                ? _buildGetStartedButton(isDark)
                : _buildNextButton(isDark),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPageIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentPage;
        return AnimatedScale(
          scale: isActive ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive ? GradientHelper.primaryGradient : null,
            color: isActive
                ? null
                : (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive ? [
              BoxShadow(
                color: GradientHelper.primaryColor.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
        ),
        );
      }),
    );
  }

  Widget _buildNextButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: GradientHelper.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: GradientHelper.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next',
                style: GoogleFonts.lato(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(bool isDark) {
    return GestureDetector(
      onTap: _completeOnboarding,
      child: Container(
        decoration: BoxDecoration(
          gradient: GradientHelper.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: GradientHelper.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Get Started',
            style: GoogleFonts.lato(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = GradientHelper.textPrimary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        tintOpacity: isDark ? 0.06 : 0.35,
        blurSigma: 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: GradientHelper.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: GradientHelper.primaryColor.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 56),
            ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.7, 0.7),
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 36),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.15),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: GradientHelper.primaryColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              description,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: mutedColor,
                height: 1.7,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

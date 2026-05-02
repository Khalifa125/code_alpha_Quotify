import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/quote_controller.dart';
import '../core/utils/gradient_helper.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/error_widget.dart';
import '../widgets/gradient_background.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/new_quote_button.dart';
import '../widgets/quote_card.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quoteControllerProvider);
    final isDark = AppTheme.isDarkMode(context);
    final colors = GradientHelper.getGradient(state.gradientIndex);

    return AnimatedGradientBackground(
      gradientIndex: state.gradientIndex,
      isDarkMode: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallHeight = constraints.maxHeight < 600;
              
              return Column(
                children: [
                  _buildHeader(context, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildContent(context, ref, state, isDark, colors, isSmallHeight),
                    ),
                  ),
                  if (!isSmallHeight) _buildBottomSection(context, ref, state),
                  _buildBottomNavBar(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quotify',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Random Quote Generator',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : const Color(0xFF6b7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          _buildThemeToggle(context, isDark, themeMode),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark, ThemeMode currentMode) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final newMode = currentMode == ThemeMode.light 
            ? ThemeMode.dark 
            : ThemeMode.light;
        ref.read(themeModeProvider.notifier).state = newMode;
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            currentMode == ThemeMode.dark 
                ? Icons.dark_mode_rounded 
                : Icons.light_mode_rounded,
            key: ValueKey(currentMode),
            size: 22,
            color: isDark ? Colors.white70 : const Color(0xFF4b5563),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    QuoteState state,
    bool isDark,
    List<Color> colors,
    bool isSmallHeight,
  ) {
    if (state.isLoading && state.quote == null) {
      return const Center(child: LoadingSkeleton());
    }

    if (state.hasError && state.quote == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: QuoteErrorWidget(
          failure: state.error!,
          onRetry: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        ),
      );
    }

    if (state.quote != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: QuoteCard(
          key: ValueKey(state.quote!.text.hashCode),
          quote: state.quote!,
          gradientIndex: state.gradientIndex,
          onCopy: () => _copyToClipboard(context, ref),
          onShare: () => _shareQuote(context, ref),
          isSmallScreen: isSmallHeight,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _copyToClipboard(BuildContext context, WidgetRef ref) {
    final quote = ref.read(quoteControllerProvider).quote;
    if (quote != null) {
      Clipboard.setData(ClipboardData(text: quote.formattedQuote));
      HapticFeedback.lightImpact();
      _showSnackBar(context, 'Quote copied to clipboard!', ref);
    }
  }

  void _shareQuote(BuildContext context, WidgetRef ref) {
    final quote = ref.read(quoteControllerProvider).quote;
    if (quote != null) {
      HapticFeedback.lightImpact();
      final shareText = '"${quote.text}"\n\n— ${quote.author}\n\n✨ Shared via Quotify';
      try {
        Share.share(
          shareText,
          subject: 'Inspirational Quote from Quotify',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, WidgetRef ref) {
    final colors = GradientHelper.getGradient(
      ref.read(quoteControllerProvider).gradientIndex,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.lato(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: colors[0],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, WidgetRef ref, QuoteState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: NewQuoteButton(
        onTap: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        isLoading: state.isLoading,
        gradientIndex: state.gradientIndex,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        if (index == 2) {
          _showSettingsDialog(context);
        }
      },
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.2);
  }

  void _showSettingsDialog(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final themeMode = ref.read(themeModeProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Settings',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1a1a2e),
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsItem(
              context,
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
              onTap: () {
                final newMode = themeMode == ThemeMode.light 
                    ? ThemeMode.dark 
                    : ThemeMode.light;
                ref.read(themeModeProvider.notifier).state = newMode;
                Navigator.pop(context);
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF667eea),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF6b7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
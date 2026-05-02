import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/quote_controller.dart';
import '../core/utils/gradient_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/error_widget.dart';
import '../widgets/gradient_background.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/new_quote_button.dart';
import '../widgets/quote_card.dart';

class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoteControllerProvider);
    final isDark = AppTheme.isDarkMode(context);
    final colors = GradientHelper.getGradient(state.gradientIndex);

    return AnimatedGradientBackground(
      gradientIndex: state.gradientIndex,
      isDarkMode: isDark,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: _buildContent(context, ref, state, isDark, colors),
            ),
            _buildBottomSection(context, ref, state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF667eea),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Quotify',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1a1a2e),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    QuoteState state,
    bool isDark,
    List<Color> colors,
  ) {
    if (state.isLoading && state.quote == null) {
      return const LoadingSkeleton();
    }

    if (state.hasError && state.quote == null) {
      return QuoteErrorWidget(
        failure: state.error!,
        onRetry: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
      );
    }

    if (state.quote != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: QuoteCard(
          key: ValueKey(state.quote!.text.hashCode),
          quote: state.quote!,
          gradientIndex: state.gradientIndex,
          onCopy: () => _copyToClipboard(context, ref),
          onShare: () => _shareQuote(context, ref),
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
      _shareText(context, shareText);
    }
  }

  void _shareText(BuildContext context, String text) {
    try {
      Share.share(
        text,
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
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: NewQuoteButton(
        onTap: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        isLoading: state.isLoading,
        gradientIndex: state.gradientIndex,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2);
  }
}
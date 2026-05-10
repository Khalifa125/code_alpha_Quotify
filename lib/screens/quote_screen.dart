import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/gradient_helper.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/mood_chips.dart';
import '../widgets/new_quote_button.dart';
import '../widgets/quote_card.dart';

class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoteControllerProvider);
    final isDark = AppTheme.isDarkMode(context);
    final isSmallHeight = MediaQuery.of(context).size.height < 600;
    final showSwipeHint = ref.watch(showSwipeHintProvider);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context, isDark, ref),
                  const MoodChips(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(quoteControllerProvider.notifier).fetchQuote();
                      },
                      color: GradientHelper.primaryColor,
                      backgroundColor: isDark ? const Color(0xFF1A1333) : Colors.white,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildContent(context, ref, state, isDark, isSmallHeight),
                      ),
                    ),
                  ),
                  if (!isSmallHeight) _buildBottomSection(context, ref, state),
                  const SizedBox(height: 8),
                ],
              ),
              if (showSwipeHint) _SwipeHintOverlay(onDismiss: () {
                ref.read(showSwipeHintProvider.notifier).state = false;
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, WidgetRef ref) {
    final textColor = GradientHelper.textPrimary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quotify',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: GradientHelper.primaryGradient,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Daily Inspiration',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildThemeToggle(context, ref),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = AppTheme.isDarkMode(context);
    final textColor = GradientHelper.textPrimary(isDark);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(themeModeProvider.notifier).state = 
          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: themeMode == ThemeMode.dark ? GradientHelper.primaryGradient : null,
          color: themeMode == ThemeMode.light 
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04))
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: GradientHelper.primaryColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            key: ValueKey(themeMode),
            size: 20,
            color: themeMode == ThemeMode.dark ? Colors.white : textColor,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, QuoteState state, bool isDark, bool isSmallHeight) {
    if (state.isLoading && state.quote == null) {
      return const Center(child: LoadingSkeleton());
    }
    if (state.error != null && state.quote == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: QuoteErrorWidget(
          message: state.error!, 
          onRetry: () => ref.read(quoteControllerProvider.notifier).fetchQuote()
        ),
      );
    }
    if (state.quote != null) {
      final favorites = ref.watch(favoritesProvider);
      final isFavorite = favorites.any((q) => q.text == state.quote!.text && q.author == state.quote!.author);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            QuoteCard(
              key: ValueKey(state.quote!.text.hashCode),
              quote: state.quote!,
              gradientIndex: state.gradientIndex,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: state.quote!.formattedQuote));
                HapticFeedback.lightImpact();
              },
              onShare: () {
                HapticFeedback.lightImpact();
                Share.share(
                  '"${state.quote!.text}"\n\n— ${state.quote!.author}\n\n✨ Shared via Quotify',
                  subject: 'Inspirational Quote from Quotify'
                );
              },
              onShareImage: () {
                HapticFeedback.mediumImpact();
                Share.share(
                  '📸 "${state.quote!.text}"\n\n— ${state.quote!.author}\n\n✨ Get inspired daily with Quotify!',
                  subject: 'Beautiful Quote from Quotify'
                );
              },
              onFavorite: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(state.quote!);
                HapticFeedback.lightImpact();
              },
              onNext: () => ref.read(quoteControllerProvider.notifier).nextQuote(),
              onPrevious: () => ref.read(quoteControllerProvider.notifier).previousQuote(),
              isFavorite: isFavorite,
              isSmallScreen: isSmallHeight,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomSection(BuildContext context, WidgetRef ref, QuoteState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: NewQuoteButton(
        onTap: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        isLoading: state.isLoading,
        gradientIndex: state.gradientIndex,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2);
  }
}

class _SwipeHintOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _SwipeHintOverlay({required this.onDismiss});

  @override
  State<_SwipeHintOverlay> createState() => _SwipeHintOverlayState();
}

class _SwipeHintOverlayState extends State<_SwipeHintOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe, size: 18, color: isDark ? Colors.white54 : Colors.black38),
              const SizedBox(width: 8),
              Text(
                '← swipe →',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).then(delay: 3000.ms).fadeOut(duration: 500.ms),
    );
  }
}
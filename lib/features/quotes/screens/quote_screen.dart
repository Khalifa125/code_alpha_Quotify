import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../providers.dart';
import '../../../../models/quote.dart';
import '../../../../models/collection.dart';
import '../../../../widgets/error_widget.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/loading_skeleton.dart';
import '../../../../widgets/mood_chips.dart';
import '../../../../widgets/new_quote_button.dart';
import '../widgets/modern_quote_card.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  final _searchController = TextEditingController();
  final _screenshotController = ScreenshotController();
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(quoteSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quoteControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  if (_isSearching) _buildSearchBar(isDark),
                  const MoodChips(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(quoteControllerProvider.notifier).fetchQuote();
                      },
                      color: GradientHelper.primaryColor,
                      backgroundColor: isDark ? const Color(0xFF1A1333) : Colors.white,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildContent(context, ref, state, isDark, isSmallHeight, _screenshotController),
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
          if (!_isSearching) ...[
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
          ] else
            Expanded(child: Container()),
          Row(
            children: [
              if (!_isSearching)
                _HeaderButton(
                  icon: Icons.search_rounded,
                  onTap: () => setState(() => _isSearching = true),
                  isDark: isDark,
                  tooltip: 'Search quotes',
                ),
              const SizedBox(width: 8),
              _buildThemeToggle(context, ref, isDark, textColor),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _buildSearchBar(bool isDark) {
    return GlassContainer.adaptive(
      context: context,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 16,
      blurSigma: 6,
      opacity: 0.08,
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.lato(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search quotes, authors...',
                hintStyle: GoogleFonts.lato(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                ref.read(quoteSearchQueryProvider.notifier).state = '';
              });
              FocusScope.of(context).unfocus();
            },
            child: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref, bool isDark, Color textColor) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Semantics(
      label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: Tooltip(
        message: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final isSystemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final actuallyDark = themeMode == ThemeMode.system ? isSystemDark : isDarkMode;
        ref.read(themeModeProvider.notifier).state =
            actuallyDark ? ThemeMode.light : ThemeMode.dark;
      },
      child: GlassContainer.adaptive(
        context: context,
        width: 44,
        height: 44,
        borderRadius: 14,
        blurSigma: 6,
        opacity: themeMode == ThemeMode.dark ? 0.0 : 0.1,
        gradient: themeMode == ThemeMode.dark ? GradientHelper.primaryGradient : null,
        boxShadow: themeMode == ThemeMode.dark
            ? [
                BoxShadow(
                  color: GradientHelper.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
      ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, QuoteState state, bool isDark, bool isSmallHeight, ScreenshotController controller) {
    if (state.isLoading && state.quote == null) {
      return const Center(child: LoadingSkeleton());
    }
    if (state.error != null && state.quote == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: QuoteErrorWidget(
          message: state.error!,
          onRetry: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        ),
      );
    }
    if (state.quote != null) {
      final isFavorite = ref.watch(favoritesProvider.select((f) =>
        f.any((q) => q.text == state.quote!.text && q.author == state.quote!.author)));
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ModernQuoteCard(
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
                  subject: 'Inspirational Quote from Quotify',
                );
              },
              onShareImage: () async {
                HapticFeedback.mediumImpact();
                final image = await controller.capture();
                if (image != null) {
                  final dir = await getTemporaryDirectory();
                  final file = File('${dir.path}/quotify_share.png');
                  await file.writeAsBytes(image);
                  await Share.shareXFiles([XFile(file.path)]);
                  try { await file.delete(); } catch (_) {}
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not capture quote image. Try again.')),
                  );
                }
              },
              onFavorite: () {
                final quote = state.quote!;
                final wasFavorite = ref.read(favoritesProvider.notifier).isFavorite(quote);
                ref.read(favoritesProvider.notifier).toggleFavorite(quote);
                HapticFeedback.lightImpact();
                if (wasFavorite && context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Quote removed from favorites'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(quote),
                      ),
                    ),
                  );
                }
              },
              onAddToCollection: () => _showCollectionDialog(context, ref, state.quote!),
              onNext: () => ref.read(quoteControllerProvider.notifier).nextQuote(),
              onPrevious: () => ref.read(quoteControllerProvider.notifier).previousQuote(),
              isFavorite: isFavorite,
              isSmallScreen: isSmallHeight,
              screenshotController: controller,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomSection(BuildContext context, WidgetRef ref, QuoteState state) {
    final isTabActive = ref.watch(currentTabIndexProvider) == 0;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: NewQuoteButton(
        onTap: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        isLoading: state.isLoading,
        gradientIndex: state.gradientIndex,
        isTabActive: isTabActive,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  void _showCollectionDialog(BuildContext context, WidgetRef ref, Quote quote) {
    final collections = ref.read(collectionsProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CollectionPickerSheet(
        collections: collections,
        isDark: Theme.of(context).brightness == Brightness.dark,
        onSelect: (collectionId) {
          ref.read(collectionsProvider.notifier).addQuoteToCollection(
            collectionId,
            quote.text.hashCode.toString(),
          );
          Navigator.pop(context);
          HapticFeedback.lightImpact();
        },
        onCreateNew: () {
          Navigator.pop(context);
          _showCreateCollectionDialog(context, ref, quote);
        },
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref, Quote quote) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _NewDeckSheet(quote: quote, isDark: isDark),
    ).then((result) async {
      if (result != null && context.mounted) {
        final name = result['name'] as String;
        final id = await ref.read(collectionsProvider.notifier).createCollection(name);
        await ref.read(collectionsProvider.notifier).addQuoteToCollection(
          id,
          quote.text.hashCode.toString(),
        );
        HapticFeedback.lightImpact();
      }
    });
  }
}

class _CollectionPickerSheet extends StatelessWidget {
  final List<Collection> collections;
  final bool isDark;
  final void Function(String) onSelect;
  final VoidCallback onCreateNew;

  const _CollectionPickerSheet({
    required this.collections,
    required this.isDark,
    required this.onSelect,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      tintOpacity: isDark ? 0.08 : 0.45,
      blurSigma: 12,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add to Collection',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E1B2E)),
          ),
          const SizedBox(height: 16),
          if (collections.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No collections yet',
                style: GoogleFonts.lato(color: isDark ? Colors.white38 : Colors.black45)),
            )
          else
            ...collections.map((c) => GestureDetector(
              onTap: () => onSelect(c.id),
              child: GlassContainer.adaptive(
                context: context,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 14,
                blurSigma: 4,
                opacity: 0.08,
                child: Row(children: [
                  const Icon(Icons.collections_bookmark_rounded, size: 20,
                    color: GradientHelper.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(c.name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87))),
                  Text('${c.quoteIds.length}',
                    style: GoogleFonts.lato(color: isDark ? Colors.white38 : Colors.black45)),
                ]),
              ),
            )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onCreateNew,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: GradientHelper.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text('New Collection',
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              )),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
        ],
      ),
      ),
      ),
    );
  }
}

class _NewDeckSheet extends StatefulWidget {
  final Quote quote;
  final bool isDark;

  const _NewDeckSheet({required this.quote, required this.isDark});

  @override
  State<_NewDeckSheet> createState() => _NewDeckSheetState();
}

class _NewDeckSheetState extends State<_NewDeckSheet> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColor = 0;

  static const List<Color> _deckColors = [
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
    Color(0xFF3B82F6),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFF84CC16),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFFA855F7),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      tintOpacity: widget.isDark ? 0.08 : 0.45,
      blurSigma: 12,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 40, height: 4, alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('New Deck',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : const Color(0xFF1E1B2E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Deck name',
              hintStyle: GoogleFonts.lato(
                color: widget.isDark ? Colors.white38 : Colors.black38),
              filled: true,
              fillColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.lato(
              color: widget.isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 20),
          Text('Deck Color',
            style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w500,
              color: widget.isDark ? Colors.white54 : Colors.black54),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_deckColors.length, (i) {
              final isSelected = i == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _deckColors[i],
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _deckColors[i].withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, {'name': name, 'color': _selectedColor});
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: GradientHelper.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('Create Deck',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
        ],
      ),
      ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String tooltip;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
      onTap: onTap,
      child: GlassContainer.adaptive(
        context: context,
        width: 44,
        height: 44,
        borderRadius: 14,
        blurSigma: 6,
        opacity: 0.1,
        padding: const EdgeInsets.all(0),
        child: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
      ),
      ),
    );
  }
}

class _SwipeHintOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _SwipeHintOverlay({required this.onDismiss});

  @override
  State<_SwipeHintOverlay> createState() => _SwipeHintOverlayState();
}

class _SwipeHintOverlayState extends State<_SwipeHintOverlay> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25,
      left: 0,
      right: 0,
      child: Center(
        child: GlassContainer.adaptive(
          context: context,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 20,
          blurSigma: 6,
          opacity: 0.06,
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

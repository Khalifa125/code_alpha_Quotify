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
import '../../../../theme/app_theme.dart';
import '../../../../providers.dart';
import '../../../../models/quote.dart';
import '../../../../models/collection.dart';
import '../../../../widgets/error_widget.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
        ),
      ),
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
              ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.04))
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: GradientHelper.primaryColor.withOpacity(0.2),
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

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic state, bool isDark, bool isSmallHeight, ScreenshotController controller) {
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
      final favorites = ref.watch(favoritesProvider);
      final isFavorite = favorites.any((q) => q.text == state.quote!.text && q.author == state.quote!.author);
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
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: '"${state.quote!.text}"\n\n— ${state.quote!.author}',
                  );
                }
              },
              onFavorite: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(state.quote!);
                HapticFeedback.lightImpact();
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

  Widget _buildBottomSection(BuildContext context, WidgetRef ref, dynamic state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: NewQuoteButton(
        onTap: () => ref.read(quoteControllerProvider.notifier).fetchQuote(),
        isLoading: state.isLoading,
        gradientIndex: state.gradientIndex,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  void _showCollectionDialog(BuildContext context, WidgetRef ref, Quote quote) {
    final collections = ref.read(collectionsProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1333) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('New Collection',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Collection name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await ref.read(collectionsProvider.notifier).createCollection(name);
                final collections = ref.read(collectionsProvider);
                if (collections.isNotEmpty) {
                  await ref.read(collectionsProvider.notifier).addQuoteToCollection(
                    collections.last.id,
                    quote.text.hashCode.toString(),
                  );
                }
                HapticFeedback.lightImpact();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text('Create',
              style: TextStyle(color: GradientHelper.primaryColor)),
          ),
        ],
      ),
    );
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1333) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Icon(Icons.collections_bookmark_rounded, size: 20,
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
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
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

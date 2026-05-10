import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/gradient_helper.dart';
import '../models/quote.dart';
import '../providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    final filteredFavorites = searchQuery.isEmpty
        ? favorites
        : favorites.where((q) => 
            q.text.toLowerCase().contains(searchQuery.toLowerCase()) ||
            q.author.toLowerCase().contains(searchQuery.toLowerCase())
          ).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, favorites.length),
            _buildSearchBar(context, isDark, searchQuery),
            Expanded(
              child: filteredFavorites.isEmpty
                  ? (favorites.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildNoResultsState(isDark))
                  : _buildFavoritesList(context, ref, filteredFavorites, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, int count) {
    final textColor = GradientHelper.textPrimary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favorites',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count saved quote${count != 1 ? 's' : ''}',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _buildSearchBar(BuildContext context, bool isDark, String searchQuery) {
    final textColor = GradientHelper.textPrimary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: GoogleFonts.lato(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search favorites...',
            hintStyle: GoogleFonts.lato(color: mutedColor, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: mutedColor, size: 22),
            suffixIcon: searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                    child: Icon(Icons.close_rounded, color: mutedColor, size: 20),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildEmptyState(bool isDark) {
    final textSecondary = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _FloatingHeart(),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any quote\nto save it here',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: mutedColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    final textSecondary = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: mutedColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No results found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: mutedColor,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
    );
  }

  Widget _buildFavoritesList(BuildContext context, WidgetRef ref, List<Quote> favorites, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final quote = favorites[index];
        return Dismissible(
          key: ValueKey(quote.text.hashCode + quote.author.hashCode),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
          ),
          onDismissed: (_) {
            ref.read(favoritesProvider.notifier).removeFavorite(quote);
            _showUndoSnackbar(context, ref, quote);
          },
          child: _FavoriteQuoteCard(
            quote: quote,
            isDark: isDark,
            onShare: () => _shareQuote(quote),
            onCopy: () => _copyQuote(context, quote),
          ),
        );
      },
    );
  }

  void _shareQuote(Quote quote) {
    HapticFeedback.lightImpact();
    Share.share(
      '"${quote.text}"\n\n— ${quote.author}\n\n✨ Shared via Quotify',
      subject: 'Inspirational Quote from Quotify'
    );
  }

  void _copyQuote(BuildContext context, Quote quote) {
    Clipboard.setData(ClipboardData(text: quote.formattedQuote));
    HapticFeedback.lightImpact();
  }

  void _showUndoSnackbar(BuildContext context, WidgetRef ref, Quote quote) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Removed', style: GoogleFonts.lato(fontWeight: FontWeight.w500)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ref.read(favoritesProvider.notifier).restoreFavorite(quote);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'UNDO',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () => ref.read(favoritesProvider.notifier).restoreFavorite(quote),
        ),
      ),
    );
  }
}

class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart();

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -10 + (_controller.value * 20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_border_rounded,
            size: 56,
            color: const Color(0xFFEC4899).withValues(alpha: 0.5 + (_controller.value * 0.3)),
          ),
        ),
      ),
    );
  }
}

class _FavoriteQuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isDark;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const _FavoriteQuoteCard({
    required this.quote,
    required this.isDark,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = GradientHelper.textPrimary(isDark);
    final textSecondary = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: GradientHelper.cardBackground(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GradientHelper.cardBorder(isDark),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quote.text,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                  height: 1.5,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 1,
                                    decoration: BoxDecoration(
                                      color: mutedColor.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    quote.author,
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.favorite_rounded,
                          color: const Color(0xFFEC4899).withValues(alpha: 0.8),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 8, bottom: 12),
                    child: Row(
                      children: [
                        _MiniActionButton(
                          icon: Icons.copy_rounded,
                          label: 'Copy',
                          onTap: onCopy,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _MiniActionButton(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          onTap: onShare,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: mutedColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
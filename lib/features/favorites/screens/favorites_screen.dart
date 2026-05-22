
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../models/quote.dart';
import '../../../../providers.dart';
import '../../../../widgets/glass_container.dart';

enum SortOrder { newest, oldest, author, category }

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isSearching = false;
  SortOrder _sortOrder = SortOrder.newest;
  final TextEditingController _searchController = TextEditingController();
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
      ref.read(favoritesSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final searchQuery = ref.watch(favoritesSearchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredFavorites = () {
      var result = searchQuery.isEmpty
          ? favorites
          : favorites.where((q) {
              final query = searchQuery.toLowerCase();
              return q.text.toLowerCase().contains(query) ||
                  q.author.toLowerCase().contains(query) ||
                  q.category.toLowerCase().contains(query);
            }).toList();
      switch (_sortOrder) {
        case SortOrder.newest:
          break;
        case SortOrder.oldest:
          result = result.reversed.toList();
          break;
        case SortOrder.author:
          result = List.from(result)..sort((a, b) => a.author.compareTo(b.author));
          break;
        case SortOrder.category:
          result = List.from(result)..sort((a, b) => a.category.compareTo(b.category));
          break;
      }
      return result;
    }();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(favoritesProvider);
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            sliver: SliverToBoxAdapter(
              child: _buildHeader(context, isDark, favorites, ref),
            ),
          ),
          if (_isSearching)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _buildSearchBar(isDark, ref),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: filteredFavorites.isEmpty
                ? SliverFillRemaining(
                    child: _buildEmptyState(isDark, searchQuery.isEmpty),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= filteredFavorites.length) {
                          return const SizedBox.shrink();
                        }
                        final quote = filteredFavorites[index];
                        return _FavoriteQuoteCard(
                          key: ValueKey(quote.text.hashCode),
                          quote: quote,
                          isDark: isDark,
                          onRemove: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(quote);
                            HapticFeedback.mediumImpact();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Quote removed'),
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
                          onShare: () {
                            Share.share(
                              '"${quote.text}"\n\n— ${quote.author}',
                              subject: 'Inspirational Quote',
                            );
                          },
                        );
                      },
                      childCount: filteredFavorites.length,
                      addAutomaticKeepAlives: true,
                    ),
                  ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, List<Quote> favorites, WidgetRef ref) {
    final textColor = GradientHelper.textPrimary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favorites',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${favorites.length} saved quotes',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: mutedColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (!_isSearching)
              _HeaderButton(
                icon: Icons.search_rounded,
                onTap: () => setState(() => _isSearching = true),
                isDark: isDark,
                tooltip: 'Search favorites',
              ),
            const SizedBox(width: 8),
            _HeaderButton(
              icon: Icons.sort_rounded,
              onTap: () => _showSortSheet(isDark),
              isDark: isDark,
              tooltip: 'Sort favorites',
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _buildSearchBar(bool isDark, WidgetRef ref) {
    return GlassContainer.adaptive(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 16,
      blurSigma: 6,
      opacity: 0.08,
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black38, size: 20),
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
                ref.read(favoritesSearchQueryProvider.notifier).state = '';
              });
              FocusScope.of(context).unfocus();
            },
            child: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildEmptyState(bool isDark, bool isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassIconContainer(
            icon: isEmpty ? Icons.favorite_outline_rounded : Icons.search_off_rounded,
            size: 36,
            containerSize: 88,
            borderRadius: 24,
          ),
          const SizedBox(height: 20),
          Text(
            isEmpty ? 'No favorites yet' : 'No results found',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEmpty
                ? 'Swipe up on quotes to add them here'
                : 'Try a different search term',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => _SortSheet(
        currentSort: _sortOrder,
        isDark: isDark,
        onSortChanged: (order) {
          Navigator.pop(context);
          setState(() => _sortOrder = order);
        },
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final SortOrder currentSort;
  final bool isDark;
  final void Function(SortOrder) onSortChanged;

  const _SortSheet({
    required this.currentSort,
    required this.isDark,
    required this.onSortChanged,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort Favorites',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E1B2E),
            ),
          ),
          const SizedBox(height: 16),
          ...SortOrder.values.map((order) => _SortOption(
            order: order,
            isSelected: order == currentSort,
            isDark: isDark,
            onTap: () => onSortChanged(order),
          )),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final SortOrder order;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SortOption({
    required this.order,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  IconData get _icon {
    switch (order) {
      case SortOrder.newest: return Icons.access_time_rounded;
      case SortOrder.oldest: return Icons.history_rounded;
      case SortOrder.author: return Icons.sort_by_alpha_rounded;
      case SortOrder.category: return Icons.category_rounded;
    }
  }

  String get _label {
    switch (order) {
      case SortOrder.newest: return 'Newest First';
      case SortOrder.oldest: return 'Oldest First';
      case SortOrder.author: return 'By Author';
      case SortOrder.category: return 'By Category';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? GradientHelper.primaryGradient : null,
            color: isSelected ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(_icon, size: 20,
                color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45)),
              const SizedBox(width: 12),
              Text(_label, style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              )),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteQuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback onShare;

  const _FavoriteQuoteCard({
    required this.quote,
    required this.isDark,
    required this.onRemove,
    required this.onShare,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = GradientHelper.textPrimary(isDark);
    final secondaryColor = GradientHelper.textSecondary(isDark);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      blurSigma: 8,
      tintOpacity: isDark ? 0.04 : 0.3,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassContainer.adaptive(
                context: context,
                borderRadius: 10,
                blurSigma: 4,
                opacity: 0.08,
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: GradientHelper.primaryColor.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onShare,
                child: Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onRemove,
                child: GlassContainer.adaptive(
                  context: context,
                  borderRadius: 10,
                  blurSigma: 4,
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.delete_rounded,
                    size: 16,
                    color: Color(0xFFFF3366),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote.text,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            '— ${quote.author}',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: secondaryColor,
              letterSpacing: 0.5,
            ),
          ),
          if (quote.category != 'All') ...[
            const SizedBox(height: 8),
            GlassContainer.adaptive(
              context: context,
              borderRadius: 8,
              blurSigma: 4,
              opacity: 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(
                quote.category,
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: GradientHelper.primaryColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
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

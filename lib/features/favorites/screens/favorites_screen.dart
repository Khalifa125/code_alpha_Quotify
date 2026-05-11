// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/quote.dart';
import '../../../../providers.dart';

enum SortOrder { newest, oldest, author, category }

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  SortOrder _sortOrder = SortOrder.newest;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more if needed
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
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
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            sliver: SliverToBoxAdapter(
              child: _buildHeader(context, isDark, ref),
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
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, WidgetRef ref) {
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
              '${ref.watch(favoritesProvider).length} saved quotes',
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
              ),
            const SizedBox(width: 8),
            _HeaderButton(
              icon: Icons.sort_rounded,
              onTap: () => _showSortSheet(isDark),
              isDark: isDark,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _buildSearchBar(bool isDark, WidgetRef ref) {
    return Container(
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
                ref.read(searchQueryProvider.notifier).state = '';
              });
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
                    : [Colors.black.withOpacity(0.03), Colors.black.withOpacity(0.01)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isEmpty ? Icons.favorite_outline_rounded : Icons.search_off_rounded,
              size: 36,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
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
            color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.02)]
              : [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 20,
                  color: GradientHelper.primaryColor.withOpacity(0.6),
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
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: GradientHelper.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
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
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
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

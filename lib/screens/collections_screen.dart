import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';
import '../models/collection.dart';
import '../models/quote.dart';
import '../providers.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: collections.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildCollectionsGrid(context, isDark, collections),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(isDark),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final textColor = GradientHelper.textPrimary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.folder_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collections',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organize your favorite quotes',
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

  Widget _buildEmptyState(bool isDark) {
    final textSecondary = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BouncingFolders(),
          const SizedBox(height: 24),
          Text(
            'No collections yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a collection to\norganize your favorite quotes',
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

  Widget _buildCollectionsGrid(BuildContext context, bool isDark, List<Collection> collections) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _CollectionCard(
          collection: collection,
          isDark: isDark,
          index: index,
          onTap: () => _openCollection(context, collection),
          onDelete: () => _deleteCollection(collection),
        );
      },
    );
  }

  Widget _buildAddButton(bool isDark) {
    return FloatingActionButton(
      onPressed: () => _showCreateDialog(context, isDark),
      backgroundColor: GradientHelper.primaryColor,
      child: const Icon(Icons.add_rounded, color: Colors.white),
    ).animate().scale(delay: 300.ms, duration: 400.ms, begin: const Offset(0, 0));
  }

  void _showCreateDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1333) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'New Collection',
          style: GoogleFonts.playfairDisplay(
            color: isDark ? Colors.white : const Color(0xFF1E1B2E),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.lato(color: isDark ? Colors.white : const Color(0xFF1E1B2E)),
          decoration: InputDecoration(
            hintText: 'Collection name',
            hintStyle: GoogleFonts.lato(color: isDark ? Colors.white38 : Colors.black26),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.lato(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(collectionsProvider.notifier).createCollection(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GradientHelper.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Create', style: GoogleFonts.lato(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openCollection(BuildContext context, Collection collection) {
    Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _CollectionDetailScreen(collection: collection),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _deleteCollection(Collection collection) {
    HapticFeedback.mediumImpact();
    ref.read(collectionsProvider.notifier).deleteCollection(collection.id);
  }
}

class _CollectionDetailScreen extends ConsumerWidget {
  final Collection collection;

  const _CollectionDetailScreen({required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collections = ref.watch(collectionsProvider);
    final currentCollection = collections.firstWhere((c) => c.id == collection.id, orElse: () => collection);
    final favorites = ref.watch(favoritesProvider);
    final collectionQuotes = favorites.where((q) => currentCollection.quoteIds.contains(q.text.hashCode.toString())).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, currentCollection.name, collectionQuotes.length),
            Expanded(
              child: collectionQuotes.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildQuotesList(context, isDark, collectionQuotes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, String name, int count) {
    final textColor = GradientHelper.textPrimary(isDark);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '$count quote${count != 1 ? 's' : ''}',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : const Color(0xFF9B9B9B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No quotes in this collection',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: isDark ? Colors.white54 : const Color(0xFF9B9B9B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesList(BuildContext context, bool isDark, List<Quote> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final quote = favorites[index];
        return _CollectionQuoteCard(quote: quote, isDark: isDark);
      },
    );
  }
}

class _CollectionQuoteCard extends StatelessWidget {
  final dynamic quote;
  final bool isDark;

  const _CollectionQuoteCard({required this.quote, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = GradientHelper.textPrimary(isDark);
    final textSecondary = GradientHelper.textSecondary(isDark);
    final mutedColor = GradientHelper.textMuted(isDark);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GradientHelper.cardBackground(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GradientHelper.cardBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote.text,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              color: textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 16, height: 1, color: mutedColor.withValues(alpha: 0.5)),
              const SizedBox(width: 10),
              Text(quote.author, style: GoogleFonts.lato(fontSize: 13, fontStyle: FontStyle.italic, color: textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Collection collection;
  final bool isDark;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CollectionCard({
    required this.collection,
    required this.isDark,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    [Color(0xFFEC4899), Color(0xFFF43F5E)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFF3B82F6), Color(0xFF2563EB)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context),
      child: Hero(
        tag: 'collection_${collection.id}',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_rounded, color: Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  collection.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${collection.quoteIds.length} quote${collection.quoteIds.length != 1 ? 's' : ''}',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Collection?', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
        content: Text('This will delete "${collection.name}" and all its quotes.', style: GoogleFonts.lato()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _BouncingFolders extends StatefulWidget {
  const _BouncingFolders();

  @override
  State<_BouncingFolders> createState() => _BouncingFoldersState();
}

class _BouncingFoldersState extends State<_BouncingFolders> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
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
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final value = (_controller.value + delay) % 1.0;
          final offset = -8 + (value * 16);
          return Transform.translate(
            offset: Offset(0, offset),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.folder_rounded,
                size: 40,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.5 + (0.5 * (1 - value))),
              ),
            ),
          );
        }),
      ),
    );
  }
}
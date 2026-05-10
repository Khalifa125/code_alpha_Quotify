import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';
import '../providers.dart';
import '../services/quote_service.dart';

class MoodChips extends ConsumerWidget {
  const MoodChips({super.key});

  static const Map<String, String> _moodEmojis = {
    'All': '✨',
    'Motivated': '🔥',
    'Calm': '😌',
    'Funny': '😂',
    'Sad': '😢',
    'Love': '❤️',
    'Success': '🏆',
    'Growth': '🌱',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const categories = QuoteService.categories;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _MoodChip(
              label: category,
              emoji: _moodEmojis[category] ?? '✨',
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(selectedCategoryProvider.notifier).state = category;
                ref.read(quoteControllerProvider.notifier).fetchByCategory(category);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _MoodChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? GradientHelper.primaryGradient : null,
          color: isSelected 
              ? null 
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: GradientHelper.primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
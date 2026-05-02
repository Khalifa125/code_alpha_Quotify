import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuoteMark(baseColor),
            const SizedBox(height: 32),
            _buildTextLine(width: double.infinity, baseColor: baseColor),
            const SizedBox(height: 16),
            _buildTextLine(width: MediaQuery.of(context).size.width * 0.85, baseColor: baseColor),
            const SizedBox(height: 16),
            _buildTextLine(width: MediaQuery.of(context).size.width * 0.7, baseColor: baseColor),
            const SizedBox(height: 16),
            _buildTextLine(width: MediaQuery.of(context).size.width * 0.5, baseColor: baseColor),
            const SizedBox(height: 48),
            _buildAuthorLine(baseColor: baseColor, highlightColor: highlightColor),
            const SizedBox(height: 48),
            _buildActionButtons(baseColor: baseColor, highlightColor: highlightColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteMark(Color baseColor) {
    return Text(
      '"',
      style: GoogleFonts.playfairDisplay(
        fontSize: 100,
        fontWeight: FontWeight.bold,
        color: baseColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildTextLine({required double width, required Color baseColor}) {
    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildAuthorLine({required Color baseColor, required Color highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 120,
          height: 16,
          decoration: BoxDecoration(
            color: highlightColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons({required Color baseColor, required Color highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButtonSkeleton(baseColor),
        const SizedBox(width: 16),
        _buildButtonSkeleton(baseColor),
      ],
    );
  }

  Widget _buildButtonSkeleton(Color baseColor) {
    return Container(
      width: 100,
      height: 44,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
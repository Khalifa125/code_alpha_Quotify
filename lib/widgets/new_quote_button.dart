import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/gradient_helper.dart';

class NewQuoteButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final int gradientIndex;
  final bool isTabActive;

  const NewQuoteButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.gradientIndex,
    this.isTabActive = true,
  });

  @override
  State<NewQuoteButton> createState() => _NewQuoteButtonState();
}

class _NewQuoteButtonState extends State<NewQuoteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    if (!widget.isLoading && widget.isTabActive) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(NewQuoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _shimmerController.stop();
      } else if (widget.isTabActive) {
        _shimmerController.repeat();
      }
    }
    if (widget.isTabActive != oldWidget.isTabActive) {
      if (widget.isTabActive && !widget.isLoading) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _scaleController.forward(),
      onTapUp: widget.isLoading ? null : (_) {
        _scaleController.reverse();
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: widget.isLoading ? null : () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _shimmerController]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            decoration: BoxDecoration(
              gradient: GradientHelper.buttonGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: GradientHelper.primaryColor.withOpacity( 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: GradientHelper.secondaryColor.withOpacity( 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          'New Quote',
          style: GoogleFonts.lato(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white70,
          size: 18,
        ),
      ],
    );
  }
}
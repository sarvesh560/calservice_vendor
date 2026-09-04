import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_motion.dart';

class OnboardingPageContent extends StatefulWidget {
  const OnboardingPageContent({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.isActive,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool isActive;

  @override
  State<OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<OnboardingPageContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _eyebrowOpacity;
  late final Animation<double> _eyebrowY;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleY;
  late final Animation<double> _descOpacity;
  late final Animation<double> _descY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // More subtle translations (12-20px)
    _eyebrowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic)),
    );
    _eyebrowY = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );
    _titleY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );

    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );
    _descY = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)),
    );

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = AppMotion.isReduced || MediaQuery.of(context).disableAnimations;
    // Adapt title size based on width
    final screenWidth = MediaQuery.of(context).size.width;
    final titleSize = screenWidth < 360 ? 28.0 : 32.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Eyebrow
            Opacity(
              opacity: isReduced ? (widget.isActive ? 1.0 : 0.0) : _eyebrowOpacity.value,
              child: Transform.translate(
                offset: Offset(0, isReduced ? 0.0 : _eyebrowY.value),
                child: Text(
                  widget.eyebrow,
                  style: AppTypography.label.copyWith(
                    color: AppColors.brandChampagne,
                    fontSize: 12,
                    fontWeight: FontWeight.w600, // Manrope 600
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Title
            Opacity(
              opacity: isReduced ? (widget.isActive ? 1.0 : 0.0) : _titleOpacity.value,
              child: Transform.translate(
                offset: Offset(0, isReduced ? 0.0 : _titleY.value),
                child: Text(
                  widget.title,
                  style: AppTypography.display.copyWith(
                    color: AppColors.brandMist,
                    fontSize: titleSize,
                    height: 1.2,
                    fontWeight: FontWeight.w700, // Manrope 700
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // 12-18px spacing between title and description
            const SizedBox(height: 16),
            
            // Description
            Opacity(
              opacity: isReduced ? (widget.isActive ? 1.0 : 0.0) : _descOpacity.value,
              child: Transform.translate(
                offset: Offset(0, isReduced ? 0.0 : _descY.value),
                child: ConstrainedBox(
                  // Max width 320-350px
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    widget.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.brandSlate,
                      height: 1.5,
                      fontSize: 16,
                      fontWeight: FontWeight.w400, // Manrope 400
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

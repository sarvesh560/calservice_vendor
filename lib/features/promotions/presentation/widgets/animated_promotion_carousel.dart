import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/static_promotions.dart';
import '../../models/promotion_model.dart';
import 'promotion_banner.dart';

/// Animated promotion carousel displaying top spotlight cards with automatic rotation and page indicators.
class AnimatedPromotionCarousel extends StatefulWidget {
  const AnimatedPromotionCarousel({
    super.key,
    this.promotions = staticPromotions,
  });

  final List<PromotionModel> promotions;

  @override
  State<AnimatedPromotionCarousel> createState() => _AnimatedPromotionCarouselState();
}

class _AnimatedPromotionCarouselState extends State<AnimatedPromotionCarousel> {
  late final PageController _pageController;
  Timer? _autoTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoRotation();
  }

  void _startAutoRotation() {
    _autoTimer?.cancel();
    if (widget.promotions.length <= 1) return;

    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % widget.promotions.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.promotions.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Reset timer when manually swiped
              _startAutoRotation();
            },
            itemBuilder: (context, index) {
              final promo = widget.promotions[index];
              return PromotionBanner(
                promotion: promo,
                isActive: index == _currentIndex,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.promotions.length, (index) {
            final isCurrent = index == _currentIndex;
            return AnimatedContainer(
              duration: AppMotion.resolve(AppMotion.fast),
              curve: AppMotion.curve,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.brandChampagne
                    : AppColors.brandSlate.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            );
          }),
        ),
      ],
    );
  }
}

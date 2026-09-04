import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.slideCount,
    required this.pageOffset,
  });

  final int slideCount;
  final double pageOffset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        slideCount,
        (index) {
          final diff = (pageOffset - index).abs().clamp(0.0, 1.0);
          final width = 6.0 + 22.0 * (1.0 - diff);
          final opacity = 0.3 + 0.7 * (1.0 - diff);
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: width,
            decoration: BoxDecoration(
              color: AppColors.brandChampagne.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        },
      ),
    );
  }
}

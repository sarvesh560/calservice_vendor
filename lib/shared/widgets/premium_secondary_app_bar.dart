import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'animated_pressable.dart';

/// Standard Premium Secondary App Bar for all secondary / detail / sub-screens.
/// Uses the exact reference design:
/// - Circular `AnimatedPressable` back button with `AppColors.brandMist` background
/// - `Icons.arrow_back_rounded`, size 20, `AppColors.brandMidnight`
/// - Subtle `brandMidnightDark` border
/// - Consistent typography, safe-area handling, and optional trailing actions.
class PremiumSecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumSecondaryAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = automaticallyImplyLeading && (GoRouter.maybeOf(context)?.canPop() ?? false);

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,
      leadingWidth: canPop ? 56 : 16,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Center(
                child: AnimatedPressable(
                  onPressed: onBack ?? () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandMist,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandMidnightDark.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.brandMidnight,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.brandMidnight,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.brandSlate,
              ),
            ),
          ],
        ],
      ),
      actions: actions != null ? [...actions!, const SizedBox(width: AppSpacing.sm)] : null,
    );
  }
}

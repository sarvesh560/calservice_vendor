import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'animated_pressable.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return AnimatedPressable(
      onPressed: isDisabled ? null : onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.surfaceMuted : AppColors.brandChampagne,
          borderRadius: BorderRadius.circular(AppRadius.control),
          boxShadow: isDisabled ? AppElevation.none : AppElevation.subtle,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandMidnight,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: isDisabled ? AppColors.textMuted : AppColors.brandMidnightDark),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: isDisabled ? AppColors.textMuted : AppColors.brandMidnightDark,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return AnimatedPressable(
      onPressed: isDisabled ? null : onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: isDisabled ? AppColors.border : AppColors.brandSlate,
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandSlate,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: isDisabled ? AppColors.textMuted : AppColors.textPrimary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: isDisabled ? AppColors.textMuted : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return AnimatedPressable(
      onPressed: isDisabled ? null : onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.surfaceMuted : AppColors.error.tint,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: isDisabled ? AppColors.border : AppColors.error.tintBorder,
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error.base,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: isDisabled ? AppColors.textMuted : AppColors.error.base),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: isDisabled ? AppColors.textMuted : AppColors.error.base,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

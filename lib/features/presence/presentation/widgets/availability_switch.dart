import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../presence_controller.dart';

/// Professional single executive availability switch widget for technicians.
class AvailabilitySwitch extends ConsumerWidget {
  const AvailabilitySwitch({super.key});

  Future<void> _handleToggle(BuildContext context, WidgetRef ref, bool targetOnline) async {
    try {
      await ref.read(presenceControllerProvider.notifier).setOnline(targetOnline);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              targetOnline
                  ? context.tr('online_status')
                  : context.tr('offline_status'),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: targetOnline ? AppColors.success.base : const Color(0xFF334155),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final rawError = e.toString();
        final displayError = rawError.startsWith('Exception: ')
            ? rawError.substring(11)
            : rawError;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayError),
            backgroundColor: AppColors.error.base,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceState = ref.watch(presenceControllerProvider);
    final isOnline = presenceState.isOnline;
    final isToggling = presenceState.isToggling;

    final statusColor = isOnline ? AppColors.success.base : AppColors.textMuted;
    final statusBgColor = isOnline ? AppColors.success.tint : AppColors.surfaceMuted;
    final statusBorderColor = isOnline ? AppColors.success.tintBorder : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: statusBorderColor, width: 1.5),
        boxShadow: AppElevation.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: AppTypography.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? AppColors.success.onTint : AppColors.textPrimary,
                      ),
                      child: Text(isOnline ? context.tr('online_status') : context.tr('offline_status')),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isToggling)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                Semantics(
                  label: 'Technician Availability Switch',
                  hint: isOnline ? context.tr('offline') : context.tr('online'),
                  child: Switch.adaptive(
                    value: isOnline,
                    onChanged: (val) => _handleToggle(context, ref, val),
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTypography.bodySmall.copyWith(
              color: isOnline ? AppColors.success.base : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            child: Text(
              isOnline
                  ? context.tr('available_for_new_requests')
                  : context.tr('job_offers_paused'),
            ),
          ),
          if (isToggling) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('updating_availability'),
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../presence_controller.dart';


/// Professional single executive availability switch widget for technicians.
///
/// Features:
/// - Displays clear status: `You are Online` or `You are Offline`
/// - Displays clear helper: `Available for new service requests` or `New job offers are currently paused`
/// - Single `Switch.adaptive` control connected to Riverpod presenceControllerProvider
/// - Disables interaction and shows loading indicator while request is in flight
/// - Catches API/network errors and displays informative SnackBar while preserving state
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
                  ? 'You are now ONLINE and available for new dispatch requests.'
                  : 'You are now OFFLINE. New dispatch offers paused.',
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: targetOnline ? const Color(0xFF059669) : AppColors.brandMidnight,
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
            backgroundColor: const Color(0xFFDC2626),
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

    final statusColor = isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final statusBgColor = isOnline ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC);
    final statusBorderColor = isOnline ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0);

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
                        color: isOnline ? const Color(0xFF065F46) : const Color(0xFF334155),
                      ),
                      child: Text(isOnline ? 'You are Online' : 'You are Offline'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isToggling)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                  ),
                )
              else
                Semantics(
                  label: 'Technician Availability Switch',
                  hint: isOnline ? 'Double tap to go offline' : 'Double tap to go online',
                  child: Switch.adaptive(
                    value: isOnline,
                    onChanged: (val) => _handleToggle(context, ref, val),
                    activeThumbColor: const Color(0xFF10B981),
                    activeTrackColor: const Color(0xFFA7F3D0),
                    inactiveThumbColor: const Color(0xFF64748B),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTypography.bodySmall.copyWith(
              color: isOnline ? const Color(0xFF047857) : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            child: Text(
              isOnline
                  ? 'Available for new service requests'
                  : 'New job offers are currently paused',
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
                  'Updating availability with server...',
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

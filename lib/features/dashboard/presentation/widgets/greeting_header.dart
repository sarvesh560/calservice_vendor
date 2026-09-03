import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/animated_pressable.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../notifications/presentation/notifications_providers.dart';
import '../../../presence/presentation/presence_controller.dart';
import '../../../profile/presentation/profile_providers.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final profileAsync = ref.watch(employeeProfileProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final displayName = user?.displayName ?? 'Technician';
    final isOnline = profileAsync.valueOrNull?.isOnline ?? true;

    return Container(
      width: double.infinity,
      color: AppColors.brandMidnight,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.paddingOf(context).top + AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brandSlate,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.brandMist,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _NotificationAction(unreadCount: unreadCount),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _AvailabilityToggle(isOnline: isOnline),
        ],
      ),
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({required this.unreadCount});
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: () => context.push('/notifications'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.brandMidnightDark,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_outlined, color: AppColors.brandMist, size: 20),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.brandChampagne,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brandMidnightDark, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityToggle extends ConsumerWidget {
  const _AvailabilityToggle({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceState = ref.watch(presenceControllerProvider);
    final isToggling = presenceState.isToggling;
    final currentOnline = presenceState.isToggling ? presenceState.isOnline : isOnline;

    return AnimatedPressable(
      onPressed: isToggling
          ? null
          : () async {
              final targetState = !currentOnline;
              try {
                await ref.read(presenceControllerProvider.notifier).setOnline(targetState);
                ref.invalidate(employeeProfileProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update availability: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: AppColors.error.base,
                    ),
                  );
                }
              }
            },
      child: AnimatedContainer(
        duration: AppMotion.resolve(AppMotion.normal),
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: currentOnline 
              ? AppColors.brandMidnightDark 
              : AppColors.surfaceElevated.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: currentOnline 
                ? AppColors.brandChampagne.withValues(alpha: 0.5) 
                : AppColors.brandSlate.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.resolve(AppMotion.fast),
              curve: AppMotion.curve,
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentOnline ? AppColors.brandChampagne : AppColors.brandSlate,
                boxShadow: currentOnline 
                    ? [BoxShadow(color: AppColors.brandChampagne.withValues(alpha: 0.6), blurRadius: 6)]
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToggling
                        ? 'UPDATING AVAILABILITY...'
                        : (currentOnline ? 'ONLINE' : 'OFFLINE'),
                    style: AppTypography.label.copyWith(
                      color: currentOnline ? AppColors.brandChampagne : AppColors.brandMist,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentOnline
                        ? "You're available for new work"
                        : "You're currently unavailable",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.brandSlate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isToggling)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandChampagne,
                ),
              )
            else
              Icon(
                currentOnline ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                size: 32,
                color: currentOnline ? AppColors.brandChampagne : AppColors.brandSlate,
              ),
          ],
        ),
      ),
    );
  }
}

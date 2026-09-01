import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../notifications/presentation/notifications_providers.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../../../../shared/widgets/animated_pressable.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final profileAsync = ref.watch(employeeProfileProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final displayName = user?.displayName ?? 'Technician';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';
    final isOnline = profileAsync.valueOrNull?.isOnline ?? true;
    final photoUrl = profileAsync.valueOrNull?.avatar;

    return Container(
      width: double.infinity,
      color: AppColors.brandMidnight,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.paddingOf(context).top + AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.massive, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderAvatar(
                initial: initial,
                photoUrl: photoUrl,
                onTap: () => context.push('/more/profile'),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
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
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              const Spacer(),
              _AvailabilityToggle(isOnline: isOnline),
            ],
          ),
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
      onPressed: () => context.go('/notifications'),
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
            Icon(Icons.notifications_outlined, color: AppColors.brandMist, size: 20),
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

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({
    required this.initial,
    this.photoUrl,
    required this.onTap,
  });

  final String initial;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandChampagne.withValues(alpha: 0.8), width: 1.5),
          color: AppColors.brandMidnightDark,
        ),
        child: ClipOval(
          child: photoUrl != null && photoUrl!.isNotEmpty
              ? Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _fallbackAvatar(),
                )
              : _fallbackAvatar(),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Center(
      child: Text(
        initial,
        style: AppTypography.title.copyWith(color: AppColors.brandMist),
      ),
    );
  }
}

class _AvailabilityToggle extends ConsumerWidget {
  const _AvailabilityToggle({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedPressable(
      onPressed: () {
        final notifier = ref.read(profileControllerProvider.notifier);
        notifier.savePreferences({'is_online': !isOnline});
      },
      child: AnimatedContainer(
        duration: AppMotion.resolve(AppMotion.normal),
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline 
              ? AppColors.brandMidnightDark 
              : AppColors.surfaceElevated.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isOnline 
                ? AppColors.brandChampagne.withValues(alpha: 0.6) 
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppMotion.resolve(AppMotion.fast),
              curve: AppMotion.curve,
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.brandChampagne : AppColors.brandSlate,
                boxShadow: isOnline 
                    ? [BoxShadow(color: AppColors.brandChampagne.withValues(alpha: 0.5), blurRadius: 4)]
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: AppTypography.label.copyWith(
                color: isOnline ? AppColors.brandChampagne : AppColors.brandSlate,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

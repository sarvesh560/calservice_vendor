import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/settings_row.dart';
import '../../../shared/widgets/status_badge.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(employeeProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.titleLarge),
        backgroundColor: AppColors.surface,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: ')),
        data: (profile) {
          /* null check removed because EmployeeProfile is non-nullable in data */
          
          return ListView(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.brandChampagne,
                      child: Text(
                        profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'V',
                        style: AppTypography.display.copyWith(color: AppColors.brandMidnightDark, fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(' ', style: AppTypography.headline.copyWith(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text((profile.displayPhone ?? profile.email) ?? '', style: AppTypography.bodySmall),
                          const SizedBox(height: 8),
                          StatusBadge(status: profile.registrationStatus),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SectionHeader(title: 'ACCOUNT'),
              Container(
                color: AppColors.surface,
                child: Column(
                  children: [
                    SettingsRow(
                      icon: Icons.badge_outlined,
                      title: 'Business Information',
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.description_outlined,
                      title: 'Documents',
                      onTap: () {},
                    ),
                    SettingsRow(
                      icon: Icons.handyman_outlined,
                      title: 'Authorized Services',
                      isLast: true,
                      onTap: () => context.push('/more/services'),
                    ),
                  ],
                ),
              ),

              const SectionHeader(title: 'PREFERENCES'),
              Container(
                color: AppColors.surface,
                child: Column(
                  children: [
                    SettingsRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () => context.push('/more/notifications'),
                    ),
                    SettingsRow(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      isLast: true,
                      onTap: () => context.push('/more/appearance'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

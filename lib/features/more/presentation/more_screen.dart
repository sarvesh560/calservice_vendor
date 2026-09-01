import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/settings_row.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/presentation/profile_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(employeeProfileProvider);
    final user = profileAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          children: [
            // PROFILE HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.brandChampagne,
                    child: Text(
                      user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'V',
                      style: AppTypography.display.copyWith(color: AppColors.brandMidnightDark, fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user != null ? '${user.firstName} ${user.lastName}' : 'Vendor Profile', style: AppTypography.headline.copyWith(fontSize: 22, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? 'Loading...', style: AppTypography.bodySmall),
                        const SizedBox(height: 8),
                        StatusBadge(status: profileAsync.valueOrNull?.registrationStatus ?? 'PENDING'),
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
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => context.push('/more/profile'),
                  ),
                  SettingsRow(
                    icon: Icons.handyman_outlined,
                    title: 'Services',
                    onTap: () => context.push('/more/services'),
                  ),
                  SettingsRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Finance & Wallet',
                    isLast: true,
                    onTap: () => context.push('/finance'),
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
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    onTap: () => context.push('/more/appearance'),
                  ),
                  SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    isLast: true,
                    onTap: () => context.push('/more/notifications'),
                  ),
                ],
              ),
            ),

            const SectionHeader(title: 'SECURITY & SUPPORT'),
            Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  SettingsRow(
                    icon: Icons.security_rounded,
                    title: 'Security',
                    onTap: () => context.push('/more/security'),
                  ),
                  SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Data',
                    onTap: () => context.push('/more/privacy'),
                  ),
                  SettingsRow(
                    icon: Icons.help_outline_rounded,
                    title: 'Support',
                    isLast: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                child: Text('Sign Out', style: AppTypography.label.copyWith(color: AppColors.error.base)),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/localization/language_controller.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/settings_row.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/presentation/auth_controller.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLanguageSelector(BuildContext context, WidgetRef ref, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('select_language'),
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _LanguageTile(
                  code: 'en',
                  label: 'English',
                  isSelected: currentLang == 'en',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('en');
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageTile(
                  code: 'ta',
                  label: 'தமிழ் (Tamil)',
                  isSelected: currentLang == 'ta',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('ta');
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageTile(
                  code: 'hi',
                  label: 'हिन्दी (Hindi)',
                  isSelected: currentLang == 'hi',
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage('hi');
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(employeeProfileProvider);
    final user = ref.watch(authControllerProvider).user;
    final currentLang = ref.watch(languageControllerProvider);

    final langLabel = switch (currentLang) {
      'ta' => 'தமிழ் (Tamil)',
      'hi' => 'हिन्दी (Hindi)',
      _ => 'English',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumSecondaryAppBar(
        title: context.tr('profile'),
        automaticallyImplyLeading: false,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unable to load profile data', style: AppTypography.body),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(employeeProfileProvider),
                child: Text(context.tr('retry')),
              ),
            ],
          ),
        ),
        data: (profile) {
          final displayName = profile.fullName.isNotEmpty
              ? profile.fullName
              : (user?.displayName ?? 'Technician Vendor');

          return ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 120,
              top: AppSpacing.lg,
            ),
            children: [
              // ── PROFILE HEADER CARD ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTypography.headline.copyWith(
                                fontSize: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.displayPhone.isNotEmpty
                                  ? profile.displayPhone
                                  : (profile.email ?? user?.email ?? ''),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StatusBadge(status: profile.registrationStatus),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── ACCOUNT SECTION ──────────────────────────────────────────
              SectionHeader(title: context.tr('account').toUpperCase()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.person_outline_rounded,
                        title: context.tr('personal_business_info'),
                        onTap: () => context.push('/more/profile'),
                      ),
                      SettingsRow(
                        icon: Icons.assignment_outlined,
                        title: context.tr('registration_application'),
                        onTap: () => context.push('/onboarding/wizard'),
                      ),
                      SettingsRow(
                        icon: Icons.description_outlined,
                        title: context.tr('compliance_documents'),
                        isLast: true,
                        onTap: () => context.push('/more/documents'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── WORK & TERRITORY ──────────────────────────────────────────
              SectionHeader(title: context.tr('work_territory').toUpperCase()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.handyman_outlined,
                        title: context.tr('authorized_services'),
                        onTap: () => context.push('/more/services'),
                      ),
                      SettingsRow(
                        icon: Icons.map_outlined,
                        title: context.tr('working_locations'),
                        onTap: () => context.push('/more/locations'),
                      ),
                      SettingsRow(
                        icon: Icons.insights_rounded,
                        title: context.tr('performance_ratings'),
                        isLast: true,
                        onTap: () => context.push('/more/performance'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── FINANCE & EARNINGS ─────────────────────────────────────────
              SectionHeader(title: context.tr('finance_earnings').toUpperCase()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.account_balance_wallet_outlined,
                        title: context.tr('wallet_overview'),
                        onTap: () => context.push('/earnings/wallet'),
                      ),
                      SettingsRow(
                        icon: Icons.receipt_long_outlined,
                        title: context.tr('transactions_ledger'),
                        onTap: () => context.push('/earnings/transactions'),
                      ),
                      SettingsRow(
                        icon: Icons.account_balance_outlined,
                        title: context.tr('payout_bank_accounts'),
                        onTap: () => context.push('/earnings/bank-account'),
                      ),
                      SettingsRow(
                        icon: Icons.payments_outlined,
                        title: context.tr('withdrawal_requests'),
                        isLast: true,
                        onTap: () => context.push('/earnings/withdrawals'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── PREFERENCES SECTION ───────────────────────────────────────
              SectionHeader(title: context.tr('preferences').toUpperCase()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.language_rounded,
                        title: '${context.tr('select_language')} ($langLabel)',
                        onTap: () => _showLanguageSelector(context, ref, currentLang),
                      ),
                      SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        title: context.tr('notification_settings'),
                        onTap: () => context.push('/more/settings/notifications'),
                      ),
                      SettingsRow(
                        icon: Icons.palette_outlined,
                        title: context.tr('appearance'),
                        isLast: true,
                        onTap: () => context.push('/more/settings/appearance'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── SECURITY & PRIVACY ────────────────────────────────────────
              SectionHeader(title: context.tr('security_privacy').toUpperCase()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.security_rounded,
                        title: context.tr('account_security'),
                        onTap: () => context.push('/more/settings/security'),
                      ),
                      SettingsRow(
                        icon: Icons.privacy_tip_outlined,
                        title: context.tr('privacy_data'),
                        isLast: true,
                        onTap: () => context.push('/more/settings/privacy'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── SIGN OUT ──────────────────────────────────────────────────
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AnimatedPressable(
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.error.tint,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.error.tintBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.tr('sign_out'),
                      style: AppTypography.label.copyWith(
                        color: AppColors.error.base,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        label,
        style: AppTypography.title.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}

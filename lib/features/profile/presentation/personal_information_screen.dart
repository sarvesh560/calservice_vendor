import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/employee_profile.dart';
import 'profile_providers.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(employeeProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(title: 'Personal Information'),
      body: profileAsync.when(
        data: (profile) => _buildProfileDetails(context, profile),
        loading: () => _buildLoadingSkeleton(),
        error: (error, stack) => _buildErrorState(ref, error),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, EmployeeProfile profile) {
    final draft = profile.onboardingData.draft;

    final address = draft['address']?.toString() ?? draft['street_address']?.toString() ?? '';
    final city = draft['city']?.toString() ?? '';
    final stateStr = profile.state ?? draft['state']?.toString() ?? '';
    final pincode = draft['pincode']?.toString() ?? draft['postal_code']?.toString() ?? '';
    final countryStr = profile.country ?? draft['country']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. PERSONAL DETAILS ─────────────────────────────────────────
          const _SectionHeader(title: 'PERSONAL DETAILS'),
          _CardContainer(
            children: [
              _InfoRow(
                icon: Icons.person_outline_rounded,
                title: 'Full Name',
                value: profile.fullName.isNotEmpty ? profile.fullName : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.phone_android_outlined,
                title: 'Phone Number',
                value: profile.displayPhone.isNotEmpty ? profile.displayPhone : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.email_outlined,
                title: 'Email Address',
                value: profile.email?.isNotEmpty == true ? profile.email! : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.cake_outlined,
                title: 'Date of Birth',
                value: profile.dateOfBirth?.isNotEmpty == true ? profile.dateOfBirth! : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.badge_outlined,
                title: 'Professional Title',
                value: profile.title?.isNotEmpty == true
                    ? profile.title!
                    : (profile.bio?.isNotEmpty == true ? profile.bio! : 'Not provided'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 2. BUSINESS INFORMATION ─────────────────────────────────────
          const _SectionHeader(title: 'BUSINESS INFORMATION'),
          _CardContainer(
            children: [
              _InfoRow(
                icon: Icons.business_outlined,
                title: 'Business / Company Name',
                value: profile.companyName?.isNotEmpty == true ? profile.companyName! : 'Independent Vendor',
              ),
              _InfoRow(
                icon: Icons.work_outline_rounded,
                title: 'Department / Role',
                value: profile.department?.isNotEmpty == true ? profile.department! : 'Not provided',
              ),
              _InfoWidgetRow(
                icon: Icons.verified_outlined,
                title: 'Registration Status',
                widget: StatusBadge(status: profile.registrationStatus),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 3. ADDRESS & TERRITORY ──────────────────────────────────────
          const _SectionHeader(title: 'ADDRESS & TERRITORY'),
          _CardContainer(
            children: [
              _InfoRow(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: address.isNotEmpty ? address : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.location_city_outlined,
                title: 'City',
                value: city.isNotEmpty ? city : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.map_outlined,
                title: 'State',
                value: stateStr.isNotEmpty ? stateStr : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.pin_drop_outlined,
                title: 'Pincode / Postal Code',
                value: pincode.isNotEmpty ? pincode : 'Not provided',
              ),
              _InfoRow(
                icon: Icons.public_outlined,
                title: 'Country',
                value: countryStr.isNotEmpty ? countryStr : 'Not provided',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── EDIT INFORMATION BUTTON ─────────────────────────────────────
          AnimatedPressable(
            onPressed: () => context.push('${AppRoutes.onboardingWizard}?step=1&edit=true'),
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.brandMidnight,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppElevation.subtle,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.brandChampagne, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Edit Information',
                    style: AppTypography.title.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.brandMist,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.brandMist,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.brandMist,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error.base.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unable to load personal information',
              style: AppTypography.titleLarge.copyWith(color: AppColors.brandMidnight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedPressable(
              onPressed: () => ref.invalidate(employeeProfileProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.brandMidnight,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Text(
                  'Retry',
                  style: AppTypography.title.copyWith(color: AppColors.brandChampagne, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.brandSlate,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.subtle,
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brandMist,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.brandMidnight),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.brandSlate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTypography.body.copyWith(
                        color: AppColors.brandMidnight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _InfoWidgetRow extends StatelessWidget {
  const _InfoWidgetRow({
    required this.icon,
    required this.title,
    required this.widget,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final Widget widget;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brandMist,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.brandMidnight),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.brandSlate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    widget,
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
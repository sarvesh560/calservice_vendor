import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/presentation/profile_providers.dart';

class PendingReviewScreen extends ConsumerStatefulWidget {
  const PendingReviewScreen({super.key});

  @override
  ConsumerState<PendingReviewScreen> createState() => _PendingReviewScreenState();
}

class _PendingReviewScreenState extends ConsumerState<PendingReviewScreen> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      ref.invalidate(employeeProfileProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(employeeProfileProvider);
    final profile = profileAsync.valueOrNull;
    final servicesCount = profile?.allRequestedServices.length ?? 0;
    final docsCount = profile?.documents.where((d) => d.hasFile).length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumSecondaryAppBar(
        title: context.tr('status'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppElevation.subtle,
                    ),
                    child: Column(
                      children: [
                        // ── Icon Badge ─────────────────────────────────────
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.warning.tint,
                            border: Border.all(color: AppColors.warning.tintBorder),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            size: 28,
                            color: AppColors.warning.base,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── Status Tag ─────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.tint,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.warning.tintBorder),
                          ),
                          child: Text(
                            context.tr('registration_under_review').toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.warning.onTint,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── Title & Description ────────────────────────────
                        Text(
                          context.tr('registration_under_review'),
                          style: AppTypography.display.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('registration_under_review_desc'),
                          style: AppTypography.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Summary Cards Row ──────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.control),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('authorized_services'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$servicesCount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.control),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('compliance_documents'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$docsCount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── Notice Box ─────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.info.tint,
                            border: Border.all(color: AppColors.info.tintBorder),
                            borderRadius: BorderRadius.circular(AppRadius.control),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppColors.info.base,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.tr('registration_under_review_desc'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.info.onTint,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Actions ────────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _isRefreshing ? null : _refresh,
                            icon: _isRefreshing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              _isRefreshing
                                  ? context.tr('loading')
                                  : context.tr('retry'),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () =>
                              ref.read(authControllerProvider.notifier).logout(),
                          child: Text(context.tr('logout')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/premium_buttons.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/job.dart';
import 'jobs_providers.dart';
import 'widgets/offer_actions_section.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({super.key, required this.job});
  final Job job;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final activeJobsAsync = ref.watch(activeJobsProvider);
    final activeJobs = activeJobsAsync.valueOrNull ?? [];
    
    // Find latest state of current job if present in provider
    final currentJob = activeJobs.firstWhere(
      (j) => j.id == widget.job.id,
      orElse: () => widget.job,
    );

    final canAccept = ['PENDING'].contains(currentJob.status.toUpperCase());
    final isActive = ['ACCEPTED', 'ACTIVE'].contains(currentJob.status.toUpperCase());

    final amountText = currentJob.totalAmount != null 
        ? '₹${currentJob.totalAmount!.toStringAsFixed(2)}'
        : 'Standard Rate';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(title: 'Job Details'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Container(
                      color: AppColors.brandMidnightDark,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${currentJob.id}',
                                style: AppTypography.caption.copyWith(color: AppColors.brandSlate),
                              ),
                              StatusBadge(status: currentJob.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currentJob.displayTitle,
                            style: AppTypography.headline.copyWith(color: AppColors.brandMist),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            currentJob.serviceCategory ?? 'General Service',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.brandChampagne),
                          ),
                        ],
                      ),
                    ),

                    // DETAILS CARD
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Customer Name',
                              value: currentJob.customerName ?? 'Verified Customer',
                            ),
                            const Divider(height: AppSpacing.xl),
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Service Location',
                              value: currentJob.address ?? 'Location coordinates provided upon dispatch',
                            ),
                            const Divider(height: AppSpacing.xl),
                            _DetailRow(
                              icon: Icons.payments_outlined,
                              label: 'Payout Amount',
                              value: amountText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM ACTION BAR
            if (canAccept)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: OfferActionsSection(job: currentJob),
              )
            else if (isActive)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: PremiumButton(
                  label: 'Job Active — Open Navigation',
                  icon: Icons.near_me_rounded,
                  onPressed: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.brandChampagne),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption.copyWith(color: AppColors.brandSlate)),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.title.copyWith(color: AppColors.brandMidnight)),
            ],
          ),
        ),
      ],
    );
  }
}

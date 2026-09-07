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
import 'widgets/active_job_actions/accepted_actions.dart';
import 'widgets/active_job_actions/en_route_actions.dart';
import 'widgets/active_job_actions/pre_service_actions.dart';
import 'widgets/active_job_actions/in_progress_actions.dart';
import 'widgets/active_job_actions/payment_actions.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({super.key, required this.job});
  final Job job;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  
  Widget _buildActiveJobActions(Job currentJob) {
    switch (currentJob.status.toUpperCase()) {
      case 'ACCEPTED':
        return AcceptedActions(job: currentJob);
      case 'ON_THE_WAY':
        return EnRouteActions(job: currentJob);
      case 'ARRIVED':
        return PreServiceActions(job: currentJob);
      case 'IN_PROGRESS':
        return InProgressActions(job: currentJob);
      case 'COMPLETED':
        return PaymentActions(job: currentJob);
      default:
        // Fallback for unknown active statuses (e.g. ACCEPTED/ACTIVE)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Job Status: ${currentJob.status}',
              style: AppTypography.title.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Refresh Job State',
              icon: Icons.refresh,
              onPressed: () {
                ref.invalidate(activeJobsProvider);
              },
            ),
          ],
        );
    }
  }

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
    final isActive = ['ACCEPTED', 'ACTIVE', 'ON_THE_WAY', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED'].contains(currentJob.status.toUpperCase());

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
                      color: AppColors.primary,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${currentJob.id}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              StatusBadge(status: currentJob.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currentJob.displayTitle,
                            style: AppTypography.headline.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            currentJob.serviceCategory ?? 'General Service',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                            ),
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
                child: _buildActiveJobActions(currentJob),
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
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

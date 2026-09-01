import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/premium_buttons.dart';
import 'package:intl/intl.dart';
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
    // Attempt to watch the latest state if available
    final jobsAsync = ref.watch(activeJobsProvider);
    final activeJobs = jobsAsync.valueOrNull ?? const [];
    final currentJob = activeJobs.firstWhere((j) => j.id == widget.job.id, orElse: () => widget.job);
    
    

    final canAccept = ['PENDING'].contains(currentJob.status.toUpperCase());
    final isActive = ['ACCEPTED', 'ACTIVE'].contains(currentJob.status.toUpperCase());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Job Details', style: AppTypography.titleLarge.copyWith(color: AppColors.brandMist)),
        backgroundColor: AppColors.brandMidnightDark,
        iconTheme: const IconThemeData(color: AppColors.brandMist),
      ),
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
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentJob.displayTitle ?? 'Assigned Service',
                            style: AppTypography.headline.copyWith(color: AppColors.brandMist),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          StatusBadge(status: currentJob.status),
                        ],
                      ),
                    ),

                    // CUSTOMER & LOCATION
                    _SectionHeader(title: 'Customer Information'),
                    _InfoRow(icon: Icons.person_outline, label: 'Name', value: currentJob.customerName ?? 'Customer'),
                    _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: 'Protected during pending state'),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: currentJob.address ?? 'Customer Location',
                      isLast: true,
                    ),

                    // SCHEDULE
                    _SectionHeader(title: 'Schedule'),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date & Time',
                      value: currentJob.preferredDate ?? 'Unscheduled',
                      isLast: true,
                    ),

                    // EARNINGS
                    _SectionHeader(title: 'Earnings'),
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Total Amount',
                      value: currentJob.totalAmount?.toStringAsFixed(2) ?? '0.00',
                      valueStyle: AppTypography.numeric.copyWith(fontSize: 16, color: AppColors.success.base),
                      isLast: true,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            
            // ACTIONS (Pinned at bottom)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
                boxShadow: AppElevation.subtle,
              ),
              child: SafeArea(
                top: false,
                child: canAccept 
                    ? OfferActionsSection(job: currentJob)
                    : isActive
                        ? PremiumButton(
                            label: 'Mark Completed',
                            onPressed: () { /* API Call */ },
                          )
                        : SecondaryButton(
                            label: 'Back to Jobs',
                            onPressed: () => context.pop(),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.label.copyWith(color: AppColors.brandSlate, letterSpacing: 1.0),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: AppColors.brandSlate),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTypography.bodySmall),
                      const SizedBox(height: 4),
                      Text(value, style: valueStyle ?? AppTypography.body.copyWith(fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) Divider(color: AppColors.divider, height: 1, indent: 52),
        ],
      ),
    );
  }
}

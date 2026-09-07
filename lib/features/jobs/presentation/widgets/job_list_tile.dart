import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/job.dart';
import 'package:intl/intl.dart' as intl;

class JobListTile extends StatelessWidget {
  const JobListTile({
    super.key,
    required this.job,
    this.hasActiveJob = false,
  });

  final Job job;
  final bool hasActiveJob;

  @override
  Widget build(BuildContext context) {
    final currency = intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    return InkWell(
      onTap: () => context.push('/jobs/', extra: job),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.displayTitle,
                        style: AppTypography.title.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(job.customerName ?? 'Customer', style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.format(job.totalAmount ?? 0),
                      style: AppTypography.numeric.copyWith(fontSize: 16, color: AppColors.success.base),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: job.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  job.preferredDate ?? 'Unscheduled',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpacing.lg),
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.address ?? 'No address',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

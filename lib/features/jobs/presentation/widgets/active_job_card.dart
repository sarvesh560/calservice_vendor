import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/premium_buttons.dart';
import '../../domain/job.dart';
import 'package:intl/intl.dart';

class ActiveJobCard extends StatelessWidget {
  const ActiveJobCard({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandMidnight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppElevation.elevated,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_fill_rounded, color: AppColors.brandChampagne, size: 20),
              const SizedBox(width: 8),
              Text('ACTIVE NOW', style: AppTypography.caption.copyWith(color: AppColors.brandChampagne)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            job.displayTitle ?? 'Assigned Service',
            style: AppTypography.titleLarge.copyWith(color: AppColors.brandMist),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Text((job.customerName ?? 'Customer'), style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              const Spacer(),
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  job.address ?? '',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          PremiumButton(
            label: 'Manage Job',
            onPressed: () => context.push('/jobs/', extra: job),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '';

import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/premium_buttons.dart';
import '../../domain/job.dart';
import 'offer_actions_section.dart';
import '../jobs_providers.dart';

class OfferCard extends ConsumerWidget {
  const OfferCard({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final isAccepting = false;
    final isRejecting = false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.brandChampagne),
        boxShadow: AppElevation.elevated,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandChampagne.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('NEW DISPATCH', style: AppTypography.caption.copyWith(color: AppColors.brandChampagneDark)),
              ),
              const Spacer(),
              Text(
                currency.format(job.totalAmount ?? 0),
                style: AppTypography.numeric.copyWith(fontSize: 18, color: AppColors.success.base),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            job.displayTitle ?? 'Assigned Service',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  job.address ?? 'Customer Location',
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          OfferActionsSection(job: job),
        ],
      ),
    );
  }
}

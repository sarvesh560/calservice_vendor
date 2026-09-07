import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/job.dart';
import 'offer_actions_section.dart';

class OfferCard extends ConsumerWidget {
  const OfferCard({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('NEW DISPATCH', style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
            job.displayTitle,
            style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  job.address ?? 'Customer Location',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../finance/presentation/finance_providers.dart';

class TodayOverviewCard extends ConsumerWidget {
  const TodayOverviewCard({super.key, required this.activeCount, required this.completedCount});
  
  final int? activeCount;
  final int? completedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY',
                style: AppTypography.label.copyWith(color: AppColors.brandSlate, letterSpacing: 1.0),
              ),
              Icon(Icons.trending_up_rounded, color: AppColors.success.base, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '₹',
            style: AppTypography.numeric.copyWith(fontSize: 32, letterSpacing: -0.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(label: 'Jobs', value: ''),
              _Stat(label: 'Completed', value: ''),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.label),
      ],
    );
  }
}

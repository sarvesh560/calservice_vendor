import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../finance/presentation/finance_providers.dart';

class TodayOverviewCard extends ConsumerWidget {
  const TodayOverviewCard({super.key, required this.activeCount, required this.completedCount});
  
  final int? activeCount;
  final int? completedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(employeeWalletProvider);

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
          AnimatedSwitcher(
            duration: AppMotion.resolve(AppMotion.normal),
            child: _buildEarningsContent(walletAsync),
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(
                label: 'Active Jobs',
                value: activeCount != null ? '$activeCount' : '0',
              ),
              Container(width: 1, height: 24, color: AppColors.divider),
              _Stat(
                label: 'Completed',
                value: completedCount != null ? '$completedCount' : '0',
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildEarningsContent(AsyncValue walletAsync) {
    return walletAsync.when(
      data: (wallet) {
        final earnings = wallet.availableBalance;
        if (earnings <= 0.0) {
          return _EmptyEarningsState();
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '₹${earnings.toStringAsFixed(0)}',
            key: const ValueKey('earnings'),
            style: AppTypography.numeric.copyWith(fontSize: 32, letterSpacing: -0.5),
          ),
        );
      },
      loading: () => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          key: const ValueKey('loading'),
          height: 38,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.brandMidnightDark.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      error: (error, _) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Unavailable',
          key: const ValueKey('error'),
          style: AppTypography.title.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _EmptyEarningsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brandMist,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.brandMidnightDark.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 24, color: AppColors.brandSlate),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '₹0',
                style: AppTypography.numeric.copyWith(fontSize: 24, color: AppColors.brandMidnight),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No earnings yet',
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            'Complete your first job today and your earnings will appear here.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
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

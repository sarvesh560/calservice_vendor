import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'status_badge.dart';

class LedgerRow extends StatelessWidget {
  const LedgerRow({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    this.isCredit = false,
    this.isLast = false,
    this.onTap,
  });

  final String title;
  final String date;
  final String amount;
  final String status;
  final bool isCredit;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(date, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: AppTypography.numeric.copyWith(
                        fontSize: 15,
                        color: isCredit ? AppColors.success.base : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: status),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(color: AppColors.divider, height: 1, indent: AppSpacing.lg),
        ],
      ),
    );
  }
}

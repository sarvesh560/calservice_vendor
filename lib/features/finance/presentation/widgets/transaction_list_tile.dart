import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/wallet_transaction.dart';

/// Renders a single transaction card with direction indicators, badges, and timestamps.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final WalletTransaction transaction;
  final VoidCallback onTap;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year · $hour12:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final amountPrefix = isCredit ? '+ ' : '- ';
    final amountColor = isCredit ? const Color(0xFF166534) : const Color(0xFF9F1239);
    final iconBg = isCredit ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final iconColor = isCredit ? const Color(0xFF16A34A) : const Color(0xFFE11D48);

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Transaction Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: isCredit
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFECDD3),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  transaction.iconData,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // 2. Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        fontSize: 13,
                        color: AppColors.brandMidnight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (transaction.referenceId != null &&
                            transaction.referenceId!.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              transaction.referenceId!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label.copyWith(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            _formatDate(transaction.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (transaction.isPendingSettlement) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 0.6),
                        ),
                        child: Text(
                          'T+7 Hold (Pending)',
                          style: AppTypography.label.copyWith(
                            fontSize: 9.5,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // 3. Amount & Direction
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$amountPrefix₹${transaction.amount.toStringAsFixed(2)}',
                      style: AppTypography.title.copyWith(
                        fontSize: 14.5,
                        fontFamily: 'monospace',
                        color: amountColor,
                      ),
                    ),
                  ),
                  if (transaction.balanceAfter != null) ...[
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Bal: ₹${transaction.balanceAfter!.toStringAsFixed(2)}',
                        style: AppTypography.label.copyWith(
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          color: AppColors.brandMidnightDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

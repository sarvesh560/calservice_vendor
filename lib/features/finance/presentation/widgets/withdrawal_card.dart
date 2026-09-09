import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/wallet_withdrawal.dart';

/// Card displaying a single payout / withdrawal request with live status tracking.
class WithdrawalCard extends StatelessWidget {
  const WithdrawalCard({
    super.key,
    required this.withdrawal,
    this.onCancel,
  });

  final WalletWithdrawal withdrawal;
  final VoidCallback? onCancel;

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
    final statusColor = withdrawal.statusColor;

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Amount & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${withdrawal.amount.toStringAsFixed(2)}',
                          style: AppTypography.title.copyWith(
                            fontSize: 17,
                            fontFamily: 'monospace',
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Payout Request #${withdrawal.id}',
                        style: AppTypography.label.copyWith(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        withdrawal.statusDisplay,
                        style: AppTypography.label.copyWith(
                          fontSize: 11,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Middle Row: Bank Account & Requested Date
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    withdrawal.payoutAccountDisplay != null
                        ? '${withdrawal.payoutAccountDisplay!.bankName ?? "Bank"} (${withdrawal.payoutAccountDisplay!.maskedAccountDisplay})'
                        : 'Direct Bank Transfer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Requested: ${_formatDate(withdrawal.requestedAt ?? withdrawal.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // If completed: UTR / Bank Reference
            if (withdrawal.isCompleted &&
                withdrawal.bankTransactionId != null &&
                withdrawal.bankTransactionId!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 15,
                      color: Color(0xFF166534),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'UTR / Bank Ref: ${withdrawal.bankTransactionId}',
                        style: AppTypography.label.copyWith(
                          fontSize: 11.5,
                          fontFamily: 'monospace',
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // If failed: Failure Reason
            if (withdrawal.isFailed &&
                withdrawal.failureReason != null &&
                withdrawal.failureReason!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 15,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Failure Reason: ${withdrawal.failureReason}',
                        style: AppTypography.body.copyWith(
                          fontSize: 11.5,
                          color: const Color(0xFF9F1239),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Cancellation action if REQUESTED
            if (withdrawal.isCancellable && onCancel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFDC2626)),
                  label: Text(
                    'Cancel Request',
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

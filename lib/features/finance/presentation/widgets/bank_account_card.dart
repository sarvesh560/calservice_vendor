import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/payout_account.dart';

/// Card widget rendering a single registered technician payout bank account.
///
/// Security: Strictly displays masked account number `•••• 1234`.
class BankAccountCard extends StatelessWidget {
  const BankAccountCard({
    super.key,
    required this.account,
    this.onDelete,
  });

  final PayoutAccount account;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = account.statusColor;

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
            // Bank Name + Status Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandMist,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          size: 20,
                          color: AppColors.brandMidnightDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.bankName.isNotEmpty ? account.bankName : 'Bank Account',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title.copyWith(
                                fontSize: 14.5,
                                color: AppColors.brandMidnight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              account.accountHolderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
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
                        account.statusDisplay,
                        style: AppTypography.label.copyWith(
                          fontSize: 10.5,
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

            // Account Number (Masked) & IFSC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Number',
                        style: AppTypography.label.copyWith(
                          fontSize: 10.5,
                          color: AppColors.brandMidnightDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          account.maskedAccountNumber,
                          style: AppTypography.title.copyWith(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            color: AppColors.brandMidnight,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'IFSC Code',
                      style: AppTypography.label.copyWith(
                        fontSize: 10.5,
                        color: AppColors.brandMidnightDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.ifscCode.isNotEmpty ? account.ifscCode : '—',
                      style: AppTypography.title.copyWith(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: AppColors.brandMidnight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Bottom row: Account type + Primary + Delete action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandMist,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          account.accountTypeDisplay,
                          style: AppTypography.label.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (account.isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandMidnight.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.brandMidnight.withValues(alpha: 0.15), width: 0.6),
                          ),
                          child: Text(
                            'PRIMARY',
                            style: AppTypography.label.copyWith(
                              fontSize: 9.5,
                              color: AppColors.brandMidnight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                    onPressed: onDelete,
                    tooltip: 'Deactivate Account',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

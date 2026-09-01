import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/wallet_transaction.dart';

/// Modal bottom sheet showing comprehensive ledger transaction details.
class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({super.key, required this.transaction});

  final WalletTransaction transaction;

  static Future<void> show(BuildContext context, WalletTransaction transaction) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(transaction: transaction),
    );
  }

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
    return '$day $month $year, $hour12:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final amountPrefix = isCredit ? '+ ' : '- ';
    final amountColor = isCredit ? const Color(0xFF166534) : const Color(0xFF9F1239);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Details',
                        style: AppTypography.headline.copyWith(color: AppColors.brandMidnight, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: TXN#${transaction.id}',
                        style: AppTypography.label.copyWith(
                          fontSize: 11.5,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.brandMidnight),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Hero Amount Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isCredit
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: isCredit
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFECDD3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    transaction.displayTitle,
                    style: AppTypography.title.copyWith(
                      fontSize: 13,
                      color: isCredit
                          ? const Color(0xFF14532D)
                          : const Color(0xFF881337),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$amountPrefix₹${transaction.amount.toStringAsFixed(2)}',
                    style: AppTypography.title.copyWith(
                      fontSize: 26,
                      fontFamily: 'monospace',
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BadgePill(
                        label: transaction.direction,
                        color: isCredit
                            ? const Color(0xFF166534)
                            : const Color(0xFF9F1239),
                        bgColor: isCredit
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFFE4E6),
                      ),
                      const SizedBox(width: 8),
                      _BadgePill(
                        label: transaction.status.replaceAll('_', ' '),
                        color: transaction.statusColor,
                        bgColor: AppColors.surface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Detailed Data Rows
            _DataSection(
              title: 'TRANSACTION BREAKDOWN',
              children: [
                if (transaction.referenceId != null)
                  _DataRow(
                    label: 'Reference ID',
                    value: transaction.referenceId!,
                    isMonospace: true,
                  ),
                if (transaction.grossAmount != null)
                  _DataRow(
                    label: 'Job Gross Value',
                    value: '₹${transaction.grossAmount!.toStringAsFixed(2)}',
                    isMonospace: true,
                  ),
                if (transaction.earnRateSnapshot != null)
                  _DataRow(
                    label: 'Technician Share',
                    value:
                        '${(transaction.earnRateSnapshot! * 100).toStringAsFixed(1)}%',
                    isMonospace: true,
                  ),
                if (transaction.platformDeductionAmount != null)
                  _DataRow(
                    label: 'Platform Deduction',
                    value:
                        '₹${transaction.platformDeductionAmount!.toStringAsFixed(2)}',
                    isMonospace: true,
                  ),
                if (transaction.balanceBefore != null)
                  _DataRow(
                    label: 'Balance Before',
                    value: '₹${transaction.balanceBefore!.toStringAsFixed(2)}',
                    isMonospace: true,
                  ),
                if (transaction.balanceAfter != null)
                  _DataRow(
                    label: 'Balance After',
                    value: '₹${transaction.balanceAfter!.toStringAsFixed(2)}',
                    isMonospace: true,
                    highlight: true,
                  ),
                if (transaction.balanceType != null)
                  _DataRow(
                    label: 'Balance Type',
                    value: transaction.balanceType!,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _DataSection(
              title: 'TIMESTAMPS & TIMELINE',
              children: [
                _DataRow(
                  label: 'Created Timestamp',
                  value: _formatDate(transaction.createdAt),
                ),
                if (transaction.settlementReleaseAt != null)
                  _DataRow(
                    label: 'T+7 Settlement Date',
                    value: _formatDate(transaction.settlementReleaseAt),
                  ),
                if (transaction.releasedAt != null)
                  _DataRow(
                    label: 'Released Timestamp',
                    value: _formatDate(transaction.releasedAt),
                  ),
              ],
            ),

            if (transaction.description != null &&
                transaction.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _DataSection(
                title: 'DESCRIPTION & NOTES',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      transaction.description!,
                      style: AppTypography.body.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandMidnight,
                side: BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 10.5,
          color: color,
        ),
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  const _DataSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              4,
            ),
            child: Text(
              title,
              style: AppTypography.label.copyWith(
                fontSize: 10,
                letterSpacing: 0.8,
                color: AppColors.brandMidnightDark,
              ),
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool isMonospace;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.body.copyWith(
                fontSize: 12.5,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                fontFamily: isMonospace ? 'monospace' : null,
                color: highlight
                    ? AppColors.brandMidnight
                    : AppColors.brandMidnight.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

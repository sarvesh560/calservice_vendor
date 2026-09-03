import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ledger_row.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import 'finance_providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(walletTransactionsProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(title: 'Transactions'),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: ')),
        data: (transactions) {
          if (transactions.results.isEmpty) return const Center(child: Text('No transactions found.'));
          return Container(
            color: AppColors.surface,
            child: ListView.builder(
              itemCount: transactions.results.length,
              itemBuilder: (context, index) {
                final tx = transactions.results[index];
                return LedgerRow(
                  title: tx.description ?? 'Transaction',
                  date: dateFormat.format(tx.createdAt ?? DateTime.now()),
                  amount: currency.format(tx.amount),
                  status: tx.status,
                  isCredit: tx.direction == 'CREDIT',
                  isLast: index == transactions.results.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

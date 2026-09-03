import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ledger_row.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import 'finance_providers.dart';


class WithdrawalsScreen extends ConsumerWidget {
  const WithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wAsync = ref.watch(walletWithdrawalsProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(title: 'Withdrawals'),
      body: wAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: ')),
        data: (withdrawals) {
          if (withdrawals.isEmpty) return const Center(child: Text('No withdrawals found.'));
          return Container(
            color: AppColors.surface,
            child: ListView.builder(
              itemCount: withdrawals.length,
              itemBuilder: (context, index) {
                final w = withdrawals[index];
                return LedgerRow(
                  title: 'To Bank',
                  date: dateFormat.format(w.createdAt ?? DateTime.now()),
                  amount: currency.format(w.amount),
                  status: w.status,
                  isCredit: false,
                  isLast: index == withdrawals.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

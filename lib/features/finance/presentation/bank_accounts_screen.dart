import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/settings_row.dart';
import '../../../shared/widgets/status_badge.dart';
import 'finance_providers.dart';

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(payoutAccountsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumSecondaryAppBar(
        title: 'Bank Accounts',
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: Implement add bank account
            },
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: ')),
        data: (accounts) {
          if (accounts.isEmpty) return const Center(child: Text('No bank accounts linked.'));
          return Container(
            color: AppColors.surface,
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                return SettingsRow(
                  icon: Icons.account_balance_rounded,
                  title: acc.bankName,
                  subtitle: ' • ...',
                  trailing: acc.isPrimary ? const StatusBadge(status: 'ACTIVE') : const SizedBox.shrink(),
                  isLast: index == accounts.length - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

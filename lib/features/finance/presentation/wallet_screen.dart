import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/premium_buttons.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/settings_row.dart';
import 'finance_providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(employeeWalletProvider);
    final wallet = walletAsync.valueOrNull;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(title: 'Wallet'),
      body: wallet == null 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => ref.refresh(employeeWalletProvider.future),
            child: ListView(
              children: [
                Container(
                  color: AppColors.brandMidnightDark,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl * 1.5),
                  child: Column(
                    children: [
                      Text('AVAILABLE BALANCE', style: AppTypography.label.copyWith(color: AppColors.brandChampagneDark)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        currency.format(wallet.availableBalance),
                        style: AppTypography.display.copyWith(color: AppColors.brandMist, fontSize: 40),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Pending: ', style: AppTypography.bodySmall.copyWith(color: AppColors.brandSlate)),
                          Text(
                            currency.format(wallet.pendingBalance),
                            style: AppTypography.numeric.copyWith(color: AppColors.brandMist),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: PremiumButton(
                    label: 'Withdraw Funds',
                    icon: Icons.account_balance_wallet_outlined,
                    onPressed: () => context.push('/finance/withdraw'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(title: 'FINANCE ACTIVITY'),
                Container(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.list_alt_rounded,
                        title: 'All Transactions',
                        subtitle: 'View earnings and deductions',
                        onTap: () => context.push('/finance/transactions'),
                      ),
                      SettingsRow(
                        icon: Icons.history_rounded,
                        title: 'Withdrawal History',
                        subtitle: 'Track your payouts',
                        onTap: () => context.push('/finance/withdrawals'),
                      ),
                      SettingsRow(
                        icon: Icons.account_balance_rounded,
                        title: 'Bank Accounts',
                        subtitle: 'Manage your payout methods',
                        isLast: true,
                        onTap: () => context.push('/finance/bank-accounts'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
    );
  }
}

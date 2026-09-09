import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
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
      appBar: PremiumSecondaryAppBar(title: context.tr('wallet_overview')),
      body: wallet == null 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => ref.refresh(employeeWalletProvider.future),
            child: ListView(
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl * 1.5),
                  child: Column(
                    children: [
                      Text(
                        context.tr('earnings').toUpperCase(),
                        style: AppTypography.label.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        currency.format(wallet.availableBalance),
                        style: AppTypography.display.copyWith(
                          color: AppColors.textOnPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pending: ',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                          Text(
                            currency.format(wallet.pendingBalance),
                            style: AppTypography.numeric.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
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
                    label: context.tr('withdraw_funds'),
                    icon: Icons.account_balance_wallet_outlined,
                    onPressed: () => context.push('/finance/withdraw'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                SectionHeader(title: context.tr('finance_earnings').toUpperCase()),
                Container(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.list_alt_rounded,
                        title: context.tr('transactions_ledger'),
                        subtitle: 'View earnings and deductions',
                        onTap: () => context.push('/finance/transactions'),
                      ),
                      SettingsRow(
                        icon: Icons.history_rounded,
                        title: context.tr('withdrawal_requests'),
                        subtitle: 'Track your payouts',
                        onTap: () => context.push('/finance/withdrawals'),
                      ),
                      SettingsRow(
                        icon: Icons.account_balance_rounded,
                        title: context.tr('payout_bank_accounts'),
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


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../data/finance_repository.dart';
import '../../domain/employee_wallet.dart';
import '../../domain/payout_account.dart';
import '../finance_providers.dart';
import 'add_bank_account_sheet.dart';

/// Modal bottom sheet for requesting a technician wallet withdrawal.
class RequestWithdrawalSheet extends ConsumerStatefulWidget {
  const RequestWithdrawalSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RequestWithdrawalSheet(),
    );
  }

  @override
  ConsumerState<RequestWithdrawalSheet> createState() => _RequestWithdrawalSheetState();
}

class _RequestWithdrawalSheetState extends ConsumerState<RequestWithdrawalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  int? _selectedPayoutAccountId;
  bool _isSubmitting = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(2);
      _serverError = null;
    });
  }

  Future<void> _submit(double availableBalance, List<PayoutAccount> accounts) async {
    if (_isSubmitting) return;

    if (accounts.isEmpty) {
      setState(() => _serverError = 'Please add a bank account before requesting withdrawal.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      setState(() => _serverError = 'Please enter a valid numeric amount.');
      return;
    }

    if (amount < EmployeeWallet.minWithdrawalThreshold) {
      setState(() => _serverError = 'Minimum withdrawal amount is ₹${EmployeeWallet.minWithdrawalThreshold.toStringAsFixed(2)}.');
      return;
    }

    if (amount > availableBalance) {
      setState(() => _serverError = 'Amount exceeds available balance (₹${availableBalance.toStringAsFixed(2)}).');
      return;
    }

    final payoutAccountId = _selectedPayoutAccountId ?? accounts.firstOrNull?.id;

    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    try {
      await ref.read(financeRepositoryProvider).requestWithdrawal(
        amount: amount,
        payoutAccountId: payoutAccountId,
      );

      // Invalidate providers for real-time reactivity
      ref.invalidate(employeeWalletProvider);
      ref.invalidate(walletWithdrawalsProvider);
      ref.invalidate(walletTransactionsProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal request of ₹${amount.toStringAsFixed(2)} submitted successfully.'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _serverError = describeDioError(e, fallback: 'Failed to request withdrawal.');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(employeeWalletProvider);
    final accountsAsync = ref.watch(payoutAccountsProvider);

    final wallet = walletAsync.valueOrNull;
    final availableBalance = wallet?.availableBalance ?? 0.0;
    final accounts = accountsAsync.valueOrNull ?? [];

    // Preselect primary account if none selected
    if (_selectedPayoutAccountId == null && accounts.isNotEmpty) {
      final primary = accounts.where((a) => a.isPrimary).firstOrNull ?? accounts.first;
      _selectedPayoutAccountId = primary.id;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.brandMidnight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 20,
                          color: AppColors.brandMidnight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Request Payout',
                        style: AppTypography.headline.copyWith(color: AppColors.brandMidnight, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.brandMidnight),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Available Balance Strip
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.brandChampagne.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available for Payout',
                          style: AppTypography.label.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${availableBalance.toStringAsFixed(0)}',
                          style: AppTypography.title.copyWith(
                            fontSize: 18,
                            fontFamily: 'monospace',
                            color: AppColors.brandMidnight,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brandMist,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Min Threshold',
                            style: AppTypography.label.copyWith(
                              fontSize: 9.5,
                              color: AppColors.brandMidnightDark,
                            ),
                          ),
                          Text(
                            '₹5,000',
                            style: AppTypography.label.copyWith(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.brandMidnight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Server error alert
              if (_serverError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFE11D48)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _serverError!,
                          style: AppTypography.body.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF9F1239),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Amount Input Field
              Text(
                'Payout Amount (₹)',
                style: AppTypography.title.copyWith(
                  fontSize: 12.5,
                  color: AppColors.brandMidnight,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.body.copyWith(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandMidnight,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: AppTypography.body.copyWith(
                    fontSize: 16,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                  hintText: '5000',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a payout amount.';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null) {
                    return 'Please enter a valid numeric value.';
                  }
                  if (parsed < EmployeeWallet.minWithdrawalThreshold) {
                    return 'Amount must be at least ₹5,000.';
                  }
                  if (parsed > availableBalance) {
                    return 'Amount exceeds available balance of ₹${availableBalance.toStringAsFixed(0)}.';
                  }
                  return null;
                },
                onChanged: (_) {
                  if (_serverError != null) setState(() => _serverError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Quick Amount Preset Chips
              if (availableBalance >= 5000) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PresetChip(
                      label: 'Min ₹5K',
                      onTap: () => _setAmount(5000.0),
                    ),
                    if (availableBalance * 0.5 >= 5000)
                      _PresetChip(
                        label: '50% (₹${(availableBalance * 0.5).toStringAsFixed(0)})',
                        onTap: () => _setAmount(availableBalance * 0.5),
                      ),
                    if (availableBalance * 0.75 >= 5000)
                      _PresetChip(
                        label: '75% (₹${(availableBalance * 0.75).toStringAsFixed(0)})',
                        onTap: () => _setAmount(availableBalance * 0.75),
                      ),
                    _PresetChip(
                      label: 'Max ₹${availableBalance.toStringAsFixed(0)}',
                      onTap: () => _setAmount(availableBalance),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Bank Account Selector / Prompt
              Text(
                'Destination Bank Account',
                style: AppTypography.title.copyWith(
                  fontSize: 12.5,
                  color: AppColors.brandMidnight,
                ),
              ),
              const SizedBox(height: 8),

              if (accounts.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'No bank account linked. Add an account to receive payouts.',
                        style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final added = await AddBankAccountSheet.show(context);
                          if (added == true) {
                            ref.invalidate(payoutAccountsProvider);
                          }
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Bank Account'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandMidnight,
                          side: BorderSide(color: AppColors.border),
                          minimumSize: const Size(120, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedPayoutAccountId,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: accounts.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.id,
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_outlined, size: 16, color: AppColors.brandMidnightDark),
                          const SizedBox(width: 8),
                          Text(
                            '${account.bankName} (${account.maskedAccountNumber})',
                            style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.brandMidnight),
                          ),
                          if (account.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.brandMist,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'PRIMARY',
                                style: AppTypography.label.copyWith(
                                  fontSize: 8.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPayoutAccountId = val);
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Submit Action
              LoadingButton(
                label: 'REQUEST PAYOUT',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: availableBalance >= EmployeeWallet.minWithdrawalThreshold &&
                        accounts.isNotEmpty
                    ? () => _submit(availableBalance, accounts)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandChampagne,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            fontSize: 11,
            color: AppColors.brandMidnight,
          ),
        ),
      ),
    );
  }
}

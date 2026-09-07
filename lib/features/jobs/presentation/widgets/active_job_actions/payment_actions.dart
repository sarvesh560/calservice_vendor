import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/premium_buttons.dart';
import '../../../domain/job.dart';
import '../../../domain/job_payment.dart';
import '../../jobs_providers.dart';
import '../../../data/job_actions_repository.dart';

class PaymentActions extends ConsumerStatefulWidget {
  const PaymentActions({super.key, required this.job});
  final Job job;

  @override
  ConsumerState<PaymentActions> createState() => _PaymentActionsState();
}

class _PaymentActionsState extends ConsumerState<PaymentActions> {
  JobPaymentInfo? _paymentInfo;
  bool _isLoading = true;
  String? _error;
  String? _success;
  
  final _amountController = TextEditingController();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPayment();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchPayment() async {
    try {
      final repo = ref.read(jobActionsRepositoryProvider);
      final info = await repo.fetchPayment(widget.job.id);
      if (mounted) {
        setState(() {
          _paymentInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCollectCash() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    
    setState(() {
      _isActionLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(jobActionsRepositoryProvider);
      final msg = await repo.collectCash(widget.job.id, amount);
      
      await _fetchPayment();
      if (!mounted) return;
      setState(() {
        _success = msg;
      });
      ref.invalidate(activeJobsProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isPaid = _paymentInfo?.isPaid ?? false;
    final isOnline = _paymentInfo?.isOnline ?? false;
    final amountDue = _paymentInfo?.amountDue ?? 0.0;
    final currency = _paymentInfo?.currency ?? '₹';
    final needsCash = !isPaid && !isOnline && (_paymentInfo?.isCashPending ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.error.tintBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error.base, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.error.base)),
                ),
              ],
            ),
          )
        else if (_success != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.success.tintBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success.base, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(_success!, style: AppTypography.bodySmall.copyWith(color: AppColors.success.base)),
                ),
              ],
            ),
          ),
          
        Text(
          'Payment Status',
          style: AppTypography.title.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        
        if (isPaid)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.success.tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.success.tintBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success.base, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Completed', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                      Text('This job has been fully paid.', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (isOnline && !needsCash)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.primary, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Online Payment Pending', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                      Text('The customer will pay online.', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (needsCash)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cash Collection', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                    Text(
                      '$currency${amountDue.toStringAsFixed(2)}',
                      style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter amount received',
                    prefixText: '$currency ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PremiumButton(
                  onPressed: _isActionLoading ? null : _handleCollectCash,
                  label: 'Confirm Cash Received',
                  isLoading: _isActionLoading,
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('No payment action required at this time.'),
          ),
      ],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../../../shared/widgets/success_animation.dart';
import '../../data/job_actions_repository.dart';
import '../../domain/job.dart';
import '../jobs_providers.dart';

class OfferActionsSection extends ConsumerStatefulWidget {
  const OfferActionsSection({super.key, required this.job});

  final Job job;

  @override
  ConsumerState<OfferActionsSection> createState() => _OfferActionsSectionState();
}

class _OfferActionsSectionState extends ConsumerState<OfferActionsSection> {
  bool _isAccepting = false;
  bool _isDeclining = false;
  String? _error;

  Future<void> _refreshJobs() async {
    ref.invalidate(activeJobsProvider);
    await ref.read(activeJobsProvider.future);
  }

  String? _codeOf(DioException e) {
    final data = e.response?.data;
    return data is Map ? data['code'] as String? : null;
  }

  Future<void> _accept() async {
    final fallbackMsg = context.tr('error_occurred');
    setState(() {
      _isAccepting = true;
      _error = null;
    });
    try {
      await ref.read(jobActionsRepositoryProvider).acceptOffer(widget.job.id);
      await _refreshJobs();
      if (mounted) {
        await SuccessAnimation.showSuccessDialog(
          context,
          title: 'Job Accepted',
          message: 'Offer accepted. Head to active jobs to start work.',
          actionLabel: 'Continue',
        );
      }
    } on DioException catch (e) {
      final code = _codeOf(e);
      String message = describeDioError(e, fallback: fallbackMsg);
      setState(() => _error = message);
      if (code == 'JOB_ALREADY_ACCEPTED' || code == 'OFFER_EXPIRED') {
        await _refreshJobs();
        if (mounted) Navigator.of(context).maybePop();
      }
    } catch (_) {
      setState(() => _error = fallbackMsg);
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _declineFlow() async {
    final reason = await _showDeclineReasonSheet(context);
    if (reason == null || !mounted) return;

    setState(() {
      _isDeclining = true;
      _error = null;
    });
    try {
      await ref.read(jobActionsRepositoryProvider).rejectOffer(widget.job.id, reason);
      await _refreshJobs();
      if (mounted) Navigator.of(context).maybePop();
    } on DioException catch (e) {
      setState(() => _error = describeDioError(e, fallback: context.tr('error_occurred')));
    } catch (_) {
      setState(() => _error = context.tr('error_occurred'));
    } finally {
      if (mounted) setState(() => _isDeclining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
            ),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
            ),
          ),
        ],
        Row(
          children: [
            Expanded(
              child: LoadingButton(
                label: context.tr('confirm'),
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isAccepting,
                onPressed: _isDeclining ? null : _accept,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: LoadingButton(
                label: context.tr('cancel'),
                filled: false,
                isLoading: _isDeclining,
                onPressed: _isAccepting ? null : _declineFlow,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _declineReasons = [
  'Too far',
  'Busy / Heavy traffic',
  'Vehicle issue',
  'Service mismatch',
  'Personal reason',
  'Other',
];

Future<String?> _showDeclineReasonSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _DeclineReasonSheet(),
  );
}

class _DeclineReasonSheet extends StatefulWidget {
  const _DeclineReasonSheet();

  @override
  State<_DeclineReasonSheet> createState() => _DeclineReasonSheetState();
}

class _DeclineReasonSheetState extends State<_DeclineReasonSheet> {
  String _selected = 'Too far';
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOther = _selected == 'Other';
    final canConfirm = !isOther || _customController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.tr('cancel'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              RadioGroup<String>(
                groupValue: _selected,
                onChanged: (value) {
                  if (value != null) setState(() => _selected = value);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final reason in _declineReasons)
                      RadioListTile<String>(
                        value: reason,
                        title: Text(reason),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              if (isOther) ...[
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _customController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Explanation'),
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              LoadingButton(
                label: context.tr('confirm'),
                onPressed: canConfirm
                    ? () => Navigator.of(context).pop(
                        isOther ? _customController.text.trim() : _selected,
                      )
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


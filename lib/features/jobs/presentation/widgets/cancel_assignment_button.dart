import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../data/job_actions_repository.dart';
import '../../domain/job.dart';
import '../jobs_providers.dart';

const _cancelReasons = [
  ('VEHICLE_ISSUE', 'Vehicle issue / Breakdown'),
  ('TRAFFIC_ROUTE_ISSUE', 'Heavy traffic / Road blockage'),
  ('TOO_FAR', 'Distance too far / Unreachable in time'),
  ('SERVICE_MISMATCH', 'Service requires different tools / equipment'),
  ('CUSTOMER_LOCATION_ISSUE', 'Customer site unreachable / unsafe access'),
  ('SAFETY_CONCERN', 'Safety concern / Hazardous conditions'),
  ('PERSONAL_EMERGENCY', 'Personal emergency'),
  ('OTHER', 'Other reason (explanation required)'),
];

class CancelAssignmentButton extends StatelessWidget {
  const CancelAssignmentButton({super.key, required this.job});

  final Job job;

  bool get _canCancelNow {
    final info = job.cancellationInfo;
    if (info == null) return true;
    if (info.canCancel == false && (info.remainingSeconds ?? 1) == 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      label: context.tr('cancel'),
      filled: false,
      onPressed: _canCancelNow
          ? () => showDialog<void>(
              context: context,
              builder: (context) => _CancelAssignmentDialog(job: job),
            )
          : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFDC2626),
        side: const BorderSide(color: Color(0xFFFECDD3)),
      ),
    );
  }
}

class _CancelAssignmentDialog extends ConsumerStatefulWidget {
  const _CancelAssignmentDialog({required this.job});

  final Job job;

  @override
  ConsumerState<_CancelAssignmentDialog> createState() => _CancelAssignmentDialogState();
}

class _CancelAssignmentDialogState extends ConsumerState<_CancelAssignmentDialog> {
  String _selectedCode = 'VEHICLE_ISSUE';
  final _detailController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final fallbackMsg = context.tr('error_occurred');
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref
          .read(jobActionsRepositoryProvider)
          .cancelJob(
            widget.job.id,
            reasonCode: _selectedCode,
            reasonDetail: _detailController.text.trim(),
          );
      ref.invalidate(activeJobsProvider);
      await ref.read(activeJobsProvider.future);
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      String message;
      switch (code) {
        case 'CANCELLATION_NOT_ALLOWED_IN_CURRENT_STATE':
          message = fallbackMsg;
          break;
        case 'CANCELLATION_LOCKED_AFTER_OTP':
          message = fallbackMsg;
          break;
        default:
          message = describeDioError(e, fallback: fallbackMsg);
      }
      setState(() => _error = message);
    } catch (_) {
      setState(() => _error = fallbackMsg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOther = _selectedCode == 'OTHER';
    final canConfirm = !isOther || _detailController.text.trim().isNotEmpty;

    return AlertDialog(
      title: Text(context.tr('cancel')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
            ],
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<String>(
              groupValue: _selectedCode,
              onChanged: (value) {
                if (value != null) setState(() => _selectedCode = value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (code, label) in _cancelReasons)
                    RadioListTile<String>(
                      value: code,
                      title: Text(label, style: const TextStyle(fontSize: 13)),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                ],
              ),
            ),
            if (isOther) ...[
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _detailController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Explanation'),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: (canConfirm && !_isSubmitting) ? _confirm : null,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
          child: Text(_isSubmitting ? context.tr('loading') : context.tr('confirm')),
        ),
      ],
    );
  }
}


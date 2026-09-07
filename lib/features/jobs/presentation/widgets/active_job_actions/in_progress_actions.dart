import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/premium_buttons.dart';
import '../../../../../shared/widgets/photo_source_sheet.dart';
import '../../../domain/job.dart';
import '../../jobs_providers.dart';
import '../../../data/job_actions_repository.dart';

class InProgressActions extends ConsumerStatefulWidget {
  const InProgressActions({super.key, required this.job});
  final Job job;

  @override
  ConsumerState<InProgressActions> createState() => _InProgressActionsState();
}

class _InProgressActionsState extends ConsumerState<InProgressActions> {
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _handleFinishJob() async {
    final path = await pickJobPhoto(context);
    if (path == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(jobActionsRepositoryProvider);
      final msg = await repo.uploadProof(
        widget.job.id,
        afterPresencePhotoPath: path,
      );
      
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
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleRequestExtension() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extensions Unavailable'),
        content: const Text(
          'Work extensions and parts purchases are not supported in this version of the app. Please contact Dispatch if this job requires additional parts or labor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Active Work Dashboard',
          style: AppTypography.title.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumButton(
                onPressed: _isLoading ? null : _handleFinishJob,
                label: 'Finish Job (Requires Selfie)',
                icon: Icons.check_circle,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                onPressed: _isLoading ? null : _handleRequestExtension,
                label: 'Request Work Extension',
                icon: Icons.add_circle_outline,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/location/location_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/premium_buttons.dart';
import '../../../../../shared/widgets/photo_source_sheet.dart';
import '../../../domain/job.dart';
import '../../../domain/pre_service_status.dart';
import '../../jobs_providers.dart';
import '../../../data/job_actions_repository.dart';
import '../../../data/job_time_tracking_repository.dart';

class PreServiceActions extends ConsumerStatefulWidget {
  const PreServiceActions({super.key, required this.job});
  final Job job;

  @override
  ConsumerState<PreServiceActions> createState() => _PreServiceActionsState();
}

class _PreServiceActionsState extends ConsumerState<PreServiceActions> {
  PreServiceStatus _status = PreServiceStatus.initial;
  bool _isLoading = true;
  String? _error;
  String? _success;
  
  final _otpController = TextEditingController();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final repo = ref.read(jobActionsRepositoryProvider);
      final status = await repo.fetchPreServiceStatus(widget.job.id);
      if (mounted) {
        setState(() {
          _status = status;
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

  Future<void> _handleOtpSubmit() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _error = 'Please enter a valid OTP');
      return;
    }
    setState(() {
      _isActionLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(jobActionsRepositoryProvider);
      final msg = await repo.verifyOtp(widget.job.id, otp);
      await _fetchStatus();
      if (!mounted) return;
      setState(() {
        _success = msg;
      });
      _checkAutoClockIn();
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

  Future<void> _handleCaptureSelfie() async {
    final path = await pickJobPhoto(context);
    if (path == null) return;
    
    setState(() {
      _isActionLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(jobActionsRepositoryProvider);
      final msg = await repo.uploadPreServicePhoto(
        widget.job.id,
        photoType: PreServicePhotoType.presence,
        filePath: path,
      );
      await _fetchStatus();
      if (!mounted) return;
      setState(() {
        _success = msg;
      });
      _checkAutoClockIn();
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

  Future<void> _checkAutoClockIn() async {
    if (_status.isComplete || (_status.otpVerified && _status.presencePhoto)) {
      setState(() {
        _isActionLoading = true;
        _error = null;
      });
      try {
        final pos = await LocationService().getCurrentPosition();
        final timeRepo = ref.read(jobTimeTrackingRepositoryProvider);
        await timeRepo.clockIn(
          jobId: widget.job.id,
          lat: pos.latitude,
          lon: pos.longitude,
          accuracy: pos.accuracy,
        );
        ref.invalidate(activeJobsProvider);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = 'Auto Clock-in failed: ${e.toString().replaceAll('Exception: ', '')}';
        });
      } finally {
        if (mounted) {
          setState(() => _isActionLoading = false);
        }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pre-Service Checklist',
          style: AppTypography.title.copyWith(color: AppColors.brandMidnightDark),
        ),
        const SizedBox(height: AppSpacing.md),
        
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
          
        // OTP Section
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: _status.otpVerified ? AppColors.success.tint : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: _status.otpVerified ? AppColors.success.tintBorder : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _status.otpVerified ? Icons.check_circle_rounded : Icons.dialpad_rounded,
                    color: _status.otpVerified ? AppColors.success.base : AppColors.brandMidnight,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '1. Customer OTP Verification',
                    style: AppTypography.label.copyWith(
                      color: _status.otpVerified ? AppColors.success.base : AppColors.brandMidnight,
                    ),
                  ),
                ],
              ),
              if (!_status.otpVerified) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Enter 4-digit OTP',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 100,
                      child: PremiumButton(
                        onPressed: _isActionLoading ? null : _handleOtpSubmit,
                        label: 'Verify',
                        isLoading: _isActionLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Selfie Section
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _status.presencePhoto ? AppColors.success.tint : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: _status.presencePhoto ? AppColors.success.tintBorder : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _status.presencePhoto ? Icons.check_circle_rounded : Icons.camera_front_rounded,
                    color: _status.presencePhoto ? AppColors.success.base : AppColors.brandMidnight,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '2. Pre-Service Selfie',
                    style: AppTypography.label.copyWith(
                      color: _status.presencePhoto ? AppColors.success.base : AppColors.brandMidnight,
                    ),
                  ),
                ],
              ),
              if (!_status.presencePhoto) ...[
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  onPressed: _isActionLoading ? null : _handleCaptureSelfie,
                  label: 'Capture Live Selfie',
                  icon: Icons.camera_alt_outlined,
                  isLoading: _isActionLoading,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  String _getLocalizedStatus(BuildContext context, String rawStatus) {
    final upper = rawStatus.toUpperCase().replaceAll(' ', '_');
    switch (upper) {
      case 'PENDING':
      case 'PENDING_REVIEW':
      case 'PENDING_PAYMENT':
        return context.tr('status_pending');
      case 'ACCEPTED':
        return context.tr('status_accepted');
      case 'ON_THE_WAY':
        return context.tr('status_on_the_way');
      case 'ARRIVED':
        return context.tr('status_arrived');
      case 'IN_PROGRESS':
        return context.tr('status_in_progress');
      case 'COMPLETED':
        return context.tr('status_completed');
      case 'CANCELLED':
        return context.tr('status_cancelled');
      case 'ONLINE':
      case 'AVAILABLE':
      case 'ACTIVE':
        return context.tr('online');
      case 'OFFLINE':
      case 'UNAVAILABLE':
        return context.tr('offline');
      case 'BUSY':
        return context.tr('busy');
      case 'MISSING':
        return context.tr('doc_missing');
      case 'VALID':
      case 'APPROVED':
        return context.tr('doc_valid');
      case 'EXPIRING':
        return context.tr('doc_expiring');
      case 'EXPIRED':
        return context.tr('doc_expired');
      case 'REJECTED':
        return context.tr('doc_rejected');
      default:
        return rawStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    
    SemanticColor color;
    if (['AVAILABLE', 'ACTIVE', 'PAID', 'COMPLETED', 'ACCEPTED', 'VALID', 'APPROVED'].contains(upper)) {
      color = AppColors.success;
    } else if (['PENDING', 'PENDING PAYMENT', 'PENDING REVIEW', 'EXPIRING'].contains(upper)) {
      color = AppColors.warning;
    } else if (['OFFLINE', 'UNAVAILABLE', 'CANCELLED'].contains(upper)) {
      color = AppColors.info;
    } else {
      color = AppColors.error; // REJECTED, FAILED, EXPIRED, MISSING
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: color.tint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.tintBorder),
      ),
      child: Text(
        _getLocalizedStatus(context, status).toUpperCase(),
        style: AppTypography.caption.copyWith(color: color.base, fontWeight: FontWeight.w800),
      ),
    );
  }
}


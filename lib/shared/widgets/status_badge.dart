import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    
    SemanticColor color;
    if (['AVAILABLE', 'ACTIVE', 'PAID', 'COMPLETED', 'ACCEPTED'].contains(upper)) {
      color = AppColors.success;
    } else if (['PENDING', 'PENDING PAYMENT', 'PENDING REVIEW'].contains(upper)) {
      color = AppColors.warning;
    } else if (['OFFLINE', 'UNAVAILABLE', 'CANCELLED'].contains(upper)) {
      color = AppColors.info;
    } else {
      color = AppColors.error; // REJECTED, FAILED
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: color.tint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.tintBorder),
      ),
      child: Text(
        upper,
        style: AppTypography.caption.copyWith(color: color.base, fontWeight: FontWeight.w800),
      ),
    );
  }
}

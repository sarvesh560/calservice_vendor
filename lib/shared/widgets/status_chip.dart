import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_typography.dart';


/// Status colors ported 1:1 from the web app's StatusBadge.jsx color table,
/// so a given status always means the same color on web and mobile.
class _StatusStyle {
  const _StatusStyle(this.labelKey, this.defaultLabel, this.background, this.foreground, this.dot);

  final String labelKey;
  final String defaultLabel;
  final Color background;
  final Color foreground;
  final Color dot;
}

const _neutral = _StatusStyle(
  '',
  '',
  Color(0xFFF1F5F9),
  Color(0xFF334155),
  Color(0xFF94A3B8),
);

const Map<String, _StatusStyle> _statusStyles = {
  'approved': _StatusStyle(
    'doc_valid',
    'Approved',
    Color(0xFFECFDF5),
    Color(0xFF065F46),
    Color(0xFF10B981),
  ),
  'active': _StatusStyle(
    'online',
    'Active',
    Color(0xFFECFDF5),
    Color(0xFF065F46),
    Color(0xFF10B981),
  ),
  'online': _StatusStyle(
    'online',
    'Online',
    Color(0xFFECFDF5),
    Color(0xFF065F46),
    Color(0xFF10B981),
  ),
  'available': _StatusStyle(
    'available_for_dispatch',
    'Available',
    Color(0xFFECFDF5),
    Color(0xFF065F46),
    Color(0xFF10B981),
  ),
  'busy': _StatusStyle(
    'busy',
    'Busy',
    Color(0xFFEFF6FF),
    Color(0xFF1E40AF),
    Color(0xFF3B82F6),
  ),
  'submitted': _StatusStyle(
    'status_pending',
    'Submitted',
    Color(0xFFFFFBEB),
    Color(0xFF92400E),
    Color(0xFFF59E0B),
  ),
  'under_review': _StatusStyle(
    'registration_under_review',
    'Under Review',
    Color(0xFFFFFBEB),
    Color(0xFF92400E),
    Color(0xFFF59E0B),
  ),
  'pending': _StatusStyle(
    'status_pending',
    'Pending',
    Color(0xFFFFFBEB),
    Color(0xFF92400E),
    Color(0xFFF59E0B),
  ),
  'offered': _StatusStyle(
    'status_pending',
    'Offered',
    Color(0xFFFFFBEB),
    Color(0xFF92400E),
    Color(0xFFF59E0B),
  ),
  'correction_required': _StatusStyle(
    'action_required',
    'Correction Required',
    Color(0xFFFFF7ED),
    Color(0xFF9A3412),
    Color(0xFFF97316),
  ),
  'rejected': _StatusStyle(
    'doc_rejected',
    'Rejected',
    Color(0xFFFFF1F2),
    Color(0xFF9F1239),
    Color(0xFFF43F5E),
  ),
  'offline': _StatusStyle(
    'offline',
    'Offline',
    Color(0xFFF1F5F9),
    Color(0xFF334155),
    Color(0xFF94A3B8),
  ),
  'not_started': _StatusStyle(
    'status_pending',
    'Not Started',
    Color(0xFFF1F5F9),
    Color(0xFF334155),
    Color(0xFF94A3B8),
  ),
  'assigned': _StatusStyle(
    'status_accepted',
    'Assigned',
    Color(0xFFEFF6FF),
    Color(0xFF1E40AF),
    Color(0xFF3B82F6),
  ),
  'accepted': _StatusStyle(
    'status_accepted',
    'Accepted',
    Color(0xFFEEF2FF),
    Color(0xFF3730A3),
    Color(0xFF6366F1),
  ),
  'on_the_way': _StatusStyle(
    'status_on_the_way',
    'On The Way',
    Color(0xFFF0F9FF),
    Color(0xFF075985),
    Color(0xFF0EA5E9),
  ),
  'arrived': _StatusStyle(
    'status_arrived',
    'Arrived',
    Color(0xFFECFEFF),
    Color(0xFF155E75),
    Color(0xFF06B6D4),
  ),
  'in_progress': _StatusStyle(
    'status_in_progress',
    'In Progress',
    Color(0xFFFFFBEB),
    Color(0xFF92400E),
    Color(0xFFF59E0B),
  ),
  'completed': _StatusStyle(
    'status_completed',
    'Completed',
    Color(0xFFECFDF5),
    Color(0xFF065F46),
    Color(0xFF10B981),
  ),
  'cancelled': _StatusStyle(
    'status_cancelled',
    'Cancelled',
    Color(0xFFF1F5F9),
    Color(0xFF334155),
    Color(0xFF94A3B8),
  ),
};

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.label, this.dense = false});

  final String status;
  final String? label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final key = status.toLowerCase().trim().replaceAll(RegExp(r'[\s-]+'), '_');
    final style = _statusStyles[key] ?? _neutral;
    
    String displayText;
    if (label != null) {
      displayText = label!;
    } else if (style.labelKey.isNotEmpty) {
      displayText = context.tr(style.labelKey);
    } else if (style.defaultLabel.isNotEmpty) {
      displayText = style.defaultLabel;
    } else {
      displayText = status.replaceAll('_', ' ');
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: style.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              displayText.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: dense ? 9.5 : 10.5,
                color: style.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


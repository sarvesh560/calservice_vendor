import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_secondary_app_bar.dart';
import '../../../shared/widgets/animated_pressable.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/app_notification.dart';
import 'notifications_providers.dart';

/// Helper to extract associated job ID from notification metadata or title/message text.
int? extractJobIdFromNotification(AppNotification notification) {
  if (notification.relatedObjectId != null) {
    final raw = notification.relatedObjectId.toString().trim();
    final parsed = int.tryParse(raw);
    if (parsed != null && parsed > 0) return parsed;
  }
  // Fallback regex parsing on title and message for "#123" or "Job #123" or "Job 123"
  final text = '${notification.title} ${notification.message}';
  final match = RegExp(r'#(\d+)|[Jj]ob\s*#?\s*(\d+)').firstMatch(text);
  if (match != null) {
    final numStr = match.group(1) ?? match.group(2);
    if (numStr != null) {
      final parsed = int.tryParse(numStr);
      if (parsed != null && parsed > 0) return parsed;
    }
  }
  return null;
}

/// Helper to determine if a notification is related to a specific job.
bool isJobRelatedNotification(AppNotification notification, int? jobId) {
  final type = notification.notificationType?.toUpperCase() ?? '';
  // Explicit non-job types
  if (['SYSTEM', 'PAYROLL_AVAILABILITY', 'PROFILE', 'DOCUMENT', 'SERVICE_APPROVAL'].contains(type)) {
    return false;
  }
  // Explicit job types
  if (['JOB_OFFER', 'JOB_OFFERED', 'JOB_ASSIGNMENT', 'JOB_ASSIGNED', 'SPECIALIST_JOB_ASSIGNED',
       'WORK_EXTENSION_REQUEST', 'WORK_EXTENSION_DECISION', 'SCHEDULE_DELAY', 'WORK_START_OTP',
       'AUTOMATIC_ARRIVAL', 'DISPATCH_UNASSIGNED', 'JOB_UPDATE', 'JOB_CANCELLED', 'JOB_STATUS_CHANGED',
       'SERVICE_REQUEST'].contains(type)) {
    return true;
  }
  // Fallback check: if a jobId was parsed from metadata or text, treat as job-related
  if (jobId != null) return true;
  return false;
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumSecondaryAppBar(title: 'Notifications'),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: AsyncValueView(
          value: asyncNotifications,
          onRetry: () => ref.invalidate(notificationsProvider),
          builder: (context, result) {
            if (result.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl * 4),
                children: const [
                  SizedBox(height: AppSpacing.xxl * 2),
                  EmptyState(
                    icon: Icons.all_inbox_rounded,
                    title: "You're all caught up",
                    message: "No new notifications right now.\nWe'll let you know when something needs your attention.",
                  ),
                ],
              );
            }

            final grouped = _groupNotificationsByDate(result.items);
            final keys = grouped.keys.toList();

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl * 4),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final dateGroup = keys[index];
                final notifications = grouped[dateGroup]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                      child: Text(
                        dateGroup.toUpperCase(),
                        style: AppTypography.label.copyWith(
                          color: AppColors.brandSlate,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      separatorBuilder: (context, idx) => Divider(height: 1, color: AppColors.border, indent: AppSpacing.xxl * 2.5),
                      itemBuilder: (context, idx) {
                        return _NotificationTile(notification: notifications[idx]);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<String, List<AppNotification>> _groupNotificationsByDate(List<AppNotification> items) {
    final map = <String, List<AppNotification>>{};
    final now = DateTime.now();
    for (final item in items) {
      if (item.createdAt == null) continue;
      final date = item.createdAt!;
      String group;
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        group = 'Today';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        group = 'Yesterday';
      } else {
        group = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }

      map.putIfAbsent(group, () => []).add(item);
    }
    return map;
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  void _handleNotificationTap(BuildContext context, WidgetRef ref) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id).catchError((_) {});
    }

    final jobId = extractJobIdFromNotification(notification);
    final isJobNotif = isJobRelatedNotification(notification, jobId);

    if (isJobNotif) {
      if (jobId != null && jobId > 0) {
        context.push('/jobs/$jobId');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('This job is no longer available.'),
              backgroundColor: AppColors.brandMidnightDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  IconData _getIconForType(String? type) {
    switch (type?.toUpperCase()) {
      case 'JOB_OFFER':
      case 'JOB_OFFERED':
        return Icons.work_outline_rounded;
      case 'PAYMENT':
      case 'PAYROLL_AVAILABILITY':
        return Icons.payments_outlined;
      case 'DOCUMENT':
        return Icons.description_outlined;
      case 'SYSTEM':
      case 'PROFILE':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;
    
    return AnimatedPressable(
      onPressed: () => _handleNotificationTap(context, ref),
      child: Container(
        color: isUnread ? AppColors.brandChampagne.withValues(alpha: 0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnread ? AppColors.brandMidnightDark : AppColors.brandMist,
                shape: BoxShape.circle,
                border: isUnread ? null : Border.all(color: AppColors.border),
              ),
              child: Icon(
                _getIconForType(notification.notificationType),
                size: 20,
                color: isUnread ? AppColors.brandChampagne : AppColors.brandSlate,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                      color: isUnread ? AppColors.brandMidnightDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13, 
                      color: isUnread ? AppColors.brandSlate : AppColors.textSecondary, 
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _relativeTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600,
                      color: isUnread ? AppColors.brandChampagne : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _relativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

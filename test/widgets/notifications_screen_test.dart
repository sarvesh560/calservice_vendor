import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/domain/app_notification.dart';
import 'package:mobile/features/notifications/presentation/notifications_providers.dart';
import 'package:mobile/features/notifications/presentation/notifications_screen.dart';

class FakeNotificationsNotifier extends NotificationsNotifier {
  FakeNotificationsNotifier(this._initialResult);
  final NotificationsResult _initialResult;

  @override
  Future<NotificationsResult> build() async {
    return _initialResult;
  }
}

void main() {
  group('NotificationsScreen Specific Job Navigation Tests', () {
    test('extractJobIdFromNotification extracts numeric job ID from relatedObjectId', () {
      const notif = AppNotification(
        id: 101,
        title: 'New Job Offer Available!',
        message: 'You have a new job request #5012',
        notificationType: 'JOB_OFFER',
        relatedObjectId: 5012,
        isRead: false,
      );

      final jobId = extractJobIdFromNotification(notif);
      expect(jobId, equals(5012));
      expect(isJobRelatedNotification(notif, jobId), isTrue);
    });

    test('extractJobIdFromNotification parses job ID from message regex if relatedObjectId missing', () {
      const notif = AppNotification(
        id: 102,
        title: 'Job Status Updated',
        message: 'Customer updated address for Job #4088',
        notificationType: 'JOB_UPDATE',
        relatedObjectId: null,
        isRead: false,
      );

      final jobId = extractJobIdFromNotification(notif);
      expect(jobId, equals(4088));
      expect(isJobRelatedNotification(notif, jobId), isTrue);
    });

    test('isJobRelatedNotification identifies non-job notifications correctly', () {
      const systemNotif = AppNotification(
        id: 103,
        title: 'System Alert',
        message: 'Scheduled maintenance tonight from 2 AM to 3 AM',
        notificationType: 'SYSTEM',
        relatedObjectId: null,
        isRead: false,
      );

      final jobId = extractJobIdFromNotification(systemNotif);
      expect(isJobRelatedNotification(systemNotif, jobId), isFalse);
    });

    testWidgets('renders notifications list and tile interaction', (WidgetTester tester) async {
      final notifResult = NotificationsResult(
        unreadCount: 1,
        items: const [
          AppNotification(
            id: 201,
            title: 'New Service Request #1234',
            message: 'Tap to view details for job #1234',
            notificationType: 'JOB_OFFER',
            relatedObjectId: 1234,
            isRead: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider.overrideWith(() => FakeNotificationsNotifier(notifResult)),
          ],
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('New Service Request #1234'), findsOneWidget);
      expect(find.text('Tap to view details for job #1234'), findsOneWidget);
    });
  });
}

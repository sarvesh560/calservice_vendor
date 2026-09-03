import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/presence/data/presence_repository.dart';
import 'package:mobile/features/presence/domain/presence_status.dart';
import 'package:mobile/features/presence/presentation/presence_controller.dart';
import 'package:mobile/features/presence/presentation/widgets/availability_switch.dart';

class FakePresenceRepository implements PresenceRepository {
  PresenceStatus currentStatus = PresenceStatus.initialOffline();

  @override
  Future<PresenceStatus> fetchStatus() async {
    return currentStatus;
  }

  @override
  Future<PresenceStatus> setAvailability({required bool isOnline}) async {
    currentStatus = currentStatus.copyWith(
      isOnline: isOnline,
      availability: isOnline ? 'online' : 'offline',
    );
    return currentStatus;
  }
}

void main() {
  late FakePresenceRepository repository;

  setUp(() {
    repository = FakePresenceRepository();
  });

  group('Presence Availability Controller Tests', () {
    test('Initial state MUST be OFFLINE by default', () {
      final container = ProviderContainer(
        overrides: [
          presenceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(presenceControllerProvider);
      expect(state.isOnline, isFalse);
      expect(state.availability, equals('offline'));
    });

    test('Explicit setOnline(true) updates state to ONLINE', () async {
      final container = ProviderContainer(
        overrides: [
          presenceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(presenceControllerProvider.notifier);
      await controller.setOnline(true);

      final state = container.read(presenceControllerProvider);
      expect(state.isOnline, isTrue);
      expect(state.availability, equals('online'));
    });

    test('Explicit setOnline(false) updates state to OFFLINE', () async {
      final container = ProviderContainer(
        overrides: [
          presenceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(presenceControllerProvider.notifier);
      await controller.setOnline(true);
      expect(container.read(presenceControllerProvider).isOnline, isTrue);

      await controller.setOnline(false);
      expect(container.read(presenceControllerProvider).isOnline, isFalse);
      expect(container.read(presenceControllerProvider).availability, equals('offline'));
    });

    test('In-flight lock prevents duplicate concurrent toggle requests', () async {
      final container = ProviderContainer(
        overrides: [
          presenceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(presenceControllerProvider.notifier);
      final future1 = controller.setOnline(true);
      final future2 = controller.setOnline(false); // Should be ignored due to in-flight lock

      await Future.wait([future1, future2]);

      final state = container.read(presenceControllerProvider);
      expect(state.isOnline, isTrue);
    });

    test('Logout triggers setOfflineOnLogout reset', () async {
      final container = ProviderContainer(
        overrides: [
          presenceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(presenceControllerProvider.notifier);
      await controller.setOnline(true);
      expect(container.read(presenceControllerProvider).isOnline, isTrue);

      await controller.setOfflineOnLogout();

      expect(container.read(presenceControllerProvider).isOnline, isFalse);
    });
  });

  group('AvailabilitySwitch Widget Tests', () {
    testWidgets('Renders OFFLINE state by default with single switch control', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presenceRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AvailabilitySwitch(),
            ),
          ),
        ),
      );

      expect(find.text('You are Offline'), findsOneWidget);
      expect(find.text('New job offers are currently paused'), findsOneWidget);

      // Tap single switch to go online
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('You are Online'), findsOneWidget);
      expect(find.text('Available for new service requests'), findsOneWidget);
    });
  });
}

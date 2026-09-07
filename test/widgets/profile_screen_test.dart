import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/features/profile/domain/employee_profile.dart';
import 'package:mobile/features/profile/presentation/profile_providers.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    final testProfile = EmployeeProfile(
      employeeId: 'ORG--0024',
      firstName: 'Mani',
      lastName: 'S',
      email: 'mani@gmail.com',
      mobileNumber: '1234597890',
      phone: '1234597890',
      bio: 'Certified Air Conditioning Specialist',
      timezone: 'Asia/Kolkata',
      language: 'en',
      avatar: null,
      title: 'Senior Technician',
      companyName: 'CalServices',
      department: 'Field Services',
      state: 'California',
      country: 'United States',
      dateOfBirth: '1992-05-15',
      isOnline: true,
      liveAvailability: 'online',
      registrationStatus: 'approved',
      approvedServices: const [],
      allRequestedServices: const [],
      documents: const [],
      controlledFields: const ControlledFieldsConfig(
        isLocked: true,
        lockedFields: [],
      ),
    );

    testWidgets('renders all profile sections with authentic data', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            employeeProfileProvider.overrideWith((ref) => Future.value(testProfile)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Mani S'), findsOneWidget);
      expect(find.text('1234597890'), findsOneWidget);

      // Verify Sections
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('WORK & TERRITORY'), findsOneWidget);
      expect(find.text('FINANCE & EARNINGS'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('SECURITY & PRIVACY'), findsOneWidget);
      final signOutFinder = find.text('Sign Out');
      await tester.scrollUntilVisible(signOutFinder, 100);
      expect(signOutFinder, findsOneWidget);
    });

    testWidgets('opens language selector bottom sheet on language tap', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            employeeProfileProvider.overrideWith((ref) => Future.value(testProfile)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final langFinder = find.byIcon(Icons.language_rounded);
      expect(langFinder, findsOneWidget);

      await tester.tap(langFinder);
      await tester.pumpAndSettle();

      expect(find.text('Select App Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('தமிழ் (Tamil)'), findsOneWidget);
      expect(find.text('हिन्दी (Hindi)'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/domain/employee_profile.dart';
import 'package:mobile/features/profile/presentation/personal_information_screen.dart';
import 'package:mobile/features/profile/presentation/profile_providers.dart';

void main() {
  group('PersonalInformationScreen Widget Tests', () {
    final testProfile = EmployeeProfile(
      employeeId: 'ORG--0024',
      firstName: 'Sarvesh',
      lastName: 'Kumar',
      email: 'sarvesh@calservice.com',
      mobileNumber: '9876543210',
      phone: '9876543210',
      bio: 'Lead HVAC Specialist',
      timezone: 'Asia/Kolkata',
      language: 'en',
      avatar: null,
      title: 'Master HVAC Technician',
      companyName: 'CalService Vendor Corp',
      department: 'Field Engineering',
      state: 'Tamil Nadu',
      country: 'India',
      dateOfBirth: '1995-08-20',
      isOnline: true,
      liveAvailability: 'online',
      registrationStatus: 'approved',
      approvedServices: const [],
      allRequestedServices: const [],
      documents: const [],
      controlledFields: const ControlledFieldsConfig(
        isLocked: true,
        lockedFields: ['first_name', 'last_name'],
      ),
      onboardingData: const OnboardingData(
        status: 'completed',
        step: 7,
        draft: {
          'address': '123 Tech Park Road',
          'city': 'Chennai',
          'pincode': '600001',
        },
        services: [],
      ),
    );

    testWidgets('renders backend profile details correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            employeeProfileProvider.overrideWith((ref) => Future.value(testProfile)),
          ],
          child: const MaterialApp(
            home: PersonalInformationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Headers
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('PERSONAL DETAILS'), findsOneWidget);
      expect(find.text('BUSINESS INFORMATION'), findsOneWidget);
      expect(find.text('ADDRESS & TERRITORY'), findsOneWidget);

      // Personal Details
      expect(find.text('Sarvesh Kumar'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('sarvesh@calservice.com'), findsOneWidget);
      expect(find.text('1995-08-20'), findsOneWidget);
      expect(find.text('Master HVAC Technician'), findsOneWidget);

      // Business Info
      expect(find.text('CalService Vendor Corp'), findsOneWidget);
      expect(find.text('Field Engineering'), findsOneWidget);

      // Address & Territory
      expect(find.text('123 Tech Park Road'), findsOneWidget);
      expect(find.text('Chennai'), findsOneWidget);
      expect(find.text('Tamil Nadu'), findsOneWidget);
      expect(find.text('600001'), findsOneWidget);

      // Edit Button
      expect(find.text('Edit Information'), findsOneWidget);
    });

    testWidgets('renders error state with retry button on failure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            employeeProfileProvider.overrideWith((ref) => Future.error('Network Error')),
          ],
          child: const MaterialApp(
            home: PersonalInformationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unable to load personal information'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

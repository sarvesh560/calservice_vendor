import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/onboarding/presentation/onboarding_controller.dart';
import 'package:mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:mobile/routing/app_routes.dart';

class FakeOnboardingController extends StateNotifier<bool?> implements OnboardingController {
  FakeOnboardingController() : super(false);

  bool completeCalled = false;

  @override
  bool get autoPreviewInDebug => false;

  @override
  Future<void> completeOnboarding() async {
    completeCalled = true;
    state = true;
  }

  @override
  Future<void> resetOnboarding() async {
    state = false;
  }
}

void main() {
  Widget buildTestableOnboarding(FakeOnboardingController controller, {Size size = const Size(390, 844)}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.createAccount,
          builder: (context, state) => const Scaffold(body: Text('Create Account Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        onboardingControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQueryData(size: size),
          child: child!,
        ),
      ),
    );
  }

  group('OnboardingScreen Single-Page Premium UI Tests', () {
    testWidgets('renders premium UI elements correctly', (tester) async {
      final controller = FakeOnboardingController();
      await tester.pumpWidget(buildTestableOnboarding(controller));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.handyman_rounded), findsOneWidget);
      expect(find.text('Join the Network'), findsOneWidget);
      expect(find.text('Receive service requests, manage your jobs, and track your earnings in one place.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('tapping Get Started completes onboarding and navigates to create account', (tester) async {
      final controller = FakeOnboardingController();
      await tester.pumpWidget(buildTestableOnboarding(controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(controller.completeCalled, isTrue);
      expect(find.text('Create Account Screen'), findsOneWidget);
    });
  });

  group('OnboardingScreen Responsive Layout Tests', () {
    const testSizes = [
      Size(320, 568), // Compact / Small Android
      Size(360, 640), // Classic Android 16:9
      Size(390, 844), // Modern Standard
      Size(412, 915), // Large Android
      Size(480, 800), // Wide Android
    ];

    for (final size in testSizes) {
      testWidgets('renders cleanly at ${size.width}x${size.height} with 0 overflow', (tester) async {
        final controller = FakeOnboardingController();
        await tester.pumpWidget(buildTestableOnboarding(controller, size: size));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}

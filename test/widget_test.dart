import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app.dart';

void main() {
  testWidgets('App starts at splash screen and routes to onboarding walkthrough', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();

    // Verify initial splash state
    expect(find.text('Verifying session...'), findsOneWidget);

    // Wait for OnboardingController storage resolution
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    // On fresh launch, routes to intro onboarding walkthrough
    expect(find.text('Next'), findsOneWidget);
  });
}

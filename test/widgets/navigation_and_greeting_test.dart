import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/utils/greeting_utils.dart';

// ==================== Greeting utility unit tests ====================

void _greetingTests() {
  DateTime t(int h, [int m = 0]) => DateTime(2024, 6, 1, h, m);
  group('getGreeting() - boundary tests', () {
    test('08:00 -> Good morning,', () => expect(getGreeting(t(8)), 'Good morning,'));
    test('11:59 -> Good morning,', () => expect(getGreeting(t(11, 59)), 'Good morning,'));
    test('12:00 -> Good afternoon,', () => expect(getGreeting(t(12)), 'Good afternoon,'));
    test('16:59 -> Good afternoon,', () => expect(getGreeting(t(16, 59)), 'Good afternoon,'));
    test('17:00 -> Good evening,', () => expect(getGreeting(t(17)), 'Good evening,'));
    test('20:59 -> Good evening,', () => expect(getGreeting(t(20, 59)), 'Good evening,'));
    test('21:00 -> Good night,', () => expect(getGreeting(t(21)), 'Good night,'));
    test('23:59 -> Good night,', () => expect(getGreeting(t(23, 59)), 'Good night,'));
    test('00:00 midnight -> Good night,', () => expect(getGreeting(t(0, 0)), 'Good night,'));
    test('04:59 -> Good night,', () => expect(getGreeting(t(4, 59)), 'Good night,'));
    test('05:00 -> Good morning,', () => expect(getGreeting(t(5, 0)), 'Good morning,'));
  });
}

// ==================== iOS Back Button Tests ====================

void _backButtonTests() {
  group('iOS Back Button — canPop behavior', () {
    testWidgets(
        'back button shown on secondary screen when canPop is true',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (ctx) => TextButton(
                  onPressed: () => ctx.push('/secondary'),
                  child: const Text('Go Secondary'),
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: 'secondary',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: Builder(
                      builder: (ctx) => ctx.canPop()
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              tooltip: 'Back',
                              onPressed: () => ctx.pop(),
                            )
                          : const SizedBox.shrink(),
                    ),
                    title: const Text('Secondary Screen'),
                  ),
                  body: const Text('Secondary Content'),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      // Navigate to secondary
      await tester.tap(find.text('Go Secondary'));
      await tester.pumpAndSettle();

      // Back button visible
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Tap back button — returns to root
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Go Secondary'), findsOneWidget);
    });

    testWidgets(
        'back button NOT shown on root screen when canPop is false',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: Builder(
                  builder: (ctx) => ctx.canPop()
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          tooltip: 'Back',
                          onPressed: () => ctx.pop(),
                        )
                      : const SizedBox.shrink(),
                ),
                title: const Text('Root Screen'),
              ),
              body: const Text('Root Content'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
      expect(find.text('Root Screen'), findsOneWidget);
    });
  });

  // Responsive layout at multiple widths and text scales
  group('Back button responsive — no overflow', () {
    for (final width in [320.0, 360.0, 390.0, 412.0, 480.0]) {
      for (final scale in [1.0, 1.15, 1.3, 1.5]) {
        testWidgets('width=$width scale=$scale no overflow',
            (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());
          addTearDown(() => tester.view.resetDevicePixelRatio());

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: MaterialApp(
                home: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      tooltip: 'Back',
                      onPressed: () {},
                    ),
                    title: const Text('Test Screen Title'),
                  ),
                  body: const SizedBox.expand(),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        });
      }
    }
  });
}

void main() {
  _greetingTests();
  _backButtonTests();
}

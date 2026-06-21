import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/onboarding/onboarding_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

import '../../helpers/test_safe_theme.dart';

void main() {
  group('OnboardingScreen', () {
    bool completed = false;

    setUp(() => completed = false);

    Widget buildSubject() => MaterialApp(
      home: OnboardingScreen(onComplete: () => completed = true),
      theme: testSafeTheme(MiToosaTheme.darkTheme),
    );

    testWidgets('renders all 4 pages (BL-07 first-session expectation page)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('Welcome to miToosa'), findsOneWidget);
      expect(find.text('🧩'), findsOneWidget);

      // Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Earn Stars & XP'), findsOneWidget);

      // Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('25 Free Games Daily'), findsOneWidget);

      // Page 4 (BL-07): first-session expectation-setting
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text("Here's what happens next"), findsOneWidget);
      expect(find.text('🚀'), findsOneWidget);
    });

    testWidgets('shows back button on pages 2+', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // First page shouldn't have back
      expect(find.text('Back'), findsNothing);

      // Go to second page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Second page should have back
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows Get Started button on last page (page 4)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Navigate to last (4th) page
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Get Started calls onComplete', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Navigate to last (4th) page
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('Skip button calls onComplete', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Skip button is on the first page
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('page indicators animate', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Check initial page has 3 indicator dots
      expect(find.byType(Container), findsWidgets);

      // Navigate to next page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check that page changed (we're on page 2 now)
      expect(find.text('Earn Stars & XP'), findsOneWidget);
    });
  });
}

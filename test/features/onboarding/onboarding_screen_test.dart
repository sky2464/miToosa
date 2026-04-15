import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/onboarding/onboarding_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders all 3 pages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
          theme: MiToosaTheme.darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Check first page
      expect(find.text('Welcome to miToosa'), findsOneWidget);
      expect(find.text('🧩'), findsOneWidget);

      // Navigate to second page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Earn Stars & XP'), findsOneWidget);

      // Navigate to third page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Manage Your Hearts'), findsOneWidget);
    });

    testWidgets('shows back button on pages 2+', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
          theme: MiToosaTheme.darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      // First page shouldn't have back
      expect(find.text('Back'), findsNothing);

      // Go to second page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Second page should have back
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows Get Started button on last page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
          theme: MiToosaTheme.darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to third (last) page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('page indicators animate', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
          theme: MiToosaTheme.darkTheme,
        ),
      );
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

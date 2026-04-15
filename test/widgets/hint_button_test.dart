import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/hint_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HintButton', () {
    testWidgets('button is disabled when hint is null', (tester) async {
      await tester.pumpWidget(_wrap(HintButton(
        hint: null,
        hearts: 5,
        hintUsed: false,
        onUseHint: () => fail('should not be called'),
      )));

      final btn =
          tester.widget<IconButton>(find.byKey(const ValueKey('hint_button')));
      expect(btn.onPressed, isNull);
    });

    testWidgets('no badges when hint is null', (tester) async {
      await tester.pumpWidget(_wrap(const HintButton(
        hint: null,
        hearts: 5,
        hintUsed: false,
      )));

      expect(find.byKey(const ValueKey('hint_heart_badge')), findsNothing);
      expect(find.byKey(const ValueKey('hint_used_badge')), findsNothing);
    });

    testWidgets('button is disabled when hintUsed is true', (tester) async {
      await tester.pumpWidget(_wrap(HintButton(
        hint: 'Look at the middle shape',
        hearts: 3,
        hintUsed: true,
        onUseHint: () => fail('should not be called'),
      )));

      final btn =
          tester.widget<IconButton>(find.byKey(const ValueKey('hint_button')));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows hint_used_badge when hintUsed=true with hint',
        (tester) async {
      await tester.pumpWidget(_wrap(const HintButton(
        hint: 'Some hint',
        hearts: 3,
        hintUsed: true,
      )));

      expect(find.byKey(const ValueKey('hint_used_badge')), findsOneWidget);
      expect(find.byKey(const ValueKey('hint_heart_badge')), findsNothing);
    });

    testWidgets('shows hint_heart_badge when active and hearts > 0',
        (tester) async {
      await tester.pumpWidget(_wrap(const HintButton(
        hint: 'Pick the odd one out',
        hearts: 2,
        hintUsed: false,
      )));

      expect(find.byKey(const ValueKey('hint_heart_badge')), findsOneWidget);
      expect(find.byKey(const ValueKey('hint_used_badge')), findsNothing);
    });

    testWidgets('calls onUseHint when hearts > 0 and tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(_wrap(HintButton(
        hint: 'Use this hint',
        hearts: 1,
        hintUsed: false,
        onUseHint: () => called = true,
        onNoHearts: () => fail('should not fire'),
      )));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      expect(called, isTrue);
    });

    testWidgets('calls onNoHearts (not onUseHint) when hearts == 0',
        (tester) async {
      bool noHeartsCalled = false;
      await tester.pumpWidget(_wrap(HintButton(
        hint: 'Some hint',
        hearts: 0,
        hintUsed: false,
        onUseHint: () => fail('should not fire'),
        onNoHearts: () => noHeartsCalled = true,
      )));

      await tester.tap(find.byKey(const ValueKey('hint_button')));
      expect(noHeartsCalled, isTrue);
    });

    testWidgets('no heart badge when hearts == 0 (button still enabled)',
        (tester) async {
      await tester.pumpWidget(_wrap(const HintButton(
        hint: 'A hint',
        hearts: 0,
        hintUsed: false,
      )));

      expect(find.byKey(const ValueKey('hint_heart_badge')), findsNothing);
      // Button is enabled (not disabled) even at 0 hearts — routes to onNoHearts
      final btn =
          tester.widget<IconButton>(find.byKey(const ValueKey('hint_button')));
      expect(btn.onPressed, isNotNull);
    });
  });
}

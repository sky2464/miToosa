/// Widget tests for [CountdownTimerWidget].
///
/// Coverage for S2-03 AC-011: timer pill switches to pink tint (#EC4899)
/// when remaining time is ≤ 4 seconds, with a pulse-glow animation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/theme/design_tokens.dart';
import 'package:mitoosa/widgets/countdown_timer_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: ThemeData.dark(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('CountdownTimerWidget', () {
    testWidgets('renders the remaining seconds as text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CountdownTimerWidget(remainingSeconds: 12, totalSeconds: 15),
        ),
      );
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('text color is NOT pink when remainingSeconds > 4', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const CountdownTimerWidget(remainingSeconds: 5, totalSeconds: 15),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('5'));
      expect(
        textWidget.style?.color,
        isNot(equals(AP.pink)),
        reason: 'Above threshold should not use pink tint',
      );
    });

    testWidgets('text color IS pink when remainingSeconds == 4 (AC-011)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const CountdownTimerWidget(remainingSeconds: 4, totalSeconds: 15),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('4'));
      expect(
        textWidget.style?.color,
        equals(AP.pink),
        reason: 'AC-011: at ≤4s the timer pill uses pink tint #EC4899',
      );
    });

    testWidgets('text color IS pink when remainingSeconds == 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const CountdownTimerWidget(remainingSeconds: 0, totalSeconds: 15),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('0'));
      expect(textWidget.style?.color, equals(AP.pink));
    });

    testWidgets('totalSeconds == 0 does not crash (defensive)', (tester) async {
      await tester.pumpWidget(
        _wrap(const CountdownTimerWidget(remainingSeconds: 0, totalSeconds: 0)),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

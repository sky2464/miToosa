import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/run_timer_overlay.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RunTimerOverlay', () {
    testWidgets('hidden when totalTime is zero', (tester) async {
      await tester.pumpWidget(_wrap(const RunTimerOverlay(
        timeRemaining: Duration.zero,
        totalTime: Duration.zero,
      )));
      expect(find.byKey(const ValueKey('run_timer_bar')), findsNothing);
    });

    testWidgets('shows full bar when timeRemaining == totalTime', (tester) async {
      await tester.pumpWidget(_wrap(const RunTimerOverlay(
        timeRemaining: Duration(minutes: 10),
        totalTime: Duration(minutes: 10),
      )));
      final widget = tester.widget<LinearProgressIndicator>(
          find.byKey(const ValueKey('run_timer_bar')));
      expect(widget.value, closeTo(1.0, 0.001));
    });

    testWidgets('shows half bar when half time remains', (tester) async {
      await tester.pumpWidget(_wrap(const RunTimerOverlay(
        timeRemaining: Duration(minutes: 5),
        totalTime: Duration(minutes: 10),
      )));
      final widget = tester.widget<LinearProgressIndicator>(
          find.byKey(const ValueKey('run_timer_bar')));
      expect(widget.value, closeTo(0.5, 0.001));
    });

    testWidgets('shows empty bar when time is zero but total is not',
        (tester) async {
      await tester.pumpWidget(_wrap(const RunTimerOverlay(
        timeRemaining: Duration.zero,
        totalTime: Duration(minutes: 10),
      )));
      final widget = tester.widget<LinearProgressIndicator>(
          find.byKey(const ValueKey('run_timer_bar')));
      expect(widget.value, closeTo(0.0, 0.001));
    });
  });
}

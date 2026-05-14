import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/weekly_bars.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 320, height: 200, child: child),
      ),
    );

void main() {
  group('WeeklyBars', () {
    testWidgets('renders all 7 day labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const WeeklyBars(dailyXp: [3, 0, 8, 12, 0, 15, 2]),
      ));
      await tester.pumpAndSettle();
      // Day labels: M T W T F S S (note: two T's, two S's)
      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      // T and S each appear twice
      expect(find.text('T'), findsNWidgets(2));
      expect(find.text('S'), findsNWidgets(2));
    });

    testWidgets('asserts exactly 7 values', (tester) async {
      await tester.pumpWidget(_wrap(
        const WeeklyBars(dailyXp: [1, 2, 3]),
      ));
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('custom todayIndex highlights different column', (tester) async {
      await tester.pumpWidget(_wrap(
        const WeeklyBars(
          dailyXp: [5, 5, 5, 5, 5, 5, 5],
          todayIndex: 2,
        ),
      ));
      await tester.pumpAndSettle();
      // No exception means the alternate index renders cleanly.
      expect(find.byType(WeeklyBars), findsOneWidget);
    });
  });
}

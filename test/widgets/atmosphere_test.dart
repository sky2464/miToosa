import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/atmosphere.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 400, height: 600, child: child)),
);

void main() {
  group('Atmosphere', () {
    testWidgets('blue accent renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere(accent: 'blue')));
      await tester.pump();
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('cyan accent renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere(accent: 'cyan')));
      await tester.pump();
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('pink accent renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere(accent: 'pink')));
      await tester.pump();
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('wraps content in RepaintBoundary', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere()));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(Atmosphere),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('is IgnorePointer (does not intercept taps)', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere()));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(Atmosphere),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
    });
  });
}

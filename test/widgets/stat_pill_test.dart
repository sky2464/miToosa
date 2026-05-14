import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/theme/design_tokens.dart';
import 'package:mitoosa/widgets/stat_pill.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('StatPill', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(const StatPill(label: '25/25 energy')));
      expect(find.text('25/25 energy'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(const StatPill(
        icon: Icon(Icons.bolt),
        label: 'test',
      )));
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('orange tint uses AP.orange', (tester) async {
      await tester.pumpWidget(_wrap(const StatPill(
        label: 'streak',
        tint: StatPillTint.orange,
      )));
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(StatPill),
        matching: find.byType(Container),
      ).first);
      final deco = container.decoration as BoxDecoration;
      expect(
        (deco.color!.r * 255).round(),
        equals((AP.orange.r * 255).round()),
      );
    });

    testWidgets('glow adds outer shadow', (tester) async {
      await tester.pumpWidget(_wrap(const StatPill(
        label: 'test',
        tint: StatPillTint.amber,
        glow: true,
      )));
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(StatPill),
        matching: find.byType(Container),
      ).first);
      final deco = container.decoration as BoxDecoration;
      expect(deco.boxShadow, isNotNull);
      expect(deco.boxShadow, isNotEmpty);
    });
  });
}

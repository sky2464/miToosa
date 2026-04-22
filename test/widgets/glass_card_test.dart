import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/glass_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

/// Returns the BoxDecoration from the innermost Container in GlassCard.
BoxDecoration _innerDecoration(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    final deco = c.decoration;
    if (deco is BoxDecoration && deco.color == AethericPulseDark.glassFill) {
      return deco;
    }
  }
  throw StateError('Could not find GlassCard inner Container');
}

void main() {
  group('GlassCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const GlassCard(child: Text('hello')),
      ));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('default shadow uses cardOuter + cardInner (2 entries)', (tester) async {
      await tester.pumpWidget(_wrap(
        const GlassCard(child: SizedBox.shrink()),
      ));
      final deco = _innerDecoration(tester);
      final expected = [
        ...AethericPulseDark.cardOuter,
        ...AethericPulseDark.cardInner,
      ];
      expect(deco.boxShadow, equals(expected));
    });

    testWidgets('neonGlow: true uses blueGlow shadow list', (tester) async {
      await tester.pumpWidget(_wrap(
        const GlassCard(neonGlow: true, child: SizedBox.shrink()),
      ));
      final deco = _innerDecoration(tester);
      expect(deco.boxShadow, equals(AethericPulseDark.blueGlow));
    });

    testWidgets('neonGlow and default shadows are different', (tester) async {
      final defaultShadows = [
        ...AethericPulseDark.cardOuter,
        ...AethericPulseDark.cardInner,
      ];
      expect(AethericPulseDark.blueGlow, isNot(equals(defaultShadows)));
    });

    testWidgets('custom borderRadius is applied', (tester) async {
      await tester.pumpWidget(_wrap(
        const GlassCard(borderRadius: 8, child: SizedBox.shrink()),
      ));
      final deco = _innerDecoration(tester);
      expect(deco.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('custom boxShadow overrides both default and neonGlow', (tester) async {
      const custom = [BoxShadow(color: Colors.red, blurRadius: 5)];
      await tester.pumpWidget(_wrap(
        const GlassCard(
          boxShadow: custom,
          neonGlow: true,
          child: SizedBox.shrink(),
        ),
      ));
      final deco = _innerDecoration(tester);
      expect(deco.boxShadow, equals(custom));
    });
  });
}

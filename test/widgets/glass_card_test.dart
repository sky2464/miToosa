import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/glass_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Returns the BoxDecoration from the GlassCard fill Container.
BoxDecoration _innerDecoration(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    final deco = c.decoration;
    if (deco is BoxDecoration &&
        deco.color != null &&
        deco.border != null &&
        deco.border!.top.width == 1) {
      return deco;
    }
  }
  throw StateError('Could not find GlassCard inner Container');
}

void main() {
  group('GlassCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(const GlassCard(child: Text('hello'))));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('default shadow uses cardOuter + cardInner in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AethericPulseDark.themeData,
          home: const Scaffold(body: GlassCard(child: SizedBox.shrink())),
        ),
      );
      final deco = _innerDecoration(tester);
      final expected = [
        ...AethericPulseDark.cardOuter,
        ...AethericPulseDark.cardInner,
      ];
      expect(deco.boxShadow, equals(expected));
    });

    testWidgets('default shadow uses light soft blue shadow in light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AethericPulseLight.lightTheme,
          home: const Scaffold(body: GlassCard(child: SizedBox.shrink())),
        ),
      );
      final deco = _innerDecoration(tester);
      expect(deco.boxShadow, equals(AethericPulseLight.shadowSoftBlue));
    });

    testWidgets('neonGlow: true uses blueGlow shadow list', (tester) async {
      await tester.pumpWidget(
        _wrap(const GlassCard(neonGlow: true, child: SizedBox.shrink())),
      );
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
      await tester.pumpWidget(
        _wrap(const GlassCard(borderRadius: 8, child: SizedBox.shrink())),
      );
      final deco = _innerDecoration(tester);
      expect(deco.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('custom boxShadow overrides both default and neonGlow', (
      tester,
    ) async {
      const custom = [BoxShadow(color: Colors.red, blurRadius: 5)];
      await tester.pumpWidget(
        _wrap(
          const GlassCard(
            boxShadow: custom,
            neonGlow: true,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final deco = _innerDecoration(tester);
      expect(deco.boxShadow, equals(custom));
    });

    testWidgets('uses light glass fill in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AethericPulseLight.lightTheme,
          home: const Scaffold(body: GlassCard(child: SizedBox.shrink())),
        ),
      );
      final deco = _innerDecoration(tester);
      expect(deco.color, equals(AethericPulseLight.glassFillLight));
      expect(
        deco.border?.top.color,
        equals(AethericPulseLight.glassBorderDimLight),
      );
    });

    testWidgets('uses dark glass fill in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AethericPulseDark.themeData,
          home: const Scaffold(body: GlassCard(child: SizedBox.shrink())),
        ),
      );
      final deco = _innerDecoration(tester);
      expect(deco.color, equals(AethericPulseDark.glassFill));
    });
  });
}

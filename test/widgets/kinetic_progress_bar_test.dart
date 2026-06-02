import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/kinetic_progress_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 300, child: child)),
);

/// Returns the fill Container inside the Stack, if present.
/// The fill Container is the one that has a [gradient] decoration.
Container? _findFillContainer(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    final deco = c.decoration;
    if (deco is BoxDecoration && deco.gradient != null) {
      return c;
    }
  }
  return null;
}

void main() {
  group('KineticProgressBar', () {
    testWidgets('value=0.0 → fill container is absent (Stack is empty)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 0.0)));
      expect(_findFillContainer(tester), isNull);
    });

    testWidgets('value=1.0 → fill container is present', (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 1.0)));
      expect(_findFillContainer(tester), isNotNull);
    });

    testWidgets('value=1.5 → clamped, no crash, fill is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 1.5)));
      expect(tester.takeException(), isNull);
      expect(_findFillContainer(tester), isNotNull);
    });

    testWidgets('value=-0.5 → clamped, no crash, fill is absent', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: -0.5)));
      expect(tester.takeException(), isNull);
      expect(_findFillContainer(tester), isNull);
    });

    testWidgets('custom height is respected', (tester) async {
      const customHeight = 10.0;
      await tester.pumpWidget(
        _wrap(const KineticProgressBar(value: 0.5, height: customHeight)),
      );

      // The outer track Container has height set directly via the height: param.
      // Find it by its glassFill background color (no gradient).
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool found = false;
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration &&
            deco.gradient == null &&
            deco.color != null) {
          // Verify the rendered size
          final renderBox = tester.renderObject<RenderBox>(find.byWidget(c));
          expect(renderBox.size.height, closeTo(customHeight, 0.1));
          found = true;
          break;
        }
      }
      expect(found, isTrue, reason: 'track container not found');
    });

    testWidgets('default height is 4.0', (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 0.5)));

      final containers = tester.widgetList<Container>(find.byType(Container));
      bool found = false;
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration &&
            deco.gradient == null &&
            deco.color != null) {
          final renderBox = tester.renderObject<RenderBox>(find.byWidget(c));
          expect(renderBox.size.height, closeTo(4.0, 0.1));
          found = true;
          break;
        }
      }
      expect(found, isTrue, reason: 'track container not found');
    });

    testWidgets('accepts custom gradient', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.red, Colors.orange],
      );
      await tester.pumpWidget(
        _wrap(const KineticProgressBar(value: 0.8, gradient: customGradient)),
      );

      final fill = _findFillContainer(tester);
      expect(fill, isNotNull);
      final deco = fill!.decoration as BoxDecoration;
      expect(deco.gradient, equals(customGradient));
    });
  });
}

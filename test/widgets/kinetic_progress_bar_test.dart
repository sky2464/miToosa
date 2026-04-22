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
    testWidgets('value=0.0 → fill container is absent (Stack is empty)',
        (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 0.0)));
      expect(_findFillContainer(tester), isNull);
    });

    testWidgets('value=1.0 → fill container is present', (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 1.0)));
      expect(_findFillContainer(tester), isNotNull);
    });

    testWidgets('value=1.5 → clamped, no crash, fill is present',
        (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 1.5)));
      expect(tester.takeException(), isNull);
      expect(_findFillContainer(tester), isNotNull);
    });

    testWidgets('value=-0.5 → clamped, no crash, fill is absent',
        (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: -0.5)));
      expect(tester.takeException(), isNull);
      expect(_findFillContainer(tester), isNull);
    });

    testWidgets('custom height is respected', (tester) async {
      const customHeight = 10.0;
      await tester.pumpWidget(
        _wrap(const KineticProgressBar(value: 0.5, height: customHeight)),
      );

      // The outer track container should have height == customHeight.
      // It is the Container directly inside the LayoutBuilder whose decoration
      // has glassFill color (no gradient).
      final containers = tester.widgetList<Container>(find.byType(Container));
      final trackContainer = containers.firstWhere((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration && deco.gradient == null) {
          // Must have a non-null height set via constraints
          return true;
        }
        return false;
      });

      // Container height is encoded in its constraints
      expect(trackContainer.constraints?.maxHeight, equals(customHeight));
    });

    testWidgets('default height is 4.0', (tester) async {
      await tester.pumpWidget(_wrap(const KineticProgressBar(value: 0.5)));

      final containers = tester.widgetList<Container>(find.byType(Container));
      final trackContainer = containers.firstWhere((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient == null;
      });

      expect(trackContainer.constraints?.maxHeight, equals(4.0));
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

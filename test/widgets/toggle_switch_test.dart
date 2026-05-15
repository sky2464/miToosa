import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/toggle_switch.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ToggleSwitch', () {
    testWidgets('off state renders without gradient', (tester) async {
      await tester.pumpWidget(_wrap(
        ToggleSwitch(value: false, onChanged: (_) {}),
      ));
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ToggleSwitch),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final deco = container.decoration as BoxDecoration;
      expect(deco.gradient, isNull);
    });

    testWidgets('on state uses gradient', (tester) async {
      await tester.pumpWidget(_wrap(
        ToggleSwitch(value: true, onChanged: (_) {}),
      ));
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ToggleSwitch),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final deco = container.decoration as BoxDecoration;
      expect(deco.gradient, isNotNull);
    });

    testWidgets('tap fires onChanged with inverted value', (tester) async {
      bool? received;
      await tester.pumpWidget(_wrap(
        ToggleSwitch(value: false, onChanged: (v) => received = v),
      ));
      await tester.tap(find.byType(ToggleSwitch));
      expect(received, isTrue);
    });

    testWidgets('tap-target is at least 44×44 pt (WCAG 2.5.5)', (tester) async {
      await tester.pumpWidget(_wrap(
        ToggleSwitch(value: false, onChanged: (_) {}),
      ));
      final size = tester.getSize(find.byType(ToggleSwitch));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });
  });
}

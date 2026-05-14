import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/primary_button.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('PrimaryButton', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        const PrimaryButton(child: Text('Start session')),
      ));
      expect(find.text('Start session'), findsOneWidget);
    });

    testWidgets('fires onPressed callback', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          onPressed: () => pressed = true,
          child: const Text('Play'),
        ),
      ));
      await tester.tap(find.byType(PrimaryButton));
      expect(pressed, isTrue);
    });

    testWidgets('disabled (no onPressed) renders at reduced opacity',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PrimaryButton(child: Text('Play')),
      ));
      final opacity = tester.widget<Opacity>(find.descendant(
        of: find.byType(PrimaryButton),
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('fullWidth expands to parent width', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 320,
          child: PrimaryButton(fullWidth: true, child: Text('Play')),
        ),
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints?.maxWidth ?? double.infinity, double.infinity);
    });
  });
}

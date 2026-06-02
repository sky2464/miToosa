import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/ghost_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('GhostButton', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(const GhostButton(child: Text('Cancel'))));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('fires onPressed callback', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          GhostButton(
            onPressed: () => pressed = true,
            child: const Text('Cancel'),
          ),
        ),
      );
      await tester.tap(find.byType(GhostButton));
      expect(pressed, isTrue);
    });

    testWidgets('null onPressed does not throw on tap', (tester) async {
      await tester.pumpWidget(_wrap(const GhostButton(child: Text('Cancel'))));
      await tester.tap(find.byType(GhostButton));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap-target is at least 44×44 pt (WCAG 2.5.5)', (tester) async {
      await tester.pumpWidget(_wrap(const GhostButton(child: Text('Cancel'))));
      final size = tester.getSize(find.byType(GhostButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/kinetic_chip.dart';
import 'package:mitoosa/theme/design_system.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 300, child: child)),
    );

void main() {
  group('KineticChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(const KineticChip(label: 'Hello')));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows leading widget when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const KineticChip(
          label: 'Chip',
          leading: Icon(Icons.star, key: ValueKey('leading_icon')),
        ),
      ));
      expect(find.byKey(const ValueKey('leading_icon')), findsOneWidget);
      // Spacer SizedBox is present when leading is provided
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacers = sizedBoxes.where((b) => b.width == 4.0).toList();
      expect(spacers, isNotEmpty);
    });

    testWidgets('no spacer SizedBox when leading is null', (tester) async {
      await tester.pumpWidget(_wrap(const KineticChip(label: 'NoLeading')));
      // The only SizedBox present should be the outer 300-wide wrapper, not the 4px spacer
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacers = sizedBoxes.where((b) => b.width == 4.0).toList();
      expect(spacers, isEmpty);
    });

    testWidgets('accepts custom color', (tester) async {
      const customColor = Colors.teal;
      await tester.pumpWidget(_wrap(
        const KineticChip(label: 'Colored', color: customColor),
      ));

      // The Container holding the chip decoration should use customColor-derived fill
      final containers = tester.widgetList<Container>(find.byType(Container));
      final chipContainer = containers.firstWhere((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          return deco.color != null &&
              deco.color != Colors.transparent &&
              deco.border != null;
        }
        return false;
      });

      final deco = chipContainer.decoration as BoxDecoration;
      final expectedFill = customColor.withValues(alpha: 0.20);
      expect(deco.color, equals(expectedFill));
    });

    testWidgets('uses brandPurple when no color provided', (tester) async {
      await tester.pumpWidget(_wrap(const KineticChip(label: 'Default')));

      final containers = tester.widgetList<Container>(find.byType(Container));
      final chipContainer = containers.firstWhere((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          return deco.color != null &&
              deco.color != Colors.transparent &&
              deco.border != null;
        }
        return false;
      });

      final deco = chipContainer.decoration as BoxDecoration;
      final expectedFill =
          AethericPulseDark.brandPurple.withValues(alpha: 0.20);
      expect(deco.color, equals(expectedFill));
    });
  });
}

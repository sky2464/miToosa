import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/hearts_bar.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HeartsBar', () {
    testWidgets('shows 5 filled hearts at full', (tester) async {
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 5, diamonds: 0)));
      expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    });

    testWidgets('shows 2 filled + 3 empty hearts', (tester) async {
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 2, diamonds: 0)));
      expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.favorite_border_rounded), findsNWidgets(3));
    });

    testWidgets('shows diamond count', (tester) async {
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 5, diamonds: 3)));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('refuel button hidden when hearts == 5', (tester) async {
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 5, diamonds: 2)));
      expect(find.byKey(const ValueKey('refuel_diamond_btn')), findsNothing);
    });

    testWidgets('refuel button hidden when diamonds == 0', (tester) async {
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 2, diamonds: 0)));
      expect(find.byKey(const ValueKey('refuel_diamond_btn')), findsNothing);
    });

    testWidgets('refuel button visible when hearts < 5 AND diamonds >= 1', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 3, diamonds: 1)));
      expect(find.byKey(const ValueKey('refuel_diamond_btn')), findsOneWidget);
    });

    testWidgets('onRefuelWithDiamond callback fires on tap', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _wrap(
          HeartsBar(
            hearts: 3,
            diamonds: 1,
            onRefuelWithDiamond: () => called = true,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('refuel_diamond_btn')));
      expect(called, true);
    });

    testWidgets('renders without overflow at 320px width', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(const HeartsBar(hearts: 3, diamonds: 2)));
      expect(tester.takeException(), isNull);
    });
  });
}

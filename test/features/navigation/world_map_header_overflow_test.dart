import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/hearts_bar.dart';
import 'package:mitoosa/theme/design_system.dart';

/// Reproduces the RenderFlex overflow reported in the header Row:
///   Row → [ title, Spacer, HeartsBar + XP badge ]
/// at 392 px wide with hearts < 5 (both refuel + share buttons visible).
Widget _headerRow({required double width, required int hearts, required int diamonds, required int xp}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: width,
        child: Row(
          children: [
            Text(
              'mi',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Text(
              'Toosa',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeartsBar(
                      hearts: hearts,
                      diamonds: diamonds,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 18, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('$xp XP'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('WorldMapScreen header Row overflow', () {
    testWidgets('no overflow at 392px with hearts=3, diamonds=2 (both refuel+share visible)',
        (tester) async {
      tester.view.physicalSize = const Size(392, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _headerRow(width: 392, hearts: 3, diamonds: 2, xp: 120),
      );

      // If there is a RenderFlex overflow the framework throws an assertion error.
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 320px with hearts=0, diamonds=0 (minimal content)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _headerRow(width: 320, hearts: 0, diamonds: 0, xp: 0),
      );

      expect(tester.takeException(), isNull);
    });
  });
}

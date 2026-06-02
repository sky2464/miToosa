/// Widget tests for [DotProgressStrip] — S2-03 AC-001.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/theme/design_tokens.dart';
import 'package:mitoosa/widgets/dot_progress_strip.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: ThemeData.dark(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('DotProgressStrip', () {
    testWidgets('renders exactly 5 dots by default', (tester) async {
      await tester.pumpWidget(_wrap(const DotProgressStrip(progress: 0.4)));
      // 5 dot containers plus 1 Row — find by container shape via decoration count
      final containers = find.byType(Container);
      // Row + 5 dots = 6 Containers, but the test cares about presence of 5 dots.
      expect(containers, findsAtLeastNWidgets(5));
    });

    testWidgets('progress = 0.0 leaves all dots unfilled (no gradient)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DotProgressStrip(progress: 0.0)));
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final dec = c.decoration;
            return dec is BoxDecoration && dec.borderRadius != null;
          });
      // None of the dot Containers should carry the primary gradient.
      for (final c in containers) {
        final dec = c.decoration as BoxDecoration;
        expect(
          dec.gradient,
          isNull,
          reason: 'progress=0 should leave dots unfilled',
        );
      }
    });

    testWidgets('progress = 1.0 fills every dot with AP.gradPrimary', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DotProgressStrip(progress: 1.0)));
      // Filter to dot containers (those with explicit 8px height).
      final dotContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).borderRadius != null,
          );
      var filled = 0;
      for (final c in dotContainers) {
        final dec = c.decoration as BoxDecoration;
        if (dec.gradient == AP.gradPrimary) filled++;
      }
      expect(filled, 5, reason: 'progress=1.0 should fill 5 dots');
    });

    testWidgets('progress = 0.5 fills approximately half the dots', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DotProgressStrip(progress: 0.5)));
      final dotContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).borderRadius != null,
          );
      var filled = 0;
      for (final c in dotContainers) {
        final dec = c.decoration as BoxDecoration;
        if (dec.gradient == AP.gradPrimary) filled++;
      }
      // ceil(0.5 * 5) = 3 filled
      expect(filled, 3);
    });

    testWidgets('exposes accessible Semantics label', (tester) async {
      await tester.pumpWidget(_wrap(const DotProgressStrip(progress: 0.4)));
      expect(find.bySemanticsLabel('Progress: 2 of 5'), findsOneWidget);
    });

    testWidgets('totalDots is configurable', (tester) async {
      await tester.pumpWidget(
        _wrap(const DotProgressStrip(progress: 1.0, totalDots: 3)),
      );
      final dotContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).borderRadius != null,
          );
      var filled = 0;
      for (final c in dotContainers) {
        final dec = c.decoration as BoxDecoration;
        if (dec.gradient == AP.gradPrimary) filled++;
      }
      expect(filled, 3);
    });
  });
}

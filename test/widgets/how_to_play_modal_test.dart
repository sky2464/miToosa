import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/widgets/how_to_play_modal.dart';

TrackDefinition _track() => TrackDefinition(
  id: 'track_test',
  name: 'Logic Gates',
  subtitle: 'Pick the shape that completes the rule.',
  rule: PuzzleRule.matchIdentical,
  icon: '🧠',
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HowToPlayModal', () {
    testWidgets('renders world name', (tester) async {
      await tester.pumpWidget(
        _wrap(HowToPlayModal(track: _track(), onStart: () {})),
      );
      expect(find.text('Logic Gates'), findsOneWidget);
    });

    testWidgets('renders world icon', (tester) async {
      await tester.pumpWidget(
        _wrap(HowToPlayModal(track: _track(), onStart: () {})),
      );
      expect(find.text('🧠'), findsOneWidget);
    });

    testWidgets('renders subtitle/rule description', (tester) async {
      await tester.pumpWidget(
        _wrap(HowToPlayModal(track: _track(), onStart: () {})),
      );
      expect(
        find.text('Pick the shape that completes the rule.'),
        findsOneWidget,
      );
    });

    testWidgets('CTA button fires onStart callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _wrap(HowToPlayModal(track: _track(), onStart: () => called = true)),
      );
      await tester.tap(find.byKey(const ValueKey('how_to_play_cta')));
      expect(called, true);
    });
  });
}

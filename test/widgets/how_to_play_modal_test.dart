import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/core/tutorial/tutorial_definition.dart';
import 'package:mitoosa/widgets/how_to_play_modal.dart';

import '../helpers/test_safe_theme.dart';

TutorialDefinition _tutorial() => TutorialDefinition(
  trackId: 'track_test',
  rule: PuzzleRule.matchIdentical,
  goal: 'Pick the shape that completes the rule.',
  steps: const ['Read the goal', 'Tap the correct answer'],
  demoType: TutorialDemoType.shapeMatch,
  correctAction: 'correct',
  objectiveTemplate: 'Match shapes',
  demoPrompt: 'Practice',
  demoOptions: const [
    TutorialDemoOption(id: 'correct', label: 'Correct answer'),
  ],
);

TrackDefinition _track() => TrackDefinition(
  id: 'track_test',
  name: 'Logic Gates',
  subtitle: 'Pick the shape that completes the rule.',
  rule: PuzzleRule.matchIdentical,
  icon: '🧠',
  iconAsset: 'assets/images/icons/track_memory.png',
);

Widget _wrap(Widget child) => MaterialApp(
  theme: testSafeMaterialTheme,
  home: Scaffold(body: child),
);

void main() {
  group('HowToPlayModal', () {
    testWidgets('renders world name', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HowToPlayModal(
            track: _track(),
            tutorial: _tutorial(),
            onStart: () {},
            helpMode: true,
          ),
        ),
      );
      expect(find.text('Logic Gates'), findsOneWidget);
    });

    testWidgets('renders world icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HowToPlayModal(
            track: _track(),
            tutorial: _tutorial(),
            onStart: () {},
            helpMode: true,
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders subtitle/rule description', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HowToPlayModal(
            track: _track(),
            tutorial: _tutorial(),
            onStart: () {},
            helpMode: true,
          ),
        ),
      );
      expect(find.textContaining('completes the rule'), findsOneWidget);
    });

    testWidgets('CTA button fires onStart callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _wrap(
          HowToPlayModal(
            track: _track(),
            tutorial: _tutorial(),
            onStart: () => called = true,
            helpMode: true,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('how_to_play_cta')));
      expect(called, true);
    });
  });
}

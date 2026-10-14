import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/core/tutorial/tutorial_definition.dart';
import 'package:mitoosa/widgets/tutorial/tutorial_demo_panel.dart';

import '../../helpers/test_safe_theme.dart';

TutorialDefinition _def() => TutorialDefinition(
  trackId: 'track_1',
  rule: PuzzleRule.matchIdentical,
  goal: 'Match the pattern',
  steps: const ['Step one'],
  demoType: TutorialDemoType.shapeMatch,
  correctAction: 'correct',
  objectiveTemplate: 'Match',
  demoPrompt: 'Practice',
  demoOptions: const [
    TutorialDemoOption(id: 'wrong_a', label: 'Wrong'),
    TutorialDemoOption(id: 'correct', label: 'Right'),
  ],
);

void main() {
  testWidgets('correct tap reports success callback', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: testSafeMaterialTheme,
        home: Scaffold(
          body: TutorialDemoPanel(
            definition: _def(),
            onPracticeComplete: (ok) => result = ok,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Right'));
    await tester.pump();
    expect(result, isTrue);
    expect(find.textContaining('Nice'), findsOneWidget);
  });

  testWidgets('fits 320pt width without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        theme: testSafeMaterialTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TutorialDemoPanel(definition: _def()),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

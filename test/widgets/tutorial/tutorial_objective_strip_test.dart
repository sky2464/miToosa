import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/tutorial/tutorial_objective_strip.dart';

import '../../helpers/test_safe_theme.dart';

void main() {
  testWidgets('renders objective and live prompt together', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: testSafeMaterialTheme,
        home: const Scaffold(
          body: TutorialObjectiveStrip(
            objective: 'Tap the matching shape.',
            livePrompt: 'Which shape matches?',
          ),
        ),
      ),
    );
    expect(find.text('Tap the matching shape.'), findsOneWidget);
    expect(find.text('Which shape matches?'), findsOneWidget);
  });
}

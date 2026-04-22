import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/feedback_toast.dart';

void main() {
  testWidgets('FeedbackToast renders headline and amount', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AethericPulseDark.themeData,
        home: const Scaffold(
          body: FeedbackToast(
            headline: 'IQ +1!',
            amount: '+10 XP',
          ),
        ),
      ),
    );
    // Drive in the spring animation.
    await tester.pump(const Duration(milliseconds: 280));

    expect(find.text('IQ +1!'), findsOneWidget);
    expect(find.text('+10 XP'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);

    // Let the internal auto-dismiss timer fire and the exit animation finish
    // so the test binding reports no pending timers.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 260));
  });

  testWidgets('FeedbackToast auto-dismisses after hold window', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AethericPulseDark.themeData,
        home: Scaffold(
          body: FeedbackToast(
            headline: 'Got it',
            amount: '+2 XP',
            onDismissed: () => dismissed = true,
          ),
        ),
      ),
    );
    // In-animation (280 ms) + hold (900 ms) + out-animation (220 ms).
    await tester.pump(const Duration(milliseconds: 280));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 260));

    expect(dismissed, isTrue);
  });
}

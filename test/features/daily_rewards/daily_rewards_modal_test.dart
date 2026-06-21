import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/daily_rewards/daily_rewards_modal.dart';

import '../../helpers/test_safe_theme.dart';

Widget _wrap({required int currentDay, required VoidCallback onClaim}) =>
    MaterialApp(
      theme: testSafeMaterialTheme,
      home: Scaffold(
        body: DailyRewardsModal(currentDay: currentDay, onClaim: onClaim),
      ),
    );

void main() {
  group('DailyRewardsModal', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(currentDay: 1, onClaim: () {}));
      expect(find.text('Daily Rewards'), findsOneWidget);
    });

    testWidgets('shows all 7 day tiles', (tester) async {
      await tester.pumpWidget(_wrap(currentDay: 3, onClaim: () {}));
      for (var d = 1; d <= 7; d++) {
        expect(find.text('Day $d'), findsOneWidget);
      }
    });

    testWidgets('highlights current day', (tester) async {
      await tester.pumpWidget(_wrap(currentDay: 3, onClaim: () {}));
      // The current day tile should have a special visual; check for key
      expect(find.byKey(const ValueKey('daily_reward_day_3')), findsOneWidget);
    });

    testWidgets('claim button fires onClaim', (tester) async {
      bool claimed = false;
      await tester.pumpWidget(
        _wrap(currentDay: 1, onClaim: () => claimed = true),
      );
      final claimBtn = find.byKey(const ValueKey('daily_reward_claim'));
      expect(claimBtn, findsOneWidget);
      await tester.tap(claimBtn);
      expect(claimed, isTrue);
    });

    testWidgets('day 7 shows bonus label', (tester) async {
      await tester.pumpWidget(_wrap(currentDay: 7, onClaim: () {}));
      expect(find.text('BONUS'), findsOneWidget);
    });

    testWidgets('shows coin amounts', (tester) async {
      await tester.pumpWidget(_wrap(currentDay: 1, onClaim: () {}));
      // Day 1 reward is 10 coins
      expect(find.textContaining('10'), findsWidgets);
    });
  });
}

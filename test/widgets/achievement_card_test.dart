import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/achievement_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('AchievementCard', () {
    testWidgets('unlocked: shows name + UNLOCKED label', (tester) async {
      await tester.pumpWidget(_wrap(
        const AchievementCard(
          a: AchievementData(
            id: 'novice_mind',
            name: 'Novice mind',
            subtitle: 'Complete your first puzzle',
            unlocked: true,
          ),
        ),
      ));
      expect(find.text('Novice mind'), findsOneWidget);
      expect(find.text('UNLOCKED'), findsOneWidget);
    });

    testWidgets('locked: shows progress fraction', (tester) async {
      await tester.pumpWidget(_wrap(
        const AchievementCard(
          a: AchievementData(
            id: 'focus_master',
            name: 'Focus master',
            subtitle: '15 perfect runs',
            unlocked: false,
            progress: 5,
            total: 15,
          ),
        ),
      ));
      expect(find.text('Focus master'), findsOneWidget);
      expect(find.text('5/15'), findsOneWidget);
      expect(find.text('UNLOCKED'), findsNothing);
    });

    testWidgets('locked: shows lock icon overlay', (tester) async {
      await tester.pumpWidget(_wrap(
        const AchievementCard(
          a: AchievementData(
            id: 'logic_legend',
            name: 'Logic legend',
            subtitle: '30 logic puzzles',
            unlocked: false,
            progress: 0,
            total: 30,
          ),
        ),
      ));
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}

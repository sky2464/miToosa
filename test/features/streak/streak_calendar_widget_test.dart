import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/streak/streak_calendar_widget.dart';

Widget _wrap({
  required int streakCount,
  required int bestStreak,
  required List<DateTime> playHistory,
  int streakFreezeCount = 0,
}) => MaterialApp(
  home: Scaffold(
    body: StreakCalendarWidget(
      streakCount: streakCount,
      bestStreak: bestStreak,
      playHistory: playHistory,
      streakFreezeCount: streakFreezeCount,
    ),
  ),
);

void main() {
  group('StreakCalendarWidget', () {
    testWidgets('shows current streak count', (tester) async {
      await tester.pumpWidget(
        _wrap(streakCount: 5, bestStreak: 10, playHistory: []),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows best streak', (tester) async {
      await tester.pumpWidget(
        _wrap(streakCount: 5, bestStreak: 10, playHistory: []),
      );
      expect(find.textContaining('Best: 10'), findsOneWidget);
    });

    testWidgets('shows streak freeze count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          streakCount: 5,
          bestStreak: 10,
          playHistory: [],
          streakFreezeCount: 2,
        ),
      );
      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('shows fire emoji for active streak', (tester) async {
      await tester.pumpWidget(
        _wrap(streakCount: 3, bestStreak: 3, playHistory: []),
      );
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('shows "day streak" label', (tester) async {
      await tester.pumpWidget(
        _wrap(streakCount: 1, bestStreak: 1, playHistory: []),
      );
      expect(find.text('day streak'), findsOneWidget);
    });

    testWidgets('renders with empty play history', (tester) async {
      await tester.pumpWidget(
        _wrap(streakCount: 0, bestStreak: 0, playHistory: []),
      );
      expect(find.text('0'), findsOneWidget);
    });
  });
}

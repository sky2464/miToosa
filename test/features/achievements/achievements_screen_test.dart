import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/achievements/achievements_screen.dart';

PlayerProgress _freshProgress() => PlayerProgress(playerId: 'test');

Widget _wrap({PlayerProgress? progress}) {
  final p = progress ?? _freshProgress();
  return ProviderScope(
    overrides: [playerProgressProvider.overrideWith((_) => Future.value(p))],
    child: const MaterialApp(home: AchievementsScreen()),
  );
}

void main() {
  group('AchievementsScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('displays all catalog achievements', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      // First Steps is always in catalog
      expect(find.text('First Steps'), findsOneWidget);
    });

    testWidgets('shows progress indicator for unearned achievement', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      // At least one LinearProgressIndicator should exist
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('unlocked achievement shows check icon', (tester) async {
      final p = _freshProgress();
      p.unlockedAchievements = ['first_steps'];
      await tester.pumpWidget(_wrap(progress: p));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsAtLeast(1));
    });

    testWidgets('shows coin reward for each achievement', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      // "10" coins for First Steps
      expect(find.textContaining('10'), findsWidgets);
    });
  });
}

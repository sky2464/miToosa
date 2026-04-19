import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/settings/settings_screen.dart';

PlayerProgress _freshProgress() => PlayerProgress(playerId: 'test');

Widget _wrap({PlayerProgress? progress}) {
  final p = progress ?? _freshProgress();
  return ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith((_) => Future.value(p)),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows mastery tier card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Your Progress'), findsOneWidget);
    });

    testWidgets('shows adaptive difficulty toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Adaptive Difficulty'), findsOneWidget);
    });

    testWidgets('shows haptics toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Haptics'), findsOneWidget);
    });

    testWidgets('shows music toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Music'), findsOneWidget);
    });

    testWidgets('shows sound effects toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Sound Effects'), findsOneWidget);
    });

    testWidgets('shows Audio section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Audio & Feedback'), findsOneWidget);
    });

    testWidgets('mastery tier shows Bronze for fresh player', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.textContaining('Bronze'), findsOneWidget);
    });
  });
}

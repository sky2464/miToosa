/// Widget tests for [WorldMapScreen] (Tracks tab) — Daily Spark hero,
/// filter chips, and featured/grid track tiles against mocked provider data.
///
/// Test IDs: T-003, T-004, T-005 (AC-001, AC-002, AC-003)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/navigation/world_map_screen.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/progress_ring.dart';

PlayerProgress _freshProgress({int freeGamesRemaining = 25}) {
  final p = PlayerProgress.fresh(playerId: 'test-player');
  p.freeGamesRemaining = freeGamesRemaining;
  p.streakCount = 3;
  p.totalXP = 150;
  return p;
}

Widget _wrap(PlayerProgress progress) => ProviderScope(
  overrides: [playerProgressProvider.overrideWith((ref) async => progress)],
  child: MaterialApp(
    theme: AethericPulseDark.themeData,
    home: const Scaffold(body: WorldMapScreen()),
  ),
);

void main() {
  group('WorldMapScreen — Daily Spark hero (AC-001, T-003)', () {
    testWidgets('renders "Today\'s session" headline', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();
      expect(find.text("Today's session"), findsOneWidget);
    });

    testWidgets('renders ProgressRing in Daily Spark hero', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();
      // ProgressRing shows N/5 games label
      expect(find.byType(ProgressRing), findsWidgets);
      expect(find.text('0/5'), findsOneWidget);
    });

    testWidgets('hero shows correct games count when 2 games played', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      // 23 remaining means 2 games played (25 - 23 = 2, capped at 5)
      await tester.pumpWidget(_wrap(_freshProgress(freeGamesRemaining: 23)));
      await tester.pump();
      expect(find.text('2/5'), findsOneWidget);
    });
  });

  group('WorldMapScreen — filter chips (AC-002, T-004)', () {
    testWidgets('renders all five filter chip labels', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();
      expect(find.text('All'), findsAtLeast(1));
      expect(find.text('Memory'), findsAtLeast(1));
      expect(find.text('Logic'), findsAtLeast(1));
      expect(find.text('Speed'), findsAtLeast(1));
      expect(find.text('Spatial'), findsAtLeast(1));
    });

    testWidgets('tapping a filter chip does not crash', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();
      await tester.tap(find.text('Logic').first);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('WorldMapScreen — stat strip (AC-001, T-005)', () {
    testWidgets('renders streak stat pill', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();
      expect(find.textContaining('day streak'), findsOneWidget);
    });
  });

  group('WorldMapScreen — error state (AC-006)', () {
    testWidgets('shows error text when provider fails, does not crash', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerProgressProvider.overrideWithValue(
              AsyncValue.error(Exception('fail'), StackTrace.empty),
            ),
          ],
          child: MaterialApp(
            theme: AethericPulseDark.themeData,
            home: const Scaffold(body: WorldMapScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('Error loading progress'), findsOneWidget);
    });
  });
}

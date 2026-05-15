/// Integration tests for [playerProgressProvider] — verifies that UI screens
/// correctly display data from the provider and handle error states gracefully.
///
/// Test IDs: T-008, T-009, T-010 (AC-006, AC-007, AC-010)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/main_app/progress_screen.dart';
import 'package:mitoosa/features/navigation/world_map_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

PlayerProgress _progressWith({
  int xp = 200,
  int streak = 5,
  int hearts = 5,
  int freeGamesRemaining = 20,
}) {
  final p = PlayerProgress.fresh(playerId: 'integration-test');
  p.totalXP = xp;
  p.streakCount = streak;
  p.hearts = hearts;
  p.freeGamesRemaining = freeGamesRemaining;
  return p;
}

Widget _wrapScreen(Widget screen, PlayerProgress progress) => ProviderScope(
      overrides: [
        playerProgressProvider.overrideWith((ref) async => progress),
      ],
      child: MaterialApp(
        theme: AethericPulseDark.themeData,
        home: Scaffold(body: screen),
      ),
    );

Widget _wrapError(Widget screen) => ProviderScope(
      overrides: [
        playerProgressProvider.overrideWithValue(
          AsyncValue.error(Exception('db error'), StackTrace.empty),
        ),
      ],
      child: MaterialApp(
        theme: AethericPulseDark.themeData,
        home: Scaffold(body: screen),
      ),
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('playerProgressProvider — ProgressScreen data wiring (AC-010, T-008)',
      () {
    testWidgets('ProgressScreen shows real XP value from provider',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
          _wrapScreen(const ProgressScreen(), _progressWith(xp: 1337)));
      await tester.pump();
      expect(find.text('1337'), findsAtLeast(1));
    });

    testWidgets('ProgressScreen shows real streak from provider',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
          _wrapScreen(const ProgressScreen(), _progressWith(streak: 7)));
      await tester.pump();
      expect(find.textContaining('7'), findsAtLeast(1));
    });
  });

  group('playerProgressProvider — WorldMapScreen data wiring (AC-007, T-009)',
      () {
    testWidgets('WorldMapScreen shows real streak label from provider',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
          _wrapScreen(const WorldMapScreen(), _progressWith(streak: 4)));
      await tester.pump();
      expect(find.textContaining('4 day streak'), findsOneWidget);
    });
  });

  group('playerProgressProvider — error state (AC-006, T-010)', () {
    testWidgets('ProgressScreen shows error text, not a crash', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrapError(const ProgressScreen()));
      await tester.pump();
      expect(find.textContaining('Error'), findsAtLeast(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('WorldMapScreen shows error text, not a crash', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrapError(const WorldMapScreen()));
      await tester.pump();
      expect(find.text('Error loading progress'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

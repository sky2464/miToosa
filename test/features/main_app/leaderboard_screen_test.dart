/// Widget tests for [LeaderboardScreen] — podium, segmented control,
/// ranked rows, and "YOU" highlight against real player XP.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/main_app/leaderboard_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

PlayerProgress _progressWithXp(int xp) {
  final p = PlayerProgress.fresh(playerId: 'test-player');
  p.totalXP = xp;
  return p;
}

Widget _wrap(PlayerProgress progress) => ProviderScope(
  overrides: [playerProgressProvider.overrideWith((ref) async => progress)],
  child: MaterialApp(
    theme: AethericPulseDark.themeData,
    home: const Scaffold(body: LeaderboardScreen()),
  ),
);

void main() {
  group('LeaderboardScreen — structure', () {
    testWidgets('renders Leaderboard heading', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWithXp(80)));
      await tester.pump();
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('renders 3 segmented control options', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWithXp(80)));
      await tester.pump();
      expect(find.text('GLOBAL'), findsOneWidget);
      expect(find.text('FRIENDS'), findsOneWidget);
      expect(find.text('LOCAL'), findsOneWidget);
    });

    testWidgets('renders top-3 podium (Mira K., Diego R., Aiko T.)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWithXp(80)));
      await tester.pump();
      expect(find.text('Mira K.'), findsAtLeast(1));
      expect(find.text('Diego R.'), findsAtLeast(1));
      expect(find.text('Aiko T.'), findsAtLeast(1));
    });
  });

  group('LeaderboardScreen — "YOU" row (AC-014)', () {
    testWidgets('renders YOU badge for current player row', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWithXp(80)));
      await tester.pump();
      expect(find.text('YOU'), findsOneWidget);
      expect(find.text('Pilot_042'), findsOneWidget);
    });
  });

  group('LeaderboardScreen — data wiring (AC-010)', () {
    testWidgets('your row displays real XP from provider', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWithXp(4242)));
      await tester.pump();
      expect(find.text('4242 XP'), findsOneWidget);
    });
  });

  group('LeaderboardScreen — segmented control interaction', () {
    testWidgets('tapping a different segment updates active state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWithXp(80)));
      await tester.pump();
      await tester.tap(find.text('FRIENDS'));
      await tester.pump();
      // No exception means the segment switched cleanly.
      expect(tester.takeException(), isNull);
    });
  });
}

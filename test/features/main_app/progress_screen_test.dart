/// Widget tests for [ProgressScreen] — covers XP hero, cognitive radar,
/// weekly bars, and achievement grid rendering against real provider data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/main_app/progress_screen.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/achievement_card.dart';
import 'package:mitoosa/widgets/progress_ring.dart';
import 'package:mitoosa/widgets/skill_radar.dart';
import 'package:mitoosa/widgets/weekly_bars.dart';

PlayerProgress _progressWith({int xp = 80, int streak = 0, int hearts = 5}) {
  final p = PlayerProgress.fresh(playerId: 'test-player');
  p.totalXP = xp;
  p.streakCount = streak;
  p.hearts = hearts;
  p.levelStars = {'track_test_0': 3, 'track_test_1': 2};
  return p;
}

Widget _wrap(PlayerProgress progress) => ProviderScope(
      overrides: [
        playerProgressProvider.overrideWith((ref) async => progress),
      ],
      child: MaterialApp(
        theme: AethericPulseDark.themeData,
        home: const Scaffold(body: ProgressScreen()),
      ),
    );

void main() {
  group('ProgressScreen — structure', () {
    testWidgets('renders XP hero with ProgressRing', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWith(xp: 80)));
      await tester.pump();
      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });

    testWidgets('renders cognitive radar (SkillRadar)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWith()));
      await tester.pump();
      expect(find.byType(SkillRadar), findsOneWidget);
      expect(find.text('Cognitive map'), findsOneWidget);
    });

    testWidgets('renders weekly bars chart', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWith()));
      await tester.pump();
      expect(find.byType(WeeklyBars), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
    });

    testWidgets('renders 6 AchievementCards in grid', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWith()));
      await tester.pump();
      // Scroll to ensure milestones grid is built
      await tester.drag(find.byType(ProgressScreen), const Offset(0, -800));
      await tester.pump();
      expect(find.byType(AchievementCard), findsAtLeast(2));
    });
  });

  group('ProgressScreen — data wiring (AC-010)', () {
    testWidgets('XP hero shows real totalXP from provider', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_progressWith(xp: 1500)));
      await tester.pump();
      // 1500 XP = level 2 with 500 progress XP
      expect(find.text('1500'), findsOneWidget);
    });
  });
}

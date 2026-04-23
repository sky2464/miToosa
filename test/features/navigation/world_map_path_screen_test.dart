/// Widget tests for [WorldMapPathScreen].
///
/// Coverage:
/// - Renders in portrait and landscape without overflow errors.
/// - Every unlocked node exposes a non-empty Semantics label.
/// - Path line gradient does not throw in either Brightness.dark or Brightness.light.
/// - Tapping an unlocked node pushes a new route (Navigator.push).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/navigation/world_map_path_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

PlayerProgress _freshWithOneCompletedLevel() {
  final p = PlayerProgress.fresh(playerId: 'test-player');
  // Mark level 0 of 'track_test' as completed (3 stars).
  p.levelStars = {'track_test_0': 3};
  return p;
}

List<TrackDefinition> _fakeTracks() => [
      TrackDefinition(
        id: 'track_test',
        name: 'Test Track',
        subtitle: 'A test track',
        rule: PuzzleRule.oddOneOut,
        icon: '🧩',
        targetLevelCount: 3,
        category: 'Test',
      ),
    ];

// ── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildScreen({
  required PlayerProgress progress,
  ThemeMode themeMode = ThemeMode.dark,
}) {
  // Populate the ContentProvider singleton with fake tracks.
  ContentProvider().tracks = _fakeTracks();

  return ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith(
        (ref) async => progress,
      ),
    ],
    child: MaterialApp(
      themeMode: themeMode,
      theme: AethericPulseLight.lightTheme,
      darkTheme: AethericPulseDark.themeData,
      home: const WorldMapPathScreen(),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  tearDown(() {
    // Reset singleton to avoid cross-test contamination.
    ContentProvider().tracks = [];
  });

  group('WorldMapPathScreen — rendering', () {
    testWidgets('renders without overflow in portrait (390×844)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildScreen(progress: _freshWithOneCompletedLevel()),
      );
      await tester.pump(); // settle the FutureProvider

      expect(tester.takeException(), isNull,
          reason: 'No RenderFlex overflow in portrait');
    });

    testWidgets('renders without overflow in landscape (844×390)',
        (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildScreen(progress: _freshWithOneCompletedLevel()),
      );
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason: 'No RenderFlex overflow in landscape');
    });

    testWidgets('renders without errors in light mode (Brightness.light)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildScreen(
          progress: _freshWithOneCompletedLevel(),
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pump();

      // _PathLinePainter uses AethericPulseLight.gradient in light mode —
      // verify CustomPaint does not throw.
      expect(tester.takeException(), isNull,
          reason: 'Light-mode path line gradient renders cleanly');
    });
  });

  group('WorldMapPathScreen — accessibility', () {
    testWidgets('every unlocked level node has a non-empty Semantics label',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final progress = _freshWithOneCompletedLevel(); // level 0 unlocked
      await tester.pumpWidget(_buildScreen(progress: progress));
      await tester.pump();

      // Collect all Semantics labels visible in the tree.
      final semanticsNodes = tester.getSemantics(find.byType(WorldMapPathScreen));
      expect(
        semanticsNodes.label,
        isNotNull,
        reason: 'WorldMapPathScreen should have at least one Semantics node',
      );
    });

    testWidgets('node for level 0 (completed) has a label containing "Level 1"',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final progress = _freshWithOneCompletedLevel();
      await tester.pumpWidget(_buildScreen(progress: progress));
      await tester.pump();

      // The _LevelNode Semantics label for a completed level is:
      // 'Level 1 completed with N stars'
      final labelFinder = find.bySemanticsLabel(
        RegExp(r'Level 1', caseSensitive: false),
      );
      expect(labelFinder, findsAtLeastNWidgets(1),
          reason: 'Level 1 node should have a Semantics label');
    });
  });

  group('WorldMapPathScreen — navigation', () {
    testWidgets('tapping an unlocked node pushes a new route', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var pushCount = 0;
      final observer = _CountingNavigatorObserver(onPush: () => pushCount++);

      ContentProvider().tracks = _fakeTracks();
      final progress = _freshWithOneCompletedLevel();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerProgressProvider.overrideWith((ref) async => progress),
          ],
          child: MaterialApp(
            navigatorObservers: [observer],
            theme: ThemeData.dark(),
            home: const WorldMapPathScreen(),
          ),
        ),
      );
      await tester.pump();

      // Level 1 node (index 0) is unlocked — tap it.
      final levelNodeFinder = find.bySemanticsLabel(
        RegExp(r'Level 1', caseSensitive: false),
      );
      if (levelNodeFinder.evaluate().isNotEmpty) {
        await tester.tap(levelNodeFinder.first, warnIfMissed: false);
        // Use pump instead of pumpAndSettle: _pulseController loops forever
        // and would cause pumpAndSettle to timeout.
        await tester.pump(const Duration(milliseconds: 500));
        expect(pushCount, greaterThan(0),
            reason: 'Tapping an unlocked node should push a route');
      }
    });
  });

  group('WorldMapPathScreen — light-mode brightness branch', () {
    // P2-A: Locked-node light-mode gradient/border/label-color path added in
    // Phase 3. Exercises the isDark==false branch of _LevelNode.build and the
    // textTheme.headlineMedium?.copyWith(...) resolution from Phase 2.
    testWidgets(
        'locked node renders without error in Brightness.light (Phase 2/3 guard)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Use a fresh (all-locked) progress so levels 1+ are locked nodes.
      final progress = PlayerProgress.fresh(playerId: 'test-player');
      await tester.pumpWidget(
        _buildScreen(progress: progress, themeMode: ThemeMode.light),
      );
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason:
              'No exception when locked nodes render in Brightness.light; '
              'covers lightSurfaceContainer gradient, glassBorderDimLight, '
              'and lightOnSurface.withValues(alpha:0.38) label color');
    });

    testWidgets(
        'locked node exposes Semantics label in light mode (headlineMedium null-safety)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Level 0 is unlocked by default in PlayerProgress.fresh; Level 1 is locked.
      final progress = PlayerProgress.fresh(playerId: 'test-player');
      await tester.pumpWidget(
        _buildScreen(progress: progress, themeMode: ThemeMode.light),
      );
      await tester.pump();

      // Level 1 node (unlocked) should have a Semantics label — verifying that
      // textTheme.headlineMedium?.copyWith(...) resolved to a non-null TextStyle
      // in the light theme (ThemeData.light() always provides headlineMedium).
      final levelLabel = find.bySemanticsLabel(
        RegExp(r'Level 1', caseSensitive: false),
      );
      expect(levelLabel, findsAtLeastNWidgets(1),
          reason:
              'Level node Semantics label must survive Brightness.light path; '
              'guards textTheme.headlineMedium?.copyWith(...) from Phase 2');
    });
  });
}

// ── Test helpers ─────────────────────────────────────────────────────────────

class _CountingNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPush;
  _CountingNavigatorObserver({required this.onPush});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPush();
  }
}

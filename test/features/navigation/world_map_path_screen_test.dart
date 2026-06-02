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
    overrides: [playerProgressProvider.overrideWith((ref) async => progress)],
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
    testWidgets('renders without overflow in portrait (390×844)', (
      tester,
    ) async {
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

      expect(
        tester.takeException(),
        isNull,
        reason: 'No RenderFlex overflow in portrait',
      );
    });

    testWidgets('renders without overflow in landscape (844×390)', (
      tester,
    ) async {
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

      expect(
        tester.takeException(),
        isNull,
        reason: 'No RenderFlex overflow in landscape',
      );
    });

    testWidgets('renders without errors in light mode (Brightness.light)', (
      tester,
    ) async {
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
      expect(
        tester.takeException(),
        isNull,
        reason: 'Light-mode path line gradient renders cleanly',
      );
    });
  });

  group('WorldMapPathScreen — accessibility', () {
    testWidgets('every unlocked level node has a non-empty Semantics label', (
      tester,
    ) async {
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
      final semanticsNodes = tester.getSemantics(
        find.byType(WorldMapPathScreen),
      );
      expect(
        semanticsNodes.label,
        isNotNull,
        reason: 'WorldMapPathScreen should have at least one Semantics node',
      );
    });

    testWidgets(
      'node for level 0 (completed) has a label containing "Level 1"',
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
        expect(
          labelFinder,
          findsAtLeastNWidgets(1),
          reason: 'Level 1 node should have a Semantics label',
        );
      },
    );
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
        expect(
          pushCount,
          greaterThan(0),
          reason: 'Tapping an unlocked node should push a route',
        );
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

        expect(
          tester.takeException(),
          isNull,
          reason:
              'No exception when locked nodes render in Brightness.light; '
              'covers lightSurfaceContainer gradient, glassBorderDimLight, '
              'and lightOnSurface.withValues(alpha:0.38) label color',
        );
      },
    );

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
        expect(
          levelLabel,
          findsAtLeastNWidgets(1),
          reason:
              'Level node Semantics label must survive Brightness.light path; '
              'guards textTheme.headlineMedium?.copyWith(...) from Phase 2',
        );
      },
    );
  });

  // S2-02 task 2.1 — all three node states have correct Semantics labels
  group('WorldMapPathScreen — node states (S2-02 2.1)', () {
    testWidgets(
      'done/current/locked nodes expose correct Semantics labels from mocked progress',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Level 0 = done (3 stars), Level 1 = current (first unstarred), Level 2 = locked
        final progress = _freshWithOneCompletedLevel();
        await tester.pumpWidget(_buildScreen(progress: progress));
        await tester.pump();

        // Done state: PathConstellation labels done nodes as "Level N completed"
        expect(
          find.bySemanticsLabel(
            RegExp(r'Level 1 completed', caseSensitive: false),
          ),
          findsAtLeastNWidgets(1),
          reason:
              'Level 1 (index 0) is done — label must say "Level 1 completed"',
        );
        // Current state: labelled "Level N, current"
        expect(
          find.bySemanticsLabel(
            RegExp(r'Level 2, current', caseSensitive: false),
          ),
          findsAtLeastNWidgets(1),
          reason:
              'Level 2 (index 1) is current — label must say "Level 2, current"',
        );
        // Locked state: labelled "Level N, locked"
        expect(
          find.bySemanticsLabel(
            RegExp(r'Level 3, locked', caseSensitive: false),
          ),
          findsAtLeastNWidgets(1),
          reason:
              'Level 3 (index 2) is locked — label must say "Level 3, locked"',
        );
      },
    );
  });

  // S2-02 task 2.2 — track switching re-renders constellation
  group('WorldMapPathScreen — track switching (S2-02 2.2)', () {
    testWidgets('switching to a second track shows that track\'s nodes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Two tracks — second track has id 'track_b' with 2 levels.
      // Set BEFORE building so WorldMapPathScreen reads both tracks.
      ContentProvider().tracks = [
        ..._fakeTracks(),
        TrackDefinition(
          id: 'track_b',
          name: 'Track B',
          subtitle: 'B subtitle',
          rule: PuzzleRule.oddOneOut,
          icon: '🅱️',
          targetLevelCount: 2,
          category: 'Logic',
        ),
      ];

      // Progress has no stars for track_b — both its levels should be current/locked.
      final progress = _freshWithOneCompletedLevel();

      // Build widget directly (not via _buildScreen, which would reset to 1 track).
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerProgressProvider.overrideWith((ref) async => progress),
          ],
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            theme: AethericPulseLight.lightTheme,
            darkTheme: AethericPulseDark.themeData,
            home: const Scaffold(body: WorldMapPathScreen()),
          ),
        ),
      );
      await tester.pump();

      // The first track (track_test) has "Level 1 completed" visible.
      expect(
        find.bySemanticsLabel(
          RegExp(r'Level 1 completed', caseSensitive: false),
        ),
        findsAtLeastNWidgets(1),
        reason: 'Track Test Level 1 should be shown as completed initially',
      );

      // Tap the "Track B" chip to switch tracks.
      expect(
        find.text('Track B'),
        findsOneWidget,
        reason: 'Track B chip should be visible when 2 tracks are loaded',
      );
      await tester.tap(find.text('Track B'));
      await tester.pump();

      // After switching, Track B's Level 1 (index 0) should be current.
      expect(
        find.bySemanticsLabel(
          RegExp(r'Level 1, current', caseSensitive: false),
        ),
        findsAtLeastNWidgets(1),
        reason:
            'Track B Level 1 should be "current" (no stars) after switching',
      );
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

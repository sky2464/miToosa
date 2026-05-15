/// Widget tests for [GameplayScreen] — S2-03 AC-005.
///
/// Coverage:
/// - CTA bar renders Hint (GhostButton) and Submit (PrimaryButton) widgets
///   during the active-play phase.
/// - Submit PrimaryButton is disabled (onPressed == null) before any option
///   is selected.
/// - Tapping an option selects it (enables Submit) without auto-submitting
///   to the engine (game phase stays Playing, not Completed).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/gameplay/gameplay_screen.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/ghost_button.dart';
import 'package:mitoosa/widgets/primary_button.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

/// A minimal track that generates text-based (math) options — easier to find
/// in the widget tree than shape cards.
TrackDefinition _mathTrack() => TrackDefinition(
      id: 'test_math',
      name: 'Math Test',
      subtitle: 'Test track',
      rule: PuzzleRule.mathAddSub,
      targetLevelCount: 5,
      category: 'Test',
    );

PlayerProgress _freshProgress(String trackId) {
  final p = PlayerProgress.fresh(playerId: 'test-player');
  // Mark tutorial seen so HowToPlayModal is suppressed during tests.
  p.markTutorialSeen(trackId);
  return p;
}

// ── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildScreen({
  required TrackDefinition track,
  required PlayerProgress progress,
}) {
  return ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith(
        (ref) async => progress,
      ),
    ],
    child: MaterialApp(
      darkTheme: AethericPulseDark.themeData,
      themeMode: ThemeMode.dark,
      home: GameplayScreen(
        track: track,
        levelIndex: 0,
      ),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  final track = _mathTrack();

  setUp(() {
    // Give ContentProvider a minimal track list to resolve level generation.
    ContentProvider().tracks = [track];
  });

  tearDown(() {
    ContentProvider().tracks = [];
  });

  group('GameplayScreen — S2-03 CTA bar (AC-004 / AC-005)', () {
    testWidgets(
        'renders Hint GhostButton and Submit PrimaryButton during active play',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildScreen(track: track, progress: _freshProgress(track.id)),
      );
      // Settle FutureProvider and post-frame callbacks.
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const ValueKey('hint_ghost_button')),
        findsOneWidget,
        reason: 'Hint GhostButton must be visible during active play',
      );
      expect(
        find.byKey(const ValueKey('submit_primary_button')),
        findsOneWidget,
        reason: 'Submit PrimaryButton must be visible during active play',
      );
    });

    testWidgets('Submit PrimaryButton is disabled before any option is selected',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildScreen(track: track, progress: _freshProgress(track.id)),
      );
      await tester.pump();
      await tester.pump();

      final submitWidget = tester.widget<PrimaryButton>(
        find.byKey(const ValueKey('submit_primary_button')),
      );
      expect(
        submitWidget.onPressed,
        isNull,
        reason: 'Submit must have onPressed==null (disabled) until an option '
            'is selected',
      );
    });

    testWidgets(
        'tapping an option enables Submit without auto-submitting to engine',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildScreen(track: track, progress: _freshProgress(track.id)),
      );
      await tester.pump();
      await tester.pump();

      // Option GestureDetectors live inside the SingleChildScrollView (the back
      // button and CTA buttons are outside it).
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget,
          reason: 'Expect a SingleChildScrollView in the options content area');

      final optionsInScroll = find.descendant(
        of: scrollView,
        matching: find.byType(GestureDetector),
      );
      expect(
        optionsInScroll.evaluate().length,
        greaterThanOrEqualTo(1),
        reason: 'Expect at least one option GestureDetector in the scroll area',
      );

      await tester.tap(optionsInScroll.first);
      await tester.pump();

      // After tapping an option, Submit should be enabled.
      final submitAfter = tester.widget<PrimaryButton>(
        find.byKey(const ValueKey('submit_primary_button')),
      );
      expect(
        submitAfter.onPressed,
        isNotNull,
        reason: 'Submit must be enabled after an option is selected',
      );

      // The CTA bar must still be visible (no auto-submit → game not complete).
      expect(
        find.byKey(const ValueKey('hint_ghost_button')),
        findsOneWidget,
        reason:
            'Hint GhostButton still visible → game is still in the Playing '
            'phase (option tap did not auto-submit)',
      );
      expect(
        find.byType(GhostButton),
        findsOneWidget,
        reason: 'CTA bar still rendered — phase has not completed',
      );
    });
  });
}

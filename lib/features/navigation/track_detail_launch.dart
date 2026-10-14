import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content_provider.dart';
import '../../core/models/gameplay_level.dart';
import '../../theme/design_system.dart';
import '../../data/player_progress_provider.dart';
import '../../widgets/free_games_depleted_sheet.dart';
import '../../widgets/how_to_play_modal.dart';
import '../auth/auth_provider.dart';
import '../gameplay/gameplay_screen.dart';
import '../progression/free_games_controller.dart';
import 'widgets/track_detail_sheets.dart';

Future<void> showDifficultyWithTutorialGate(
  BuildContext context, {
  required WidgetRef ref,
  required TrackDefinition track,
  required int levelIndex,
}) async {
  final progress = await ref.read(playerProgressProvider.future);
  final tutorial = ContentProvider().tutorials.forTrack(track.id);
  final needsTutorial =
      tutorial != null && !progress.seenTutorialWorlds.contains(track.id);

  if (needsTutorial && context.mounted) {
    await HowToPlayModal.show(
      context,
      track: track,
      tutorial: tutorial,
      onStart: () async {
        final playerId = ref.playerId;
        if (playerId != null) {
          await ref
              .read(persistenceProvider)
              .markTutorialSeen(playerId, track.id);
          ref.invalidate(playerProgressProvider);
        }
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }

  if (!context.mounted) return;
  showTrackDifficultySheet(
    context,
    ref: ref,
    track: track,
    levelIndex: levelIndex,
  );
}

void showTrackDifficultySheet(
  BuildContext context, {
  required WidgetRef ref,
  required TrackDefinition track,
  required int levelIndex,
}) {
  showModalBottomSheet<DifficultyTier>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(MiToosaTheme.radiusXl),
      ),
    ),
    builder: (_) => DifficultySelectionSheet(
      onSelect: (tier) async {
        Navigator.pop(context);
        final result = await ref
            .read(freeGamesControllerProvider)
            .consumeGameForStart(DateTime.now());
        if (!context.mounted) return;

        switch (result) {
          case GameStartResult.started:
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameplayScreen(
                  track: track,
                  levelIndex: levelIndex,
                  initialDifficulty: tier,
                  sessionStartLevelIndex: levelIndex,
                  sessionXP: 0,
                ),
              ),
            );
          case GameStartResult.noAllowance:
            final progress = await ref.read(playerProgressProvider.future);
            if (!context.mounted) return;
            await showFreeGamesDepletedSheet(
              context,
              ref: ref,
              progress: progress,
            );
          case GameStartResult.failed:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not start game. Try again.')),
            );
        }
      },
    ),
  );
}

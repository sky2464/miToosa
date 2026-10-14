import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';

/// Offers an explicit, player-driven choice when progress was quarantined
/// after a failed integrity check — never silently discards recoverable
/// data (BL-40).
class RecoveryController {
  RecoveryController({
    required IPersistenceProvider persistence,
    required void Function() invalidateProgress,
  }) : _persistence = persistence,
       _invalidateProgress = invalidateProgress;

  final IPersistenceProvider _persistence;
  final void Function() _invalidateProgress;

  /// Checks for progress quarantined after a failed integrity check and,
  /// if found, prompts the player to recover or discard it before
  /// continuing. Returns the restored [PlayerProgress] if the player chose
  /// to recover, or null if there was nothing to recover or the player
  /// chose to start fresh.
  Future<PlayerProgress?> checkAndPromptRecovery(
    BuildContext context,
    String playerId,
  ) async {
    final recoverable = await _persistence.checkForRecoverableProgress(
      playerId,
    );
    if (recoverable == null) return null;
    if (!context.mounted) return null;

    final shouldRestore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Recover your progress?'),
          content: const Text(
            "Your last save didn't pass a safety check, so it was set "
            'aside instead of being deleted. You can try to recover it, '
            'or start fresh on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Start fresh'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Recover my progress'),
            ),
          ],
        ),
      ),
    );

    if (shouldRestore == true) {
      final restored = await _persistence.restoreRecoverableProgress(playerId);
      _invalidateProgress();
      return restored;
    }

    await _persistence.discardRecoverableProgress(playerId);
    _invalidateProgress();
    return null;
  }
}

final recoveryControllerProvider = Provider<RecoveryController>((ref) {
  return RecoveryController(
    persistence: ref.watch(persistenceProvider),
    invalidateProgress: () => ref.invalidate(playerProgressProvider),
  );
});

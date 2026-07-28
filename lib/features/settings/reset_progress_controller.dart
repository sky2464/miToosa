import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_provider.dart';
import '../../data/player_progress_provider.dart';
import '../auth/auth_provider.dart';

/// Outcome of a reset-progress attempt.
enum ResetProgressResult { success, cancelled, failed }

/// Orchestrates confirmation and safe local progress reset.
class ResetProgressController {
  ResetProgressController({
    required Future<String?> Function() playerId,
    required IPersistenceProvider persistence,
    required void Function() invalidateProgress,
  }) : _playerId = playerId,
       _persistence = persistence,
       _invalidateProgress = invalidateProgress;

  final Future<String?> Function() _playerId;
  final IPersistenceProvider _persistence;
  final void Function() _invalidateProgress;

  Future<ResetProgressResult> confirmAndReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This clears all local stats, levels, and streaks on this device. '
          'Your anonymous pilot ID stays the same.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return ResetProgressResult.cancelled;

    try {
      final id = await _playerId();
      if (id == null || id.isEmpty) return ResetProgressResult.failed;

      await _persistence.resetGameProgress(id);
      _invalidateProgress();
      return ResetProgressResult.success;
    } catch (_) {
      return ResetProgressResult.failed;
    }
  }
}

final resetProgressControllerProvider = Provider<ResetProgressController>((
  ref,
) {
  return ResetProgressController(
    playerId: () async => ref.read(authProvider).maybeWhen(
      data: (id) => id,
      orElse: () => null,
    ),
    persistence: ref.watch(persistenceProvider),
    invalidateProgress: () => ref.invalidate(playerProgressProvider),
  );
});

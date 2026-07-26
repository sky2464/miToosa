import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_provider.dart';
import '../../data/player_progress_provider.dart';
import '../../data/share_bonus_service.dart';
import '../auth/auth_provider.dart';

/// Outcome of attempting to consume one game at final start confirmation.
enum GameStartResult { started, noAllowance, failed }

/// Outcome of requesting the daily share bonus.
enum ShareGrantResult { granted, alreadyClaimed, dismissed, unavailable }

/// Orchestrates allowance consumption and share-bonus grants at the feature layer.
class FreeGamesController {
  FreeGamesController({
    required Future<String?> Function() playerId,
    required IPersistenceProvider persistence,
    required ShareBonusService shareBonus,
    required void Function() invalidateProgress,
  }) : _playerId = playerId,
       _persistence = persistence,
       _shareBonus = shareBonus,
       _invalidateProgress = invalidateProgress;

  final Future<String?> Function() _playerId;
  final IPersistenceProvider _persistence;
  final ShareBonusService _shareBonus;
  final void Function() _invalidateProgress;
  bool _busy = false;

  Future<GameStartResult> consumeGameForStart(DateTime now) async {
    if (_busy) return GameStartResult.failed;
    _busy = true;
    try {
      final id = await _playerId();
      if (id == null || id.isEmpty) return GameStartResult.failed;

      final progress = await _persistence.loadProgress(id);
      progress.checkAllowanceReset(now);
      if (progress.totalGamesAvailable <= 0) {
        return GameStartResult.noAllowance;
      }

      final consumed = await _persistence.consumeFreeGame(id, now);
      if (!consumed) return GameStartResult.noAllowance;

      _invalidateProgress();
      return GameStartResult.started;
    } finally {
      _busy = false;
    }
  }

  Future<ShareGrantResult> requestShareBonus(DateTime now) async {
    if (_busy) return ShareGrantResult.unavailable;
    _busy = true;
    try {
      final id = await _playerId();
      if (id == null || id.isEmpty) return ShareGrantResult.unavailable;

      final progress = await _persistence.loadProgress(id);
      progress.checkAllowanceReset(now);
      if (_claimedShareBonusToday(progress.lastShareDate, now)) {
        return ShareGrantResult.alreadyClaimed;
      }

      final status = await _shareBonus.shareApp();
      if (status == ShareBonusStatus.dismissed) {
        return ShareGrantResult.dismissed;
      }
      if (status != ShareBonusStatus.success) {
        return ShareGrantResult.unavailable;
      }

      final granted = await _persistence.grantShareBonus(id, now);
      if (!granted) return ShareGrantResult.alreadyClaimed;

      _invalidateProgress();
      return ShareGrantResult.granted;
    } finally {
      _busy = false;
    }
  }

  static bool claimedShareBonusToday(DateTime? lastShareDate, DateTime now) {
    if (lastShareDate == null) return false;
    return lastShareDate.year == now.year &&
        lastShareDate.month == now.month &&
        lastShareDate.day == now.day;
  }

  bool _claimedShareBonusToday(DateTime? lastShareDate, DateTime now) =>
      claimedShareBonusToday(lastShareDate, now);
}

final freeGamesControllerProvider = Provider<FreeGamesController>((ref) {
  return FreeGamesController(
    playerId: () async => ref.read(authProvider).maybeWhen(
      data: (id) => id,
      orElse: () => null,
    ),
    persistence: ref.watch(persistenceProvider),
    shareBonus: ref.watch(shareBonusServiceProvider),
    invalidateProgress: () => ref.invalidate(playerProgressProvider),
  );
});

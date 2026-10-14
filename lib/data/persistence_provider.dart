import 'player_progress.dart';

abstract class IPersistenceProvider {
  Future<void> init();
  Future<PlayerProgress> loadProgress(String playerId);
  Future<void> saveProgress(PlayerProgress progress);

  /// Applies [mutate] to the saved progress for [playerId] as one
  /// serialized load-modify-save and returns its result. Competing calls
  /// run one at a time, so no mutation is lost to another.
  Future<T> updateProgress<T>(
    String playerId,
    T Function(PlayerProgress progress) mutate,
  );

  // Engagement-loop mutations
  Future<void> deductHeart(String playerId);
  Future<bool> refuelHeartsWithDiamond(String playerId);
  Future<void> addDiamond(String playerId, [int count = 1]);
  Future<bool> checkAndRefuelHeart(String playerId, DateTime now);
  Future<void> markTutorialSeen(String playerId, String worldId);
  Future<bool> shareAndRefuel(String playerId, DateTime now);
  Future<void> completeOnboarding(String playerId);
  Future<bool> consumeFreeGame(String playerId, DateTime now);
  Future<bool> grantShareBonus(String playerId, DateTime now);

  /// Grants today's daily reward when eligible. Returns false when already claimed.
  Future<bool> claimDailyReward(String playerId, DateTime now);

  /// Replaces saved game progress with a fresh [PlayerProgress] for [playerId].
  /// Preserves anonymous identity — does not rotate player ID or encryption keys.
  Future<void> resetGameProgress(String playerId);

  // Durable saves and recovery (BL-40)

  /// Returns the progress record quarantined after a failed integrity
  /// check for [playerId], or null if nothing is pending recovery.
  Future<PlayerProgress?> checkForRecoverableProgress(String playerId);

  /// Restores the quarantined record for [playerId] into live use and
  /// clears the quarantine slot. Throws a [StateError] if nothing is
  /// pending recovery — callers should check [checkForRecoverableProgress]
  /// first.
  Future<PlayerProgress> restoreRecoverableProgress(String playerId);

  /// Discards the quarantined record for [playerId] without restoring it.
  /// A no-op if nothing is pending recovery.
  Future<void> discardRecoverableProgress(String playerId);
}

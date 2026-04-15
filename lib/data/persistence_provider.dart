import 'player_progress.dart';

abstract class IPersistenceProvider {
  Future<void> init();
  Future<PlayerProgress> loadProgress(String playerId);
  Future<void> saveProgress(PlayerProgress progress);
  Future<void> updateLevelStar(String playerId, String levelId, int stars);

  // Engagement-loop mutations
  Future<void> deductHeart(String playerId);
  Future<bool> refuelHeartsWithDiamond(String playerId);
  Future<void> addDiamond(String playerId, [int count = 1]);
  Future<bool> checkAndRefuelHeart(String playerId, DateTime now);
  Future<void> refuelHeartLowerLevel(String playerId);
  Future<void> markTutorialSeen(String playerId, String worldId);
  Future<bool> shareAndRefuel(String playerId, DateTime now);
}

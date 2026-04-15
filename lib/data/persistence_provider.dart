import 'player_progress.dart';

abstract class IPersistenceProvider {
  Future<void> init();
  Future<PlayerProgress> loadProgress(String playerId);
  Future<void> saveProgress(PlayerProgress progress);
  Future<void> updateLevelStar(String playerId, String levelId, int stars);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/features/engagement/daily_reward_controller.dart';

void main() {
  group('DailyRewardController', () {
    test('can claim when never claimed', () {
      final progress = PlayerProgress.fresh(playerId: 'p');
      final controller = DailyRewardController(
        progress: progress,
        clock: DateTime(2026, 4, 18),
      );
      expect(controller.canClaim, isTrue);
      expect(controller.claimTargetDay, 1);
    });

    test('cannot claim twice same calendar day', () {
      final progress = PlayerProgress.fresh(playerId: 'p');
      progress.claimDailyReward(2, DateTime(2026, 4, 18, 9));
      final controller = DailyRewardController(
        progress: progress,
        clock: DateTime(2026, 4, 18, 20),
      );
      expect(controller.canClaim, isFalse);
      expect(controller.highlightDay, 2);
    });

    test('advances claim target after prior day', () {
      final progress = PlayerProgress.fresh(playerId: 'p');
      progress.claimDailyReward(2, DateTime(2026, 4, 17));
      final controller = DailyRewardController(
        progress: progress,
        clock: DateTime(2026, 4, 18),
      );
      expect(controller.canClaim, isTrue);
      expect(controller.claimTargetDay, 3);
    });
  });
}

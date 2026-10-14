import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../features/auth/auth_provider.dart';
import '../daily_rewards/daily_rewards_modal.dart';
import 'daily_reward_controller.dart';

Future<void> showDailyRewardSheet(
  BuildContext context, {
  required WidgetRef ref,
  required PlayerProgress progress,
}) async {
  final controller = DailyRewardController(progress: progress);
  if (!controller.canClaim) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return DailyRewardsModal(
        currentDay: controller.highlightDay,
        canClaim: controller.canClaim,
        onClaim: controller.canClaim
            ? () => _claimAndClose(sheetContext, ref: ref)
            : null,
      );
    },
  );
}

Future<void> _claimAndClose(
  BuildContext context, {
  required WidgetRef ref,
}) async {
  final playerId = ref
      .read(authProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);
  if (playerId == null || playerId.isEmpty) return;

  final persistence = ref.read(persistenceProvider);
  final claimed = await persistence.claimDailyReward(playerId, DateTime.now());
  if (claimed) {
    ref.invalidate(playerProgressProvider);
  }
  if (context.mounted) {
    Navigator.of(context).pop();
  }
}

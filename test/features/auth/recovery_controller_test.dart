/// BL-40 — Recovery controller tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/persistence_provider.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/features/auth/recovery_controller.dart';

class _FakePersistence implements IPersistenceProvider {
  final Map<String, PlayerProgress> store = {};
  final Map<String, PlayerProgress> quarantine = {};

  @override
  Future<void> init() async {}

  @override
  Future<PlayerProgress> loadProgress(String playerId) async {
    return store.putIfAbsent(
      playerId,
      () => PlayerProgress.fresh(playerId: playerId),
    );
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    store[progress.playerId] = progress;
  }

  @override
  Future<PlayerProgress?> checkForRecoverableProgress(String playerId) async {
    return quarantine[playerId];
  }

  @override
  Future<PlayerProgress> restoreRecoverableProgress(String playerId) async {
    final quarantined = quarantine[playerId];
    if (quarantined == null) {
      throw StateError('No recoverable progress for $playerId');
    }
    store[playerId] = quarantined;
    quarantine.remove(playerId);
    return quarantined;
  }

  @override
  Future<void> discardRecoverableProgress(String playerId) async {
    quarantine.remove(playerId);
  }

  @override
  Future<void> resetGameProgress(String playerId) async {
    store[playerId] = PlayerProgress.fresh(playerId: playerId);
    quarantine.remove(playerId);
  }

  // Unused by these tests — not exercised by RecoveryController.
  @override
  Future<T> updateProgress<T>(
    String playerId,
    T Function(PlayerProgress progress) mutate,
  ) async {
    final progress = await loadProgress(playerId);
    final value = mutate(progress);
    await saveProgress(progress);
    return value;
  }

  @override
  Future<void> deductHeart(String playerId) async {}
  @override
  Future<bool> refuelHeartsWithDiamond(String playerId) async => false;
  @override
  Future<void> addDiamond(String playerId, [int count = 1]) async {}
  @override
  Future<bool> checkAndRefuelHeart(String playerId, DateTime now) async =>
      false;
  @override
  Future<void> markTutorialSeen(String playerId, String worldId) async {}
  @override
  Future<bool> shareAndRefuel(String playerId, DateTime now) async => false;
  @override
  Future<void> completeOnboarding(String playerId) async {}
  @override
  Future<bool> consumeFreeGame(String playerId, DateTime now) async => false;
  @override
  Future<bool> grantShareBonus(String playerId, DateTime now) async => false;
  @override
  Future<bool> claimDailyReward(String playerId, DateTime now) async => false;
}

RecoveryController _controller({
  required _FakePersistence persistence,
  void Function()? onInvalidate,
}) {
  return RecoveryController(
    persistence: persistence,
    invalidateProgress: onInvalidate ?? () {},
  );
}

Widget _host(
  RecoveryController controller,
  String playerId,
  void Function(PlayerProgress?)? onResult,
) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            final result = await controller.checkAndPromptRecovery(
              context,
              playerId,
            );
            onResult?.call(result);
          },
          child: const Text('trigger'),
        ),
      ),
    ),
  );
}

void main() {
  late _FakePersistence persistence;

  setUp(() {
    persistence = _FakePersistence();
  });

  group('RecoveryController — nothing to recover', () {
    testWidgets('no dialog shown when nothing is quarantined', (tester) async {
      final controller = _controller(persistence: persistence);
      PlayerProgress? result;
      await tester.pumpWidget(_host(controller, 'p1', (r) => result = r));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isNull);
    });
  });

  group('RecoveryController — recovery offered', () {
    testWidgets('choosing "Recover my progress" restores the record', (
      tester,
    ) async {
      final quarantined = PlayerProgress.fresh(playerId: 'p2')..totalXP = 500;
      persistence.quarantine['p2'] = quarantined;
      var invalidated = false;

      final controller = _controller(
        persistence: persistence,
        onInvalidate: () => invalidated = true,
      );
      PlayerProgress? result;
      await tester.pumpWidget(_host(controller, 'p2', (r) => result = r));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Recover your progress?'), findsOneWidget);

      await tester.tap(find.text('Recover my progress'));
      await tester.pumpAndSettle();

      expect(result?.totalXP, 500);
      expect(persistence.quarantine.containsKey('p2'), isFalse);
      expect(persistence.store['p2']?.totalXP, 500);
      expect(invalidated, isTrue);
    });

    testWidgets('choosing "Start fresh" discards without restoring', (
      tester,
    ) async {
      final quarantined = PlayerProgress.fresh(playerId: 'p3')..totalXP = 700;
      persistence.quarantine['p3'] = quarantined;

      final controller = _controller(persistence: persistence);
      PlayerProgress? result;
      await tester.pumpWidget(_host(controller, 'p3', (r) => result = r));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start fresh'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(persistence.quarantine.containsKey('p3'), isFalse);
      expect(
        persistence.store.containsKey('p3'),
        isFalse,
        reason: 'Discarding must not write the corrupted value back',
      );
    });

    testWidgets('the dialog cannot be dismissed without an explicit choice '
        '(never silently discard)', (tester) async {
      final quarantined = PlayerProgress.fresh(playerId: 'p4')..totalXP = 900;
      persistence.quarantine['p4'] = quarantined;

      final controller = _controller(persistence: persistence);
      await tester.pumpWidget(_host(controller, 'p4', null));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      // Tap the barrier (outside the dialog) — must not dismiss it.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Recover your progress?'), findsOneWidget);

      // Attempt a system back gesture — must not dismiss it either.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Recover your progress?'), findsOneWidget);

      // The quarantined record must still be sitting there, untouched.
      expect(persistence.quarantine.containsKey('p4'), isTrue);
    });
  });
}

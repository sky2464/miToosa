/// BL-31 — Reset progress controller tests (T-003–T-005).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/hive_persistence_provider.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/features/settings/reset_progress_controller.dart';

class _MemPersistence extends HivePersistenceProvider {
  final Map<String, PlayerProgress> _store = {};
  bool failReset = false;

  @override
  Future<void> init() async {}

  @override
  Future<PlayerProgress> loadProgress(String playerId) async {
    return _store.putIfAbsent(
      playerId,
      () => PlayerProgress.fresh(playerId: playerId),
    );
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    _store[progress.playerId] = progress;
  }

  @override
  Future<void> resetGameProgress(String playerId) async {
    if (failReset) throw StateError('reset failed');
    await saveProgress(PlayerProgress.fresh(playerId: playerId));
  }
}

ResetProgressController _controller({
  required _MemPersistence persistence,
  String playerId = 'pilot-42',
  void Function()? onInvalidate,
}) {
  return ResetProgressController(
    playerId: () async => playerId,
    persistence: persistence,
    invalidateProgress: onInvalidate ?? () {},
  );
}

Widget _dialogHost(ResetProgressController controller) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: ElevatedButton(
          onPressed: () => controller.confirmAndReset(context),
          child: const Text('trigger'),
        ),
      ),
    ),
  );
}

void main() {
  late _MemPersistence persistence;

  setUp(() {
    persistence = _MemPersistence();
  });

  group('ResetProgressController — confirmation (T-003)', () {
    testWidgets('cancel preserves progress', (tester) async {
      final progress = await persistence.loadProgress('pilot-42');
      progress.totalXP = 5000;
      await persistence.saveProgress(progress);

      final controller = _controller(persistence: persistence);
      await tester.pumpWidget(_dialogHost(controller));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final after = await persistence.loadProgress('pilot-42');
      expect(after.totalXP, 5000);
    });

    testWidgets('barrier dismiss preserves progress', (tester) async {
      final progress = await persistence.loadProgress('pilot-42');
      progress.totalXP = 1200;
      await persistence.saveProgress(progress);

      final controller = _controller(persistence: persistence);
      await tester.pumpWidget(_dialogHost(controller));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      final after = await persistence.loadProgress('pilot-42');
      expect(after.totalXP, 1200);
    });
  });

  group('ResetProgressController — success (T-004)', () {
    testWidgets('confirm resets stats but keeps player ID', (tester) async {
      var invalidated = false;
      final progress = await persistence.loadProgress('pilot-42');
      progress.totalXP = 9000;
      progress.streakCount = 14;
      await persistence.saveProgress(progress);

      final controller = _controller(
        persistence: persistence,
        onInvalidate: () => invalidated = true,
      );

      await tester.pumpWidget(_dialogHost(controller));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      final after = await persistence.loadProgress('pilot-42');
      expect(after.playerId, 'pilot-42');
      expect(after.totalXP, 0);
      expect(after.streakCount, 0);
      expect(invalidated, isTrue);
    });
  });

  group('ResetProgressController — failure (T-005)', () {
    testWidgets('persistence failure leaves prior progress', (tester) async {
      persistence.failReset = true;
      final progress = await persistence.loadProgress('pilot-42');
      progress.totalXP = 3333;
      await persistence.saveProgress(progress);

      final controller = _controller(persistence: persistence);
      await tester.pumpWidget(_dialogHost(controller));
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      final after = await persistence.loadProgress('pilot-42');
      expect(after.totalXP, 3333);
    });
  });
}

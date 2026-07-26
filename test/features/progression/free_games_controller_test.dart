/// Controller tests for BL-29 free-games wedge — T-002 through T-006.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/hive_persistence_provider.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/share_bonus_service.dart';
import 'package:mitoosa/features/progression/free_games_controller.dart';

class _MemPersistence extends HivePersistenceProvider {
  final Map<String, PlayerProgress> _store = {};

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
}

class _FakeShareBonus extends ShareBonusService {
  _FakeShareBonus(this.status);

  ShareBonusStatus status;

  @override
  Future<ShareBonusStatus> shareApp() async => status;
}

FreeGamesController _controller({
  required _MemPersistence persistence,
  required _FakeShareBonus share,
  String playerId = 'player-1',
  void Function()? onInvalidate,
}) {
  return FreeGamesController(
    playerId: () async => playerId,
    persistence: persistence,
    shareBonus: share,
    invalidateProgress: onInvalidate ?? () {},
  );
}

void main() {
  final now = DateTime(2026, 7, 26, 14, 0);
  late _MemPersistence persistence;

  setUp(() {
    persistence = _MemPersistence();
  });

  Future<void> seedProgress({
    int freeGames = 25,
    int shareBonus = 0,
  }) async {
    final progress = await persistence.loadProgress('player-1');
    progress.freeGamesRemaining = freeGames;
    progress.shareBonusGames = shareBonus;
    progress.lastAllowanceReset = now;
    await persistence.saveProgress(progress);
  }

  group('FreeGamesController — consumeGameForStart (T-002)', () {
    test('consumes exactly one game when allowance remains', () async {
      await seedProgress(freeGames: 3);

      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.success),
      );

      final result = await controller.consumeGameForStart(now);
      expect(result, GameStartResult.started);

      final updated = await persistence.loadProgress('player-1');
      expect(updated.freeGamesRemaining, 2);
      expect(updated.totalGamesAvailable, 2);
    });

    test('serializes double taps to a single consumption', () async {
      await seedProgress(freeGames: 1);

      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.success),
      );

      final first = controller.consumeGameForStart(now);
      final second = controller.consumeGameForStart(now);
      expect(await first, GameStartResult.started);
      expect(await second, GameStartResult.failed);

      final updated = await persistence.loadProgress('player-1');
      expect(updated.totalGamesAvailable, 0);
    });

    test('returns noAllowance when depleted', () async {
      await seedProgress(freeGames: 0, shareBonus: 0);

      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.success),
      );

      expect(
        await controller.consumeGameForStart(now),
        GameStartResult.noAllowance,
      );
    });
  });

  group('FreeGamesController — requestShareBonus (T-005, T-006)', () {
    test('grants 40 games after successful share', () async {
      await seedProgress();
      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.success),
      );

      expect(await controller.requestShareBonus(now), ShareGrantResult.granted);

      final updated = await persistence.loadProgress('player-1');
      expect(updated.shareBonusGames, 40);
      expect(updated.totalGamesAvailable, 25 + 40);
    });

    test('does not grant on dismissed share', () async {
      await seedProgress();
      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.dismissed),
      );

      expect(
        await controller.requestShareBonus(now),
        ShareGrantResult.dismissed,
      );

      final updated = await persistence.loadProgress('player-1');
      expect(updated.shareBonusGames, 0);
    });

    test('blocks same-day repeat even after bonus is fully consumed', () async {
      await seedProgress();
      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.success),
      );

      expect(await controller.requestShareBonus(now), ShareGrantResult.granted);

      final depleted = await persistence.loadProgress('player-1');
      depleted.shareBonusGames = 0;
      depleted.freeGamesRemaining = 0;
      await persistence.saveProgress(depleted);

      expect(
        await controller.requestShareBonus(now),
        ShareGrantResult.alreadyClaimed,
      );
    });

    test('allows grant on the next local calendar day', () async {
      await seedProgress();
      final controller = _controller(
        persistence: persistence,
        share: _FakeShareBonus(ShareBonusStatus.success),
      );

      expect(await controller.requestShareBonus(now), ShareGrantResult.granted);

      final nextDay = DateTime(2026, 7, 27, 9);
      expect(
        await controller.requestShareBonus(nextDay),
        ShareGrantResult.granted,
      );

      final updated = await persistence.loadProgress('player-1');
      expect(updated.shareBonusGames, 40);
    });
  });
}

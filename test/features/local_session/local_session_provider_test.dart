import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/local_session/local_session_provider.dart';

void main() {
  group('LocalSessionState', () {
    test('Creates state with idle phase by default', () {
      final state = LocalSessionState(phase: LocalSessionPhase.idle);

      expect(state.phase, LocalSessionPhase.idle);
      expect(state.sessionId, isNull);
      expect(state.players.isEmpty, true);
    });

    test('copyWith updates fields correctly', () {
      final original = LocalSessionState(phase: LocalSessionPhase.idle);
      final updated = original.copyWith(
        phase: LocalSessionPhase.hosting,
        sessionId: 'sess-123',
      );

      expect(updated.phase, LocalSessionPhase.hosting);
      expect(updated.sessionId, 'sess-123');
      expect(original.phase, LocalSessionPhase.idle); // Original unchanged
    });

    test('isValid returns true when no expiry', () {
      final state = LocalSessionState(
        phase: LocalSessionPhase.hosting,
        expiresAt: null,
      );

      expect(state.isValid, true);
    });

    test('isValid returns false when expired', () {
      final state = LocalSessionState(
        phase: LocalSessionPhase.hosting,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(state.isValid, false);
    });

    test('isValid returns true when not yet expired', () {
      final state = LocalSessionState(
        phase: LocalSessionPhase.hosting,
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      expect(state.isValid, true);
    });

    test('isActive returns true for hosting phase', () {
      final state = LocalSessionState(phase: LocalSessionPhase.hosting);
      expect(state.isActive, true);
    });

    test('isActive returns true for playing phase', () {
      final state = LocalSessionState(phase: LocalSessionPhase.playing);
      expect(state.isActive, true);
    });

    test('isActive returns false for idle phase', () {
      final state = LocalSessionState(phase: LocalSessionPhase.idle);
      expect(state.isActive, false);
    });
  });

  group('LocalSessionPlayer', () {
    test('Creates player with default values', () {
      final player = LocalSessionPlayer(
        playerId: 'player-1',
        name: 'Alice',
      );

      expect(player.playerId, 'player-1');
      expect(player.name, 'Alice');
      expect(player.xp, 0);
      expect(player.coins, 0);
      expect(player.stars, 0);
    });

    test('copyWith updates fields correctly', () {
      final original = LocalSessionPlayer(
        playerId: 'player-1',
        name: 'Alice',
        xp: 100,
      );

      final updated = original.copyWith(
        xp: 150,
        stars: 5,
      );

      expect(updated.xp, 150);
      expect(updated.stars, 5);
      expect(updated.name, 'Alice'); // Unchanged
      expect(original.xp, 100); // Original unchanged
    });
  });

  group('LocalSessionNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is idle', () {
      final state = container.read(localSessionProvider);

      expect(state.phase, LocalSessionPhase.idle);
      expect(state.players.isEmpty, true);
    });

    test('startHosting updates state to hosting', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      final state = container.read(localSessionProvider);

      expect(state.phase, LocalSessionPhase.hosting);
      expect(state.sessionId, isNotNull);
      expect(state.players.length, 1);
      expect(state.players['player-1']?.name, 'Alice');
      expect(state.currentPlayerId, 'player-1');
    });

    test('startHosting creates expiry timeout', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      final state = container.read(localSessionProvider);

      expect(state.expiresAt, isNotNull);
      expect(state.expiresAt?.isAfter(DateTime.now()), true);
    });

    test('recordMove updates player score', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      container.read(localSessionProvider.notifier).recordMove(
            0,
            true,
            3,
            50,
          );

      final state = container.read(localSessionProvider);
      final player = state.players['player-1'];

      expect(player?.stars, 3);
      expect(player?.xp, 50);
    });

    test('startGame changes phase from hosting to playing', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      container.read(localSessionProvider.notifier).startGame();

      final state = container.read(localSessionProvider);
      expect(state.phase, LocalSessionPhase.playing);
    });

    test('endSession resets to idle state', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      await container.read(localSessionProvider.notifier).endSession();

      final state = container.read(localSessionProvider);

      expect(state.phase, LocalSessionPhase.idle);
      expect(state.sessionId, isNull);
      expect(state.players.isEmpty, true);
    });

    test('resetError clears error state', () {
      // Manually set error state for testing
      container.read(localSessionProvider.notifier).state =
          LocalSessionState(
        phase: LocalSessionPhase.error,
        errorMessage: 'Test error',
      );

      container.read(localSessionProvider.notifier).resetError();

      final state = container.read(localSessionProvider);
      expect(state.phase, LocalSessionPhase.idle);
      expect(state.errorMessage, isNull);
    });

    test('joinSession updates state', () async {
      const qrUrl = 'ws://192.168.1.100:8765?session=sess-123&playerId=host-1';

      await container.read(localSessionProvider.notifier).joinSession(
            qrUrl,
            'player-2',
            'Bob',
          );

      final state = container.read(localSessionProvider);

      expect(state.phase, LocalSessionPhase.joining);
      expect(state.qrUrl, qrUrl);
      expect(state.players.length, 1);
      expect(state.players['player-2']?.name, 'Bob');
    });

    test('joinSession with invalid QR URL sets error', () async {
      await container.read(localSessionProvider.notifier).joinSession(
            'invalid-url',
            'player-2',
            'Bob',
          );

      final state = container.read(localSessionProvider);

      expect(state.phase, LocalSessionPhase.error);
      expect(state.errorMessage, contains('Invalid'));
    });

    test('Multiple players can be in session', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      // Manually add another player (in real scenario, would come from network)
      final state = container.read(localSessionProvider);
      final updatedPlayers = {
        ...state.players,
        'player-2': LocalSessionPlayer(
          playerId: 'player-2',
          name: 'Bob',
        ),
      };

      container.read(localSessionProvider.notifier).state = state.copyWith(
        players: updatedPlayers,
      );

      final finalState = container.read(localSessionProvider);
      expect(finalState.players.length, 2);
      expect(finalState.players['player-1']?.name, 'Alice');
      expect(finalState.players['player-2']?.name, 'Bob');
    });

    test('Player score updates preserve other player data', () async {
      await container.read(localSessionProvider.notifier).startHosting(
            'player-1',
            'Alice',
          );

      // Add second player
      final state1 = container.read(localSessionProvider);
      final updatedPlayers = {
        ...state1.players,
        'player-2': LocalSessionPlayer(
          playerId: 'player-2',
          name: 'Bob',
          xp: 200,
        ),
      };

      container.read(localSessionProvider.notifier).state = state1.copyWith(
        players: updatedPlayers,
      );

      // Update player 1's score
      container.read(localSessionProvider.notifier).recordMove(0, true, 3, 50);

      final finalState = container.read(localSessionProvider);
      expect(finalState.players['player-1']?.xp, 50);
      expect(finalState.players['player-2']?.xp, 200); // Unchanged
    });
  });

  group('LocalSessionPhase', () {
    test('All phases are defined', () {
      expect(LocalSessionPhase.idle, isNotNull);
      expect(LocalSessionPhase.hosting, isNotNull);
      expect(LocalSessionPhase.joining, isNotNull);
      expect(LocalSessionPhase.playing, isNotNull);
      expect(LocalSessionPhase.ended, isNotNull);
      expect(LocalSessionPhase.error, isNotNull);
    });
  });
}

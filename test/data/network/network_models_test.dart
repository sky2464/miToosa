import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/network/network_models.dart';

void main() {
  group('NetworkMessage Serialization', () {
    test('JoinSessionMessage serializes and deserializes correctly', () {
      const originalMessage = JoinSessionMessage(
        playerId: 'player-123',
        sessionId: 'session-abc',
        timestamp: 1000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'join_session');
      expect(json['playerId'], 'player-123');
      expect(json['sessionId'], 'session-abc');

      final deserialized = JoinSessionMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('JoinSessionAckMessage serializes and deserializes correctly', () {
      const originalMessage = JoinSessionAckMessage(
        sessionId: 'session-abc',
        connectedPlayers: ['player-1', 'player-2'],
        timestamp: 2000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'join_session_ack');
      expect(json['connectedPlayers'], ['player-1', 'player-2']);

      final deserialized = JoinSessionAckMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('GameStartMessage serializes and deserializes correctly', () {
      const originalMessage = GameStartMessage(
        sessionId: 'session-abc',
        levelId: 'level-42',
        durationSeconds: 60,
        timestamp: 3000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'game_start');
      expect(json['levelId'], 'level-42');
      expect(json['durationSeconds'], 60);

      final deserialized = GameStartMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('MoveSelectedMessage serializes and deserializes correctly', () {
      const originalMessage = MoveSelectedMessage(
        playerId: 'player-123',
        sessionId: 'session-abc',
        levelId: 'level-42',
        optionIndex: 2,
        isCorrect: true,
        stars: 3,
        xpGained: 150,
        timestamp: 4000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'move_selected');
      expect(json['optionIndex'], 2);
      expect(json['isCorrect'], true);
      expect(json['stars'], 3);
      expect(json['xpGained'], 150);

      final deserialized = MoveSelectedMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('TimerTickMessage serializes and deserializes correctly', () {
      const originalMessage = TimerTickMessage(
        sessionId: 'session-abc',
        remainingSeconds: 45,
        timestamp: 5000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'timer_tick');
      expect(json['remainingSeconds'], 45);

      final deserialized = TimerTickMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('PlayerConnectedMessage serializes and deserializes correctly', () {
      const originalMessage = PlayerConnectedMessage(
        sessionId: 'session-abc',
        playerId: 'player-456',
        playerName: 'Alice',
        timestamp: 6000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'player_connected');
      expect(json['playerId'], 'player-456');
      expect(json['playerName'], 'Alice');

      final deserialized = PlayerConnectedMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('PlayerDisconnectedMessage serializes and deserializes correctly', () {
      const originalMessage = PlayerDisconnectedMessage(
        sessionId: 'session-abc',
        playerId: 'player-456',
        timestamp: 7000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'player_disconnected');
      expect(json['playerId'], 'player-456');

      final deserialized = PlayerDisconnectedMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('SessionEndedMessage serializes and deserializes correctly', () {
      const originalMessage = SessionEndedMessage(
        sessionId: 'session-abc',
        reason: 'host_ended',
        timestamp: 8000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'session_ended');
      expect(json['reason'], 'host_ended');

      final deserialized = SessionEndedMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('RequestSyncMessage serializes and deserializes correctly', () {
      const originalMessage = RequestSyncMessage(
        playerId: 'player-123',
        sessionId: 'session-abc',
        timestamp: 9000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'request_sync');
      expect(json['playerId'], 'player-123');

      final deserialized = RequestSyncMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('SyncStateMessage serializes and deserializes correctly', () {
      final originalMessage = const SyncStateMessage(
        sessionId: 'session-abc',
        currentLevelId: 'level-42',
        playerScores: {'player-1': 100, 'player-2': 80},
        remainingSeconds: 30,
        timestamp: 10000,
      );

      final json = originalMessage.toJson();
      expect(json['type'], 'sync_state');
      expect(json['playerScores'], {'player-1': 100, 'player-2': 80});
      expect(json['remainingSeconds'], 30);

      final deserialized = SyncStateMessage.fromJson(json);
      expect(deserialized, originalMessage);
    });

    test('NetworkMessage.fromJson dispatches correctly', () {
      const joinJson = {
        'type': 'join_session',
        'playerId': 'player-123',
        'sessionId': 'session-abc',
        'timestamp': 1000,
      };

      final message = NetworkMessage.fromJson(joinJson);
      expect(message, isA<JoinSessionMessage>());
      expect((message as JoinSessionMessage).playerId, 'player-123');
    });

    test('NetworkMessage.fromJson throws on unknown type', () {
      const unknownJson = {'type': 'unknown_message_type', 'data': 'some data'};

      expect(
        () => NetworkMessage.fromJson(unknownJson),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('LocalPlaySession', () {
    test('LocalPlaySession copyWith updates fields correctly', () {
      final now = DateTime.now();
      final session = LocalPlaySession(
        id: 'session-1',
        hostPlayerId: 'host-123',
        guestPlayerId: null,
        createdAt: now,
      );

      final updated = session.copyWith(guestPlayerId: 'guest-456');

      expect(updated.hostPlayerId, 'host-123');
      expect(updated.guestPlayerId, 'guest-456');
      expect(updated.createdAt, now);
    });

    test('LocalPlaySession.isValid returns true when not expired', () {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      final session = LocalPlaySession(
        id: 'session-1',
        hostPlayerId: 'host-123',
        createdAt: DateTime.now(),
        expiresAt: futureTime,
      );

      expect(session.isValid, true);
    });

    test('LocalPlaySession.isValid returns false when expired', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
      final session = LocalPlaySession(
        id: 'session-1',
        hostPlayerId: 'host-123',
        createdAt: DateTime.now(),
        expiresAt: pastTime,
      );

      expect(session.isValid, false);
    });

    test('LocalPlaySession.isValid returns true when expiresAt is null', () {
      final session = LocalPlaySession(
        id: 'session-1',
        hostPlayerId: 'host-123',
        createdAt: DateTime.now(),
        expiresAt: null,
      );

      expect(session.isValid, true);
    });
  });

  group('PlayerScore', () {
    test('PlayerScore copyWith updates fields correctly', () {
      const score = PlayerScore(
        playerId: 'player-1',
        xpGained: 100,
        coinsGained: 10,
        starsEarned: 3,
        moveHistory: [3, 2, 4],
      );

      final updated = score.copyWith(xpGained: 150, coinsGained: 15);

      expect(updated.playerId, 'player-1');
      expect(updated.xpGained, 150);
      expect(updated.coinsGained, 15);
      expect(updated.starsEarned, 3);
      expect(updated.moveHistory, [3, 2, 4]);
    });

    test('PlayerScore equality works correctly', () {
      const score1 = PlayerScore(
        playerId: 'player-1',
        xpGained: 100,
        coinsGained: 10,
        starsEarned: 3,
        moveHistory: [3, 2, 4],
      );

      const score2 = PlayerScore(
        playerId: 'player-1',
        xpGained: 100,
        coinsGained: 10,
        starsEarned: 3,
        moveHistory: [3, 2, 4],
      );

      expect(score1, score2);
    });
  });
}

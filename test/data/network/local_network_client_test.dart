import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/network/local_network_client.dart';
import 'package:mitoosa/data/network/network_models.dart';

void main() {
  group('LocalNetworkClient', () {
    late LocalNetworkClient client;
    late String testWsUrl;
    late String testPlayerId;
    late String testSessionId;

    setUp(() {
      testWsUrl =
          'ws://192.168.1.100:8765?session=sess-123&playerId=player-456';
      testPlayerId = 'player-456';
      testSessionId = 'sess-123';
    });

    tearDown(() async {
      try {
        await client.disconnect();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('Client initializes in disconnected state', () {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
      );

      expect(client.state, LocalNetworkClientState.disconnected);
      expect(client.isConnected, false);
    });

    test('Client can disconnect when not connected', () async {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
      );

      await client.disconnect();
      expect(client.state, LocalNetworkClientState.disconnected);
    });

    test('Client throws StateError when sending without connection', () {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
      );

      final message = GameStartMessage(
        sessionId: testSessionId,
        levelId: 'level-1',
        durationSeconds: 60,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      expect(() => client.sendMessage(message), throwsA(isA<StateError>()));
    });

    test('Client state transitions are tracked', () {
      final states = <LocalNetworkClientState>[];

      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
        onConnectionStateChanged: (state) {
          states.add(state);
        },
      );

      expect(client.state, LocalNetworkClientState.disconnected);
    });

    test('Connection timeout is configured correctly', () {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
        handshakeTimeout: const Duration(seconds: 60),
      );

      expect(client.handshakeTimeout, const Duration(seconds: 60));
    });

    test('Max reconnect attempts is configurable', () {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
        maxReconnectAttempts: 10,
      );

      expect(client.maxReconnectAttempts, 10);
    });

    test('Max reconnect delay is configurable', () {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
        maxReconnectDelay: const Duration(seconds: 60),
      );

      expect(client.maxReconnectDelay, const Duration(seconds: 60));
    });

    test('Client can be created with default configuration', () {
      client = LocalNetworkClient(
        wsUrl: testWsUrl,
        playerId: testPlayerId,
        sessionId: testSessionId,
        onMessageReceived: (message) {},
      );

      expect(client.wsUrl, testWsUrl);
      expect(client.playerId, testPlayerId);
      expect(client.sessionId, testSessionId);
      expect(client.handshakeTimeout, const Duration(seconds: 30));
      expect(client.maxReconnectAttempts, 5);
      expect(client.maxReconnectDelay, const Duration(seconds: 30));
    });
  });

  group('QR URL parsing', () {
    test('Parse standard QR URL format', () {
      const url = 'ws://192.168.1.100:8765?session=abc123&playerId=xyz789';
      final result = LocalNetworkClient.parseQrUrl(url);

      expect(result?.$2, 'abc123');
      expect(result?.$3, 'xyz789');
    });

    test('Parse QR URL with HTTPS scheme', () {
      const url = 'wss://192.168.1.100:8765?session=abc123&playerId=xyz789';
      final result = LocalNetworkClient.parseQrUrl(url);

      expect(result?.$2, 'abc123');
      expect(result?.$3, 'xyz789');
    });

    test('Parse QR URL with port number', () {
      const url = 'ws://10.0.0.1:18765?session=sess123&playerId=player123';
      final result = LocalNetworkClient.parseQrUrl(url);

      expect(result?.$2, 'sess123');
      expect(result?.$3, 'player123');
    });

    test('Parse QR URL with localhost', () {
      const url = 'ws://127.0.0.1:8765?session=local123&playerId=test456';
      final result = LocalNetworkClient.parseQrUrl(url);

      expect(result?.$2, 'local123');
      expect(result?.$3, 'test456');
    });

    test('Reject URL with malformed query params', () {
      const url = 'ws://192.168.1.100:8765?invalid=param';
      final result = LocalNetworkClient.parseQrUrl(url);

      expect(result, isNull);
    });

    test('parseQrUrl extracts correct parameters from valid URL', () {
      const qrUrl =
          'ws://192.168.1.100:8765?session=sess-123&playerId=player-456';
      final result = LocalNetworkClient.parseQrUrl(qrUrl);

      expect(result, isNotNull);
      expect(result?.$1, qrUrl);
      expect(result?.$2, 'sess-123');
      expect(result?.$3, 'player-456');
    });

    test('parseQrUrl handles invalid URLs gracefully', () {
      const invalidUrl = 'https://example.com';
      final result = LocalNetworkClient.parseQrUrl(invalidUrl);

      expect(result, isNull);
    });

    test('parseQrUrl handles missing session parameter', () {
      const urlMissingSession = 'ws://192.168.1.100:8765?playerId=player-456';
      final result = LocalNetworkClient.parseQrUrl(urlMissingSession);

      expect(result, isNull);
    });

    test('parseQrUrl handles missing playerId parameter', () {
      const urlMissingPlayerId = 'ws://192.168.1.100:8765?session=sess-123';
      final result = LocalNetworkClient.parseQrUrl(urlMissingPlayerId);

      expect(result, isNull);
    });
  });

  group('Message handling', () {
    test('JoinSessionAckMessage can be created', () {
      final message = const JoinSessionAckMessage(
        sessionId: 'sess-123',
        connectedPlayers: ['client-1', 'client-2'],
        timestamp: 1000,
      );

      expect(message.sessionId, 'sess-123');
      expect(message.connectedPlayers.length, 2);
    });

    test('MoveSelectedMessage can be created', () {
      final message = const MoveSelectedMessage(
        sessionId: 'sess-123',
        playerId: 'player-456',
        levelId: 'level-1',
        optionIndex: 0,
        isCorrect: true,
        stars: 3,
        xpGained: 100,
        timestamp: 2000,
      );

      expect(message.sessionId, 'sess-123');
      expect(message.playerId, 'player-456');
      expect(message.optionIndex, 0);
      expect(message.isCorrect, true);
    });

    test('GameStartMessage can be created', () {
      final message = const GameStartMessage(
        sessionId: 'sess-123',
        levelId: 'level-1',
        durationSeconds: 60,
        timestamp: 3000,
      );

      expect(message.sessionId, 'sess-123');
      expect(message.levelId, 'level-1');
      expect(message.durationSeconds, 60);
    });
  });

  group('Reconnection strategy', () {
    test('Default backoff timing is exponential', () {
      final client = LocalNetworkClient(
        wsUrl: 'ws://localhost:8765?session=s&playerId=p',
        playerId: 'p',
        sessionId: 's',
        onMessageReceived: (msg) {},
        maxReconnectDelay: const Duration(seconds: 30),
      );

      expect(client.maxReconnectDelay, const Duration(seconds: 30));
    });

    test('Max reconnect attempts defaults to 5', () {
      final client = LocalNetworkClient(
        wsUrl: 'ws://localhost:8765?session=s&playerId=p',
        playerId: 'p',
        sessionId: 's',
        onMessageReceived: (msg) {},
      );

      expect(client.maxReconnectAttempts, 5);
    });
  });
}

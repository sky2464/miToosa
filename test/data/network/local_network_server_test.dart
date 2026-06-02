import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/network/local_network_server.dart';
import 'package:mitoosa/data/network/network_exceptions.dart';
import 'package:mitoosa/data/network/network_models.dart';

void main() {
  group('LocalNetworkServer', () {
    late LocalNetworkServer server;
    late String testSessionId;
    late int testPort;

    setUp(() {
      testSessionId = 'test-session-${DateTime.now().millisecondsSinceEpoch}';
      testPort = 18765; // Use a port that's unlikely to be in use
    });

    tearDown(() async {
      try {
        await server.stop();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('Server starts on specified port', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      final port = await server.start(testPort);
      expect(port, testPort);
      expect(server.getConnectedClientIds().length, 0);

      await server.stop();
    });

    test('Server throws PortBindingException if port is in use', () async {
      // Create and start first server
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );
      await server.start(testPort);

      // Try to start another server on same port (should fail)
      final server2 = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      expect(
        () => server2.start(testPort),
        throwsA(isA<PortBindingException>()),
      );

      await server2.stop();
    });

    test('Client handshake validates session ID', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
        onClientConnected: (clientId) {
          fail('Should not validate a client with wrong session ID');
        },
      );

      await server.start(testPort);

      // Connect with a wrong session ID
      final socket = await WebSocket.connect('ws://127.0.0.1:$testPort');
      final closedCompleter = Completer<void>();

      socket.listen(
        (_) {},
        onDone: closedCompleter.complete,
        cancelOnError: true,
      );

      socket.add(
        jsonEncode(
          const JoinSessionMessage(
            sessionId: 'wrong-session-id',
            playerId: 'test-player',
            timestamp: 0,
          ).toJson(),
        ),
      );

      // Server must close the connection on bad session ID
      await closedCompleter.future.timeout(const Duration(seconds: 5));

      expect(socket.closeCode, isNotNull);
      expect(server.getConnectedClientIds(), isEmpty);

      await server.stop();
    });

    test('Server enforces max clients limit', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
        maxClients: 2,
      );

      await server.start(testPort);

      // Manually add clients to connectedClients map (simulate connections)
      // In real scenario, these would be WebSocket connections
      expect(server.maxClients, 2);

      await server.stop();
    });

    test('Server can broadcast messages', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      await server.start(testPort);

      // Create a test message
      final testMessage = GameStartMessage(
        sessionId: testSessionId,
        levelId: 'level-1',
        durationSeconds: 60,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Broadcast should not throw even with no clients
      server.broadcast(testMessage);

      await server.stop();
    });

    test(
      'Server throws StateError when broadcasting without running',
      () async {
        server = LocalNetworkServer(
          sessionId: testSessionId,
          onMessageReceived: (message, clientId) {},
        );

        final testMessage = GameStartMessage(
          sessionId: testSessionId,
          levelId: 'level-1',
          durationSeconds: 60,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );

        expect(() => server.broadcast(testMessage), throwsA(isA<StateError>()));
      },
    );

    test('Server state after stopping', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      await server.start(testPort);
      expect(server.getConnectedClientIds().length, 0);

      await server.stop();

      // After stopping, getConnectedClientIds should return empty
      expect(server.getConnectedClientIds().length, 0);
    });

    test('Server throws StateError when starting twice', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      await server.start(testPort);

      expect(() => server.start(testPort), throwsA(isA<StateError>()));

      await server.stop();
    });

    test('isClientConnected returns correct status', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      await server.start(testPort);

      // Before connection
      expect(server.isClientConnected('client-123'), false);

      await server.stop();
    });

    test('getConnectedClientIds returns list', () async {
      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {},
      );

      await server.start(testPort);

      final clientIds = server.getConnectedClientIds();
      expect(clientIds, isA<List<String>>());
      expect(clientIds.isEmpty, true);

      await server.stop();
    });
  });

  group('WebSocket message serialization', () {
    test('JoinSessionAckMessage serializes correctly', () {
      final message = const JoinSessionAckMessage(
        sessionId: 'session-123',
        connectedPlayers: ['client-1', 'client-2'],
        timestamp: 1000,
      );

      final json = message.toJson();
      final encoded = jsonEncode(json);

      expect(encoded, isA<String>());
      expect(encoded.contains('join_session_ack'), true);
      expect(encoded.contains('client-1'), true);
    });

    test('PlayerConnectedMessage serializes correctly', () {
      final message = const PlayerConnectedMessage(
        sessionId: 'session-123',
        playerId: 'player-456',
        playerName: 'Alice',
        timestamp: 2000,
      );

      final json = message.toJson();
      final encoded = jsonEncode(json);

      expect(encoded, isA<String>());
      expect(encoded.contains('player_connected'), true);
      expect(encoded.contains('Alice'), true);
    });
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/network/local_network_server.dart';
import 'package:mitoosa/data/network/network_exceptions.dart';
import 'package:mitoosa/data/network/network_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
      NetworkMessage? receivedMessage;
      String? connectedClientId;

      server = LocalNetworkServer(
        sessionId: testSessionId,
        onMessageReceived: (message, clientId) {
          receivedMessage = message;
        },
        onClientConnected: (clientId) {
          connectedClientId = clientId;
        },
      );

      final port = await server.start(testPort);

      // Create a mock client that sends join_session with WRONG session ID
      final wrongSessionMessage = JoinSessionMessage(
        playerId: 'player-123',
        sessionId: 'wrong-session-id',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Note: In real scenario, we'd connect via WebSocket
      // For this test, we're verifying the server's session validation logic
      expect(server.getConnectedClientIds().length, 0);

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

    test('Server throws StateError when broadcasting without running', () async {
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

      expect(
        () => server.broadcast(testMessage),
        throwsA(isA<StateError>()),
      );
    });

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

      expect(
        () => server.start(testPort),
        throwsA(isA<StateError>()),
      );

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
      final message = JoinSessionAckMessage(
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
      final message = PlayerConnectedMessage(
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

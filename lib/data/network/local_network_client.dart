import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/network/network_exceptions.dart';
import '../../data/network/network_models.dart';

typedef OnMessageReceived = void Function(NetworkMessage message);
typedef OnConnectionStateChanged = void Function(LocalNetworkClientState state);

/// Connection state for guest client.
enum LocalNetworkClientState { disconnected, connecting, connected, error }

/// WebSocket client for guest device connecting to host multiplayer session.
///
/// Responsibilities:
/// - Connect to host WebSocket via QR-decoded URL
/// - Perform handshake (join_session) with host
/// - Send and receive messages with automatic reconnection
/// - Implement exponential backoff for reconnection (1s, 2s, 4s, 8s, max 30s)
/// - Emit connection state changes
/// - Graceful disconnect
class LocalNetworkClient {
  final String wsUrl;
  final String playerId;
  final String sessionId;
  final OnMessageReceived onMessageReceived;
  final OnConnectionStateChanged? onConnectionStateChanged;
  final Duration handshakeTimeout;
  final Duration maxReconnectDelay;
  final int maxReconnectAttempts;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  LocalNetworkClientState _state = LocalNetworkClientState.disconnected;
  int _reconnectAttempts = 0;
  Duration _currentReconnectDelay = const Duration(seconds: 1);
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _isManualDisconnect = false;

  /// Create a new WebSocket client for joining a local network play session.
  LocalNetworkClient({
    required this.wsUrl,
    required this.playerId,
    required this.sessionId,
    required this.onMessageReceived,
    this.onConnectionStateChanged,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.maxReconnectAttempts = 5,
  });

  /// Get current connection state.
  LocalNetworkClientState get state => _state;

  /// Check if client is connected.
  bool get isConnected => _state == LocalNetworkClientState.connected;

  /// Connect to the host WebSocket.
  Future<void> connect() async {
    if (_isConnecting || _state == LocalNetworkClientState.connected) {
      return;
    }

    _isManualDisconnect = false;
    _reconnectAttempts = 0;
    _currentReconnectDelay = const Duration(seconds: 1);

    await _attemptConnection();
  }

  /// Disconnect from the host WebSocket.
  Future<void> disconnect() async {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _closeConnection();
  }

  /// Send a message to the host.
  void sendMessage(NetworkMessage message) {
    if (_channel == null || !isConnected) {
      throw StateError('Client is not connected');
    }

    try {
      final json = message.toJson();
      final encodedMessage = jsonEncode(json);
      _channel!.sink.add(encodedMessage);
    } catch (e) {
      debugPrint('Error sending message: $e');
      _handleError(e);
    }
  }

  /// Attempt to connect to the WebSocket server.
  Future<void> _attemptConnection() async {
    if (_isConnecting) return;

    _isConnecting = true;
    _setState(LocalNetworkClientState.connecting);

    try {
      debugPrint('Connecting to $wsUrl (attempt ${_reconnectAttempts + 1})');

      // Create WebSocket connection with timeout
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Set up handshake timeout
      final handshakeCompleted = Completer<bool>();
      final timeoutHandle = Timer(handshakeTimeout, () {
        if (!handshakeCompleted.isCompleted) {
          handshakeCompleted.completeError(
            NetworkTimeoutException(
              timeout: handshakeTimeout,
              message: 'Handshake timeout',
            ),
          );
        }
      });

      // Listen for messages
      _subscription = _channel!.stream.listen(
        (message) {
          try {
            _handleMessage(
              message as String,
              handshakeCompleted,
              timeoutHandle,
            );
          } catch (e) {
            debugPrint('Error handling message: $e');
            _handleError(e);
          }
        },
        onDone: () {
          timeoutHandle.cancel();
          _handleDisconnection();
        },
        onError: (error) {
          timeoutHandle.cancel();
          debugPrint('WebSocket error: $error');
          _handleError(error);
        },
        cancelOnError: true,
      );

      // Send handshake message
      final joinMessage = JoinSessionMessage(
        playerId: playerId,
        sessionId: sessionId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('Sending join_session handshake');
      _channel!.sink.add(jsonEncode(joinMessage.toJson()));

      // Wait for handshake completion with timeout
      try {
        await handshakeCompleted.future;
        _reconnectAttempts = 0;
        _currentReconnectDelay = const Duration(seconds: 1);
        _setState(LocalNetworkClientState.connected);
        _isConnecting = false;
      } on TimeoutException {
        handshakeCompleted.completeError(
          NetworkTimeoutException(
            timeout: handshakeTimeout,
            message: 'Handshake timeout',
          ),
        );
      }
    } catch (e) {
      _isConnecting = false;
      debugPrint('Connection error: $e');
      _handleConnectionError(e);
    }
  }

  /// Handle incoming message from host.
  void _handleMessage(
    String rawMessage,
    Completer<bool> handshakeCompleted,
    Timer timeoutHandle,
  ) {
    try {
      final json = jsonDecode(rawMessage);
      if (json is! Map<String, dynamic>) {
        throw InvalidMessageFormatException(
          messageData: rawMessage,
          message: 'Expected JSON object at root',
        );
      }

      final message = NetworkMessage.fromJson(json);

      // Handle handshake acknowledgment
      if (message is JoinSessionAckMessage && !handshakeCompleted.isCompleted) {
        timeoutHandle.cancel();
        if (message.sessionId != sessionId) {
          throw InvalidSessionException(
            sessionId: sessionId,
            message: 'Session ID mismatch in acknowledgment',
          );
        }
        debugPrint(
          'Handshake successful, joined with ${message.connectedPlayers.length} players',
        );
        handshakeCompleted.complete(true);
        return;
      }

      // Pass other messages to callback (only after handshake)
      if (handshakeCompleted.isCompleted && isConnected) {
        onMessageReceived(message);
      }
    } on NetworkException catch (e) {
      debugPrint('Network error: ${e.message}');
      if (!handshakeCompleted.isCompleted) {
        handshakeCompleted.completeError(e);
      } else {
        _handleError(e);
      }
    } catch (e) {
      debugPrint('Error processing message: $e');
      if (!handshakeCompleted.isCompleted) {
        handshakeCompleted.completeError(e);
      } else {
        _handleError(e);
      }
    }
  }

  /// Handle disconnection and attempt reconnection.
  void _handleDisconnection() {
    if (_isManualDisconnect) {
      _setState(LocalNetworkClientState.disconnected);
      _isConnecting = false;
      return;
    }

    _subscription?.cancel();
    _subscription = null;

    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      _setState(LocalNetworkClientState.error);
      _isConnecting = false;
      return;
    }

    _reconnectAttempts++;
    debugPrint(
      'Disconnected, will reconnect in ${_currentReconnectDelay.inSeconds}s '
      '(attempt $_reconnectAttempts/$maxReconnectAttempts)',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_currentReconnectDelay, () {
      // Exponential backoff: 1s, 2s, 4s, 8s, max 30s
      _currentReconnectDelay = Duration(
        seconds: (_currentReconnectDelay.inSeconds * 2).clamp(
          1,
          maxReconnectDelay.inSeconds,
        ),
      );
      _attemptConnection();
    });
  }

  /// Handle connection errors.
  void _handleConnectionError(Object error) {
    _subscription?.cancel();
    _subscription = null;

    if (_isManualDisconnect) {
      _setState(LocalNetworkClientState.disconnected);
      return;
    }

    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      _setState(LocalNetworkClientState.error);
      return;
    }

    _reconnectAttempts++;
    final nextDelay = Duration(
      seconds: (_currentReconnectDelay.inSeconds * 2).clamp(
        1,
        maxReconnectDelay.inSeconds,
      ),
    );

    debugPrint(
      'Connection error: $error, will retry in ${_currentReconnectDelay.inSeconds}s '
      '(attempt $_reconnectAttempts/$maxReconnectAttempts)',
    );

    _setState(LocalNetworkClientState.error);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_currentReconnectDelay, () {
      _currentReconnectDelay = nextDelay;
      _attemptConnection();
    });
  }

  /// Handle generic errors during message processing.
  void _handleError(Object error) {
    debugPrint('Error: $error');
    _handleDisconnection();
  }

  /// Close the WebSocket connection.
  Future<void> _closeConnection() async {
    _subscription?.cancel();
    _subscription = null;

    try {
      await _channel?.sink.close();
    } catch (e) {
      debugPrint('Error closing connection: $e');
    }

    _channel = null;
    _setState(LocalNetworkClientState.disconnected);
  }

  /// Update connection state and notify listeners.
  void _setState(LocalNetworkClientState newState) {
    if (_state != newState) {
      _state = newState;
      debugPrint('Connection state changed to: $newState');
      onConnectionStateChanged?.call(_state);
    }
  }

  /// Parse QR URL and extract connection parameters.
  static (String, String, String)? parseQrUrl(String qrText) {
    try {
      final uri = Uri.parse(qrText);

      if (!uri.scheme.startsWith('ws')) {
        return null;
      }

      final sessionId = uri.queryParameters['session'];
      final playerId = uri.queryParameters['playerId'];

      if (sessionId == null || playerId == null) {
        return null;
      }

      return (qrText, sessionId, playerId);
    } catch (e) {
      debugPrint('Error parsing QR URL: $e');
      return null;
    }
  }
}

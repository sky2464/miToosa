/// Base exception for all network-related errors.
abstract class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  NetworkException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'NetworkException: $message${originalError != null ? '\nCause: $originalError' : ''}';
}

/// Connection to WebSocket server failed.
class ConnectionFailedException extends NetworkException {
  ConnectionFailedException({
    required String message,
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
        );
}

/// Session ID or connection info invalid or expired.
class InvalidSessionException extends NetworkException {
  final String sessionId;

  InvalidSessionException({
    required this.sessionId,
    required String message,
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
        );
}

/// QR code could not be parsed or decoded.
class InvalidQRException extends NetworkException {
  final String? qrData;

  InvalidQRException({
    required String message,
    this.qrData,
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
        );
}

/// Session has expired (no activity for >5 minutes).
class SessionExpiredException extends NetworkException {
  final String sessionId;
  final DateTime expirationTime;

  SessionExpiredException({
    required this.sessionId,
    required this.expirationTime,
    dynamic originalError,
  }) : super(
          message: 'Session $sessionId expired at $expirationTime',
          originalError: originalError,
        );
}

/// Network request timed out (no response within threshold).
class NetworkTimeoutException extends NetworkException {
  final Duration timeout;

  NetworkTimeoutException({
    required String message,
    required this.timeout,
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
        );
}

/// Server port could not be bound (already in use or permission denied).
class PortBindingException extends NetworkException {
  final int port;

  PortBindingException({
    required this.port,
    required String message,
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
        );
}

/// Max reconnection attempts exceeded.
class MaxReconnectAttemptsExceededException extends NetworkException {
  final int attempts;
  final Duration maxBackoff;

  MaxReconnectAttemptsExceededException({
    required this.attempts,
    required this.maxBackoff,
    dynamic originalError,
  }) : super(
          message: 'Max reconnection attempts ($attempts) exceeded after backoff of $maxBackoff',
          originalError: originalError,
        );
}

/// Message could not be deserialized (malformed JSON or unknown type).
class InvalidMessageFormatException extends NetworkException {
  final String messageData;

  InvalidMessageFormatException({
    required this.messageData,
    required String message,
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
        );
}

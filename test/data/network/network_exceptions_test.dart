import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/network/network_exceptions.dart';

void main() {
  group('NetworkExceptions', () {
    group('ConnectionFailedException', () {
      test('creates with message', () {
        final e = ConnectionFailedException(message: 'Connection refused');
        expect(e.message, 'Connection refused');
        expect(e.originalError, isNull);
        expect(e, isA<NetworkException>());
      });

      test('creates with original error', () {
        final cause = Exception('socket error');
        final e = ConnectionFailedException(
          message: 'Connection failed',
          originalError: cause,
        );
        expect(e.originalError, cause);
        expect(e.toString(), contains('Connection failed'));
        expect(e.toString(), contains('socket error'));
      });
    });

    group('InvalidSessionException', () {
      test('creates with sessionId and message', () {
        final e = InvalidSessionException(
          sessionId: 'abc-123',
          message: 'Session not found',
        );
        expect(e.sessionId, 'abc-123');
        expect(e.message, 'Session not found');
        expect(e, isA<NetworkException>());
      });
    });

    group('InvalidQRException', () {
      test('creates without qrData', () {
        final e = InvalidQRException(message: 'Bad QR');
        expect(e.message, 'Bad QR');
        expect(e.qrData, isNull);
      });

      test('creates with qrData', () {
        final e = InvalidQRException(message: 'Bad QR', qrData: 'invalid://data');
        expect(e.qrData, 'invalid://data');
      });
    });

    group('SessionExpiredException', () {
      test('generates message from sessionId and time', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final e = SessionExpiredException(
          sessionId: 'session-xyz',
          expirationTime: now,
        );
        expect(e.sessionId, 'session-xyz');
        expect(e.expirationTime, now);
        expect(e.message, contains('session-xyz'));
        expect(e, isA<NetworkException>());
      });
    });

    group('NetworkTimeoutException', () {
      test('creates with duration', () {
        final e = NetworkTimeoutException(
          message: 'Timed out after 30s',
          timeout: const Duration(seconds: 30),
        );
        expect(e.timeout, const Duration(seconds: 30));
        expect(e.message, 'Timed out after 30s');
      });
    });

    group('PortBindingException', () {
      test('creates with port', () {
        final e = PortBindingException(port: 8765, message: 'Port in use');
        expect(e.port, 8765);
        expect(e.message, 'Port in use');
        expect(e, isA<NetworkException>());
      });
    });

    group('MaxReconnectAttemptsExceededException', () {
      test('creates with attempts and backoff', () {
        final e = MaxReconnectAttemptsExceededException(
          attempts: 5,
          maxBackoff: const Duration(seconds: 32),
        );
        expect(e.attempts, 5);
        expect(e.maxBackoff, const Duration(seconds: 32));
        expect(e.message, contains('5'));
        expect(e, isA<NetworkException>());
      });
    });

    group('InvalidMessageFormatException', () {
      test('creates with messageData', () {
        final e = InvalidMessageFormatException(
          messageData: '{"bad": "json"',
          message: 'Could not parse message',
        );
        expect(e.messageData, '{"bad": "json"');
        expect(e.message, 'Could not parse message');
        expect(e, isA<NetworkException>());
      });
    });

    group('NetworkException.toString()', () {
      test('includes message only when no original error', () {
        final e = ConnectionFailedException(message: 'No server');
        expect(e.toString(), 'NetworkException: No server');
      });

      test('includes cause when original error present', () {
        final e = ConnectionFailedException(
          message: 'No server',
          originalError: 'SocketException',
        );
        expect(e.toString(), contains('No server'));
        expect(e.toString(), contains('SocketException'));
      });
    });
  });
}

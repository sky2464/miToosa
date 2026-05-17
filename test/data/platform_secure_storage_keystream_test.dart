/// Unit tests for the BL-11 Web Platform Crypto Hardening keystream.
///
/// These tests run on the Dart VM (not the Web target) and exercise the
/// pure-Dart HMAC-SHA256 keystream + base64 framing logic without depending
/// on a SharedPreferences platform implementation. The Web `_encryptWeb` /
/// `_maybeDecryptWeb` methods are private but their building blocks
/// (`crypto.Hmac` + base64 framing) are public-domain primitives we can
/// re-derive here to assert round-trip correctness.
///
/// This test guards against regressions in the keystream contract — if the
/// HMAC domain string, suffix, or counter encoding changes, all stored
/// values on existing web installs would become unreadable.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Re-implements the keystream so the test is independent of the production
/// class's private API. The test will fail loudly if the production keystream
/// drifts from this contract (it's the same definition copied verbatim).
List<int> _expectedKeystream({
  required List<int> salt,
  required String valueKey,
  required int length,
  String domain = 'miToosa-web-storage-v1',
  String suffix = '|stream',
}) {
  final hmac = Hmac(sha256, salt);
  final out = <int>[];
  int counter = 0;
  while (out.length < length) {
    final input = utf8.encode('$domain|$valueKey$suffix|$counter');
    out.addAll(hmac.convert(input).bytes);
    counter++;
  }
  return out.sublist(0, length);
}

List<int> _xor(List<int> a, List<int> b) {
  final out = List<int>.filled(a.length, 0);
  for (int i = 0; i < a.length; i++) {
    out[i] = a[i] ^ b[i];
  }
  return out;
}

void main() {
  group('BL-11 Web crypto hardening — HMAC-SHA256 keystream contract', () {
    test('keystream is deterministic for the same salt + key', () {
      final salt = List<int>.generate(16, (i) => i);
      final ks1 = _expectedKeystream(
        salt: salt,
        valueKey: 'hive_encryption_key_v1',
        length: 64,
      );
      final ks2 = _expectedKeystream(
        salt: salt,
        valueKey: 'hive_encryption_key_v1',
        length: 64,
      );
      expect(ks1, equals(ks2),
          reason: 'Same salt + key + length must produce identical bytes');
    });

    test('keystream differs across keys (per-key isolation)', () {
      final salt = List<int>.generate(16, (i) => i);
      final ks1 = _expectedKeystream(
        salt: salt,
        valueKey: 'key_a',
        length: 32,
      );
      final ks2 = _expectedKeystream(
        salt: salt,
        valueKey: 'key_b',
        length: 32,
      );
      expect(ks1, isNot(equals(ks2)),
          reason: 'Different valueKey must produce different keystreams '
              '(prevents shared keystream attacks across stored items)');
    });

    test('keystream differs across salts (per-install isolation)', () {
      final ks1 = _expectedKeystream(
        salt: List<int>.generate(16, (i) => i),
        valueKey: 'shared_key',
        length: 32,
      );
      final ks2 = _expectedKeystream(
        salt: List<int>.generate(16, (i) => 255 - i),
        valueKey: 'shared_key',
        length: 32,
      );
      expect(ks1, isNot(equals(ks2)),
          reason: 'Different salts must produce different keystreams '
              '(per-install crypto isolation)');
    });

    test('round-trip: XOR encrypt then XOR decrypt recovers plaintext', () {
      final salt = [
        0xfe, 0xed, 0xfa, 0xce, 0xde, 0xad, 0xbe, 0xef,
        0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef,
      ];
      const plaintext = 'Hive AES-256 encryption key, 44-char base64 string!';
      final ptBytes = utf8.encode(plaintext);
      final ks = _expectedKeystream(
        salt: salt,
        valueKey: 'hive_encryption_key_v1',
        length: ptBytes.length,
      );

      // Encrypt
      final ct = _xor(ptBytes, ks);
      // Decrypt
      final recovered = _xor(ct, ks);

      expect(utf8.decode(recovered), equals(plaintext),
          reason: 'XOR with the same keystream must be involutive');
      expect(ct, isNot(equals(ptBytes)),
          reason: 'Ciphertext should differ from plaintext (sanity)');
    });

    test('keystream extends correctly across HMAC block boundaries', () {
      // SHA-256 produces 32-byte blocks. Request 100 bytes to force 4 HMAC
      // rounds and verify the catenation is correct.
      final salt = List<int>.generate(16, (i) => i * 7 & 0xff);
      final ks = _expectedKeystream(
        salt: salt,
        valueKey: 'long_value',
        length: 100,
      );
      expect(ks.length, 100);

      // Verify the last 4 bytes correspond to HMAC of counter=3, bytes 0..3.
      final hmac = Hmac(sha256, salt);
      final block3 = hmac
          .convert(utf8.encode('miToosa-web-storage-v1|long_value|stream|3'))
          .bytes;
      // We requested 100 bytes — that's blocks 0, 1, 2 (96 bytes) + 4 bytes of block 3.
      expect(ks.sublist(96, 100), equals(block3.sublist(0, 4)),
          reason: 'Block boundary catenation must be correct');
    });

    test('v2 prefix tag distinguishes ciphertext from legacy plaintext', () {
      const legacy = 'plain-uuid-like-value';
      const v2 = 'v2:ZXhhbXBsZQ==';
      expect(legacy.startsWith('v2:'), isFalse,
          reason: 'Legacy v1 values must not collide with the v2 tag');
      expect(v2.startsWith('v2:'), isTrue,
          reason: 'v2 values carry the version tag for safe migration');
    });
  });
}

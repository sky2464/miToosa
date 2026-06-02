import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform secure storage wrapper.
///
/// ## Threat model
///
/// On mobile and desktop platforms this uses `flutter_secure_storage` which
/// stores data in platform-provided secure enclaves (iOS Keychain, Android
/// Keystore, macOS Keychain, Windows Credential Manager, libsecret). Values
/// stored there are encrypted at rest by the platform and are not accessible
/// to other apps.
///
/// On Web the platform provides no built-in secure-enclave equivalent.
/// `localStorage` is plaintext and visible to any same-origin JS. This class
/// applies a per-install **keystream obfuscation** (BL-11 hardening, v2) on
/// Web so that values stored in `localStorage` are NOT trivially readable
/// from devtools or by exfiltration of `localStorage` contents alone:
///
///   1. On first call the class generates a **16-byte per-install salt** via
///      `Random.secure()` and stores it under [_kSaltKey] in `localStorage`.
///   2. Each stored value is XOR-encrypted against a keystream derived from
///      `HMAC-SHA256(salt, 'miToosa-web-storage-v1' || valueKey || counter)`.
///      The HMAC secret string lives in the compiled JS bundle, raising the
///      bar for an attacker that has only `localStorage` contents.
///   3. The ciphertext is base64-encoded and stored under the original key.
///   4. Legacy v1 plaintext entries are read transparently and silently
///      re-encrypted on the next write.
///
/// **Limitations of the Web path** (documented for honesty):
///   - Same-origin JS injection can derive the HMAC key by reading the JS
///     bundle. This obfuscation does NOT defend against XSS or supply-chain
///     attacks inside the same origin. Use a strong CSP to mitigate.
///   - True non-extractable keys require `crypto.subtle` + `IndexedDB`. A
///     follow-up may upgrade to that if the Web build becomes a Tier-1
///     surface and an XSS/CSP audit identifies higher-value targets.
///   - Browser private-mode and storage clearing wipe both the salt and the
///     ciphertext, so a fresh anonymous user ID is generated. This is the
///     same behavior as `flutter_secure_storage` on platforms where the
///     keychain is reset.
class PlatformSecureStorage {
  /// Key used to store the per-install salt in `localStorage` on Web.
  static const String _kSaltKey = '_miToosa_web_storage_salt_v2';

  /// HMAC domain separator — lives in the JS bundle, raising the bar for an
  /// attacker with `localStorage` access only.
  static const String _kHmacDomain = 'miToosa-web-storage-v1';

  /// Suffix appended to a [valueKey] so the keystream is per-key (prevents
  /// two values that share a length from sharing a keystream).
  static const String _kKeystreamSuffix = '|stream';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  /// Cached per-install salt for the lifetime of this isolate.
  List<int>? _saltCache;

  Future<bool> containsKey({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    }
    return await _secure.containsKey(key: key);
  }

  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(key);
      if (stored == null) return null;
      return _maybeDecryptWeb(key: key, stored: stored);
    }
    return await _secure.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final ciphertext = await _encryptWeb(key: key, value: value);
      await prefs.setString(key, ciphertext);
      return;
    }
    await _secure.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }
    await _secure.delete(key: key);
  }

  // ─── Web hardening internals (BL-11) ────────────────────────────────────

  /// Tag prefix written ahead of obfuscated values so we can distinguish
  /// v2 ciphertext from legacy v1 plaintext when reading.
  static const String _v2Prefix = 'v2:';

  /// Encrypts [value] for storage in `localStorage` using a per-key
  /// HMAC-SHA256-derived keystream. Output is `v2:<base64-ciphertext>`.
  Future<String> _encryptWeb({
    required String key,
    required String value,
  }) async {
    final valueBytes = utf8.encode(value);
    final keystream = await _keystreamFor(
      valueKey: key,
      length: valueBytes.length,
    );
    final out = List<int>.filled(valueBytes.length, 0);
    for (int i = 0; i < valueBytes.length; i++) {
      out[i] = valueBytes[i] ^ keystream[i];
    }
    return '$_v2Prefix${base64Encode(out)}';
  }

  /// Reads a stored value, decrypting v2 ciphertext or returning legacy
  /// plaintext unchanged. Legacy plaintext is migrated to v2 on the next
  /// write call by the caller (no implicit re-write here, to keep `read`
  /// side-effect-free and idempotent).
  Future<String?> _maybeDecryptWeb({
    required String key,
    required String stored,
  }) async {
    if (!stored.startsWith(_v2Prefix)) {
      // Legacy v1 plaintext — return as-is. Subsequent write() will upgrade.
      return stored;
    }
    final ciphertext = base64Decode(stored.substring(_v2Prefix.length));
    final keystream = await _keystreamFor(
      valueKey: key,
      length: ciphertext.length,
    );
    final out = List<int>.filled(ciphertext.length, 0);
    for (int i = 0; i < ciphertext.length; i++) {
      out[i] = ciphertext[i] ^ keystream[i];
    }
    return utf8.decode(out);
  }

  /// Builds a deterministic keystream of [length] bytes for [valueKey] using
  /// `HMAC-SHA256(salt, domain || valueKey || suffix || counter)` chained
  /// across counters. Each 32-byte HMAC output forms one keystream block.
  Future<List<int>> _keystreamFor({
    required String valueKey,
    required int length,
  }) async {
    final salt = await _getOrCreateSalt();
    final hmac = Hmac(sha256, salt);
    final out = <int>[];
    int counter = 0;
    while (out.length < length) {
      final input = utf8.encode(
        '$_kHmacDomain|$valueKey$_kKeystreamSuffix|$counter',
      );
      out.addAll(hmac.convert(input).bytes);
      counter++;
    }
    return out.sublist(0, length);
  }

  /// Returns the per-install salt, generating and persisting a new one on
  /// first call. The salt is itself stored in plaintext `localStorage` —
  /// it's a public unique-per-install value, not a secret. The secret is
  /// the HMAC domain string that lives in the JS bundle.
  Future<List<int>> _getOrCreateSalt() async {
    if (_saltCache != null) return _saltCache!;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kSaltKey);
    if (existing != null) {
      _saltCache = base64Decode(existing);
      return _saltCache!;
    }
    final rand = Random.secure();
    final salt = List<int>.generate(16, (_) => rand.nextInt(256));
    await prefs.setString(_kSaltKey, base64Encode(salt));
    _saltCache = salt;
    return salt;
  }

  /// Test-only: reset the in-memory salt cache so a new SharedPreferences
  /// instance picks up a fresh salt. Used in unit tests.
  @visibleForTesting
  void debugResetSaltCache() {
    _saltCache = null;
  }
}

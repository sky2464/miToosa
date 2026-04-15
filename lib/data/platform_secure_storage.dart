import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform secure storage wrapper.
///
/// IMPORTANT: On Web this implementation falls back to `SharedPreferences`,
/// which uses the browser's `localStorage` and is NOT secure for secrets or
/// cryptographic keys. Do NOT assume values stored via this class on Web are
/// encrypted or protected. For truly sensitive data on Web, provide an
/// opt-in server-backed sync or inform users that data is stored in plaintext.
///
/// On mobile and desktop platforms this uses `flutter_secure_storage` which
/// stores data in platform-provided secure enclaves (Keychain / Keystore).
class PlatformSecureStorage {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

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
      return prefs.getString(key);
    }
    return await _secure.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
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
}

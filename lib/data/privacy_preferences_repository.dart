import 'package:shared_preferences/shared_preferences.dart';

/// Bound at app startup from [main]; tests may rebind with a fake.
IPrivacyPreferencesRepository? _boundPrivacyPreferencesRepository;

void bindPrivacyPreferencesRepository(IPrivacyPreferencesRepository repository) {
  _boundPrivacyPreferencesRepository = repository;
}

IPrivacyPreferencesRepository get boundPrivacyPreferencesRepository {
  final bound = _boundPrivacyPreferencesRepository;
  if (bound == null) {
    throw StateError(
      'Privacy preferences repository not bound — call bindPrivacyPreferencesRepository in main()',
    );
  }
  return bound;
}

/// Local anonymous-analytics opt-out preference (default enabled).
abstract class IPrivacyPreferencesRepository {
  Future<bool> isAnalyticsEnabled();

  Future<void> setAnalyticsEnabled(bool enabled);
}

class SharedPreferencesPrivacyPreferencesRepository
    implements IPrivacyPreferencesRepository {
  SharedPreferencesPrivacyPreferencesRepository(this._prefs);

  static const analyticsEnabledKey = 'privacy_analytics_enabled';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesPrivacyPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesPrivacyPreferencesRepository(prefs);
  }

  @override
  Future<bool> isAnalyticsEnabled() async {
    return _prefs.getBool(analyticsEnabledKey) ?? true;
  }

  @override
  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _prefs.setBool(analyticsEnabledKey, enabled);
  }
}

/// In-memory fake for unit tests.
class FakePrivacyPreferencesRepository implements IPrivacyPreferencesRepository {
  bool? storedValue;

  @override
  Future<bool> isAnalyticsEnabled() async => storedValue ?? true;

  @override
  Future<void> setAnalyticsEnabled(bool enabled) async {
    storedValue = enabled;
  }
}

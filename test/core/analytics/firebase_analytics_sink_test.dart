import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics/firebase_analytics_sink.dart';

void main() {
  group('FirebaseAnalyticsSink.sanitizeParameters', () {
    test('returns null when all values are null', () {
      final result = FirebaseAnalyticsSink.sanitizeParameters({
        'a': null,
        'b': null,
      });

      expect(result, isNull);
    });

    test('keeps primitive firebase-safe types', () {
      final result = FirebaseAnalyticsSink.sanitizeParameters({
        'string': 'value',
        'int': 1,
        'double': 1.5,
        'bool': true,
      });

      expect(result, {
        'string': 'value',
        'int': 1,
        'double': 1.5,
        'bool': true,
      });
    });

    test('converts DateTime to UTC iso8601 string', () {
      final dt = DateTime.parse('2026-05-11T08:30:00+02:00');

      final result = FirebaseAnalyticsSink.sanitizeParameters({
        'timestamp': dt,
      });

      expect(result, {'timestamp': dt.toUtc().toIso8601String()});
    });

    test('converts Duration to milliseconds', () {
      final result = FirebaseAnalyticsSink.sanitizeParameters({
        'elapsed': const Duration(seconds: 2, milliseconds: 250),
      });

      expect(result, {'elapsed': 2250});
    });

    test('stringifies unsupported object values', () {
      const unsupported = _Unsupported('demo');

      final result = FirebaseAnalyticsSink.sanitizeParameters({
        'unsupported': unsupported,
      });

      expect(result, {'unsupported': 'Unsupported(demo)'});
    });

    test('drops null values but preserves non-null values', () {
      final result = FirebaseAnalyticsSink.sanitizeParameters({
        'a': null,
        'b': 'ok',
      });

      expect(result, {'b': 'ok'});
    });
  });
}

class _Unsupported {
  final String value;

  const _Unsupported(this.value);

  @override
  String toString() => 'Unsupported($value)';
}

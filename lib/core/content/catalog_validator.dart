import 'package:mitoosa/core/content_provider.dart';

/// Approved catalog categories for shipped puzzle tracks.
class TrackCategory {
  TrackCategory._();

  static const Set<String> allowlist = {
    'memory',
    'logic',
    'speed',
    'spatial',
  };
}

/// Thrown when bundled catalog content fails schema or integrity checks.
class CatalogValidationException implements Exception {
  CatalogValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() =>
      'CatalogValidationException: ${errors.join('; ')}';
}

/// Validates worlds.json rows and parsed [TrackDefinition] lists.
///
/// Intended for use by [ContentProvider] during `init()` and by content tests.
class CatalogValidator {
  CatalogValidator._();

  static const int expectedTrackCount = 23;

  static const String _iconAssetPrefix = 'assets/images/icons/';

  /// Validates a single worlds.json record before or after parsing.
  static void validateTrackRecord(Map<String, dynamic> json) {
    final errors = <String>[];
    final id = json['id']?.toString();
    final trackLabel = id ?? '<unknown>';

    if (id == null || id.isEmpty) {
      errors.add('missing id');
    }

    final category = json['category'];
    if (category == null || category.toString().trim().isEmpty) {
      errors.add('track $trackLabel: missing category');
    } else if (!TrackCategory.allowlist.contains(category)) {
      errors.add(
        'track $trackLabel: unknown category "$category" '
        '(expected one of ${TrackCategory.allowlist.join(', ')})',
      );
    }

    final iconAsset = json['iconAsset'];
    if (iconAsset == null || iconAsset.toString().trim().isEmpty) {
      errors.add('track $trackLabel: missing iconAsset');
    } else if (!_isAllowedIconAssetPath(iconAsset.toString())) {
      errors.add(
        'track $trackLabel: iconAsset must be under $_iconAssetPrefix',
      );
    }

    if (errors.isNotEmpty) {
      throw CatalogValidationException(errors);
    }
  }

  /// Validates the full shipped catalog after parsing.
  static void validateTracks(List<TrackDefinition> tracks) {
    final errors = <String>[];

    if (tracks.length != expectedTrackCount) {
      errors.add(
        'expected $expectedTrackCount tracks, got ${tracks.length}',
      );
    }

    final ids = <String>{};
    for (final track in tracks) {
      if (track.id.isEmpty) {
        errors.add('track has empty id');
        continue;
      }
      if (ids.contains(track.id)) {
        errors.add('duplicate id: ${track.id}');
      }
      ids.add(track.id);

      if (!TrackCategory.allowlist.contains(track.category)) {
        errors.add(
          'track ${track.id}: category "${track.category}" not in allowlist',
        );
      }
    }

    if (ids.length != tracks.length) {
      errors.add('track ids must be unique');
    }

    if (errors.isNotEmpty) {
      throw CatalogValidationException(errors);
    }
  }

  static bool _isAllowedIconAssetPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.startsWith(_iconAssetPrefix) &&
        !normalized.contains('..');
  }
}

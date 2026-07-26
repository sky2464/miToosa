import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Result of invoking the native share sheet for the daily wedge bonus.
enum ShareBonusStatus { success, dismissed, unavailable }

/// Narrow adapter around share_plus — injectable for tests.
class ShareBonusService {
  ShareBonusService({SharePlus? sharePlus})
    : _sharePlus = sharePlus ?? SharePlus.instance;

  final SharePlus _sharePlus;

  static const String shareMessage =
      'Train your brain with miToosa — 25 free puzzle games every day!';

  Future<ShareBonusStatus> shareApp() async {
    try {
      final result = await _sharePlus.share(
        ShareParams(text: shareMessage, subject: 'Try miToosa'),
      );
      return switch (result.status) {
        ShareResultStatus.success => ShareBonusStatus.success,
        ShareResultStatus.dismissed => ShareBonusStatus.dismissed,
        ShareResultStatus.unavailable => ShareBonusStatus.unavailable,
      };
    } catch (_) {
      return ShareBonusStatus.unavailable;
    }
  }
}

final shareBonusServiceProvider = Provider<ShareBonusService>(
  (ref) => ShareBonusService(),
);

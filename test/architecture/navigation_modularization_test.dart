import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/navigation/track_detail_launch.dart';
import 'package:mitoosa/features/navigation/track_detail_screen.dart';
import 'package:mitoosa/features/navigation/widgets/track_detail_sheets.dart';

/// BL-38 AC-004 (T-004): navigation helpers remain available after extraction.
void main() {
  test('track detail modules are wired @smoke T-004', () {
    expect(TrackDetailScreen, isNotNull);
    expect(DifficultySelectionSheet, isNotNull);
    expect(showDifficultyWithTutorialGate, isNotNull);
    expect(showTrackDifficultySheet, isNotNull);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// BL-38 AC-001 (T-001): modularized targets stay at or below 500 lines.
///
/// Deferred (still above budget; documented in PR): `gameplay_screen.dart`,
/// `player_progress.dart` (Hive adapter extracted; model trim follow-up).
void main() {
  const maxLines = 500;

  const targets = <String>[
    'lib/core/engine/puzzle_generator.dart',
    'lib/core/engine/generators/puzzle_generator_support.dart',
    'lib/core/engine/generators/puzzle_generator_shape_rules.dart',
    'lib/core/engine/generators/puzzle_generator_logic_rules.dart',
    'lib/core/engine/generators/puzzle_generator_math_rules.dart',
    'lib/core/engine/generators/puzzle_generator_science_rules.dart',
    'lib/core/engine/generators/puzzle_generator_grid_rules.dart',
    'lib/data/player_progress_adapter.dart',
    'lib/features/navigation/track_detail_screen.dart',
    'lib/features/navigation/track_detail_launch.dart',
    'lib/features/navigation/widgets/track_detail_sheets.dart',
  ];

  test('BL-38 target files respect line budget @smoke T-001', () {
    for (final path in targets) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'missing $path');
      final lineCount = file.readAsLinesSync().length;
      expect(
        lineCount,
        lessThanOrEqualTo(maxLines),
        reason: '$path has $lineCount lines (max $maxLines)',
      );
    }
  });
}

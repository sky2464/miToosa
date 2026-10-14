import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';

void main() {
  test('PlayerProgressAdapter typeId unchanged after split', () {
    expect(PlayerProgressAdapter().typeId, 2);
  });
}

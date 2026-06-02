import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/local_play/local_play_mode_screen.dart';

void main() {
  group('LocalPlayModeScreen', () {
    testWidgets('Renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LocalPlayModeScreen())),
      );

      expect(find.byType(LocalPlayModeScreen), findsOneWidget);
      expect(find.text('Host a Game'), findsOneWidget);
      expect(find.text('Join a Game'), findsOneWidget);
    });
  });
}

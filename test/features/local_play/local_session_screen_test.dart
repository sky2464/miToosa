import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/local_play/local_session_screen.dart';

void main() {
  group('LocalSessionScreen', () {
    testWidgets('Renders without crashing - idle state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LocalSessionScreen())),
      );

      expect(find.byType(LocalSessionScreen), findsOneWidget);
      // Default state is idle
      expect(find.text('No active session'), findsOneWidget);
    });
  });
}

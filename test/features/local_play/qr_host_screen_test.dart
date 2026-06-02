import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/local_play/qr_host_screen.dart';

void main() {
  group('QRHostScreen', () {
    testWidgets('Widget renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: QRHostScreen())),
      );

      // Widget should render
      expect(find.byType(QRHostScreen), findsOneWidget);

      // Should show idle state by default (no session)
      expect(find.text('No active session'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/features/local_play/qr_scanner_screen.dart';

void main() {
  group('QRScannerScreen', () {
    testWidgets('Widget renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QRScannerScreen(),
          ),
        ),
      );

      expect(find.byType(QRScannerScreen), findsOneWidget);
      // Entry form visible by default
      expect(find.text('Join a Local Game'), findsOneWidget);
    });

    testWidgets('Shows session URL and name fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QRScannerScreen(),
          ),
        ),
      );

      expect(find.text('Your Name'), findsOneWidget);
      expect(find.text('Session URL'), findsOneWidget);
      expect(find.text('Connect to Host'), findsOneWidget);
    });

    testWidgets('Validates empty URL field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QRScannerScreen(),
          ),
        ),
      );

      // Clear the name field so it triggers validation too
      await tester.tap(find.text('Connect to Host'));
      await tester.pump();

      // Validation error shown
      expect(find.text('Please enter the session URL'), findsOneWidget);
    });

    testWidgets('Validates URL must start with ws://', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QRScannerScreen(),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session URL'),
        'http://bad.url',
      );
      await tester.tap(find.text('Connect to Host'));
      await tester.pump();

      expect(find.text('URL must start with ws:// or wss://'), findsOneWidget);
    });
  });
}

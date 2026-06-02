import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/skill_radar.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('SkillRadar', () {
    testWidgets('renders at given size', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SkillRadar(
            size: 140,
            skills: [
              SkillScore(name: 'A', value: 60, color: Colors.blue),
              SkillScore(name: 'B', value: 80, color: Colors.purple),
              SkillScore(name: 'C', value: 50, color: Colors.cyan),
              SkillScore(name: 'D', value: 90, color: Colors.orange),
              SkillScore(name: 'E', value: 70, color: Colors.green),
              SkillScore(name: 'F', value: 65, color: Colors.pink),
            ],
          ),
        ),
      );
      final sized = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(SkillRadar),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sized.width, equals(140));
      expect(sized.height, equals(140));
    });

    testWidgets('contains a CustomPaint for the radar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SkillRadar(
            skills: [
              SkillScore(name: 'A', value: 50, color: Colors.blue),
              SkillScore(name: 'B', value: 50, color: Colors.purple),
              SkillScore(name: 'C', value: 50, color: Colors.cyan),
              SkillScore(name: 'D', value: 50, color: Colors.orange),
              SkillScore(name: 'E', value: 50, color: Colors.green),
              SkillScore(name: 'F', value: 50, color: Colors.pink),
            ],
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(SkillRadar),
          matching: find.byType(CustomPaint),
        ),
        findsAtLeast(1),
      );
    });
  });
}

import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Aetheric Pulse progress bar.
/// 4px height, blue→purple gradient fill, cyan glow shadow.
/// [value] must be between 0.0 and 1.0.
class KineticProgressBar extends StatelessWidget {
  final double value;
  final Gradient? gradient;
  final double height;

  const KineticProgressBar({
    super.key,
    required this.value,
    this.gradient,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final fillGradient = gradient ?? AethericPulseDark.gradPrimary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AethericPulseDark.glassFill,
        borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
      ),
      child: Stack(
        children: [
          if (clampedValue > 0)
            FractionallySizedBox(
              widthFactor: clampedValue,
              child: Container(
                decoration: BoxDecoration(
                  gradient: fillGradient,
                  borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4022D3EE),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

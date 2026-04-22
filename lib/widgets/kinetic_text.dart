import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Text rendered with the kinetic purple→cyan gradient.
class KineticText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const KineticText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          KineticObsidian.kineticGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

/// A thin [height]-px horizontal bar with the kinetic gradient and cyan glow.
class KineticProgressBar extends StatelessWidget {
  final double percent;   // 0–100
  final double height;
  final bool glow;

  const KineticProgressBar({
    super.key,
    required this.percent,
    this.height = 3,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillWidth = constraints.maxWidth * (percent.clamp(0, 100) / 100);
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: KineticObsidian.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KineticObsidian.radiusFull),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: fillWidth,
              height: height,
              decoration: BoxDecoration(
                gradient: KineticObsidian.kineticGradient,
                borderRadius:
                    BorderRadius.circular(KineticObsidian.radiusFull),
                boxShadow: glow
                    ? const [
                        BoxShadow(
                          color: Color(0x8000F0FF),
                          blurRadius: 10,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

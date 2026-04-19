import 'package:flutter/material.dart';

class SessionStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const SessionStat({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor ?? theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

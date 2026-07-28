import 'package:flutter/material.dart';

import '../../theme/design_system.dart';
import 'privacy_disclosure_copy.dart';

/// In-app privacy policy route (source-aligned with docs/PRIVACY-POLICY.md).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kPrivacyPolicyScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
        children: [
          Text(
            kPrivacyPolicySummary,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AethericPulseDark.spaceMd),
          Text(
            'Local data: progress, preferences, and encrypted saves remain on '
            'your device until you uninstall or reset progress.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AethericPulseDark.spaceSm),
          Text(
            'Analytics: optional anonymous events when enabled. No advertising '
            'ID collection or ad personalization.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AethericPulseDark.spaceSm),
          Text(
            'Contact: sky2464@gmail.com',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

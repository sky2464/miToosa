/// miToosa design system — barrel re-export.
///
/// Token classes live in dedicated files to keep each under the 500-line cap:
///   * [KineticObsidian] + [MiToosaTheme] → `kinetic_obsidian.dart` (legacy
///     dark theme, retained for screens that still depend on it).
///   * [AethericPulseLight] → `aetheric_pulse_light.dart` (active light
///     theme).
///   * [AethericPulseDark] → `aetheric_pulse_dark.dart` (active dark theme).
///
/// Consumers continue to `import 'package:mitoosa/theme/design_system.dart';`
/// — this file fans out the public surface unchanged.
library;

export 'aetheric_pulse_dark.dart';
export 'aetheric_pulse_light.dart';
export 'kinetic_obsidian.dart';

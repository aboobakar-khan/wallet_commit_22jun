import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Ergonomic access to the design system from any [BuildContext]:
///   `context.colors.dawn`, `context.text.prayerName`.
/// Keeps widgets reading the semantic tokens rather than poking at ThemeData.
extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppText get text => Theme.of(this).extension<AppText>()!;
  TextTheme get type => Theme.of(this).textTheme;

  /// True when the platform/user requests reduced motion. Widgets combine this
  /// with any in-app override (see motion providers) before animating.
  bool get platformReduceMotion => MediaQuery.maybeOf(this)?.disableAnimations ?? false;
}

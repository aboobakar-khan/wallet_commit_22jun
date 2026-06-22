import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

export 'colors.dart';
export 'context_ext.dart';
export 'radii.dart';
export 'spacing.dart';
export 'typography.dart';

/// Builds the two hand-tuned [ThemeData]s from the semantic [AppColors].
/// Both themes are authored, not auto-derived — dark is not `.dark()` of light.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = buildTextTheme(ink: c.ink, inkMuted: c.inkMuted);
    final appText = AppText.build(ink: c.ink, inkMuted: c.inkMuted);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.dawn,
      onSecondary: c.ink,
      tertiary: c.sadaqah,
      onTertiary: c.onPrimary,
      error: c.sadaqah, // we never use a klaxon red; giving-rose carries concern
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.ink,
      surfaceContainerHighest: c.surfaceMuted,
      onSurfaceVariant: c.inkMuted,
      outline: c.hairline,
      outlineVariant: c.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: textTheme,
      primaryColor: c.primary,
      splashFactory: InkSparkle.splashFactory,
      // Keep ripples quiet — the feel comes from hand-built feedback, not chrome.
      splashColor: c.primary.withValues(alpha: 0.06),
      highlightColor: c.primary.withValues(alpha: 0.04),
      dividerColor: c.hairline,
      extensions: <ThemeExtension<dynamic>>[c, appText],
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(
        color: c.hairline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: c.ink, size: 22),
    );
  }
}

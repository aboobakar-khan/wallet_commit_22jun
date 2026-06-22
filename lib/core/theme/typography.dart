import 'package:flutter/material.dart';

/// Type system (see design/THESIS.md):
///   - Newsreader (soft editorial serif) for prayer names & lines of meaning.
///   - Hanken Grotesk (warm humanist sans) for all UI — deliberately NOT Inter.
///   - Tabular figures for money so amounts don't shimmer when they change.
///   - Amiri (Naskh) for Arabic spiritual phrases, shaped + RTL.
///
/// All three are bundled as assets (see pubspec) — no runtime fetch. Newsreader
/// and Hanken Grotesk are variable fonts; Flutter maps [TextStyle.fontWeight] to
/// the `wght` axis automatically.
///
/// Scale (sp): Display 32 / Title 24 / Headline 19 / Body 16 / Label 14 / Caption 12.
abstract final class FontFamilies {
  static const serif = 'Newsreader';
  static const sans = 'Hanken Grotesk';
  static const arabic = 'Amiri';
}

/// The ceremonial serif, money, and Arabic styles live on [AppText] so they read
/// as intentional, reserved registers rather than ambient defaults.
@immutable
class AppText extends ThemeExtension<AppText> {
  final TextStyle serifDisplay;
  final TextStyle serifTitle;
  final TextStyle prayerName;
  final TextStyle money;
  final TextStyle moneyLarge;
  final TextStyle arabic;

  const AppText({
    required this.serifDisplay,
    required this.serifTitle,
    required this.prayerName,
    required this.money,
    required this.moneyLarge,
    required this.arabic,
  });

  static AppText build({required Color ink, required Color inkMuted}) {
    return AppText(
      serifDisplay: TextStyle(
        fontFamily: FontFamilies.serif,
        fontSize: 32,
        height: 1.18,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: ink,
      ),
      serifTitle: TextStyle(
        fontFamily: FontFamilies.serif,
        fontSize: 24,
        height: 1.22,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: ink,
      ),
      prayerName: TextStyle(
        fontFamily: FontFamilies.serif,
        fontSize: 19,
        height: 1.1,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      money: TextStyle(
        fontFamily: FontFamilies.sans,
        fontSize: 16,
        height: 1.1,
        fontWeight: FontWeight.w500,
        color: ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      moneyLarge: TextStyle(
        fontFamily: FontFamilies.sans,
        fontSize: 32,
        height: 1.05,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        color: ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      arabic: TextStyle(
        fontFamily: FontFamilies.arabic,
        fontSize: 22,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
    );
  }

  @override
  AppText copyWith({
    TextStyle? serifDisplay,
    TextStyle? serifTitle,
    TextStyle? prayerName,
    TextStyle? money,
    TextStyle? moneyLarge,
    TextStyle? arabic,
  }) {
    return AppText(
      serifDisplay: serifDisplay ?? this.serifDisplay,
      serifTitle: serifTitle ?? this.serifTitle,
      prayerName: prayerName ?? this.prayerName,
      money: money ?? this.money,
      moneyLarge: moneyLarge ?? this.moneyLarge,
      arabic: arabic ?? this.arabic,
    );
  }

  @override
  AppText lerp(ThemeExtension<AppText>? other, double t) {
    if (other is! AppText) return this;
    return AppText(
      serifDisplay: TextStyle.lerp(serifDisplay, other.serifDisplay, t)!,
      serifTitle: TextStyle.lerp(serifTitle, other.serifTitle, t)!,
      prayerName: TextStyle.lerp(prayerName, other.prayerName, t)!,
      money: TextStyle.lerp(money, other.money, t)!,
      moneyLarge: TextStyle.lerp(moneyLarge, other.moneyLarge, t)!,
      arabic: TextStyle.lerp(arabic, other.arabic, t)!,
    );
  }
}

/// The base UI/body text theme — Hanken Grotesk across the scale.
TextTheme buildTextTheme({required Color ink, required Color inkMuted}) {
  TextStyle sans(double size, FontWeight weight,
      {double height = 1.35, double spacing = 0, Color? color}) {
    return TextStyle(
      fontFamily: FontFamilies.sans,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color ?? ink,
    );
  }

  return TextTheme(
    displayLarge: sans(32, FontWeight.w600, height: 1.1, spacing: -0.4),
    titleLarge: sans(24, FontWeight.w600, height: 1.2, spacing: -0.2),
    titleMedium: sans(19, FontWeight.w600, height: 1.25), // Headline
    bodyLarge: sans(16, FontWeight.w400, height: 1.45), // Body
    bodyMedium: sans(16, FontWeight.w400, height: 1.45, color: inkMuted),
    labelLarge: sans(14, FontWeight.w600, height: 1.2, spacing: 0.1), // Label
    labelMedium: sans(14, FontWeight.w500, height: 1.2, color: inkMuted),
    bodySmall: sans(12, FontWeight.w400, height: 1.3, color: inkMuted), // Caption
    labelSmall: sans(12, FontWeight.w500, height: 1.2, spacing: 0.3, color: inkMuted),
  );
}

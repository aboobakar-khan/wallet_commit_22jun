import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type system (see design/THESIS.md):
///   - Newsreader (soft editorial serif) for prayer names & lines of meaning.
///   - Hanken Grotesk (warm humanist sans) for all UI — deliberately NOT Inter.
///   - Tabular figures for money so amounts don't shimmer when they change.
///   - Amiri (Naskh) for Arabic spiritual phrases, shaped + RTL.
///
/// Scale (sp): Display 32 / Title 24 / Headline 19 / Body 16 / Label 14 / Caption 12.
///
/// The base [TextTheme] covers body/label/title chrome; the ceremonial serif,
/// money, and Arabic styles live on [AppText] so they read as intentional,
/// reserved registers rather than ambient defaults.
@immutable
class AppText extends ThemeExtension<AppText> {
  /// Large ceremonial serif — onboarding lines, the commitment summary line.
  final TextStyle serifDisplay;

  /// Section-scale serif — screen titles that should feel editorial.
  final TextStyle serifTitle;

  /// Prayer names on the Arc and detail (Fajr, Dhuhr…), serif, quiet weight.
  final TextStyle prayerName;

  /// Money — tabular figures, calm weight. Never louder than the prayer.
  final TextStyle money;

  /// Money at hero scale (rare — wallet balance), still calm.
  final TextStyle moneyLarge;

  /// Arabic spiritual phrases.
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
      serifDisplay: GoogleFonts.newsreader(
        fontSize: 32,
        height: 1.18,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: ink,
      ),
      serifTitle: GoogleFonts.newsreader(
        fontSize: 24,
        height: 1.22,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: ink,
      ),
      prayerName: GoogleFonts.newsreader(
        fontSize: 19,
        height: 1.1,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      money: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        height: 1.1,
        fontWeight: FontWeight.w500,
        color: ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      moneyLarge: GoogleFonts.hankenGrotesk(
        fontSize: 32,
        height: 1.05,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        color: ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      arabic: GoogleFonts.amiri(
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
    return GoogleFonts.hankenGrotesk(
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color ?? ink,
    );
  }

  return TextTheme(
    // Display reserved for the serif register; keep a sans fallback subtle.
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

import 'package:flutter/material.dart';

/// Semantic colour tokens for the two hand-tuned themes — "Sahar" (light/dawn)
/// and "Layl" (dark/night). Everything in the app derives from here; no widget
/// should hardcode a hex value.
///
/// Each accent has exactly one job (see design/THESIS.md):
///   - [primary]  grounded teal-green — the app's voice.
///   - [dawn]     warm amber — used ONLY for light & completion.
///   - [sadaqah]  muted clay rose — used ONLY where money becomes giving.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkMuted;
  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color dawn;
  final Color sadaqah;
  final Color hairline;

  /// Whether this is the dark ("Layl") register — lets a few widgets make
  /// register-aware micro-decisions (e.g. how light blooms read).
  final bool isNight;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkMuted,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.dawn,
    required this.sadaqah,
    required this.hairline,
    required this.isNight,
  });

  /// "Sahar" — the calm of pre-dawn. A cool sage ground, deliberately not cream.
  static const AppColors light = AppColors(
    bg: Color(0xFFEDF1EF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF6F8F7),
    ink: Color(0xFF14242A),
    inkMuted: Color(0xFF5C6B70),
    primary: Color(0xFF14695A),
    primaryPressed: Color(0xFF0F5447),
    onPrimary: Color(0xFFF3F7F5),
    dawn: Color(0xFFE3A857),
    sadaqah: Color(0xFFC97A6D),
    hairline: Color(0xFFDDE4E1),
    isNight: false,
  );

  /// "Layl" — deep teal-navy night. Hand-tuned, not auto-derived: primary and
  /// dawn are brightened so light still reads as light against a dark ground.
  static const AppColors dark = AppColors(
    bg: Color(0xFF0C1B22),
    surface: Color(0xFF122A33),
    surfaceMuted: Color(0xFF16323C),
    ink: Color(0xFFEAF1EE),
    inkMuted: Color(0xFF8FA3A8),
    primary: Color(0xFF2E9C86),
    primaryPressed: Color(0xFF257E6C),
    onPrimary: Color(0xFF07151B),
    dawn: Color(0xFFE9B36A),
    sadaqah: Color(0xFFD98B7D),
    hairline: Color(0xFF1E3A44),
    isNight: true,
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceMuted,
    Color? ink,
    Color? inkMuted,
    Color? primary,
    Color? primaryPressed,
    Color? onPrimary,
    Color? dawn,
    Color? sadaqah,
    Color? hairline,
    bool? isNight,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      dawn: dawn ?? this.dawn,
      sadaqah: sadaqah ?? this.sadaqah,
      hairline: hairline ?? this.hairline,
      isNight: isNight ?? this.isNight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      dawn: Color.lerp(dawn, other.dawn, t)!,
      sadaqah: Color.lerp(sadaqah, other.sadaqah, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      isNight: t < 0.5 ? isNight : other.isNight,
    );
  }
}

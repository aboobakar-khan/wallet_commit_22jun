import 'package:flutter/widgets.dart';

/// The motion system — the soul of the app (see design/THESIS.md §5).
///
/// Two registers that never blur:
///   - [Register A — Ceremonial] the sky, light, the bloom. Slow, organic,
///     sine-eased. Beauty is allowed to take its time.
///   - [Register B — Tactile] taps, toggles, sheets. Quick, alive, and
///     CRITICALLY DAMPED — no bounce (bounce reads as a toy; wrong for worship).
abstract final class Motion {
  // ---- Register B: tactile / responsive ----
  static const Duration tap = Duration(milliseconds: 120);
  static const Duration state = Duration(milliseconds: 220);
  static const Duration transition = Duration(milliseconds: 340);

  /// Emphasized-decelerate — for sheets & entrances that arrive and settle.
  static const Curve decelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  // ---- Register A: ceremonial / ambient ----
  static const Duration bloom = Duration(milliseconds: 480);
  static const Duration settle = Duration(milliseconds: 900);
  static const Duration ambientBreath = Duration(milliseconds: 7000);

  /// Slow, symmetric, breath-like. Used for light blooming and sky settling.
  static const Curve sine = Cubic(0.37, 0.0, 0.18, 1.0);
  static const Curve gentleInOut = Cubic(0.45, 0.0, 0.2, 1.0);

  /// Stagger between the five nodes as the day reveals (Fajr→Isha).
  static const Duration nodeStagger = Duration(milliseconds: 60);

  /// Critically-damped spring for tactile state changes. Tuned to *settle*,
  /// never wobble (no overshoot → reads as considered, not playful).
  static SpringDescription get damped =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 180, ratio: 1.0);
}

/// Resolves motion against the user's reduced-motion preference.
///
/// When reduced motion is on, Register A (ambient/ceremonial) collapses to a
/// quiet fade and ambient loops are disabled. Register B keeps its quick state
/// changes (they aid comprehension) but loses any flourish.
@immutable
class MotionSpec {
  final bool reduceMotion;
  const MotionSpec(this.reduceMotion);

  Duration ambient(Duration full) =>
      reduceMotion ? const Duration(milliseconds: 180) : full;

  Curve ambientCurve() => reduceMotion ? Curves.easeOut : Motion.sine;

  /// Whether continuous ambient loops (sky shimmer, breathing) should run.
  bool get allowAmbientLoops => !reduceMotion;
}

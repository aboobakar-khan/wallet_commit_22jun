import 'package:flutter/widgets.dart';

/// Soft radii, differentiated by role — never 0, never bubbly.
/// (Anti-slop §7: "one border-radius on everything".)
abstract final class Radii {
  /// Inputs, chips, small controls.
  static const double small = 12;

  /// Cards, sheets, the primary surfaces.
  static const double card = 16;

  /// Large ceremonial surfaces (the Arc panel, top-up sheet).
  static const double large = 24;

  static const Radius rSmall = Radius.circular(small);
  static const Radius rCard = Radius.circular(card);
  static const Radius rLarge = Radius.circular(large);

  static const BorderRadius small_ = BorderRadius.all(rSmall);
  static const BorderRadius card_ = BorderRadius.all(rCard);
  static const BorderRadius large_ = BorderRadius.all(rLarge);

  /// Pill — for the calm balance chip and the prayer toggle track.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

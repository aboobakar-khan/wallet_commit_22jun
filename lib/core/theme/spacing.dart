/// 4-pt spacing base. Used with rhythm, not as a uniform 16 everywhere.
/// (See anti-slop checklist §7: "uniform 16px padding, no spatial rhythm".)
abstract final class Space {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// The breathing room a screen leans on — wider than the default 16 so the
  /// content feels held, not boxed.
  static const double screenGutter = 24;
}

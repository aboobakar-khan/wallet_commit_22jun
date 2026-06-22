/// The five daily prayers, in order. `arcT` is the node's horizontal position
/// along the Day's Arc (0 = dawn-left, 1 = night-right) — position encodes the
/// day, it does not decorate it (see THESIS §6).
enum Prayer {
  fajr(0.07, 'Fajr', 'الفجر'),
  dhuhr(0.34, 'Dhuhr', 'الظهر'),
  asr(0.55, 'Asr', 'العصر'),
  maghrib(0.78, 'Maghrib', 'المغرب'),
  isha(0.93, 'Isha', 'العشاء');

  const Prayer(this.arcT, this.displayName, this.arabicName);

  /// Horizontal position along the arc, 0..1.
  final double arcT;
  final String displayName;
  final String arabicName;

  /// The five prayers in canonical order.
  static const List<Prayer> ordered = [fajr, dhuhr, asr, maghrib, isha];
}

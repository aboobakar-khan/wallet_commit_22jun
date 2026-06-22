/// Date-only helpers. PrayerLogs and commitment bounds are keyed by calendar
/// day in the user's local time; we normalise to local midnight so equality and
/// difference math are unambiguous.
abstract final class Day {
  static DateTime only(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Inclusive whole-day difference (b - a) in days.
  static int between(DateTime a, DateTime b) =>
      only(b).difference(only(a)).inDays;

  /// A stable key for maps/fixtures, e.g. 2026-06-22.
  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

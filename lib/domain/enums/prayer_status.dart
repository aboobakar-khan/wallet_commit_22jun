/// The status of a single prayer on a single day.
///
/// Lenient rule (THESIS §3): only genuinely [missed] prayers ever count; [late]
/// is treated exactly like [prayed] and is never charged. A prayer with no log
/// is "pending" until the day locks, after which it becomes [missed].
enum PrayerStatus {
  prayed,
  late,
  missed;

  /// Whether this status keeps the prayer (no deduction). Late counts as kept.
  bool get isKept => this == prayed || this == late;
}
